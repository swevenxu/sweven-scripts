local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- ==================== CENTRAL STATE MANAGER ====================
local ScriptState = {
    -- Flying state
    smoothFlyConnection = nil,
    flyModeConnection = nil,
    flyBodyVelocity = nil,
    flyBodyGyro = nil,
    
    -- Noclip state
    noclipEnabled = false,
    noclipConnection = nil,
    
    -- Loop control flags (for cleanup on re-execution)
    loopsRunning = true,
    
    -- Saved user settings (for restoration after Auto Stronghold)
    savedAutoKillSettings = nil,
}

-- ==================== TOOL MANAGEMENT MODULE ====================
-- Unified tool discovery, validation, and equipping for Auto Kill and Auto Cut Trees

-- Tool name patterns for detection
local TOOL_PATTERNS = {
    "Axe", "Sword", "Pickaxe", "Spear", "Hammer",
    "Mace", "Scythe", "Trident", "Chainsaw", "Katana", "Morningstar"
}

-- Axe-specific patterns for tree cutting priority
local AXE_PATTERNS = {"Axe", "Chainsaw"}

-- Tool Management Module
local ToolManager = {}

-- Validates a tool instance is usable
-- Returns: boolean
function ToolManager.isValidTool(tool)
    -- Check existence
    if not tool then return false end
    
    -- Check parent (tool must be somewhere valid)
    if not tool.Parent then return false end
    
    -- Check it's still a valid instance using pcall
    local success, _ = pcall(function()
        return tool.Name
    end)
    if not success then return false end
    
    return true
end

-- Discovers the best available tool from all containers
-- preferAxes: boolean - if true, prioritize axes/chainsaws for tree cutting
-- Returns: tool instance or nil, source container name
function ToolManager.discoverBestTool(preferAxes)
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    local allTools = {}
    
    -- Helper: Check if item is a valid tool candidate
    local function isToolCandidate(item)
        if not item then return false end
        
        -- Use pcall to safely check Name
        local hasName, itemName = pcall(function() return item.Name end)
        if not hasName or not itemName then return false end
        
        -- Check for damage attributes (highest priority)
        local hasGetAttr = pcall(function() return type(item.GetAttribute) == "function" end)
        if hasGetAttr and type(item.GetAttribute) == "function" then
            local ok1, weaponDmg = pcall(function() return item:GetAttribute("WeaponDamage") end)
            if ok1 and weaponDmg ~= nil then
                return true
            end
            local ok2, toolCd = pcall(function() return item:GetAttribute("ToolCooldown") end)
            if ok2 and toolCd ~= nil then
                return true
            end
        end
        
        -- Check name patterns
        local nameLower = itemName:lower()
        for _, pattern in ipairs(TOOL_PATTERNS) do
            if nameLower:find(pattern:lower()) then
                return true
            end
        end
        
        -- Check if it's a Tool instance
        local isToolOk, isTool = pcall(function() return item:IsA("Tool") end)
        if isToolOk and isTool then
            return true
        end
        
        return false
    end
    
    -- Helper: Get tool damage value for sorting
    local function getToolDamage(tool)
        local ok, dmg = pcall(function()
            if type(tool.GetAttribute) == "function" then
                return tool:GetAttribute("WeaponDamage")
            end
            return nil
        end)
        if ok and dmg then return tonumber(dmg) or 0 end
        return 0
    end
    
    -- Helper: Check if tool is an axe (for preferAxes mode)
    local function isAxe(tool)
        local ok, name = pcall(function() return tool.Name:lower() end)
        if not ok or not name then return false end
        for _, pattern in ipairs(AXE_PATTERNS) do
            if name:find(pattern:lower()) then
                return true
            end
        end
        return false
    end
    
    -- Scan container and collect tools
    local function scanContainer(container, sourceName)
        if not container then return end
        for _, item in pairs(container:GetChildren()) do
            -- For Character, be more lenient - accept any Tool instance
            local isCandidate = isToolCandidate(item)
            if not isCandidate and sourceName == "Character" then
                -- Fallback: check if it's a Tool class
                local ok, isTool = pcall(function() return item:IsA("Tool") end)
                if ok and isTool then
                    isCandidate = true
                end
            end
            
            if isCandidate then
                table.insert(allTools, {
                    tool = item,
                    source = sourceName,
                    damage = getToolDamage(item),
                    isAxe = isAxe(item),
                    inCharacter = sourceName == "Character"
                })
            end
        end
    end
    
    -- Scan all containers (Character first for priority)
    if character then
        scanContainer(character, "Character")
    end
    scanContainer(player:FindFirstChild("Inventory"), "Inventory")
    scanContainer(player:FindFirstChild("Backpack"), "Backpack")
    
    -- Sort tools by priority
    table.sort(allTools, function(a, b)
        -- If NOT preferAxes (combat mode), deprioritize axes even if equipped
        if not preferAxes then
            if a.isAxe ~= b.isAxe then
                return not a.isAxe -- non-axes first for combat
            end
        end
        
        -- Already equipped tools have priority (within same axe/non-axe category)
        if a.inCharacter ~= b.inCharacter then
            return a.inCharacter
        end
        -- If preferAxes (tree cutting), prioritize axes
        if preferAxes and a.isAxe ~= b.isAxe then
            return a.isAxe
        end
        -- Otherwise sort by damage
        return a.damage > b.damage
    end)
    
    -- Return best tool
    if #allTools > 0 then
        return allTools[1].tool, allTools[1].source
    end
    return nil, nil
end

-- Ensures tool is equipped in character
-- Returns: boolean success
function ToolManager.ensureEquipped(tool)
    if not ToolManager.isValidTool(tool) then return false end
    
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return false end
    
    local replicatedStorage = game:GetService("ReplicatedStorage")
    local alreadyEquipped = tool.Parent == character
    local success = alreadyEquipped -- If already equipped, consider it a success
    
    -- ALWAYS fire EquipItemHandle even if already equipped
    -- This tells the server we're actively using this tool
    pcall(function()
        local remote = replicatedStorage.RemoteEvents:FindFirstChild("EquipItemHandle")
        if remote then
            remote:FireServer("FireAllClients", tool)
            success = true
        end
    end)
    
    -- If not already equipped, try other methods
    if not alreadyEquipped and not success then
        -- Method 2: Humanoid:EquipTool
        pcall(function()
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid and tool:IsA("Tool") then
                humanoid:EquipTool(tool)
                success = true
            end
        end)
    end
    
    if not alreadyEquipped and not success then
        -- Method 3: RequestEquipItem remote
        pcall(function()
            local remote = replicatedStorage.RemoteEvents:FindFirstChild("RequestEquipItem")
            if remote then
                remote:FireServer(tool)
                success = true
            end
        end)
    end
    
    -- Wait briefly for equip to complete (only if we actually equipped)
    if success and not alreadyEquipped then
        task.wait(0.1)
    end
    
    return success
end

-- Central Noclip Manager
local function setNoclip(enabled)
    local player = game:GetService("Players").LocalPlayer
    
    if enabled and not ScriptState.noclipEnabled then
        ScriptState.noclipEnabled = true
        if ScriptState.noclipConnection then
            ScriptState.noclipConnection:Disconnect()
        end
        ScriptState.noclipConnection = game:GetService("RunService").Stepped:Connect(function()
            local character = player.Character
            if character then
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end
        end)
    elseif not enabled and ScriptState.noclipEnabled then
        ScriptState.noclipEnabled = false
        if ScriptState.noclipConnection then
            ScriptState.noclipConnection:Disconnect()
            ScriptState.noclipConnection = nil
        end
        -- Re-enable collision
        local character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end
end

-- Unified F Key Simulation
local function simulateFKeyPress()
    if keypress and keyrelease then
        keypress(0x46)
        task.wait(0.1)
        keyrelease(0x46)
    elseif Input and Input.KeyPress then
        Input.KeyPress(0x46)
        task.wait(0.1)
        Input.KeyRelease(0x46)
    else
        local VirtualInputManager = game:GetService("VirtualInputManager")
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.F, false, game)
        task.wait(0.1)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.F, false, game)
    end
end

-- Forward declaration for autoEatSavedPosition (defined later in Auto Eat section)
local autoEatSavedPosition = nil

-- Character death handler
local player = game:GetService("Players").LocalPlayer
local function setupDeathHandler()
    local function onCharacterAdded(character)
        local humanoid = character:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.Died:Connect(function()
                -- Reset saved positions on death
                autoEatSavedPosition = nil
                -- Disable noclip on death
                setNoclip(false)
            end)
        end
    end
    
    if player.Character then
        onCharacterAdded(player.Character)
    end
    player.CharacterAdded:Connect(onCharacterAdded)
end
setupDeathHandler()

