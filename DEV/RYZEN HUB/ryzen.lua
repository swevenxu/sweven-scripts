--[[    
    AutoQuest.CustomTween = ur_tween -- put ur tween here
    AutoQuest.CustomMine = ur_mine   -- put ur mine here
    AutoQuest.CustomAttack = ur_atk  -- put ur attack here
    
    AutoQuest.SetSpeed(30)
    AutoQuest.SetOffsets(0, 0, 0)
    AutoQuest.SetFallback("Farm Rocks", "Pebble", nil)
    AutoQuest.Enable()
]]

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()

local AutoQuest = {}

-- Services
local rs = game:GetService("ReplicatedStorage")
local ts = game:GetService("TweenService")
local plrs = game:GetService("Players")
local runService = game:GetService("RunService")

-- Variables
local auto_quest_en = false
local current_quest_task = nil
local last_quest_check = 0
local sel_quest = nil
local is_farming = false
local is_mob_farm = false
local is_mining = false
local is_atk = false
local sel_ore = nil
local sel_mob = nil
local tween_spd = 30
local y_offset = 0
local mob_y_offset = 0
local mob_x_offset = 0

-- Fallback settings
local fallback_mode = "None" -- "None", "Farm Rocks", "Farm Mobs"
local fallback_rock = nil
local fallback_mob = nil
local is_fallback_active = false

-- Stuck detection
local death_recovery_en = true
local stuck_threshold = 5

-- Tween system
local current_tween_conn = nil
local tween_cancelled = false

