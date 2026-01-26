local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local AutoMine = {}

-- Services
local rs = game:GetService("ReplicatedStorage")
local plrs = game:GetService("Players")
local runService = game:GetService("RunService")

-- Variables
local is_farming = false
local is_mining = false
local sel_ore = nil
local tween_spd = 30
local y_offset = 0

-- Tween system
local current_tween_conn = nil
local tween_cancelled = false

-- Helper Functions
local function cancel_current_tween()
    tween_cancelled = true
    if current_tween_conn then
        current_tween_conn:Disconnect()
        current_tween_conn = nil
    end
end

local function get_ore_hp(ore)
    local info = ore:FindFirstChild("infoFrame")
    if info and info:FindFirstChild("Frame") and info.Frame:FindFirstChild("rockHP") then
        return tonumber(info.Frame.rockHP.Text:match("[%d%.]+")) or 0
    end
    return nil
end


local function get_ore_insts(ore_tp)
    local insts = {}
    local rocks = workspace:FindFirstChild("Rocks")
    if not rocks then return insts end
    for _, area in ipairs(rocks:GetChildren()) do
        for _, spwn in ipairs(area:GetChildren()) do
            local ore_fld = spwn:FindFirstChild(ore_tp)
            if ore_fld and ore_fld:FindFirstChild("Hitbox") then
                local hp = get_ore_hp(ore_fld)
                if hp and hp > 0 then table.insert(insts, ore_fld) end
            end
        end
    end
    return insts
end

local function get_all_ore_tps()
    local ore_set = {}
    local rocks = workspace:FindFirstChild("Rocks")
    if not rocks then return {} end
    for _, area in ipairs(rocks:GetChildren()) do
        for _, spwn in ipairs(area:GetChildren()) do
            for _, ore_fld in ipairs(spwn:GetChildren()) do
                if ore_fld:FindFirstChild("Hitbox") then ore_set[ore_fld.Name] = true end
            end
        end
    end
    local ores = {}
    for ore_nm in pairs(ore_set) do table.insert(ores, ore_nm) end
    table.sort(ores)
    return ores
end

-- Tool remote
local function get_tool_act()
    return rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
end

local tool_act_evt
pcall(function() tool_act_evt = get_tool_act() end)

AutoMine.CustomTween = nil -- put ur tween if u want

local function tween_to_pos(tgt_pos, spd)
    if AutoMine.CustomTween then
        return AutoMine.CustomTween(tgt_pos, spd)
    end
    cancel_current_tween()
    tween_cancelled = false
    
    local plyr = plrs.LocalPlayer
    local char = plyr.Character or plyr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    
    local startPos = hrp.Position
    local dist = (tgt_pos - startPos).Magnitude
    local safeSpd = math.min(spd, 35)
    local dur = math.max(dist / safeSpd, 0.1)
    local startTime = tick()
    
    local done = false
    
    current_tween_conn = runService.Heartbeat:Connect(function()
        if done or tween_cancelled or not hrp or not hrp.Parent then
            if current_tween_conn then
                current_tween_conn:Disconnect()
                current_tween_conn = nil
            end
            done = true
            return
        end
        
        local elapsed = tick() - startTime
        local alpha = math.min(elapsed / dur, 1)
        
        local newPos = startPos:Lerp(tgt_pos, alpha)
        hrp.CFrame = CFrame.new(newPos)
        
        if alpha >= 1 then
            done = true
            if current_tween_conn then
                current_tween_conn:Disconnect()
                current_tween_conn = nil
            end
            hrp.CFrame = CFrame.new(tgt_pos)
        end
    end)
    
    while not done and not tween_cancelled do task.wait() end
end

AutoMine.CustomMine = nil -- put ur mine if u want