-- Create Main Window
local Window = Library:Window({
    Title = "99 Nights in the Forest",
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

-- Get Fire Status (fuel remaining, target, level, progress)
local function getFireStatus()
    local mainFire = workspace:FindFirstChild("Map") 
        and workspace.Map:FindFirstChild("Campground") 
        and workspace.Map.Campground:FindFirstChild("MainFire")
    
    if not mainFire then
        return nil
    end
    
    local fuelRemaining = mainFire:GetAttribute("FuelRemaining") or 0
    local fuelTarget = mainFire:GetAttribute("FuelTarget") or 1
    
    -- Parse level and progress from the BillboardGui text
    local level, progress, maxProgress = 1, 0, 100
    local center = mainFire:FindFirstChild("Center")
    if center then
        local billboard = center:FindFirstChild("BillboardGui")
        if billboard then
            local textLabel = billboard:FindFirstChildWhichIsA("TextLabel", true)
            if textLabel then
                local text = textLabel.Text
                -- Parse "level X progress: Y/Z"
                local l, p, m = text:match("level (%d+) progress: <?[^>]*>?(%d+)/(%d+)")
                if l then level = tonumber(l) end
                if p then progress = tonumber(p) end
                if m then maxProgress = tonumber(m) end
            end
        end
    end
    
    -- Get timer if available
    local timer = "N/A"
    if center then
        local billboard = center:FindFirstChild("BillboardGui")
        if billboard then
            local timerLabel = billboard:FindFirstChild("RealTimer")
            if timerLabel and timerLabel:IsA("TextLabel") then
                timer = timerLabel.Text
            end
        end
    end
    
    return {
        fuelRemaining = fuelRemaining,
        fuelTarget = fuelTarget,
        level = level,
        progress = progress,
        maxProgress = maxProgress,
        timer = timer
    }
end

-- Teleport Function
local function teleportTo(cframe)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
    
    if humanoidRootPart then
        humanoidRootPart.CFrame = cframe + Vector3.new(0, 10, 0)
    end
end

-- Get campfire position (dynamically detects campfire location)
local function getCampfirePosition()
    local campground = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Campground")
    if campground then
        local mainFire = campground:FindFirstChild("MainFire")
        if mainFire then
            -- Primary: Look for the "Center" part (the actual fire)
            local center = mainFire:FindFirstChild("Center")
            if center and center:IsA("BasePart") then
                return center.Position + Vector3.new(0, 10, 0)
            end
            
            -- Fallback: use MainFire's pivot
            return mainFire:GetPivot().Position + Vector3.new(0, 10, 0)
        end
    end
    
    -- Last resort fallback
    return Vector3.new(0, 10, 0)
end

-- Smooth Flying Function (uses central state)
local function smoothFlyTo(targetCFrame, speed, cancelCheck)
    speed = speed or 300
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character
    if not character then return end
    
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    -- Disconnect old smooth fly connection
    if ScriptState.smoothFlyConnection then
        ScriptState.smoothFlyConnection:Disconnect()
        ScriptState.smoothFlyConnection = nil
    end
    
    -- Enable noclip using central manager
    setNoclip(true)
    
    -- Create flying physics
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.Parent = hrp
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    local targetPos = targetCFrame.Position
    
    -- Fly using velocity
    ScriptState.smoothFlyConnection = game:GetService("RunService").Heartbeat:Connect(function()
        -- Check cancel condition
        if cancelCheck and cancelCheck() then
            if ScriptState.smoothFlyConnection then 
                ScriptState.smoothFlyConnection:Disconnect() 
                ScriptState.smoothFlyConnection = nil 
            end
            setNoclip(false)
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            return
        end
        
        if not character or not hrp then
            if ScriptState.smoothFlyConnection then 
                ScriptState.smoothFlyConnection:Disconnect() 
                ScriptState.smoothFlyConnection = nil
            end
            setNoclip(false)
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            return
        end
        
        -- Calculate direction and distance
        local direction = (targetPos - hrp.Position)
        local distance = direction.Magnitude
        
        -- Calculate velocity
        local velocity = direction.Unit * math.min(speed, distance * 10)
        
        -- Apply velocity
        if bodyVelocity and bodyVelocity.Parent then
            bodyVelocity.Velocity = velocity
        end
        
        -- Keep upright
        if bodyGyro and bodyGyro.Parent then
            bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
        end
        
        -- Stop when close enough
        if distance < 3 then
            if ScriptState.smoothFlyConnection then
                ScriptState.smoothFlyConnection:Disconnect()
                ScriptState.smoothFlyConnection = nil
            end
            setNoclip(false)
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
        end
    end)
    
    -- Wait until arrived or cancelled
    repeat
        task.wait(0.1)
        if cancelCheck and cancelCheck() then
            stopFlying()
            break
        end
    until not ScriptState.smoothFlyConnection or (hrp.Position - targetPos).Magnitude < 3
end

local function stopFlying()
    if ScriptState.smoothFlyConnection then
        ScriptState.smoothFlyConnection:Disconnect()
        ScriptState.smoothFlyConnection = nil
    end
    setNoclip(false)
end

-- Forward declaration for autoStrongholdEnabled (defined later in Quest Tab)
local autoStrongholdEnabled = false

-- Wait for enemies to be cleared
local function waitForEnemiesCleared()
    Window:Notify({Title = "Auto Stronghold", Desc = "Waiting for enemies to be cleared...", Time = 2})
    task.wait(3) -- Initial wait for enemies to spawn
    
    -- Get stronghold position for radius check
    local stronghold = workspace.Map.Landmarks.Stronghold
    local strongholdPos = stronghold:GetPivot().Position
    local detectionRadius = 150 -- 150 studs radius around stronghold
    
    repeat
        task.wait(2)
        local enemyCount = 0
        local enemyNames = {}
        
        if workspace:FindFirstChild("Characters") then
            for _, entity in pairs(workspace.Characters:GetChildren()) do
                if entity:IsA("Model") and entity:FindFirstChild("HumanoidRootPart") then
                    local name = entity.Name
                    -- Check if it's a cultist enemy
                    if name == "Cultist" or name == "Crossbow Cultist" or name == "Juggernaut Cultist" then
                        -- Check if enemy is within radius of stronghold
                        local distance = (entity.HumanoidRootPart.Position - strongholdPos).Magnitude
                        if distance <= detectionRadius then
                            enemyCount = enemyCount + 1
                            table.insert(enemyNames, name)
                        end
                    end
                end
            end
        end
        
        if enemyCount > 0 then
            local nameList = table.concat(enemyNames, ", ")
            print("Enemies remaining:", enemyCount, "-", nameList)
            Window:Notify({Title = "Enemies", Desc = enemyCount .. " enemies left", Time = 1})
        end
    until enemyCount == 0 or not autoStrongholdEnabled
    
    Window:Notify({Title = "Auto Stronghold", Desc = "All enemies cleared!", Time = 2})
end

-- Helper function to find part by size
local function findPartBySize(parent, targetSize, tolerance)
    tolerance = tolerance or 0.1
    for _, obj in pairs(parent:GetDescendants()) do
        if obj:IsA("BasePart") then
            local size = obj.Size
            if math.abs(size.X - targetSize.X) < tolerance and
               math.abs(size.Y - targetSize.Y) < tolerance and
               math.abs(size.Z - targetSize.Z) < tolerance then
                return obj
            end
        end
    end
    return nil
end

-- Helper function to find safe zone platform (special case)
local function findSafeZonePlatform(stronghold)
    -- Look for the large concrete platform near the pillar
    for _, obj in pairs(stronghold.Building.Exterior:GetDescendants()) do
        if obj:IsA("BasePart") then
            local size = obj.Size
            if math.abs(size.X - 20) < 1 and
               math.abs(size.Y - 0.4) < 0.1 and
               math.abs(size.Z - 41.2) < 1 and
               obj.Material == Enum.Material.Concrete then
                return obj
            end
        end
    end
    return nil
end

-- Variables
local player = game:GetService("Players").LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local autoKillEnabled = false
local killRadius = 200
local radiusVisual = nil
local showRadius = false
local selectedEntities = {}
local showEntityESP = false
-- entityESPObjects declared below in ESP section

-- Get the correct remote
local toolDamageRemote = replicatedStorage.RemoteEvents:FindFirstChild("ToolDamageObject")

-- All available entities
local allEntities = {
    "Cultist", "Crossbow Cultist", "Juggernaut Cultist", "Cultist King",
    "Wolf", "Alpha Wolf", "Mossy Wolf", "Bear", "Polar Bear", "Aliens", "Arctic Fox",
    "Frogs", "Scorpion", "Hellephant", "Meteor Crab", "Shadow Cultist",
    "Brute Cultist", "Bunny", "Horse", "Kiwi", "Turkey"
}

-- Create Radius Visual
local function createRadiusVisual()
    if radiusVisual then
        radiusVisual:Destroy()
    end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    
    radiusVisual = Instance.new("Part")
    radiusVisual.Name = "RadiusVisual"
    radiusVisual.Shape = Enum.PartType.Ball
    radiusVisual.Material = Enum.Material.ForceField
    radiusVisual.Size = Vector3.new(killRadius * 2, killRadius * 2, killRadius * 2)
    radiusVisual.CanCollide = false
    radiusVisual.Anchored = true
    radiusVisual.Transparency = 0.7
    radiusVisual.Color = Color3.fromRGB(255, 0, 0)
    radiusVisual.Parent = workspace
    
    -- Update position loop
    task.spawn(function()
        while radiusVisual and showRadius do
            task.wait()
            if character and character:FindFirstChild("HumanoidRootPart") then
                radiusVisual.CFrame = character.HumanoidRootPart.CFrame
                radiusVisual.Size = Vector3.new(killRadius * 2, killRadius * 2, killRadius * 2)
            end
        end
    end)
end

-- Remove Radius Visual
local function removeRadiusVisual()
    if radiusVisual then
        radiusVisual:Destroy()
        radiusVisual = nil
    end
end

-- ==================== ENTITY ESP SYSTEM ====================
local entityESPFolder = Instance.new("Folder")
entityESPFolder.Name = "EntityESPSystem"
entityESPFolder.Parent = workspace

local entityESPObjects = {}

-- Create Entity ESP Billboard
local function createEntityESPBillboard(entity)
    if not entity or not entity.Parent then return nil end
    
    local root = entity:FindFirstChild("HumanoidRootPart") or entity.PrimaryPart or entity:FindFirstChildWhichIsA("BasePart")
    if not root then return nil end
    
    local gui = Instance.new("BillboardGui")
    gui.Name = "EntityESP_" .. entity.Name
    gui.Adornee = root
    gui.Size = UDim2.new(0, 150, 0, 40)
    gui.StudsOffset = Vector3.new(0, root.Size.Y / 2 + 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = killRadius + 50
    gui.Parent = entityESPFolder
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.fromScale(1, 0.5)
    nameLabel.Position = UDim2.fromScale(0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50) -- Red for entities
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = entity.Name
    nameLabel.Parent = gui
    
    -- HP label
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Name = "HPLabel"
    hpLabel.Size = UDim2.fromScale(1, 0.5)
    hpLabel.Position = UDim2.fromScale(0, 0.5)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextScaled = true
    hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    hpLabel.TextStrokeTransparency = 0
    hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hpLabel.Text = "HP: ?"
    hpLabel.Parent = gui
    
    return gui
end

-- Clear all Entity ESP
local function clearAllEntityESP()
    for entity, espGui in pairs(entityESPObjects) do
        if espGui and espGui.Parent then
            espGui:Destroy()
        end
    end
    entityESPObjects = {}
end

-- Update Entity ESP
local function updateEntityESP()
    if not showEntityESP then
        clearAllEntityESP()
        return
    end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    
    local entitiesInRange = {}
    
    -- Scan for entities
    if workspace:FindFirstChild("Characters") then
        for _, entity in pairs(workspace.Characters:GetChildren()) do
            if entity:IsA("Model") and entity:FindFirstChild("HumanoidRootPart") and entity ~= character then
                -- Check if entity is in selected list
                local isAllowed = false
                for _, allowedName in pairs(selectedEntities) do
                    if entity.Name == allowedName then
                        isAllowed = true
                        break
                    end
                end
                
                if isAllowed then
                    local entityHRP = entity.HumanoidRootPart
                    local distance = (hrp.Position - entityHRP.Position).Magnitude
                    if distance <= killRadius then
                        entitiesInRange[entity] = distance
                    end
                end
            end
        end
    end
    
    -- Remove ESP for entities no longer in range or destroyed
    for entity, espGui in pairs(entityESPObjects) do
        if not entity or not entity.Parent or not entitiesInRange[entity] then
            if espGui and espGui.Parent then
                espGui:Destroy()
            end
            entityESPObjects[entity] = nil
        end
    end
    
    -- Update or create ESP for entities in range
    for entity, distance in pairs(entitiesInRange) do
        local humanoid = entity:FindFirstChildOfClass("Humanoid")
        local currentHP = humanoid and math.floor(humanoid.Health) or 0
        local maxHP = humanoid and math.floor(humanoid.MaxHealth) or 0
        
        if not entityESPObjects[entity] then
            -- Create new ESP
            local esp = createEntityESPBillboard(entity)
            if esp then
                entityESPObjects[entity] = esp
            end
        end
        
        -- Update ESP text
        local esp = entityESPObjects[entity]
        if esp then
            local hpLabel = esp:FindFirstChild("HPLabel")
            local nameLabel = esp:FindFirstChild("NameLabel")
            
            if hpLabel then
                local hpPercent = maxHP > 0 and (currentHP / maxHP * 100) or 0
                
                hpLabel.Text = "HP: " .. currentHP .. "/" .. maxHP .. " (" .. math.floor(hpPercent) .. "%)"
                
                -- Color based on HP percentage
                if hpPercent > 60 then
                    hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
                elseif hpPercent > 30 then
                    hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
                else
                    hpLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
                end
            end
            
            if nameLabel then
                nameLabel.Text = entity.Name .. " [" .. math.floor(distance) .. "m]"
            end
        end
    end
end

-- Entity ESP Update Loop (fast updates)
task.spawn(function()
    while ScriptState.loopsRunning do
        task.wait(0.1)
        if showEntityESP then
            updateEntityESP()
        end
    end
end)

-- Equip Item Remote
local equipItemRemote = replicatedStorage.RemoteEvents:FindFirstChild("EquipItemHandle")

-- DEPRECATED: Old tool functions removed - now using ToolManager module
-- equipTool, isToolEquipped, and getPlayerTool have been replaced by:
-- - ToolManager.ensureEquipped(tool)
-- - ToolManager.isValidTool(tool)
-- - ToolManager.discoverBestTool(preferAxes)

-- Track last equipped tool to avoid spam
local lastEquippedTool = nil

-- Hit counter for entity kills (like tree system)
local entityHitCounter = 1

-- Attempt hit on entity (same approach as working tree system)
local function attemptEntityHit(remote, tool, entity)
    if not remote or not tool or not entity then return false end
    
    local entityHRP = entity:FindFirstChild("HumanoidRootPart")
    if not entityHRP then return false end
    
    -- Get damage values (same as tree system)
    local damageValues = {}
    if type(tool.GetAttribute) == "function" then
        local weaponDmg = tool:GetAttribute("WeaponDamage")
        if weaponDmg ~= nil then table.insert(damageValues, weaponDmg) end
    end
    if #damageValues == 0 then damageValues = {1} end
    
    -- Try different signatures (same as tree system)
    local signatures = {"tool_damage_numeric_cframe", "tool_damage_string_cframe", "tool_damage_count_cframe"}
    
    for _, sig in ipairs(signatures) do
        for _, dmg in ipairs(damageValues) do
            local args
            local charCFrame = player.Character and player.Character:GetPivot() or CFrame.new(entityHRP.Position)
            
            if sig == "tool_damage_numeric_cframe" then
                args = {entity, tool, dmg, charCFrame}
            elseif sig == "tool_damage_string_cframe" then
                args = {entity, tool, tostring(dmg), charCFrame}
            elseif sig == "tool_damage_count_cframe" then
                args = {entity, tool, "1", tostring(entityHitCounter), charCFrame}
            end
            
            -- Call remote (same method as tree system)
            local success, res
            if remote.ClassName == "RemoteFunction" then
                success, res = pcall(function()
                    return remote:InvokeServer(unpack(args))
                end)
            else
                success, res = pcall(function()
                    remote:FireServer(unpack(args))
                    return true
                end)
            end
            
            if success then
                entityHitCounter = entityHitCounter + 1
                return true
            end
        end
    end
    
    return false
end

-- Auto Kill Function
local function autoKillEntities()
    while autoKillEnabled do
        task.wait(0.15)
        
        -- Wrap in pcall to prevent crashes
        pcall(function()
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                
                -- Use ToolManager for dynamic tool discovery (preferAxes = false for combat)
                local tool, source = ToolManager.discoverBestTool(false)
                
                -- Re-fetch remote if needed
                if not toolDamageRemote then
                    toolDamageRemote = replicatedStorage.RemoteEvents:FindFirstChild("ToolDamageObject")
                end
                
                -- Validate tool before using
                if tool and ToolManager.isValidTool(tool) and toolDamageRemote then
                    -- Ensure tool is equipped using ToolManager
                    ToolManager.ensureEquipped(tool)
                    
                    -- Find and kill nearby entities
                    if workspace:FindFirstChild("Characters") then
                        for _, entity in pairs(workspace.Characters:GetChildren()) do
                            if entity:IsA("Model") and entity:FindFirstChild("HumanoidRootPart") and entity ~= character then
                                -- Check if entity is in selected list
                                local isAllowed = false
                                for _, allowedName in pairs(selectedEntities) do
                                    if entity.Name == allowedName then
                                        isAllowed = true
                                        break
                                    end
                                end
                                
                                if isAllowed then
                                    local entityHRP = entity.HumanoidRootPart
                                    local distance = (hrp.Position - entityHRP.Position).Magnitude
                                    
                                    if distance <= killRadius then
                                        task.spawn(function()
                                            attemptEntityHit(toolDamageRemote, tool, entity)
                                        end)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end

-- Create Main Tab (Combat)
local MainTab = Window:Tab({Title = "Main", Icon = "sword"})

Window:Line()

-- Teleport to Campfire Button
MainTab:Button({
    Title = "Teleport to Campfire",
    Desc = "Teleports you to the campfire",
    Callback = function()
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local campfirePos = getCampfirePosition()
            character.HumanoidRootPart.CFrame = CFrame.new(campfirePos)
            Window:Notify({Title = "Teleport", Desc = "Teleported to campfire!", Time = 2})
        end
    end
})

-- Godmode Toggle (with notification concealment)
local godmodeEnabled = false
MainTab:Toggle({
    Title = "Godmode",
    Desc = "Enables infinite health",
    Value = false,
    Callback = function(v)
        if v and not godmodeEnabled then
            godmodeEnabled = true
            
            -- Block notifications by hooking StarterGui:SetCore
            local StarterGui = game:GetService("StarterGui")
            local oldSetCore = StarterGui.SetCore
            local blocking = true
            
            hookfunction(StarterGui.SetCore, function(self, name, ...)
                if blocking and name == "SendNotification" then
                    return nil
                end
                return oldSetCore(self, name, ...)
            end)
            
            -- Load the infinite health script
            loadstring(game:HttpGet("https://raw.githubusercontent.com/ProBaconHub/DATABASE/refs/heads/main/99%20Nights%20in%20the%20Forest/Infinite%20Health.lua"))()
            
            -- Unblock notifications after a short delay
            task.delay(1, function()
                blocking = false
            end)
            
            Window:Notify({Title = "Godmode", Desc = "Infinite health enabled!", Time = 2})
        elseif not v and godmodeEnabled then
            Window:Notify({Title = "Godmode", Desc = "Rejoin to disable godmode", Time = 2})
        end
    end
})

-- Create Auto Tab
local AutoTab = Window:Tab({Title = "Auto", Icon = "zap"})

Window:Line()

-- ==================== AUTO CAMPFIRE ====================
AutoTab:Section({Title = "Auto Campfire"})

local fireStatusLabel = AutoTab:Label({Title = "Loading fire status..."})

-- Update fire status display
local function updateFireStatusLabel()
    local status = getFireStatus()
    if status then
        local text = string.format(
            "Level %d \nProgress: %d/%d \nFuel: %d/%d",
            status.level,
            status.progress,
            status.maxProgress,
            status.fuelRemaining,
            status.fuelTarget
        )
        fireStatusLabel:SetTitle(text)
    else
        fireStatusLabel:SetTitle("Fire not found")
    end
end

-- Auto-update fire status every 2 seconds
task.spawn(function()
    while ScriptState.loopsRunning do
        pcall(updateFireStatusLabel)
        task.wait(2)
    end
end)

local autoCampfireEnabled = false
local autoCampfireThreshold = 50
local autoCampfireFuels = {"Log", "Biofuel", "Coal", "Fuel Canister", "Oil Barrel"}
local autoCampfireFuelLimit = math.huge -- No limit by default

-- Auto Campfire Toggle
AutoTab:Toggle({
    Title = "Auto Campfire",
    Desc = "Auto teleport fuels to campfire when progress drops below threshold",
    Value = false,
    Callback = function(v)
        autoCampfireEnabled = v
        if v then
            Window:Notify({Title = "Auto Campfire", Desc = "Enabled - monitoring fire progress", Time = 2})
        end
    end
})

-- Threshold Slider
AutoTab:Slider({
    Title = "Fuel Threshold (%)",
    Desc = "Teleport fuels when progress drops below this",
    Min = 10,
    Max = 90,
    Value = 50,
    Callback = function(v)
        autoCampfireThreshold = v
    end
})

-- Fuel Limit Slider
AutoTab:Slider({
    Title = "Fuel Limit Per Cycle",
    Desc = "Max fuels to bring per cycle (100 = no limit)",
    Min = 1,
    Max = 100,
    Value = 100,
    Callback = function(v)
        autoCampfireFuelLimit = v >= 100 and math.huge or v
    end
})

-- Fuel Selection for Auto Campfire
AutoTab:Dropdown({
    Title = "Auto Campfire Fuels",
    List = {
        "Log", "Biofuel", "Coal", "Purple Fur Tuft", "Fuel Canister", "Oil Barrel",
        "Cultist Corpse", "Crossbow Cultist Corpse", "Juggernaut Cultist Corpse", 
        "Cultist King Corpse", "Alien Corpse", "Elite Alien Corpse", "Wolf Corpse", 
        "Alpha Wolf Corpse", "Bear Corpse"
    },
    Multi = true,
    Value = {"Log", "Biofuel", "Coal", "Fuel Canister", "Oil Barrel"},
    Callback = function(selected)
        autoCampfireFuels = selected
    end
})

-- Auto Campfire Loop
task.spawn(function()
    while ScriptState.loopsRunning do
        task.wait(5) -- Check every 5 seconds
        
        if autoCampfireEnabled then
            local status = getFireStatus()
            if status then
                local progressPercent = (status.progress / status.maxProgress) * 100
                
                if progressPercent < autoCampfireThreshold then
                    -- Get campfire center and add height for drop (same as debug button)
                    local campground = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Campground")
                    local campfirePos = Vector3.new(0, 15, 0) -- fallback
                    
                    if campground then
                        local mainFire = campground:FindFirstChild("MainFire")
                        if mainFire then
                            local center = mainFire:FindFirstChild("Center")
                            if center and center:IsA("BasePart") then
                                campfirePos = center.Position + Vector3.new(0, 15, 0)
                            end
                        end
                    end
                    
                    local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
                    local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
                    local items = workspace:FindFirstChild("Items")
                    
                    local fuelsBrought = 0
                    
                    if items then
                        for _, item in ipairs(items:GetChildren()) do
                            if fuelsBrought >= autoCampfireFuelLimit then break end
                            
                            -- Check if item is a fuel
                            for _, fuelName in pairs(autoCampfireFuels) do
                                if item.Name == fuelName then
                                    fuelsBrought = fuelsBrought + 1
                                    
                                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                                    
                                    if mainPart then
                                        pcall(function()
                                            if dragRemote then
                                                dragRemote:FireServer(item)
                                            end
                                            mainPart.CFrame = CFrame.new(campfirePos)
                                        end)
                                    end
                                    break
                                end
                            end
                        end
                    end
                    
                    if fuelsBrought > 0 then
                        Window:Notify({
                            Title = "Auto Campfire",
                            Desc = "Dropped " .. fuelsBrought .. " fuels (Progress: " .. math.floor(progressPercent) .. "%)",
                            Time = 2
                        })
                    else
                        Window:Notify({
                            Title = "Auto Campfire",
                            Desc = "No fuels found! (Progress: " .. math.floor(progressPercent) .. "%)",
                            Time = 2
                        })
                    end
                end
            end
        end
    end
end)

-- ==================== AUTO EAT ====================
AutoTab:Section({Title = "Auto Eat"})

-- Get player hunger
local function getPlayerHunger()
    return player:GetAttribute("Hunger") or 0
end

local hungerStatusLabel = AutoTab:Label({Title = "Hunger: Loading..."})

-- Update hunger display
local function updateHungerLabel()
    local hunger = getPlayerHunger()
    hungerStatusLabel:SetTitle(string.format("Hunger: %.0f/100", hunger))
end

-- Auto-update hunger every 2 seconds
task.spawn(function()
    while ScriptState.loopsRunning do
        pcall(updateHungerLabel)
        task.wait(2)
    end
end)

local autoEatEnabled = false
local autoEatThreshold = 50
local autoEatFoods = {"Cooked Meat", "Raw Meat", "Cooked Fish", "Raw Fish", "Berry", "Apple"}
local autoEatSavedPosition = nil -- Position when toggle was enabled

-- Auto Eat Toggle
AutoTab:Toggle({
    Title = "Auto Eat",
    Desc = "Auto eat food when hunger drops below threshold, returns to position",
    Value = false,
    Callback = function(v)
        autoEatEnabled = v
        if v then
            -- Save current position when enabled
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                autoEatSavedPosition = character.HumanoidRootPart.CFrame
            end
            Window:Notify({Title = "Auto Eat", Desc = "Enabled - position saved", Time = 2})
        else
            autoEatSavedPosition = nil
        end
    end
})

-- Hunger Threshold Slider
AutoTab:Slider({
    Title = "Hunger Threshold (%)",
    Desc = "Eat food when hunger drops below this",
    Min = 10,
    Max = 90,
    Value = 50,
    Callback = function(v)
        autoEatThreshold = v
    end
})

-- Food Selection for Auto Eat
AutoTab:Dropdown({
    Title = "Auto Eat Foods",
    List = {
        "Cooked Meat", "Raw Meat", "Cooked Fish", "Raw Fish", 
        "Berry", "Apple", "Carrot", "Corn", "Potato", "Pumpkin",
        "Cooked Carrot", "Cooked Corn", "Cooked Potato", "Cooked Pumpkin",
        "Mushroom", "Cooked Mushroom", "Candy"
    },
    Multi = true,
    Value = {"Cooked Meat", "Cooked Fish", "Berry", "Apple"},
    Callback = function(selected)
        autoEatFoods = selected
    end
})

-- Get consume remote (for eating food)
local consumeRemote = replicatedStorage.RemoteEvents:FindFirstChild("RequestConsumeItem")

-- Auto Eat Loop
task.spawn(function()
    while ScriptState.loopsRunning do
        task.wait(1) -- Check every 1 second (faster)
        
        if autoEatEnabled then
            local hunger = getPlayerHunger()
            
            if hunger < autoEatThreshold then
                local character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    local hrp = character.HumanoidRootPart
                    local items = workspace:FindFirstChild("Items")
                    
                    -- Find nearest food in world
                    local nearestFood = nil
                    local nearestDist = math.huge
                    
                    if items then
                        for _, item in pairs(items:GetChildren()) do
                            local isFood = false
                            for _, foodName in pairs(autoEatFoods) do
                                if item.Name == foodName then
                                    isFood = true
                                    break
                                end
                            end
                            
                            if isFood then
                                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                                if part then
                                    local dist = (part.Position - hrp.Position).Magnitude
                                    if dist < nearestDist then
                                        nearestDist = dist
                                        nearestFood = item
                                    end
                                end
                            end
                        end
                    end
                    
                    if nearestFood then
                        local part = nearestFood.PrimaryPart or nearestFood:FindFirstChildWhichIsA("BasePart")
                        
                        -- Teleport to food
                        hrp.CFrame = CFrame.new(part.Position + Vector3.new(0, 3, 0))
                        task.wait(0.2)
                        
                        -- Eat it
                        pcall(function()
                            consumeRemote:InvokeServer(nearestFood)
                        end)
                        
                        -- Return to saved position
                        task.wait(0.2)
                        if autoEatSavedPosition then
                            hrp.CFrame = autoEatSavedPosition
                        end
                        
                        Window:Notify({
                            Title = "Auto Eat",
                            Desc = "Ate " .. nearestFood.Name .. " (Hunger: " .. math.floor(hunger) .. "%)",
                            Time = 2
                        })
                    end
                end
            end
        end
    end
end)

-- ==================== AUTO CHEST ====================
AutoTab:Section({Title = "Auto Chest"})

-- Helper function to simulate F key press (for releasing items from sack)
-- Using unified simulateFKeyPress() defined at top of script

-- Helper function to find and equip a sack (for Auto Chest)
local function equipSackForChest()
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then return false, "No inventory", nil end
    
    -- Look for any sack in inventory (prefer larger capacity)
    local sackNames = {"Large Sack", "Good Sack", "Sack", "Small Sack"}
    local sack = nil
    
    for _, sackName in ipairs(sackNames) do
        sack = inventory:FindFirstChild(sackName)
        if sack then break end
    end
    
    -- Fallback: find anything with "Sack" in name
    if not sack then
        for _, item in pairs(inventory:GetChildren()) do
            if item.Name:find("Sack") then
                sack = item
                break
            end
        end
    end
    
    if not sack then
        return false, "No sack found", nil
    end
    
    -- Equip the sack using the remote
    if equipItemRemote then
        pcall(function()
            equipItemRemote:FireServer("FireAllClients", sack)
        end)
        task.wait(0.3)
        return true, sack.Name, sack
    end
    
    return false, "Equip remote not found", nil
end

-- Helper function to get sack capacity info
local function getSackCapacity(sack)
    if not sack then return 0, 0 end
    local current = sack:GetAttribute("NumberItems") or 0
    local max = sack:GetAttribute("Capacity") or 15
    return current, max
end

-- Helper function to check if sack has space
local function sackHasSpace(sack)
    local current, max = getSackCapacity(sack)
    return current < max
end

-- Helper function to check if position is inside boundaries (not blocked by boundary walls)
local function isInsideBoundaries(position)
    local boundaries = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("Boundaries")
    if not boundaries then return true end -- No boundaries = allow all
    
    -- Check if any boundary part is very close to the position (within 25 studs)
    -- If a boundary part is close, the position is likely outside/blocked
    for _, part in pairs(boundaries:GetChildren()) do
        if part:IsA("BasePart") then
            local distance = (part.Position - position).Magnitude
            if distance < 30 then
                return false -- Too close to boundary wall
            end
        end
    end
    
    return true
end

-- Helper function to check if chest is opened
local function isChestOpened(chest)
    if not chest then return true end
    
    -- Check for LocalOpened attribute
    if chest:GetAttribute("LocalOpened") == true then
        return true
    end
    
    -- Check for playerIdOpened attributes (format: "1234567890Opened")
    for name, value in pairs(chest:GetAttributes()) do
        if name:find("Opened") and value == true then
            return true
        end
    end
    
    -- Check if ProximityPrompt exists and is enabled
    local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
    if not prompt then
        return true -- No prompt means already opened
    end
    
    return false
end

-- Helper function to get unlocked radius for filtering
local function getUnlockedRadiusForFilter()
    local map = workspace:FindFirstChild("Map")
    if not map then return 500 end -- Default fallback
    
    local boundaries = map:FindFirstChild("Boundaries")
    if not boundaries then return 500 end
    
    local centerX, centerZ = 0, 0
    local closestDist = math.huge
    local wallThickness = 40
    
    for _, child in pairs(boundaries:GetChildren()) do
        if child:IsA("BasePart") and child.Name == "Part" then
            local dist = math.sqrt((child.Position.X - centerX)^2 + (child.Position.Z - centerZ)^2)
            local innerEdge = dist - (wallThickness / 2)
            if innerEdge < closestDist then
                closestDist = innerEdge
            end
        end
    end
    
    return closestDist < math.huge and closestDist or 500
end

-- Helper function to find all UNOPENED chests in workspace.Items (within unlocked radius)
local function findAllChests()
    local chests = {}
    local items = workspace:FindFirstChild("Items")
    if not items then return chests end
    
    local unlockedRadius = getUnlockedRadiusForFilter()
    local centerX, centerZ = 0, 0
    
    for _, item in pairs(items:GetChildren()) do
        if item.Name:lower():find("chest") then
            -- Only add if NOT opened
            if not isChestOpened(item) then
                -- Check if within unlocked radius
                local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                if part then
                    local dist = math.sqrt((part.Position.X - centerX)^2 + (part.Position.Z - centerZ)^2)
                    if dist <= unlockedRadius then
                        table.insert(chests, item)
                    end
                else
                    table.insert(chests, item) -- Add anyway if no part found
                end
            end
        end
    end
    
    return chests
end

-- Helper function to find dropped items near a position
local function findDroppedItemsNear(position, radius)
    radius = radius or 20
    local droppedItems = {}
    local items = workspace:FindFirstChild("Items")
    if not items then return droppedItems end
    
    for _, item in pairs(items:GetChildren()) do
        -- Skip chests themselves
        if not item.Name:lower():find("chest") then
            local part = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
            if part then
                local distance = (part.Position - position).Magnitude
                if distance <= radius then
                    table.insert(droppedItems, item)
                end
            end
        end
    end
    
    return droppedItems
end

-- Get remotes for item pickup
local bagStoreRemote = replicatedStorage.RemoteEvents:FindFirstChild("RequestBagStoreItem")

-- Helper function to pick up item and store in sack
local function pickUpItem(item, sack)
    if not item or not item.Parent then 
        return false 
    end
    
    if not sack then
        print("[AutoChest] No sack!")
        return false
    end
    
    print("[AutoChest] Storing: " .. item.Name)
    
    -- Get or create ItemBag
    local itemBag = player:FindFirstChild("ItemBag")
    if not itemBag then
        itemBag = Instance.new("Folder")
        itemBag.Name = "ItemBag"
        itemBag.Parent = player
    end
    
    -- Move item to ItemBag (clone it there with same name)
    local itemInBag = itemBag:FindFirstChild(item.Name)
    if not itemInBag then
        -- Parent the item to ItemBag
        item.Parent = itemBag
        task.wait(0.1)
    end
    
    -- Now call RequestBagStoreItem
    if bagStoreRemote then
        local itemToStore = itemBag:FindFirstChild(item.Name) or item
        local success, result = pcall(function()
            return bagStoreRemote:InvokeServer(sack, itemToStore)
        end)
        print("[AutoChest] Store result: " .. tostring(result))
        task.wait(0.2)
        return success
    end
    
    return false
end

-- Auto Chest Toggle
local autoChestEnabled = false

AutoTab:Toggle({
    Title = "Auto Chest",
    Desc = "Opens all chests and teleports loot to your current position",
    Value = false,
    Callback = function(v)
        autoChestEnabled = v
        if v then
            task.spawn(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    Window:Notify({Title = "Error", Desc = "Character not found!", Time = 3})
                    autoChestEnabled = false
                    return
                end
                
                -- Save starting position (where toggle was enabled)
                local startPos = character.HumanoidRootPart.Position
                
                -- Find all chests
                local chests = findAllChests()
                if #chests == 0 then
                    Window:Notify({Title = "Auto Chest", Desc = "No chests found!", Time = 3})
                    autoChestEnabled = false
                    return
                end
                
                Window:Notify({Title = "Auto Chest", Desc = "Found " .. #chests .. " chests!", Time = 2})
                
                local totalItemsCollected = 0
                
                -- Process each chest
                for i, chest in ipairs(chests) do
                    if not autoChestEnabled then break end
                    if chest and chest.Parent then
                        local chestPart = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
                        if chestPart then
                            -- Teleport to chest
                            Window:Notify({Title = "Auto Chest", Desc = "(" .. i .. "/" .. #chests .. ") " .. chest.Name, Time = 1})
                            character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                character.HumanoidRootPart.CFrame = chestPart.CFrame + Vector3.new(0, 2, 0)
                            end
                            task.wait(0.3)
                            
                            if autoChestEnabled then
                                -- Open chest
                                local chestPrompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if chestPrompt then
                                    fireproximityprompt(chestPrompt, 0)
                                    task.wait(0.5)
                                    
                                    -- Find dropped items near chest and teleport them to start position
                                    local droppedItems = findDroppedItemsNear(chestPart.Position, 15)
                                    for _, item in ipairs(droppedItems) do
                                        if item and item.Parent then
                                            local itemPart = item.PrimaryPart or item:FindFirstChildWhichIsA("BasePart")
                                            if itemPart then
                                                pcall(function()
                                                    itemPart.CFrame = CFrame.new(startPos + Vector3.new(math.random(-5, 5), 0, math.random(-5, 5)))
                                                end)
                                                totalItemsCollected = totalItemsCollected + 1
                                            end
                                        end
                                    end
                                end
                                
                                task.wait(0.2)
                            end
                        end
                    end
                end
                
                -- Return to start position
                if autoChestEnabled then
                    Window:Notify({Title = "Auto Chest", Desc = "Done! " .. totalItemsCollected .. " items collected", Time = 3})
                else
                    Window:Notify({Title = "Auto Chest", Desc = "Stopped! " .. totalItemsCollected .. " items collected", Time = 3})
                end
                character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = CFrame.new(startPos)
                end
                autoChestEnabled = false
            end)
        end
    end
})

-- Auto Diamond Toggle
local autoDiamondEnabled = false

AutoTab:Toggle({
    Title = "Auto Diamond",
    Desc = "Opens all chests and picks up diamonds",
    Value = false,
    Callback = function(v)
        autoDiamondEnabled = v
        if v then
            task.spawn(function()
                local character = player.Character
                if not character or not character:FindFirstChild("HumanoidRootPart") then
                    Window:Notify({Title = "Error", Desc = "Character not found!", Time = 3})
                    autoDiamondEnabled = false
                    return
                end
                
                -- Get campfire position for return
                local campfirePos = getCampfirePosition() or Vector3.new(0, 10, 0)
                
                -- Find all chests
                local chests = findAllChests()
                if #chests == 0 then
                    Window:Notify({Title = "Auto Diamond", Desc = "No chests found! Returning to camp...", Time = 3})
                    character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = CFrame.new(campfirePos)
                    end
                    autoDiamondEnabled = false
                    return
                end
                
                Window:Notify({Title = "Auto Diamond", Desc = "Found " .. #chests .. " chests!", Time = 2})
                
                -- Get the diamond pickup remote
                local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
                local takeDiamondsRemote = RemoteEvents:FindFirstChild("RequestTakeDiamonds")
                
                local totalDiamondsCollected = 0
                
                -- Process each chest
                for i, chest in ipairs(chests) do
                    if not autoDiamondEnabled then break end
                    if chest and chest.Parent then
                        local chestPart = chest.PrimaryPart or chest:FindFirstChildWhichIsA("BasePart")
                        if chestPart then
                            -- Teleport to chest
                            Window:Notify({Title = "Auto Diamond", Desc = "(" .. i .. "/" .. #chests .. ") " .. chest.Name, Time = 1})
                            character = player.Character
                            if character and character:FindFirstChild("HumanoidRootPart") then
                                character.HumanoidRootPart.CFrame = chestPart.CFrame + Vector3.new(0, 2, 0)
                            end
                            task.wait(0.3)
                            
                            if autoDiamondEnabled then
                                -- Open chest
                                local chestPrompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if chestPrompt then
                                    fireproximityprompt(chestPrompt, 0)
                                    task.wait(0.5)
                                    
                                    -- Pick up any diamonds that dropped
                                    if takeDiamondsRemote then
                                        local items = workspace:FindFirstChild("Items")
                                        if items then
                                            for _, diamond in pairs(items:GetChildren()) do
                                                if not autoDiamondEnabled then break end
                                                if diamond.Name == "Diamond" and diamond:IsA("Model") then
                                                    local mainPart = diamond:FindFirstChildWhichIsA("BasePart") or diamond:FindFirstChild("Main")
                                                    if mainPart then
                                                        -- Teleport to diamond
                                                        character = player.Character
                                                        if character and character:FindFirstChild("HumanoidRootPart") then
                                                            character.HumanoidRootPart.CFrame = mainPart.CFrame + Vector3.new(0, 3, 0)
                                                        end
                                                        task.wait(0.2)
                                                        pcall(function()
                                                            takeDiamondsRemote:FireServer(diamond)
                                                        end)
                                                        totalDiamondsCollected = totalDiamondsCollected + 1
                                                        task.wait(0.2)
                                                    end
                                                end
                                            end
                                        end
                                    end
                                end
                                
                                task.wait(0.2)
                            end
                        end
                    end
                end
                
                -- Return to campfire
                character = player.Character
                if character and character:FindFirstChild("HumanoidRootPart") then
                    character.HumanoidRootPart.CFrame = CFrame.new(campfirePos)
                end
                
                if autoDiamondEnabled then
                    Window:Notify({Title = "Auto Diamond", Desc = "Done! " .. totalDiamondsCollected .. " diamonds collected", Time = 3})
                else
                    Window:Notify({Title = "Auto Diamond", Desc = "Stopped! " .. totalDiamondsCollected .. " diamonds collected", Time = 3})
                end
                autoDiamondEnabled = false
            end)
        end
    end
})

-- ==================== AUTO WALL ====================
AutoTab:Section({Title = "Auto Wall"})

-- Get current log count from CraftingBench WoodSign (moved here for Auto Wall to use)
local function getScrapperLogCount()
    local textLabel = workspace:FindFirstChild("Map")
        and workspace.Map:FindFirstChild("Campground")
        and workspace.Map.Campground:FindFirstChild("CraftingBench")
        and workspace.Map.Campground.CraftingBench:FindFirstChild("WoodSign")
        and workspace.Map.Campground.CraftingBench.WoodSign:FindFirstChild("SurfaceGui")
        and workspace.Map.Campground.CraftingBench.WoodSign.SurfaceGui:FindFirstChild("TextLabel")
    
    if textLabel then
        local rawText = textLabel.Text
        local count = tonumber(rawText)
        return count or 0
    end
    return 0
end

-- Auto Wall Settings
local autoWallSettings = {
    shape = "Square",
    radius = 30,
    wallWidth = 15.19, -- Default based on actual Log Wall width (length)
    previewParts = {},
    isBuilding = false
}

-- Function to scan Log Wall size from workspace (deep scan)
-- Returns: width (length of wall), depth (thickness), height
local function scanLogWallDimensions()
    local function scanModel(model)
        if not model or not model:IsA("Model") then return nil end
        
        local cf, size = model:GetBoundingBox()
        -- Size: X, Y, Z
        -- Wall is typically: long (width), tall (height), thin (depth)
        -- We need to figure out which axis is which
        
        local dims = {
            {axis = "X", value = size.X},
            {axis = "Y", value = size.Y},
            {axis = "Z", value = size.Z}
        }
        
        -- Sort by size: smallest is depth, largest horizontal is width, Y is height
        table.sort(dims, function(a, b) return a.value < b.value end)
        
        -- Height is Y axis
        local height = size.Y
        
        -- For horizontal axes (X and Z), the larger one is width, smaller is depth
        local horizontalDims = {}
        for _, d in ipairs(dims) do
            if d.axis ~= "Y" then
                table.insert(horizontalDims, d.value)
            end
        end
        table.sort(horizontalDims)
        
        local depth = horizontalDims[1] or 1
        local width = horizontalDims[2] or 4.6
        
        return {
            width = width,   -- Length of wall (for spacing calculation)
            depth = depth,   -- Thickness of wall
            height = height, -- Height of wall
            rawSize = size   -- Raw bounding box
        }
    end
    
    -- Search locations
    local searchLocations = {
        workspace:FindFirstChild("Structures"),
        workspace:FindFirstChild("Items"),
        workspace:FindFirstChild("Map")
    }
    
    for _, location in ipairs(searchLocations) do
        if location then
            for _, obj in ipairs(location:GetDescendants()) do
                if obj.Name == "Log Wall" and obj:IsA("Model") then
                    local dims = scanModel(obj)
                    if dims then
                        return dims
                    end
                end
            end
        end
    end
    
    return nil
end

-- Wrapper for backward compatibility
local function scanLogWallWidth()
    local dims = scanLogWallDimensions()
    if dims then
        return dims.width
    end
    return nil
end

-- Function to calculate walls needed
local function calculateWallsNeeded(shape, radius, wallWidth)
    if wallWidth <= 0 then wallWidth = 15.19 end
    
    -- Square only: 4 sides, each side = radius * 2
    local sideLength = radius * 2
    local wallsPerSide = math.ceil(sideLength / wallWidth)
    return wallsPerSide * 4
end

-- Function to generate wall positions (Square only)
local function generateWallPositions(shape, radius, wallCount, centerPos)
    local positions = {}
    local groundY = centerPos.Y - 10 -- Ground level (campfire pos has +10 offset)
    local wallWidth = autoWallSettings.wallWidth
    
    -- Place walls end-to-end along 4 sides of a square
    local sideLength = radius * 2
    local wallsPerSide = math.ceil(sideLength / wallWidth)
    local actualSpacing = sideLength / wallsPerSide
    
    -- 4 sides: North (-Z), East (+X), South (+Z), West (-X)
    -- Each wall should face OUTWARD from the center of the square
    -- Wall model front faces +Z by default, so:
    -- -Z (North): rotate 180° | +Z (South): rotate 0°
    -- +X (East): rotate -90° | -X (West): rotate +90°
    -- BUT based on testing: North=π and West=π/2 work, so model front must face -Z
    -- Therefore: +Z (South) needs 0°, +X (East) needs -π/2, -X (West) needs π/2
    -- Since North/West work, East/South must need the SAME rotation as their working opposite
    local sides = {
        {startX = -radius, startZ = -radius, dirX = 1, dirZ = 0, rot = math.pi},         -- North side ✓
        {startX = radius, startZ = -radius, dirX = 0, dirZ = 1, rot = math.pi/2},        -- East side (try same as West)
        {startX = radius, startZ = radius, dirX = -1, dirZ = 0, rot = math.pi},          -- South side (try same as North)
        {startX = -radius, startZ = radius, dirX = 0, dirZ = -1, rot = -math.pi/2}       -- West side (swap with East)
    }
    
    for _, side in ipairs(sides) do
        for i = 0, wallsPerSide - 1 do
            -- Position each wall centered along the side
            local offset = (i + 0.5) * actualSpacing
            local x = centerPos.X + side.startX + side.dirX * offset
            local z = centerPos.Z + side.startZ + side.dirZ * offset
            
            local wallCFrame = CFrame.new(x, groundY, z) * CFrame.Angles(0, side.rot, 0)
            table.insert(positions, wallCFrame)
        end
    end
    
    return positions
end

-- Function to clear wall preview
local function clearWallPreview()
    for _, part in ipairs(autoWallSettings.previewParts) do
        if part and part.Parent then
            part:Destroy()
        end
    end
    autoWallSettings.previewParts = {}
end

-- Function to show wall preview
local function showWallPreview()
    clearWallPreview()
    
    local campfirePos = getCampfirePosition()
    local wallCount = calculateWallsNeeded(autoWallSettings.shape, autoWallSettings.radius, autoWallSettings.wallWidth)
    local positions = generateWallPositions(autoWallSettings.shape, autoWallSettings.radius, wallCount, campfirePos)
    
    -- Create preview folder
    local previewFolder = workspace:FindFirstChild("AutoWallPreview")
    if not previewFolder then
        previewFolder = Instance.new("Folder")
        previewFolder.Name = "AutoWallPreview"
        previewFolder.Parent = workspace
    end
    
    -- Create preview parts
    for i, cf in ipairs(positions) do
        local previewPart = Instance.new("Part")
        previewPart.Name = "WallPreview_" .. i
        -- Log Wall: length along X-axis, thin on Z-axis
        -- Using smaller preview for visibility (actual wall is ~15x14.5x4.6)
        previewPart.Size = Vector3.new(autoWallSettings.wallWidth, 10, 1) -- Length, Height, Depth (thin for preview)
        previewPart.CFrame = cf
        previewPart.Anchored = true
        previewPart.CanCollide = false
        previewPart.Transparency = 0.6
        previewPart.Color = Color3.fromRGB(0, 255, 0) -- Green preview
        previewPart.Material = Enum.Material.Neon
        previewPart.Parent = previewFolder
        
        table.insert(autoWallSettings.previewParts, previewPart)
    end
    
    Window:Notify({
        Title = "Auto Wall",
        Desc = "Preview showing " .. #positions .. " wall positions",
        Time = 2
    })
end

-- Function to find blueprint in inventory or nil instances
local function findLogWallBlueprint()
    local blueprintName = "Log Wall Blueprint"
    
    -- Check inventory first
    local inventory = player:FindFirstChild("Inventory")
    if inventory then
        local blueprint = inventory:FindFirstChild(blueprintName)
        if blueprint then return blueprint end
    end
    
    -- Fallback to nil instances
    local success, result = pcall(function()
        for _, obj in pairs(getnilinstances()) do
            if obj.Name == blueprintName then
                return obj
            end
        end
        return nil
    end)
    
    if success and result then
        return result
    end
    
    return nil
end

-- Constants for Log Wall crafting
local LOG_WALL_COST = 12 -- Logs required per Log Wall Blueprint

-- Function to check if scrapper has enough logs for auto wall
local function checkLogsForAutoWall()
    local wallCount = calculateWallsNeeded(autoWallSettings.shape, autoWallSettings.radius, autoWallSettings.wallWidth)
    local logsNeeded = wallCount * LOG_WALL_COST
    local currentLogs = getScrapperLogCount()
    
    return {
        wallCount = wallCount,
        logsNeeded = logsNeeded,
        currentLogs = currentLogs,
        hasEnough = currentLogs >= logsNeeded,
        shortage = math.max(0, logsNeeded - currentLogs)
    }
end

-- Function to build walls
local function buildWalls()
    if autoWallSettings.isBuilding then
        Window:Notify({Title = "Auto Wall", Desc = "Already building walls!", Time = 2})
        return
    end
    
    -- Check if we have enough logs before starting
    local logCheck = checkLogsForAutoWall()
    
    if not logCheck.hasEnough then
        Window:Notify({
            Title = "Not Enough Logs!",
            Desc = "You have " .. logCheck.currentLogs .. "/" .. logCheck.logsNeeded .. " logs. Farm " .. logCheck.shortage .. " more logs to build " .. logCheck.wallCount .. " walls!",
            Time = 5
        })
        return
    end
    
    autoWallSettings.isBuilding = true
    clearWallPreview()
    
    local campfirePos = getCampfirePosition()
    local wallCount = logCheck.wallCount
    local positions = generateWallPositions(autoWallSettings.shape, autoWallSettings.radius, wallCount, campfirePos)
    
    Window:Notify({
        Title = "Auto Wall",
        Desc = "Building " .. wallCount .. " walls (" .. logCheck.logsNeeded .. " logs)...",
        Time = 3
    })
    
    local wallsPlaced = 0
    local wallsFailed = 0
    
    for i, targetCFrame in ipairs(positions) do
        if not autoWallSettings.isBuilding then
            Window:Notify({Title = "Auto Wall", Desc = "Build cancelled!", Time = 2})
            break
        end
        
        -- Step 1: Craft Log Wall
        local craftSuccess = pcall(function()
            replicatedStorage.RemoteEvents.CraftItem:InvokeServer("Log Wall")
        end)
        
        if not craftSuccess then
            wallsFailed = wallsFailed + 1
            Window:Notify({Title = "Auto Wall", Desc = "Failed to craft wall " .. i .. "/" .. wallCount, Time = 1})
        else
            task.wait(0.3) -- Wait for blueprint to appear
            
            -- Step 2: Find and place the blueprint
            local blueprint = findLogWallBlueprint()
            
            if blueprint then
                local placeSuccess = pcall(function()
                    -- Extract rotation from targetCFrame to pass as the 3rd argument
                    local rotationCFrame = targetCFrame - targetCFrame.Position -- Get just the rotation component
                    replicatedStorage.RemoteEvents.RequestPlaceStructure:InvokeServer(
                        blueprint,
                        {
                            Valid = true,
                            CFrame = targetCFrame,
                            Position = targetCFrame.Position
                        },
                        rotationCFrame,
                        nil
                    )
                end)
                
                if placeSuccess then
                    wallsPlaced = wallsPlaced + 1
                else
                    wallsFailed = wallsFailed + 1
                end
            else
                wallsFailed = wallsFailed + 1
                Window:Notify({Title = "Auto Wall", Desc = "Blueprint not found for wall " .. i, Time = 1})
            end
        end
        
        -- Progress notification every 5 walls
        if i % 5 == 0 then
            Window:Notify({Title = "Auto Wall", Desc = "Progress: " .. i .. "/" .. wallCount, Time = 1})
        end
        
        task.wait(0.5) -- Delay between placements
    end
    
    autoWallSettings.isBuilding = false
    
    Window:Notify({
        Title = "Auto Wall",
        Desc = "Complete! Placed: " .. wallsPlaced .. ", Failed: " .. wallsFailed,
        Time = 5
    })
end

-- Wall Radius Slider
AutoTab:Slider({
    Title = "Wall Radius",
    Desc = "Distance from campfire to walls",
    Min = 10,
    Max = 100,
    Rounding = 0,
    Value = 30,
    Callback = function(val)
        autoWallSettings.radius = val
        -- Update preview in real-time if preview exists
        if #autoWallSettings.previewParts > 0 then
            showWallPreview()
        end
    end
})

-- Preview Wall Toggle
AutoTab:Toggle({
    Title = "Preview Wall",
    Desc = "Shows where walls will be placed (green preview)",
    Value = false,
    Callback = function(v)
        if v then
            showWallPreview()
        else
            clearWallPreview()
            local previewFolder = workspace:FindFirstChild("AutoWallPreview")
            if previewFolder then
                previewFolder:Destroy()
            end
        end
    end
})

-- Build Wall Button
AutoTab:Button({
    Title = "Build Wall",
    Desc = "Crafts and places all walls around campfire",
    Callback = function()
        task.spawn(buildWalls)
    end
})

MainTab:Section({Title = "Auto Kill"})

-- Warning label
MainTab:Label({
    Title = "Do NOT manually equip weapons. Keep in inventory."
})

-- Entity Selection Dropdown
MainTab:Dropdown({
    Title = "Target Entities",
    List = allEntities,
    Multi = true,
    Value = allEntities,
    Callback = function(selected)
        selectedEntities = selected
    end
})

-- Initialize with all entities selected
selectedEntities = allEntities

-- Kill Radius Slider
MainTab:Slider({
    Title = "Kill Radius",
    Min = 10,
    Max = 200,
    Rounding = 0,
    Value = 200,
    Callback = function(val)
        killRadius = val
    end
})

-- Auto Kill Toggle (combined with ESP)
MainTab:Toggle({
    Title = "Auto Kill Entities",
    Desc = "Automatically kills entities within range with ESP",
    Value = false,
    Callback = function(v)
        autoKillEnabled = v
        showEntityESP = v -- Enable/disable ESP together
        if v then
            Window:Notify({
                Title = "Auto Kill",
                Desc = "Auto kill + ESP enabled!",
                Time = 2
            })
            task.spawn(autoKillEntities)
        else
            clearAllEntityESP()
            Window:Notify({
                Title = "Auto Kill",
                Desc = "Auto kill + ESP disabled!",
                Time = 2
            })
        end
    end
})

-- ==================== AUTO CUT TREES ====================
MainTab:Section({Title = "Auto Cut Trees"})

-- Warning label
MainTab:Label({
    Title = "Do NOT manually equip axes. Keep in inventory."
})

-- Tree cutting settings
local treeCutSettings = {
    AutoCut = false,
    Targets = {"All"},
    Range = 200,
    ShowHP = false,
    HitDelay = 0.5,
    TryDamageValues = {"1"},
    TrySignatures = {"tool_damage_numeric_cframe", "tool_damage_string_cframe", "tool_damage_count_cframe"}
}

-- Find ToolDamageObject remote
local function findToolDamageRemote()
    local remoteName = "ToolDamageObject"
    local remote = replicatedStorage:FindFirstChild("RemoteEvents") and replicatedStorage.RemoteEvents:FindFirstChild(remoteName)
    if remote then return remote end
    
    for _, child in ipairs(replicatedStorage:GetDescendants()) do
        if child.Name == remoteName and (child.ClassName == "RemoteFunction" or child.ClassName == "RemoteEvent") then
            return child
        end
    end
    return nil
end

local treeRemoteToolDamage = findToolDamageRemote()

-- Get map folders (Foliage and Landmarks)
local function getMapFolders()
    local map = workspace:FindFirstChild("Map") or workspace:FindFirstChild("map")
    if not map then return nil, nil end
    
    local foliage = map:FindFirstChild("Foliage") or map:FindFirstChild("foliage")
    local landmarks = map:FindFirstChild("Landmarks") or map:FindFirstChild("landmarks")
    return foliage, landmarks
end

-- Check if model is damageable (has Health attribute)
local function isDamageableModel(model)
    if not model or not model:IsA("Model") then return false end
    if type(model.GetAttribute) ~= "function" then return false end
    return model:GetAttribute("Health") ~= nil
end

-- Get targets in range
local function getTreeTargetsInRange(range)
    range = tonumber(range) or treeCutSettings.Range
    local targets = {}
    local foliage, landmarks = getMapFolders()
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return targets end
    local hrp = character.HumanoidRootPart
    
    local function scanFolder(folder)
        if not folder then return end
        for _, obj in ipairs(folder:GetChildren()) do
            if isDamageableModel(obj) then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local distance = (part.Position - hrp.Position).Magnitude
                    if distance <= range then
                        table.insert(targets, obj)
                    end
                end
            end
        end
    end
    
    scanFolder(foliage)
    scanFolder(landmarks)
    return targets
end

-- DEPRECATED: Old tree tool functions removed - now using ToolManager module
-- getTreeToolCandidates, preferredTreeTools, and selectBestTreeTool have been replaced by:
-- - ToolManager.discoverBestTool(true) for tree cutting (preferAxes = true)

-- Call remote
local function callTreeRemote(remote, args)
    if not remote then return false, "no remote" end
    if type(args) ~= "table" then return false, "args must be table" end
    
    if remote.ClassName == "RemoteFunction" then
        local success, res = pcall(function()
            return remote:InvokeServer(unpack(args))
        end)
        return success, res
    else
        local success, res = pcall(function()
            remote:FireServer(unpack(args))
            return true
        end)
        return success, res
    end
end

-- Hit counter for signatures
local treeHitCounter = 1

-- Attempt hit on tree
local function attemptTreeHit(remote, tool, target)
    if not remote or not tool or not target then return false, "missing param" end
    
    local part = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
    if not part then return false, "no basepart" end
    
    -- Get damage values
    local damageValues = {}
    if type(tool.GetAttribute) == "function" then
        local weaponDmg = tool:GetAttribute("WeaponDamage")
        if weaponDmg ~= nil then table.insert(damageValues, weaponDmg) end
        local resourceDmg = tool:GetAttribute("WeaponResourceDamage")
        if resourceDmg ~= nil then table.insert(damageValues, resourceDmg) end
    end
    for _, v in ipairs(treeCutSettings.TryDamageValues) do
        table.insert(damageValues, v)
    end
    
    -- Remove duplicates
    local seen = {}
    local uniqueDamage = {}
    for _, v in ipairs(damageValues) do
        local s = tostring(v)
        if not seen[s] then
            seen[s] = true
            table.insert(uniqueDamage, v)
        end
    end
    if #uniqueDamage == 0 then uniqueDamage = {"1"} end
    
    -- Try different signatures
    for _, sig in ipairs(treeCutSettings.TrySignatures) do
        for _, dmg in ipairs(uniqueDamage) do
            local args
            local charCFrame = player.Character and player.Character:GetPivot() or CFrame.new(part.Position)
            
            if sig == "tool_damage_numeric_cframe" then
                args = {target, tool, dmg, charCFrame}
            elseif sig == "tool_damage_string_cframe" then
                args = {target, tool, tostring(dmg), charCFrame}
            elseif sig == "tool_damage_count_cframe" then
                args = {target, tool, "1", tostring(treeHitCounter), charCFrame}
            else
                args = {target, tool, tostring(dmg), charCFrame}
            end
            
            local success, res = callTreeRemote(remote, args)
            task.wait(0.12)
            
            if success then
                treeHitCounter = treeHitCounter + 1
                return true, "hit successful"
            end
            task.wait(0.1)
        end
    end
    
    return false, "exhausted signatures"
end

-- Tree ESP
local treeESPFolder = Instance.new("Folder")
treeESPFolder.Name = "TreeHPESP"
treeESPFolder.Parent = workspace

local treeESPMap = {}

local function removeTreeESP(model)
    local entry = treeESPMap[model]
    if entry then
        pcall(function()
            if entry.bb and entry.bb.Parent then
                entry.bb:Destroy()
            end
        end)
        treeESPMap[model] = nil
    end
end

local function removeAllTreeESP()
    for model, _ in pairs(treeESPMap) do
        removeTreeESP(model)
    end
end

local function updateTreeESP(model)
    if not treeCutSettings.ShowHP then
        return removeTreeESP(model)
    end
    if not model or not model.Parent then
        return removeTreeESP(model)
    end
    
    local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not root then return removeTreeESP(model) end
    
    local entry = treeESPMap[model]
    if not entry then
        local gui = Instance.new("BillboardGui")
        gui.Name = "AutoCut_HP"
        gui.Adornee = root
        gui.Size = UDim2.new(0, 120, 0, 22)
        gui.StudsOffset = Vector3.new(0, 2.2, 0)
        gui.AlwaysOnTop = true
        gui.Parent = treeESPFolder
        
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.fromScale(1, 1)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamBold
        lbl.TextScaled = true
        lbl.TextColor3 = Color3.new(1, 1, 1)
        lbl.TextStrokeTransparency = 0
        lbl.Parent = gui
        
        treeESPMap[model] = {bb = gui, lbl = lbl}
        entry = treeESPMap[model]
    end
    
    local health = model:GetAttribute("Health")
    entry.lbl.Text = (model.Name or "Tree") .. " | HP: " .. (health and math.floor(tonumber(health) or 0) or "N/A")
    entry.bb.Enabled = treeCutSettings.ShowHP
end

-- Main tree cutting loop
local treeCutLoop = nil

local function startTreeCutLoop()
    if treeCutLoop == true then return end -- Only skip if actively running
    treeCutLoop = true
    
    task.spawn(function()
        while treeCutLoop do
            if not treeCutSettings.AutoCut then
                task.wait(0.5)
            else
                -- Wrap in pcall to prevent crashes
                pcall(function()
                    local targets = getTreeTargetsInRange(treeCutSettings.Range)
                    if #targets == 0 then
                        return -- will wait at end of loop
                    end
                    
                    -- Use ToolManager for dynamic tool discovery (preferAxes = true for tree cutting)
                    local tool, source = ToolManager.discoverBestTool(true)
                    
                    if tool and ToolManager.isValidTool(tool) then
                        -- Ensure tool is equipped
                        ToolManager.ensureEquipped(tool)
                        
                        -- Get tool's actual cooldown (use ToolCooldown attribute if available)
                        local toolCooldown = treeCutSettings.HitDelay or 0.5
                        pcall(function()
                            if type(tool.GetAttribute) == "function" then
                                local cd = tool:GetAttribute("ToolCooldown")
                                if cd and tonumber(cd) then
                                    toolCooldown = tonumber(cd)
                                end
                            end
                        end)
                        
                        for _, target in ipairs(targets) do
                            task.spawn(function()
                                pcall(function()
                                    if not (target and target.Parent) then return end
                                    
                                    -- Check if target matches selected types
                                    local allowed = false
                                    for _, t in ipairs(treeCutSettings.Targets or {"All"}) do
                                        if t == "All" then
                                            allowed = true
                                            break
                                        end
                                    end
                                    
                                    if not allowed then
                                        local name = (target.Name or ""):lower()
                                        for _, t in ipairs(treeCutSettings.Targets) do
                                            if name:find(t:lower()) then
                                                allowed = true
                                                break
                                            end
                                        end
                                    end
                                    
                                    if not allowed then return end
                                    
                                    if treeCutSettings.ShowHP then
                                        updateTreeESP(target)
                                    end
                                    
                                    attemptTreeHit(treeRemoteToolDamage, tool, target)
                                    task.wait(toolCooldown)
                                end)
                            end)
                        end
                        task.wait(0.25)
                    else
                        -- No valid tool found, wait and retry
                        task.wait(1)
                    end
                end)
                task.wait(0.25) -- Small delay between iterations
            end
        end
    end)
end

local function stopTreeCutLoop()
    treeCutLoop = false -- Changed from nil to false so it can be restarted
end

-- ESP update loop (for auto cut feature)
task.spawn(function()
    while ScriptState.loopsRunning do
        task.wait(0.25)
        if treeCutSettings.ShowHP then
            local foliage, landmarks = getMapFolders()
            local list = {}
            
            if foliage then
                for _, obj in ipairs(foliage:GetChildren()) do
                    if obj:GetAttribute("Health") then
                        table.insert(list, obj)
                    end
                end
            end
            if landmarks then
                for _, obj in ipairs(landmarks:GetChildren()) do
                    if obj:GetAttribute("Health") then
                        table.insert(list, obj)
                    end
                end
            end
            
            for _, model in ipairs(list) do
                updateTreeESP(model)
            end
        end
    end
end)

-- ==================== TREE ESP SYSTEM ====================
local treeESPEnabled = false
local treeESPRange = 200
local treeESPFolder2 = Instance.new("Folder")
treeESPFolder2.Name = "TreeESPSystem"
treeESPFolder2.Parent = workspace

local treeESPObjects = {}

-- Create Tree ESP Billboard
local function createTreeESPBillboard(model)
    if not model or not model.Parent then return nil end
    
    local root = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
    if not root then return nil end
    
    local gui = Instance.new("BillboardGui")
    gui.Name = "TreeESP_" .. model.Name
    gui.Adornee = root
    gui.Size = UDim2.new(0, 150, 0, 40)
    gui.StudsOffset = Vector3.new(0, root.Size.Y / 2 + 3, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = treeESPRange + 50
    gui.Parent = treeESPFolder2
    
    -- Name label
    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.fromScale(1, 0.5)
    nameLabel.Position = UDim2.fromScale(0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextScaled = true
    nameLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    nameLabel.TextStrokeTransparency = 0
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Text = model.Name
    nameLabel.Parent = gui
    
    -- HP label
    local hpLabel = Instance.new("TextLabel")
    hpLabel.Name = "HPLabel"
    hpLabel.Size = UDim2.fromScale(1, 0.5)
    hpLabel.Position = UDim2.fromScale(0, 0.5)
    hpLabel.BackgroundTransparency = 1
    hpLabel.Font = Enum.Font.GothamBold
    hpLabel.TextScaled = true
    hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
    hpLabel.TextStrokeTransparency = 0
    hpLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    hpLabel.Text = "HP: ?"
    hpLabel.Parent = gui
    
    return gui
end

-- Update Tree ESP
local function updateTreeESPSystem()
    if not treeESPEnabled then return end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local hrp = character.HumanoidRootPart
    
    local foliage, landmarks = getMapFolders()
    local treesInRange = {}
    
    -- Scan for trees with Health attribute
    local function scanForTrees(folder)
        if not folder then return end
        for _, obj in ipairs(folder:GetChildren()) do
            if obj:IsA("Model") and obj:GetAttribute("Health") ~= nil then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart")
                if part then
                    local distance = (part.Position - hrp.Position).Magnitude
                    if distance <= treeESPRange then
                        treesInRange[obj] = distance
                    end
                end
            end
        end
    end
    
    scanForTrees(foliage)
    scanForTrees(landmarks)
    
    -- Remove ESP for trees no longer in range or destroyed
    for model, espGui in pairs(treeESPObjects) do
        if not model or not model.Parent or not treesInRange[model] then
            if espGui and espGui.Parent then
                espGui:Destroy()
            end
            treeESPObjects[model] = nil
        end
    end
    
    -- Update or create ESP for trees in range
    for model, distance in pairs(treesInRange) do
        local health = model:GetAttribute("Health")
        local maxHealth = model:GetAttribute("MaxHealth") or health
        
        if not treeESPObjects[model] then
            -- Create new ESP
            local esp = createTreeESPBillboard(model)
            if esp then
                treeESPObjects[model] = esp
            end
        end
        
        -- Update ESP text
        local esp = treeESPObjects[model]
        if esp then
            local hpLabel = esp:FindFirstChild("HPLabel")
            local nameLabel = esp:FindFirstChild("NameLabel")
            
            if hpLabel then
                local currentHP = math.floor(tonumber(health) or 0)
                local maxHP = math.floor(tonumber(maxHealth) or currentHP)
                local hpPercent = maxHP > 0 and (currentHP / maxHP * 100) or 0
                
                hpLabel.Text = "HP: " .. currentHP .. "/" .. maxHP .. " (" .. math.floor(hpPercent) .. "%)"
                
                -- Color based on HP percentage
                if hpPercent > 60 then
                    hpLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
                elseif hpPercent > 30 then
                    hpLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
                else
                    hpLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
                end
            end
            
            if nameLabel then
                nameLabel.Text = model.Name .. " [" .. math.floor(distance) .. "m]"
            end
        end
    end
end

-- Clear all Tree ESP
local function clearTreeESPSystem()
    for model, espGui in pairs(treeESPObjects) do
        if espGui and espGui.Parent then
            espGui:Destroy()
        end
    end
    treeESPObjects = {}
end

-- Real-time Tree ESP update loop (faster updates for HP changes)
task.spawn(function()
    while ScriptState.loopsRunning do
        task.wait(0.1) -- Fast update for real-time HP tracking
        if treeESPEnabled then
            updateTreeESPSystem()
        end
    end
end)

-- Cleanup ESP when trees are removed
workspace.DescendantRemoving:Connect(function(desc)
    if treeESPMap[desc] then
        removeTreeESP(desc)
    end
end)

-- Start the loop
startTreeCutLoop()

-- UI Elements
MainTab:Dropdown({
    Title = "Tree Types",
    List = {"All", "Small Tree", "Snowy Small Tree", "TreeBig1", "TreeBig2", "TreeBig3"},
    Multi = true,
    Value = {"All"},
    Callback = function(selected)
        if type(selected) == "table" and #selected > 0 then
            treeCutSettings.Targets = selected
        else
            treeCutSettings.Targets = {"All"}
        end
    end
})

MainTab:Slider({
    Title = "Tree Range",
    Min = 10,
    Max = 200,
    Rounding = 0,
    Value = 200,
    Callback = function(val)
        treeCutSettings.Range = val
        treeESPRange = val -- Sync ESP range with cut range
    end
})

MainTab:Toggle({
    Title = "Auto Cut Trees",
    Desc = "Automatically chop trees in range with ESP",
    Value = false,
    Callback = function(v)
        treeCutSettings.AutoCut = v
        treeESPEnabled = v -- Enable/disable ESP together
        if v then
            Window:Notify({
                Title = "Auto Cut",
                Desc = "Tree cutting + ESP enabled!",
                Time = 2
            })
            startTreeCutLoop()
        else
            clearTreeESPSystem()
            Window:Notify({
                Title = "Auto Cut",
                Desc = "Tree cutting + ESP disabled!",
                Time = 2
            })
        end
    end
})

-- Get scrapper position (needed for Auto Day Farm)
local function getScrapperPosition()
    local scrapper = workspace.Map.Campground:FindFirstChild("Scrapper")
    if scrapper then
        local movers = scrapper:FindFirstChild("Movers")
        if movers then
            local pos = movers:GetPivot().Position
            return pos + Vector3.new(0, 3, 0)
        end
    end
    return Vector3.new(0, 10, 0) -- Fallback to spawn
end

-- Note: getScrapperLogCount() is defined earlier in the Auto Wall section

-- ==================== AUTO DAY FARM ====================
AutoTab:Section({Title = "Auto Day Farm"})

-- Phase State Variables
local autoDayFarmEnabled = false
local autoDayFarmPhase = 0  -- 0 = idle, 1-5 = active phase
local autoDayFarmComplete = false  -- Tracks if all phases completed successfully
local mapLoaderRunning = false  -- Tracks if map loader is currently running

-- Phase Configuration
local AutoDayFarmConfig = {
    bringInterval = 2,  -- seconds between bring cycles
    phase1LogsToScrapper = 5,
    phase4LogsToScrapper = 20,
    phase7LogsToScrapper = 30,
    rodPlacementDistance = 50,  -- studs from player
    spiralSpeed = 300,  -- studs per second
}

-- Fuel items (non-log fuels)
local autoDayFarmFuelItems = {"Biofuel", "Coal", "Purple Fur Tuft", "Fuel Canister", "Oil Barrel"}

-- All scrap types that should go to scrapper
local autoDayFarmScrapItems = {
    "Scrap", "Bolt", "Sheet Metal", "UFO Junk", "UFO Component", "Broken Fan", 
    "Old Radio", "Gears", "Broken Microwave", "Tyre", "Metal Chair", 
    "Old Car Engine", "Washing Machine", "Cultist Experiment", 
    "Cultist Prototype", "UFO Scrap"
}

-- Helper function to get nil instances (for finding blueprints)
local function GetNil(Name)
    for _, Object in getnilinstances() do
        if Object.Name == Name then
            return Object
        end
    end
    return nil
end

-- Helper function to get item from inventory
local function GetFromInventory(Name)
    local inventory = player:FindFirstChild("Inventory")
    if inventory then
        return inventory:FindFirstChild(Name)
    end
    return nil
end

-- Status Label
local autoDayFarmStatusLabel = AutoTab:Label({Title = "Phase: Idle"})

-- Update status label
local function updateAutoDayFarmStatus()
    local phaseNames = {
        [0] = "Idle",
        [1] = "1: Bring Logic (5 logs)",
        [2] = "2: Map Crafting",
        [3] = "3: Map Loader",
        [4] = "4: Bring Logic (20 logs)",
        [5] = "5: Crafting",
        [6] = "6: Map Loader (2nd)",
        [7] = "7: Bring Logic (30 logs)",
        [8] = "8: Craft & Place Beds",
        [9] = "9: Lost Child Quest",
        [10] = "10: Idle at Campfire"
    }
    local statusText
    if autoDayFarmComplete and not autoDayFarmEnabled then
        statusText = "Complete"
    elseif autoDayFarmEnabled then
        statusText = phaseNames[autoDayFarmPhase] or "Unknown"
    else
        statusText = "Disabled"
    end
    autoDayFarmStatusLabel:SetTitle("Phase: " .. statusText)
end

-- Generic function to bring items by name to a position
-- Returns count of items brought
local function bringItemsTo(targetPos, itemNames, limit)
    limit = limit or math.huge
    local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
    local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
    local items = workspace:FindFirstChild("Items")
    
    local itemsBrought = 0
    
    if items then
        for _, item in ipairs(items:GetChildren()) do
            if itemsBrought >= limit then break end
            
            -- Check if item name matches any in the list
            local isMatch = false
            for _, itemName in pairs(itemNames) do
                if item.Name == itemName then
                    isMatch = true
                    break
                end
            end
            
            if isMatch and item:IsA("Model") then
                local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                
                if mainPart then
                    pcall(function()
                        if dragRemote then
                            dragRemote:FireServer(item)
                        end
                        mainPart.CFrame = CFrame.new(targetPos)
                    end)
                    itemsBrought = itemsBrought + 1
                end
            end
        end
    end
    
    return itemsBrought
end

-- Execute bring logic
-- Brings fuel items to campfire, ALL logs to scrapper, scraps to scrapper
local function executeBringLogic()
    local campfirePos = getCampfirePosition()
    local scrapperPos = getScrapperPosition()
    
    if not campfirePos or not scrapperPos then
        Window:Notify({Title = "Auto Day Farm", Desc = "Campfire or Scrapper not found!", Time = 2})
        return
    end
    
    -- 1. Bring all fuel items to campfire (NOT logs)
    local fuelsBrought = bringItemsTo(campfirePos, autoDayFarmFuelItems, math.huge)
    
    -- 2. Bring ALL logs to scrapper
    local logsBrought = bringItemsTo(scrapperPos, {"Log"}, math.huge)
    
    -- 3. Bring all scraps to scrapper
    local scrapsBrought = bringItemsTo(scrapperPos, autoDayFarmScrapItems, math.huge)
    
    -- Notify summary
    local summary = string.format(
        "Fuels→Fire: %d, Logs→Scrapper: %d, Scraps→Scrapper: %d",
        fuelsBrought, logsBrought, scrapsBrought
    )
    Window:Notify({Title = "Auto Day Farm", Desc = summary, Time = 2})
end

-- Forward declarations for phase functions
local runPhase3
local runPhase4
local runPhase5
local runPhase6
local runPhase7
local runPhase8
local runPhase9
local runPhase10

-- Forward declaration for Auto Stronghold (defined later in Quest Tab)
local autoStrongholdLoop
-- Note: autoStrongholdEnabled is declared earlier near waitForEnemiesCleared()

-- Phase 2 - Map Crafting & Placement
-- Crafts Map Blueprint and places it ~50 studs away from player
local function runPhase2()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 2 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 2 started: Map Crafting & Placement", Time = 2})
    updateAutoDayFarmStatus()
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Window:Notify({Title = "Auto Day Farm", Desc = "Error: Character not found!", Time = 3})
        -- Still advance to Phase 3
        if autoDayFarmEnabled then
            autoDayFarmPhase = 3
            updateAutoDayFarmStatus()
            task.spawn(runPhase3)
        end
        return
    end
    
    local hrp = character.HumanoidRootPart
    local pos = hrp.Position
    
    -- Step 1: Craft Map Blueprint via CraftItem:InvokeServer("Map")
    local craftSuccess = pcall(function()
        game:GetService("ReplicatedStorage").RemoteEvents.CraftItem:InvokeServer("Map")
    end)
    
    if not craftSuccess then
        Window:Notify({Title = "Auto Day Farm", Desc = "Error: Failed to craft Map Blueprint!", Time = 3})
        -- Continue to next phase even on failure
        if autoDayFarmEnabled then
            autoDayFarmPhase = 3
            updateAutoDayFarmStatus()
            Window:Notify({Title = "Auto Day Farm", Desc = "Skipping to Phase 3...", Time = 2})
            task.spawn(runPhase3)
        end
        return
    end
    
    task.wait(0.5) -- Wait for craft to register
    
    -- Step 2: Find the Map Blueprint in inventory or nil instances
    local mapBlueprint = GetFromInventory("Map Blueprint")
    if not mapBlueprint then
        mapBlueprint = GetNil("Map Blueprint")
    end
    
    if not mapBlueprint then
        Window:Notify({Title = "Auto Day Farm", Desc = "Error: Map Blueprint not found after crafting!", Time = 3})
        -- Continue to next phase even on failure
        if autoDayFarmEnabled then
            autoDayFarmPhase = 3
            updateAutoDayFarmStatus()
            Window:Notify({Title = "Auto Day Farm", Desc = "Skipping to Phase 3...", Time = 2})
            task.spawn(runPhase3)
        end
        return
    end
    
    -- Step 3: Place Map Blueprint ~50 studs away (West direction)
    local mapDistance = AutoDayFarmConfig.rodPlacementDistance or 50
    local placePos = pos + Vector3.new(-mapDistance, 0, 0) -- West direction
    
    local placeSuccess = pcall(function()
        replicatedStorage.RemoteEvents.RequestPlaceStructure:InvokeServer(
            mapBlueprint,
            {
                Valid = true,
                CFrame = CFrame.new(placePos.X, placePos.Y + 6, placePos.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                Position = Vector3.new(placePos.X, placePos.Y, placePos.Z)
            },
            CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
            nil
        )
    end)
    
    if placeSuccess then
        Window:Notify({Title = "Auto Day Farm", Desc = "Map Blueprint crafted and placed (West)!", Time = 2})
    else
        Window:Notify({Title = "Auto Day Farm", Desc = "Map crafted but failed to place!", Time = 3})
    end
    
    -- Advance to Phase 3
    if autoDayFarmEnabled then
        autoDayFarmPhase = 3
        updateAutoDayFarmStatus()
        Window:Notify({Title = "Auto Day Farm", Desc = "Phase 2 complete, advancing to Phase 3...", Time = 2})
        task.spawn(runPhase3)
    end
end

-- Get unlocked map radius based on boundaries
-- Returns the inner edge distance of the closest boundary wall
local function getUnlockedRadius()
    local map = workspace:FindFirstChild("Map")
    if not map then return nil end
    local boundaries = map:FindFirstChild("Boundaries")
    if not boundaries then return nil end
    
    local closestDist = math.huge
    local wallThickness = 40
    
    for _, child in pairs(boundaries:GetChildren()) do
        if child:IsA("BasePart") and child.Name == "Part" then
            local dist = math.sqrt(child.Position.X^2 + child.Position.Z^2)
            local innerEdge = dist - (wallThickness / 2)
            if innerEdge < closestDist then
                closestDist = innerEdge
            end
        end
    end
    
    return closestDist < math.huge and closestDist or nil
end

-- Generate spiral points for map loading
-- Returns array of CFrame positions in spiral pattern from center outward
local function generateSpiralPoints(maxRadius, visitHeight)
    local spiralGap = 30
    local spiralTurns = math.ceil(maxRadius / spiralGap)
    local pointsPerTurn = math.max(20, math.ceil((2 * math.pi * maxRadius / spiralTurns) / 20))
    local totalPoints = spiralTurns * pointsPerTurn
    
    local spiralPoints = {}
    for i = 0, totalPoints - 1 do
        local t = i / totalPoints
        local angle = t * spiralTurns * 2 * math.pi
        local radius = t * maxRadius
        local x = radius * math.cos(angle)
        local z = radius * math.sin(angle)
        table.insert(spiralPoints, CFrame.new(x, visitHeight, z))
    end
    
    return spiralPoints
end

-- Phase 3 - Map Loader
-- Flies in spiral pattern to load/render all map chunks
runPhase3 = function()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 3 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 3 started: Map Loader", Time = 2})
    updateAutoDayFarmStatus()
    
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Save camp position as return point (Requirement 3.1)
    local campPosition = hrp.CFrame
    
    -- Get unlocked radius (Requirement 3.4)
    local maxRadius = getUnlockedRadius()
    if not maxRadius or maxRadius < 50 then
        Window:Notify({Title = "Auto Day Farm", Desc = "Error: Could not determine map radius! Using default.", Time = 3})
        maxRadius = 500  -- Default fallback radius
    end
    
    -- Add buffer to ensure full coverage
    maxRadius = maxRadius + 200
    local groundY = campPosition.Position.Y
    local visitHeight = groundY + 20
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Map Loader: Radius " .. math.floor(maxRadius) .. " studs", Time = 2})
    
    -- Generate spiral points (Requirement 3.3)
    local spiralPoints = generateSpiralPoints(maxRadius, visitHeight)
    
    -- Enable noclip using central manager (Requirement 3.2)
    mapLoaderRunning = true
    setNoclip(true)
    
    -- Create flying physics
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.Parent = hrp
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    local currentTargetIndex = 1
    local speed = AutoDayFarmConfig.spiralSpeed or 300
    
    -- Movement loop - fly through spiral points
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        -- Check if map loader should stop
        if not mapLoaderRunning or not autoDayFarmEnabled then
            connection:Disconnect()
            return
        end
        
        -- Verify character still exists
        character = player.Character
        hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            connection:Disconnect()
            mapLoaderRunning = false
            return
        end
        
        local currentTarget = spiralPoints[currentTargetIndex]
        local direction = (currentTarget.Position - hrp.Position)
        local distance = direction.Magnitude
        
        -- Calculate velocity towards target
        local velocity = direction.Unit * math.min(speed, distance * 10)
        
        -- Apply velocity and rotation
        if bodyVelocity and bodyVelocity.Parent then
            bodyVelocity.Velocity = velocity
        end
        if bodyGyro and bodyGyro.Parent then
            bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
        end
        
        -- Check if reached current target
        if distance < 15 then
            currentTargetIndex = currentTargetIndex + 1
            
            -- Check if spiral complete
            if currentTargetIndex > #spiralPoints then
                connection:Disconnect()
                mapLoaderRunning = false
                
                -- Cleanup physics
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
                
                -- Disable noclip and restore collision (Requirement 3.6)
                setNoclip(false)
                
                -- Return to camp position (Requirement 3.5)
                task.wait(0.5)
                if hrp then
                    hrp.CFrame = campPosition
                end
                
                Window:Notify({Title = "Auto Day Farm", Desc = "Map Loader complete!", Time = 2})
                
                -- Advance to Phase 4
                if autoDayFarmEnabled then
                    autoDayFarmPhase = 4
                    updateAutoDayFarmStatus()
                    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 3 complete, advancing to Phase 4...", Time = 2})
                    -- Start Phase 4
                    task.spawn(runPhase4)
                end
            end
        end
    end)
    
    -- Wait until map loader completes or is stopped
    while mapLoaderRunning and autoDayFarmEnabled do
        task.wait(1)
    end
    
    -- Cleanup if stopped early
    if connection then connection:Disconnect() end
    if bodyVelocity and bodyVelocity.Parent then bodyVelocity:Destroy() end
    if bodyGyro and bodyGyro.Parent then bodyGyro:Destroy() end
    setNoclip(false)
    mapLoaderRunning = false
end

-- Phase 1 - Loop bringing items until scrapper has 5 logs, then advance to Phase 2
local function runPhase1()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 1 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 1: Bring loop until 5 logs", Time = 2})
    
    local campfirePos = getCampfirePosition()
    local scrapperPos = getScrapperPosition()
    
    if not campfirePos or not scrapperPos then
        Window:Notify({Title = "Auto Day Farm", Desc = "Campfire or Scrapper not found!", Time = 2})
        return
    end
    
    local threshold = AutoDayFarmConfig.phase1LogsToScrapper
    
    -- Loop until scrapper has enough logs
    while autoDayFarmEnabled and autoDayFarmPhase == 1 do
        -- Bring fuels to campfire (NOT logs)
        bringItemsTo(campfirePos, autoDayFarmFuelItems, math.huge)
        
        -- Bring scraps to scrapper
        bringItemsTo(scrapperPos, autoDayFarmScrapItems, math.huge)
        
        -- Bring ALL logs to scrapper
        bringItemsTo(scrapperPos, {"Log"}, math.huge)
        
        -- Check if scrapper has enough logs
        task.wait(1)
        local currentLogs = getScrapperLogCount()
        print("[Auto Day Farm] Phase 1 - Scrapper logs: " .. tostring(currentLogs) .. "/" .. tostring(threshold))
        
        if currentLogs >= threshold then
            Window:Notify({Title = "Auto Day Farm", Desc = "Scrapper has " .. currentLogs .. " logs!", Time = 2})
            break
        end
        
        task.wait(AutoDayFarmConfig.bringInterval)
    end
    
    -- Advance to Phase 2
    if autoDayFarmEnabled then
        autoDayFarmPhase = 2
        updateAutoDayFarmStatus()
        Window:Notify({Title = "Auto Day Farm", Desc = "Phase 1 complete, advancing to Phase 2...", Time = 2})
        task.spawn(runPhase2)
    end
end

-- Phase 4 - Loop bringing items until scrapper has 20 logs, then advance to Phase 5
runPhase4 = function()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 4 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 4: Bring loop until 20 logs", Time = 2})
    
    local campfirePos = getCampfirePosition()
    local scrapperPos = getScrapperPosition()
    
    if not campfirePos or not scrapperPos then
        Window:Notify({Title = "Auto Day Farm", Desc = "Campfire or Scrapper not found!", Time = 2})
        return
    end
    
    local threshold = AutoDayFarmConfig.phase4LogsToScrapper
    
    -- Loop until scrapper has enough logs
    while autoDayFarmEnabled and autoDayFarmPhase == 4 do
        -- Bring fuels to campfire (NOT logs)
        bringItemsTo(campfirePos, autoDayFarmFuelItems, math.huge)
        
        -- Bring scraps to scrapper
        bringItemsTo(scrapperPos, autoDayFarmScrapItems, math.huge)
        
        -- Bring ALL logs to scrapper
        bringItemsTo(scrapperPos, {"Log"}, math.huge)
        
        -- Check if scrapper has enough logs
        task.wait(1)
        local currentLogs = getScrapperLogCount()
        print("[Auto Day Farm] Phase 4 - Scrapper logs: " .. tostring(currentLogs) .. "/" .. tostring(threshold))
        
        if currentLogs >= threshold then
            Window:Notify({Title = "Auto Day Farm", Desc = "Scrapper has " .. currentLogs .. " logs!", Time = 2})
            break
        end
        
        task.wait(AutoDayFarmConfig.bringInterval)
    end
    
    -- Advance to Phase 5
    if autoDayFarmEnabled then
        autoDayFarmPhase = 5
        updateAutoDayFarmStatus()
        Window:Notify({Title = "Auto Day Farm", Desc = "Phase 4 complete, advancing to Phase 5...", Time = 2})
        task.spawn(runPhase5)
    end
end

-- Phase 5 - Crafting (Benches + Lightning Rods)
-- Crafts Bench 2 → Bench 3 → 4 Lightning Rods, then places Lightning Rods ~50 studs away
runPhase5 = function()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 5 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 5 started: Crafting (Benches + Lightning Rods)", Time = 2})
    updateAutoDayFarmStatus()
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Window:Notify({Title = "Auto Day Farm", Desc = "Error: Character not found!", Time = 3})
        return
    end
    
    local hrp = character.HumanoidRootPart
    local playerPos = hrp.Position
    
    -- Step 1: Craft Crafting Bench 2
    Window:Notify({Title = "Auto Day Farm", Desc = "Crafting Bench 2...", Time = 1})
    local bench2Success = pcall(function()
        game:GetService("ReplicatedStorage").RemoteEvents.CraftItem:InvokeServer("Crafting Bench 2")
    end)
    
    if not bench2Success then
        Window:Notify({Title = "Auto Day Farm", Desc = "Warning: Failed to craft Bench 2", Time = 2})
    else
        Window:Notify({Title = "Auto Day Farm", Desc = "Bench 2 crafted!", Time = 1})
    end
    
    task.wait(0.5) -- Wait between crafts
    
    -- Step 2: Craft Crafting Bench 3
    Window:Notify({Title = "Auto Day Farm", Desc = "Crafting Bench 3...", Time = 1})
    local bench3Success = pcall(function()
        game:GetService("ReplicatedStorage").RemoteEvents.CraftItem:InvokeServer("Crafting Bench 3")
    end)
    
    if not bench3Success then
        Window:Notify({Title = "Auto Day Farm", Desc = "Warning: Failed to craft Bench 3", Time = 2})
    else
        Window:Notify({Title = "Auto Day Farm", Desc = "Bench 3 crafted!", Time = 1})
    end
    
    task.wait(0.5) -- Wait between crafts
    
    -- Step 3: Craft 4 Lightning Rods
    local rodsCreated = 0
    for i = 1, 4 do
        Window:Notify({Title = "Auto Day Farm", Desc = "Crafting Lightning Rod " .. i .. "/4...", Time = 1})
        local rodSuccess = pcall(function()
            game:GetService("ReplicatedStorage").RemoteEvents.CraftItem:InvokeServer("Lightning Rod")
        end)
        
        if rodSuccess then
            rodsCreated = rodsCreated + 1
        else
            Window:Notify({Title = "Auto Day Farm", Desc = "Warning: Failed to craft Lightning Rod " .. i, Time = 2})
        end
        
        task.wait(0.5) -- Wait between crafts
    end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Crafted " .. rodsCreated .. "/4 Lightning Rods", Time = 2})
    
    -- Step 4: Place Lightning Rods ~50 studs away in N, S, E, W directions
    -- Calculate 4 positions spread around player
    local rodDistance = AutoDayFarmConfig.rodPlacementDistance or 50
    local directions = {
        {name = "North", offset = Vector3.new(0, 0, -rodDistance)},
        {name = "South", offset = Vector3.new(0, 0, rodDistance)},
        {name = "East", offset = Vector3.new(rodDistance, 0, 0)},
        {name = "West", offset = Vector3.new(-rodDistance, 0, 0)}
    }
    
    local rodsPlaced = 0
    for i, dir in ipairs(directions) do
        -- Wait for inventory to update before looking for next blueprint
        task.wait(0.5)
        
        -- Find Lightning Rod Blueprint in inventory or nil instances
        local rodBlueprint = nil
        local inventory = player:FindFirstChild("Inventory")
        if inventory then
            rodBlueprint = inventory:FindFirstChild("Lightning Rod Blueprint")
        end
        if not rodBlueprint then
            rodBlueprint = GetNil("Lightning Rod Blueprint")
        end
        
        if rodBlueprint then
            local targetPos = playerPos + dir.offset
            
            local placeSuccess = pcall(function()
                replicatedStorage.RemoteEvents.RequestPlaceStructure:InvokeServer(
                    rodBlueprint,
                    {
                        Valid = true,
                        CFrame = CFrame.new(targetPos.X, targetPos.Y + 6, targetPos.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                        Position = Vector3.new(targetPos.X, targetPos.Y, targetPos.Z)
                    },
                    CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                    nil
                )
            end)
            
            if placeSuccess then
                rodsPlaced = rodsPlaced + 1
                Window:Notify({Title = "Auto Day Farm", Desc = "Placed Lightning Rod " .. dir.name, Time = 1})
            else
                Window:Notify({Title = "Auto Day Farm", Desc = "Failed to place Lightning Rod " .. dir.name, Time = 2})
            end
            
            task.wait(0.5) -- Wait for placement to register before next
        else
            Window:Notify({Title = "Auto Day Farm", Desc = "No Lightning Rod Blueprint found for " .. dir.name, Time = 2})
        end
    end
    
    -- Phase 5 complete
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 5 complete! Placed " .. rodsPlaced .. "/4 Lightning Rods", Time = 3})
    
    -- Advance to Phase 6
    if autoDayFarmEnabled then
        autoDayFarmPhase = 6
        updateAutoDayFarmStatus()
        Window:Notify({Title = "Auto Day Farm", Desc = "Phase 5 complete, advancing to Phase 6...", Time = 2})
        task.spawn(runPhase6)
    end
end

-- Phase 6 - Map Loader (second run)
-- Flies in spiral pattern again to load newly unlocked map areas
runPhase6 = function()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 6 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 6 started: Map Loader (2nd run)", Time = 2})
    updateAutoDayFarmStatus()
    
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    
    -- Save camp position as return point
    local campPosition = hrp.CFrame
    
    -- Get unlocked radius
    local maxRadius = getUnlockedRadius()
    if not maxRadius or maxRadius < 50 then
        Window:Notify({Title = "Auto Day Farm", Desc = "Error: Could not determine map radius! Using default.", Time = 3})
        maxRadius = 500
    end
    
    -- Add buffer to ensure full coverage
    maxRadius = maxRadius + 200
    local groundY = campPosition.Position.Y
    local visitHeight = groundY + 20
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Map Loader: Radius " .. math.floor(maxRadius) .. " studs", Time = 2})
    
    -- Generate spiral points
    local spiralPoints = generateSpiralPoints(maxRadius, visitHeight)
    
    -- Enable noclip
    mapLoaderRunning = true
    setNoclip(true)
    
    -- Create flying physics
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.Parent = hrp
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    local currentTargetIndex = 1
    local speed = AutoDayFarmConfig.spiralSpeed or 300
    
    -- Movement loop
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not mapLoaderRunning or not autoDayFarmEnabled then
            connection:Disconnect()
            return
        end
        
        character = player.Character
        hrp = character and character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            connection:Disconnect()
            mapLoaderRunning = false
            return
        end
        
        local currentTarget = spiralPoints[currentTargetIndex]
        local direction = (currentTarget.Position - hrp.Position)
        local distance = direction.Magnitude
        
        local velocity = direction.Unit * math.min(speed, distance * 10)
        
        if bodyVelocity and bodyVelocity.Parent then
            bodyVelocity.Velocity = velocity
        end
        if bodyGyro and bodyGyro.Parent then
            bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
        end
        
        if distance < 15 then
            currentTargetIndex = currentTargetIndex + 1
            
            if currentTargetIndex > #spiralPoints then
                connection:Disconnect()
                mapLoaderRunning = false
                
                if bodyVelocity then bodyVelocity:Destroy() end
                if bodyGyro then bodyGyro:Destroy() end
                
                setNoclip(false)
                
                task.wait(0.5)
                if hrp then
                    hrp.CFrame = campPosition
                end
                
                Window:Notify({Title = "Auto Day Farm", Desc = "Map Loader (2nd run) complete!", Time = 2})
                
                -- Advance to Phase 7
                if autoDayFarmEnabled then
                    autoDayFarmPhase = 7
                    updateAutoDayFarmStatus()
                    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 6 complete, advancing to Phase 7...", Time = 2})
                    task.spawn(runPhase7)
                end
            end
        end
    end)
    
    -- Wait until map loader completes or is stopped
    while mapLoaderRunning and autoDayFarmEnabled do
        task.wait(1)
    end
    
    -- Cleanup if stopped early
    if connection then connection:Disconnect() end
    if bodyVelocity and bodyVelocity.Parent then bodyVelocity:Destroy() end
    if bodyGyro and bodyGyro.Parent then bodyGyro:Destroy() end
    setNoclip(false)
    mapLoaderRunning = false
end

-- Phase 7 - Bring Logic (30 logs)
-- Loop bringing items until scrapper has 30 logs, then complete
runPhase7 = function()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 7 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 7: Bring loop until 30 logs", Time = 2})
    
    local campfirePos = getCampfirePosition()
    local scrapperPos = getScrapperPosition()
    
    if not campfirePos or not scrapperPos then
        Window:Notify({Title = "Auto Day Farm", Desc = "Campfire or Scrapper not found!", Time = 2})
        return
    end
    
    local threshold = AutoDayFarmConfig.phase7LogsToScrapper
    
    -- Loop until scrapper has enough logs
    while autoDayFarmEnabled and autoDayFarmPhase == 7 do
        -- Bring fuels to campfire (NOT logs)
        bringItemsTo(campfirePos, autoDayFarmFuelItems, math.huge)
        
        -- Bring scraps to scrapper
        bringItemsTo(scrapperPos, autoDayFarmScrapItems, math.huge)
        
        -- Bring ALL logs to scrapper
        bringItemsTo(scrapperPos, {"Log"}, math.huge)
        
        -- Check if scrapper has enough logs
        task.wait(1)
        local currentLogs = getScrapperLogCount()
        print("[Auto Day Farm] Phase 7 - Scrapper logs: " .. tostring(currentLogs) .. "/" .. tostring(threshold))
        
        if currentLogs >= threshold then
            Window:Notify({Title = "Auto Day Farm", Desc = "Scrapper has " .. currentLogs .. " logs!", Time = 2})
            break
        end
        
        task.wait(AutoDayFarmConfig.bringInterval)
    end
    
    -- Advance to Phase 8
    if autoDayFarmEnabled then
        autoDayFarmPhase = 8
        updateAutoDayFarmStatus()
        Window:Notify({Title = "Auto Day Farm", Desc = "Phase 7 complete, advancing to Phase 8...", Time = 2})
        task.spawn(runPhase8)
    end
end

-- Phase 8 - Craft & Place Beds
-- Crafts Regular Bed, Good Bed, Old Bed and places them ~50 studs away
runPhase8 = function()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 8 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 8 started: Craft & Place Beds", Time = 2})
    updateAutoDayFarmStatus()
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        Window:Notify({Title = "Auto Day Farm", Desc = "Error: Character not found!", Time = 3})
        -- Still advance to Phase 9
        if autoDayFarmEnabled then
            autoDayFarmPhase = 9
            updateAutoDayFarmStatus()
            Window:Notify({Title = "Auto Day Farm", Desc = "Skipping to Phase 9...", Time = 2})
            task.spawn(runPhase9)
        end
        return
    end
    
    local hrp = character.HumanoidRootPart
    local pos = hrp.Position
    
    -- Beds to craft: Regular Bed, Good Bed, Old Bed
    local bedsToCraft = {"Regular Bed", "Good Bed", "Old Bed"}
    
    -- Step 1: Craft all beds
    for _, bedName in ipairs(bedsToCraft) do
        local craftSuccess = pcall(function()
            replicatedStorage.RemoteEvents.CraftItem:InvokeServer(bedName)
        end)
        
        if craftSuccess then
            Window:Notify({Title = "Auto Day Farm", Desc = "Crafted " .. bedName, Time = 1})
        else
            Window:Notify({Title = "Auto Day Farm", Desc = "Failed to craft " .. bedName, Time = 2})
        end
        task.wait(0.5)
    end
    
    task.wait(1)
    
    -- Step 2: Place beds ~50 studs away in different directions
    local bedDistance = AutoDayFarmConfig.rodPlacementDistance or 50
    local directions = {
        {name = "North", offset = Vector3.new(0, 0, -bedDistance)},
        {name = "East", offset = Vector3.new(bedDistance, 0, 0)},
        {name = "South", offset = Vector3.new(0, 0, bedDistance)}
    }
    
    -- Place each bed
    for i, bedName in ipairs(bedsToCraft) do
        -- Wait for inventory to update before looking for blueprint
        task.wait(0.5)
        
        local blueprintName = bedName .. " Blueprint"
        
        -- Fresh lookup each time
        local blueprint = nil
        local inventory = player:FindFirstChild("Inventory")
        if inventory then
            blueprint = inventory:FindFirstChild(blueprintName)
        end
        if not blueprint then
            -- Fallback to nil instances
            for _, obj in pairs(getnilinstances()) do
                if obj.Name == blueprintName then
                    blueprint = obj
                    break
                end
            end
        end
        
        if blueprint then
            local dir = directions[i]
            if dir then
                local placePos = pos + dir.offset
                
                local placeSuccess = pcall(function()
                    replicatedStorage.RemoteEvents.RequestPlaceStructure:InvokeServer(
                        blueprint,
                        {
                            Valid = true,
                            CFrame = CFrame.new(placePos.X, placePos.Y + 3, placePos.Z, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                            Position = Vector3.new(placePos.X, placePos.Y, placePos.Z)
                        },
                        CFrame.new(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
                        nil
                    )
                end)
                
                if placeSuccess then
                    Window:Notify({Title = "Auto Day Farm", Desc = "Placed " .. bedName .. " (" .. dir.name .. ")", Time = 1})
                else
                    Window:Notify({Title = "Auto Day Farm", Desc = "Failed to place " .. bedName, Time = 2})
                end
            end
        else
            Window:Notify({Title = "Auto Day Farm", Desc = blueprintName .. " not found!", Time = 2})
        end
        task.wait(0.5)
    end
    
    -- Advance to Phase 9
    if autoDayFarmEnabled then
        autoDayFarmPhase = 9
        updateAutoDayFarmStatus()
        Window:Notify({Title = "Auto Day Farm", Desc = "Phase 8 complete, advancing to Phase 9...", Time = 2})
        task.spawn(runPhase9)
    end
end

-- Phase 9 - Lost Child Quest
-- Rescues all available lost children and brings them back to camp
runPhase9 = function()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 9 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 9 started: Lost Child Quest", Time = 2})
    updateAutoDayFarmStatus()
    
    -- Lost child names mapping
    local lostChildNamesPhase9 = {
        ["Lost Child 1"] = "Lost Child",
        ["Lost Child 2"] = "Lost Child2",
        ["Lost Child 3"] = "Lost Child3",
        ["Lost Child 4"] = "Lost Child4",
    }
    
    -- Helper function to get all available Lost Children
    local function getAvailableLostChildrenPhase9()
        local children = {}
        local characters = workspace:FindFirstChild("Characters")
        if not characters then return children end
        
        for name, childName in pairs(lostChildNamesPhase9) do
            local child = characters:FindFirstChild(childName)
            if child then
                table.insert(children, {displayName = name, modelName = childName, model = child})
            end
        end
        
        return children
    end
    
    -- Helper function to find and equip a sack
    local function equipSackPhase9()
        local inventory = player:FindFirstChild("Inventory")
        if not inventory then return false end
        
        local sackNames = {"Sack", "Large Sack", "Small Sack"}
        local sack = nil
        
        for _, sackName in ipairs(sackNames) do
            sack = inventory:FindFirstChild(sackName)
            if sack then break end
        end
        
        if not sack then
            for _, item in pairs(inventory:GetChildren()) do
                if item.Name:find("Sack") then
                    sack = item
                    break
                end
            end
        end
        
        if not sack then
            return false, "No sack found"
        end
        
        if equipItemRemote then
            pcall(function()
                equipItemRemote:FireServer("FireAllClients", sack)
            end)
            task.wait(0.3)
            return true, sack.Name
        end
        
        return false, "Equip remote not found"
    end
    
    -- Get available children
    local availableChildren = getAvailableLostChildrenPhase9()
    if #availableChildren == 0 then
        Window:Notify({Title = "Auto Day Farm", Desc = "No Lost Children found, skipping...", Time = 2})
        -- Advance to Phase 10
        if autoDayFarmEnabled then
            autoDayFarmPhase = 10
            updateAutoDayFarmStatus()
            Window:Notify({Title = "Auto Day Farm", Desc = "Phase 9 complete, advancing to Phase 10...", Time = 2})
            task.spawn(runPhase10)
        end
        return
    end
    
    -- Auto-equip sack
    local equipped, sackInfo = equipSackPhase9()
    if equipped then
        Window:Notify({Title = "Auto Day Farm", Desc = "Equipped " .. sackInfo .. "!", Time = 2})
    else
        Window:Notify({Title = "Auto Day Farm", Desc = "Could not equip sack, trying anyway...", Time = 2})
    end
    task.wait(0.5)
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Found " .. #availableChildren .. " children to rescue!", Time = 2})
    
    local pickedUp = 0
    
    -- Step 1: Pick up all children
    for i, childData in ipairs(availableChildren) do
        if not autoDayFarmEnabled or autoDayFarmPhase ~= 9 then break end
        
        local lostChild = workspace.Characters:FindFirstChild(childData.modelName)
        if not lostChild then
            Window:Notify({Title = "Auto Day Farm", Desc = childData.displayName .. " no longer exists, skipping...", Time = 2})
        else
            local targetPart = lostChild:FindFirstChild("HumanoidRootPart") or lostChild.PrimaryPart or lostChild:FindFirstChildWhichIsA("BasePart")
            if not targetPart then
                Window:Notify({Title = "Auto Day Farm", Desc = "Could not find " .. childData.displayName .. " position, skipping...", Time = 2})
            else
                Window:Notify({Title = "Auto Day Farm", Desc = "(" .. i .. "/" .. #availableChildren .. ") Flying to " .. childData.displayName .. "...", Time = 2})
                smoothFlyTo(targetPart.CFrame + Vector3.new(0, 3, 0), nil, function() return not autoDayFarmEnabled or autoDayFarmPhase ~= 9 end)
                task.wait(1)
                
                if autoDayFarmEnabled and autoDayFarmPhase == 9 then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
                    end
                    task.wait(0.5)
                    
                    local prompt = lostChild:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        Window:Notify({Title = "Auto Day Farm", Desc = "Picking up " .. childData.displayName .. "...", Time = 2})
                        fireproximityprompt(prompt, 0)
                        pickedUp = pickedUp + 1
                        task.wait(0.5)
                    else
                        Window:Notify({Title = "Auto Day Farm", Desc = "No prompt found for " .. childData.displayName .. ", skipping...", Time = 2})
                    end
                end
            end
        end
    end
    
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 9 then
        return
    end
    
    -- Step 2: Fly back to camp
    Window:Notify({Title = "Auto Day Farm", Desc = "Returning to camp with " .. pickedUp .. " children...", Time = 2})
    smoothFlyTo(CFrame.new(0, 10, 0), nil, function() return not autoDayFarmEnabled or autoDayFarmPhase ~= 9 end)
    task.wait(1)
    
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 9 then
        return
    end
    
    -- Step 3: Release all children using remote
    Window:Notify({Title = "Auto Day Farm", Desc = "Releasing all children...", Time = 2})
    
    local bagDropRemote = replicatedStorage.RemoteEvents:FindFirstChild("RequestBagDropItem")
    local itemBag = player:FindFirstChild("ItemBag")
    local inventory = player:FindFirstChild("Inventory")
    
    local sack = nil
    if inventory then
        for _, item in pairs(inventory:GetChildren()) do
            if item.Name:find("Sack") then
                sack = item
                break
            end
        end
    end
    
    if sack and itemBag and bagDropRemote then
        for _, item in pairs(itemBag:GetChildren()) do
            pcall(function()
                bagDropRemote:FireServer(sack, item, true)
            end)
            task.wait(0.3)
        end
    end
    task.wait(1)
    
    Window:Notify({Title = "Auto Day Farm", Desc = pickedUp .. " children rescued!", Time = 3})
    
    -- Advance to Phase 10
    if autoDayFarmEnabled then
        autoDayFarmPhase = 10
        updateAutoDayFarmStatus()
        Window:Notify({Title = "Auto Day Farm", Desc = "Phase 9 complete, advancing to Phase 10...", Time = 2})
        task.spawn(runPhase10)
    end
end

-- Phase 10 - Idle at Campfire
-- Stays at campfire indefinitely
runPhase10 = function()
    if not autoDayFarmEnabled or autoDayFarmPhase ~= 10 then return end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Phase 10: Idling at campfire", Time = 3})
    updateAutoDayFarmStatus()
    
    -- Teleport to campfire
    local campfirePos = getCampfirePosition()
    local character = player.Character
    if character and character:FindFirstChild("HumanoidRootPart") then
        character.HumanoidRootPart.CFrame = CFrame.new(campfirePos)
    end
    
    Window:Notify({Title = "Auto Day Farm", Desc = "Day farm complete! Idling at campfire.", Time = 3})
    
    -- Idle loop - just stay at campfire
    while autoDayFarmEnabled and autoDayFarmPhase == 10 do
        task.wait(5)
    end
    
    if not autoDayFarmEnabled then
        Window:Notify({Title = "Auto Day Farm", Desc = "Stopped", Time = 2})
    end
end

-- Auto Day Farm Toggle
AutoTab:Toggle({
    Title = "Auto Day Farm",
    Desc = "Automated 10-phase day farming system",
    Value = false,
    Callback = function(v)
        autoDayFarmEnabled = v
        if v then
            autoDayFarmPhase = 1
            autoDayFarmComplete = false  -- Reset complete flag on new session
            updateAutoDayFarmStatus()
            -- Start Phase 1 in a separate thread
            task.spawn(runPhase1)
        else
            autoDayFarmPhase = 0
            updateAutoDayFarmStatus()
            Window:Notify({Title = "Auto Day Farm", Desc = "Stopped", Time = 2})
        end
    end
})

-- Skip to Next Phase Button (for advancing from Phase 1 or Phase 4)
AutoTab:Button({
    Title = "Skip to Next Phase",
    Desc = "Advance to the next phase (Phase 1→2, Phase 4→5)",
    Callback = function()
        if not autoDayFarmEnabled then
            Window:Notify({Title = "Auto Day Farm", Desc = "Auto Day Farm is not running!", Time = 2})
            return
        end
        
        if autoDayFarmPhase == 1 then
            -- Advance from Phase 1 to Phase 2
            autoDayFarmPhase = 2
            updateAutoDayFarmStatus()
            Window:Notify({Title = "Auto Day Farm", Desc = "Skipping to Phase 2: Map Crafting", Time = 2})
            task.spawn(runPhase2)
        elseif autoDayFarmPhase == 4 then
            -- Advance from Phase 4 to Phase 5
            autoDayFarmPhase = 5
            updateAutoDayFarmStatus()
            Window:Notify({Title = "Auto Day Farm", Desc = "Skipping to Phase 5: Crafting", Time = 2})
            task.spawn(runPhase5)
        else
            Window:Notify({Title = "Auto Day Farm", Desc = "Cannot skip from Phase " .. autoDayFarmPhase, Time = 2})
        end
    end
})

-- Create Event Tab
local EventTab = Window:Tab({Title = "Event", Icon = "calendar"})

Window:Line()

EventTab:Section({Title = "Event Features"})

EventTab:Button({
    Title = "Teleport to Fairy Tree",
    Desc = "Teleports you to the Fairy Tree",
    Callback = function()
        local success, err = pcall(function()
            local fairyTree = workspace.Map.Landmarks["Fairy Tree"].FairyTree
            if fairyTree then
                local targetPart = fairyTree.PrimaryPart or fairyTree:FindFirstChildWhichIsA("BasePart")
                if targetPart then
                    local character = player.Character
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 10, 0)
                        Window:Notify({Title = "Teleport", Desc = "Teleported to Fairy Tree!", Time = 2})
                    end
                end
            end
        end)
        
        if not success then
            Window:Notify({Title = "Error", Desc = "Fairy Tree not found!", Time = 3})
        end
    end
})

-- Event Items
local selectedEventItems = {}

EventTab:Dropdown({
    Title = "Select Event Items",
    List = {"Acorn"},
    Multi = true,
    Value = {},
    Callback = function(selected)
        selectedEventItems = selected
    end
})

EventTab:Button({
    Title = "Bring Selected Items",
    Desc = "Teleports selected event items to your position",
    Callback = function()
        if #selectedEventItems == 0 then
            Window:Notify({Title = "Error", Desc = "Please select at least one item!", Time = 2})
            return
        end
        
        local character = player.Character
        if not character or not character:FindFirstChild("HumanoidRootPart") then
            Window:Notify({Title = "Error", Desc = "Character not found!", Time = 2})
            return
        end
        
        local targetPos = character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                local isSelected = false
                for _, itemName in pairs(selectedEventItems) do
                    if item.Name == itemName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3)))
                        end)
                    end
                end
            end
        end
        
        Window:Notify({Title = "Bring Items", Desc = "Brought " .. itemsBrought .. " items!", Time = 2})
    end
})

-- Create Quest Tab
local QuestTab = Window:Tab({Title = "Quest", Icon = "scroll"})

Window:Line()

-- Map Loader Section
QuestTab:Section({Title = "Map Loader"})

-- Note: mapLoaderRunning is shared with Auto Day Farm phases (declared earlier)
local mapLoaderSpeed = 0.2

QuestTab:Slider({
    Title = "Map Loader Speed",
    Min = 0.1,
    Max = 1.0,
    Rounding = 2,
    Value = 0.5,
    Callback = function(val)
        mapLoaderSpeed = val
    end
})

QuestTab:Toggle({
    Title = "Auto Map Loader",
    Value = false,
    Callback = function(v)
        mapLoaderRunning = v
        if v then
            Window:Notify({
                Title = "Map Loader",
                Desc = "Starting spiral map loader...",
                Time = 3
            })
            task.spawn(spiralMapLoader)
        else
            Window:Notify({
                Title = "Map Loader",
                Desc = "Map loader stopped",
                Time = 2
            })
        end
    end
})

-- Spiral Map Loader Function
function spiralMapLoader()
    local player = game:GetService("Players").LocalPlayer
    
    -- Wait for character
    local character = player.Character or player.CharacterAdded:Wait()
    local hrp = character:WaitForChild("HumanoidRootPart")
    local humanoid = character:WaitForChild("Humanoid")
    
    -- Save starting position (camp)
    local campPosition = hrp.CFrame
    
    Window:Notify({
        Title = "Map Loader",
        Desc = "Scanning boundaries...",
        Time = 2
    })
    
    -- Function to get unlocked radius (closest boundary to center)
    local function getUnlockedRadius()
        local map = workspace:FindFirstChild("Map")
        if not map then return nil end
        
        local boundaries = map:FindFirstChild("Boundaries")
        if not boundaries then return nil end
        
        local centerX, centerZ = 0, 0
        local closestDist = math.huge
        local wallThickness = 40 -- Boundary parts are ~40 studs wide
        
        for _, child in pairs(boundaries:GetChildren()) do
            if child:IsA("BasePart") and child.Name == "Part" then
                local dist = math.sqrt((child.Position.X - centerX)^2 + (child.Position.Z - centerZ)^2)
                -- The inner edge of the wall is the part position minus half the wall thickness
                local innerEdge = dist - (wallThickness / 2)
                if innerEdge < closestDist then
                    closestDist = innerEdge
                end
            end
        end
        
        return closestDist < math.huge and closestDist or nil
    end
    
    -- Get initial unlocked radius
    local maxRadius = getUnlockedRadius()
    if not maxRadius or maxRadius < 50 then
        Window:Notify({
            Title = "Error",
            Desc = "Could not determine map radius!",
            Time = 3
        })
        mapLoaderRunning = false
        return
    end
    
    -- Add buffer to ensure full coverage
    maxRadius = maxRadius + 200
    
    local groundY = campPosition.Y
    local visitHeight = groundY + 20
    local centerX, centerZ = 0, 0
    
    Window:Notify({
        Title = "Map Loader",
        Desc = "Unlocked radius: " .. math.floor(maxRadius) .. " studs",
        Time = 2
    })
    
    -- Calculate spiral parameters based on radius
    -- Gap between spiral arms should be ~30 studs for good coverage
    local spiralGap = 30
    local spiralTurns = math.ceil(maxRadius / spiralGap)
    local pointsPerTurn = math.ceil((2 * math.pi * maxRadius / spiralTurns) / 20) -- Point every ~20 studs on outer ring
    pointsPerTurn = math.max(20, pointsPerTurn) -- Minimum 20 points per turn
    local totalPoints = spiralTurns * pointsPerTurn
    
    Window:Notify({
        Title = "Map Loader",
        Desc = "Spiral: " .. spiralTurns .. " turns, " .. totalPoints .. " points",
        Time = 2
    })
    
    local visitedCount = 0
    local currentTargetIndex = 0
    
    -- Pre-calculate spiral points
    local spiralPoints = {}
    for i = 0, totalPoints - 1 do
        local t = i / totalPoints
        local angle = t * spiralTurns * 2 * math.pi
        local radius = t * maxRadius
        
        local x = centerX + radius * math.cos(angle)
        local z = centerZ + radius * math.sin(angle)
        
        table.insert(spiralPoints, CFrame.new(x, visitHeight, z))
    end
    
    -- Enable noclip
    local noclipConnection
    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
        if not mapLoaderRunning then
            if noclipConnection then noclipConnection:Disconnect() end
            return
        end
        
        character = player.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    -- Create flying physics
    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.P = 9e4
    bodyGyro.Parent = hrp
    
    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp
    
    currentTargetIndex = 1
    local currentTarget = spiralPoints[currentTargetIndex]
    
    -- Movement loop
    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        if not mapLoaderRunning then
            if connection then connection:Disconnect() end
            return
        end
        
        character = player.Character
        if not character then
            if connection then connection:Disconnect() end
            return
        end
        
        hrp = character:FindFirstChild("HumanoidRootPart")
        if not hrp then
            if connection then connection:Disconnect() end
            return
        end
        
        local direction = (currentTarget.Position - hrp.Position)
        local distance = direction.Magnitude
        
        local speed = 100 + (mapLoaderSpeed * 400)
        local velocity = direction.Unit * math.min(speed, distance * 10)
        
        if bodyVelocity and bodyVelocity.Parent then
            bodyVelocity.Velocity = velocity
        end
        
        if bodyGyro and bodyGyro.Parent then
            bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + direction)
        end
        
        if distance < 15 then
            currentTargetIndex = currentTargetIndex + 1
            
            if currentTargetIndex > #spiralPoints then
                -- Finished - check if boundaries expanded
                local newRadius = getUnlockedRadius()
                if newRadius and newRadius > maxRadius + 30 then
                    -- Boundaries expanded! Add more points
                    Window:Notify({
                        Title = "Map Loader",
                        Desc = "Boundaries expanded! Continuing...",
                        Time = 2
                    })
                    
                    local oldRadius = maxRadius
                    maxRadius = newRadius
                    
                    -- Add more spiral points for expanded area
                    local extraTurns = math.ceil((maxRadius - oldRadius) / 30)
                    local extraPointsPerTurn = pointsPerTurn
                    
                    for i = 1, extraTurns * extraPointsPerTurn do
                        local t = i / (extraTurns * extraPointsPerTurn)
                        local angle = t * extraTurns * 2 * math.pi
                        local radius = oldRadius + (t * (maxRadius - oldRadius))
                        
                        local x = centerX + radius * math.cos(angle)
                        local z = centerZ + radius * math.sin(angle)
                        
                        table.insert(spiralPoints, CFrame.new(x, visitHeight, z))
                    end
                    
                    totalPoints = #spiralPoints
                    currentTarget = spiralPoints[currentTargetIndex]
                else
                    -- Done!
                    if connection then connection:Disconnect() end
                    if noclipConnection then noclipConnection:Disconnect() end
                    mapLoaderRunning = false
                    
                    character = player.Character
                    if character then
                        for _, part in pairs(character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = true
                            end
                        end
                    end
                    
                    if bodyVelocity then bodyVelocity:Destroy() end
                    if bodyGyro then bodyGyro:Destroy() end
                    
                    Window:Notify({
                        Title = "Map Loader",
                        Desc = "Complete! Returning to camp...",
                        Time = 2
                    })
                    
                    task.wait(1)
                    smoothFlyTo(campPosition)
                    
                    Window:Notify({
                        Title = "Map Loader",
                        Desc = "Map fully loaded!",
                        Time = 3
                    })
                    return
                end
            else
                currentTarget = spiralPoints[currentTargetIndex]
                visitedCount = visitedCount + 1
                
                if visitedCount % 50 == 0 then
                    local progress = math.floor((visitedCount / totalPoints) * 100)
                    Window:Notify({
                        Title = "Map Loader",
                        Desc = progress .. "% (" .. visitedCount .. "/" .. totalPoints .. ")",
                        Time = 1
                    })
                end
            end
        end
    end)
    
    -- Wait until finished or stopped
    while mapLoaderRunning do
        task.wait(1)
    end
    
    -- Cleanup if stopped early
    if connection then
        connection:Disconnect()
    end
    if noclipConnection then
        noclipConnection:Disconnect()
    end
    if bodyVelocity then
        bodyVelocity:Destroy()
    end
    if bodyGyro then
        bodyGyro:Destroy()
    end
    
    -- Re-enable collision when stopped
    character = player.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end

QuestTab:Section({Title = "Lost Child Quest"})

-- Lost Child Quest System (New)
local lostChildNames = {
    ["Lost Child 1"] = "Lost Child",
    ["Lost Child 2"] = "Lost Child2",
    ["Lost Child 3"] = "Lost Child3",
    ["Lost Child 4"] = "Lost Child4",
}

-- Status Label (Combined)
local lostChildStatusLabel = QuestTab:Label({
    Title = "Checking..."
})

-- Update Lost Child Status Loop
task.spawn(function()
    while ScriptState.loopsRunning do
        task.wait(1)
        
        local child1 = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Lost Child")
        local child2 = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Lost Child2")
        local child3 = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Lost Child3")
        local child4 = workspace:FindFirstChild("Characters") and workspace.Characters:FindFirstChild("Lost Child4")
        
        local status1 = child1 and "Spawned" or "Not Spawned"
        local status2 = child2 and "Spawned" or "Not Spawned"
        local status3 = child3 and "Spawned" or "Not Spawned"
        local status4 = child4 and "Spawned" or "Not Spawned"
        
        lostChildStatusLabel:SetTitle("Dino Kid: " .. status1 .. "\nKraken Kid: " .. status2 .. "\nSquid Kid: " .. status3 .. "\nKoala Kid: " .. status4)
    end
end)

-- Helper function to get all available Lost Children
local function getAvailableLostChildren()
    local children = {}
    local characters = workspace:FindFirstChild("Characters")
    if not characters then return children end
    
    for name, childName in pairs(lostChildNames) do
        local child = characters:FindFirstChild(childName)
        if child then
            table.insert(children, {displayName = name, modelName = childName, model = child})
        end
    end
    
    return children
end

-- Helper function to find and equip a sack
local function equipSack()
    local inventory = player:FindFirstChild("Inventory")
    if not inventory then return false end
    
    -- Look for any sack in inventory
    local sackNames = {"Sack", "Large Sack", "Small Sack"}
    local sack = nil
    
    for _, sackName in ipairs(sackNames) do
        sack = inventory:FindFirstChild(sackName)
        if sack then break end
    end
    
    -- Fallback: find anything with "Sack" in name
    if not sack then
        for _, item in pairs(inventory:GetChildren()) do
            if item.Name:find("Sack") then
                sack = item
                break
            end
        end
    end
    
    if not sack then
        return false, "No sack found in inventory"
    end
    
    -- Equip the sack using the remote
    if equipItemRemote then
        pcall(function()
            equipItemRemote:FireServer("FireAllClients", sack)
        end)
        task.wait(0.3)
        return true, sack.Name
    end
    
    return false, "Equip remote not found"
end

-- Helper function to simulate F key press (drop from sack)
-- Using unified simulateFKeyPress() defined at top of script

-- Rescue All Children Button
-- Auto Rescue Toggle
local autoRescueEnabled = false

QuestTab:Toggle({
    Title = "Rescue All Lost Children",
    Value = false,
    Callback = function(v)
        autoRescueEnabled = v
        if v then
            task.spawn(function()
                -- Get available children
                local availableChildren = getAvailableLostChildren()
                if #availableChildren == 0 then
                    Window:Notify({Title = "Error", Desc = "No Lost Children found!", Time = 3})
                    autoRescueEnabled = false
                    return
                end
                
                -- Auto-equip sack
                local equipped, sackInfo = equipSack()
                if equipped then
                    Window:Notify({Title = "Auto Rescue", Desc = "Equipped " .. sackInfo .. "!", Time = 2})
                else
                    Window:Notify({Title = "Warning", Desc = sackInfo or "Could not equip sack, trying anyway...", Time = 2})
                end
                task.wait(0.5)
                
                if not autoRescueEnabled then return end
                
                Window:Notify({Title = "Auto Rescue", Desc = "Found " .. #availableChildren .. " children to rescue!", Time = 2})
                
                local pickedUp = 0
                
                -- Step 1: Pick up all children
                for i, childData in ipairs(availableChildren) do
                    if not autoRescueEnabled then break end
                    
                    local lostChild = workspace.Characters:FindFirstChild(childData.modelName)
                    if not lostChild then
                        Window:Notify({Title = "Auto Rescue", Desc = childData.displayName .. " no longer exists, skipping...", Time = 2})
                    else
                        local targetPart = lostChild:FindFirstChild("HumanoidRootPart") or lostChild.PrimaryPart or lostChild:FindFirstChildWhichIsA("BasePart")
                        if not targetPart then
                            Window:Notify({Title = "Auto Rescue", Desc = "Could not find " .. childData.displayName .. " position, skipping...", Time = 2})
                        else
                            Window:Notify({Title = "Auto Rescue", Desc = "(" .. i .. "/" .. #availableChildren .. ") Flying to " .. childData.displayName .. "...", Time = 2})
                            smoothFlyTo(targetPart.CFrame + Vector3.new(0, 3, 0), nil, function() return not autoRescueEnabled end)
                            task.wait(1)
                            
                            if autoRescueEnabled then
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    character.HumanoidRootPart.CFrame = targetPart.CFrame + Vector3.new(0, 2, 0)
                                end
                                task.wait(0.5)
                                
                                local prompt = lostChild:FindFirstChildWhichIsA("ProximityPrompt", true)
                                if prompt then
                                    Window:Notify({Title = "Auto Rescue", Desc = "Picking up " .. childData.displayName .. "...", Time = 2})
                                    fireproximityprompt(prompt, 0)
                                    pickedUp = pickedUp + 1
                                    task.wait(0.5)
                                else
                                    Window:Notify({Title = "Auto Rescue", Desc = "No prompt found for " .. childData.displayName .. ", skipping...", Time = 2})
                                end
                            end
                        end
                    end
                end
                
                if not autoRescueEnabled then
                    Window:Notify({Title = "Auto Rescue", Desc = "Stopped!", Time = 2})
                    return
                end
                
                if pickedUp == 0 then
                    Window:Notify({Title = "Auto Rescue", Desc = "No children were picked up!", Time = 3})
                    autoRescueEnabled = false
                    return
                end
                
                -- Step 2: Fly back to camp
                Window:Notify({Title = "Auto Rescue", Desc = "Returning to camp with " .. pickedUp .. " children...", Time = 2})
                smoothFlyTo(CFrame.new(0, 10, 0), nil, function() return not autoRescueEnabled end)
                task.wait(1)
                
                if not autoRescueEnabled then
                    Window:Notify({Title = "Auto Rescue", Desc = "Stopped!", Time = 2})
                    return
                end
                
                -- Step 3: Release all children using remote
                Window:Notify({Title = "Auto Rescue", Desc = "Releasing all children...", Time = 2})
                
                local bagDropRemote = replicatedStorage.RemoteEvents:FindFirstChild("RequestBagDropItem")
                local itemBag = player:FindFirstChild("ItemBag")
                local inventory = player:FindFirstChild("Inventory")
                
                local sack = nil
                if inventory then
                    for _, item in pairs(inventory:GetChildren()) do
                        if item.Name:find("Sack") then
                            sack = item
                            break
                        end
                    end
                end
                
                if sack and itemBag and bagDropRemote then
                    for _, item in pairs(itemBag:GetChildren()) do
                        pcall(function()
                            bagDropRemote:FireServer(sack, item, true)
                        end)
                        task.wait(0.3)
                    end
                end
                task.wait(1)
                
                Window:Notify({Title = "Auto Rescue", Desc = pickedUp .. " children rescued!", Time = 3})
                autoRescueEnabled = false
            end)
        end
    end
})

QuestTab:Section({Title = "Auto Stronghold"})

-- Auto Stronghold Variables (autoStrongholdEnabled declared earlier for Phase 10)
local safeZoneWaitTime = 110 -- Default 1 minute 50 seconds

-- Timer Display
local timerLabel = QuestTab:Label({
    Title = "Stronghold Timer",
    Desc = "Waiting for timer..."
})

-- Level Display
local levelLabel = QuestTab:Label({
    Title = "Level: Not in stronghold"
})

-- Store current timer text for detection
local currentTimerText = ""

-- Update timer and level continuously
task.spawn(function()
    while ScriptState.loopsRunning do
        task.wait(0.5)
        local success, result = pcall(function()
            local sign = workspace.Map.Landmarks.Stronghold.Functional.Sign
            local timeText = ""
            local levelText = ""
            
            for _, gui in pairs(sign:GetChildren()) do
                if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                    for _, label in pairs(gui:GetDescendants()) do
                        if label:IsA("TextLabel") then
                            if label.Text:find("m") or label.Text:find("s") then
                                timeText = label.Text
                            elseif label.Text:find("LEVEL") then
                                levelText = label.Text
                            end
                        end
                    end
                end
            end
            
            return timeText, levelText
        end)
        
        if success and result then
            local timeText, levelText = result, select(2, pcall(function()
                local sign = workspace.Map.Landmarks.Stronghold.Functional.Sign
                for _, gui in pairs(sign:GetChildren()) do
                    if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                        for _, label in pairs(gui:GetDescendants()) do
                            if label:IsA("TextLabel") and label.Text:find("LEVEL") then
                                return label.Text
                            end
                        end
                    end
                end
            end))
            
            pcall(function()
                local sign = workspace.Map.Landmarks.Stronghold.Functional.Sign
                for _, gui in pairs(sign:GetChildren()) do
                    if gui:IsA("BillboardGui") or gui:IsA("SurfaceGui") then
                        for _, label in pairs(gui:GetDescendants()) do
                            if label:IsA("TextLabel") then
                                if label.Text:find("m") or label.Text:find("s") then
                                    currentTimerText = label.Text -- Store for detection
                                    timerLabel:SetTitle("Time Remaining: " .. label.Text)
                                elseif label.Text:find("LEVEL") then
                                    levelLabel:SetTitle(label.Text)
                                end
                            end
                        end
                    end
                end
            end)
        else
            currentTimerText = ""
            timerLabel:SetTitle("Stronghold Timer: Not Active")
            levelLabel:SetTitle("Level: Not in stronghold")
        end
    end
end)

-- Find floor part by size (used by auto stronghold)
local function findFloorPartBySize(targetSize, tolerance)
    tolerance = tolerance or 0.3 -- Tighter tolerance to distinguish 57.6 from 57.2
    local floor = workspace.Map.Landmarks.Stronghold.Building.Floor
    for _, part in pairs(floor:GetChildren()) do
        if part:IsA("BasePart") then
            local size = part.Size
            if math.abs(size.X - targetSize.X) < tolerance and
               math.abs(size.Y - targetSize.Y) < tolerance and
               math.abs(size.Z - targetSize.Z) < tolerance then
                return part
            end
        end
    end
    return nil
end

-- Safe Zone Wait Time Slider
QuestTab:Slider({
    Title = "Safe Zone Wait Time",
    Min = 10,
    Max = 150,
    Rounding = 0,
    Value = 110,
    Callback = function(val)
        safeZoneWaitTime = val
    end
})

-- Auto Stronghold Toggle
QuestTab:Toggle({
    Title = "Auto Stronghold",
    Desc = "Pavement > Walk floors > Safe zone > Wait > Floor 3",
    Value = false,
    Callback = function(v)
        autoStrongholdEnabled = v
        if v then
            Window:Notify({
                Title = "Auto Stronghold",
                Desc = "Starting auto stronghold...",
                Time = 3
            })
            task.spawn(autoStrongholdLoop)
        end
    end
})

-- Noclip walk function for auto stronghold
local function noclipWalkTo(targetCFrame, speed)
    local character = player.Character
    if not character then return end
    local hrp = character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local startPos = hrp.Position
    local targetPos = Vector3.new(targetCFrame.Position.X, targetCFrame.Position.Y + 3, targetCFrame.Position.Z)
    local distance = (targetPos - startPos).Magnitude
    speed = speed or 50
    local duration = distance / speed
    local steps = math.max(1, math.ceil(duration * 30))
    
    -- Enable noclip during walk
    local noclipConn
    noclipConn = game:GetService("RunService").Stepped:Connect(function()
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    for i = 1, steps do
        if not autoStrongholdEnabled then break end
        local alpha = i / steps
        local newPos = startPos:Lerp(targetPos, alpha)
        hrp.CFrame = CFrame.new(newPos)
        task.wait(1/30)
    end
    
    -- Disable noclip
    if noclipConn then noclipConn:Disconnect() end
end

-- Check if stronghold is ready (timer at 0)
local function isStrongholdReady()
    local text = currentTimerText
    -- Only trigger on exactly "00s" or "0s" (not "09s", "10s", etc.)
    if text == "00s" or text == "0s" or text == "00 s" or text == "0 s" then
        return true
    end
    return false
end

-- Auto Stronghold Function
autoStrongholdLoop = function()
    while autoStrongholdEnabled do
        -- Wait for stronghold to be ready
        Window:Notify({Title = "Auto Stronghold", Desc = "Waiting for stronghold timer...", Time = 3})
        
        while autoStrongholdEnabled and not isStrongholdReady() do
            task.wait(5) -- Check every 5 seconds
        end
        
        if not autoStrongholdEnabled then break end
        
        Window:Notify({Title = "Auto Stronghold", Desc = "Stronghold ready! Starting...", Time = 3})
        task.wait(2)
        
        pcall(function()
            local stronghold = workspace.Map.Landmarks.Stronghold
            if not stronghold then
                Window:Notify({Title = "Error", Desc = "Stronghold not found!", Time = 3})
                autoStrongholdEnabled = false
                return
            end
            
            -- Save user's current auto kill settings before modifying
            ScriptState.savedAutoKillSettings = {
                selectedEntities = selectedEntities,
                killRadius = killRadius,
                autoKillEnabled = autoKillEnabled
            }
            
            -- Enable auto kill for cultists with large radius
            selectedEntities = {"Cultist", "Crossbow Cultist", "Juggernaut Cultist"}
            killRadius = 500 -- Large radius to cover whole stronghold
            if not autoKillEnabled then
                autoKillEnabled = true
                task.spawn(autoKillEntities) -- Start the kill loop
            end
            Window:Notify({Title = "Auto Stronghold", Desc = "Auto kill enabled (radius: 500)!", Time = 2})
            
            -- Step 1: Fly to pavement
            Window:Notify({Title = "Auto Stronghold", Desc = "Step 1: Flying to pavement...", Time = 2})
            local pavementPart = findPartBySize(stronghold.Building.Exterior, Vector3.new(20.8, 4.4, 16.2), 0.5)
            if pavementPart and pavementPart.Material == Enum.Material.Pavement then
                smoothFlyTo(pavementPart.CFrame + Vector3.new(0, 5, 0))
                task.wait(1)
            end
            
            -- Step 2: Walk through floors with noclip (sorted by distance from entrance)
            Window:Notify({Title = "Auto Stronghold", Desc = "Step 2: Walking through floors...", Time = 2})
            
            -- Find pavement as starting reference
            local pavementPos = pavementPart and pavementPart.Position or player.Character.HumanoidRootPart.Position
            
            -- Only entrance and main floor (no need for back)
            local floorSizesAuto = {
                Vector3.new(57.6, 0.4, 29.0),  -- Entrance
                Vector3.new(75.6, 0.4, 40.0),  -- Main
            }
            
            -- Find all floor parts
            local floorParts = {}
            for _, size in ipairs(floorSizesAuto) do
                local part = findFloorPartBySize(size)
                if part then
                    table.insert(floorParts, part)
                end
            end
            
            -- Sort by distance from pavement (closest first)
            table.sort(floorParts, function(a, b)
                return (a.Position - pavementPos).Magnitude < (b.Position - pavementPos).Magnitude
            end)
            
            for i, floorPart in ipairs(floorParts) do
                if not autoStrongholdEnabled then break end
                noclipWalkTo(floorPart.CFrame, 60)
                task.wait(0.5)
            end
            
            -- Step 3: Teleport to safe zone
            Window:Notify({Title = "Auto Stronghold", Desc = "Step 3: Going to safe zone...", Time = 2})
            local safeZone = findSafeZonePlatform(stronghold)
            if safeZone then
                smoothFlyTo(safeZone.CFrame + Vector3.new(0, 5, 0))
                task.wait(1)
            end
            
            -- Step 4: Wait at safe zone
            Window:Notify({Title = "Auto Stronghold", Desc = "Step 4: Waiting " .. safeZoneWaitTime .. "s at safe zone...", Time = 3})
            for i = safeZoneWaitTime, 1, -1 do
                if not autoStrongholdEnabled then break end
                if i % 10 == 0 then
                    Window:Notify({Title = "Auto Stronghold", Desc = i .. " seconds remaining...", Time = 2})
                end
                task.wait(1)
            end
            
            -- Step 5: Fly to Floor 3
            Window:Notify({Title = "Auto Stronghold", Desc = "Step 5: Flying to Floor 3...", Time = 2})
            local floor3Part = findPartBySize(stronghold.Building.Floor3, Vector3.new(70, 0.4, 55.8), 1)
            if floor3Part and floor3Part.Material == Enum.Material.WoodPlanks then
                smoothFlyTo(floor3Part.CFrame + Vector3.new(0, 5, 0))
                task.wait(2)
            end
            
            -- Step 6: Open Diamond Chest
            Window:Notify({Title = "Auto Stronghold", Desc = "Step 6: Opening diamond chest...", Time = 2})
            task.wait(1)
            local chest = workspace.Items:FindFirstChild("Stronghold Diamond Chest")
            if chest then
                local prompt = chest:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    fireproximityprompt(prompt, 0)
                    Window:Notify({Title = "Auto Stronghold", Desc = "Diamond chest opened!", Time = 2})
                else
                    Window:Notify({Title = "Warning", Desc = "Chest prompt not found", Time = 2})
                end
            else
                Window:Notify({Title = "Warning", Desc = "Diamond chest not found", Time = 2})
            end
            
            -- Step 7: Pickup Diamonds
            Window:Notify({Title = "Auto Stronghold", Desc = "Step 7: Picking up diamonds...", Time = 2})
            task.wait(1)
            local RemoteEvents = game:GetService("ReplicatedStorage"):WaitForChild("RemoteEvents")
            local takeDiamondsRemote = RemoteEvents:FindFirstChild("RequestTakeDiamonds")
            
            if takeDiamondsRemote then
                local items = workspace:FindFirstChild("Items")
                if items then
                    for _, diamond in pairs(items:GetChildren()) do
                        if diamond.Name == "Diamond" and diamond:IsA("Model") then
                            local mainPart = diamond:FindFirstChildWhichIsA("BasePart") or diamond:FindFirstChild("Main")
                            if mainPart then
                                -- Teleport to diamond
                                local character = player.Character
                                if character and character:FindFirstChild("HumanoidRootPart") then
                                    character.HumanoidRootPart.CFrame = mainPart.CFrame + Vector3.new(0, 3, 0)
                                end
                                task.wait(0.2)
                                takeDiamondsRemote:FireServer(diamond)
                                task.wait(0.2)
                            end
                        end
                    end
                end
                Window:Notify({Title = "Auto Stronghold", Desc = "Diamonds collected!", Time = 2})
            end
            
            -- Step 8: Return to Campground
            Window:Notify({Title = "Auto Stronghold", Desc = "Step 8: Returning to camp...", Time = 2})
            task.wait(0.5)
            local character = player.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                character:PivotTo(CFrame.new(0, 10, 0))
            end
            
            Window:Notify({Title = "Auto Stronghold", Desc = "Stronghold complete!", Time = 3})
            
            -- Cleanup
            stopFlying()
            
            -- Restore user's previous auto kill settings
            if ScriptState.savedAutoKillSettings then
                selectedEntities = ScriptState.savedAutoKillSettings.selectedEntities
                killRadius = ScriptState.savedAutoKillSettings.killRadius
                autoKillEnabled = ScriptState.savedAutoKillSettings.autoKillEnabled
                ScriptState.savedAutoKillSettings = nil
            else
                autoKillEnabled = false
            end
            
            autoStrongholdEnabled = false
        end)
        
        if not autoStrongholdEnabled then break end
        task.wait(1)
    end
end

-- Stronghold Teleport Button
QuestTab:Button({
    Title = "Teleport to Stronghold",
    Desc = "Teleports you to the Stronghold location",
    Callback = function()
        local success, err = pcall(function()
            local targetPart = workspace.Map.Landmarks.Stronghold.Building.Exterior:GetChildren()[6]:GetChildren()[26]
            if targetPart and targetPart:IsA("BasePart") then
                smoothFlyTo(targetPart.CFrame + Vector3.new(0, 10, 0))
                Window:Notify({
                    Title = "Teleport",
                    Desc = "Flying to Stronghold!",
                    Time = 3
                })
            else
                Window:Notify({
                    Title = "Error",
                    Desc = "Target location not found!",
                    Time = 3
                })
            end
        end)
        
        if not success then
            Window:Notify({
                Title = "Error",
                Desc = "Teleport failed: " .. tostring(err),
                Time = 3
            })
        end
    end
})

-- Create Bring Tab
local BringTab = Window:Tab({Title = "Bring", Icon = "package"})

Window:Line()

BringTab:Section({Title = "Item Teleport"})

-- Teleport destination
local teleportDestination = "Campfire"
local selectedOtherPlayer = nil

-- Note: getScrapperPosition() is defined earlier in Auto Day Farm section

-- Get player list (excluding local player)
local function getOtherPlayerNames()
    local names = {}
    for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
        if plr ~= player then
            table.insert(names, plr.Name)
        end
    end
    return names
end

-- Get target position based on selection
local function getTargetPosition()
    if teleportDestination == "Campfire" then
        return getCampfirePosition()
    elseif teleportDestination == "Scrapper" then
        return getScrapperPosition()
    elseif teleportDestination == "Player" then
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            return character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
        end
    elseif teleportDestination == "Other Player" then
        if selectedOtherPlayer then
            local otherPlr = game:GetService("Players"):FindFirstChild(selectedOtherPlayer)
            if otherPlr and otherPlr.Character and otherPlr.Character:FindFirstChild("HumanoidRootPart") then
                return otherPlr.Character.HumanoidRootPart.Position + Vector3.new(0, 2, 0)
            end
        end
    end
    return Vector3.new(0, 10, 0)
end

-- Get final teleport position (with scatter for players, exact for campfire/scrapper)
local teleportHeightOffset = 10

local function getFinalTeleportPosition()
    local basePos = getTargetPosition()
    if teleportDestination == "Player" or teleportDestination == "Other Player" then
        -- Scatter around players so items don't stack on them
        return basePos + Vector3.new(math.random(-5, 5), teleportHeightOffset, math.random(-5, 5))
    end
    -- Stack at exact position for Campfire/Scrapper
    return basePos + Vector3.new(0, teleportHeightOffset, 0)
end

-- Destination Dropdown
BringTab:Dropdown({
    Title = "Teleport Destination",
    List = {"Campfire", "Scrapper", "Player", "Other Player"},
    Value = "Campfire",
    Callback = function(selected)
        teleportDestination = selected
        Window:Notify({
            Title = "Destination",
            Desc = "Items will teleport to: " .. selected,
            Time = 2
        })
    end
})

-- Other Player Dropdown
local otherPlayerDropdown = BringTab:Dropdown({
    Title = "Select Player",
    List = getOtherPlayerNames(),
    Value = nil,
    Callback = function(selected)
        selectedOtherPlayer = selected
        Window:Notify({
            Title = "Player Selected",
            Desc = "Target: " .. selected,
            Time = 2
        })
    end
})

-- Height Offset Slider
BringTab:Slider({
    Title = "Height Offset",
    Desc = "Adjust vertical offset for teleported items",
    Min = -20,
    Max = 20,
    Value = 10,
    Callback = function(v)
        teleportHeightOffset = v
    end
})

-- Auto-update player list every 5 seconds
task.spawn(function()
    while ScriptState.loopsRunning do
        task.wait(5)
        pcall(function()
            otherPlayerDropdown:SetList(getOtherPlayerNames())
        end)
    end
end)

-- Item count limit
local itemCountLimit = 10
local noLimitEnabled = false

-- Item Count Slider
BringTab:Slider({
    Title = "Item Count Limit",
    Min = 1,
    Max = 100,
    Rounding = 0,
    Value = 10,
    Callback = function(val)
        itemCountLimit = val
    end
})

-- No Limit Toggle
BringTab:Toggle({
    Title = "No Limit",
    Desc = "Bring all items without count limit",
    Value = false,
    Callback = function(v)
        noLimitEnabled = v
        if v then
            Window:Notify({
                Title = "No Limit",
                Desc = "Will bring ALL items!",
                Time = 2
            })
        else
            Window:Notify({
                Title = "Limit Enabled",
                Desc = "Will bring " .. itemCountLimit .. " items",
                Time = 2
            })
        end
    end
})

BringTab:Section({Title = "Fuels"})

-- All fuel types
local allFuels = {
    "Log", "Biofuel", "Coal", "Purple Fur Tuft", "Fuel Canister", "Oil Barrel",
    "Cultist Corpse", "Crossbow Cultist Corpse", "Juggernaut Cultist Corpse", 
    "Cultist King Corpse", "Alien Corpse", "Elite Alien Corpse", "Wolf Corpse", 
    "Alpha Wolf Corpse", "Bear Corpse"
}

-- Selected fuels
local selectedFuels = {}

-- Fuels Dropdown
local fuelsDropdown = BringTab:Dropdown({
    Title = "Select Fuels",
    List = {"All", "Log", "Biofuel", "Coal", "Purple Fur Tuft", "Fuel Canister", "Oil Barrel",
        "Cultist Corpse", "Crossbow Cultist Corpse", "Juggernaut Cultist Corpse", 
        "Cultist King Corpse", "Alien Corpse", "Elite Alien Corpse", "Wolf Corpse", 
        "Alpha Wolf Corpse", "Bear Corpse"
    },
    Multi = true,
    Value = {},
    Callback = function(selected)
        -- Check if "All" is selected
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedFuels = hasAll and allFuels or selected
    end
})

-- Bring Fuels Button
BringTab:Button({
    Title = "Bring Fuels",
    Desc = "Teleports selected fuels to destination",
    Callback = function()
        if #selectedFuels == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one fuel type!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected fuels
                local isSelected = false
                for _, fuelName in pairs(selectedFuels) do
                    if item.Name == fuelName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " fuels!",
            Time = 2
        })
    end
})

BringTab:Section({Title = "Scraps"})

-- All scrap types
local allScraps = {
    "Bolt", "Sheet Metal", "UFO Junk", "UFO Component", "Broken Fan", 
    "Old Radio", "Gears", "Broken Microwave", "Tyre", "Metal Chair", 
    "Old Car Engine", "Washing Machine", "Cultist Experiment", 
    "Cultist Prototype", "UFO Scrap"
}

-- Selected scraps
local selectedScraps = {}

-- Scraps Dropdown
local scrapsDropdown = BringTab:Dropdown({
    Title = "Select Scraps",
    List = {"All", "Bolt", "Sheet Metal", "UFO Junk", "UFO Component", "Broken Fan", 
        "Old Radio", "Gears", "Broken Microwave", "Tyre", "Metal Chair", 
        "Old Car Engine", "Washing Machine", "Cultist Experiment", 
        "Cultist Prototype", "UFO Scrap"
    },
    Multi = true,
    Value = {},
    Callback = function(selected)
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedScraps = hasAll and allScraps or selected
    end
})

-- Bring Scraps Button
BringTab:Button({
    Title = "Bring Scraps",
    Desc = "Teleports selected scraps to destination",
    Callback = function()
        if #selectedScraps == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one scrap type!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected scraps
                local isSelected = false
                for _, scrapName in pairs(selectedScraps) do
                    if item.Name == scrapName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " scraps!",
            Time = 2
        })
    end
})

BringTab:Section({Title = "Healing"})

-- All healing types
local allHealing = {
    "Bandage", "Medkit", "Cake", "Hearty Stew", "BBQ Ribs", 
    "Carrot Cake", "Jar o' Jelly"
}

-- Selected healing items
local selectedHealing = {}

-- Healing Dropdown
local healingDropdown = BringTab:Dropdown({
    Title = "Select Healing Items",
    List = {"All", "Bandage", "Medkit", "Cake", "Hearty Stew", "BBQ Ribs", 
        "Carrot Cake", "Jar o' Jelly"
    },
    Multi = true,
    Value = {},
    Callback = function(selected)
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedHealing = hasAll and allHealing or selected
    end
})

-- Bring Healing Button
BringTab:Button({
    Title = "Bring Healing Items",
    Desc = "Teleports selected healing items to destination",
    Callback = function()
        if #selectedHealing == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one healing item!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected healing items
                local isSelected = false
                for _, healingName in pairs(selectedHealing) do
                    if item.Name == healingName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " healing items!",
            Time = 2
        })
    end
})

BringTab:Section({Title = "Food"})

-- All food types
local allFood = {
    "Carrot", "Corn", "Pumpkin", "Berry", "Apple", "Morsel", "Steak", "Ribs", "Cake", "Chili", 
    "Stew", "Hearty Stew", "Meat? Sandwich", "Seafood Chowder", "Steak Dinner", "Pumpkin Soup", 
    "BBQ Ribs", "Carrot Cake", "Jar o' Jelly", "Candy Apple", "Candy Corn", "Pumpkin Pie", 
    "Cotton Candy", "Mackerel", "Salmon", "Clownfish", "Jellyfish", "Char", "Eel", "Swordfish", 
    "Shark", "Lava Eel", "Lionfish",
    "Cooked Morsel", "Cooked Steak", "Cooked Ribs", "Cooked Mackerel", "Cooked Salmon", 
    "Cooked Clownfish", "Cooked Char", "Cooked Eel", "Cooked Swordfish", "Cooked Shark", 
    "Cooked Lava Eel", "Cooked Lionfish"
}

-- Selected food
local selectedFood = {}

-- Food Dropdown
local foodDropdown = BringTab:Dropdown({
    Title = "Select Food",
    List = {"All", "Carrot", "Corn", "Pumpkin", "Berry", "Apple", "Morsel", "Steak", "Ribs", "Cake", "Chili", 
        "Stew", "Hearty Stew", "Meat? Sandwich", "Seafood Chowder", "Steak Dinner", "Pumpkin Soup", 
        "BBQ Ribs", "Carrot Cake", "Jar o' Jelly", "Candy Apple", "Candy Corn", "Pumpkin Pie", 
        "Cotton Candy", "Mackerel", "Salmon", "Clownfish", "Jellyfish", "Char", "Eel", "Swordfish", 
        "Shark", "Lava Eel", "Lionfish",
        "Cooked Morsel", "Cooked Steak", "Cooked Ribs", "Cooked Mackerel", "Cooked Salmon", 
        "Cooked Clownfish", "Cooked Char", "Cooked Eel", "Cooked Swordfish", "Cooked Shark", 
        "Cooked Lava Eel", "Cooked Lionfish"
    },
    Multi = true,
    Value = {},
    Callback = function(selected)
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedFood = hasAll and allFood or selected
    end
})

-- Bring Food Button
BringTab:Button({
    Title = "Bring Food",
    Desc = "Teleports selected food to destination",
    Callback = function()
        if #selectedFood == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one food item!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected food
                local isSelected = false
                for _, foodName in pairs(selectedFood) do
                    if item.Name == foodName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " food items!",
            Time = 2
        })
    end
})

BringTab:Section({Title = "Axes"})

-- All axe types
local allAxes = {"Old Axe", "Good Axe", "Ice Axe", "Strong Axe", "Chainsaw"}

-- Selected axes
local selectedAxes = {}

-- Axes Dropdown
local axesDropdown = BringTab:Dropdown({
    Title = "Select Axes",
    List = {"All", "Old Axe", "Good Axe", "Ice Axe", "Strong Axe", "Chainsaw"},
    Multi = true,
    Value = {},
    Callback = function(selected)
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedAxes = hasAll and allAxes or selected
    end
})

-- Bring Axes Button
BringTab:Button({
    Title = "Bring Axes",
    Desc = "Teleports selected axes to destination",
    Callback = function()
        if #selectedAxes == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one axe!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected axes
                local isSelected = false
                for _, axeName in pairs(selectedAxes) do
                    if item.Name == axeName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " axes!",
            Time = 2
        })
    end
})

BringTab:Section({Title = "Weapons and Armors"})

-- All weapons and armors types
local allWeaponsArmors = {
    "Spear", "Morningstar", "Katana", "Laser Sword", "Ice Sword", "Trident", 
    "Poison Spear", "Infernal Sword", "Cultist King Mace", "Obsidiron Hammer", 
    "Scythe", "Vampire Scythe", "Leather Body", "Poison Armor", "Iron Body", 
    "Thorn Body", "Riot Shield", "Alien Armor", "Obsidiron Body", "Vampire Cloak", 
    "Earmuffs", "Beanie", "Arctic Fox Hat", "Polar Bear Hat", "Mammoth Helmet", 
    "Frog Boots", "Obsidiron Boots"
}

-- Selected weapons and armors
local selectedWeaponsArmors = {}

-- Weapons and Armors Dropdown
local weaponsArmorsDropdown = BringTab:Dropdown({
    Title = "Select Weapons/Armors",
    List = {"All", "Spear", "Morningstar", "Katana", "Laser Sword", "Ice Sword", "Trident", 
        "Poison Spear", "Infernal Sword", "Cultist King Mace", "Obsidiron Hammer", 
        "Scythe", "Vampire Scythe", "Leather Body", "Poison Armor", "Iron Body", 
        "Thorn Body", "Riot Shield", "Alien Armor", "Obsidiron Body", "Vampire Cloak", 
        "Earmuffs", "Beanie", "Arctic Fox Hat", "Polar Bear Hat", "Mammoth Helmet", 
        "Frog Boots", "Obsidiron Boots"
    },
    Multi = true,
    Value = {},
    Callback = function(selected)
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedWeaponsArmors = hasAll and allWeaponsArmors or selected
    end
})

-- Bring Weapons and Armors Button
BringTab:Button({
    Title = "Bring Weapons/Armors",
    Desc = "Teleports selected weapons and armors to destination",
    Callback = function()
        if #selectedWeaponsArmors == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one item!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected weapons/armors
                local isSelected = false
                for _, itemName in pairs(selectedWeaponsArmors) do
                    if item.Name == itemName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " weapons/armors!",
            Time = 2
        })
    end
})

BringTab:Section({Title = "Sacks"})

-- All sack types
local allSacks = {"Old Sack", "Good Sack", "Infernal Sack", "Giant Sack"}

-- Selected sacks
local selectedSacks = {}

-- Sacks Dropdown
local sacksDropdown = BringTab:Dropdown({
    Title = "Select Sacks",
    List = {"All", "Old Sack", "Good Sack", "Infernal Sack", "Giant Sack"},
    Multi = true,
    Value = {},
    Callback = function(selected)
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedSacks = hasAll and allSacks or selected
    end
})

-- Bring Sacks Button
BringTab:Button({
    Title = "Bring Sacks",
    Desc = "Teleports selected sacks to destination",
    Callback = function()
        if #selectedSacks == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one sack!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected sacks
                local isSelected = false
                for _, sackName in pairs(selectedSacks) do
                    if item.Name == sackName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " sacks!",
            Time = 2
        })
    end
})

BringTab:Section({Title = "Pelts and Materials"})

-- All pelts and materials types
local allPeltsMaterials = {
    "Bunny Foot", "Wolf Pelt", "Alpha Wolf Pelt", "Bear Pelt", "Arctic Fox Pelt", 
    "Polar Bear Pelt", "Mammoth Tusk", "Scorpion Shell", "Cultist King Antler", 
    "Wood", "Scrap", "Cultist Gem", "Forest Gem", "Forest Gem Fragment", 
    "Mossy Coin", "Flower", "Sapling", "Sacrifice Totem", "Meteor Shard", 
    "Gold Shard", "Raw Obsidiron Ore", "Raw Obsidiron Ore (Shard)", 
    "Scalding Obsidiron Ingot", "Obsidiron Ingot"
}

-- Selected pelts and materials
local selectedPeltsMaterials = {}

-- Pelts and Materials Dropdown
local peltsMaterialsDropdown = BringTab:Dropdown({
    Title = "Select Pelts/Materials",
    List = {"All", "Bunny Foot", "Wolf Pelt", "Alpha Wolf Pelt", "Bear Pelt", "Arctic Fox Pelt", 
        "Polar Bear Pelt", "Mammoth Tusk", "Scorpion Shell", "Cultist King Antler", 
        "Wood", "Scrap", "Cultist Gem", "Forest Gem", "Forest Gem Fragment", 
        "Mossy Coin", "Flower", "Sapling", "Sacrifice Totem", "Meteor Shard", 
        "Gold Shard", "Raw Obsidiron Ore", "Raw Obsidiron Ore (Shard)", 
        "Scalding Obsidiron Ingot", "Obsidiron Ingot"
    },
    Multi = true,
    Value = {},
    Callback = function(selected)
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedPeltsMaterials = hasAll and allPeltsMaterials or selected
    end
})

-- Bring Pelts and Materials Button
BringTab:Button({
    Title = "Bring Pelts/Materials",
    Desc = "Teleports selected pelts and materials to destination",
    Callback = function()
        if #selectedPeltsMaterials == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one item!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected pelts/materials
                local isSelected = false
                for _, itemName in pairs(selectedPeltsMaterials) do
                    if item.Name == itemName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " pelts/materials!",
            Time = 2
        })
    end
})

BringTab:Section({Title = "Seeds"})

-- All seed types
local allSeeds = {
    "Chili Seeds", "Flower Seeds", "Berry Seeds", "Firefly Seeds", 
    "Dripleaf Seeds", "Moonflower Seeds", "Stareweed Seeds", 
    "Cavevine Seeds", "Mandrake Seeds"
}

-- Selected seeds
local selectedSeeds = {}

-- Seeds Dropdown
local seedsDropdown = BringTab:Dropdown({
    Title = "Select Seeds",
    List = {"All", "Chili Seeds", "Flower Seeds", "Berry Seeds", "Firefly Seeds", 
        "Dripleaf Seeds", "Moonflower Seeds", "Stareweed Seeds", 
        "Cavevine Seeds", "Mandrake Seeds"
    },
    Multi = true,
    Value = {},
    Callback = function(selected)
        local hasAll = false
        for _, v in pairs(selected) do
            if v == "All" then hasAll = true break end
        end
        selectedSeeds = hasAll and allSeeds or selected
    end
})

-- Bring Seeds Button
BringTab:Button({
    Title = "Bring Seeds",
    Desc = "Teleports selected seeds to destination",
    Callback = function()
        if #selectedSeeds == 0 then
            Window:Notify({
                Title = "Error",
                Desc = "Please select at least one seed type!",
                Time = 2
            })
            return
        end
        
        local targetPos = getFinalTeleportPosition()
        local RemoteEvents = replicatedStorage:WaitForChild("RemoteEvents")
        local dragRemote = RemoteEvents:FindFirstChild("RequestStartDraggingItem")
        
        local itemsBrought = 0
        local itemsToProcess = noLimitEnabled and math.huge or itemCountLimit
        local items = workspace:FindFirstChild("Items")
        
        if items then
            for _, item in ipairs(items:GetChildren()) do
                if itemsBrought >= itemsToProcess then break end
                
                -- Check if item is in selected seeds
                local isSelected = false
                for _, seedName in pairs(selectedSeeds) do
                    if item.Name == seedName then
                        isSelected = true
                        break
                    end
                end
                
                if isSelected and item:IsA("Model") then
                    itemsBrought = itemsBrought + 1
                    
                    local mainPart = item.PrimaryPart or item:FindFirstChild("Handle") or item:FindFirstChildWhichIsA("BasePart", true)
                    
                    if mainPart then
                        pcall(function()
                            if dragRemote then
                                dragRemote:FireServer(item)
                            end
                            mainPart.CFrame = CFrame.new(targetPos)
                        end)
                    end
                end
            end
        end
        
        Window:Notify({
            Title = "Bring Items",
            Desc = "Brought " .. itemsBrought .. " seeds!",
            Time = 2
        })
    end
})

-- Create Misc Tab
local MiscTab = Window:Tab({Title = "Misc", Icon = "settings"})

Window:Line()

MiscTab:Section({Title = "Character"})

-- Character Speed Variables
local speedLoopEnabled = false
local targetSpeed = 16

-- Character Speed Slider
MiscTab:Slider({
    Title = "Character Speed",
    Min = 16,
    Max = 200,
    Rounding = 0,
    Value = 16,
    Callback = function(val)
        targetSpeed = val
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.WalkSpeed = val
            end
        end
    end
})

-- Speed Loop Toggle
MiscTab:Toggle({
    Title = "Lock Speed",
    Desc = "Continuously maintains your speed (prevents resets)",
    Value = false,
    Callback = function(v)
        speedLoopEnabled = v
        if v then
            task.spawn(function()
                while speedLoopEnabled do
                    local character = player.Character
                    if character then
                        local humanoid = character:FindFirstChildOfClass("Humanoid")
                        if humanoid and humanoid.WalkSpeed ~= targetSpeed then
                            humanoid.WalkSpeed = targetSpeed
                        end
                    end
                    task.wait(0.1)
                end
            end)
            Window:Notify({
                Title = "Speed Lock",
                Desc = "Speed locked at " .. targetSpeed,
                Time = 2
            })
        else
            Window:Notify({
                Title = "Speed Lock",
                Desc = "Speed lock disabled",
                Time = 2
            })
        end
    end
})

-- Infinite Jump Toggle
local infiniteJumpEnabled = false

MiscTab:Toggle({
    Title = "Infinite Jump",
    Desc = "Jump infinitely without touching the ground",
    Value = false,
    Callback = function(v)
        infiniteJumpEnabled = v
    end
})

-- Infinite Jump Handler
local UserInputService = game:GetService("UserInputService")
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local character = player.Character
        if character then
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Fly Mode (uses central state to avoid conflicts with smoothFlyTo)
local flyModeEnabled = false
local flySpeed = 50

MiscTab:Toggle({
    Title = "Fly Mode",
    Desc = "Fly around the map freely",
    Value = false,
    Callback = function(v)
        flyModeEnabled = v
        if v then
            -- Stop any smooth fly in progress first
            if ScriptState.smoothFlyConnection then
                ScriptState.smoothFlyConnection:Disconnect()
                ScriptState.smoothFlyConnection = nil
            end
            
            -- Start flying
            local character = player.Character
            if not character then return end
            
            local hrp = character:FindFirstChild("HumanoidRootPart")
            local humanoid = character:FindFirstChildOfClass("Humanoid")
            if not hrp or not humanoid then return end
            
            -- Create flying physics using central state
            ScriptState.flyBodyGyro = Instance.new("BodyGyro")
            ScriptState.flyBodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
            ScriptState.flyBodyGyro.P = 9e4
            ScriptState.flyBodyGyro.Parent = hrp
            
            ScriptState.flyBodyVelocity = Instance.new("BodyVelocity")
            ScriptState.flyBodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)
            ScriptState.flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
            ScriptState.flyBodyVelocity.Parent = hrp
            
            humanoid.PlatformStand = true
            
            -- Fly control loop using central state
            ScriptState.flyModeConnection = game:GetService("RunService").Heartbeat:Connect(function()
                if not flyModeEnabled or not character or not hrp then
                    if ScriptState.flyModeConnection then ScriptState.flyModeConnection:Disconnect() end
                    return
                end
                
                local camera = workspace.CurrentCamera
                local moveDirection = humanoid.MoveDirection
                
                -- Calculate velocity based on camera direction and movement
                local velocity = Vector3.new(0, 0, 0)
                if moveDirection.Magnitude > 0 then
                    local cameraCFrame = camera.CFrame
                    velocity = (cameraCFrame.LookVector * moveDirection.Z + cameraCFrame.RightVector * moveDirection.X) * flySpeed
                end
                
                -- Apply velocity
                if ScriptState.flyBodyVelocity and ScriptState.flyBodyVelocity.Parent then
                    ScriptState.flyBodyVelocity.Velocity = velocity
                end
                
                -- Keep camera orientation
                if ScriptState.flyBodyGyro and ScriptState.flyBodyGyro.Parent then
                    ScriptState.flyBodyGyro.CFrame = camera.CFrame
                end
            end)
            
            Window:Notify({
                Title = "Fly Mode",
                Desc = "Fly mode enabled!",
                Time = 2
            })
        else
            -- Stop flying
            if ScriptState.flyModeConnection then
                ScriptState.flyModeConnection:Disconnect()
                ScriptState.flyModeConnection = nil
            end
            
            if ScriptState.flyBodyVelocity then
                ScriptState.flyBodyVelocity:Destroy()
                ScriptState.flyBodyVelocity = nil
            end
            
            if ScriptState.flyBodyGyro then
                ScriptState.flyBodyGyro:Destroy()
                ScriptState.flyBodyGyro = nil
            end
            
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.PlatformStand = false
                end
            end
            
            Window:Notify({
                Title = "Fly Mode",
                Desc = "Fly mode disabled!",
                Time = 2
            })
        end
    end
})

