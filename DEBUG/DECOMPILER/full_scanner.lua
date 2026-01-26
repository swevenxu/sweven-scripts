-- Full Game Scanner + Decompiler
-- Saves to file with game name, captures property values

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- Get game name for filename
local gameName = "unknown_game"
pcall(function()
    local info = MarketplaceService:GetProductInfo(game.PlaceId)
    gameName = info.Name:gsub("[^%w%s]", ""):gsub("%s+", "_"):lower()
end)

local fileName = gameName .. "_" .. game.PlaceId .. ".md"

local output = "# " .. gameName:upper() .. " - FULL GAME SCAN\n"
output = output .. "PlaceId: " .. game.PlaceId .. "\n"
output = output .. "Generated: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n\n"

local maxDepth = 6
local maxChildren = 50

-- ============================================
-- PROPERTY CAPTURE
-- ============================================

local function getProperties(obj)
    local props = {}
    
    pcall(function()
        -- Text properties
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            local text = obj.Text
            if text and text ~= "" then
                table.insert(props, 'Text="' .. tostring(text):sub(1, 50) .. '"')
            end
        end
        
        -- Image properties
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            local img = obj.Image
            if img and img ~= "" then
                table.insert(props, 'Image="' .. tostring(img) .. '"')
            end
        end
        
        -- Visibility
        if obj:IsA("GuiObject") then
            if not obj.Visible then
                table.insert(props, "Visible=false")
            end
        end
        
        -- Size for frames (useful for bars/progress)
        if obj:IsA("Frame") and obj.Name:lower():find("bar") then
            table.insert(props, "Size=" .. tostring(obj.Size))
        end
        
        -- Value objects
        if obj:IsA("ValueBase") then
            pcall(function()
                table.insert(props, "Value=" .. tostring(obj.Value):sub(1, 50))
            end)
        end
        
        -- BasePart
        if obj:IsA("BasePart") then
            table.insert(props, "Pos=" .. tostring(obj.Position))
        end
        
        -- Remotes
        if obj:IsA("RemoteFunction") then
            table.insert(props, "[RF]")
        elseif obj:IsA("RemoteEvent") then
            table.insert(props, "[RE]")
        end
    end)
    
    -- Attributes
    pcall(function()
        for name, value in pairs(obj:GetAttributes()) do
            table.insert(props, "@" .. name .. "=" .. tostring(value):sub(1, 30))
        end
    end)
    
    if #props > 0 then
        return " {" .. table.concat(props, ", ") .. "}"
    end
    return ""
end