local function mine_ore(ore)
    if AutoMine.CustomMine then
        return AutoMine.CustomMine(ore)
    end
    if not ore or not ore:FindFirstChild("Hitbox") then return end
    local char = plrs.LocalPlayer and plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target_ore = sel_ore
    
    if hrp and y_offset ~= 0 then
        local ore_pos = ore.Hitbox.CFrame.Position
        hrp.CFrame = CFrame.new(Vector3.new(ore_pos.X, ore_pos.Y + y_offset, ore_pos.Z), ore_pos)
        hrp.Anchored = true
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part ~= hrp then part.CanCollide = false end
        end
    end
    
    while ore and ore.Parent and is_farming and sel_ore == target_ore and not tween_cancelled do
        local hp = get_ore_hp(ore)
        if not hp or hp <= 0 then break end
        if tool_act_evt then tool_act_evt:InvokeServer("Pickaxe") end
        task.wait(0.3)
    end
    
    if hrp and y_offset ~= 0 then hrp.Anchored = false end
end


-- Main mining loop
task.spawn(function()
    while true do
        task.wait(0.1)
        
        if is_farming and sel_ore and not is_mining then
            local ores = get_ore_insts(sel_ore)
            if #ores > 0 and ores[1]:FindFirstChild("Hitbox") then
                is_mining = true
                tween_to_pos(ores[1].Hitbox.CFrame.Position, tween_spd)
                mine_ore(ores[1])
                is_mining = false
            end
        end
        if not is_farming then is_mining = false end
    end
end)

-- Control functions
function AutoMine.Enable()
    is_farming = true
    print("[AutoMine] Enabled" .. (sel_ore and (" - " .. sel_ore) or ""))
end

function AutoMine.Disable()
    is_farming = false
    is_mining = false
    cancel_current_tween()
    local char = plrs.LocalPlayer and plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false end
    print("[AutoMine] Disabled")
end

function AutoMine.SetOre(ore)
    if sel_ore ~= ore and is_farming then
        cancel_current_tween()
    end
    sel_ore = ore
    print("[AutoMine] Target: " .. (ore or "None"))
end

function AutoMine.SetSpeed(speed)
    tween_spd = math.min(speed or 30, 35)
end

function AutoMine.SetYOffset(offset)
    y_offset = offset or 0
end

function AutoMine.GetOreTypes()
    return get_all_ore_tps()
end

function AutoMine.IsEnabled()
    return is_farming
end

function AutoMine.IsMining()
    return is_mining
end

function AutoMine.GetSelectedOre()
    return sel_ore
end


-- UI
local Window = Fluent:CreateWindow({
    Title = "Auto Mine",
    TabWidth = 160,
    Size = UDim2.fromOffset(400, 300),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tab = Window:AddTab({Title = "Mining", Icon = "pickaxe"})
local Options = Fluent.Options

-- Get available ores
local avail_ores = get_all_ore_tps()
if #avail_ores == 0 then avail_ores = {"None"} end

Tab:AddParagraph({Title = "Ore Mining", Content = "Select ore and enable auto mine"})

local OreDropdown = Tab:AddDropdown("OreSelect", {
    Title = "Select Ore",
    Values = avail_ores,
    Default = 1
})
OreDropdown:OnChanged(function(v)
    AutoMine.SetOre(v)
end)

Tab:AddButton({
    Title = "Refresh Ores",
    Description = "Scan for available ores",
    Callback = function()
        avail_ores = get_all_ore_tps()
        if #avail_ores == 0 then avail_ores = {"None"} end
        OreDropdown:SetValues(avail_ores)
        Fluent:Notify({Title = "Refreshed", Content = "Found " .. #avail_ores .. " ore types", Duration = 3})
    end
})

Tab:AddToggle("AutoMine", {Title = "Auto Mine Ores", Default = false})
Options.AutoMine:OnChanged(function()
    if Options.AutoMine.Value then
        AutoMine.Enable()
    else
        AutoMine.Disable()
    end
end)

Tab:AddSlider("TweenSpeed", {
    Title = "Tween Speed",
    Default = 30,
    Min = 10,
    Max = 35,
    Rounding = 0
})
Options.TweenSpeed:OnChanged(function(v)
    AutoMine.SetSpeed(v)
end)

Tab:AddSlider("YOffset", {
    Title = "Y Offset",
    Default = 0,
    Min = -20,
    Max = 20,
    Rounding = 0
})
Options.YOffset:OnChanged(function(v)
    AutoMine.SetYOffset(v)
end)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Auto Mine Loaded",
    Content = "Use the UI or API to control mining",
    Duration = 3
})

return AutoMine
