
--[[
    Snoe Forge - The Forge Script
    Using Dummy UI Library
]]

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local rs = game:GetService("ReplicatedStorage")
local plrs = game:GetService("Players")
local player = plrs.LocalPlayer

-- Disable preload
local preload = game:GetService("ReplicatedFirst"):FindFirstChild("Preload")
if preload and preload:IsA("LocalScript") then preload.Disabled = true end

-- ============================================
-- SCRIPT VARIABLES
-- ============================================

-- Forward declaration for Window (used by functions defined before UI creation)
local Window

local is_running, is_swinging, is_farming, is_mining = false, false, false, false
local sel_ore, tween_spd = nil, 30
local is_mob_farm, is_atk, sel_mob, mob_tween_spd = false, false, nil, 30
local farm_position = "Above" -- Fixed to Above only
local auto_sell_en, auto_sell_intv, auto_sell_wl, last_auto_sell = false, 10, {}, 0
local auto_fav_en, auto_fav_wl, last_auto_fav = false, {}, 0
local ore_cancel_en, ore_cancel_wl = false, {}
local skipped_rocks = {}
local sel_sell_ore, sell_qty = nil, 1
local last_inv_upd = 0
local avail_ores, avail_mobs = {}, {}
local stuck_threshold = 5
local xray_en = false
local xray_original_transparency = {}

-- Travel Method (Above/Underground)
local travel_method = "Above" -- "Above" or "Underground"
local underground_y_offset = -20

-- Reroll System
local reroll_enabled = false
local reroll_target_race = "Angel"
local reroll_delay = 0.6
local reroll_attempts = 0
local RACE_OPTIONS = {
    "Human", "Elf", "Zombie", "Goblin", "Undead", "Orc", "Dwarf",
    "Shadow", "Vampire", "Minotaur", "Dragonborn", "Golem", "Felynx",
    "Angel", "Demon", "Archangel"
}

-- FPS Boost
local fps_boost_enabled = false
local original_lighting_settings = {}

-- Server hop
local max_players_threshold = 4

local ore_prices = {
    ["Fichillium"] = 0, ["Stone"] = 3, ["Sand Stone"] = 3.75, ["Copper"] = 4.5,
    ["Iron"] = 5.25, ["Tin"] = 6.38, ["Silver"] = 7.5, ["Cardboardite"] = 10.5,
    ["Mushroomite"] = 12, ["Platinum"] = 12, ["Bananite"] = 12.75, ["Cobalt"] = 15,
    ["Aite"] = 16.5, ["Titanium"] = 17.25, ["Boneite"] = 18, ["Poopite"] = 18,
    ["Gold"] = 19.5, ["Lapis Lazuli"] = 19.5, ["Quartz"] = 22.5, ["Volcanic Rock"] = 23.25,
    ["Amethyst"] = 24.75, ["Topaz"] = 26.25, ["Diamond"] = 30, ["Sapphire"] = 33.75,
    ["Slimite"] = 33.75, ["Dark Boneite"] = 33.75, ["Obsidian"] = 35.25, ["Cuprite"] = 36.45,
    ["Emerald"] = 38.25, ["Ruby"] = 44.25, ["Mythril"] = 52.5, ["Uranium"] = 66,
    ["Galaxite"] = 172.5, ["Heavenite"] = 468.75, ["Gargantuan"] = 624.375,
}

local ore_to_source = {
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
    ["Uranium"] = {type = "rock", sources = {"Basalt Vein"}},
    ["Mythril"] = {type = "rock", sources = {"Basalt Vein"}},
    ["Boneite"] = {type = "mob", sources = {"Skeleton Rogue", "Axe Skeleton", "Deathaxe Skeleton"}},
    ["Dark Boneite"] = {type = "mob", sources = {"Elite Skeleton Rogue", "Reaper", "Elite Deathaxe Skeleton"}},
    ["Slimite"] = {type = "mob", sources = {"Slime", "Burning Slime"}},
    ["Heavenite"] = {type = "rock", sources = {"Floating Crystal"}},
    ["Gargantuan"] = {type = "rock", sources = {"Large Ice Crystal"}},
    ["Galaxite"] = {type = "none", sources = {}},
}

-- Helper Functions
local function get_ore_nms()
    local nms = {}
    for ore in pairs(ore_prices) do table.insert(nms, ore) end
    table.sort(nms)
    return nms
end

local function open_greedy_cey_dialogue()
    local char = plrs.LocalPlayer.Character
    local myHrp = char and char:FindFirstChild("HumanoidRootPart")
    if not myHrp then return false end
    local greedyCey = workspace.Proximity:FindFirstChild("Greedy Cey")
    if not greedyCey then return false end
    local prompt = greedyCey:FindFirstChild("ProximityPrompt")
    local npcHrp = greedyCey:FindFirstChild("HumanoidRootPart")
    if not prompt or not npcHrp then return false end
    local originalCFrame = myHrp.CFrame
    myHrp.CFrame = npcHrp.CFrame + Vector3.new(3, 0, 0)
    task.wait(0.3)
    fireproximityprompt(prompt, 9999)
    task.wait(0.5)
    myHrp.CFrame = originalCFrame
    return true
end


local function get_ore_qty(ore_nm)
    local plyr = plrs.LocalPlayer
    if not plyr then return 0 end
    local bg = plyr:FindFirstChild("PlayerGui") and plyr.PlayerGui:FindFirstChild("Menu") and plyr.PlayerGui.Menu:FindFirstChild("Frame") and plyr.PlayerGui.Menu.Frame:FindFirstChild("Frame") and plyr.PlayerGui.Menu.Frame.Frame:FindFirstChild("Menus") and plyr.PlayerGui.Menu.Frame.Frame.Menus:FindFirstChild("Stash") and plyr.PlayerGui.Menu.Frame.Frame.Menus.Stash:FindFirstChild("Background")
    if not bg then return 0 end
    local ore_fld = bg:FindFirstChild(ore_nm)
    if not ore_fld then return 0 end
    local main = ore_fld:FindFirstChild("Main")
    if not main then return 0 end
    local qty_lbl = main:FindFirstChild("Quantity")
    if qty_lbl and qty_lbl:IsA("TextLabel") then return tonumber(qty_lbl.Text:match("x(%d+)")) or 0 end
    return 0
end

local function get_inv_ore_stats()
    local total_cnt, total_val = 0, 0
    local plyr = plrs.LocalPlayer
    if not plyr then return 0, 0 end
    local bg = plyr:FindFirstChild("PlayerGui") and plyr.PlayerGui:FindFirstChild("Menu") and plyr.PlayerGui.Menu:FindFirstChild("Frame") and plyr.PlayerGui.Menu.Frame:FindFirstChild("Frame") and plyr.PlayerGui.Menu.Frame.Frame:FindFirstChild("Menus") and plyr.PlayerGui.Menu.Frame.Frame.Menus:FindFirstChild("Stash") and plyr.PlayerGui.Menu.Frame.Frame.Menus.Stash:FindFirstChild("Background")
    if not bg then return 0, 0 end
    for _, ore_fld in ipairs(bg:GetChildren()) do
        local price = ore_prices[ore_fld.Name]
        if price then
            local main = ore_fld:FindFirstChild("Main")
            if main then
                local qty_lbl = main:FindFirstChild("Quantity")
                if qty_lbl and qty_lbl:IsA("TextLabel") then
                    local qty = tonumber(qty_lbl.Text:match("x(%d+)"))
                    if qty and qty > 0 then total_cnt = total_cnt + qty; total_val = total_val + qty * price end
                end
            end
        end
    end
    return total_cnt, total_val
end

local function fmt_money(amt)
    if typeof(amt) ~= "number" then return tostring(amt) end
    return math.floor(amt) == amt and tostring(amt) or string.format("%.2f", amt)
end

local function sell_ore(ore_nm, qty)
    rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("DialogueService"):WaitForChild("RF"):WaitForChild("RunCommand"):InvokeServer("SellConfirm", {Basket = {[ore_nm] = qty}})
end

local function auto_sell_whitelist()
    for _, ore_nm in ipairs(auto_sell_wl) do
        local qty = get_ore_qty(ore_nm)
        if qty > 0 then sell_ore(ore_nm, qty) end
    end
end

local function fav_ore(ore_nm)
    rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("InventoryService"):WaitForChild("RF"):WaitForChild("FavoriteItem"):InvokeServer(ore_nm)
end

local function is_ore_favorited(ore_nm)
    local plyr = plrs.LocalPlayer
    if not plyr then return false end
    local bg = plyr:FindFirstChild("PlayerGui") and plyr.PlayerGui:FindFirstChild("Menu") and plyr.PlayerGui.Menu:FindFirstChild("Frame") and plyr.PlayerGui.Menu.Frame:FindFirstChild("Frame") and plyr.PlayerGui.Menu.Frame.Frame:FindFirstChild("Menus") and plyr.PlayerGui.Menu.Frame.Frame.Menus:FindFirstChild("Stash") and plyr.PlayerGui.Menu.Frame.Frame.Menus.Stash:FindFirstChild("Background")
    if not bg then return false end
    local ore_fld = bg:FindFirstChild(ore_nm)
    if not ore_fld then return false end
    local fav = ore_fld:FindFirstChild("Favorite", true)
    if fav and fav:IsA("ImageLabel") then return fav.Visible end
    return false
end

local function auto_fav_whitelist()
    for _, ore_nm in ipairs(auto_fav_wl) do
        local qty = get_ore_qty(ore_nm)
        if qty > 0 and not is_ore_favorited(ore_nm) then fav_ore(ore_nm) end
    end
