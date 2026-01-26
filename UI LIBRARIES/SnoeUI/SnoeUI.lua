--[[
    SnoeUI - Bundled Single-File Version
    A minimal, SwiftUI-inspired UI library for Roblox
    
    Execute this directly in your Roblox executor for preview
]]

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

-- Icons from WindUI
local Icons
pcall(function()
    local IconsURL = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
    Icons = loadstring(game:HttpGet(IconsURL))()
    Icons.SetIconsType("lucide")
end)

-- Utility functions
local function spring(obj, props, duration, style)
    style = style or Enum.EasingStyle.Quint
    return TweenService:Create(obj, TweenInfo.new(duration or 0.3, style, Enum.EasingDirection.Out), props)
end

local function create(class, props, children)
    local obj = Instance.new(class)
    if class == "Frame" or class == "TextLabel" or class == "TextButton" or class == "TextBox" then
        obj.BorderSizePixel = 0
        obj.BackgroundColor3 = Color3.new(1, 1, 1)
    end
    if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
        obj.TextColor3 = Color3.new(1, 1, 1)
        obj.Font = Enum.Font.Gotham
        obj.TextSize = 14
    end
    if class == "ScrollingFrame" then
        obj.BorderSizePixel = 0
        obj.ScrollBarThickness = 2
        obj.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        obj.ScrollBarImageTransparency = 0.5
    end
    if class == "ImageLabel" or class == "ImageButton" then
        obj.BackgroundTransparency = 1
    end
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    for _, child in ipairs(children or {}) do
        child.Parent = obj
    end
    return obj
end

-- Theme
local Theme = {
    Background = Color3.fromRGB(12, 12, 14),
    Surface = Color3.fromRGB(22, 22, 26),
    SurfaceHover = Color3.fromRGB(32, 32, 38),
    Accent = Color3.fromRGB(88, 101, 242),
    Text = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(160, 160, 170),
    Border = Color3.fromRGB(45, 45, 55),
    Success = Color3.fromRGB(67, 181, 129),
    Warning = Color3.fromRGB(250, 166, 26),
    Error = Color3.fromRGB(237, 66, 69),
    Transparency = 0.15,
}

-- SnoeUI Main
local SnoeUI = {
    Version = "1.0.0",
    Theme = Theme,
    Create = create,
    Spring = spring,
    Icons = Icons,
}

-- Initialize ScreenGui
local GUIParent = (gethui and gethui()) or CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
SnoeUI.ScreenGui = create("ScreenGui", {
    Name = "SnoeUI",
    Parent = GUIParent,
    ResetOnSpawn = false,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    IgnoreGuiInset = true,
})
if syn and syn.protect_gui then syn.protect_gui(SnoeUI.ScreenGui) end

-- Notification holder
local notificationHolder = nil
local notifications = {}

