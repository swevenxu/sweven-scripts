-- Underground Auto Farm (Dummy UI)

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- Valid item names
local ValidItems = {
    "Carrot", "Jelly Beans", "Potato", "Fish Bone", "Tomato Soup", "Pizza Crust End",
    "Milk", "Corn", "Strawberry", "Strange Meat", "Peppermint Candy",
    "Half Watermelon", "Olive Oil", "Fresh Meat", "Honey", "Waffle", "Christmas Cookie",
    "Grapes", "Rabbit Haunch", "Luminescent Berries", "Turkey", "Pumpkin", "Banana",
    "Leg Meat", "Mini Worm", "Cheap Soda", "Chocolate", "Canned Pudding", "Pufferfish",
    "Watermelon", "Halloween Pumpkin", "Bread", "Crate of Eggs", "Gingerbread Man",
    "Cheese", "Shrimp", "Macaron", "Bloomaw's Eye", "Cherry", "Crocodile Egg",
    "Blood Crocodile Egg", "MRE", "Roast Piglet", "Crab", "Lobster", "Crocodile Tail",
    "Blood Crocodile Tail", "Truffle", "Imported Caviar", "Heart of Stone", "Durian",
    "Yellowfin Tuna", "Giant Squid", "Gingerbread House", "Bloom Heart", "Golden Bar"
}

local ValidItemsSet = {}
for _, name in ipairs(ValidItems) do
    ValidItemsSet[name] = true
end

-- Big items that fill hands
local BigItems = {
    "Turkey", "Pumpkin", "Banana", "Watermelon", "Halloween Pumpkin",
    "Bread", "Crate of Eggs", "Gingerbread Man", "MRE", "Roast Piglet", "Crab",
    "Lobster", "Crocodile Tail", "Blood Crocodile Tail", "Heart of Stone", "Durian",
    "Yellowfin Tuna", "Giant Squid", "Gingerbread House", "Bloom Heart"
}

local BigItemsSet = {}
for _, name in ipairs(BigItems) do
    BigItemsSet[name] = true
end

-- Variables
local flyEnabled = false
local flySpeed = 50
local flyConnection = nil
local autoInteract = false
local autoElevatorEnabled = false
local autoGoDeepEnabled = false
local xrayEnabled = false
local xrayOriginalTransparency = {}
local itemESPEnabled = false
local containerESPEnabled = false
local espFolder = nil
local VIM = cloneref(game:GetService("VirtualInputManager"))
local ContainerTypes = {"Cabinet", "Crate", "OilBucket", "Fridge", "Barrel"}
local currentSublevel = ""
local goingToElevator = false
local isDroppingItems = false
local isWaitingAtElevator = false
local shouldRestartFly = false -- Track if we need to restart fly after new floor
local floorStartTime = tick() -- When we entered this floor
local hasVotedGoDeep = false -- Only vote once per floor
local cameraLockEnabled = false
local cameraLockConnection = nil
local lastPosition = nil
local stuckTime = 0
local currentTargetPart = nil
local bobPhase = 0
local npcESPEnabled = false
local autoGiftBoxEnabled = false

-- Failed pickup tracking (mimic detection)
local failedPickupAttempts = {} -- [part] = {attempts = number, lastAttemptTime = tick()}
local blacklistedItems = {} -- Items that failed too many times (likely mimics)
local MAX_PICKUP_ATTEMPTS = 3 -- Max attempts before blacklisting
local ATTEMPT_TIMEOUT = 8 -- Seconds near item before counting as failed attempt
local BLACKLIST_DURATION = 120 -- Seconds to keep item blacklisted

-- ============ SUBLEVEL DETECTION ============
local function getSublevel()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return "" end
    local uiAnimation = pg:FindFirstChild("UIAnimation")
    if not uiAnimation then return "" end
    local sublevelDisplay = uiAnimation:FindFirstChild("SublevelDisplay")
    if not sublevelDisplay then return "" end
    local level = sublevelDisplay:FindFirstChild("Level")
    if level and level:IsA("TextLabel") then
        return level.Text or ""
    end
    return ""
end

-- ============ HOTBAR FUNCTIONS ============
local function findHotbar()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return nil end
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") and gui.Name == "Main" then
            local function searchForBottom(parent)
                for _, child in ipairs(parent:GetChildren()) do
                    if child.Name == "Bottom" and child:IsA("Frame") then
                        local slot1 = child:FindFirstChild("1")
                        if slot1 and slot1:IsA("Frame") and slot1:FindFirstChild("Tool") then
                            return child
                        end
                    end
                    if child:IsA("Frame") or child:IsA("Folder") then
                        local found = searchForBottom(child)
                        if found then return found end
                    end
                end
                return nil
            end
            return searchForBottom(gui)
        end
    end
    return nil
end

local function isHotbarEmpty()
    local hotbar = findHotbar()
    if not hotbar then return true end
    for i = 1, 4 do
        local slot = hotbar:FindFirstChild(tostring(i))
        if slot then
            local itemDetails = slot:FindFirstChild("ItemDetails")
            if itemDetails then
                local itemName = itemDetails:FindFirstChild("ItemName")
                if itemName and itemName.Text and itemName.Text ~= "" then
                    return false
                end
            end
        end
    end
    return true
end

local function isHotbarFull()
    local hotbar = findHotbar()
    if not hotbar then return false end
    local filledSlots = 0
    for i = 1, 4 do
        local slot = hotbar:FindFirstChild(tostring(i))
        if slot then
            local itemDetails = slot:FindFirstChild("ItemDetails")
            if itemDetails then
                local itemName = itemDetails:FindFirstChild("ItemName")
                if itemName and itemName.Text and itemName.Text ~= "" then
                    filledSlots = filledSlots + 1
                end
            end
        end
    end
    return filledSlots >= 4
