--[[
    Keybind Element - Key binding selector
]]

local Keybind = {}
Keybind.__index = Keybind

local UserInputService = game:GetService("UserInputService")

function Keybind.new(Tab, Parent, config)
    local self = setmetatable({}, Keybind)
    
    self.Tab = Tab
    self.SnoeUI = Tab.SnoeUI
    self.Title = config.Title or "Keybind"
    self.Desc = config.Desc
    self.Value = config.Default or Enum.KeyCode.E
    self.Callback = config.Callback or function() end
    self.OnPress = config.OnPress or function() end
    self.Theme = Tab.Theme
    self.Listening = false
    
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    
    local height = self.Desc and 44 or 32
    
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
        Position = UDim2.fromOffset(10, self.Desc and 6 or 0),
        Size = UDim2.new(1, -80, 0, self.Desc and 16 or height),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    })
    
    -- Description
    if self.Desc then
        self.DescLabel = create("TextLabel", {
            Name = "Desc",
            Parent = self.Frame,
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -80, 0, 14),
            BackgroundTransparency = 1,
            Text = self.Desc,
            TextColor3 = self.Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 11,
        })
    end
    
    -- Keybind button
    self.KeyButton = create("TextButton", {
        Name = "KeyButton",
        Parent = self.Frame,
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.fromOffset(60, 24),
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = 0.3,
        Text = self:GetKeyName(),
        TextColor3 = self.Theme.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        create("UIStroke", {
            Color = self.Theme.Border,
            Thickness = 1,
            Transparency = 0.5,
        }),
    })
    
    -- Click to rebind
    self.KeyButton.MouseButton1Click:Connect(function()
        self:StartListening()
    end)
    
    -- Listen for key presses
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if self.Listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                self:Set(input.KeyCode)
                self:StopListening()
            end
        elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == self.Value then
                self.OnPress()
            end
        end
    end)
    
    return self
end

function Keybind:GetKeyName()
    if typeof(self.Value) == "EnumItem" then
        return self.Value.Name
    end
    return tostring(self.Value)
end

function Keybind:StartListening()
    local spring = self.SnoeUI.Spring
    self.Listening = true
    self.KeyButton.Text = "..."
    spring(self.KeyButton:FindFirstChild("UIStroke"), { Color = self.Theme.Accent, Transparency = 0 }, 0.2):Play()
end

function Keybind:StopListening()
    local spring = self.SnoeUI.Spring
    self.Listening = false
    self.KeyButton.Text = self:GetKeyName()
    spring(self.KeyButton:FindFirstChild("UIStroke"), { Color = self.Theme.Border, Transparency = 0.5 }, 0.2):Play()
end

function Keybind:Set(keyCode, skipCallback)
    self.Value = keyCode
    self.KeyButton.Text = self:GetKeyName()
    
    if not skipCallback then
        self.Callback(keyCode)
    end
end

function Keybind:Get()
    return self.Value
end

return Keybind