local function scan(obj, depth, indent)
    if depth > maxDepth then return end
    
    local children = obj:GetChildren()
    local count = 0
    
    for _, child in ipairs(children) do
        if count >= maxChildren then
            output = output .. indent .. "... and " .. (#children - count) .. " more\n"
            break
        end
        
        local props = getProperties(child)
        output = output .. indent .. "- " .. child.Name .. " (" .. child.ClassName .. ")" .. props .. "\n"
        
        if #child:GetChildren() > 0 then
            scan(child, depth + 1, indent .. "  ")
        end
        
        count = count + 1
    end
end

local function scanDeep(obj, depth, indent, maxD)
    if depth > maxD then return end
    
    for _, child in ipairs(obj:GetChildren()) do
        local props = getProperties(child)
        output = output .. indent .. "- " .. child.Name .. " (" .. child.ClassName .. ")" .. props .. "\n"
        
        if #child:GetChildren() > 0 then
            scanDeep(child, depth + 1, indent .. "  ", maxD)
        end
    end
end

-- ============================================
-- SECTION 1: KNIT SERVICES (REMOTES)
-- ============================================

output = output .. "# SECTION 1: KNIT SERVICES REMOTES\n\n"

local rs = game:GetService("ReplicatedStorage")
local shared = rs:FindFirstChild("Shared")
if shared then
    local packages = shared:FindFirstChild("Packages")
    if packages then
        local knit = packages:FindFirstChild("Knit")
        if knit then
            local services = knit:FindFirstChild("Services")
            if services then
                output = output .. "PATH: ReplicatedStorage.Shared.Packages.Knit.Services\n\n"
                for _, service in ipairs(services:GetChildren()) do
                    output = output .. "## " .. service.Name .. "\n"
                    scanDeep(service, 1, "", 5)
                    output = output .. "\n"
                end
            end
        end
    end
end

-- ============================================
-- SECTION 2: DECOMPILED CLIENT SCRIPTS
-- ============================================

output = output .. "\n# SECTION 2: DECOMPILED CLIENT SCRIPTS\n\n"

local function tryDecompile(script)
    local success, result = pcall(function()
        if decompile then
            return decompile(script)
        elseif getscriptbytecode then
            return "-- Bytecode available but no decompiler"
        else
            return "-- No decompiler available"
        end
    end)
    
    if success then
        return result
    else
        return "-- Decompile failed: " .. tostring(result)
    end
end

-- Decompile Controllers
local controllers = rs:FindFirstChild("Controllers")
if controllers then
    output = output .. "## Controllers (ReplicatedStorage)\n\n"
    for _, controller in ipairs(controllers:GetChildren()) do
        if controller:IsA("ModuleScript") then
            output = output .. "### " .. controller.Name .. "\n"
            output = output .. "```lua\n"
            output = output .. tryDecompile(controller)
            output = output .. "\n```\n\n"
        end
    end
end

-- Decompile PlayerScripts
local player = Players.LocalPlayer
local playerScripts = player:FindFirstChild("PlayerScripts")
if playerScripts then
    output = output .. "## PlayerScripts\n\n"
    for _, script in ipairs(playerScripts:GetDescendants()) do
        if script:IsA("LocalScript") or script:IsA("ModuleScript") then
            output = output .. "### " .. script:GetFullName() .. "\n"
            output = output .. "```lua\n"
            output = output .. tryDecompile(script)
            output = output .. "\n```\n\n"
        end
    end
end

-- ============================================
-- SECTION 3: WORKSPACE STRUCTURE
-- ============================================

output = output .. "\n# SECTION 3: GAME WORLD STRUCTURE\n\n"

-- Scan all workspace children (universal)
for _, folder in ipairs(workspace:GetChildren()) do
    -- Skip camera, terrain, and player characters
    if not folder:IsA("Camera") and not folder:IsA("Terrain") and not folder:IsA("Model") then
        if #folder:GetChildren() > 0 then
            output = output .. "## " .. folder.Name .. " (" .. folder.ClassName .. ")\n"
            scan(folder, 1, "")
            output = output .. "\n"
        end
    end
end

-- ============================================
-- SECTION 4: PLAYERGUI STRUCTURE (WITH PROPERTIES)
-- ============================================

output = output .. "\n# SECTION 4: PLAYERGUI STRUCTURE\n\n"

local pg = player:FindFirstChild("PlayerGui")
if pg then
    for _, gui in ipairs(pg:GetChildren()) do
        if gui:IsA("ScreenGui") then
            output = output .. "## " .. gui.Name .. " (ScreenGui)\n"
            scanDeep(gui, 1, "", 8)
            output = output .. "\n"
        end
    end
end

-- ============================================
-- SECTION 5: PLAYER DATA (if accessible)
-- ============================================

output = output .. "\n# SECTION 5: PLAYER DATA\n\n"

local dataFolders = {"Data", "PlayerData", "Stats", "Inventory", "leaderstats"}
for _, folderName in ipairs(dataFolders) do
    local folder = player:FindFirstChild(folderName)
    if folder then
        output = output .. "## " .. folderName .. "\n"
        scanDeep(folder, 1, "", 5)
        output = output .. "\n"
    end
end

-- ============================================
-- SAVE TO FILE
-- ============================================

local folderName = "GameScans"
local filePath = folderName .. "/" .. fileName

-- Create folder if it doesn't exist
pcall(function()
    if not isfolder(folderName) then
        makefolder(folderName)
    end
end)

local success, err = pcall(function()
    writefile(filePath, output)
end)

if success then
    print("✅ Saved to: " .. filePath)
    print("📁 Check your executor's workspace/" .. folderName .. " folder")
else
    print("❌ writefile failed: " .. tostring(err))
    -- Try without folder
    local success2 = pcall(function()
        writefile(fileName, output)
    end)
    if success2 then
        print("✅ Saved to: " .. fileName .. " (root folder)")
    else
        print("📋 Copying to clipboard instead...")
        setclipboard(output)
        print("✅ Copied to clipboard! Paste into a .md file")
    end
end

print("Game: " .. gameName)
print("PlaceId: " .. game.PlaceId)
print("Total size: " .. #output .. " characters")