end

local function hasBigItem()
    local hotbar = findHotbar()
    if not hotbar then return false end
    for i = 1, 4 do
        local slot = hotbar:FindFirstChild(tostring(i))
        if slot then
            local itemDetails = slot:FindFirstChild("ItemDetails")
            if itemDetails then
                local itemName = itemDetails:FindFirstChild("ItemName")
                if itemName and itemName.Text and itemName.Text ~= "" then
                    if BigItemsSet[itemName.Text] then
                        return true
                    end
                end
            end
        end
    end
    return false
end

-- ============ MIMIC DETECTION ============
local MimicKeywords = {"mimic", "Mimic", "MIMIC", "fake", "Fake", "trap", "Trap"}
local SuspiciousAttributes = {"IsMimic", "Mimic", "Fake", "Hostile", "Enemy", "Monster"}

local function hasMonsterNearby(position, threshold)
    threshold = threshold or 12
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return false end
    local monsters = gameSystem:FindFirstChild("Monsters")
    if not monsters then return false end
    
    for _, monster in ipairs(monsters:GetChildren()) do
        local monsterPos = nil
        -- Try multiple ways to get monster position
        local hrp = monster:FindFirstChild("HumanoidRootPart")
        if hrp then
            monsterPos = hrp.Position
        else
            local checker = monster:FindFirstChild("Checker")
            if checker then
                monsterPos = checker.Position
            else
                local root = monster:FindFirstChild("Root")
                if root then
                    monsterPos = root.Position
                else
                    -- Try to find any BasePart as fallback
                    for _, child in ipairs(monster:GetDescendants()) do
                        if child:IsA("BasePart") then
                            monsterPos = child.Position
                            break
                        end
                    end
                end
            end
        end
        if monsterPos and (monsterPos - position).Magnitude < threshold then
            return true
        end
    end
    return false
end

local function checkNameForMimic(name)
    if not name then return false end
    local lowerName = name:lower()
    for _, keyword in ipairs(MimicKeywords) do
        if lowerName:find(keyword:lower()) then
            return true
        end
    end
    return false
end

local function checkAttributesForMimic(obj)
    if not obj then return false end
    for _, attr in ipairs(SuspiciousAttributes) do
        local val = nil
        pcall(function() val = obj:GetAttribute(attr) end)
        if val == true then return true end
    end
    return false
end

local function checkParentChainForMimic(part)
    local current = part
    local depth = 0
    while current and depth < 10 do
        -- Check name
        if checkNameForMimic(current.Name) then return true end
        -- Check attributes
        if checkAttributesForMimic(current) then return true end
        -- Check if parent is in Monsters folder
        local gameSystem = workspace:FindFirstChild("GameSystem")
        if gameSystem then
            local monsters = gameSystem:FindFirstChild("Monsters")
            if monsters and current:IsDescendantOf(monsters) then
                return true
            end
        end
        current = current.Parent
        depth = depth + 1
    end
    return false
end

local function hasAnimationController(model)
    if not model then return false end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("AnimationController") or desc:IsA("Animator") then
            -- Items shouldn't have animation controllers
            return true
        end
        if desc:IsA("Humanoid") and desc.Name ~= "Humanoid" then
            -- Suspicious humanoid that's not standard
            return true
        end
    end
    return false
end

local function hasSuspiciousScripts(model)
    if not model then return false end
    for _, desc in ipairs(model:GetDescendants()) do
        if desc:IsA("Script") or desc:IsA("LocalScript") then
            local scriptName = desc.Name:lower()
            if scriptName:find("attack") or scriptName:find("chase") or 
               scriptName:find("mimic") or scriptName:find("ai") or
               scriptName:find("behavior") or scriptName:find("hunt") then
                return true
            end
        end
    end
    return false
end