-- Ore to Source Mapping
local ore_to_source = {
    -- Start Island
    ["Stone"] = {type = "rock", sources = {"Pebble"}},
    ["Sand Stone"] = {type = "rock", sources = {"Pebble", "Rock"}},
    ["Copper"] = {type = "rock", sources = {"Pebble", "Rock", "Boulder"}},
    ["Iron"] = {type = "rock", sources = {"Pebble", "Rock", "Boulder"}},
    ["Tin"] = {type = "rock", sources = {"Rock", "Boulder"}},
    ["Silver"] = {type = "rock", sources = {"Rock", "Boulder"}},
    ["Gold"] = {type = "rock", sources = {"Boulder"}},
    ["Mushroomite"] = {type = "rock", sources = {"Rock", "Boulder"}},
    ["Platinum"] = {type = "rock", sources = {"Boulder"}},
    ["Bananite"] = {type = "rock", sources = {"Rock", "Boulder"}},
    ["Cardboardite"] = {type = "rock", sources = {"Rock", "Boulder"}},
    ["Aite"] = {type = "rock", sources = {"Boulder"}},
    ["Poopite"] = {type = "rock", sources = {"Pebble", "Rock", "Boulder"}},
    ["Fichillium"] = {type = "rock", sources = {"Lucky Block"}},
    -- Volcanic spot
    ["Cobalt"] = {type = "rock", sources = {"Basalt Rock", "Basalt Core"}},
    ["Titanium"] = {type = "rock", sources = {"Basalt Rock", "Basalt Core"}},
    ["Lapis Lazuli"] = {type = "rock", sources = {"Basalt Core", "Basalt Rock"}},
    ["Volcanic Rock"] = {type = "rock", sources = {"Volcanic Rock"}},
    ["Quartz"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
    ["Amethyst"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
    ["Topaz"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein", "Volcanic Rock"}},
    ["Diamond"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
    ["Sapphire"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
    ["Cuprite"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein", "Volcanic Rock"}},
    ["Obsidian"] = {type = "rock", sources = {"Volcanic Rock"}},
    ["Emerald"] = {type = "rock", sources = {"Basalt Core", "Basalt Vein"}},
    ["Ruby"] = {type = "rock", sources = {"Basalt Vein"}},
    ["Rivalite"] = {type = "rock", sources = {"Basalt Vein", "Volcanic Rock"}},
    ["Uranium"] = {type = "rock", sources = {"Basalt Vein"}},
    ["Mythril"] = {type = "rock", sources = {"Basalt Vein"}},
    ["Eye Ore"] = {type = "rock", sources = {"Basalt Rock", "Basalt Core", "Basalt Vein", "Volcanic Rock"}},
    ["Fireite"] = {type = "rock", sources = {"Volcanic Rock"}},
    ["Magmaite"] = {type = "rock", sources = {"Volcanic Rock"}},
    ["Lightite"] = {type = "rock", sources = {"Basalt Vein"}},
    ["Demonite"] = {type = "rock", sources = {"Volcanic Rock"}},
    ["Darkryte"] = {type = "rock", sources = {"Volcanic Rock"}},
    -- Mob drops
    ["Boneite"] = {type = "mob", sources = {"Skeleton Rogue", "Axe Skeleton", "Deathaxe Skeleton"}},
    ["Dark Boneite"] = {type = "mob", sources = {"Elite Skeleton Rogue", "Reaper", "Elite Deathaxe Skeleton"}},
    ["Slimite"] = {type = "mob", sources = {"Slime", "Burning Slime"}},
    -- Crystal spot
    ["Magenta Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
    ["Crimson Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
    ["Green Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
    ["Orange Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
    ["Blue Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
    ["Rainbow Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
    ["Arcane Crystal"] = {type = "rock", sources = {"Crimson Crystal", "Cyan Crystal", "Earth Crystal", "Light Crystal"}},
    -- Ice spot
    ["Tungsten"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder"}},
    ["Sulfur"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder"}},
    ["Pumice"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder"}},
    ["Graphite"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder"}},
    ["Snowite"] = {type = "rock", sources = {"Icy Pebble", "Icy Rock", "Icy Boulder", "Small Ice Crystal"}},
    ["Iceite"] = {type = "rock", sources = {"Icy Rock", "Icy Boulder", "Small Ice Crystal", "Medium Ice Crystal", "Large Ice Crystal", "Floating Crystal"}},
    ["Heavenite"] = {type = "rock", sources = {"Floating Crystal"}},
    ["Gargantuan"] = {type = "rock", sources = {"Large Ice Crystal"}},
    -- Boss drops
    ["Prismatic Heart"] = {type = "mob", sources = {"Prismarine Spider"}},
    ["Yeti Heart"] = {type = "mob", sources = {"Yeti"}},
    ["Golem Heart"] = {type = "mob", sources = {"Ice Golem Boss"}},
    -- Not obt
    ["Galaxite"] = {type = "none", sources = {}},
    ["Vooite"] = {type = "none", sources = {}},
}

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

local function get_ore_sources(ore_name)
    return ore_to_source[ore_name] or {type = "none", sources = {}}
end

local function find_rocks_by_hp(rock_types)
    local rocks = {}
    local rocksFolder = workspace:FindFirstChild("Rocks")
    if not rocksFolder then return rocks end
    
    for _, area in ipairs(rocksFolder:GetChildren()) do
        for _, spawn in ipairs(area:GetChildren()) do
            for _, rock_type in ipairs(rock_types) do
                local rock = spawn:FindFirstChild(rock_type)
                if rock and rock:FindFirstChild("Hitbox") then
                    local hp = get_ore_hp(rock)
                    if hp and hp > 0 then
                        table.insert(rocks, {rock = rock, hp = hp, type = rock_type})
                    end
                end
            end
        end
    end
    
    table.sort(rocks, function(a, b) return a.hp < b.hp end)
    return rocks
end

local function get_best_rock_for_ore(ore_name)
    local source_info = get_ore_sources(ore_name)
    if source_info.type ~= "rock" or #source_info.sources == 0 then
        return nil
    end
    
    local rocks = find_rocks_by_hp(source_info.sources)
    if #rocks > 0 then
        return rocks[1].type
    end
    return source_info.sources[1]
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

local function get_mob_insts(mob_tp)
    local insts = {}
    local living = workspace:FindFirstChild("Living")
    if not living then return insts end
    for _, ent in ipairs(living:GetChildren()) do
        if not plrs:FindFirstChild(ent.Name) and ent.Name:gsub("%d+$", "") == mob_tp and ent:FindFirstChild("HumanoidRootPart") then
            local hum = ent:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then table.insert(insts, ent) end
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

local function get_all_mob_tps()
    local mob_set = {}
    local living = workspace:FindFirstChild("Living")
    if not living then return {} end
    for _, ent in ipairs(living:GetChildren()) do
        if not plrs:FindFirstChild(ent.Name) and ent:FindFirstChild("HumanoidRootPart") then
            mob_set[ent.Name:gsub("%d+$", "")] = true
        end
    end
    local mobs = {}
    for mob_nm in pairs(mob_set) do table.insert(mobs, mob_nm) end
    table.sort(mobs)
    return mobs
end

-- tool remote
local function get_tool_act()
    return rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
end

local tool_act_evt
pcall(function() tool_act_evt = get_tool_act() end)

AutoQuest.CustomTween = nil -- put ur tween

local function tween_to_pos(tgt_pos, spd)
    if AutoQuest.CustomTween then
        return AutoQuest.CustomTween(tgt_pos, spd)
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

AutoQuest.CustomMine = nil -- put ur mine

local function mine_ore(ore)
    if AutoQuest.CustomMine then
        return AutoQuest.CustomMine(ore)
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

AutoQuest.CustomAttack = nil -- put ur attack

local function atk_mob(mob)
    if AutoQuest.CustomAttack then
        return AutoQuest.CustomAttack(mob)
    end
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local char = plrs.LocalPlayer and plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target_mob = sel_mob
    
    if hrp and (mob_y_offset ~= 0 or mob_x_offset ~= 0) then
        local mob_pos = mob.HumanoidRootPart.Position
        hrp.CFrame = CFrame.new(Vector3.new(mob_pos.X + mob_x_offset, mob_pos.Y + mob_y_offset, mob_pos.Z), mob_pos)
        hrp.Anchored = true
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part ~= hrp then part.CanCollide = false end
        end
    end
    
    while mob and mob.Parent and is_mob_farm and sel_mob == target_mob and not tween_cancelled do
        local hum = mob:FindFirstChild("Humanoid")
        if not hum or hum.Health <= 0 then break end
        
        -- Mob tracking
        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp and mobHrp then
            local mob_pos = mobHrp.Position
            local distance = (hrp.Position - mob_pos).Magnitude
            if distance > 8 then
                if mob_y_offset ~= 0 or mob_x_offset ~= 0 then
                    hrp.CFrame = CFrame.new(Vector3.new(mob_pos.X + mob_x_offset, mob_pos.Y + mob_y_offset, mob_pos.Z), mob_pos)
                else
                    hrp.CFrame = CFrame.new(mob_pos + Vector3.new(3, 0, 0), mob_pos)
                end
            end
        end
        
        if tool_act_evt then tool_act_evt:InvokeServer("Weapon") end
        task.wait(0.3)
    end
    
    if hrp and (mob_y_offset ~= 0 or mob_x_offset ~= 0) then hrp.Anchored = false end
end

-- Get active quests from UI
local function get_active_quests()
    local quests = {}
    local plyr = plrs.LocalPlayer
    if not plyr then return quests end
    
    local playerGui = plyr:FindFirstChild("PlayerGui")
    if not playerGui then return quests end
    
    local main = playerGui:FindFirstChild("Main")
    if not main then return quests end
    
    local screen = main:FindFirstChild("Screen")
    if not screen then return quests end
    
    local questsFolder = screen:FindFirstChild("Quests")
    if not questsFolder then return quests end
    
    local questList = questsFolder:FindFirstChild("List")
    if not questList then return quests end
    
    for _, child in ipairs(questList:GetChildren()) do
        if child.Name:match("List$") and child:IsA("Frame") then
            local questId = child.Name:gsub("List$", "")
            local tasks = {}
            
            local titleFrame = questList:FindFirstChild(questId .. "Title")
            local displayName = questId
            if titleFrame then
                local frame = titleFrame:FindFirstChild("Frame")
                local textLabel = frame and frame:FindFirstChild("TextLabel")
                if textLabel then displayName = textLabel.Text end
            end
            
            for _, taskChild in ipairs(child:GetChildren()) do
                if tonumber(taskChild.Name) then
                    local taskMain = taskChild:FindFirstChild("Main")
                    local textLabel = taskMain and taskMain:FindFirstChild("TextLabel")
                    if textLabel and textLabel:IsA("TextLabel") then
                        table.insert(tasks, {
                            text = textLabel.Text,
                            frame = taskChild,
                            index = tonumber(taskChild.Name)
                        })
                    end
                end
            end
            
            table.sort(tasks, function(a, b) return a.index < b.index end)
            
            if #tasks > 0 then
                table.insert(quests, {name = questId, displayName = displayName, tasks = tasks})
            end
        end
    end
    
    if sel_quest then
        table.sort(quests, function(a, b)
            if a.name == sel_quest then return true end
            if b.name == sel_quest then return false end
            return a.name < b.name
        end)
    end
    
    return quests
end

-- Parse task text
local function parse_task(text)
    if not text or text == "" then return nil end
    
    local action, target, current, required = text:match("^%-?%s*(%w+)%s+(.+):%s*(%d+)/(%d+)")
    
    if not action then return nil end
    
    action = action:lower()
    current = tonumber(current)
    required = tonumber(required)
    
    return {
        action = action,
        target = target,
        current = current,
        required = required,
        completed = current >= required
    }
end

-- Main auto quest logic
local function run_auto_quest()
    if not auto_quest_en then return end
    
    local quests = get_active_quests()
    
    if #quests == 0 then
        if current_quest_task ~= "NO_QUESTS" then
            current_quest_task = "NO_QUESTS"
            print("[AutoQuest] No active quests found")
        end
        return
    end
    
    for _, quest in ipairs(quests) do
        local questLabel = quest.displayName or quest.name
        
        for _, task in ipairs(quest.tasks) do
            local parsed = parse_task(task.text)
            
            if parsed and not parsed.completed then
                local task_id = quest.name .. "_" .. parsed.action .. "_" .. parsed.target .. "_" .. parsed.required
                
                if current_quest_task == task_id then
                    if parsed.action == "mine" or parsed.action == "get" or parsed.action == "collect" then
                        if not is_farming then
                            is_farming = true
                            is_mob_farm = false
                        end
                    elseif parsed.action == "kill" then
                        if not is_mob_farm then
                            is_mob_farm = true
                            is_farming = false
                        end
                    end
                    return
                end
                
                cancel_current_tween()
                current_quest_task = task_id
                
                if parsed.action == "purchase" or parsed.action == "buy" then
                    print("[" .. questLabel .. "] Skipping purchase task: " .. parsed.target)
                    
                elseif parsed.action == "mine" then
                    sel_ore = parsed.target
                    is_farming = true
                    is_mob_farm = false
                    print("[" .. questLabel .. "] Mining " .. parsed.target .. " (" .. parsed.current .. "/" .. parsed.required .. ")")
                    return
                    
                elseif parsed.action == "get" or parsed.action == "collect" then
                    local source_info = get_ore_sources(parsed.target)
                    
                    if parsed.target == "Ore" or parsed.target == "ore" then
                        if fallback_rock then
                            sel_ore = fallback_rock
                            is_farming = true
                            is_mob_farm = false
                            is_fallback_active = true
                            print("[" .. questLabel .. "] Mining " .. fallback_rock .. " for generic Ore")
                            return
                        else
                            sel_ore = "Pebble"
                            is_farming = true
                            is_mob_farm = false
                            print("[" .. questLabel .. "] Mining Pebble for generic Ore")
                            return
                        end
                    end
                    
                    if source_info.type == "rock" then
                        local best_rock = get_best_rock_for_ore(parsed.target)
                        if best_rock then
                            sel_ore = best_rock
                            is_farming = true
                            is_mob_farm = false
                            is_fallback_active = false
                            print("[" .. questLabel .. "] Mining " .. best_rock .. " for " .. parsed.target)
                            return
                        else
                            if fallback_mode == "Farm Rocks" and fallback_rock then
                                sel_ore = fallback_rock
                                is_farming = true
                                is_mob_farm = false
                                is_fallback_active = true
                                print("[" .. questLabel .. "] Fallback: Mining " .. fallback_rock)
                                return
                            elseif fallback_mode == "Farm Mobs" and fallback_mob then
                                sel_mob = fallback_mob
                                is_mob_farm = true
                                is_farming = false
                                is_fallback_active = true
                                print("[" .. questLabel .. "] Fallback: Killing " .. fallback_mob)
                                return
                            end
                        end
                    elseif source_info.type == "mob" then
                        sel_mob = source_info.sources[1]
                        is_mob_farm = true
                        is_farming = false
                        is_fallback_active = false
                        print("[" .. questLabel .. "] Killing " .. sel_mob .. " for " .. parsed.target)
                        return
                    else
                        if fallback_mode == "Farm Rocks" and fallback_rock then
                            sel_ore = fallback_rock
                            is_farming = true
                            is_mob_farm = false
                            is_fallback_active = true
                            print("[" .. questLabel .. "] Fallback: Mining " .. fallback_rock)
                            return
                        elseif fallback_mode == "Farm Mobs" and fallback_mob then
                            sel_mob = fallback_mob
                            is_mob_farm = true
                            is_farming = false
                            is_fallback_active = true
                            print("[" .. questLabel .. "] Fallback: Killing " .. fallback_mob)
                            return
                        end
                    end
                    
                elseif parsed.action == "kill" then
                    sel_mob = parsed.target
                    is_mob_farm = true
                    is_farming = false
                    print("[" .. questLabel .. "] Killing " .. parsed.target .. " (" .. parsed.current .. "/" .. parsed.required .. ")")
                    return
                end
            end
        end
    end
    
    if current_quest_task and current_quest_task ~= "ALL_DONE" then
        current_quest_task = "ALL_DONE"
        is_farming = false
        is_mob_farm = false
        print("[AutoQuest] All tasks completed!")
    end
end

-- Stuck detection variables
local last_position = nil
local last_move_time = tick()

-- Stuck detection loop
task.spawn(function()
    while true do
        task.wait(1)
        if death_recovery_en and auto_quest_en and (is_farming or is_mob_farm) then
            local char = plrs.LocalPlayer and plrs.LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            
            if hrp then
                local current_pos = hrp.Position
                
                if last_position then
                    local distance_moved = (current_pos - last_position).Magnitude
                    if distance_moved > 1 then
                        last_move_time = tick()
                    end
                end
                
                last_position = current_pos
                
                if tick() - last_move_time >= stuck_threshold then
                    print("[AutoQuest] Stuck detected, resetting...")
                    current_quest_task = nil
                    is_farming = false
                    is_mob_farm = false
                    cancel_current_tween()
                    task.wait(0.5)
                    last_move_time = tick()
                end
            end
        else
            last_position = nil
            last_move_time = tick()
        end
    end
end)

-- Main farming loop
local last_quest_check_time = 0

task.spawn(function()
    while true do
        task.wait(0.1)
        
        -- Auto Quest check
        if auto_quest_en and tick() - last_quest_check_time >= 0.5 then
            pcall(run_auto_quest)
            last_quest_check_time = tick()
        end
        
        -- Mining
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
        
        -- Mob farming
        if is_mob_farm and sel_mob and not is_atk then
            local mobs = get_mob_insts(sel_mob)
            if #mobs > 0 and mobs[1]:FindFirstChild("HumanoidRootPart") then
                is_atk = true
                tween_to_pos(mobs[1].HumanoidRootPart.Position, tween_spd)
                atk_mob(mobs[1])
                is_atk = false
            end
        end
        if not is_mob_farm then is_atk = false end
    end
end)

-- control functions
function AutoQuest.Enable()
    auto_quest_en = true
    current_quest_task = nil
    last_quest_check_time = 0
    print("[AutoQuest] Enabled")
end

function AutoQuest.Disable()
    auto_quest_en = false
    cancel_current_tween()
    current_quest_task = nil
    is_farming = false
    is_mob_farm = false
    is_mining = false
    is_atk = false
    is_fallback_active = false
    local char = plrs.LocalPlayer and plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false end
    print("[AutoQuest] Disabled")
end

function AutoQuest.SetFallback(mode, rock, mob)
    fallback_mode = mode or "None"
    fallback_rock = rock
    fallback_mob = mob
    print("[AutoQuest] Fallback: " .. fallback_mode)
end

function AutoQuest.SetSpeed(speed)
    tween_spd = math.min(speed or 30, 35)
end

function AutoQuest.SetOffsets(y, mobY, mobX)
    y_offset = y or 0
    mob_y_offset = mobY or 0
    mob_x_offset = mobX or 0
end

function AutoQuest.SetStuckDetection(enabled, threshold)
    death_recovery_en = enabled ~= false
    stuck_threshold = threshold or 5
end

function AutoQuest.SetQuest(questId)
    sel_quest = questId
    current_quest_task = nil
end

function AutoQuest.GetOreTypes()
    return get_all_ore_tps()
end

function AutoQuest.GetMobTypes()
    return get_all_mob_tps()
end

function AutoQuest.IsEnabled()
    return auto_quest_en
end

function AutoQuest.IsFarming()
    return is_farming
end

function AutoQuest.IsMobFarming()
    return is_mob_farm
end

-- ui
local Window = Fluent:CreateWindow({
    Title = "Auto Quest",
    TabWidth = 160,
    Size = UDim2.fromOffset(400, 350),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.RightShift
})

local Tab = Window:AddTab({Title = "Quest", Icon = "scroll"})
local Options = Fluent.Options

-- get quest names for dropdown
local function get_quest_names()
    local names = {}
    local plyr = plrs.LocalPlayer
    if not plyr then return {"None"} end
    local playerGui = plyr:FindFirstChild("PlayerGui")
    if not playerGui then return {"None"} end
    local main = playerGui:FindFirstChild("Main")
    if not main then return {"None"} end
    local screen = main:FindFirstChild("Screen")
    if not screen then return {"None"} end
    local questsFolder = screen:FindFirstChild("Quests")
    if not questsFolder then return {"None"} end
    local questList = questsFolder:FindFirstChild("List")
    if not questList then return {"None"} end
    
    for _, child in ipairs(questList:GetChildren()) do
        if child.Name:match("List$") and child:IsA("Frame") then
            local questId = child.Name:gsub("List$", "")
            local titleFrame = questList:FindFirstChild(questId .. "Title")
            local displayName = questId
            if titleFrame then
                local frame = titleFrame:FindFirstChild("Frame")
                local textLabel = frame and frame:FindFirstChild("TextLabel")
                if textLabel then displayName = textLabel.Text end
            end
            table.insert(names, displayName)
        end
    end
    
    if #names == 0 then return {"None"} end
    table.insert(names, 1, "Auto (All)")
    return names
end

local avail_ores = get_all_ore_tps()
local avail_mobs = get_all_mob_tps()
if #avail_ores == 0 then avail_ores = {"None"} end
if #avail_mobs == 0 then avail_mobs = {"None"} end

local QuestDropdown = Tab:AddDropdown("QuestSelect", {
    Title = "Quest",
    Values = get_quest_names(),
    Default = 1
})
QuestDropdown:OnChanged(function(v)
    if v == "Auto (All)" then
        sel_quest = nil
    else
        sel_quest = v
    end
    current_quest_task = nil
end)

Tab:AddButton({
    Title = "Refresh Quests",
    Callback = function()
        QuestDropdown:SetValues(get_quest_names())
        Fluent:Notify({Title = "done", Content = "quests refreshed", Duration = 2})
    end
})

Tab:AddToggle("AutoQuestToggle", {Title = "Auto Quest", Default = false})
Options.AutoQuestToggle:OnChanged(function()
    if Options.AutoQuestToggle.Value then
        AutoQuest.Enable()
    else
        AutoQuest.Disable()
    end
end)

Tab:AddDropdown("FallbackMode", {
    Title = "Fallback Mode",
    Values = {"None", "Farm Rocks", "Farm Mobs"},
    Default = 1
}):OnChanged(function(v)
    fallback_mode = v
end)

Tab:AddDropdown("FallbackRock", {
    Title = "Fallback Rock",
    Values = avail_ores,
    Default = 1
}):OnChanged(function(v)
    fallback_rock = v ~= "None" and v or nil
end)

Tab:AddDropdown("FallbackMob", {
    Title = "Fallback Mob",
    Values = avail_mobs,
    Default = 1
}):OnChanged(function(v)
    fallback_mob = v ~= "None" and v or nil
end)

Tab:AddSlider("Speed", {
    Title = "Tween Speed",
    Default = 30,
    Min = 10,
    Max = 35,
    Rounding = 0
}):OnChanged(function(v)
    tween_spd = v
end)

Tab:AddSlider("YOffset", {
    Title = "Y Offset",
    Default = 0,
    Min = -20,
    Max = 20,
    Rounding = 0
}):OnChanged(function(v)
    y_offset = v
end)

Tab:AddSlider("MobYOffset", {
    Title = "Mob Y Offset",
    Default = 0,
    Min = -50,
    Max = 50,
    Rounding = 0
}):OnChanged(function(v)
    mob_y_offset = v
end)

Tab:AddSlider("MobXOffset", {
    Title = "Mob X Offset",
    Default = 0,
    Min = -50,
    Max = 50,
    Rounding = 0
}):OnChanged(function(v)
    mob_x_offset = v
end)

Tab:AddToggle("StuckDetection", {Title = "Stuck Detection", Default = true})
Options.StuckDetection:OnChanged(function()
    death_recovery_en = Options.StuckDetection.Value
end)

Tab:AddSlider("StuckThreshold", {
    Title = "Stuck Threshold (sec)",
    Default = 5,
    Min = 2,
    Max = 15,
    Rounding = 0
}):OnChanged(function(v)
    stuck_threshold = v
end)

Window:SelectTab(1)
Fluent:Notify({Title = "auto quest", Content = "loaded", Duration = 2})

return AutoQuest
