local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local OreCancel = {}

-- Services
local rs = game:GetService("ReplicatedStorage")
local plrs = game:GetService("Players")
local runService = game:GetService("RunService")

-- Variables
local is_farming, is_mining = false, false
local sel_ore = nil
local tween_spd, y_offset = 30, 0
local ore_cancel_en = false
local ore_cancel_wl = {}
local skipped_rocks = {}

-- Tween system
local current_tween_conn = nil
local tween_cancelled = false

-- Ore list
local ore_list = {
    "Aite", "Amethyst", "Bananite", "Cardboardite", "Cobalt", "Copper", "Cuprite",
    "Dark Boneite", "Diamond", "Emerald", "Fichillium", "Gargantuan", "Galaxite",
    "Gold", "Heavenite", "Iron", "Lapis Lazuli", "Mushroomite", "Mythril", "Obsidian",
    "Platinum", "Poopite", "Quartz", "Ruby", "Sand Stone", "Sapphire", "Silver",
    "Slimite", "Stone", "Tin", "Titanium", "Topaz", "Uranium", "Volcanic Rock"
}

-- Helper functions
local function cancel_tween()
    tween_cancelled = true
    if current_tween_conn then
        current_tween_conn:Disconnect()
        current_tween_conn = nil
    end
end

local function get_hp(ore)
    local info = ore:FindFirstChild("infoFrame")
    if info and info:FindFirstChild("Frame") and info.Frame:FindFirstChild("rockHP") then
        return tonumber(info.Frame.rockHP.Text:match("[%d%.]+")) or 0
    end
    return nil
end

local function get_previews(rock)
    local out = {}
    for _, c in ipairs(rock:GetChildren()) do
        if c.Name == "Ore" then
            local nm = c:GetAttribute("Ore")
            if nm then table.insert(out, nm) end
        end
    end
    return out
end

local function should_mine(rock)
    if not ore_cancel_en then return true end
    local prev = get_previews(rock)
    if #prev == 0 or #ore_cancel_wl == 0 then return true end
    for _, p in ipairs(prev) do
        for _, w in ipairs(ore_cancel_wl) do
            if p == w then return true end
        end
    end
    return false
end

local function get_rocks()
    local out = {}
    local rocks = workspace:FindFirstChild("Rocks")
    if not rocks then return out end
    for _, area in ipairs(rocks:GetChildren()) do
        for _, spwn in ipairs(area:GetChildren()) do
            for _, r in ipairs(spwn:GetChildren()) do
                if r:FindFirstChild("Hitbox") then out[r.Name] = true end
            end
        end
    end
    local list = {}
    for nm in pairs(out) do table.insert(list, nm) end
    table.sort(list)
    return list
end

local function get_ores(tp)
    local out = {}
    local rocks = workspace:FindFirstChild("Rocks")
    if not rocks then return out end
    for _, area in ipairs(rocks:GetChildren()) do
        for _, spwn in ipairs(area:GetChildren()) do
            local r = spwn:FindFirstChild(tp)
            if r and r:FindFirstChild("Hitbox") then
                local hp = get_hp(r)
                if hp and hp > 0 and not skipped_rocks[r] then
                    table.insert(out, r)
                end
            end
        end
    end
    return out
end

-- Tool remote
local tool_evt
pcall(function()
    tool_evt = rs.Shared.Packages.Knit.Services.ToolService.RF.ToolActivated
end)

OreCancel.CustomTween = nil -- put ur tween

local function tween_to(pos, spd)
    if OreCancel.CustomTween then
        return OreCancel.CustomTween(pos, spd)
    end
    cancel_tween()
    tween_cancelled = false
    
    local char = plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local start = hrp.Position
    local dist = (pos - start).Magnitude
    local dur = math.max(dist / math.min(spd, 35), 0.1)
    local t0 = tick()
    local done = false
    
    current_tween_conn = runService.Heartbeat:Connect(function()
        if done or tween_cancelled or not hrp.Parent then
            if current_tween_conn then current_tween_conn:Disconnect() end
            current_tween_conn = nil
            done = true
            return
        end
        local a = math.min((tick() - t0) / dur, 1)
        hrp.CFrame = CFrame.new(start:Lerp(pos, a))
        if a >= 1 then done = true end
    end)
    
    while not done and not tween_cancelled do task.wait() end
end

OreCancel.CustomMine = nil -- put ur mine