end

-- Tween cancellation system
local current_tween_conn = nil
local tween_cancelled = false

local function cancel_current_tween()
    tween_cancelled = true
    if current_tween_conn then
        current_tween_conn:Disconnect()
        current_tween_conn = nil
    end
end

-- Auto Quest Variables
local auto_quest_en = false
local current_quest_task = nil
local last_quest_check = 0
local sel_quest = nil
local avail_quests = {}
local quest_display_names = {}
local death_recovery_en = true
local was_auto_quest_active = false

local quest_to_npc = {
    ["Introduction0"] = "Sensei Moro", ["Introduction1"] = "Sensei Moro", ["Introduction2"] = "Sensei Moro",
    ["Daily1"] = "Ceypai ( Daily Quest )", ["Weekly1"] = "Not Real Ceypai",
    ["Island2Quest0"] = "Sensei Moro 2", ["Island2Quest1"] = "Sensei Moro 2",
}


local function get_quest_names()
    local names, display_map = {}, {}
    local plyr = plrs.LocalPlayer
    if not plyr then return names, display_map end
    local playerGui = plyr:FindFirstChild("PlayerGui")
    local main = playerGui and playerGui:FindFirstChild("Main")
    local screen = main and main:FindFirstChild("Screen")
    local questsFolder = screen and screen:FindFirstChild("Quests")
    local questList = questsFolder and questsFolder:FindFirstChild("List")
    if not questList then return names, display_map end
    
    for _, child in ipairs(questList:GetChildren()) do
        if child.Name:match("Title$") and child:IsA("Frame") then
            local questId = child.Name:gsub("Title$", "")
            local frame = child:FindFirstChild("Frame")
            local textLabel = frame and frame:FindFirstChild("TextLabel")
            local displayName = textLabel and textLabel.Text or questId
            local listFrame = questList:FindFirstChild(questId .. "List")
            if listFrame then
                table.insert(names, questId)
                display_map[questId] = displayName
            end
        end
    end
    return names, display_map
end

local function get_active_quests()
    local quests = {}
    local plyr = plrs.LocalPlayer
    if not plyr then return quests end
    local playerGui = plyr:FindFirstChild("PlayerGui")
    local main = playerGui and playerGui:FindFirstChild("Main")
    local screen = main and main:FindFirstChild("Screen")
    local questsFolder = screen and screen:FindFirstChild("Quests")
    local questList = questsFolder and questsFolder:FindFirstChild("List")
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
                    local main = taskChild:FindFirstChild("Main")
                    local textLabel = main and main:FindFirstChild("TextLabel")
                    if textLabel and textLabel:IsA("TextLabel") then
                        table.insert(tasks, { text = textLabel.Text, frame = taskChild, index = tonumber(taskChild.Name) })
                    end
                end
            end
            table.sort(tasks, function(a, b) return a.index < b.index end)
            if #tasks > 0 then table.insert(quests, {name = questId, displayName = displayName, tasks = tasks}) end
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

local function parse_task(text)
    if not text or text == "" then return nil end
    local action, target, current, required = text:match("^%-?%s*(%w+)%s+(.+):%s*(%d+)/(%d+)")
    if not action then return nil end
    action = action:lower()
    current = tonumber(current)
    required = tonumber(required)
    return { action = action, target = target, current = current, required = required, completed = current >= required }
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
                    local info = rock:FindFirstChild("infoFrame")
                    local hp = nil
                    if info and info:FindFirstChild("Frame") and info.Frame:FindFirstChild("rockHP") then
                        hp = tonumber(info.Frame.rockHP.Text:match("[%d%.]+")) or 0
                    end
                    if hp and hp > 0 then table.insert(rocks, { rock = rock, hp = hp, type = rock_type }) end
                end
            end
        end
    end
    table.sort(rocks, function(a, b) return a.hp < b.hp end)
    return rocks
end

local function get_best_rock_for_ore(ore_name)
    local source_info = get_ore_sources(ore_name)
    if source_info.type ~= "rock" or #source_info.sources == 0 then return nil end
    local rocks = find_rocks_by_hp(source_info.sources)
    if #rocks > 0 then return rocks[1].type end
    return source_info.sources[1]
end

local function log_action(msg)
    local timestamp = os.date("%H:%M:%S")
    print("[Snoe " .. timestamp .. "] " .. msg)
end


local function run_auto_quest()
    if not auto_quest_en then return end
    local quests = get_active_quests()
    if #quests == 0 then
        if current_quest_task ~= "NO_QUESTS" then
            current_quest_task = "NO_QUESTS"
            log_action("Auto Quest: No active quests found")
        end
        return
    end
    
    for _, quest in ipairs(quests) do
        local questLabel = quest.displayName or quest.name
        local all_tasks_complete = true
        local has_incomplete_task = false
        
        for _, task in ipairs(quest.tasks) do
            local parsed = parse_task(task.text)
            if parsed and not parsed.completed then
                has_incomplete_task = true
                all_tasks_complete = false
                local task_id = quest.name .. "_" .. parsed.action .. "_" .. parsed.target .. "_" .. parsed.required
                
                if current_quest_task == task_id then
                    if parsed.action == "mine" or parsed.action == "get" or parsed.action == "collect" then
                        if not is_farming then is_farming = true; is_mob_farm = false end
                    elseif parsed.action == "kill" then
                        if not is_mob_farm then is_mob_farm = true; is_farming = false end
                    end
                    return
                end
                
                cancel_current_tween()
                current_quest_task = task_id
                
                if parsed.action == "mine" then
                    sel_ore = parsed.target
                    is_farming = true
                    is_mob_farm = false
                    log_action("[" .. questLabel .. "] Mining " .. parsed.target .. " (" .. parsed.current .. "/" .. parsed.required .. ")")
                    return
                elseif parsed.action == "get" or parsed.action == "collect" then
                    local source_info = get_ore_sources(parsed.target)
                    if source_info.type == "rock" then
                        local best_rock = get_best_rock_for_ore(parsed.target)
                        if best_rock then
                            sel_ore = best_rock
                            is_farming = true
                            is_mob_farm = false
                            log_action("[" .. questLabel .. "] Mining " .. best_rock .. " for " .. parsed.target)
                            return
                        end
                    elseif source_info.type == "mob" then
                        sel_mob = source_info.sources[1]
                        is_mob_farm = true
                        is_farming = false
                        log_action("[" .. questLabel .. "] Killing " .. sel_mob .. " for " .. parsed.target)
                        return
                    end
                elseif parsed.action == "kill" then
                    sel_mob = parsed.target
                    is_mob_farm = true
                    is_farming = false
                    log_action("[" .. questLabel .. "] Killing " .. parsed.target .. " (" .. parsed.current .. "/" .. parsed.required .. ")")
                    return
                end
            end
        end
        
        if all_tasks_complete and not has_incomplete_task then
            local npc_name = quest_to_npc[quest.name]
            if npc_name then
                local reward_task_id = "REWARD_" .. quest.name
                if current_quest_task ~= reward_task_id then
                    current_quest_task = reward_task_id
                    is_farming = false
                    is_mob_farm = false
                    log_action("[" .. questLabel .. "] All tasks done! Talk to " .. npc_name)
                    Window:Notify({Title = "Quest Complete!", Desc = "Talk to " .. npc_name, Time = 8})
                    return
                end
            end
        end
    end
end

local function get_run_evt()
    return rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("CharacterService"):WaitForChild("RF"):WaitForChild("Run")
end

local function get_tool_act()
    return rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("ToolService"):WaitForChild("RF"):WaitForChild("ToolActivated")
end

local function get_ore_hp(ore)
    local info = ore:FindFirstChild("infoFrame")
    if info and info:FindFirstChild("Frame") and info.Frame:FindFirstChild("rockHP") then
        return tonumber(info.Frame.rockHP.Text:match("[%d%.]+")) or 0
    end
    return nil
end

local function get_ore_previews(rock)
    local previews = {}
    for _, child in ipairs(rock:GetChildren()) do
        if child.Name == "Ore" then
            local ore_name = child:GetAttribute("Ore")
            if ore_name then table.insert(previews, ore_name) end
        end
    end
    return previews
end

local function should_keep_mining(rock)
    if not ore_cancel_en then return true end
    local previews = get_ore_previews(rock)
    if #previews == 0 then return true end
    if #ore_cancel_wl == 0 then return true end
    for _, preview in ipairs(previews) do
        for _, wanted in ipairs(ore_cancel_wl) do
            if preview == wanted then return true end
        end
    end
    return false
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

local function get_ore_insts(ore_tp)
    local insts = {}
    local rocks = workspace:FindFirstChild("Rocks")
    if not rocks then return insts end
    for _, area in ipairs(rocks:GetChildren()) do
        for _, spwn in ipairs(area:GetChildren()) do
            local ore_fld = spwn:FindFirstChild(ore_tp)
            if ore_fld and ore_fld:FindFirstChild("Hitbox") then
                local hp = get_ore_hp(ore_fld)
                if hp and hp > 0 and not skipped_rocks[ore_fld] then table.insert(insts, ore_fld) end
            end
        end
    end
    return insts
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