local function isLikelyMimic(part)
    if not part or not part.Position then return false end
    
    -- Method 0: Check if blacklisted from failed pickup attempts
    if blacklistedItems[part] then
        local blacklistData = blacklistedItems[part]
        if tick() - blacklistData.time < BLACKLIST_DURATION then
            return true -- Still blacklisted
        else
            blacklistedItems[part] = nil -- Blacklist expired
        end
    end
    
    -- Method 1: Check for monsters nearby (increased range)
    if hasMonsterNearby(part.Position, 12) then return true end
    
    -- Method 2: Check parent chain for mimic indicators
    if checkParentChainForMimic(part) then return true end
    
    -- Method 3: Find the root model and check it
    local model = part:FindFirstAncestorOfClass("Model")
    if model then
        -- Check model name
        if checkNameForMimic(model.Name) then return true end
        -- Check model attributes
        if checkAttributesForMimic(model) then return true end
        -- Check for animation controllers (mimics often have these)
        if hasAnimationController(model) then return true end
        -- Check for suspicious scripts
        if hasSuspiciousScripts(model) then return true end
        -- Check if model has a Humanoid with health (items shouldn't)
        local humanoid = model:FindFirstChildOfClass("Humanoid")
        if humanoid and humanoid.Health > 0 and humanoid.MaxHealth > 0 then
            return true
        end
    end
    
    -- Method 4: Check if the item itself has suspicious properties
    if checkAttributesForMimic(part) then return true end
    
    -- Method 5: Check siblings for monster-like parts
    if part.Parent then
        for _, sibling in ipairs(part.Parent:GetChildren()) do
            if sibling:IsA("BasePart") then
                local sibName = sibling.Name:lower()
                if sibName:find("teeth") or sibName:find("jaw") or 
                   sibName:find("tongue") or sibName:find("eye") then
                    return true
                end
            end
        end
    end
    
    return false
end

-- Track pickup attempts and blacklist items that fail too many times
local function trackPickupAttempt(part, distance)
    if not part then return end
    
    -- Only track when close enough to interact
    if distance > 6 then
        -- Reset timer if we moved away
        if failedPickupAttempts[part] then
            failedPickupAttempts[part].nearTime = 0
        end
        return
    end
    
    -- Initialize tracking for this part
    if not failedPickupAttempts[part] then
        failedPickupAttempts[part] = {
            attempts = 0,
            nearTime = 0,
            lastCheck = tick()
        }
    end
    
    local data = failedPickupAttempts[part]
    local now = tick()
    local deltaTime = now - data.lastCheck
    data.lastCheck = now
    
    -- Accumulate time spent near this item
    data.nearTime = data.nearTime + deltaTime
    
    -- If we've been near this item for too long, count as failed attempt
    if data.nearTime >= ATTEMPT_TIMEOUT then
        data.attempts = data.attempts + 1
        data.nearTime = 0 -- Reset timer for next attempt
        
        -- Check if we should blacklist
        if data.attempts >= MAX_PICKUP_ATTEMPTS then
            blacklistedItems[part] = {time = tick()}
            failedPickupAttempts[part] = nil
            
            -- Notify user
            pcall(function()
                Window:Notify({
                    Title = "Mimic Detected",
                    Desc = "Item blacklisted after " .. MAX_PICKUP_ATTEMPTS .. " failed attempts",
                    Time = 3
                })
            end)
            
            return true -- Item was blacklisted
        end
    end
    
    return false
end

-- Clear tracking when item is successfully picked up or destroyed
local function clearPickupTracking(part)
    if part then
        failedPickupAttempts[part] = nil
    end
end

-- Clean up old tracking data periodically
local function cleanupTrackingData()
    local now = tick()
    
    -- Clean up failed attempts for parts that no longer exist
    for part, _ in pairs(failedPickupAttempts) do
        if not part or not part.Parent then
            failedPickupAttempts[part] = nil
        end
    end
    
    -- Clean up expired blacklist entries
    for part, data in pairs(blacklistedItems) do
        if not part or not part.Parent or (now - data.time >= BLACKLIST_DURATION) then
            blacklistedItems[part] = nil
        end
    end
end

-- ============ MONSTER DETECTION ============
local function getAllMonsters()
    local monsterList = {}
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return monsterList end
    local monsters = gameSystem:FindFirstChild("Monsters")
    if not monsters then return monsterList end
    
    for _, monster in ipairs(monsters:GetChildren()) do
        local monsterData = {
            model = monster,
            name = monster.Name,
            position = nil,
            humanoid = nil,
            health = 0,
            maxHealth = 0,
            isAlive = true,
            monsterType = "monster"  -- Everything in Monsters folder is a real monster
        }
        
        local humanoid = monster:FindFirstChildOfClass("Humanoid")
        if humanoid then
            monsterData.humanoid = humanoid
            monsterData.health = humanoid.Health
            monsterData.maxHealth = humanoid.MaxHealth
            monsterData.isAlive = humanoid.Health > 0
        end
        
        -- Get position
        local hrp = monster:FindFirstChild("HumanoidRootPart")
        if hrp then
            monsterData.position = hrp.Position
        else
            local checker = monster:FindFirstChild("Checker")
            if checker then
                monsterData.position = checker.Position
            end
        end
        
        if monsterData.position then
            table.insert(monsterList, monsterData)
        end
    end
    
    return monsterList
end

local function getNearestMonster()
    local monsters = getAllMonsters()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest, nearestDist = nil, math.huge
    for _, monster in ipairs(monsters) do
        if monster.isAlive and monster.position then
            local dist = (monster.position - hrp.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = monster
            end
        end
    end
    return nearest, nearestDist
end

-- ============ ELEVATOR ============
local function findElevator()
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return nil end
    local elevatorCenter = gameSystem:FindFirstChild("ElevatorCenter", true)
    if elevatorCenter and elevatorCenter:IsA("BasePart") then
        return elevatorCenter.Position
    end
    for _, child in ipairs(gameSystem:GetDescendants()) do
        if child.Name == "ElevatorCenter" and child:IsA("BasePart") then
            return child.Position
        end
        if child.Name == "RetreatPart" and child:IsA("BasePart") then
            return child.Position + Vector3.new(0, 2, 5)
        end
    end
    return Vector3.new(-310.69, 325.62, 410.03)
end

-- ============ ITEMS ============
local function getScatteredItems()
    local itemsList = {}
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return itemsList end
    local loots = gameSystem:FindFirstChild("Loots")
    if not loots then return itemsList end
    local world = loots:FindFirstChild("World")
    if not world then return itemsList end
    
    for _, child in ipairs(world:GetChildren()) do
        local interactable = child:FindFirstChild("Interactable", true)
        if interactable and interactable:IsA("BasePart") then
            local lootUI = interactable:FindFirstChild("LootUI")
            if lootUI then
                local frame = lootUI:FindFirstChild("Frame")
                if frame then
                    local itemNameLabel = frame:FindFirstChild("ItemName")
                    if itemNameLabel and itemNameLabel:IsA("TextLabel") then
                        local text = itemNameLabel.Text or ""
                        local name = text:match("^(.-)%(") or text
                        name = name:gsub("%s+$", "")
                        if name ~= "" and name ~= "Cash" and ValidItemsSet[name] and not isLikelyMimic(interactable) then
                            table.insert(itemsList, {name = name, part = interactable, position = interactable.Position})
                        end
                    end
                end
            end
        end
    end
    return itemsList
end

local function getNearestItem()
    local itemsList = getScatteredItems()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest, nearestDist = nil, math.huge
    for _, item in ipairs(itemsList) do
        if item.part and item.part.Parent then
            local dist = (item.part.Position - hrp.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = item
                nearest.position = item.part.Position
            end
        end
    end
    return nearest, nearestDist
end

-- ============ CONTAINERS ============
local function getContainers()
    local containers = {total = 0, unopened = 0, list = {}}
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return containers end
    local interactiveItem = gameSystem:FindFirstChild("InteractiveItem")
    if not interactiveItem then return containers end
    
    for _, child in ipairs(interactiveItem:GetChildren()) do
        if child:IsA("Model") then
            for _, cType in ipairs(ContainerTypes) do
                if child.Name:find(cType) then
                    containers.total = containers.total + 1
                    local isOpen, isEnabled = false, true
                    pcall(function() isOpen = child:GetAttribute("Open") == true end)
                    pcall(function() isEnabled = child:GetAttribute("en") ~= false end)
                    if not isOpen and isEnabled then
                        containers.unopened = containers.unopened + 1
                        local interactable = child:FindFirstChild("Interactable")
                        if interactable and interactable:IsA("BasePart") then
                            table.insert(containers.list, {model = child, part = interactable, position = interactable.Position})
                        end
                    end
                    break
                end
            end
        end
    end
    return containers
end

local function getNearestContainer()
    local data = getContainers()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    local nearest, nearestDist = nil, math.huge
    for _, container in ipairs(data.list) do
        local dist = (container.position - hrp.Position).Magnitude
        if dist < nearestDist then
            nearestDist = dist
            nearest = container
        end
    end
    return nearest, nearestDist
end

-- ============ NPC FUNCTIONS ============
local function getNPCs()
    local npcList = {}
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return npcList end
    local npcModels = gameSystem:FindFirstChild("NPCModels")
    if not npcModels then return npcList end
    
    for _, npc in ipairs(npcModels:GetChildren()) do
        if npc:IsA("Model") then
            local interactable = npc:FindFirstChild("Interactable") or npc:FindFirstChild("HumanoidRootPart")
            if interactable and interactable:IsA("BasePart") then
                table.insert(npcList, {
                    model = npc,
                    name = npc.Name,
                    part = interactable,
                    position = interactable.Position
                })
            end
        end
    end
    return npcList
end

local function getNearestNPC()
    local npcs = getNPCs()
    local char = player.Character
    if not char then return nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return nil end
    
    local nearest, nearestDist = nil, math.huge
    for _, npc in ipairs(npcs) do
        if npc.part and npc.part.Parent then
            local dist = (npc.part.Position - hrp.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearest = npc
            end
        end
    end
    return nearest, nearestDist
end

-- ============ FLY SYSTEM ============
local noclipConn = nil

local function stopFly()
    flyEnabled = false
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local bv = hrp:FindFirstChild("BodyVelocity")
            local bg = hrp:FindFirstChild("BodyGyro")
            if bv then bv:Destroy() end
            if bg then bg:Destroy() end
        end
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                part.CanCollide = true
            end
        end
    end
end

local function startFly()
    -- Clean up any existing fly state first
    if flyConnection then
        flyConnection:Disconnect()
        flyConnection = nil
    end
    if noclipConn then
        noclipConn:Disconnect()
        noclipConn = nil
    end
    
    -- Clean up old body movers from any character
    local char = player.Character
    if char then
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then
            local oldBv = hrp:FindFirstChild("BodyVelocity")
            local oldBg = hrp:FindFirstChild("BodyGyro")
            if oldBv then oldBv:Destroy() end
            if oldBg then oldBg:Destroy() end
        end
    end
    
    noclipConn = RunService.Stepped:Connect(function()
        pcall(function()
            if not flyEnabled then
                if noclipConn then noclipConn:Disconnect() noclipConn = nil end
                return
            end
            if isWaitingAtElevator or isDroppingItems then return end
            local c = player.Character
            if not c then return end
            for _, part in ipairs(c:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = false end
            end
        end)
    end)
    
    flyConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            -- Get fresh references every frame
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            -- Ensure body movers exist
            local bv = hrp:FindFirstChild("BodyVelocity")
            local bg = hrp:FindFirstChild("BodyGyro")
            
            if not bv then
                bv = Instance.new("BodyVelocity")
                bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                bv.Velocity = Vector3.new(0, 0, 0)
                bv.Parent = hrp
            end
            
            if not bg then
                bg = Instance.new("BodyGyro")
                bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
                bg.P = 10000
                bg.Parent = hrp
            end
            
            if not flyEnabled then
                if bv then bv:Destroy() end
                if bg then bg:Destroy() end
                if flyConnection then
                    flyConnection:Disconnect()
                    flyConnection = nil
                end
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                        part.CanCollide = true
                    end
                end
                return
            end
            
            if isDroppingItems or isWaitingAtElevator then
                bv.Velocity = Vector3.new(0, 0, 0)
                return
            end
            
            if (isHotbarFull() or hasBigItem()) and not isDroppingItems then
                goingToElevator = true
                local elevatorPos = findElevator()
                if elevatorPos then
                    local elevDist = (hrp.Position - elevatorPos).Magnitude
                    if elevDist > 10 then
                        local direction = (elevatorPos + Vector3.new(0, 3, 0) - hrp.Position).Unit
                        bv.Velocity = direction * flySpeed
                        bg.CFrame = CFrame.lookAt(hrp.Position, elevatorPos)
                    else
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                return
            end
            
            goingToElevator = false
            
            local target, dist = getNearestContainer()
            if not target then
                target, dist = getNearestItem()
            end
            
            if not target or not target.part or not target.part.Parent then
                -- No targets left, go to elevator and wait
                local elevatorPos = findElevator()
                if elevatorPos then
                    local elevDist = (hrp.Position - elevatorPos).Magnitude
                    if elevDist > 10 then
                        local direction = (elevatorPos + Vector3.new(0, 3, 0) - hrp.Position).Unit
                        bv.Velocity = direction * flySpeed
                        bg.CFrame = CFrame.lookAt(hrp.Position, elevatorPos)
                    else
                        -- At elevator, just stop moving (don't anchor here, let status loop handle go deep)
                        bv.Velocity = Vector3.new(0, 0, 0)
                    end
                end
                return
            end
            
            local targetPos = target.position + Vector3.new(0, 3, 0)
            local direction = (targetPos - hrp.Position).Unit
            
            if lastPosition then
                local moved = (hrp.Position - lastPosition).Magnitude
                if moved < 0.5 and dist > 3 then
                    stuckTime = stuckTime + 1
                    if stuckTime > 60 then
                        if target.part and currentTargetPart == target.part then
                            -- Blacklist this item as we're stuck on it
                            blacklistedItems[target.part] = {time = tick()}
                            stuckTime = 0
                            currentTargetPart = nil
                            return
                        end
                    end
                else
                    stuckTime = 0
                end
            end
            lastPosition = hrp.Position
            currentTargetPart = target.part
            
            if dist > 4 then
                bv.Velocity = direction * flySpeed
                bg.CFrame = CFrame.lookAt(hrp.Position, targetPos)
            else
                -- Track pickup attempts when close to target
                if target.part then
                    local wasBlacklisted = trackPickupAttempt(target.part, dist)
                    if wasBlacklisted then
                        -- Item was just blacklisted, skip it
                        bv.Velocity = Vector3.new(0, 0, 0)
                        return
                    end
                end
                
                bobPhase = bobPhase + 0.05
                local bobSpeed = math.sin(bobPhase) * 8
                local toTarget = (target.position - hrp.Position).Unit
                bv.Velocity = toTarget * bobSpeed
                hrp.CFrame = CFrame.lookAt(hrp.Position, target.position)
            end
        end)
    end)
end

-- ============ AUTO INTERACT ============
local function setupAutoInteract()
    local pg = player:FindFirstChild("PlayerGui")
    if not pg then return end
    local main = pg:FindFirstChild("Main")
    if not main then return end
    local homePage = main:FindFirstChild("HomePage")
    if not homePage then return end
    local keyPrompt = homePage:FindFirstChild("KeyPrompt")
    if not keyPrompt then return end
    local interact = keyPrompt:FindFirstChild("Interact")
    if not interact then return end
    
    interact:GetPropertyChangedSignal("Visible"):Connect(function()
        if goingToElevator or isDroppingItems or isWaitingAtElevator then return end
        if autoInteract and interact.Visible and not hasBigItem() and not isHotbarFull() then
            task.spawn(function()
                task.wait(0.05)
                if not interact.Visible or not autoInteract or hasBigItem() or isHotbarFull() or goingToElevator or isDroppingItems or isWaitingAtElevator then return end
                VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.05)
                VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            end)
        end
    end)
end

task.spawn(function()
    task.wait(1)
    setupAutoInteract()
end)

-- ============ AUTO GIFT BOX ============
local function findGiftBoxSlot()
    local hotbar = findHotbar()
    if not hotbar then return nil end
    
    for i = 1, 4 do
        local slot = hotbar:FindFirstChild(tostring(i))
        if slot then
            local itemDetails = slot:FindFirstChild("ItemDetails")
            if itemDetails then
                local itemName = itemDetails:FindFirstChild("ItemName")
                if itemName and itemName.Text then
                    local name = itemName.Text:lower()
                    if name:find("gift") or name:find("box") then
                        return i
                    end
                end
            end
        end
    end
    return nil
end

local isOpeningGiftBox = false
local function openGiftBox()
    if isOpeningGiftBox then return end
    
    local slot = findGiftBoxSlot()
    if not slot then return end
    
    isOpeningGiftBox = true
    
    -- Select the slot
    local slotKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
    VIM:SendKeyEvent(true, slotKeys[slot], false, game)
    task.wait(0.05)
    VIM:SendKeyEvent(false, slotKeys[slot], false, game)
    task.wait(0.2)
    
    -- Click to open (left mouse button)
    local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    VIM:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, true, game, 1)
    task.wait(0.1)
    VIM:SendMouseButtonEvent(screenCenter.X, screenCenter.Y, 0, false, game, 1)
    
    task.wait(0.5)
    isOpeningGiftBox = false
end

-- Gift box check loop
task.spawn(function()
    while true do
        pcall(function()
            if autoGiftBoxEnabled and not isDroppingItems and not isWaitingAtElevator then
                local slot = findGiftBoxSlot()
                if slot then
                    openGiftBox()
                end
            end
        end)
        task.wait(1)
    end
end)

-- ============ AUTO ELEVATOR ============
local elevatorCheckConnection = nil
local function startAutoElevator()
    if elevatorCheckConnection then return end
    
    elevatorCheckConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if not autoElevatorEnabled then
                elevatorCheckConnection:Disconnect()
                elevatorCheckConnection = nil
                return
            end
            if isDroppingItems then return end
            
            if isHotbarFull() or hasBigItem() then
                local elevatorPos = findElevator()
                if elevatorPos then
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        local elevDist = (hrp.Position - elevatorPos).Magnitude
                        
                        if elevDist <= 15 then
                            isDroppingItems = true
                            goingToElevator = false
                            hrp.CFrame = CFrame.new(elevatorPos + Vector3.new(0, 3, 0))
                            hrp.Anchored = true
                            
                            task.spawn(function()
                                local slotKeys = {Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three, Enum.KeyCode.Four}
                                while not isHotbarEmpty() do
                                    if hrp and hrp.Parent then
                                        hrp.CFrame = CFrame.new(elevatorPos + Vector3.new(0, 3, 0))
                                        hrp.Anchored = true
                                    end
                                    for slot = 1, 4 do
                                        VIM:SendKeyEvent(true, slotKeys[slot], false, game)
                                        task.wait(0.05)
                                        VIM:SendKeyEvent(false, slotKeys[slot], false, game)
                                        task.wait(0.1)
                                        VIM:SendKeyEvent(true, Enum.KeyCode.G, false, game)
                                        task.wait(0.05)
                                        VIM:SendKeyEvent(false, Enum.KeyCode.G, false, game)
                                        task.wait(0.1)
                                    end
                                    task.wait(0.3)
                                end
                                if hrp and hrp.Parent then hrp.Anchored = false end
                                isDroppingItems = false
                            end)
                        end
                    end
                end
            end
        end)
    end)
