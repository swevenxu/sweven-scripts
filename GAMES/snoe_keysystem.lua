-- Snoe Key System (Standalone)
-- Execute directly in your executor

local HttpService = game:GetService("HttpService")

-- CONFIG - Change these
local KEY_LINK = "https://work.ink/2cCC/snoe-checkpoint-1" -- your work.ink URL
local SCRIPT_URL = "" -- script to load after valid key (optional)
local KEY_FILE = "snoe_key_data.json"
local KEY_DURATION = 24 * 60 * 60 -- 24 hours in seconds

-- Check if saved key is still valid (within 24 hours)
local function checkSavedKey()
    local success, content = pcall(function()
        return readfile(KEY_FILE)
    end)
    if not success then return false end
    
    local ok, data = pcall(function()
        return HttpService:JSONDecode(content)
    end)
    if not ok then return false end
    
    if data and data.timestamp then
        local elapsed = os.time() - data.timestamp
        if elapsed < KEY_DURATION then
            return true -- still valid
        else
            pcall(function() delfile(KEY_FILE) end) -- expired, delete
        end
    end
    return false
end

-- Save key with timestamp
local function saveKey()
    pcall(function()
        local data = {timestamp = os.time()}
        writefile(KEY_FILE, HttpService:JSONEncode(data))
    end)
end

-- Validate key (one-time use with deleteToken=1)
local function validateKey(key)
    if not key or key == "" then return false end
    local success, response = pcall(function()
        return game:HttpGet("https://work.ink/_api/v2/token/isValid/" .. key .. "?deleteToken=1")
    end)
    if success then
        local data = HttpService:JSONDecode(response)
        return data.valid == true
    end
    return false
end

-- Check saved key first - skip UI if still valid
if checkSavedKey() then
    if SCRIPT_URL ~= "" then
        loadstring(game:HttpGet(SCRIPT_URL))()
    end
    return
end

-- Load DummyUI (same source as your working scripts)
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/x2zu/OPEN-SOURCE-UI-ROBLOX/refs/heads/main/X2ZU%20UI%20ROBLOX%20OPEN%20SOURCE/DummyUi-leak-by-x2zu/fetching-main/Tools/Framework.luau"))()

-- Create Window
local Window = Library:Window({
    Title = "Snoe Hub",
    Desc = "Key System",
    Theme = "Dark",
    Config = {
        Keybind = Enum.KeyCode.RightControl,
        Size = UDim2.new(0, 400, 0, 250)
    },
    CloseUIButton = {
        Enabled = true,
        Text = "Close"
    }
})

-- Key System Tab
local KeyTab = Window:Tab({Title = "Key System", Icon = "key"})

KeyTab:Section({Title = "Authentication"})

local keyInput = ""

KeyTab:Textbox({
    Title = "Enter Key",
    Desc = "Paste your key here",
    Placeholder = "Key...",
    Value = "",
    Callback = function(text)
        keyInput = text
    end
})

KeyTab:Button({
    Title = "Submit Key",
    Desc = "Validate and continue",
    Callback = function()
        if keyInput == "" then
            Window:Notify({Title = "Error", Desc = "Please enter a key!", Time = 3})
            return
        end
        
        Window:Notify({Title = "Checking...", Desc = "Validating key...", Time = 2})
        
        if validateKey(keyInput) then
            saveKey() -- Save timestamp for 24hr access
            Window:Notify({Title = "Success!", Desc = "Key valid for 24 hours!", Time = 3})
            
            task.wait(1)
            if SCRIPT_URL ~= "" then
                loadstring(game:HttpGet(SCRIPT_URL))()
            end
        else
            Window:Notify({Title = "Invalid", Desc = "Key is not valid or already used!", Time = 3})
        end
    end
})

KeyTab:Button({
    Title = "Get Key",
    Desc = "Copy key link to clipboard",
    Callback = function()
        setclipboard(KEY_LINK)
        Window:Notify({Title = "Copied!", Desc = "Paste link in your browser", Time = 3})
    end
})

Window:Notify({
    Title = "Key System",
    Desc = "Enter your key to continue",
    Time = 4
})
