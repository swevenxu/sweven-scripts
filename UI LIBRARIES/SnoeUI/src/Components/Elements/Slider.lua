--[[
    Slider Element
]]

local Slider = {}
Slider.__index = Slider

local UserInputService = game:GetService("UserInputService")

function Slider.new(Tab, Parent, config)
    local self = setmetatable({}, Slider)
    
    self.Tab = Tab
    self.SnoeUI = Tab.SnoeUI
    self.Title = config.Title or "Slider"
    self.Desc = config.Desc
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Value = config.Default or self.Min
    self.Step = config.Step or 1
    self.Suffix = config.Suffix or ""
    self.Callback = config.Callback or function() end
    self.Theme = Tab.Theme
    
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    
    local height = self.Desc and 56 or 44
    
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
        Size = UDim2.new(0.6, -10, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamMedium,
        TextSize = 13,
    })
    
    -- Value display
    self.ValueLabel = create("TextLabel", {
        Name = "Value",
        Parent = self.Frame,
        Position = UDim2.new(1, -10, 0, 6),
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0.4, -10, 0, 16),
        BackgroundTransparency = 1,
        Text = tostring(self.Value) .. self.Suffix,
        TextColor3 = self.Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
    })
    
    -- Description
    if self.Desc then
        self.DescLabel = create("TextLabel", {
            Name = "Desc",
            Parent = self.Frame,
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -20, 0, 12),
            BackgroundTransparency = 1,
            Text = self.Desc,
            TextColor3 = self.Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 11,
        })
    end
    
    -- Slider track
    local trackY = self.Desc and 42 or 28
    self.Track = create("Frame", {
        Name = "Track",
        Parent = self.Frame,
        Position = UDim2.new(0, 10, 0, trackY),
        Size = UDim2.new(1, -20, 0, 6),
        BackgroundColor3 = self.Theme.SurfaceHover,
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    
    -- Fill
    local percent = (self.Value - self.Min) / (self.Max - self.Min)
    self.Fill = create("Frame", {
        Name = "Fill",
        Parent = self.Track,
        Size = UDim2.new(percent, 0, 1, 0),
        BackgroundColor3 = self.Theme.Accent,
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    
    -- Knob
    self.Knob = create("Frame", {
        Name = "Knob",
        Parent = self.Track,
        Position = UDim2.new(percent, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    
    -- Interaction
    local dragging = false
    
    local function update(input)
        local trackPos = self.Track.AbsolutePosition.X
        local trackSize = self.Track.AbsoluteSize.X
        local mouseX = input.Position.X
        
        local percent = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
        local value = self.Min + (self.Max - self.Min) * percent
        
        -- Apply step
        value = math.floor(value / self.Step + 0.5) * self.Step
        value = math.clamp(value, self.Min, self.Max)
        
        self:Set(value)
    end
    
    self.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    return self
end

function Slider:Set(value, skipCallback)
    local spring = self.SnoeUI.Spring
    self.Value = value
    
    local percent = (value - self.Min) / (self.Max - self.Min)
    
    spring(self.Fill, { Size = UDim2.new(percent, 0, 1, 0) }, 0.1):Play()
    spring(self.Knob, { Position = UDim2.new(percent, 0, 0.5, 0) }, 0.1):Play()
    
    self.ValueLabel.Text = tostring(value) .. self.Suffix
    
    if not skipCallback then
        self.Callback(value)
    end
end

function Slider:Get()
    return self.Value
end

return Slider
