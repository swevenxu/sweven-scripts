--[[
    Input Element - Text input field
]]

local Input = {}
Input.__index = Input

function Input.new(Tab, Parent, config)
    local self = setmetatable({}, Input)
    
    self.Tab = Tab
    self.SnoeUI = Tab.SnoeUI
    self.Title = config.Title or "Input"
    self.Desc = config.Desc
    self.Placeholder = config.Placeholder or "Enter text..."
    self.Value = config.Default or ""
    self.Callback = config.Callback or function() end
    self.Theme = Tab.Theme
    
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    
    local height = self.Desc and 64 or 52
    
    -- Container
    self.Frame = create("Frame", {
        Name = self.Title,
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.3,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })
    
    -- Title
    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Parent = self.Frame,
        Position = UDim2.fromOffset(10, 6),
        Size = UDim2.new(1, -20, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    })
    
    -- Description
    local inputY = 26
    if self.Desc then
        self.DescLabel = create("TextLabel", {
            Name = "Desc",
            Parent = self.Frame,
            Position = UDim2.fromOffset(10, 22),
            Size = UDim2.new(1, -20, 0, 12),
            BackgroundTransparency = 1,
            Text = self.Desc,
            TextColor3 = self.Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 11,
        })
        inputY = 38
    end
    
    -- Input box container
    self.InputContainer = create("Frame", {
        Name = "InputContainer",
        Parent = self.Frame,
        Position = UDim2.new(0, 10, 0, inputY),
        Size = UDim2.new(1, -20, 0, 22),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.3,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        create("UIStroke", {
            Color = self.Theme.Border,
            Thickness = 1,
            Transparency = 0.5,
        }),
    })
    
    -- TextBox
    self.TextBox = create("TextBox", {
        Name = "TextBox",
        Parent = self.InputContainer,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Value,
        PlaceholderText = self.Placeholder,
        PlaceholderColor3 = self.Theme.TextSecondary,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        ClearTextOnFocus = false,
    })
    
    -- Focus effects
    self.TextBox.Focused:Connect(function()
        spring(self.InputContainer:FindFirstChild("UIStroke"), { Color = self.Theme.Accent, Transparency = 0 }, 0.2):Play()
    end)
    
    self.TextBox.FocusLost:Connect(function(enterPressed)
        spring(self.InputContainer:FindFirstChild("UIStroke"), { Color = self.Theme.Border, Transparency = 0.5 }, 0.2):Play()
        self.Value = self.TextBox.Text
        self.Callback(self.Value, enterPressed)
    end)
    
    return self
end

function Input:Set(value)
    self.Value = value
    self.TextBox.Text = value
end

function Input:Get()
    return self.Value
end

return Input