end

-- ============ AUTO GO DEEP ============
local function findGoDeepButton()
    local elevator = workspace:FindFirstChild("电梯")
    if not elevator then return nil end
    local left4 = elevator:FindFirstChild("Left4")
    if not left4 then return nil end
    local console = left4:FindFirstChild("控制台")
    if not console then return nil end
    return console:FindFirstChild("Part7")
end

local function voteGoDeep()
    local goDeep = findGoDeepButton()
    if not goDeep then return false end
    
    local char = player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return false end
    local hrp = char.HumanoidRootPart
    
    -- Only set shouldRestartFly on first call (when fly is still on)
    if flyEnabled then
        shouldRestartFly = true
        stopFly()
        flyEnabled = false
    end
    
    local buttonPos = goDeep.Position
    
    -- Go to button and interact
    hrp.CFrame = CFrame.lookAt(buttonPos + Vector3.new(0, 0, 3), buttonPos)
    task.wait(0.2)
    
    for i = 1, 3 do
        VIM:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.05)
        VIM:SendKeyEvent(false, Enum.KeyCode.E, false, game)
        task.wait(0.1)
    end
    
    -- Go back to elevator and anchor there
    local elevatorPos = findElevator()
    if elevatorPos then
        hrp.CFrame = CFrame.new(elevatorPos + Vector3.new(0, 3, 0))
        hrp.Anchored = true
    end
    
    isWaitingAtElevator = true
    
    return true