-- Fly Speed Slider
MiscTab:Slider({
    Title = "Fly Speed",
    Min = 10,
    Max = 200,
    Rounding = 0,
    Value = 50,
    Callback = function(val)
        flySpeed = val
    end
})

MiscTab:Section({Title = "Visual"})

-- Remove Fog Toggle
local fogRemoved = false
local originalFogEnd = nil
local originalFogStart = nil
local originalBrightness = nil
local originalClockTime = nil
local originalAmbient = nil
local originalOutdoorAmbient = nil

MiscTab:Toggle({
    Title = "Remove Fog",
    Desc = "Remove fog for better visibility",
    Value = false,
    Callback = function(v)
        local Lighting = game:GetService("Lighting")
        
        if v then
            -- Save original values
            originalFogEnd = Lighting.FogEnd
            originalFogStart = Lighting.FogStart
            originalBrightness = Lighting.Brightness
            originalClockTime = Lighting.ClockTime
            originalAmbient = Lighting.Ambient
            originalOutdoorAmbient = Lighting.OutdoorAmbient
            
            -- Remove fog
            Lighting.FogEnd = 1e6
            Lighting.FogStart = 1e6 - 1
            Lighting.Brightness = 5
            Lighting.ClockTime = 14
            Lighting.Ambient = Color3.new(1, 1, 1)
            Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            
            fogRemoved = true
            
            Window:Notify({
                Title = "Remove Fog",
                Desc = "Fog removed!",
                Time = 2
            })
        else
            -- Restore original values
            if originalFogEnd then
                Lighting.FogEnd = originalFogEnd
                Lighting.FogStart = originalFogStart
                Lighting.Brightness = originalBrightness
                Lighting.ClockTime = originalClockTime
                Lighting.Ambient = originalAmbient
                Lighting.OutdoorAmbient = originalOutdoorAmbient
            end
            
            fogRemoved = false
            
            Window:Notify({
                Title = "Remove Fog",
                Desc = "Fog restored!",
                Time = 2
            })
        end
    end
})

-- Success Notification
Window:Notify({
    Title = "99 Nights",
    Desc = "Script loaded successfully!",
    Time = 3
})