--[[
    SnoeUI Example
    Demonstrates the minimal, SwiftUI-inspired UI library
]]

-- Load SnoeUI (adjust path as needed)
local SnoeUI = require(script.Parent.src.Init)

-- Create window
local Window = SnoeUI:CreateWindow({
    Title = "SnoeUI Example",
    Size = UDim2.fromOffset(400, 500),
})

-- Main tab
local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
})

MainTab:Label({ Text = "Welcome to SnoeUI!" })

MainTab:Button({
    Title = "Click Me",
    Desc = "A simple button example",
    Icon = "mouse-pointer",
    Callback = function()
        SnoeUI:Notify({
            Title = "Button Clicked",
            Content = "You clicked the button!",
            Icon = "check",
            Duration = 3,
        })
    end,
})

MainTab:Toggle({
    Title = "Enable Feature",
    Desc = "Toggle this feature on or off",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

MainTab:Slider({
    Title = "Speed",
    Desc = "Adjust the speed value",
    Min = 0,
    Max = 100,
    Default = 50,
    Step = 5,
    Suffix = "%",
    Callback = function(value)
        print("Slider:", value)
    end,
})

MainTab:Input({
    Title = "Username",
    Placeholder = "Enter your name...",
    Callback = function(value)
        print("Input:", value)
    end,
})

MainTab:Dropdown({
    Title = "Select Option",
    Options = { "Option 1", "Option 2", "Option 3" },
    Default = "Option 1",
    Callback = function(value)
        print("Dropdown:", value)
    end,
})

MainTab:Keybind({
    Title = "Toggle UI",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        print("Keybind changed to:", key)
    end,
    OnPress = function()
        print("Keybind pressed!")
    end,
})

-- Settings tab
local SettingsTab = Window:Tab({
    Title = "Settings",
    Icon = "settings",
})

local GeneralSection = SettingsTab:Section({
    Title = "General",
})

GeneralSection:Toggle({
    Title = "Auto Save",
    Default = true,
    Callback = function(value)
        print("Auto Save:", value)
    end,
})

GeneralSection:Toggle({
    Title = "Notifications",
    Default = true,
    Callback = function(value)
        print("Notifications:", value)
    end,
})

local AppearanceSection = SettingsTab:Section({
    Title = "Appearance",
})

AppearanceSection:Dropdown({
    Title = "Theme",
    Options = { "Dark", "Light", "Blue" },
    Default = "Dark",
    Callback = function(value)
        print("Theme:", value)
    end,
})

AppearanceSection:Slider({
    Title = "UI Scale",
    Min = 50,
    Max = 150,
    Default = 100,
    Step = 10,
    Suffix = "%",
    Callback = function(value)
        print("Scale:", value)
    end,
})

-- Info tab
local InfoTab = Window:Tab({
    Title = "Info",
    Icon = "info",
})

InfoTab:Label({ Text = "SnoeUI v" .. SnoeUI.Version })
InfoTab:Label({ Text = "A minimal UI library" })

InfoTab:Button({
    Title = "Join Discord",
    Icon = "message-circle",
    Callback = function()
        -- setclipboard("discord.gg/example")
        SnoeUI:Notify({
            Title = "Discord",
            Content = "Link copied to clipboard!",
            Duration = 2,
        })
    end,
})

InfoTab:Button({
    Title = "Destroy UI",
    Icon = "x",
    Callback = function()
        Window:Close()
    end,
})

print("SnoeUI Example loaded!")
