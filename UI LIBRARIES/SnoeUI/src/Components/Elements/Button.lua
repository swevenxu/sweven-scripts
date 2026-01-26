--[[
    Button Element
]]

local Button = {}
Button.__index = Button

function Button.new(Tab, Parent, config)
    local self = setmetatable({}, Button)
    
    self.Tab = Tab
    self.SnoeUI = Tab.SnoeUI
    self.Title = config.Title or "Button"
    self.Desc = config.Desc
    self.Icon = config.Icon
    self.Callback = config.Callback or function() end
    self.Theme = Tab.Theme
    
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    local Icons = self.SnoeUI.Icons
    
    local height = self.Desc and 44 or 32
    
    -- Button frame
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
    
    -- Icon
    local textOffset = 10
    if self.Icon then
        local iconFrame = Icons.Image({
            Icon = self.Icon,
            Size = UDim2.fromOffset(16, 16),
            Colors = { false, false },
        }).IconFrame
        iconFrame.Position = UDim2.new(0, 10, 0.5, 0)
        iconFrame.AnchorPoint = Vector2.new(0, 0.5)
        iconFrame.ImageColor3 = self.Theme.TextSecondary
        iconFrame.Parent = self.Frame
        self.IconFrame = iconFrame
        textOffset = 34
    end
    
    -- Title
    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Parent = self.Frame,
        Position = UDim2.fromOffset(textOffset, self.Desc and 6 or 0),
        Size = UDim2.new(1, -textOffset - 10, 0, self.Desc and 16 or height),
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
            Position = UDim2.fromOffset(textOffset, 24),
            Size = UDim2.new(1, -textOffset - 10, 0, 14),
            BackgroundTransparency = 1,
            Text = self.Desc,
            TextColor3 = self.Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 11,
        })
    end
    
    -- Hover & Click
    self.Frame.MouseEnter:Connect(function()
        spring(self.Frame, { BackgroundTransparency = 0.1 }, 0.15):Play()
    end)
    
    self.Frame.MouseLeave:Connect(function()
        spring(self.Frame, { BackgroundTransparency = 0.3 }, 0.15):Play()
    end)
    
    self.Frame.MouseButton1Click:Connect(function()
        -- Click feedback
        spring(self.Frame, { BackgroundTransparency = 0 }, 0.05):Play()
        task.delay(0.05, function()
            spring(self.Frame, { BackgroundTransparency = 0.1 }, 0.1):Play()
        end)
        
        self.Callback()
    end)
    
    return self
end

function Button:SetTitle(title)
    self.TitleLabel.Text = title
end

function Button:SetCallback(callback)
    self.Callback = callback
end

return Button