local function tween_to_pos(tgt_pos, spd)
    cancel_current_tween()
    tween_cancelled = false
    local plyr = plrs.LocalPlayer
    local char = plyr.Character or plyr.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local startPos = hrp.Position
    local safeSpd = math.min(spd, 35)
    local done = false
    
    -- Build waypoints based on travel method
    local waypoints = {}
    if travel_method == "Underground" then
        -- Go underground first, travel, then come up
        local undergroundY = math.min(startPos.Y, tgt_pos.Y) + underground_y_offset
        table.insert(waypoints, Vector3.new(startPos.X, undergroundY, startPos.Z)) -- Go down
        table.insert(waypoints, Vector3.new(tgt_pos.X, undergroundY, tgt_pos.Z)) -- Travel underground
        table.insert(waypoints, tgt_pos) -- Come up to target
    else
        -- Above travel: go up to Y=250, travel horizontally, then descend
        local aboveY = 250
        table.insert(waypoints, Vector3.new(startPos.X, aboveY, startPos.Z)) -- Go up
        table.insert(waypoints, Vector3.new(tgt_pos.X, aboveY, tgt_pos.Z)) -- Travel horizontally
        table.insert(waypoints, tgt_pos) -- Descend to target
    end
    
    -- Traverse each waypoint
    for _, waypoint in ipairs(waypoints) do
        if tween_cancelled then break end
        
        local wpStartPos = hrp.Position
        local dist = (waypoint - wpStartPos).Magnitude
        local dur = math.max(dist / safeSpd, 0.1)
        local startTime = tick()
        local wpDone = false
        
        current_tween_conn = RunService.Heartbeat:Connect(function()
            if wpDone or tween_cancelled or not hrp or not hrp.Parent then
                if current_tween_conn then current_tween_conn:Disconnect(); current_tween_conn = nil end
                wpDone = true
                return
            end
            local elapsed = tick() - startTime
            local alpha = math.min(elapsed / dur, 1)
            local newPos = wpStartPos:Lerp(waypoint, alpha)
            hrp.CFrame = CFrame.new(newPos)
            if alpha >= 1 then
                wpDone = true
                if current_tween_conn then current_tween_conn:Disconnect(); current_tween_conn = nil end
                hrp.CFrame = CFrame.new(waypoint)
            end
        end)
        while not wpDone and not tween_cancelled do task.wait() end
    end
    done = true
end

local function mine_ore(ore, tool_act_evt)
    if not ore or not ore:FindFirstChild("Hitbox") then return end
    local char = plrs.LocalPlayer and plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target_ore = sel_ore
    
    -- Apply Above position offset (fixed)
    if hrp then
        local ore_pos = ore.Hitbox.CFrame.Position
        hrp.CFrame = CFrame.new(Vector3.new(ore_pos.X, ore_pos.Y + 11, ore_pos.Z), ore_pos)
        hrp.Anchored = true
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part ~= hrp then part.CanCollide = false end
        end
    end
    
    while ore and ore.Parent and is_farming and sel_ore == target_ore and not tween_cancelled do
        local hp = get_ore_hp(ore)
        if not hp or hp <= 0 then skipped_rocks[ore] = nil; break end
        if ore_cancel_en then
            local previews = get_ore_previews(ore)
            if #previews > 0 then
                if not should_keep_mining(ore) then skipped_rocks[ore] = true; break end
            end
        end
        if tool_act_evt then tool_act_evt:InvokeServer("Pickaxe") end
        task.wait(0.3)
    end
    if hrp then hrp.Anchored = false end
end

local function atk_mob(mob, tool_act_evt)
    if not mob or not mob:FindFirstChild("HumanoidRootPart") then return end
    local char = plrs.LocalPlayer and plrs.LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local target_mob = sel_mob
    
    -- Noclip all parts
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
    
    -- BodyVelocity for movement
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bv.Velocity = Vector3.zero
    bv.Parent = hrp
    
    -- BodyGyro to face the mob
    local bg = Instance.new("BodyGyro")
    bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bg.P = 50000
    bg.Parent = hrp
    
    while mob and mob.Parent and is_mob_farm and sel_mob == target_mob and not tween_cancelled do
        local mobHum = mob:FindFirstChild("Humanoid")
        if not mobHum or mobHum.Health <= 0 then break end
        
        local mobHrp = mob:FindFirstChild("HumanoidRootPart")
        if hrp and mobHrp and bv and bv.Parent then
            local mobPos = mobHrp.Position
            local targetPos
            
            -- Always above with Y offset of 7
            local targetPos = mobPos + Vector3.new(0, 7, 0)
            
            local direction = targetPos - hrp.Position
            local dist = direction.Magnitude
            
            -- Always apply velocity toward target to counter any drift
            if dist > 0.5 then
                -- Move toward target
                bv.Velocity = direction.Unit * math.clamp(dist * 3, 10, 50)
            else
                -- At target - apply small correction to stay locked
                bv.Velocity = direction * 5
            end
            
            bg.CFrame = CFrame.new(hrp.Position, mobPos)
        end
        
        if tool_act_evt then tool_act_evt:InvokeServer("Weapon") end
        task.wait(0.1)
    end
    
    -- Cleanup
    if bv then bv:Destroy() end
    if bg then bg:Destroy() end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            part.CanCollide = true
        end
    end
end

local run_evt = get_run_evt()
local tool_act_evt
pcall(function() tool_act_evt = get_tool_act() end)

-- ============================================
-- FORGE SYSTEM (RyZen Hub Method)
-- ============================================

local patchedModules = {}
local meltEnabled = false
local pourEnabled = false
local autoHammerEnabled = false
local hammerPerfectEnabled = false
local _orig_Hammer_CreateNote = nil

local function tryRequireControllerModule(name)
    -- Try Controllers path
    local controllers = rs:FindFirstChild("Controllers")
    if controllers then
        local forgeController = controllers:FindFirstChild("ForgeController")
        if forgeController then
            local mod = forgeController:FindFirstChild(name)
            if mod and mod:IsA("ModuleScript") then
                local ok, m = pcall(require, mod)
                if ok and type(m) == "table" then
                    return m, mod
                end
            end
        end
    end
    
    -- Try Shared/Controllers path
    local shared = rs:FindFirstChild("Shared")
    if shared then
        local sharedControllers = shared:FindFirstChild("Controllers")
        if sharedControllers then
            local forgeController = sharedControllers:FindFirstChild("ForgeController")
            if forgeController then
                local mod = forgeController:FindFirstChild(name)
                if mod and mod:IsA("ModuleScript") then
                    local ok, m = pcall(require, mod)
                    if ok and type(m) == "table" then
                        return m, mod
                    end
                end
            end
        end
    end
    
    return nil, nil
end

local function safePatch(name, overrideFunc)
    local moduleTable, _ = tryRequireControllerModule(name)
    if moduleTable == nil then
        return false, "module_not_found"
    end
    
    if patchedModules[name] == nil then
        patchedModules[name] = moduleTable.Start
    end
    
    moduleTable.Start = function(self, a, b)
        local ok, res = pcall(function()
            return overrideFunc(moduleTable, a, b)
        end)
        if ok then
            return res
        else
            local orig = patchedModules[name]
            if orig then return orig(self, a, b) end
            return nil
        end
    end
    
    return true
end

local function restorePatch(name)
    local moduleTable, _ = tryRequireControllerModule(name)
    if moduleTable == nil then return false end
    
    local orig = patchedModules[name]
    if orig then
        moduleTable.Start = orig
        patchedModules[name] = nil
        return true
    end
    return false
end

local function meltAutoComplete(_, _, data)
    local gui = plrs.LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        local forge = gui:FindFirstChild("Forge")
        if forge then
            local melt = forge:FindFirstChild("MeltMinigame")
            if melt then
                pcall(function()
                    melt.Visible = true
                    local bar = melt:FindFirstChild("Bar", true)
                    if bar and bar:IsA("Frame") then
                        TweenService:Create(bar, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.fromScale(1, bar.Size.Y.Scale) }):Play()
                    end
                    task.wait(0.28)
                    melt.Visible = false
                end)
            else
                task.wait(0.25)
            end
        else
            task.wait(0.25)
        end
    end
    
    local clientTime = workspace:GetServerTimeNow()
    if data and data.StartTime then
        clientTime = data.StartTime
    end
    return clientTime, true
end

local function pourAutoComplete(_, _, data)
    local gui = plrs.LocalPlayer:FindFirstChild("PlayerGui")
    if gui then
        local forge = gui:FindFirstChild("Forge")
        if forge then
            local pour = forge:FindFirstChild("PourMinigame")
            if pour then
                pcall(function()
                    pour.Visible = true
                    local timer = pour:FindFirstChild("Timer")
                    if timer then
                        local bar = timer:FindFirstChild("Bar")
                        if bar and bar:IsA("Frame") then
                            TweenService:Create(bar, TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), { Size = UDim2.fromScale(1, bar.Size.Y.Scale) }):Play()
                        end
                    end
                    task.wait(0.28)
                    pour.Visible = false
                end)
            else
                task.wait(0.25)
            end
        else
            task.wait(0.25)
        end
    end
    
    local clientTime = workspace:GetServerTimeNow()
    if data and data.StartTime then
        clientTime = data.StartTime
    end
    return clientTime
end

