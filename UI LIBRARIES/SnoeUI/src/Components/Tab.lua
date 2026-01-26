--[[
    Tab Component - Navigation tabs with content sections
]]

local Tab = {}
Tab.__index = Tab

function Tab.new(Window, config)
    local self = setmetatable({}, Tab)
    
    self.Window = Window
    self.SnoeUI = Window.SnoeUI
    self.Title = config.Title or "Tab"
    self.Icon = config.Icon
    self.Elements = {}
    self.Selected = false
    self.Theme = Window.Theme
    
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    local Icons = self.SnoeUI.Icons
    
    -- Tab button
    self.Button = create("TextButton", {
        Name = self.Title,
        Parent = Window.TabList,
        Size = UDim2.new(1, -16, 0, 32),
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 1,
        Text = "",
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })
    
    -- Icon (if provided)
    if self.Icon then
        local iconFrame = Icons.Image({
            Icon = self.Icon,
            Size = UDim2.fromOffset(16, 16),
            Colors = { false, false },
        }).IconFrame
        iconFrame.Position = UDim2.fromOffset(10, 8)
        iconFrame.ImageColor3 = self.Theme.TextSecondary
        iconFrame.Parent = self.Button
        self.IconFrame = iconFrame
    end
    
    -- Tab label
    self.Label = create("TextLabel", {
        Name = "Label",
        Parent = self.Button,
        Position = UDim2.fromOffset(self.Icon and 32 or 10, 0),
        Size = UDim2.new(1, self.Icon and -42 or -20, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    
    -- Content frame
    self.Content = create("ScrollingFrame", {
        Name = self.Title .. "_Content",
        Parent = Window.Content,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 6),
        }),
        create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 10),
            PaddingRight = UDim.new(0, 10),
        }),
    })
    
    -- Hover effects
    self.Button.MouseEnter:Connect(function()
        if not self.Selected then
            spring(self.Button, { BackgroundTransparency = 0.7 }, 0.15):Play()
        end
    end)
    
    self.Button.MouseLeave:Connect(function()
        if not self.Selected then
            spring(self.Button, { BackgroundTransparency = 1 }, 0.15):Play()
        end
    end)
    
    self.Button.MouseButton1Click:Connect(function()
        self:Select()
    end)
    
    return self
end

function Tab:Select()
    local spring = self.SnoeUI.Spring
    
    -- Deselect all other tabs
    for _, tab in ipairs(self.Window.Tabs) do
        if tab ~= self and tab.Selected then
            tab.Selected = false
            tab.Content.Visible = false
            spring(tab.Button, { BackgroundTransparency = 1 }, 0.2):Play()
            spring(tab.Label, { TextColor3 = self.Theme.TextSecondary }, 0.2):Play()
            if tab.IconFrame then
                spring(tab.IconFrame, { ImageColor3 = self.Theme.TextSecondary }, 0.2):Play()
            end
        end
    end
    
    -- Select this tab
    self.Selected = true
    self.Content.Visible = true
    self.Window.CurrentTab = self
    
    spring(self.Button, { BackgroundTransparency = 0.5 }, 0.2):Play()
    spring(self.Label, { TextColor3 = self.Theme.Text }, 0.2):Play()
    if self.IconFrame then
        spring(self.IconFrame, { ImageColor3 = self.Theme.Accent }, 0.2):Play()
    end
end

-- Add Section
function Tab:Section(config)
    local Section = require(script.Parent.Section)
    return Section.new(self, config)
end

-- Add Button
function Tab:Button(config)
    local Button = require(script.Parent.Elements.Button)
    return Button.new(self, self.Content, config)
end

-- Add Toggle
function Tab:Toggle(config)
    local Toggle = require(script.Parent.Elements.Toggle)
    return Toggle.new(self, self.Content, config)
end

-- Add Slider
function Tab:Slider(config)
    local Slider = require(script.Parent.Elements.Slider)
    return Slider.new(self, self.Content, config)
end

-- Add Input
function Tab:Input(config)
    local Input = require(script.Parent.Elements.Input)
    return Input.new(self, self.Content, config)
end

-- Add Dropdown
function Tab:Dropdown(config)
    local Dropdown = require(script.Parent.Elements.Dropdown)
    return Dropdown.new(self, self.Content, config)
end

-- Add Keybind
function Tab:Keybind(config)
    local Keybind = require(script.Parent.Elements.Keybind)
    return Keybind.new(self, self.Content, config)
end

-- Add Label
function Tab:Label(config)
    local Label = require(script.Parent.Elements.Label)
    return Label.new(self, self.Content, config)
end

return Tab