function SnoeUI:Notify(config)
    local Title = config.Title or "Notification"
    local Content = config.Content or ""
    local Duration = config.Duration or 3
    local Icon = config.Icon
    
    if not notificationHolder then
        notificationHolder = create("Frame", {
            Name = "Notifications",
            Parent = self.ScreenGui,
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
    
    local frame = create("Frame", {
        Name = "Notification",
        Parent = notificationHolder,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 8) }),
        create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
        create("UIPadding", { PaddingTop = UDim.new(0, 10), PaddingBottom = UDim.new(0, 10), PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12) }),
    })
    
    local contentOffset = 0
    if Icon and Icons then
        pcall(function()
            local iconFrame = Icons.Image({ Icon = Icon, Size = UDim2.fromOffset(18, 18), Colors = { false, false } }).IconFrame
            iconFrame.Position = UDim2.fromOffset(0, 2)
            iconFrame.ImageColor3 = Theme.Accent
            iconFrame.Parent = frame
            contentOffset = 28
        end)
    end
    
    create("TextLabel", {
        Name = "Title", Parent = frame,
        Position = UDim2.fromOffset(contentOffset, 0),
        Size = UDim2.new(1, -contentOffset, 0, 18),
        BackgroundTransparency = 1, Text = Title,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 14,
    })
    
    if Content ~= "" then
        create("TextLabel", {
            Name = "Content", Parent = frame,
            Position = UDim2.fromOffset(contentOffset, 20),
            Size = UDim2.new(1, -contentOffset, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1, Text = Content,
            TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true, Font = Enum.Font.Gotham, TextSize = 11,
        })
    end
    
    frame.Position = UDim2.new(1, 50, 0, 0)
    spring(frame, { Position = UDim2.new(0, 0, 0, 0) }, 0.3, Enum.EasingStyle.Back):Play()
    
    if Duration > 0 then
        task.delay(Duration, function()
            spring(frame, { Position = UDim2.new(1, 50, 0, 0) }, 0.25):Play()
            task.delay(0.25, function() frame:Destroy() end)
        end)
    end
    
    return frame
end

-- Window Class
local Window = {}
Window.__index = Window

function SnoeUI:CreateWindow(config)
    local self = setmetatable({}, Window)
    self.SnoeUI = SnoeUI
    self.Title = config.Title or "Window"
    self.Size = config.Size or UDim2.fromOffset(380, 480)
    self.Tabs = {}
    self.CurrentTab = nil
    self.Minimized = false
    self.Theme = Theme
    
    self.Main = create("Frame", {
        Name = "Window", Parent = SnoeUI.ScreenGui,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = self.Size,
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = Theme.Transparency,
        ClipsDescendants = true,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 10) }),
        create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
    })
    
    -- Topbar
    self.Topbar = create("Frame", {
        Name = "Topbar", Parent = self.Main,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
    })
    
    self.TitleLabel = create("TextLabel", {
        Name = "Title", Parent = self.Topbar,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -70, 1, 0),
        BackgroundTransparency = 1, Text = self.Title,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 16,
    })
    
    -- Minimize button (text style)
    self.MinBtn = create("TextButton", {
        Name = "Minimize", Parent = self.Topbar,
        Position = UDim2.new(1, -36, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(20, 20),
        BackgroundTransparency = 1,
        Text = "—",
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
    })
    
    self.MinBtn.MouseEnter:Connect(function() spring(self.MinBtn, { TextColor3 = Theme.Text }, 0.15):Play() end)
    self.MinBtn.MouseLeave:Connect(function() spring(self.MinBtn, { TextColor3 = Theme.TextSecondary }, 0.15):Play() end)
    self.MinBtn.MouseButton1Click:Connect(function() self:Minimize() end)
    
    -- Divider
    create("Frame", {
        Name = "Divider", Parent = self.Main,
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BackgroundTransparency = 0.5,
    })
    
    -- Tab list
    self.TabList = create("ScrollingFrame", {
        Name = "TabList", Parent = self.Main,
        Position = UDim2.fromOffset(0, 33),
        Size = UDim2.new(0, 100, 1, -33),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 4), HorizontalAlignment = Enum.HorizontalAlignment.Center }),
        create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8) }),
    })
    
    -- Content
    self.Content = create("Frame", {
        Name = "Content", Parent = self.Main,
        Position = UDim2.fromOffset(100, 33),
        Size = UDim2.new(1, -100, 1, -33),
        BackgroundTransparency = 1,
        ClipsDescendants = false,
    })
    
    -- Dragging
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
            self.Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    -- Open animation
    self.Main.Size = UDim2.fromOffset(self.Size.X.Offset, 0)
    self.Main.BackgroundTransparency = 1
    spring(self.Main, { Size = self.Size, BackgroundTransparency = Theme.Transparency }, 0.4, Enum.EasingStyle.Back):Play()
    
    return self
end

