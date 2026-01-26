-- Snoe Hub Loader (Luarmor Protected)
-- Key validation handled by Luarmor

local REPO_BASE = "https://raw.githubusercontent.com/swevenxu/thesnoeproject/main/"

local scripts = {
    [93044798454681] = "games/deadly-delivery.obfuscated.lua",
}

local gameNames = {
    [93044798454681] = "Deadly Delivery",
}

local function isTheForge()
    local w = workspace
    return w:FindFirstChild("Forgotten Kingdom", true)
        or w:FindFirstChild("Island3BossArena", true)
        or w:FindFirstChild("Stonewake's Cross", true)
        or w:FindFirstChild("Rocks")
        or w:FindFirstChild("Island1CaveStart", true)
end

local function is99Nights()
    local map = workspace:FindFirstChild("Map")
    if map then
        local campground = map:FindFirstChild("Campground")
        if campground and campground:FindFirstChild("Scrapper") then
            return true
        end
    end
    return false
end

local function loadGameScript()
    local placeId = game.PlaceId
    local scriptPath = scripts[placeId]
    local gameName = gameNames[placeId]
    
    -- Detect The Forge by workspace objects
    if not scriptPath and isTheForge() then
        scriptPath = "games/the-forge.obfuscated.lua"
        gameName = "The Forge"
    end
    
    -- Detect 99 Nights by Scrapper
    if not scriptPath and is99Nights() then
        scriptPath = "games/99-nights.obfuscated.lua"
        gameName = "99 Nights"
    end
    
    if scriptPath then
        print("[Snoe] Loading: " .. (gameName or "Unknown"))
        local success, err = pcall(function()
            loadstring(game:HttpGet(REPO_BASE .. scriptPath))()
        end)
        if not success then warn("[Snoe] Failed: " .. tostring(err)) end
    else
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "Snoe Hub", Text = "No script for this game", Duration = 5
        })
    end
end

-- Luarmor handles key validation before this runs
loadGameScript()