local function mine(ore)
    if OreCancel.CustomMine then
        return OreCancel.CustomMine(ore)
    end
    if not ore or not ore:FindFirstChild("Hitbox") then return end
    local char = plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target = sel_ore
    
    if hrp and y_offset ~= 0 then
        local p = ore.Hitbox.Position
        hrp.CFrame = CFrame.new(p.X, p.Y + y_offset, p.Z)
        hrp.Anchored = true
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part ~= hrp then part.CanCollide = false end
        end
    end
    
    while ore and ore.Parent and is_farming and sel_ore == target and not tween_cancelled do
        local hp = get_hp(ore)
        if not hp or hp <= 0 then
            skipped_rocks[ore] = nil
            break
        end
        if ore_cancel_en and #get_previews(ore) > 0 and not should_mine(ore) then
            skipped_rocks[ore] = true
            break
        end
        if tool_evt then tool_evt:InvokeServer("Pickaxe") end
        task.wait(0.3)
    end
    
    if hrp and y_offset ~= 0 then hrp.Anchored = false end
end

-- Main loop
task.spawn(function()
    while true do
        task.wait(0.1)
        if is_farming and sel_ore and not is_mining then
            local ores = get_ores(sel_ore)
            if #ores > 0 and ores[1]:FindFirstChild("Hitbox") then
                is_mining = true
                tween_to(ores[1].Hitbox.Position, tween_spd)
                mine(ores[1])
                is_mining = false
            end
        end
        if not is_farming then is_mining = false end
    end
end)

-- Cleanup
task.spawn(function()
    while true do
        task.wait(30)
        for r in pairs(skipped_rocks) do
            if not r or not r.Parent then skipped_rocks[r] = nil end
        end
    end
end)

-- Control functions
function OreCancel.Enable()
    ore_cancel_en = true
    is_farming = true
    print("[OreCancel] Enabled")
end

function OreCancel.Disable()
    ore_cancel_en = false
    is_farming = false
    cancel_tween()
    local hrp = plrs.LocalPlayer.Character and plrs.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false end
    print("[OreCancel] Disabled")
end

function OreCancel.SetSpeed(spd)
    tween_spd = math.min(spd or 30, 35)
end

function OreCancel.SetYOffset(off)
    y_offset = off or 0
end

function OreCancel.SetWhitelist(list)
    ore_cancel_wl = list or {}
end

function OreCancel.SetRock(rock)
    sel_ore = rock
end

function OreCancel.ClearSkipped()
    skipped_rocks = {}
end

function OreCancel.IsEnabled()
    return ore_cancel_en and is_farming
end

-- UI
local Window = Fluent:CreateWindow({
    Title = "Ore Cancel",
    TabWidth = 160,
    Size = UDim2.fromOffset(400, 340),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tab = Window:AddTab({Title = "Farm", Icon = "pickaxe"})
local Options = Fluent.Options

local rocks = get_rocks()
if #rocks == 0 then rocks = {"None"} end

local RockDrop = Tab:AddDropdown("Rock", {
    Title = "Rock Type",
    Values = rocks,
    Default = 1
})
RockDrop:OnChanged(function(v)
    if sel_ore ~= v and is_farming then cancel_tween() end
    sel_ore = v
end)

Tab:AddButton({
    Title = "Refresh",
    Callback = function()
        rocks = get_rocks()
        if #rocks == 0 then rocks = {"None"} end
        RockDrop:SetValues(rocks)
    end
})

Tab:AddToggle("Farm", {Title = "Auto Farm", Default = false})
Options.Farm:OnChanged(function()
    is_farming = Options.Farm.Value
    if not is_farming then
        cancel_tween()
        local hrp = plrs.LocalPlayer.Character and plrs.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Anchored = false end
    end
end)

Tab:AddSlider("Speed", {Title = "Speed", Default = 30, Min = 10, Max = 35, Rounding = 0})
Options.Speed:OnChanged(function(v) tween_spd = v end)

Tab:AddSlider("YOff", {Title = "Y Offset", Default = 0, Min = -20, Max = 20, Rounding = 0})
Options.YOff:OnChanged(function(v) y_offset = v end)

Tab:AddParagraph({Title = "Ore Cancel", Content = "skip rocks without wanted ores"})

local CancelDrop = Tab:AddDropdown("Whitelist", {
    Title = "Wanted Ores",
    Values = ore_list,
    Multi = true,
    Default = {}
})
CancelDrop:OnChanged(function(v)
    ore_cancel_wl = {}
    for ore, en in pairs(v) do
        if en then table.insert(ore_cancel_wl, ore) end
    end
end)

Tab:AddToggle("Cancel", {Title = "Enable Ore Cancel", Default = false})
Options.Cancel:OnChanged(function()
    ore_cancel_en = Options.Cancel.Value
    if ore_cancel_en and #ore_cancel_wl == 0 then
        Fluent:Notify({Title = "yo", Content = "add ores to whitelist first", Duration = 3})
    end
end)

Tab:AddButton({
    Title = "Clear Skipped",
    Callback = function() skipped_rocks = {} end
})

Window:SelectTab(1)

return OreCancel
