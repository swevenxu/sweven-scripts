--[[
    Window Component - Main container for the UI
]]

local Window = {}
Window.__index = Window

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

function Window.new(SnoeUI, config)
    local self = setmetatable({}, Window)
    
    self.SnoeUI = SnoeUI
    self.Title = config.Title or "Window"
    self.Size = config.Size or UDim2.fromOffset(380, 480)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    self.Theme = SnoeUI.Theme
    
    local create = SnoeUI.Create
    local spring = SnoeUI.Spring
    
    -- Main container
    self.Main = create("Frame", {
        Name = "Window",
        Parent = SnoeUI.ScreenGui,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = self.Size,
        BackgroundColor3 = self.Theme.Background,
        BackgroundTransparency = self.Theme.Transparency,
        ClipsDescendants = true,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        create("UIStroke", {
            Color = self.Theme.Border,
            Thickness = 1,
            Transparency = 0.5,
        }),
    })
    
    -- Topbar
    self.Topbar = create("Frame", {
        Name = "Topbar",
        Parent = self.Main,
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
    })
    
    -- Title
    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Parent = self.Topbar,
        Position = UDim2.fromOffset(12, 0),
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = self.Title,
        TextColor3 = self.Theme.Text,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
    })
    
    -- Close button
    self.CloseBtn = create("TextButton", {
        Name = "Close",
        Parent = self.Topbar,
        Position = UDim2.new(1, -32, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = self.Theme.Error,
        BackgroundTransparency = 0.8,
        Text = "",
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    
    self.CloseBtn.MouseEnter:Connect(function()
        spring(self.CloseBtn, { BackgroundTransparency = 0.4 }, 0.2):Play()
    end)
    self.CloseBtn.MouseLeave:Connect(function()
        spring(self.CloseBtn, { BackgroundTransparency = 0.8 }, 0.2):Play()
    end)
    self.CloseBtn.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    -- Minimize button
    self.MinBtn = create("TextButton", {
        Name = "Minimize",
        Parent = self.Topbar,
        Position = UDim2.new(1, -56, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundColor3 = self.Theme.Warning,
        BackgroundTransparency = 0.8,
        Text = "",
    }, {
        create("UICorner", { CornerRadius = UDim.new(1, 0) }),
    })
    
    self.MinBtn.MouseEnter:Connect(function()
        spring(self.MinBtn, { BackgroundTransparency = 0.4 }, 0.2):Play()
    end)
    self.MinBtn.MouseLeave:Connect(function()
        spring(self.MinBtn, { BackgroundTransparency = 0.8 }, 0.2):Play()
    end)
    self.MinBtn.MouseButton1Click:Connect(function()
        self:Minimize()
    end)
    
    -- Divider
    create("Frame", {
        Name = "Divider",
        Parent = self.Main,
        Position = UDim2.fromOffset(0, 40),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = self.Theme.Border,
        BackgroundTransparency = 0.5,
    })
    
    -- Tab container (left side)
    self.TabList = create("ScrollingFrame", {
        Name = "TabList",
        Parent = self.Main,
        Position = UDim2.fromOffset(0, 41),
        Size = UDim2.new(0, 120, 1, -41),
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 4),
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }),
        create("UIPadding", {
            PaddingTop = UDim.new(0, 8),
            PaddingBottom = UDim.new(0, 8),
        }),
    })
    
    -- Content container (right side)
    self.Content = create("Frame", {
        Name = "Content",
        Parent = self.Main,
        Position = UDim2.fromOffset(120, 41),
        Size = UDim2.new(1, -120, 1, -41),
        BackgroundTransparency = 1,
    })
    
    -- Dragging
    self:SetupDrag()
    
    -- Open animation
    self.Main.Size = UDim2.fromOffset(self.Size.X.Offset, 0)
    self.Main.BackgroundTransparency = 1
    spring(self.Main, { Size = self.Size, BackgroundTransparency = self.Theme.Transparency }, 0.4, Enum.EasingStyle.Back):Play()
    
    return self
end

function Window:SetupDrag()
    local dragging, dragStart, startPos
    
    self.Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = self.Main.Position
        end
    end)
    
    self.Topbar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            self.Main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

function Window:Tab(config)
    local Tab = require(script.Parent.Tab)
    local tab = Tab.new(self, config)
    table.insert(self.Tabs, tab)
    
    if #self.Tabs == 1 then
        tab:Select()
    end
    
    return tab
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    local spring = self.SnoeUI.Spring
    
    if self.Minimized then
        spring(self.Main, { Size = UDim2.fromOffset(self.Size.X.Offset, 40) }, 0.3, Enum.EasingStyle.Back):Play()
    else
        spring(self.Main, { Size = self.Size }, 0.3, Enum.EasingStyle.Back):Play()
    end
end

function Window:Close()
    local spring = self.SnoeUI.Spring
    spring(self.Main, { Size = UDim2.fromOffset(self.Size.X.Offset, 0), BackgroundTransparency = 1 }, 0.3):Play()
    task.delay(0.3, function()
        self.Main:Destroy()
    end)
end

function Window:SetTitle(title)
    self.TitleLabel.Text = title
end

return Window