end

-- ============ X-RAY ============
local function applyXray()
    local gameSystem = workspace:FindFirstChild("GameSystem")
    local loots = gameSystem and gameSystem:FindFirstChild("Loots")
    local interactiveItem = gameSystem and gameSystem:FindFirstChild("InteractiveItem")
    local monsters = gameSystem and gameSystem:FindFirstChild("Monsters")
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Parent then
            local isLoot = loots and obj:IsDescendantOf(loots)
            local isContainer = interactiveItem and obj:IsDescendantOf(interactiveItem)
            local isPlayer = player.Character and obj:IsDescendantOf(player.Character)
            local isMonster = monsters and obj:IsDescendantOf(monsters)
            if not isLoot and not isContainer and not isPlayer and not isMonster then
                if xrayOriginalTransparency[obj] == nil then
                    xrayOriginalTransparency[obj] = obj.Transparency
                end
                obj.Transparency = 1
            end
        end
    end
end

local function removeXray()
    for obj, originalTransparency in pairs(xrayOriginalTransparency) do
        if obj and obj.Parent then obj.Transparency = originalTransparency end
    end
    xrayOriginalTransparency = {}
end

-- ============ CAMERA LOCK ============
local function getCurrentTarget()
    -- Priority: container > item
    local container, containerDist = getNearestContainer()
    local item, itemDist = getNearestItem()
    
    if container and container.part and container.part.Parent then
        return container.part.Position
    elseif item and item.part and item.part.Parent then
        return item.part.Position
    end
    return nil