function Window:Minimize()
    self.Minimized = not self.Minimized
    if self.Minimized then
        spring(self.Main, { Size = UDim2.fromOffset(self.Size.X.Offset, 32) }, 0.3, Enum.EasingStyle.Back):Play()
    else
        spring(self.Main, { Size = self.Size }, 0.3, Enum.EasingStyle.Back):Play()
    end
end

function Window:Close()
    spring(self.Main, { Size = UDim2.fromOffset(self.Size.X.Offset, 0), BackgroundTransparency = 1 }, 0.3):Play()
    task.delay(0.3, function() self.Main:Destroy() end)
end

-- Tab Class
local Tab = {}
Tab.__index = Tab

function Window:Tab(config)
    local tab = setmetatable({}, Tab)
    tab.Window = self
    tab.SnoeUI = self.SnoeUI
    tab.Title = config.Title or "Tab"
    tab.Icon = config.Icon
    tab.Elements = {}
    tab.Selected = false
    tab.Theme = Theme
    
    tab.Button = create("TextButton", {
        Name = tab.Title, Parent = self.TabList,
        Size = UDim2.new(1, -12, 0, 26),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 1, Text = "",
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    
    if tab.Icon and Icons then
        pcall(function()
            local iconFrame = Icons.Image({ Icon = tab.Icon, Size = UDim2.fromOffset(14, 14), Colors = { false, false } }).IconFrame
            iconFrame.Position = UDim2.fromOffset(8, 6)
            iconFrame.ImageColor3 = Theme.TextSecondary
            iconFrame.Parent = tab.Button
            tab.IconFrame = iconFrame
        end)
    end
    
    tab.Label = create("TextLabel", {
        Name = "Label", Parent = tab.Button,
        Position = UDim2.fromOffset(tab.Icon and 26 or 8, 0),
        Size = UDim2.new(1, tab.Icon and -34 or -16, 1, 0),
        BackgroundTransparency = 1, Text = tab.Title,
        TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    
    tab.Content = create("ScrollingFrame", {
        Name = tab.Title .. "_Content", Parent = self.Content,
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1, Visible = (#self.Tabs == 0),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollingDirection = Enum.ScrollingDirection.Y,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 6), SortOrder = Enum.SortOrder.LayoutOrder, FillDirection = Enum.FillDirection.Vertical }),
        create("UIPadding", { PaddingTop = UDim.new(0, 8), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10) }),
    })
    
    tab.Button.MouseEnter:Connect(function()
        if not tab.Selected then spring(tab.Button, { BackgroundTransparency = 0.7 }, 0.15):Play() end
    end)
    tab.Button.MouseLeave:Connect(function()
        if not tab.Selected then spring(tab.Button, { BackgroundTransparency = 1 }, 0.15):Play() end
    end)
    tab.Button.MouseButton1Click:Connect(function() tab:Select() end)
    
    table.insert(self.Tabs, tab)
    if #self.Tabs == 1 then 
        tab.Selected = true
        self.CurrentTab = tab
        spring(tab.Button, { BackgroundTransparency = 0.5 }, 0.2):Play()
        spring(tab.Label, { TextColor3 = Theme.Text }, 0.2):Play()
        if tab.IconFrame then spring(tab.IconFrame, { ImageColor3 = Theme.Accent }, 0.2):Play() end
    end
    
    return tab
end

function Tab:Select()
    for _, t in ipairs(self.Window.Tabs) do
        if t ~= self and t.Selected then
            t.Selected = false
            t.Content.Visible = false
            spring(t.Button, { BackgroundTransparency = 1 }, 0.2):Play()
            spring(t.Label, { TextColor3 = Theme.TextSecondary }, 0.2):Play()
            if t.IconFrame then spring(t.IconFrame, { ImageColor3 = Theme.TextSecondary }, 0.2):Play() end
        end
    end
    self.Selected = true
    self.Content.Visible = true
    self.Window.CurrentTab = self
    spring(self.Button, { BackgroundTransparency = 0.5 }, 0.2):Play()
    spring(self.Label, { TextColor3 = Theme.Text }, 0.2):Play()
    if self.IconFrame then spring(self.IconFrame, { ImageColor3 = Theme.Accent }, 0.2):Play() end
end

-- Button Element
function Tab:Button(config)
    local Title = config.Title or "Button"
    local Desc = config.Desc
    local Icon = config.Icon
    local Callback = config.Callback or function() end
    local height = Desc and 36 or 26
    
    local frame = create("TextButton", {
        Name = Title, Parent = self.Content,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3, Text = "",
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    
    local textOffset = 10
    if Icon and Icons then
        pcall(function()
            local iconFrame = Icons.Image({ Icon = Icon, Size = UDim2.fromOffset(16, 16), Colors = { false, false } }).IconFrame
            iconFrame.Position = UDim2.new(0, 10, 0.5, 0)
            iconFrame.AnchorPoint = Vector2.new(0, 0.5)
            iconFrame.ImageColor3 = Theme.TextSecondary
            iconFrame.Parent = frame
            textOffset = 34
        end)
    end
    
    create("TextLabel", {
        Name = "Title", Parent = frame,
        Position = UDim2.fromOffset(textOffset, Desc and 6 or 0),
        Size = UDim2.new(1, -textOffset - 10, 0, Desc and 16 or height),
        BackgroundTransparency = 1, Text = Title,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 14,
    })
    
    if Desc then
        create("TextLabel", {
            Name = "Desc", Parent = frame,
            Position = UDim2.fromOffset(textOffset, 24),
            Size = UDim2.new(1, -textOffset - 10, 0, 14),
            BackgroundTransparency = 1, Text = Desc,
            TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, TextSize = 10,
        })
    end
    
    frame.MouseEnter:Connect(function() spring(frame, { BackgroundTransparency = 0.1 }, 0.15):Play() end)
    frame.MouseLeave:Connect(function() spring(frame, { BackgroundTransparency = 0.3 }, 0.15):Play() end)
    frame.MouseButton1Click:Connect(function()
        spring(frame, { BackgroundTransparency = 0 }, 0.05):Play()
        task.delay(0.05, function() spring(frame, { BackgroundTransparency = 0.1 }, 0.1):Play() end)
        Callback()
    end)
    
    return { Frame = frame }
end

-- Toggle Element
function Tab:Toggle(config)
    local Title = config.Title or "Toggle"
    local Desc = config.Desc
    local Value = config.Default or false
    local Callback = config.Callback or function() end
    local height = Desc and 36 or 26
    
    local frame = create("TextButton", {
        Name = Title, Parent = self.Content,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3, Text = "",
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    
    create("TextLabel", {
        Name = "Title", Parent = frame,
        Position = UDim2.fromOffset(10, Desc and 6 or 0),
        Size = UDim2.new(1, -60, 0, Desc and 16 or height),
        BackgroundTransparency = 1, Text = Title,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 14,
    })
    
    if Desc then
        create("TextLabel", {
            Name = "Desc", Parent = frame,
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -60, 0, 14),
            BackgroundTransparency = 1, Text = Desc,
            TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, TextSize = 10,
        })
    end
    
    local track = create("Frame", {
        Name = "Track", Parent = frame,
        Position = UDim2.new(1, -48, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(38, 20),
        BackgroundColor3 = Value and Theme.Accent or Theme.SurfaceHover,
    }, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    
    local knob = create("Frame", {
        Name = "Knob", Parent = track,
        Position = Value and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(16, 16),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    
    local function set(v)
        Value = v
        if v then
            spring(track, { BackgroundColor3 = Theme.Accent }, 0.2):Play()
            spring(knob, { Position = UDim2.new(1, -18, 0.5, 0) }, 0.2, Enum.EasingStyle.Back):Play()
        else
            spring(track, { BackgroundColor3 = Theme.SurfaceHover }, 0.2):Play()
            spring(knob, { Position = UDim2.new(0, 2, 0.5, 0) }, 0.2, Enum.EasingStyle.Back):Play()
        end
        Callback(v)
    end
    
    frame.MouseButton1Click:Connect(function() set(not Value) end)
    frame.MouseEnter:Connect(function() spring(frame, { BackgroundTransparency = 0.1 }, 0.15):Play() end)
    frame.MouseLeave:Connect(function() spring(frame, { BackgroundTransparency = 0.3 }, 0.15):Play() end)
    
    return { Frame = frame, Set = set, Get = function() return Value end }
end

-- Slider Element
function Tab:Slider(config)
    local Title = config.Title or "Slider"
    local Desc = config.Desc
    local Min = config.Min or 0
    local Max = config.Max or 100
    local Value = config.Default or Min
    local Step = config.Step or 1
    local Suffix = config.Suffix or ""
    local Callback = config.Callback or function() end
    local height = Desc and 46 or 36
    
    local frame = create("Frame", {
        Name = Title, Parent = self.Content,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    
    create("TextLabel", {
        Name = "Title", Parent = frame,
        Position = UDim2.fromOffset(10, 6),
        Size = UDim2.new(0.6, -10, 0, 16),
        BackgroundTransparency = 1, Text = Title,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 14,
    })
    
    local valueLabel = create("TextLabel", {
        Name = "Value", Parent = frame,
        Position = UDim2.new(1, -10, 0, 6),
        AnchorPoint = Vector2.new(1, 0),
        Size = UDim2.new(0.4, -10, 0, 16),
        BackgroundTransparency = 1, Text = tostring(Value) .. Suffix,
        TextColor3 = Theme.Accent, TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.FredokaOne, TextSize = 14,
    })
    
    if Desc then
        create("TextLabel", {
            Name = "Desc", Parent = frame,
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -20, 0, 12),
            BackgroundTransparency = 1, Text = Desc,
            TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, TextSize = 10,
        })
    end
    
    local trackY = Desc and 34 or 24
    local track = create("Frame", {
        Name = "Track", Parent = frame,
        Position = UDim2.new(0, 10, 0, trackY),
        Size = UDim2.new(1, -20, 0, 6),
        BackgroundColor3 = Theme.SurfaceHover,
    }, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    
    local percent = (Value - Min) / (Max - Min)
    local fill = create("Frame", {
        Name = "Fill", Parent = track,
        Size = UDim2.new(percent, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
    }, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    
    local knob = create("Frame", {
        Name = "Knob", Parent = track,
        Position = UDim2.new(percent, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Size = UDim2.fromOffset(14, 14),
        BackgroundColor3 = Color3.new(1, 1, 1),
    }, { create("UICorner", { CornerRadius = UDim.new(1, 0) }) })
    
    local dragging = false
    local function update(input)
        local trackPos = track.AbsolutePosition.X
        local trackSize = track.AbsoluteSize.X
        local mouseX = input.Position.X
        local p = math.clamp((mouseX - trackPos) / trackSize, 0, 1)
        local v = Min + (Max - Min) * p
        v = math.floor(v / Step + 0.5) * Step
        v = math.clamp(v, Min, Max)
        Value = v
        local newPercent = (v - Min) / (Max - Min)
        spring(fill, { Size = UDim2.new(newPercent, 0, 1, 0) }, 0.1):Play()
        spring(knob, { Position = UDim2.new(newPercent, 0, 0.5, 0) }, 0.1):Play()
        valueLabel.Text = tostring(v) .. Suffix
        Callback(v)
    end
    
    track.InputBegan:Connect(function(input)
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
    
    return { Frame = frame, Set = function(v) Value = v; update({ Position = Vector3.new(track.AbsolutePosition.X + track.AbsoluteSize.X * ((v - Min) / (Max - Min)), 0, 0) }) end, Get = function() return Value end }
end

-- Input Element
function Tab:Input(config)
    local Title = config.Title or "Input"
    local Desc = config.Desc
    local Placeholder = config.Placeholder or "Enter text..."
    local Value = config.Default or ""
    local Callback = config.Callback or function() end
    local height = Desc and 54 or 44
    
    local frame = create("Frame", {
        Name = Title, Parent = self.Content,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    
    create("TextLabel", {
        Name = "Title", Parent = frame,
        Position = UDim2.fromOffset(10, 6),
        Size = UDim2.new(1, -20, 0, 16),
        BackgroundTransparency = 1, Text = Title,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 14,
    })
    
    local inputY = 22
    if Desc then
        create("TextLabel", {
            Name = "Desc", Parent = frame,
            Position = UDim2.fromOffset(10, 20),
            Size = UDim2.new(1, -20, 0, 12),
            BackgroundTransparency = 1, Text = Desc,
            TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, TextSize = 10,
        })
        inputY = 32
    end
    
    local inputContainer = create("Frame", {
        Name = "InputContainer", Parent = frame,
        Position = UDim2.new(0, 10, 0, inputY),
        Size = UDim2.new(1, -20, 0, 20),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.3,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
    })
    
    local textBox = create("TextBox", {
        Name = "TextBox", Parent = inputContainer,
        Position = UDim2.fromOffset(8, 0),
        Size = UDim2.new(1, -16, 1, 0),
        BackgroundTransparency = 1, Text = Value,
        PlaceholderText = Placeholder,
        PlaceholderColor3 = Theme.TextSecondary,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.Gotham, TextSize = 12,
        ClearTextOnFocus = false,
    })
    
    textBox.Focused:Connect(function()
        spring(inputContainer:FindFirstChild("UIStroke"), { Color = Theme.Accent, Transparency = 0 }, 0.2):Play()
    end)
    textBox.FocusLost:Connect(function(enterPressed)
        spring(inputContainer:FindFirstChild("UIStroke"), { Color = Theme.Border, Transparency = 0.5 }, 0.2):Play()
        Value = textBox.Text
        Callback(Value, enterPressed)
    end)
    
    return { Frame = frame, Set = function(v) Value = v; textBox.Text = v end, Get = function() return Value end }
end

-- Dropdown Element
function Tab:Dropdown(config)
    local Title = config.Title or "Dropdown"
    local Desc = config.Desc
    local Options = config.Options or {}
    local Value = config.Default
    local Callback = config.Callback or function() end
    local Opened = false
    local baseHeight = Desc and 36 or 26
    
    local frame = create("Frame", {
        Name = Title, Parent = self.Content,
        Size = UDim2.new(1, 0, 0, baseHeight),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
        ClipsDescendants = true,
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    
    local header = create("TextButton", {
        Name = "Header", Parent = frame,
        Size = UDim2.new(1, 0, 0, baseHeight),
        BackgroundTransparency = 1, Text = "",
    })
    
    create("TextLabel", {
        Name = "Title", Parent = header,
        Position = UDim2.fromOffset(10, Desc and 6 or 0),
        Size = UDim2.new(0.6, -10, 0, Desc and 16 or baseHeight),
        BackgroundTransparency = 1, Text = Title,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 14,
    })
    
    if Desc then
        create("TextLabel", {
            Name = "Desc", Parent = header,
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -80, 0, 12),
            BackgroundTransparency = 1, Text = Desc,
            TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, TextSize = 10,
        })
    end
    
    local valueLabel = create("TextLabel", {
        Name = "Value", Parent = header,
        Position = UDim2.new(1, -30, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0.4, -20, 0, 16),
        BackgroundTransparency = 1, Text = Value or "Select...",
        TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Gotham, TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    
    local arrow = create("TextLabel", {
        Name = "Arrow", Parent = header,
        Position = UDim2.new(1, -18, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1, Text = "▼",
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.GothamMedium, TextSize = 8,
    })
    
    local optionsContainer = create("Frame", {
        Name = "Options", Parent = frame,
        Position = UDim2.new(0, 0, 0, baseHeight),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 2) }),
        create("UIPadding", { PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6) }),
    })
    
    local function toggle()
        Opened = not Opened
        local optionsHeight = #Options * 28 + 8
        if Opened then
            spring(frame, { Size = UDim2.new(1, 0, 0, baseHeight + optionsHeight) }, 0.25, Enum.EasingStyle.Back):Play()
            spring(arrow, { Rotation = 180 }, 0.2):Play()
        else
            spring(frame, { Size = UDim2.new(1, 0, 0, baseHeight) }, 0.2):Play()
            spring(arrow, { Rotation = 0 }, 0.2):Play()
        end
    end
    
    for _, option in ipairs(Options) do
        local optionBtn = create("TextButton", {
            Name = option, Parent = optionsContainer,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = Theme.SurfaceHover,
            BackgroundTransparency = 0.5, Text = "",
        }, { create("UICorner", { CornerRadius = UDim.new(0, 4) }) })
        
        create("TextLabel", {
            Name = "Label", Parent = optionBtn,
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(1, -16, 1, 0),
            BackgroundTransparency = 1, Text = option,
            TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, TextSize = 12,
        })
        
        optionBtn.MouseEnter:Connect(function() spring(optionBtn, { BackgroundTransparency = 0.2 }, 0.1):Play() end)
        optionBtn.MouseLeave:Connect(function() spring(optionBtn, { BackgroundTransparency = 0.5 }, 0.1):Play() end)
        optionBtn.MouseButton1Click:Connect(function()
            Value = option
            valueLabel.Text = option
            toggle()
            Callback(option)
        end)
    end
    
    header.MouseButton1Click:Connect(toggle)
    header.MouseEnter:Connect(function() spring(frame, { BackgroundTransparency = 0.1 }, 0.15):Play() end)
    header.MouseLeave:Connect(function() spring(frame, { BackgroundTransparency = 0.3 }, 0.15):Play() end)
    
    return { Frame = frame, Set = function(v) Value = v; valueLabel.Text = v end, Get = function() return Value end }
end

-- Keybind Element
function Tab:Keybind(config)
    local Title = config.Title or "Keybind"
    local Desc = config.Desc
    local Value = config.Default or Enum.KeyCode.E
    local Callback = config.Callback or function() end
    local OnPress = config.OnPress or function() end
    local Listening = false
    local height = Desc and 36 or 26
    
    local frame = create("Frame", {
        Name = Title, Parent = self.Content,
        Size = UDim2.new(1, 0, 0, height),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.3,
    }, { create("UICorner", { CornerRadius = UDim.new(0, 6) }) })
    
    create("TextLabel", {
        Name = "Title", Parent = frame,
        Position = UDim2.fromOffset(10, Desc and 6 or 0),
        Size = UDim2.new(1, -80, 0, Desc and 16 or height),
        BackgroundTransparency = 1, Text = Title,
        TextColor3 = Theme.Text, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 14,
    })
    
    if Desc then
        create("TextLabel", {
            Name = "Desc", Parent = frame,
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -80, 0, 14),
            BackgroundTransparency = 1, Text = Desc,
            TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham, TextSize = 10,
        })
    end
    
    local keyButton = create("TextButton", {
        Name = "KeyButton", Parent = frame,
        Position = UDim2.new(1, -10, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.fromOffset(60, 24),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.3,
        Text = Value.Name, TextColor3 = Theme.Text,
        Font = Enum.Font.GothamMedium, TextSize = 11,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        create("UIStroke", { Color = Theme.Border, Thickness = 1, Transparency = 0.5 }),
    })
    
    keyButton.MouseButton1Click:Connect(function()
        Listening = true
        keyButton.Text = "..."
        spring(keyButton:FindFirstChild("UIStroke"), { Color = Theme.Accent, Transparency = 0 }, 0.2):Play()
    end)
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if Listening then
            if input.UserInputType == Enum.UserInputType.Keyboard then
                Value = input.KeyCode
                keyButton.Text = Value.Name
                Listening = false
                spring(keyButton:FindFirstChild("UIStroke"), { Color = Theme.Border, Transparency = 0.5 }, 0.2):Play()
                Callback(Value)
            end
        elseif not gameProcessed and input.UserInputType == Enum.UserInputType.Keyboard then
            if input.KeyCode == Value then OnPress() end
        end
    end)
    
    return { Frame = frame, Set = function(v) Value = v; keyButton.Text = v.Name end, Get = function() return Value end }
end

-- Label Element
function Tab:Label(config)
    local Text = config.Text or "Label"
    local Color = config.Color
    
    local label = create("TextLabel", {
        Name = "Label", Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1, Text = Text,
        TextColor3 = Color or Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 13,
    })
    
    return { Frame = label, Set = function(t) label.Text = t end }
end

-- Section Element
function Tab:Section(config)
    local section = {}
    section.Title = config.Title or "Section"
    section.Opened = config.Opened ~= false
    section.Tab = self
    
    section.Container = create("Frame", {
        Name = section.Title, Parent = self.Content,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0.5,
    }, { create("UICorner", { CornerRadius = UDim.new(0, 8) }) })
    
    section.Header = create("TextButton", {
        Name = "Header", Parent = section.Container,
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1, Text = "",
    })
    
    create("TextLabel", {
        Name = "Title", Parent = section.Header,
        Position = UDim2.fromOffset(10, 0),
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1, Text = section.Title,
        TextColor3 = Theme.TextSecondary, TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.FredokaOne, TextSize = 12,
    })
    
    section.Arrow = create("TextLabel", {
        Name = "Arrow", Parent = section.Header,
        Position = UDim2.new(1, -24, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1, Text = "▼",
        TextColor3 = Theme.TextSecondary,
        Font = Enum.Font.GothamMedium, TextSize = 8,
        Rotation = section.Opened and 0 or -90,
    })
    
    section.Content = create("Frame", {
        Name = "Content", Parent = section.Container,
        Position = UDim2.fromOffset(0, 28),
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Visible = section.Opened,
    }, {
        create("UIListLayout", { Padding = UDim.new(0, 4) }),
        create("UIPadding", { PaddingTop = UDim.new(0, 2), PaddingBottom = UDim.new(0, 8), PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }),
    })
    
    section.Header.MouseButton1Click:Connect(function()
        section.Opened = not section.Opened
        if section.Opened then
            section.Content.Visible = true
            spring(section.Arrow, { Rotation = 0 }, 0.2):Play()
        else
            spring(section.Arrow, { Rotation = -90 }, 0.2):Play()
            task.delay(0.2, function() if not section.Opened then section.Content.Visible = false end end)
        end
    end)
    
    -- Add element methods to section
    function section:Button(cfg) return Tab.Button({ Content = self.Content, Theme = Theme, SnoeUI = SnoeUI }, cfg) end
    function section:Toggle(cfg) return Tab.Toggle({ Content = self.Content, Theme = Theme, SnoeUI = SnoeUI }, cfg) end
    function section:Slider(cfg) return Tab.Slider({ Content = self.Content, Theme = Theme, SnoeUI = SnoeUI }, cfg) end
    function section:Input(cfg) return Tab.Input({ Content = self.Content, Theme = Theme, SnoeUI = SnoeUI }, cfg) end
    function section:Dropdown(cfg) return Tab.Dropdown({ Content = self.Content, Theme = Theme, SnoeUI = SnoeUI }, cfg) end
    function section:Keybind(cfg) return Tab.Keybind({ Content = self.Content, Theme = Theme, SnoeUI = SnoeUI }, cfg) end
    function section:Label(cfg) return Tab.Label({ Content = self.Content, Theme = Theme, SnoeUI = SnoeUI }, cfg) end
    
    return section
end

return SnoeUI
