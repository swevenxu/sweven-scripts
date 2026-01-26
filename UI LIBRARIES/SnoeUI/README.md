# SnoeUI

A minimal, SwiftUI-inspired UI library for Roblox scripts.

## Usage

```lua
local SnoeUI = loadstring(game:HttpGet("https://raw.githubusercontent.com/swevenxu/snoeUI/main/SnoeUI.lua"))()

local Window = SnoeUI:CreateWindow({
    Title = "My Script",
    Size = UDim2.fromOffset(360, 340),
})

local MainTab = Window:Tab({
    Title = "Main",
    Icon = "home",
})

MainTab:Button({
    Title = "Click Me",
    Callback = function()
        print("Clicked!")
    end,
})

MainTab:Toggle({
    Title = "Enable Feature",
    Default = false,
    Callback = function(value)
        print("Toggle:", value)
    end,
})

MainTab:Slider({
    Title = "Speed",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(value)
        print("Slider:", value)
    end,
})
```

## Elements

- `Button` - Clickable button
- `Toggle` - iOS-style switch
- `Slider` - Value slider
- `Input` - Text input field
- `Dropdown` - Selection menu
- `Keybind` - Key binding selector
- `Label` - Text label
- `Section` - Collapsible group

## Notifications

```lua
SnoeUI:Notify({
    Title = "Hello",
    Content = "Welcome!",
    Icon = "check",
    Duration = 3,
})
```
