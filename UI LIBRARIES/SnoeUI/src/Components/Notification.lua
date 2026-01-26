--[[
    Notification Component - Toast notifications
]]

local Notification = {}
Notification.__index = Notification

local notifications = {}
local notificationHolder = nil

function Notification.new(SnoeUI, config)
    local self = setmetatable({}, Notification)
    
    self.SnoeUI = SnoeUI
    self.Title = config.Title or "Notification"
    self.Content = config.Content or ""
    self.Duration = config.Duration or 3
    self.Icon = config.Icon
    self.Theme = SnoeUI.Theme
    
    local create = SnoeUI.Create
    local spring = SnoeUI.Spring
    local Icons = SnoeUI.Icons
    
    -- Create holder if not exists
    if not notificationHolder then
        notificationHolder = create("Frame", {
            Name = "Notifications",
            Parent = SnoeUI.ScreenGui,
            Position = UDim2.new(1, -20, 1, -20),
            AnchorPoint = Vector2.new(1, 1),
            Size = UDim2.fromOffset(280, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
        }, {
            create("UIListLayout", {
                Padding = UDim.new(0, 8),
                VerticalAlignment = Enum.VerticalAlignment.Bottom,
                HorizontalAlignment = Enum.HorizontalAlignment.Right,
            }),
        })
    end
    
    -- Notification frame
    self.Frame = create("Frame", {
        Name = "Notification",
        Parent = notificationHolder,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        create("UIStroke", {
            Color = self.Theme.Border,
            Thickness = 1,
            Transparency = 0.5,
        }),
        create("UIPadding", {
            PaddingTop = UDim.new(0, 10),
            PaddingBottom = UDim.new(0, 10),
            PaddingLeft = UDim.new(0, 12),
            PaddingRight = UDim.new(0, 12),
        }),
    })
    
    -- Icon
    local contentOffset = 0
    if self.Icon then
        local iconFrame = Icons.Image({
            Icon = self.Icon,
            Size = UDim2.fromOffset(18, 18),
            Colors = { false, false },
        }).IconFrame
        iconFrame.Position = UDim2.fromOffset(0, 2)
        iconFrame.ImageColor3 = self.Theme.Accent
        iconFrame.Parent = self.Frame
        contentOffset = 28
    end
    
    -- Title
    create("TextLabel", {
        Name = "Title",
        Parent = self.Frame,
        Position = UDim2.fromOffset(contentOffset, 0),
        Size = UDim2.new(1, -contentOffset, 0, 18),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
    })
    
    -- Content
    if self.Content ~= "" then
        create("TextLabel", {
            Name = "Content",
            Parent = self.Frame,
            Position = UDim2.fromOffset(contentOffset, 20),
            Size = UDim2.new(1, -contentOffset, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = self.Content,
            TextColor3 = self.Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
        })
    end
    
    -- Animate in
    self.Frame.Position = UDim2.new(1, 50, 0, 0)
    spring(self.Frame, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back):Play()
    
    -- Auto dismiss
    if self.Duration > 0 then
        task.delay(self.Duration, function()
            self:Dismiss()
        end)
    end
    
    table.insert(notifications, self)
    return self
end

function Notification:Dismiss()
    local spring = self.SnoeUI.Spring
    spring(self.Frame, { Position = UDim2.new(1, 50, 0, 0) }, 0.25):Play()
    task.delay(0.25, function()
        self.Frame:Destroy()
        for i, n in ipairs(notifications) do
            if n == self then
                table.remove(notifications, i)
                break
            end
        end
    end)
end

return Notification