end

local function startCameraLock()
    if cameraLockConnection then return end
    
    cameraLockConnection = RunService.RenderStepped:Connect(function()
        pcall(function()
            if not cameraLockEnabled then
                cameraLockConnection:Disconnect()
                cameraLockConnection = nil
                return
            end
            
            if isDroppingItems or isWaitingAtElevator or goingToElevator then return end
            if isHotbarFull() or hasBigItem() then return end
            
            local char = player.Character
            if not char then return end
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if not hrp then return end
            
            local targetPos = getCurrentTarget()
            if not targetPos then return end
            
            local distance = (targetPos - hrp.Position).Magnitude
            -- Only lock camera when close enough to interact
            if distance < 15 then
                local camPos = camera.CFrame.Position
                local lookAt = CFrame.lookAt(camPos, targetPos)
                camera.CFrame = camera.CFrame:Lerp(lookAt, 0.3)
            end
        end)
    end)
end

local function stopCameraLock()
    cameraLockEnabled = false
    if cameraLockConnection then
        cameraLockConnection:Disconnect()
        cameraLockConnection = nil
    end
end

-- ============ ESP SYSTEM ============
local function getESPFolder()
    if espFolder and espFolder.Parent then return espFolder end
    espFolder = Instance.new("Folder")
    espFolder.Name = "ESPFolder"
    espFolder.Parent = game:GetService("CoreGui")
    return espFolder
end

