--[[
    Toggle Element - iOS-style switch
]]

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(Tab, Parent, config)
    local self = setmetatable({}, Toggle)
    
    self.Tab = Tab
    self.SnoeUI = Tab.SnoeUI
    self.Title = config.Title or "Toggle"
    self.Desc = config.Desc
    self.Value = config.Default or false
    self.Callback = config.Callback or function() end
    self.Theme = Tab.Theme
    
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    
    local height = self.Desc and 44 or 32
    
    -- Container
    self.Frame = create("TextButton", {
        Name = self.Title,
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.3,
        Text = "",
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })
    
    -- Title
    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Parent = self.Frame,
        Position = UDim2.fromOffset(10, self.Desc and 6 or 0),
        Size = UDim2.new(1, -60, 0, self.Desc and 16 or height),
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
            Size = UDim2.new(1, -60, 0, 14),
            BackgroundTransparency = 1,
            Text = self.Desc,
            TextColor3 = self.Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 11,
        })
    end
    
    -- Switch track
    self.Track = create("Frame", {
        Name = "Track",
        Parent = self.Frame,
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(38, 20),
        BackgroundColor3 = self.Value and self.Theme.Accent or self.Theme.SurfaceHover,
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    
    -- Switch knob
    self.Knob = create("Frame", {
        Name = "Knob",
        Parent = self.Track,
        Position = self.Value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    
    -- Click handler
    self.Frame.MouseButton1Click:Connect(function()
        self:Set(not self.Value)
    end)
    
    -- Hover
    self.Frame.MouseEnter:Connect(function()
        spring(self.Frame, { BackgroundTransparency = 0.1 }, 0.15):Play()
    end)
    
    self.Frame.MouseLeave:Connect(function()
        spring(self.Frame, { BackgroundTransparency = 0.3 }, 0.15):Play()
    end)
    
    return self
end

function Toggle:Set(value, skipCallback)
    local spring = self.SnoeUI.Spring
    self.Value = value
    
    if value then
        spring(self.Track, { BackgroundColor3 = self.Theme.Accent }, 0.2):Play()
        spring(self.Knob, { Position = UDim2.new(1, -18, 0.5, 0) }, 0.2, Enum.EasingStyle.Back):Play()
    else
        spring(self.Track, { BackgroundColor3 = self.Theme.SurfaceHover }, 0.2):Play()
        spring(self.Knob, { Position = UDim2.new(0, 2, 0.5, 0) }, 0.2, Enum.EasingStyle.Back):Play()
    end
    
    if not skipCallback then
        self.Callback(value)
    end
end

function Toggle:Get()
    return self.Value
end

return Toggle