-- Auto Hammer loop
task.spawn(function()
    while true do
        task.wait(0.05)
        if autoHammerEnabled then
            local gui = plrs.LocalPlayer:FindFirstChild("PlayerGui")
            if gui then
                local forge = gui:FindFirstChild("Forge")
                if forge then
                    local hammerUI = forge:FindFirstChild("HammerMinigame")
                    if hammerUI and hammerUI.Visible then
                        local debris = workspace:FindFirstChild("Debris")
                        if debris then
                            for _, obj in ipairs(debris:GetChildren()) do
                                local cd = obj:FindFirstChild("ClickDetector")
                                if cd then
                                    pcall(function() fireclickdetector(cd) end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local function openForgeUI()
    local proximity = workspace:FindFirstChild("Proximity")
    if not proximity then return end
    local forgeObj = proximity:FindFirstChild("Forge")
    if not forgeObj then return end
    
    local ProximityRF = nil
    local StartForgeRF = nil
    
    pcall(function()
        ProximityRF = rs.Shared.Packages.Knit.Services.ProximityService.RF.Forge
    end)
    pcall(function()
        StartForgeRF = rs.Shared.Packages.Knit.Services.ForgeService.RF.StartForge
    end)
    
    if ProximityRF then
        pcall(function() ProximityRF:InvokeServer(forgeObj) end)
        task.wait(0.12)
    end
    if StartForgeRF then
        pcall(function() StartForgeRF:InvokeServer(forgeObj) end)
    end
end


-- Enhance system variables
local auto_enhance_en = false
local enhance_only_100 = true
local enhance_target_lvl = 9
local sel_enhance_equip = nil
local enhance_equip_list = {}
local enhance_equip_labels = {}
local last_enhance_refresh = 0

local enhance_svc = rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("EnhanceService"):WaitForChild("RF")
local FindEquipmentByGUID = enhance_svc:WaitForChild("FindEquipmentByGUID")
local CalculateSuccessChance = enhance_svc:WaitForChild("CalculateSuccessChance")
local EnhanceEquipment = enhance_svc:WaitForChild("EnhanceEquipment")

-- ============================================
-- FPS BOOST SYSTEM (moved up for UI usage)
-- ============================================
local fps_original_settings = {}

local function enable_fps_boost()
    if fps_boost_enabled then return end
    fps_boost_enabled = true
    
    -- Save original lighting settings
    fps_original_settings = {
        GlobalShadows = Lighting.GlobalShadows,
        FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart,
        Brightness = Lighting.Brightness,
        ShadowSoftness = Lighting.ShadowSoftness,
        Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient,
    }
    
    -- Lighting optimizations
    Lighting.GlobalShadows = false
    Lighting.FogEnd = 9e9
    Lighting.FogStart = 0
    Lighting.ShadowSoftness = 0
    
    -- Set lowest quality
    pcall(function() settings().Rendering.QualityLevel = 1 end)
    
    -- Try to set lighting technology to lower quality
    pcall(function()
        if sethiddenproperty then
            sethiddenproperty(Lighting, "Technology", 2)
        end
    end)
    
    -- Disable lighting effects
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or 
           v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
            v.Enabled = false
        end
    end
    
    -- Terrain optimizations
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.WaterTransparency = 1
            terrain.Decoration = false
        end
    end)
    
    -- Workspace descendants optimizations
    for _, v in ipairs(workspace:GetDescendants()) do
        pcall(function()
            -- Disable particles/trails/beams
            if v:IsA("ParticleEmitter") or v:IsA("Trail") or v:IsA("Beam") or v:IsA("Fire") or v:IsA("Smoke") or v:IsA("Sparkles") then
                v.Enabled = false
            -- Hide decals/textures
            elseif v:IsA("Decal") or v:IsA("Texture") then
                v.Transparency = 1
            -- Lower mesh quality
            elseif v:IsA("MeshPart") then
                v.RenderFidelity = Enum.RenderFidelity.Performance
                v.Reflectance = 0
            -- Disable reflections on parts
            elseif v:IsA("BasePart") then
                v.Reflectance = 0
            -- Disable lights
            elseif v:IsA("Light") then
                v.Enabled = false
            end
        end)
    end
end

local function disable_fps_boost()
    if not fps_boost_enabled then return end
    fps_boost_enabled = false
    
    -- Restore lighting settings
    pcall(function()
        if fps_original_settings.GlobalShadows ~= nil then Lighting.GlobalShadows = fps_original_settings.GlobalShadows end
        if fps_original_settings.FogEnd then Lighting.FogEnd = fps_original_settings.FogEnd end
        if fps_original_settings.FogStart then Lighting.FogStart = fps_original_settings.FogStart end
        if fps_original_settings.ShadowSoftness then Lighting.ShadowSoftness = fps_original_settings.ShadowSoftness end
        if fps_original_settings.Ambient then Lighting.Ambient = fps_original_settings.Ambient end
        if fps_original_settings.OutdoorAmbient then Lighting.OutdoorAmbient = fps_original_settings.OutdoorAmbient end
    end)
    
    -- Re-enable lighting effects
    for _, v in ipairs(Lighting:GetChildren()) do
        if v:IsA("BlurEffect") or v:IsA("BloomEffect") or v:IsA("SunRaysEffect") or 
           v:IsA("ColorCorrectionEffect") or v:IsA("DepthOfFieldEffect") or v:IsA("Atmosphere") then
            v.Enabled = true
        end
    end
    
    -- Restore terrain
    pcall(function()
        local terrain = workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.Decoration = true
        end
    end)
end

-- ============================================
-- SERVER HOP SYSTEM (moved up for UI usage)
-- ============================================
local function server_hop_random()
    pcall(function()
        TeleportService:Teleport(game.PlaceId, player)
    end)
end

local function rejoin_server()
    pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
end

local function copy_server_link()
    local link = "https://www.roblox.com/games/" .. tostring(game.PlaceId) .. "?privateServerLinkCode=" .. tostring(game.JobId)
    if setclipboard then
        setclipboard(link)
        if Window then Window:Notify({Title = "Server Link", Desc = "Copied to clipboard!", Time = 3}) end
    else
        if Window then Window:Notify({Title = "Server Link", Desc = "Clipboard not supported", Time = 3}) end
    end
end

local function hop_to_low_player_server()
    local maxPlayers = max_players_threshold
    
    local requestFunc
    if syn and syn.request then
        requestFunc = function(url) return syn.request({Url = url, Method = "GET"}).Body end
    elseif http_request then
        requestFunc = function(url) return http_request({Url = url, Method = "GET"}).Body end
    elseif request then
        requestFunc = function(url) return request({Url = url, Method = "GET"}).Body end
    end
    
    if not requestFunc then
        if Window then Window:Notify({Title = "Server Hop", Desc = "HTTP not available", Time = 3}) end
        return
    end
    
    local base = "https://games.roblox.com/v1/games/" .. tostring(game.PlaceId) .. "/servers/Public?sortOrder=Asc&limit=100"
    local cursor = nil
    
    repeat
        local url = base
        if cursor then url = url .. "&cursor=" .. HttpService:UrlEncode(tostring(cursor)) end
        
        local ok, body = pcall(function() return requestFunc(url) end)
        if not ok or not body then break end
        
        local success, data = pcall(function() return HttpService:JSONDecode(body) end)
        if not success or type(data) ~= "table" then break end
        
        for _, server in ipairs(data.data or {}) do
            local playing = tonumber(server.playing) or 0
            local serverId = tostring(server.id or "")
            local curJob = tostring(game.JobId or "")
            
            if serverId ~= "" and serverId ~= curJob and playing <= maxPlayers then
                pcall(function()
                    TeleportService:TeleportToPlaceInstance(game.PlaceId, serverId, player)
                end)
                return true
            end
        end
        cursor = data.nextPageCursor
    until not cursor
    
    if Window then Window:Notify({Title = "Server Hop", Desc = "No server found with <=" .. maxPlayers .. " players", Time = 3}) end
    return false
end

-- ============================================
-- REROLL SYSTEM (moved up for UI usage)
-- ============================================
local function find_reroll_remote()
    local ok, rf = pcall(function()
        return rs.Shared.Packages.Knit.Services.RaceService.RF.Reroll
    end)
    if ok and rf then return rf end
    return nil
end

local function get_current_race()
    -- Try to get race from UI (PlayerGui.Sell.RaceUI.CurrentRace)
    local ok, race = pcall(function()
        local raceText = player.PlayerGui.Sell.RaceUI.CurrentRace.Text
        -- Strip HTML tags: <font color="rgb(169,169,169)">Human</font> -> Human
        local raceName = raceText:gsub("<[^>]+>", "")
        return raceName
    end)
    if ok and race and race ~= "" then return race end
    
    -- Fallback: try StatMain.Slots.SlotTemplate.CurrentRace
    local ok2, race2 = pcall(function()
        local raceText = player.PlayerGui.Sell.RaceUI.StatMain.Slots.SlotTemplate.CurrentRace.Text
        -- Extract race name from: ~ Human ~
        local raceName = raceText:match("~%s*(.-)%s*~")
        return raceName
    end)
    if ok2 and race2 and race2 ~= "" then return race2 end
    
    return "Unknown"
end

local function get_spins_left()
    -- Try to get spins from UI (PlayerGui.Sell.RaceUI.Reroll.Spins)
    local ok, spins = pcall(function()
        local spinsText = player.PlayerGui.Sell.RaceUI.Reroll.Spins.Text
        -- Extract number from: "Spins: 0"
        local num = spinsText:match("%d+")
        return num or "0"
    end)
    if ok and spins then return spins end
    
    -- Fallback: try Menu path
    local ok2, spins2 = pcall(function()
        local spinsText = player.PlayerGui.Menu.Frame.Frame.Menus.Shop.Background.Reroll.Frame.Main.Spins.Text
        -- Extract number from: "Spins Left: 0"
        local num = spinsText:match("%d+")
        return num or "0"
    end)
    if ok2 and spins2 then return spins2 end
    
    return "0"
end

local function do_reroll()
    local remote = find_reroll_remote()
    if not remote then
        if Window then Window:Notify({Title = "Reroll", Desc = "Remote not found", Time = 3}) end
        return false
    end
    pcall(function() remote:InvokeServer() end)
    return true
end

local function start_auto_reroll()
    if reroll_enabled then return end
    reroll_enabled = true
    reroll_attempts = 0
    
    task.spawn(function()
        while reroll_enabled do
            -- Check spins first
            local spins = tonumber(get_spins_left()) or 0
            if spins <= 0 then
                if Window then Window:Notify({Title = "Reroll", Desc = "No spins left!", Time = 3}) end
                reroll_enabled = false
                break
            end
            
            -- Do the reroll
            do_reroll()
            reroll_attempts = reroll_attempts + 1
            task.wait(0.8) -- Wait for UI to update
            
            -- Check if we got target race
            local currentRace = get_current_race()
            if currentRace == reroll_target_race then
                if Window then Window:Notify({Title = "Reroll", Desc = "Got " .. reroll_target_race .. " after " .. reroll_attempts .. " attempts!", Time = 5}) end
                reroll_enabled = false
                break
            end
            
            task.wait(reroll_delay)
        end
    end)
end

local function stop_auto_reroll()
    reroll_enabled = false
end

-- ============================================
-- BUY SYSTEM
-- ============================================

local POTION_OPTIONS = {"HealthPotion1", "AttackDamagePotion1", "MinerPotion1", "MovementSpeedPotion1", "LuckPotion1"}
local PotionToBuy = POTION_OPTIONS[1]
local PotionBuyAmount = 1

local PurchaseRemote = nil

local function FindPurchaseRemote()
    if PurchaseRemote then return PurchaseRemote end
    local ok, rf = pcall(function()
        return rs.Shared.Packages.Knit.Services.ProximityService.RF.Purchase
    end)
    if ok and rf then
        PurchaseRemote = rf
        return rf
    end
    return nil
end

local function TryPurchase(itemName, amount)
    local purchase = FindPurchaseRemote()
    if not purchase then return false end
    local ok, res = pcall(function()
        return purchase:InvokeServer(itemName, amount)
    end)
    return ok, res
end

-- Dynamic shop item scanner
local function GetShopItems()
    local potions = {}
    local pickaxes = {}
    local itemPositions = {}
    
    local proximity = workspace:FindFirstChild("Proximity")
    if proximity then
        for _, item in ipairs(proximity:GetChildren()) do
            local name = item.Name
            
            -- Get position from HumanoidRootPart, PrimaryPart, or first BasePart
            local pos = nil
            local hrp = item:FindFirstChild("HumanoidRootPart")
            if hrp then
                pos = hrp.Position
            elseif item:IsA("Model") and item.PrimaryPart then
                pos = item.PrimaryPart.Position
            else
                local part = item:FindFirstChildWhichIsA("BasePart")
                if part then pos = part.Position end
            end
            
            if pos then
                -- Check if it has ProximityPrompt (means it's purchasable)
                local hasPrompt = false
                for _, desc in ipairs(item:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") then
                        hasPrompt = true
                        break
                    end
                end
                
                if hasPrompt then
                    itemPositions[name] = pos
                    
                    if name:lower():find("potion") then
                        table.insert(potions, name)
                    elseif name:lower():find("pickaxe") then
                        table.insert(pickaxes, name)
                    end
                end
            end
        end
    end
    
    return potions, pickaxes, itemPositions
end

-- Cached shop data
local ShopItemPositions = {}
local PICKAXE_OPTIONS = {}
local PickaxeToBuy = nil

-- Background shop scanner loop
task.spawn(function()
    while true do
        local p, pk, pos = GetShopItems()
        ShopItemPositions = pos
        if #p > 0 then POTION_OPTIONS = p end
        if #pk > 0 then 
            PICKAXE_OPTIONS = pk 
            if not PickaxeToBuy then PickaxeToBuy = pk[1] end
        end
        task.wait(5)
    end
end)

-- Buy any item by tweening to its position (uses RunService like farming)
local function BuyShopItem(itemName, amount)
    local pos = ShopItemPositions[itemName]
    
    if not pos then
        -- Try refresh
        local _, _, newPos = GetShopItems()
        ShopItemPositions = newPos
        pos = ShopItemPositions[itemName]
    end
    
    if not pos then
        if Window then Window:Notify({Title = "Buy", Desc = "Item not found", Time = 2}) end
        return false
    end
    
    local char = Players.LocalPlayer and Players.LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return false end
    
    -- Enable NoClip
    local noClipParts = {}
    for _, p in ipairs(char:GetDescendants()) do
        if p:IsA("BasePart") then
            noClipParts[p] = p.CanCollide
            p.CanCollide = false
        end
    end
    
    -- Tween using RunService (same as farming)
    local targetPos = pos + Vector3.new(0, 3, 0)
    local startPos = hrp.Position
    local distance = (targetPos - startPos).Magnitude
    local duration = math.max(distance / tween_spd, 0.1)
    local startTime = tick()
    local done = false
    
    local conn
    conn = RunService.Heartbeat:Connect(function()
        if done or not hrp or not hrp.Parent then
            if conn then conn:Disconnect() end
            done = true
            return
        end
        local elapsed = tick() - startTime
        local alpha = math.min(elapsed / duration, 1)
        local newPos = startPos:Lerp(targetPos, alpha)
        hrp.CFrame = CFrame.new(newPos)
        if alpha >= 1 then
            done = true
            if conn then conn:Disconnect() end
            hrp.CFrame = CFrame.new(targetPos)
        end
    end)
    
    while not done do task.wait() end
    task.wait(0.3)
    
    local ok, res = TryPurchase(itemName, amount or 1)
    
    -- Restore collision
    for part, original in pairs(noClipParts) do
        if part and part.Parent then
            pcall(function() part.CanCollide = original end)
        end
    end
    
    if ok then
        if Window then Window:Notify({Title = "Buy", Desc = "Purchased " .. itemName, Time = 2}) end
    else
        if Window then Window:Notify({Title = "Buy", Desc = "Failed to purchase", Time = 2}) end
    end
    return ok
end

local function get_enhance_equipment()
    local list, labels = {}, {}
    local playerGui = plrs.LocalPlayer:FindFirstChild("PlayerGui")
    local menu = playerGui and playerGui:FindFirstChild("Menu")
    local frame1 = menu and menu:FindFirstChild("Frame")
    local frame2 = frame1 and frame1:FindFirstChild("Frame")
    local menus = frame2 and frame2:FindFirstChild("Menus")
    local tools = menus and menus:FindFirstChild("Tools")
    if not tools then return list, labels end
    
    for _, item in ipairs(tools:GetDescendants()) do
        if item.Name:match("^%x+%-%x+%-%x+%-%x+%-%x+$") then
            local guid = item.Name
            local success, result = pcall(function() return FindEquipmentByGUID:InvokeServer(guid) end)
            if success and result and result.equipment then
                local eq = result.equipment
                eq.GUID = guid
                table.insert(list, eq)
                local label = string.format("%s | %s | +%d | %d%%", eq.Type or eq.Name or "?", eq.Ore or "?", eq.Upgrade or 0, eq.Quality or 0)
                table.insert(labels, label)
            end
        end
    end
    return list, labels
end

local function get_enhance_chance(equip)
    if not equip then return 0 end
    local success, chance = pcall(function() return CalculateSuccessChance:InvokeServer(equip) end)
    if success and typeof(chance) == "number" then return chance end
    return 0
end

local function do_enhance(equip)
    if not equip or not equip.GUID then return false end
    local success = pcall(function() return EnhanceEquipment:InvokeServer(equip.GUID) end)
    return success
end

-- Teleport variables
local tp_active = false
local avail_npcs, avail_players = {}, {}
local npc_parts, player_parts = {}, {}
local sel_npc, sel_player = nil, nil

pcall(function()
    local oldNamecall
    oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
        local method = getnamecallmethod()
        if method == "Kick" or method == "kick" then return nil end
        return oldNamecall(self, ...)
    end)
end)

local function teleport_to_location(locationName, targetPart)
    local char = plrs.LocalPlayer.Character
    if not char then return false end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp or tp_active then return false end
    tp_active = true
    
    local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
    local startPos = hrp.Position
    local distance = (targetPos - startPos).Magnitude
    local duration = distance / 35
    local startTime = tick()
    
    pcall(function() Window:Notify({Title = "Teleporting", Desc = locationName, Time = 3}) end)
    
    local runService = game:GetService("RunService")
    local conn
    conn = runService.Heartbeat:Connect(function()
        if not tp_active or not hrp or not hrp.Parent then conn:Disconnect(); tp_active = false; return end
        local elapsed = tick() - startTime
        local alpha = math.min(elapsed / duration, 1)
        hrp.CFrame = CFrame.new(startPos:Lerp(targetPos, alpha))
        if alpha >= 1 then conn:Disconnect(); tp_active = false; hrp.CFrame = CFrame.new(targetPos) end
    end)
    return true
end

local function refresh_npcs()
    avail_npcs, npc_parts = {}, {}
    local proximity = workspace:FindFirstChild("Proximity")
    if proximity then
        for _, npc in ipairs(proximity:GetChildren()) do
            local hrp = npc:FindFirstChild("HumanoidRootPart")
            if hrp then table.insert(avail_npcs, npc.Name); npc_parts[npc.Name] = hrp end
        end
    end
    table.sort(avail_npcs)
    if #avail_npcs == 0 then avail_npcs = {"None"} end
end

local function refresh_players()
    avail_players, player_parts = {}, {}
    for _, p in ipairs(plrs:GetPlayers()) do
        if p ~= plrs.LocalPlayer then
            local char = p.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then table.insert(avail_players, p.Name); player_parts[p.Name] = hrp end
        end
    end
    table.sort(avail_players)
    if #avail_players == 0 then avail_players = {"None"} end
end

refresh_npcs()
refresh_players()
sel_npc = avail_npcs[1]
sel_player = avail_players[1]

-- Helper to update dropdown values (Dummy UI uses Clear/Add)
local function updateDropdown(dropdown, newList)
    dropdown:Clear()
    for _, item in ipairs(newList) do
        dropdown:Add(item)
    end
end


-- ============================================
-- CREATE UI (DUMMY UI LIBRARY)
-- ============================================

Window = Library:Window({
    Title = "The Forge",
    Desc = "Snoe Project",
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.Z,
        Size = UDim2.new(0, 500, 0, 400)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "Close"
    }
})

-- Info Tab
local StatusLabel
local InfoTab = Window:Tab({Title = "Info", Icon = "info"}) do
    InfoTab:Section({Title = "Player Info"})
    
    StatusLabel = InfoTab:Label({
        Title = "",
        Desc = "Loading..."
    })
    
    InfoTab:Section({Title = "Actions"})
    
    InfoTab:Button({
        Title = "Join Snoe Discord",
        Desc = "Copy invite link to clipboard",
        Callback = function()
            setclipboard("https://discord.gg/jCGGNedr")
            Window:Notify({Title = "Copied!", Desc = "Discord link copied", Time = 3})
        end
    })
    
    InfoTab:Button({
        Title = "Redeem All Codes",
        Desc = "Fetch & redeem active codes from wiki",
        Callback = function()
            Window:Notify({Title = "Fetching...", Desc = "Getting codes from wiki", Time = 2})
            local codes = {}
            local success, result = pcall(function() return game:HttpGet("https://forge-roblox.fandom.com/wiki/Codes") end)
            if success and result then
                local list_start = result:find("List of Codes")
                local expired_start = result:lower():find("these codes are ones that were used before")
                if list_start then
                    local active_section = result:sub(list_start, expired_start or #result)
                    for td_content in active_section:gmatch("<td[^>]*>%s*([^<]+)%s*</td>") do
                        local trimmed = td_content:match("^%s*(.-)%s*$")
                        if trimmed and #trimmed >= 4 and #trimmed <= 20 and trimmed:match("^[A-Z0-9!]+$") and not trimmed:match("^%d+$") then
                            table.insert(codes, trimmed)
                        end
                    end
                end
            end
            for _, code in ipairs(codes) do
                pcall(function()
                    rs:WaitForChild("Shared"):WaitForChild("Packages"):WaitForChild("Knit"):WaitForChild("Services"):WaitForChild("CodeService"):WaitForChild("RF"):WaitForChild("RedeemCode"):InvokeServer(code)
                end)
                task.wait(0.5)
            end
            Window:Notify({Title = "Done", Desc = "Tried " .. #codes .. " codes", Time = 3})
        end
    })
end

Window:Line()

-- Player Tab
local AutoQuestToggle
local PlayerTab = Window:Tab({Title = "Player", Icon = "user"}) do
    PlayerTab:Section({Title = "Auto Features"})
    
    PlayerTab:Toggle({
        Title = "Auto Run",
        Desc = "Automatically sprint",
        Value = false,
        Callback = function(v) is_running = v end
    })
    
    PlayerTab:Toggle({
        Title = "Auto Swing",
        Desc = "Automatically swing tools",
        Value = false,
        Callback = function(v) is_swinging = v end
    })
    
    PlayerTab:Section({Title = "Auto Quest"})
    
    avail_quests, quest_display_names = get_quest_names()
    local quest_dropdown_values = {"Auto (All Quests)"}
    local quest_dropdown_map = {["Auto (All Quests)"] = nil}
    for _, questId in ipairs(avail_quests) do
        local label = quest_display_names[questId] or questId
        table.insert(quest_dropdown_values, label)
        quest_dropdown_map[label] = questId
    end
    
    local QuestDropdown = PlayerTab:Dropdown({
        Title = "Select Quest",
        List = quest_dropdown_values,
        Value = "Auto (All Quests)",
        Callback = function(v)
            sel_quest = quest_dropdown_map[v]
            current_quest_task = nil
        end
    })
    
    PlayerTab:Button({
        Title = "Refresh Quests",
        Desc = "Scan for available quests",
        Callback = function()
            avail_quests, quest_display_names = get_quest_names()
            quest_dropdown_values = {"Auto (All Quests)"}
            quest_dropdown_map = {["Auto (All Quests)"] = nil}
            for _, questId in ipairs(avail_quests) do
                local label = quest_display_names[questId] or questId
                table.insert(quest_dropdown_values, label)
                quest_dropdown_map[label] = questId
            end
            updateDropdown(QuestDropdown, quest_dropdown_values)
            Window:Notify({Title = "Refreshed", Desc = "Found " .. #avail_quests .. " quests", Time = 3})
        end
    })
    
    AutoQuestToggle = PlayerTab:Toggle({
        Title = "Auto Quest",
        Desc = "Automatically complete quest objectives",
        Value = false,
        Callback = function(v)
            auto_quest_en = v
            if v then
                was_auto_quest_active = true
                current_quest_task = nil
                last_quest_check = 0
                Window:Notify({Title = "Auto Quest", Desc = "Scanning...", Time = 3})
            else
                was_auto_quest_active = false
                cancel_current_tween()
                current_quest_task = nil
                is_farming = false
                is_mob_farm = false
                local char = plrs.LocalPlayer and plrs.LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.Anchored = false end
            end
        end
    })
    
    PlayerTab:Toggle({
        Title = "Stuck Detection",
        Desc = "Reset when stuck",
        Value = true,
        Callback = function(v) death_recovery_en = v end
    })
    
    PlayerTab:Slider({
        Title = "Stuck Threshold",
        Min = 2,
        Max = 15,
        Value = 5,
        Rounding = 0,
        Callback = function(v) stuck_threshold = v end
    })
end

Window:Line()

-- Farm Tab
local AutoFarmToggle, AutoMobFarmToggle
avail_ores = get_all_ore_tps()
if #avail_ores == 0 then avail_ores = {"None"} end
avail_mobs = get_all_mob_tps()
if #avail_mobs == 0 then avail_mobs = {"None"} end

-- Background loop to refresh ores and mobs
task.spawn(function()
    while true do
        avail_ores = get_all_ore_tps()
        if #avail_ores == 0 then avail_ores = {"None"} end
        avail_mobs = get_all_mob_tps()
        if #avail_mobs == 0 then avail_mobs = {"None"} end
        task.wait(5)
    end
end)

local FarmTab = Window:Tab({Title = "Farm", Icon = "hammer"}) do
    FarmTab:Section({Title = "Settings"})
    
    FarmTab:Dropdown({
        Title = "Travel Method",
        List = {"Above", "Underground"},
        Value = travel_method,
        Callback = function(v) travel_method = v end
    })
    
    FarmTab:Section({Title = "Ore Mining"})
    
    FarmTab:Dropdown({
        Title = "Select Ore",
        List = avail_ores,
        Callback = function(v)
            if sel_ore ~= v and is_farming then cancel_current_tween() end
            sel_ore = v
        end
    })
    
    AutoFarmToggle = FarmTab:Toggle({
        Title = "Auto Farm Ore",
        Value = false,
        Callback = function(v)
            is_farming = v
            if not v then cancel_current_tween() end
            if v and auto_quest_en then
                auto_quest_en = false
                AutoQuestToggle:SetValue(false)
            end
        end
    })
    
    FarmTab:Section({Title = "Ore Cancel"})
    
    FarmTab:Dropdown({
        Title = "Wanted Ores",
        List = get_ore_nms(),
        Multi = true,
        Callback = function(v)
            ore_cancel_wl = {}
            for ore, enabled in pairs(v) do if enabled then table.insert(ore_cancel_wl, ore) end end
        end
    })
    
    FarmTab:Toggle({
        Title = "Enable Ore Cancel",
        Desc = "Skip rocks without wanted ores",
        Value = false,
        Callback = function(v) ore_cancel_en = v end
    })
    
    FarmTab:Section({Title = "Mob Combat"})
    
    FarmTab:Dropdown({
        Title = "Select Mob",
        List = avail_mobs,
        Callback = function(v)
            if sel_mob ~= v and is_mob_farm then cancel_current_tween() end
            sel_mob = v
        end
    })
    
    AutoMobFarmToggle = FarmTab:Toggle({
        Title = "Auto Fight Mob",
        Value = false,
        Callback = function(v)
            is_mob_farm = v
            if not v then cancel_current_tween() end
            if v and auto_quest_en then
                auto_quest_en = false
                AutoQuestToggle:SetValue(false)
            end
        end
    })
end

Window:Line()

-- Sell Tab
local SellTab = Window:Tab({Title = "Sell", Icon = "dollar-sign"}) do
    SellTab:Section({Title = "Manual Sell"})
    
    SellTab:Dropdown({
        Title = "Select Ore",
        List = get_ore_nms(),
        Callback = function(v) sel_sell_ore = v end
    })
    
    SellTab:Slider({
        Title = "Quantity",
        Min = 1,
        Max = 1000,
        Value = 1,
        Rounding = 0,
        Callback = function(v) sell_qty = v end
    })
    
    SellTab:Button({
        Title = "Sell",
        Desc = "Sell selected ore",
        Callback = function()
            if sel_sell_ore then
                local qty = math.min(sell_qty, get_ore_qty(sel_sell_ore))
                if qty > 0 then
                    sell_ore(sel_sell_ore, qty)
                    Window:Notify({Title = "Sold!", Desc = qty .. "x " .. sel_sell_ore, Time = 3})
                end
            end
        end
    })
    
    SellTab:Section({Title = "Auto Sell"})
    
    SellTab:Dropdown({
        Title = "Add to Whitelist",
        List = get_ore_nms(),
        Multi = true,
        Callback = function(v)
            auto_sell_wl = {}
            for ore, enabled in pairs(v) do if enabled then table.insert(auto_sell_wl, ore) end end
        end
    })
    
    SellTab:Slider({
        Title = "Interval (seconds)",
        Min = 1,
        Max = 60,
        Value = 10,
        Rounding = 0,
        Callback = function(v) auto_sell_intv = v end
    })
    
    SellTab:Toggle({
        Title = "Auto Sell",
        Desc = "Automatically sell whitelisted ores",
        Value = false,
        Callback = function(v) auto_sell_en = v end
    })
    
    SellTab:Section({Title = "Auto Favorite"})
    
    SellTab:Dropdown({
        Title = "Add to Whitelist",
        List = get_ore_nms(),
        Multi = true,
        Callback = function(v)
            auto_fav_wl = {}
            for ore, enabled in pairs(v) do if enabled then table.insert(auto_fav_wl, ore) end end
        end
    })
    
    SellTab:Toggle({
        Title = "Auto Favorite",
        Desc = "Automatically favorite ores",
        Value = false,
        Callback = function(v) auto_fav_en = v end
    })
end

Window:Line()

-- Forge Tab
local ForgeTab = Window:Tab({Title = "Forge", Icon = "flame"}) do
    ForgeTab:Section({Title = "Forge"})
    
    ForgeTab:Button({
        Title = "Open Forge UI",
        Callback = function()
            openForgeUI()
        end
    })
    
    ForgeTab:Toggle({
        Title = "Instant Forge",
        Desc = "Auto-completes all forge minigames",
        Value = false,
        Callback = function(v)
            meltEnabled = v
            pourEnabled = v
            autoHammerEnabled = v
            hammerPerfectEnabled = v
            
            if v then
                -- Enable all patches
                safePatch("MeltMinigame", meltAutoComplete)
                safePatch("PourMinigame", pourAutoComplete)
                
                -- Patch hammer perfect
                local moduleTable = tryRequireControllerModule("HammerMinigame")
                if moduleTable then
                    if _orig_Hammer_CreateNote == nil then
                        _orig_Hammer_CreateNote = moduleTable.CreateNote
                    end
                    moduleTable.CreateNote = function(_, noteData)
                        local Lifetime = 1
                        if noteData and noteData.Lifetime then
                            Lifetime = noteData.Lifetime
                        end
                        local perfectDelay = Lifetime * 25 / 44
                        task.wait(perfectDelay)
                        return true
                    end
                end
            else
                -- Disable all patches
                restorePatch("MeltMinigame")
                restorePatch("PourMinigame")
                
                -- Restore hammer
                local moduleTable = tryRequireControllerModule("HammerMinigame")
                if moduleTable and _orig_Hammer_CreateNote then
                    moduleTable.CreateNote = _orig_Hammer_CreateNote
                    _orig_Hammer_CreateNote = nil
                end
            end
        end
    })
end

Window:Line()

-- Enhance Tab
local EnhanceTab = Window:Tab({Title = "Enhance", Icon = "arrow-up"}) do
    EnhanceTab:Section({Title = "Auto Enhance"})
    
    EnhanceTab:Label({
        Title = "Instructions",
        Desc = "Open inventory → Equipments tab, then click Refresh"
    })
    
    local EnhanceDropdown = EnhanceTab:Dropdown({
        Title = "Select Equipment",
        List = {"None - Open inventory first"},
        Callback = function(v)
            for i, label in ipairs(enhance_equip_labels) do
                if label == v then sel_enhance_equip = enhance_equip_list[i]; break end
            end
        end
    })
    
    EnhanceTab:Button({
        Title = "Refresh Equipment",
        Desc = "Open your inventory (Equipments tab) first",
        Callback = function()
            enhance_equip_list, enhance_equip_labels = get_enhance_equipment()
            if #enhance_equip_labels == 0 then
                enhance_equip_labels = {"None - Open inventory Equipments tab"}
                sel_enhance_equip = nil
                Window:Notify({Title = "No Equipment", Desc = "Open inventory → Equipments tab first", Time = 3})
            else
                sel_enhance_equip = enhance_equip_list[1]
                Window:Notify({Title = "Refreshed", Desc = "Found " .. #enhance_equip_list .. " equipment(s)", Time = 3})
            end
            updateDropdown(EnhanceDropdown, enhance_equip_labels)
        end
    })
    
    EnhanceTab:Toggle({
        Title = "Only Enhance 100%",
        Desc = "Only enhance when success rate is 100%",
        Value = true,
        Callback = function(v) enhance_only_100 = v end
    })
    
    EnhanceTab:Slider({
        Title = "Target Upgrade Level",
        Min = 1,
        Max = 9,
        Value = 9,
        Rounding = 0,
        Callback = function(v) enhance_target_lvl = v end
    })
    
    EnhanceTab:Toggle({
        Title = "Auto Enhance",
        Desc = "Automatically enhance equipment",
        Value = false,
        Callback = function(v) auto_enhance_en = v end
    })
end

Window:Line()

-- ============================================
-- BUY TAB
-- ============================================
local BuyTab = Window:Tab({Title = "Buy", Icon = "shopping-cart"}) do
    BuyTab:Section({Title = "Potions"})
    
    BuyTab:Dropdown({
        Title = "Select Potion",
        List = #POTION_OPTIONS > 0 and POTION_OPTIONS or {"Loading..."},
        Value = PotionToBuy,
        Callback = function(v) PotionToBuy = v end
    })
    
    BuyTab:Slider({
        Title = "Amount",
        Min = 1,
        Max = 10,
        Value = PotionBuyAmount,
        Callback = function(v) PotionBuyAmount = v end
    })
    
    BuyTab:Button({
        Title = "Buy Potion",
        Callback = function()
            BuyShopItem(PotionToBuy, PotionBuyAmount)
        end
    })
    
    BuyTab:Section({Title = "Pickaxes"})
    
    BuyTab:Dropdown({
        Title = "Select Pickaxe",
        List = #PICKAXE_OPTIONS > 0 and PICKAXE_OPTIONS or {"Loading..."},
        Value = PickaxeToBuy,
        Callback = function(v) PickaxeToBuy = v end
    })
    
    BuyTab:Button({
        Title = "Buy Pickaxe",
        Callback = function()
            if PickaxeToBuy then
                BuyShopItem(PickaxeToBuy, 1)
            end
        end
    })
end

Window:Line()

-- ============================================
-- REROLLS TAB
-- ============================================
local RerollsTab = Window:Tab({Title = "Rerolls", Icon = "refresh-cw"}) do
    RerollsTab:Section({Title = "Race Reroll"})
    
    local RaceLabel = RerollsTab:Label({
        Title = "Current Race",
        Desc = get_current_race()
    })
    
    local SpinsLabel = RerollsTab:Label({
        Title = "Spins Left",
        Desc = get_spins_left()
    })
    
    RerollsTab:Dropdown({
        Title = "Target Race",
        Desc = "Stop when this race is rolled",
        List = RACE_OPTIONS,
        Value = reroll_target_race,
        Callback = function(v) reroll_target_race = v end
    })
    
    RerollsTab:Button({
        Title = "Reroll Once",
        Desc = "Reroll your race once",
        Callback = function()
            do_reroll()
            task.wait(0.5)
            RaceLabel:SetDesc(get_current_race())
            SpinsLabel:SetDesc(get_spins_left())
        end
    })
    
    RerollsTab:Toggle({
        Title = "Auto Reroll",
        Desc = "Reroll until target race is obtained",
        Value = false,
        Callback = function(v)
            if v then
                start_auto_reroll()
            else
                stop_auto_reroll()
            end
        end
    })
end

Window:Line()

-- ============================================
-- TELEPORT TAB
-- ============================================
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map-pin"}) do
    TeleportTab:Section({Title = "Players"})
    
    local PlayerDropdown = TeleportTab:Dropdown({
        Title = "Select Player",
        List = avail_players,
        Value = avail_players[1],
        Callback = function(v) sel_player = v end
    })
    
    TeleportTab:Button({
        Title = "Teleport to Player",
        Callback = function()
            if sel_player and sel_player ~= "None" and player_parts[sel_player] then
                teleport_to_location(sel_player, player_parts[sel_player])
            end
        end
    })
    
    TeleportTab:Button({
        Title = "Refresh Players",
        Callback = function()
            refresh_players()
            updateDropdown(PlayerDropdown, avail_players)
        end
    })
    
    TeleportTab:Section({Title = "NPCs"})
    
    local NPCDropdown = TeleportTab:Dropdown({
        Title = "Select NPC",
        List = avail_npcs,
        Value = avail_npcs[1],
        Callback = function(v) sel_npc = v end
    })
    
    TeleportTab:Button({
        Title = "Teleport to NPC",
        Callback = function()
            if sel_npc and sel_npc ~= "None" and npc_parts[sel_npc] then
                teleport_to_location(sel_npc, npc_parts[sel_npc])
            end
        end
    })
end

Window:Line()

-- ============================================
-- MISC TAB
-- ============================================
local MiscTab = Window:Tab({Title = "Misc", Icon = "settings"}) do
    MiscTab:Section({Title = "Graphics"})
    
    MiscTab:Toggle({
        Title = "X-Ray",
        Desc = "See through walls",
        Value = false,
        Callback = function(v)
            xray_en = v
            if v then
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") and obj.Parent then
                        local isRock = obj:IsDescendantOf(workspace:FindFirstChild("Rocks") or workspace)
                        local isMob = obj:IsDescendantOf(workspace:FindFirstChild("Living") or workspace)
                        local isPlayer = obj:IsDescendantOf(plrs.LocalPlayer.Character or workspace)
                        if not isRock and not isMob and not isPlayer then
                            if xray_original_transparency[obj] == nil then xray_original_transparency[obj] = obj.Transparency end
                            obj.Transparency = 1
                        end
                    end
                end
            else
                for obj, orig in pairs(xray_original_transparency) do
                    if obj and obj.Parent then obj.Transparency = orig end
                end
                xray_original_transparency = {}
            end
        end
    })
    
    MiscTab:Toggle({
        Title = "Improve FPS",
        Desc = "Reduce graphics for better performance",
        Value = false,
        Callback = function(v)
            if v then enable_fps_boost() else disable_fps_boost() end
        end
    })
    
    MiscTab:Toggle({
        Title = "Anti AFK",
        Desc = "Prevent being kicked for inactivity",
        Value = false,
        Callback = function(v)
            if v then
                local vu = game:GetService("VirtualUser")
                plrs.LocalPlayer.Idled:Connect(function() vu:CaptureController(); vu:ClickButton2(Vector2.new()) end)
            end
        end
    })
    
    MiscTab:Section({Title = "Server"})
    
    local low_player_mode = false
    
    MiscTab:Toggle({
        Title = "Low Player Mode",
        Desc = "Server hop will find servers with ≤5 players",
        Value = false,
        Callback = function(v) low_player_mode = v end
    })
    
    MiscTab:Button({
        Title = "Server Hop",
        Callback = function()
            if low_player_mode then
                task.spawn(hop_to_low_player_server)
            else
                server_hop_random()
            end
        end
    })
    
    MiscTab:Button({
        Title = "Rejoin",
        Callback = function() rejoin_server() end
    })
    
    MiscTab:Button({
        Title = "Copy Server Link",
        Callback = function() copy_server_link() end
    })
end

-- ============================================
-- MAIN LOOPS
-- ============================================

-- Skipped rocks cleanup
task.spawn(function()
    while true do
        task.wait(5)
        for rock, _ in pairs(skipped_rocks) do
            if not rock or not rock.Parent then
                skipped_rocks[rock] = nil
            else
                local hp = get_ore_hp(rock)
                if not hp or hp <= 0 then skipped_rocks[rock] = nil end
            end
        end
    end
end)

-- Death Recovery / Stuck Detection
local last_position = nil
local last_move_time = tick()

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
                    if distance_moved > 1 then last_move_time = tick() end
                end
                last_position = current_pos
                if tick() - last_move_time >= stuck_threshold then
                    log_action("Auto Quest: Stuck detected, resetting...")
                    current_quest_task = nil
                    is_farming = false
                    is_mob_farm = false
                    is_mining = false
                    is_atk = false
                    cancel_current_tween()
                    task.wait(0.5)
                    last_quest_check = 0
                    last_move_time = tick()
                end
            end
        else
            last_position = nil
            last_move_time = tick()
        end
    end
end)

-- Main Loop
task.spawn(function()
    while true do
        task.wait(0.1)

        if is_running then pcall(function() run_evt:InvokeServer() end) end

        if is_swinging and tool_act_evt then
            pcall(function() tool_act_evt:InvokeServer("Pickaxe") end)
            pcall(function() tool_act_evt:InvokeServer("Weapon") end)
        end

        -- Update player info
        if tick() - last_inv_upd >= 1 then
            local tot_cnt, tot_val = get_inv_ore_stats()
            local lvlText, gldText, xpText = "?", "?", "?"
            local hud = plrs.LocalPlayer:FindFirstChild("PlayerGui") and plrs.LocalPlayer.PlayerGui:FindFirstChild("Main") and plrs.LocalPlayer.PlayerGui.Main:FindFirstChild("Screen") and plrs.LocalPlayer.PlayerGui.Main.Screen:FindFirstChild("Hud")
            if hud then
                local lvl = hud:FindFirstChild("Level")
                if lvl and lvl:IsA("TextLabel") then lvlText = lvl.Text end
                local gld = hud:FindFirstChild("Gold")
                if gld and gld:IsA("TextLabel") then gldText = gld.Text end
                local xp_br = hud:FindFirstChild("XPbarHover")
                if xp_br and xp_br:FindFirstChild("Frame") then
                    local xp_lbl = xp_br.Frame:FindFirstChild("TextLabel")
                    if xp_lbl and xp_lbl:IsA("TextLabel") then xpText = xp_lbl.Text end
                end
            end
            pcall(function()
                StatusLabel:SetDesc("Level: " .. lvlText .. "\nGold: " .. gldText .. "\nXP: " .. xpText .. "\nOres: " .. tot_cnt .. "\nValue: $" .. fmt_money(tot_val))
            end)
            last_inv_upd = tick()
        end

        -- Manual ore farming
        if is_farming and sel_ore and not is_mining and not auto_quest_en then
            local ores = get_ore_insts(sel_ore)
            while #ores > 0 and is_farming do
                local ore = ores[1]
                if not ore or not ore:FindFirstChild("Hitbox") then break end
                is_mining = true
                tween_to_pos(ore.Hitbox.CFrame.Position, tween_spd)
                mine_ore(ore, tool_act_evt)
                is_mining = false
                if skipped_rocks[ore] then ores = get_ore_insts(sel_ore) else break end
            end
        end

        -- Auto Quest farming
        if auto_quest_en and is_farming and sel_ore and not is_mining then
            local ores = get_ore_insts(sel_ore)
            while #ores > 0 and is_farming and auto_quest_en do
                local ore = ores[1]
                if not ore or not ore:FindFirstChild("Hitbox") then break end
                is_mining = true
                tween_to_pos(ore.Hitbox.CFrame.Position, tween_spd)
                mine_ore(ore, tool_act_evt)
                is_mining = false
                if skipped_rocks[ore] then ores = get_ore_insts(sel_ore) else break end
            end
        end
        if not is_farming then is_mining = false end

        -- Manual mob farming
        if is_mob_farm and sel_mob and not is_atk and not auto_quest_en then
            local mobs = get_mob_insts(sel_mob)
            if #mobs > 0 and mobs[1]:FindFirstChild("HumanoidRootPart") then
                is_atk = true
                tween_to_pos(mobs[1].HumanoidRootPart.Position, mob_tween_spd)
                atk_mob(mobs[1], tool_act_evt)
                is_atk = false
            end
        end

        -- Auto Quest mob farming
        if auto_quest_en and is_mob_farm and sel_mob and not is_atk then
            local mobs = get_mob_insts(sel_mob)
            if #mobs > 0 and mobs[1]:FindFirstChild("HumanoidRootPart") then
                is_atk = true
                tween_to_pos(mobs[1].HumanoidRootPart.Position, mob_tween_spd)
                atk_mob(mobs[1], tool_act_evt)
                is_atk = false
            end
        end
        if not is_mob_farm then is_atk = false end

        -- Auto sell
        if auto_sell_en and tick() - last_auto_sell >= auto_sell_intv then
            auto_sell_whitelist()
            last_auto_sell = tick()
        end

        -- Auto favorite
        if auto_fav_en and tick() - last_auto_fav >= 1 then
            auto_fav_whitelist()
            last_auto_fav = tick()
        end

        -- Auto Quest check
        if auto_quest_en and tick() - last_quest_check >= 0.5 then
            pcall(run_auto_quest)
            last_quest_check = tick()
        end

        -- Auto Enhance
        if auto_enhance_en and sel_enhance_equip and tick() - last_enhance_refresh >= 1 then
            last_enhance_refresh = tick()
            local success, result = pcall(function() return FindEquipmentByGUID:InvokeServer(sel_enhance_equip.GUID) end)
            if success and result and result.equipment then
                local equip = result.equipment
                local currentLvl = equip.Upgrade or 0
                if currentLvl >= enhance_target_lvl then
                    Window:Notify({Title = "Enhance Complete", Desc = (equip.Type or "Equipment") .. " reached +" .. currentLvl, Time = 3})
                    auto_enhance_en = false
                else
                    local chance = get_enhance_chance(equip)
                    local chanceOk = not enhance_only_100 or chance >= 100
                    if chanceOk then
                        local enhanced = do_enhance(equip)
                        if enhanced then
                            Window:Notify({Title = "Enhanced!", Desc = (equip.Type or "Equipment") .. " +" .. currentLvl .. " → +" .. (currentLvl + 1), Time = 2})
                        end
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)


-- Open Greedy Cey dialogue on startup
task.spawn(function()
    task.wait(1)
    open_greedy_cey_dialogue()
end)

Window:Notify({Title = "The Forge", Desc = "Script loaded!", Time = 5})