local function createESPBillboard(part, text, color)
    if not part or not part.Parent then return nil end
    
    local existing = part:FindFirstChild("ESPBillboard")
    if existing then existing:Destroy() end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESPBillboard"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 100, 0, 40)
    billboard.StudsOffset = Vector3.new(0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundColor3 = Color3.new(0, 0, 0)
    frame.BackgroundTransparency = 0.5
    frame.BorderSizePixel = 0
    frame.Parent = billboard
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = frame
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color
    label.TextScaled = true
    label.Font = Enum.Font.GothamBold
    label.Parent = frame
    
    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistLabel"
    distLabel.Size = UDim2.new(1, 0, 0.4, 0)
    distLabel.Position = UDim2.new(0, 0, 1, 2)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "0m"
    distLabel.TextColor3 = Color3.new(1, 1, 1)
    distLabel.TextScaled = true
    distLabel.Font = Enum.Font.Gotham
    distLabel.Parent = frame
    
    return billboard
end

local function updateItemESP()
    if not itemESPEnabled then return end
    
    local items = getScatteredItems()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    for _, item in ipairs(items) do
        if item.part and item.part.Parent then
            local existing = item.part:FindFirstChild("ESPBillboard")
            if not existing then
                createESPBillboard(item.part, item.name, Color3.fromRGB(0, 255, 100))
            end
            
            if hrp and existing then
                local dist = math.floor((item.part.Position - hrp.Position).Magnitude)
                local distLabel = existing:FindFirstChild("Frame") and existing.Frame:FindFirstChild("DistLabel")
                if distLabel then
                    distLabel.Text = dist .. "m"
                end
            end
        end
    end
end

local function updateContainerESP()
    if not containerESPEnabled then return end
    
    local containers = getContainers()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    for _, container in ipairs(containers.list) do
        if container.part and container.part.Parent then
            local containerName = container.model and container.model.Name or "Container"
            local existing = container.part:FindFirstChild("ESPBillboard")
            if not existing then
                createESPBillboard(container.part, containerName, Color3.fromRGB(255, 200, 0))
            end
            
            if hrp and existing then
                local dist = math.floor((container.part.Position - hrp.Position).Magnitude)
                local distLabel = existing:FindFirstChild("Frame") and existing.Frame:FindFirstChild("DistLabel")
                if distLabel then
                    distLabel.Text = dist .. "m"
                end
            end
        end
    end
end

local function clearItemESP()
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return end
    local loots = gameSystem:FindFirstChild("Loots")
    if not loots then return end
    
    for _, desc in ipairs(loots:GetDescendants()) do
        if desc.Name == "ESPBillboard" then
            desc:Destroy()
        end
    end
end

local function clearContainerESP()
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return end
    local interactiveItem = gameSystem:FindFirstChild("InteractiveItem")
    if not interactiveItem then return end
    
    for _, desc in ipairs(interactiveItem:GetDescendants()) do
        if desc.Name == "ESPBillboard" then
            desc:Destroy()
        end
    end
end

local function updateNPCESP()
    if not npcESPEnabled then return end
    
    local npcs = getNPCs()
    local char = player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    for _, npc in ipairs(npcs) do
        if npc.part and npc.part.Parent then
            local existing = npc.part:FindFirstChild("ESPBillboard")
            if not existing then
                createESPBillboard(npc.part, npc.name, Color3.fromRGB(0, 200, 255))
            end
            
            if hrp and existing then
                local dist = math.floor((npc.part.Position - hrp.Position).Magnitude)
                local distLabel = existing:FindFirstChild("Frame") and existing.Frame:FindFirstChild("DistLabel")
                if distLabel then
                    distLabel.Text = dist .. "m"
                end
            end
        end
    end
end

local function clearNPCESP()
    local gameSystem = workspace:FindFirstChild("GameSystem")
    if not gameSystem then return end
    local npcModels = gameSystem:FindFirstChild("NPCModels")
    if not npcModels then return end
    
    for _, desc in ipairs(npcModels:GetDescendants()) do
        if desc.Name == "ESPBillboard" then
            desc:Destroy()
        end
    end
end

-- ESP Update Loop
task.spawn(function()
    while true do
        pcall(function()
            if itemESPEnabled then updateItemESP() end
            if containerESPEnabled then updateContainerESP() end
            if npcESPEnabled then updateNPCESP() end
        end)
        task.wait(0.5)
    end
end)

-- Cleanup tracking data periodically
task.spawn(function()
    while true do
        pcall(function()
            cleanupTrackingData()
        end)
        task.wait(5)
    end
end)

-- ============ UI (DUMMY UI LIBRARY) ============
local Window = Library:Window({
    Title = "Deadly Delivery",
    Desc = "Snoe Project",
    Icon = "snowflake",
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

-- Farm Tab
local StatusLabel
local FarmTab = Window:Tab({Title = "Farm", Icon = "zap"}) do
    FarmTab:Section({Title = "Status"})
    
    StatusLabel = FarmTab:Label({
        Title = "Status",
        Desc = "Level: Unknown | Items: 0 | Containers: 0/0"
    })
    
    FarmTab:Section({Title = "Auto Farm"})
    
    FarmTab:Toggle({
        Title = "Auto Farm",
        Desc = "Fly to items and containers automatically",
        Value = false,
        Callback = function(v)
            flyEnabled = v
            if v then startFly() end
        end
    })
    
    FarmTab:Toggle({
        Title = "Auto Interact",
        Desc = "Auto press E when near interactable",
        Value = false,
        Callback = function(v)
            autoInteract = v
        end
    })
    
    FarmTab:Toggle({
        Title = "Auto Elevator",
        Desc = "Auto drop items at elevator when full",
        Value = false,
        Callback = function(v)
            autoElevatorEnabled = v
            if v then startAutoElevator() end
        end
    })
    
    FarmTab:Toggle({
        Title = "Auto Go Deep",
        Desc = "Vote Go Deep when floor is empty",
        Value = false,
        Callback = function(v)
            autoGoDeepEnabled = v
        end
    })
    
    FarmTab:Toggle({
        Title = "Auto Gift Box",
        Desc = "Auto open gift boxes in hotbar",
        Value = false,
        Callback = function(v)
            autoGiftBoxEnabled = v
        end
    })
    
    FarmTab:Toggle({
        Title = "Camera Lock",
        Desc = "Lock camera to nearest target for better interact detection",
        Value = false,
        Callback = function(v)
            cameraLockEnabled = v
            if v then startCameraLock() end
        end
    })
    
    FarmTab:Slider({
        Title = "Fly Speed",
        Min = 10,
        Max = 150,
        Value = 50,
        Rounding = 0,
        Callback = function(v)
            flySpeed = v
        end
    })
end

Window:Line()

-- Visuals Tab
local VisualsTab = Window:Tab({Title = "Visuals", Icon = "eye"}) do
    VisualsTab:Section({Title = "ESP"})
    
    VisualsTab:Toggle({
        Title = "Item ESP",
        Desc = "Show items through walls (green)",
        Value = false,
        Callback = function(v)
            itemESPEnabled = v
            if not v then clearItemESP() end
        end
    })
    
    VisualsTab:Toggle({
        Title = "Container ESP",
        Desc = "Show containers through walls (yellow)",
        Value = false,
        Callback = function(v)
            containerESPEnabled = v
            if not v then clearContainerESP() end
        end
    })
    
    VisualsTab:Toggle({
        Title = "NPC ESP",
        Desc = "Show NPCs through walls (cyan)",
        Value = false,
        Callback = function(v)
            npcESPEnabled = v
            if not v then clearNPCESP() end
        end
    })
    
    VisualsTab:Section({Title = "X-Ray"})
    
    VisualsTab:Toggle({
        Title = "X-Ray",
        Desc = "See through walls",
        Value = false,
        Callback = function(v)
            xrayEnabled = v
            if v then applyXray() else removeXray() end
        end
    })
end

Window:Line()

-- Teleport Tab
local TeleportTab = Window:Tab({Title = "Teleport", Icon = "map-pin"}) do
    TeleportTab:Section({Title = "Quick Teleport"})
    
    TeleportTab:Button({
        Title = "TP to Elevator",
        Desc = "Teleport to the elevator",
        Callback = function()
            local elevatorPos = findElevator()
            if elevatorPos then
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.CFrame = CFrame.new(elevatorPos + Vector3.new(0, 3, 0))
                    Window:Notify({
                        Title = "Teleport",
                        Desc = "Teleported to elevator!",
                        Time = 3
                    })
                end
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "Could not find elevator!",
                    Time = 3
                })
            end
        end
    })
end

Window:Line()

-- Settings Tab
local SettingsTab = Window:Tab({Title = "Settings", Icon = "wrench"}) do
    SettingsTab:Section({Title = "Info"})
    
    SettingsTab:Button({
        Title = "Show Credits",
        Desc = "Display script info",
        Callback = function()
            Window:Notify({
                Title = "Underground Auto Farm",
                Desc = "Made for Deadly Delivery\nUsing Dummy UI Library",
                Time = 5
            })
        end
    })
end

-- ============ AUTO REFRESH STATUS ============
local wasEmpty = false

task.spawn(function()
    while true do
        pcall(function()
            local items = getScatteredItems()
            local containers = getContainers()
            local sublevel = getSublevel()
            
            local isEmpty = #items == 0 and containers.unopened == 0
            local hasTargets = #items > 0 or containers.unopened > 0
            
            -- Detect new floor by sublevel change OR items appearing after empty
            local newFloorDetected = false
            if sublevel ~= "" and currentSublevel ~= "" and sublevel ~= currentSublevel then
                newFloorDetected = true
            end
            if wasEmpty and hasTargets and shouldRestartFly then
                newFloorDetected = true
            end
            -- Also detect if we're waiting and items appear
            if isWaitingAtElevator and hasTargets then
                newFloorDetected = true
            end
            
            if newFloorDetected then
                -- New floor detected
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    char.HumanoidRootPart.Anchored = false
                end
                
                -- Clear tracking data for new floor
                failedPickupAttempts = {}
                blacklistedItems = {}
                isWaitingAtElevator = false
                floorStartTime = tick()
                hasVotedGoDeep = false
                goingToElevator = false
                
                -- Restart fly if it was on before going deep
                if shouldRestartFly then
                    shouldRestartFly = false
                    stopFly()
                    task.wait(0.3)
                    flyEnabled = true
                    startFly()
                end
            end
            
            if sublevel ~= "" then
                currentSublevel = sublevel
            end
            wasEmpty = isEmpty
            
            if autoGoDeepEnabled and isEmpty and isHotbarEmpty() and not hasVotedGoDeep then
                -- Only vote if been on floor for at least 15 seconds
                local timeOnFloor = tick() - floorStartTime
                if timeOnFloor >= 15 then
                    local success = voteGoDeep()
                    if success then
                        hasVotedGoDeep = true
                    end
                end
            end
            
            local sublevelText = sublevel ~= "" and sublevel or "Unknown"
            pcall(function()
                StatusLabel:SetDesc("Level: " .. sublevelText .. " | Items: " .. #items .. " | Containers: " .. containers.unopened .. "/" .. containers.total)
            end)
        end)
        task.wait(0.5)
    end
end)

-- Startup notification
Window:Notify({
    Title = "Underground Auto Farm",
    Desc = "Script loaded successfully!",
    Time = 4
})
