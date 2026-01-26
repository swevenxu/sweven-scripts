--[[
    Section Component - Collapsible content groups
]]

local Section = {}
Section.__index = Section

function Section.new(Tab, config)
    local self = setmetatable({}, Section)
    
    self.Tab = Tab
    self.SnoeUI = Tab.SnoeUI
    self.Title = config.Title or "Section"
    self.Opened = config.Opened ~= false
    self.Theme = Tab.Theme
    
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    
    -- Section container
    self.Container = create("Frame", {
        Name = self.Title,
        Parent = Tab.Content,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.5,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 8) }),
    })
    
    -- Header
    self.Header = create("TextButton", {
        Name = "Header",
        Parent = self.Container,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    -- Title label
    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Parent = self.Header,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
    })
    
    -- Arrow indicator
    self.Arrow = create("TextLabel", {
        Name = "Arrow",
        Parent = self.Header,
        Position = UDim2.new(1, -24, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = self.Theme.TextSecondary,
        Font = Enum.Font.GothamMedium,
        TextSize = 8,
        Rotation = self.Opened and 0 or -90,
    })
    
    -- Content holder
    self.Content = create("Frame", {
        Name = "Content",
        Parent = self.Container,
        Position = UDim2.fromOffset(0, 28),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = self.Opened,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 4),
        }),
        create("UIPadding", {
            PaddingTop = UDim.new(0, 2),
            PaddingBottom = UDim.new(0, 8),
            PaddingLeft = UDim.new(0, 8),
            PaddingRight = UDim.new(0, 8),
        }),
    })
    
    -- Toggle section
    self.Header.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    return self
end

function Section:Toggle()
    local spring = self.SnoeUI.Spring
    self.Opened = not self.Opened
    
    if self.Opened then
        self.Content.Visible = true
        spring(self.Arrow, { Rotation = 0 }, 0.2):Play()
    else
        spring(self.Arrow, { Rotation = -90 }, 0.2):Play()
        task.delay(0.2, function()
            if not self.Opened then
                self.Content.Visible = false
            end
        end)
    end
end

-- Element methods
function Section:Button(config)
    local Button = require(script.Parent.Elements.Button)
    return Button.new(self.Tab, self.Content, config)
end

function Section:Toggle(config)
    local Toggle = require(script.Parent.Elements.Toggle)
    return Toggle.new(self.Tab, self.Content, config)
end

function Section:Slider(config)
    local Slider = require(script.Parent.Elements.Slider)
    return Slider.new(self.Tab, self.Content, config)
end

function Section:Input(config)
    local Input = require(script.Parent.Elements.Input)
    return Input.new(self.Tab, self.Content, config)
end

function Section:Dropdown(config)
    local Dropdown = require(script.Parent.Elements.Dropdown)
    return Dropdown.new(self.Tab, self.Content, config)
end

function Section:Keybind(config)
    local Keybind = require(script.Parent.Elements.Keybind)
    return Keybind.new(self.Tab, self.Content, config)
end

function Section:Label(config)
    local Label = require(script.Parent.Elements.Label)
    return Label.new(self.Tab, self.Content, config)
end

return Section
