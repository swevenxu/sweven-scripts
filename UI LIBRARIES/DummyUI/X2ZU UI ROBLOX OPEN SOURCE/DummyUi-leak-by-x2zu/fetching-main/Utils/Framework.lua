Fetching = {}
local ScreenUI = Instance.new("ScreenGui")
ScreenUI.Name = "Fetching"
ScreenUI.Parent = not game:GetService("RunService"):IsStudio() and game:GetService("CoreGui") or game:GetService("Players").LocalPlayer.PlayerGui
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
function Fetching:Window(info)
	local Logo = info.Logo
	local Size = info.Size
	local MainColor = info.MainColor or Color3.fromRGB(0, 170, 255)
	local DropColor = info.DropColor or Color3.fromRGB(105, 94, 255)
	local Keybind = info.Keybind

	local function GetIcon(i)
		if type(i) == 'string' and not i:find('rbxassetid://') then
			return "rbxassetid://".. i
		elseif type(i) == 'number' then
			return "rbxassetid://".. i
		else
			return i
		end
	end

	local function tw(info)
		return TweenService:Create(
			info.v, 
			TweenInfo.new(info.t, Enum.EasingStyle[info.s], Enum.EasingDirection[info.d]), 
			info.g
		)
	end


	local function lak(a)
		local Dragging = nil
		local DragInput = nil
		local DragStart = nil
		local StartPosition = nil

		local function Update(input)
			local Delta = input.Position - DragStart
			local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
			local Tween = game:GetService("TweenService"):Create(a, TweenInfo.new(0.3), {Position = pos})
			Tween:Play()
		end

		a.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				DragStart = input.Position
				StartPosition = a.Position

				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						Dragging = false
					end
				end)
			end
		end)

		a.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				DragInput = input
			end
		end)

		game:GetService("UserInputService").InputChanged:Connect(function(input)
			if input == DragInput and Dragging then
				Update(input)
			end
		end)
	end
	local function click(p)
		local Click = Instance.new("TextButton")

		Click.Name = "Click"
		Click.Parent = p
		Click.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Click.BackgroundTransparency = 1.000
		Click.BorderColor3 = Color3.fromRGB(0, 0, 0)
		Click.BorderSizePixel = 0
		Click.Size = UDim2.new(1, 0, 1, 0)
		Click.Font = Enum.Font.SourceSans
		Click.Text = ""
		Click.TextColor3 = Color3.fromRGB(0, 0, 0)
		Click.TextSize = 14.000

		return Click
	end
	local function ButtoneffectClick(c, p)
		local Mouse = game.Players.LocalPlayer:GetMouse()

		local relativeX = Mouse.X - c.AbsolutePosition.X
		local relativeY = Mouse.Y - c.AbsolutePosition.Y

		if relativeX < 0 or relativeY < 0 or relativeX > c.AbsoluteSize.X or relativeY > c.AbsoluteSize.Y then
			return
		end

		local ClickButtonCircle = Instance.new("Frame")
		ClickButtonCircle.Parent = p
		ClickButtonCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		ClickButtonCircle.BackgroundTransparency = 0.7
		ClickButtonCircle.BorderSizePixel = 0
		ClickButtonCircle.AnchorPoint = Vector2.new(0.5, 0.5)
		ClickButtonCircle.Position = UDim2.new(0, relativeX, 0, relativeY)
		ClickButtonCircle.Size = UDim2.new(0, 0, 0, 0)
		ClickButtonCircle.ZIndex = 10

		local UICorner = Instance.new("UICorner")
		UICorner.CornerRadius = UDim.new(1, 0)
		UICorner.Parent = ClickButtonCircle

		local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

		local goal = {
			Size = UDim2.new(0, c.AbsoluteSize.X * 1.5, 0, c.AbsoluteSize.X * 1.5),
			BackgroundTransparency = 1
		}

		local expandTween = game:GetService("TweenService"):Create(ClickButtonCircle, tweenInfo, goal)

		expandTween.Completed:Connect(function()
			ClickButtonCircle:Destroy()
		end)

		expandTween:Play()
	end

	local NameHub = info.Title
	local Icon = info.Logo
	local Size = info.Size

	local CloseUI = Instance.new("TextButton")
	local UICorner_1 = Instance.new("UICorner")
	local Icon_1 = Instance.new("Frame")
	local ImageLabel_1 = Instance.new("ImageLabel")


	CloseUI.Name = "CloseUI"
	CloseUI.Parent = ScreenUI
	CloseUI.AnchorPoint = Vector2.new(0, 1)
	CloseUI.BackgroundColor3 = Color3.fromRGB(0,0,0)
	CloseUI.BorderColor3 = Color3.fromRGB(0,0,0)
	CloseUI.BorderSizePixel = 0
	CloseUI.Position = UDim2.new(0.05, 0,0.3, 0)
	CloseUI.Size = UDim2.new(0, 50,0, 50)
	CloseUI.BackgroundTransparency = 0.35
	CloseUI.Text = ""

	lak(CloseUI)

	UICorner_1.Parent = CloseUI
	UICorner_1.CornerRadius = UDim.new(0,5)

	Icon_1.Name = "Icon"
	Icon_1.Parent = CloseUI
	Icon_1.BackgroundColor3 = Color3.fromRGB(22,22,22)
	Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Icon_1.BorderSizePixel = 0
	Icon_1.Size = UDim2.new(0, 50,0, 50)
	Icon_1.BackgroundTransparency = 1

	ImageLabel_1.Parent = Icon_1
	ImageLabel_1.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_1.BackgroundTransparency = 1
	ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_1.BorderSizePixel = 0
	ImageLabel_1.Position = UDim2.new(0.5, 0,0.5, 0)
	ImageLabel_1.Size = UDim2.new(0, 45,0, 45)
	ImageLabel_1.Image = GetIcon(Icon)
	ImageLabel_1.ImageTransparency = 0

	local Background_1 = Instance.new("Frame")
	local UICorner_1 = Instance.new("UICorner")
	local Line_1 = Instance.new("Frame")
	local Hub_1 = Instance.new("Frame")
	local UIListLayout_6 = Instance.new("UIListLayout")
	local Logo_1 = Instance.new("ImageLabel")
	local Shadow = Instance.new("ImageLabel")

	Background_1.Name = "Background"
	Background_1.Parent = ScreenUI
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundColor3 = Color3.fromRGB(10,10,10)
	Background_1.BackgroundTransparency = 0.2
	Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Background_1.BorderSizePixel = 0
	Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Background_1.Size = Size


	local ImageLabel_11 = Instance.new("ImageLabel")
	ImageLabel_11.Parent = Background_1
	ImageLabel_11.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel_11.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_11.BackgroundTransparency = 1
	ImageLabel_11.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_11.BorderSizePixel = 0
	ImageLabel_11.Position = UDim2.new(0.5, 0,0.5, 0)
	ImageLabel_11.Size = UDim2.new(1, 120,1, 0)
	ImageLabel_11.Image = GetIcon(104034982402252)
	ImageLabel_11.ImageTransparency = 0.5
	ImageLabel_11.ScaleType = Enum.ScaleType.Crop

	local ImageLabel_12 = Instance.new("ImageLabel")
	ImageLabel_12.Parent = Background_1
	ImageLabel_12.AnchorPoint = Vector2.new(0.5, 0.5)
	ImageLabel_12.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ImageLabel_12.BackgroundTransparency = 1
	ImageLabel_12.BorderColor3 = Color3.fromRGB(0,0,0)
	ImageLabel_12.BorderSizePixel = 0
	ImageLabel_12.Position = UDim2.new(0.5, 0,0.55, 0)
	ImageLabel_12.Size = UDim2.new(0, 300,0, 300)
	ImageLabel_12.Image = GetIcon(Icon)
	ImageLabel_12.ImageTransparency = 0.75

	Shadow.Parent = Background_1
	Shadow.Name = "DropShadow"
	Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	Shadow.BackgroundColor3 = Color3.fromRGB(28,28,30)
	Shadow.BackgroundTransparency = 1
	Shadow.BorderColor3 = Color3.fromRGB(0,0,0)
	Shadow.BorderSizePixel = 0
	Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
	Shadow.Size = UDim2.new(1, 120, 1, 120)
	Shadow.ZIndex = 0
	Shadow.Image = "rbxassetid://8992230677"
	Shadow.ImageColor3 = Color3.new(0, 0, 0)
	Shadow.ImageTransparency = 0.35
	Shadow.ResampleMode = Enum.ResamplerMode.Default
	Shadow.ScaleType = Enum.ScaleType.Slice
	Shadow.SliceScale = 1
	Shadow.TileSize = UDim2.new(1, 0, 1, 0)
	Shadow.SliceCenter = Rect.new(99, 99, 99, 99)

	local ShadowInside = Instance.new("Frame")
	local UIGradient = Instance.new("UIGradient")
	local UICorner = Instance.new("UICorner")

	ShadowInside.Name = "ShadowInside"
	ShadowInside.Parent = Background_1
	ShadowInside.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ShadowInside.BackgroundTransparency = 0.5
	ShadowInside.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ShadowInside.BorderSizePixel = 0
	ShadowInside.Size = UDim2.new(1, 0, 1, 0)
	ShadowInside.ZIndex = 2

	UIGradient.Rotation = 90
	UIGradient.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0.00, 1.00), NumberSequenceKeypoint.new(0.70, 1.00), NumberSequenceKeypoint.new(1.00, 0.20)}
	UIGradient.Parent = ShadowInside

	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = ShadowInside

	local function closeopenui()
		task.spawn(function()
			tw({
				v = ImageLabel_1,
				t = 0.2,
				s = "Back",
				d = "Out",
				g = {Size = UDim2.new(0, 35, 0, 35)}
			}):Play()
			task.wait(0.016) 
			tw({
				v = ImageLabel_1,
				t = 0.2,
				s = "Back",
				d = "Out",
				g = {Size = UDim2.new(0, 45, 0, 45)}
			}):Play()
		end)
		Background_1.Visible = not Background_1.Visible
	end


	CloseUI.MouseButton1Click:Connect(function()
		closeopenui()
	end)

	game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessed)
		if not gameProcessed and input.KeyCode == Enum.KeyCode.F2 then
			closeopenui()
		end
	end)

	lak(Background_1)

	UICorner_1.Parent = Background_1
	UICorner_1.CornerRadius = UDim.new(0,10)

	Hub_1.Name = "Hub"
	Hub_1.Parent = Background_1
	Hub_1.AnchorPoint = Vector2.new(0, 0.5)
	Hub_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Hub_1.BackgroundTransparency = 1
	Hub_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Hub_1.BorderSizePixel = 0
	Hub_1.Position = UDim2.new(0.0275, 0,0.0799999982, 0)
	Hub_1.Size = UDim2.new(0, 55,0, 55)

	UIListLayout_6.Parent = Hub_1
	UIListLayout_6.Padding = UDim.new(0,10)
	UIListLayout_6.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_6.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_6.VerticalAlignment = Enum.VerticalAlignment.Center

	Logo_1.Name = "Logo"
	Logo_1.Parent = Hub_1
	Logo_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Logo_1.BackgroundTransparency = 1
	Logo_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Logo_1.BorderSizePixel = 0
	Logo_1.Size = UDim2.new(1,0,1,0)
	Logo_1.Image = GetIcon(Icon)
	local Tablist_1 = Instance.new("Frame")
	local ScrollingFrame_1 = Instance.new("ScrollingFrame")
	local UIListLayout_1 = Instance.new("UIListLayout")
	Tablist_1.Name = "Tablist"
	Tablist_1.Parent = Background_1
	Tablist_1.AnchorPoint = Vector2.new(1, 0.5)
	Tablist_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Tablist_1.BackgroundTransparency = 1
	Tablist_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Tablist_1.BorderSizePixel = 0
	Tablist_1.Position = UDim2.new(0.970000029, 0,0.0799999982, 0)
	Tablist_1.Size = UDim2.new(0, 410,0, 45)
	ScrollingFrame_1.Name = "ScrollingFrame"
	ScrollingFrame_1.Parent = Tablist_1
	ScrollingFrame_1.Active = true
	ScrollingFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	ScrollingFrame_1.BackgroundTransparency = 1
	ScrollingFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
	ScrollingFrame_1.BorderSizePixel = 0
	ScrollingFrame_1.Size = UDim2.new(1, 0,1, 0)
	ScrollingFrame_1.ClipsDescendants = true
	ScrollingFrame_1.AutomaticCanvasSize = Enum.AutomaticSize.None
	ScrollingFrame_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
	ScrollingFrame_1.CanvasPosition = Vector2.new(0, 0)
	ScrollingFrame_1.CanvasSize = UDim2.new(2, 0,0, 0)
	ScrollingFrame_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
	ScrollingFrame_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
	ScrollingFrame_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
	ScrollingFrame_1.ScrollBarImageTransparency = 0
	ScrollingFrame_1.ScrollBarThickness = 0
	ScrollingFrame_1.ScrollingDirection = Enum.ScrollingDirection.XY
	ScrollingFrame_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
	ScrollingFrame_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
	ScrollingFrame_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right
	UIListLayout_1.Parent = ScrollingFrame_1
	UIListLayout_1.Padding = UDim.new(0,8)
	UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
	UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
	UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center
	Fetching.Tab = {
		Value = false
	}
	function Fetching.Tab:SetVisible(tab, value)
		for i, v in pairs(ScrollingFrame_1:GetChildren()) do
			if v:IsA("Frame") and v:FindFirstChild("List") and v.List:FindFirstChild("Title") and v.List.Title:FindFirstChild("TitleTab") and v.List.Title.TitleTab.Text == tab then
				v.Visible = value
			end
		end
	end
	function Fetching.Tab:CreateTab(info)

		local Title = info.Title

		local Tab_1 = Instance.new("Frame")
		local UICorner_2z = Instance.new("UICorner")
		local Title_1 = Instance.new("Frame")
		local TitleTab_1 = Instance.new("TextLabel")
		local LineTab_1 = Instance.new("Frame")
		local UIGD = Instance.new("UIGradient")
		local Click = click(Tab_1)

		Tab_1.Name = "Tab"
		Tab_1.Parent = ScrollingFrame_1
		Tab_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Tab_1.BackgroundTransparency = 1
		Tab_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Tab_1.BorderSizePixel = 0
		Tab_1.Position = UDim2.new(0, 0,0.111111112, 0)
		Tab_1.Size = UDim2.new(0, 105,0, 35)
		Tab_1.ClipsDescendants = true

		UIGD.Rotation = 180
		UIGD.Parent = Tab_1
		UIGD.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}


		UICorner_2z.Parent = Tab_1
		UICorner_2z.CornerRadius = UDim.new(1,0)

		Title_1.Name = "Title"
		Title_1.Parent = Tab_1
		Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Title_1.BackgroundTransparency = 1
		Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Title_1.BorderSizePixel = 0
		Title_1.Position = UDim2.new(0.5, 0,0.5, 0)
		Title_1.Size = UDim2.new(0.9, 0,0.9, 0)

		TitleTab_1.Name = "TitleTab"
		TitleTab_1.Parent = Title_1
		TitleTab_1.AnchorPoint = Vector2.new(0.5, 0.5)
		TitleTab_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		TitleTab_1.BackgroundTransparency = 1
		TitleTab_1.BorderColor3 = Color3.fromRGB(0,0,0)
		TitleTab_1.BorderSizePixel = 0
		TitleTab_1.Position = UDim2.new(0.5, 0,0.5, 0)
		TitleTab_1.Size = UDim2.new(1, 0,1, 0)
		TitleTab_1.Font = Enum.Font.GothamBold
		TitleTab_1.Text = tostring(Title)
		TitleTab_1.TextColor3 = Color3.fromRGB(255,255,255)
		TitleTab_1.TextSize = 15
		TitleTab_1.TextXAlignment = Enum.TextXAlignment.Center
		TitleTab_1.TextTransparency = 0.5

		local Page_1 = Instance.new("Frame")
		local UIListLayout_8 = Instance.new("UIListLayout")
		local PageLeft_1 = Instance.new("ScrollingFrame")
		local PageRight_1 = Instance.new("ScrollingFrame")
		local UIListLayout_12 = Instance.new("UIListLayout")
		local UIListLayout_13 = Instance.new("UIListLayout")

		Page_1.Name = "Page"
		Page_1.Parent = Background_1
		Page_1.AnchorPoint = Vector2.new(0.5, 0.5)
		Page_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		Page_1.BackgroundTransparency = 1
		Page_1.BorderColor3 = Color3.fromRGB(0,0,0)
		Page_1.BorderSizePixel = 0
		Page_1.Position = UDim2.new(0.5, 0,0.56, 0)
		Page_1.Size = UDim2.new(0.95, 0,0, 315)
		Page_1.Visible = false

		UIListLayout_8.Parent = Page_1
		UIListLayout_8.Padding = UDim.new(0,5)
		UIListLayout_8.FillDirection = Enum.FillDirection.Horizontal
		UIListLayout_8.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_8.SortOrder = Enum.SortOrder.LayoutOrder

		PageLeft_1.Name = "PageLeft"
		PageLeft_1.Parent = Page_1
		PageLeft_1.Active = true
		PageLeft_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		PageLeft_1.BackgroundTransparency = 1
		PageLeft_1.BorderColor3 = Color3.fromRGB(0,0,0)
		PageLeft_1.BorderSizePixel = 0
		PageLeft_1.Size = UDim2.new(0.5, 0,1, 0)
		PageLeft_1.ClipsDescendants = true
		PageLeft_1.AutomaticCanvasSize = Enum.AutomaticSize.None
		PageLeft_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		PageLeft_1.CanvasPosition = Vector2.new(0, 0)
		PageLeft_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		PageLeft_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		PageLeft_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		PageLeft_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
		PageLeft_1.ScrollBarImageTransparency = 0
		PageLeft_1.ScrollBarThickness = 0
		PageLeft_1.ScrollingDirection = Enum.ScrollingDirection.XY
		PageLeft_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		PageLeft_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		PageLeft_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		UIListLayout_12.Parent = PageLeft_1
		UIListLayout_12.Padding = UDim.new(0,10)
		UIListLayout_12.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_12.SortOrder = Enum.SortOrder.LayoutOrder

		PageRight_1.Name = "PageRight"
		PageRight_1.Parent = Page_1
		PageRight_1.Active = true
		PageRight_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
		PageRight_1.BackgroundTransparency = 1
		PageRight_1.BorderColor3 = Color3.fromRGB(0,0,0)
		PageRight_1.BorderSizePixel = 0
		PageRight_1.Size = UDim2.new(0.5, 0,1, 0)
		PageRight_1.ClipsDescendants = true
		PageRight_1.AutomaticCanvasSize = Enum.AutomaticSize.None
		PageRight_1.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
		PageRight_1.CanvasPosition = Vector2.new(0, 0)
		PageRight_1.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
		PageRight_1.HorizontalScrollBarInset = Enum.ScrollBarInset.None
		PageRight_1.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
		PageRight_1.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
		PageRight_1.ScrollBarImageTransparency = 0
		PageRight_1.ScrollBarThickness = 0
		PageRight_1.ScrollingDirection = Enum.ScrollingDirection.XY
		PageRight_1.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
		PageRight_1.VerticalScrollBarInset = Enum.ScrollBarInset.None
		PageRight_1.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

		UIListLayout_13.Parent = PageRight_1
		UIListLayout_13.Padding = UDim.new(0,10)
		UIListLayout_13.HorizontalAlignment = Enum.HorizontalAlignment.Center
		UIListLayout_13.SortOrder = Enum.SortOrder.LayoutOrder

		local TextService = game:GetService("TextService")

		local titleSize = TextService:GetTextSize(tostring(Title), 13, Enum.Font.SourceSansBold, Vector2.new(math.huge, 10))

		local maxWidth = math.max(titleSize.X, 0) + 63

		Tab_1.Size = UDim2.new(0, maxWidth, 0, 35)

		TitleTab_1.Size = UDim2.new(0, titleSize.X, 0, 10)

		Click.MouseButton1Click:Connect(function()
			for i, v in pairs(Background_1:GetChildren()) do
				if v.Name == "Page" then
					v.Visible = false
					v.Position = UDim2.new(0.5, 0,0.65, 0)
				end
			end
			for i, v in pairs(ScrollingFrame_1:GetChildren()) do
				if v:IsA("Frame") then
					tw({
						v = v,
						t = 0.2,
						s = "Linear",
						d = "Out",
						g = {BackgroundTransparency = 1}
					}):Play()
					tw({
						v = v.Title.TitleTab,
						t = 0.2,
						s = "Linear",
						d = "Out",
						g = {TextTransparency = 0.5}
					}):Play()
				end
			end
			Page_1.Visible = true
			tw({
				v = Tab_1,
				t = 0.2,
				s = "Linear",
				d = "Out",
				g = {BackgroundTransparency = 0}
			}):Play()
			tw({
				v = TitleTab_1,
				t = 0.2,
				s = "Linear",
				d = "Out",
				g = {TextTransparency = 0}
			}):Play()
			tw({
				v = Page_1,
				t = 0.2,
				s = "Linear",
				d = "Out",
				g = {Position = UDim2.new(0.5, 0,0.579999983, 0)}
			}):Play()
		end)

		delay(0.2,function()
			if not Fetching.Tab.Value then
				tw({
					v = Tab_1,
					t = 0.2,
					s = "Linear",
					d = "Out",
					g = {BackgroundTransparency = 0}
				}):Play()
				tw({
					v = TitleTab_1,
					t = 0.2,
					s = "Linear",
					d = "Out",
					g = {TextTransparency = 0}
				}):Play()
				tw({
					v = Page_1,
					t = 0.2,
					s = "Linear",
					d = "Out",
					g = {Position = UDim2.new(0.5, 0,0.579999983, 0)}
				}):Play()
				Page_1.Visible = true
				Fetching.Tab.Value = true
			end
		end)

		local function GetSide(side)
			if not side then
				return PageLeft_1
			end
			local sideLower = string.lower(tostring(side))
			if sideLower == "r" or sideLower == "right" or side == 2 then
				return PageRight_1
			elseif sideLower == "l" or sideLower == "left" or side == 1 then
				return PageLeft_1
			else
				return PageLeft_1
			end
		end

		Fetching.Section = {}

		function Fetching.Section:CreateSection(info)
			local Title = info.Title
			local Side = info.Side

			local Section_1 = Instance.new("Frame")
			local UICorner_4 = Instance.new("UICorner")
			local UIListLayout_9 = Instance.new("UIListLayout")
			local SectionTitle_1 = Instance.new("TextLabel")
			local Line_2 = Instance.new("Frame")
			local Line = Instance.new("Frame")
			local Line_1 = Instance.new("Frame")

			Section_1.Name = "Section"
			Section_1.Parent = GetSide(Side)
			Section_1.BackgroundColor3 = Color3.fromRGB(23,23,23)
			Section_1.BackgroundTransparency = 0.2
			Section_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Section_1.BorderSizePixel = 0
			Section_1.Position = UDim2.new(0.0049999305, 0,0.0250000004, 0)
			Section_1.Size = UDim2.new(0.99000001, 0,0, 200)
			Section_1.ClipsDescendants = true

			local Stroke = Instance.new("UIStroke")
			Stroke.Parent = Section_1
			Stroke.Color = Color3.fromRGB(30,30,30)
			Stroke.Thickness = 1

			UICorner_4.Parent = Section_1
			UICorner_4.CornerRadius = UDim.new(0,3)

			Line_1.Name = "Line"
			Line_1.Parent = Section_1
			Line_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Line_1.BackgroundTransparency = 1
			Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
			Line_1.BorderSizePixel = 0
			Line_1.LayoutOrder = -1
			Line_1.Size = UDim2.new(1, 0,0, 1)

			Line.Name = "Line"
			Line.Parent = Section_1
			Line.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Line.BackgroundTransparency = 0.9
			Line.BorderColor3 = Color3.fromRGB(0,0,0)
			Line.BorderSizePixel = 0
			Line.LayoutOrder = 0
			Line.Size = UDim2.new(1, 0,0, 1)

			UIListLayout_9.Parent = Section_1
			UIListLayout_9.Padding = UDim.new(0,5)
			UIListLayout_9.HorizontalAlignment = Enum.HorizontalAlignment.Center
			UIListLayout_9.SortOrder = Enum.SortOrder.LayoutOrder

			SectionTitle_1.Name = "SectionTitle"
			SectionTitle_1.Parent = Section_1
			SectionTitle_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
			SectionTitle_1.BackgroundTransparency = 1
			SectionTitle_1.BorderColor3 = Color3.fromRGB(0,0,0)
			SectionTitle_1.BorderSizePixel = 0
			SectionTitle_1.Size = UDim2.new(0.9, 0,0, 20)
			SectionTitle_1.Font = Enum.Font.GothamBold
			SectionTitle_1.Text = tostring(Title)
			SectionTitle_1.TextColor3 = Color3.fromRGB(255,255,255)
			SectionTitle_1.TextSize = 13

			Line_2.Name = "Line"
			Line_2.Parent = Section_1
			Line_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
			Line_2.BackgroundTransparency = 0.9
			Line_2.BorderColor3 = Color3.fromRGB(0,0,0)
			Line_2.BorderSizePixel = 0
			Line_2.LayoutOrder = 1
			Line_2.Size = UDim2.new(1, 0,0, 1)

			Fetching.Main = {}

			function Fetching.Main:SetVisible(value)
				Section_1.Visible = value
			end

			function Fetching.Main:CreateDropdown(info)

				local Title = info.Title
				local List = info.List
				local Value = info.Value
				local Multi = info.Multi or false
				local Callback = info.Callback

				local Dropdown = Instance.new("Frame")
				local DropdownFrame_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local TextHub_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Selected_1 = Instance.new("TextLabel")
				local Title_1 = Instance.new("TextLabel")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local Click_1 = Instance.new("TextButton")
				local pd = Instance.new("UIPadding")

				Dropdown.Name = "Dropdown"
				Dropdown.Parent = Section_1
				Dropdown.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Dropdown.BackgroundTransparency = 1
				Dropdown.BorderColor3 = Color3.fromRGB(0,0,0)
				Dropdown.BorderSizePixel = 0
				Dropdown.LayoutOrder = 2
				Dropdown.Size = UDim2.new(1, 0,0, 38)

				DropdownFrame_1.Name = "DropdownFrame"
				DropdownFrame_1.Parent = Dropdown
				DropdownFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
				DropdownFrame_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				DropdownFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				DropdownFrame_1.BorderSizePixel = 0
				DropdownFrame_1.Position = UDim2.new(0.5, 0,0.5, 0)
				DropdownFrame_1.Size = UDim2.new(0.95, 0,1, 0)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = DropdownFrame_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(56,56,56)

				UICorner_1.Parent = DropdownFrame_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				TextHub_1.Name = "TextHub"
				TextHub_1.Parent = DropdownFrame_1
				TextHub_1.AnchorPoint = Vector2.new(0, 0.5)
				TextHub_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextHub_1.BackgroundTransparency = 1
				TextHub_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextHub_1.BorderSizePixel = 0
				TextHub_1.Position = UDim2.new(0.0299999993, 0,0.5, 0)
				TextHub_1.Size = UDim2.new(1, 0,0.800000012, 0)

				pd.Parent = TextHub_1
				pd.PaddingTop = UDim.new(0,3)

				UIListLayout_1.Parent = TextHub_1
				UIListLayout_1.Padding = UDim.new(0,4)
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder

				Selected_1.Name = "Selected"
				Selected_1.Parent = TextHub_1
				Selected_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Selected_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Selected_1.BackgroundTransparency = 1
				Selected_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Selected_1.BorderSizePixel = 0
				Selected_1.LayoutOrder = 1
				Selected_1.Position = UDim2.new(0.248750001, 0,0.0944999978, 0)
				Selected_1.Size = UDim2.new(0, 150,0, 11)
				Selected_1.Font = Enum.Font.GothamBold
				if type(Value) == "table" then
					Selected_1.Text = table.concat(Value, ", ")
				else
					Selected_1.Text = Value
				end

				local UIGD = Instance.new("UIGradient")
				UIGD.Rotation = 90
				UIGD.Parent = Selected_1
				UIGD.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}

				Selected_1.TextColor3 = Color3.fromRGB(255,255,255)
				Selected_1.TextSize = 8
				Selected_1.TextTransparency = 0
				Selected_1.TextXAlignment = Enum.TextXAlignment.Left

				Title_1.Name = "Title"
				Title_1.Parent = TextHub_1
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.248750001, 0,0.0644999966, 0)
				Title_1.Size = UDim2.new(0, 150,0, 11)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 10
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				ImageLabel_1.Parent = DropdownFrame_1
				ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.970000029, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(0, 17,0, 17)
				ImageLabel_1.Image = "rbxassetid://129573215183311"

				local UIGD = Instance.new("UIGradient")
				UIGD.Rotation = 90
				UIGD.Parent = ImageLabel_1
				UIGD.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}

				Click_1.Name = "Click"
				Click_1.Parent = Dropdown
				Click_1.Active = true
				Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Click_1.BackgroundTransparency = 1
				Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Click_1.BorderSizePixel = 0
				Click_1.Size = UDim2.new(1, 0,1, 0)
				Click_1.Font = Enum.Font.SourceSans
				Click_1.Text = ""
				Click_1.TextSize = 14

				local DropdownSelect = Instance.new("Frame")
				local DropdownFrame_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local ScrollingFrame_1z = Instance.new("ScrollingFrame")
				local UIListLayout_1 = Instance.new("UIListLayout")

				DropdownSelect.Name = "DropdownSelect"
				DropdownSelect.Parent = Background_1
				DropdownSelect.AnchorPoint = Vector2.new(0.5,0.5)
				DropdownSelect.Position = UDim2.new(0.5,0,0.5,0)
				DropdownSelect.BackgroundColor3 = Color3.fromRGB(255,255,255)
				DropdownSelect.BackgroundTransparency = 1
				DropdownSelect.BorderColor3 = Color3.fromRGB(0,0,0)
				DropdownSelect.BorderSizePixel = 0
				DropdownSelect.LayoutOrder = 2
				DropdownSelect.Size = UDim2.new(0.5, 0,0, 250)
				DropdownSelect.Visible = false

				local Shadow = Instance.new("ImageLabel")
				Shadow.Parent = DropdownSelect
				Shadow.Name = "DropShadow"
				Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
				Shadow.BackgroundColor3 = Color3.fromRGB(28,28,30)
				Shadow.BackgroundTransparency = 1
				Shadow.BorderColor3 = Color3.fromRGB(0,0,0)
				Shadow.BorderSizePixel = 0
				Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
				Shadow.Size = UDim2.new(1, 120, 1, 120)
				Shadow.Image = "rbxassetid://8992230677"
				Shadow.ImageColor3 = Color3.new(1, 1, 1)
				Shadow.ImageTransparency = 0.8
				Shadow.ResampleMode = Enum.ResamplerMode.Default
				Shadow.ScaleType = Enum.ScaleType.Slice
				Shadow.SliceScale = 1
				Shadow.TileSize = UDim2.new(1, 0, 1, 0)
				Shadow.SliceCenter = Rect.new(99, 99, 99, 99)

				local UIGD = Instance.new("UIGradient")
				UIGD.Rotation = 180
				UIGD.Parent = Shadow
				UIGD.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(105, 94, 255))}

				local Search_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local TextBox_1 = Instance.new("TextBox")
				local ImageLabel_1 = Instance.new("ImageLabel")
				local UIPadding_1 = Instance.new("UIPadding")
				Search_1.Name = "Search"
				Search_1.Parent = DropdownSelect
				Search_1.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
				Search_1.AnchorPoint = Vector2.new(0.5,0.5)
				Search_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Search_1.BorderSizePixel = 0
				Search_1.LayoutOrder = -1
				Search_1.Size = UDim2.new(0.9, 0,0, 20)
				Search_1.Position = UDim2.new(0.5, 0,0, 15)
				Search_1.ZIndex = 2

				UICorner_2.Parent = Search_1
				UICorner_2.CornerRadius = UDim.new(1,0)

				TextBox_1.Parent = Search_1
				TextBox_1.Active = true
				TextBox_1.ZIndex = 2
				TextBox_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.BackgroundTransparency = 1
				TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBox_1.BorderSizePixel = 0
				TextBox_1.Size = UDim2.new(0.95, 0,1, 0)
				TextBox_1.Font = Enum.Font.GothamBold
				TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				TextBox_1.PlaceholderText = "Search"
				TextBox_1.Text = ""
				TextBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextBox_1.TextSize = 9
				TextBox_1.TextXAlignment = Enum.TextXAlignment.Left

				UIPadding_1.Parent = Search_1
				UIPadding_1.PaddingLeft = UDim.new(0,5)
				UIPadding_1.PaddingRight = UDim.new(0,5)
				ImageLabel_1.Parent = Search_1
				ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(1, 0,0.5, 0)
				ImageLabel_1.Size = UDim2.new(0, 10,0, 10)
				ImageLabel_1.Image = "rbxassetid://14897613248"
				ImageLabel_1.ImageTransparency = 0.5
				ImageLabel_1.ZIndex = 2

				DropdownFrame_1.Name = "DropdownFrame"
				DropdownFrame_1.Parent = DropdownSelect
				DropdownFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
				DropdownFrame_1.BackgroundColor3 = Color3.fromRGB(18,18,18)
				DropdownFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				DropdownFrame_1.BorderSizePixel = 0
				DropdownFrame_1.Position = UDim2.new(0.5, 0,0.5, 0)
				DropdownFrame_1.Size = UDim2.new(0.95, 0,1, 0)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = DropdownFrame_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(56,56,56)

				UICorner_1.Parent = DropdownFrame_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				ScrollingFrame_1z.Name = "ScrollingFrame"
				ScrollingFrame_1z.Parent = DropdownFrame_1
				ScrollingFrame_1z.Active = true
				ScrollingFrame_1z.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ScrollingFrame_1z.BackgroundTransparency = 1
				ScrollingFrame_1z.BorderColor3 = Color3.fromRGB(0,0,0)
				ScrollingFrame_1z.BorderSizePixel = 0
				ScrollingFrame_1z.Size = UDim2.new(1, 0,0.85, 0)
				ScrollingFrame_1z.Position = UDim2.new(0, 0,0, 35)
				ScrollingFrame_1z.ClipsDescendants = true
				ScrollingFrame_1z.AutomaticCanvasSize = Enum.AutomaticSize.None
				ScrollingFrame_1z.BottomImage = "rbxasset://textures/ui/Scroll/scroll-bottom.png"
				ScrollingFrame_1z.CanvasPosition = Vector2.new(0, 0)
				ScrollingFrame_1z.ElasticBehavior = Enum.ElasticBehavior.WhenScrollable
				ScrollingFrame_1z.HorizontalScrollBarInset = Enum.ScrollBarInset.None
				ScrollingFrame_1z.MidImage = "rbxasset://textures/ui/Scroll/scroll-middle.png"
				ScrollingFrame_1z.ScrollBarImageColor3 = Color3.fromRGB(0,0,0)
				ScrollingFrame_1z.ScrollBarImageTransparency = 0
				ScrollingFrame_1z.ScrollBarThickness = 0
				ScrollingFrame_1z.ScrollingDirection = Enum.ScrollingDirection.XY
				ScrollingFrame_1z.TopImage = "rbxasset://textures/ui/Scroll/scroll-top.png"
				ScrollingFrame_1z.VerticalScrollBarInset = Enum.ScrollBarInset.None
				ScrollingFrame_1z.VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right

				UIListLayout_1.Parent = ScrollingFrame_1z
				UIListLayout_1.SortOrder = Enum.SortOrder.Name

				local NewValue = {}

				function NewValue:SetVisible(a)
					Dropdown.Visible = a
					DropdownSelect.Visible = a
				end

				function NewValue:Set(b)
					Title_1.Text = b
				end

				local isOpen = false
				game:GetService "UserInputService".InputBegan:Connect(function(A)
					if A.UserInputType == Enum.UserInputType.MouseButton1 or A.UserInputType == Enum.UserInputType.Touch then
						local B, C = DropdownSelect.AbsolutePosition, DropdownSelect.AbsoluteSize
						if game:GetService "Players".LocalPlayer:GetMouse().X < B.X or game:GetService "Players".LocalPlayer:GetMouse().X > B.X + C.X or game:GetService "Players".LocalPlayer:GetMouse().Y < (B.Y - 20 - 1) or game:GetService "Players".LocalPlayer:GetMouse().Y > B.Y + C.Y then
							isOpen = false
							tw({
								v = ImageLabel_1,
								t = 0.15,
								s = "Exponential",
								d = "Out",
								g = {Rotation = 0}
							}):Play()
							DropdownSelect.Visible = false
						end
					end
				end)
				TextBox_1.Changed:Connect(function()
					local SearchT = string.lower(TextBox_1.Text)
					for i, v in pairs(ScrollingFrame_1z:GetChildren()) do
						if v:IsA("Frame") then
							for _, k in pairs(v:GetChildren()) do
								if k.Name == "LabelFrame" then
									for _, a in pairs(k:GetChildren()) do
										if a:IsA("TextLabel") then
											local labelText = string.lower(a.Text)
											if string.find(labelText, SearchT, 1, true) then
												v.Visible = true
											else
												v.Visible = false
											end
										end
									end
								end
							end
						end
					end
				end)


				Click_1.MouseButton1Click:Connect(function()
					isOpen = not isOpen
					if isOpen then
						tw({
							v = ImageLabel_1,
							t = 0.15,
							s = "Exponential",
							d = "Out",
							g = {Rotation = 90}
						}):Play()
						task.wait(0.05)
						DropdownSelect.Visible = true
					else
						tw({
							v = ImageLabel_1,
							t = 0.15,
							s = "Exponential",
							d = "Out",
							g = {Rotation = 0}
						}):Play()
						task.wait(0.07)
						DropdownSelect.Visible = false
					end
				end)

				local itemslist = {}
				local selectedItem

				function itemslist:Clear(a)
					local function shouldClear(v)
						if a == nil then
							return true
						elseif type(a) == "string" then
							return v:FindFirstChild("LabelFrame") and v.LabelFrame:FindFirstChild("Title") and v.LabelFrame.Title.Text == a
						elseif type(a) == "table" then
							for _, name in ipairs(a) do
								if v:FindFirstChild("LabelFrame") and v.LabelFrame:FindFirstChild("Title") and v.LabelFrame.Title.Text == name then
									return true
								end
							end
						end
						return false
					end

					for _, v in ipairs(ScrollingFrame_1z:GetChildren()) do
						if v:IsA("Frame") and shouldClear(v) then
							if selectedItem and v:FindFirstChild("LabelFrame") and v.LabelFrame:FindFirstChild("Title") and v.LabelFrame.Title.Text == selectedItem then
								selectedItem = nil
								Selected_1.Text = ""
							end
							v:Destroy()
						end
					end

					if selectedItem == a or Selected_1.Text == a then
						selectedItem = nil
						Selected_1.Text = ""
					end

					if a == nil then
						selectedItem = nil
						Selected_1.Text = ""
					end
				end

				local selectedValues = {}

				function itemslist:AddList(text)

					local Item_1 = Instance.new("Frame")
					local LabelFrame_1 = Instance.new("Frame")
					local UICorner_2 = Instance.new("UICorner")
					local Title_1 = Instance.new("TextLabel")
					local UIGradient_1 = Instance.new("UIGradient")
					local SelectedFrame_1 = Instance.new("Frame")
					local UICorner_3 = Instance.new("UICorner")
					local Click_1 = Instance.new("TextButton")

					Item_1.Name = "Item"
					Item_1.Parent = ScrollingFrame_1z
					Item_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Item_1.BackgroundTransparency = 1
					Item_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Item_1.BorderSizePixel = 0
					Item_1.LayoutOrder = 2
					Item_1.Size = UDim2.new(1, 0,0, 25)

					LabelFrame_1.Name = "LabelFrame"
					LabelFrame_1.Parent = Item_1
					LabelFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
					LabelFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					LabelFrame_1.BackgroundTransparency = 1
					LabelFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
					LabelFrame_1.BorderSizePixel = 0
					LabelFrame_1.Position = UDim2.new(0.5, 0,0.5, 0)
					LabelFrame_1.Size = UDim2.new(0.899999976, 0,0, 25)

					UICorner_2.Parent = LabelFrame_1
					UICorner_2.CornerRadius = UDim.new(0,5)

					Title_1.Name = "Title"
					Title_1.Parent = LabelFrame_1
					Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Title_1.BackgroundTransparency = 1
					Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Title_1.BorderSizePixel = 0
					Title_1.Size = UDim2.new(1, 0,1, 0)
					Title_1.Font = Enum.Font.GothamBold
					Title_1.RichText = true
					Title_1.Text = tostring(text)
					Title_1.TextColor3 = Color3.fromRGB(204,204,204)
					Title_1.TextSize = 9
					Title_1.TextWrapped = true
					Title_1.TextTransparency = 0.5

					UIGradient_1.Parent = LabelFrame_1
					UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(113, 113, 113)), ColorSequenceKeypoint.new(1, Color3.fromRGB(94, 94, 94))}

					SelectedFrame_1.Name = "SelectedFrame"
					SelectedFrame_1.Parent = Item_1
					SelectedFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
					SelectedFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					SelectedFrame_1.BackgroundTransparency = 1
					SelectedFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
					SelectedFrame_1.BorderSizePixel = 0
					SelectedFrame_1.Position = UDim2.new(0.5, 0,0.899999976, 0)
					SelectedFrame_1.Size = UDim2.new(0, 40,0, 2)

					UICorner_3.Parent = SelectedFrame_1
					UICorner_3.CornerRadius = UDim.new(1,0)

					Click_1.Name = "Click"
					Click_1.Parent = Item_1
					Click_1.Active = true
					Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
					Click_1.BackgroundTransparency = 1
					Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
					Click_1.BorderSizePixel = 0
					Click_1.Size = UDim2.new(1, 0,1, 0)
					Click_1.Font = Enum.Font.SourceSans
					Click_1.Text = ""
					Click_1.TextSize = 14

					Click_1.MouseButton1Click:Connect(function()
						if Multi then
							if selectedValues[text] then
								selectedValues[text] = nil
								tw({
									v = Title_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0.5}
								}):Play()
								tw({
									v = SelectedFrame_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 1}
								}):Play()
							else
								selectedValues[text] = true
								tw({
									v = Title_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0}
								}):Play()
								tw({
									v = SelectedFrame_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 0.3}
								}):Play()
							end
							local selectedList = {}
							for i, v in pairs(selectedValues) do
								table.insert(selectedList, i)
							end
							if #selectedList > 0 then
								Selected_1.Text = table.concat(selectedList, ", ")
							else
								Selected_1.Text = ""
							end
							pcall(Callback, selectedList)
						else
							for i,v in pairs(ScrollingFrame_1z:GetChildren()) do
								if v:IsA("Frame") then
									tw({
										v = v.LabelFrame.Title,
										t = 0.15,
										s = "Exponential",
										d = "Out",
										g = {TextTransparency = 0.5}
									}):Play()
									tw({
										v = v.SelectedFrame,
										t = 0.15,
										s = "Exponential",
										d = "Out",
										g = {BackgroundTransparency = 1}
									}):Play()
								end
							end

							tw({
								v = Title_1,
								t = 0.15,
								s = "Exponential",
								d = "Out",
								g = {TextTransparency = 0}
							}):Play()
							tw({
								v = SelectedFrame_1,
								t = 0.15,
								s = "Exponential",
								d = "Out",
								g = {BackgroundTransparency = 0.3}
							}):Play()

							task.wait(0.07)
							DropdownSelect.Visible = false
							isOpen = false
							Value = text
							Selected_1.Text = text

							pcall(function()
								Callback(Selected_1.Text)
							end)
						end
					end)

					local function isValueInTable(val, tbl)
						if type(tbl) ~= "table" then
							return false
						end

						for _, v in pairs(tbl) do
							if v == val then
								return true
							end
						end
						return false
					end

					delay(0,function()
						if Multi then
							if isValueInTable(text, Value) then
								tw({
									v = Title_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0}
								}):Play()
								tw({
									v = SelectedFrame_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 0.3}
								}):Play()
								selectedValues[text] = true
								local selectedList = {}
								for i, v in pairs(selectedValues) do
									table.insert(selectedList, i)
								end
								if #selectedList > 0 then
									Selected_1.Text = table.concat(selectedList, ", ")
								else
									Selected_1.Text = ""
								end
								pcall(Callback, selectedList)
							end
						else
							if text == Value then
								tw({
									v = Title_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {TextTransparency = 0}
								}):Play()
								tw({
									v = SelectedFrame_1,
									t = 0.15,
									s = "Exponential",
									d = "Out",
									g = {BackgroundTransparency = 0.3}
								}):Play()

								Value = text
								Selected_1.Text = text
								Callback(Selected_1.Text)
							end
						end
					end)
				end

				for i,v in ipairs(List) do
					itemslist:AddList(v, i)
				end

				UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					ScrollingFrame_1z.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 5)
				end)

				return itemslist
			end

			function Fetching.Main:Video(info)
				local Video = info.Video

				local Toggle = Instance.new("Frame")
				local video = Instance.new("VideoFrame")
				local UICorner_1 = Instance.new("UICorner")

				Toggle.Name = "Image"
				Toggle.Parent = Section_1
				Toggle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				Toggle.BackgroundTransparency = 1
				Toggle.BorderSizePixel = 0
				Toggle.LayoutOrder = 2
				Toggle.Size = UDim2.new(1, 0, 0, 120)

				video.Name = "Im"
				video.Parent = Toggle
				video.AnchorPoint = Vector2.new(0.5, 0.5)
				video.Position = UDim2.new(0.5, 0, 0.5, 0)
				video.BackgroundTransparency = 1
				video.Size = UDim2.new(0.95, 0, 1, 0)
				video.Video = Video
				video.Looped = true
				video.Playing = true
				video.Volume = 0

				UICorner_1.Parent = video
				UICorner_1.CornerRadius = UDim.new(0, 3)

				local NewValue = {}

				function NewValue:SetVisible(a)
					Toggle.Visible = a
				end

				return NewValue
			end

			function Fetching.Main:Image(info)

				local Title = info.Title
				local Image = info.Image

				local Toggle = Instance.new("Frame")
				local ImageLogo = Instance.new("ImageLabel")
				local UICorner_1 = Instance.new("UICorner")

				Toggle.Name = "Image"
				Toggle.Parent = Section_1
				Toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Toggle.BackgroundTransparency = 1
				Toggle.BorderColor3 = Color3.fromRGB(0,0,0)
				Toggle.BorderSizePixel = 0
				Toggle.LayoutOrder = 2
				Toggle.Size = UDim2.new(1, 0,0, 120)

				ImageLogo.Name = "Im"
				ImageLogo.Parent = Toggle
				ImageLogo.AnchorPoint = Vector2.new(0.5,0.5)
				ImageLogo.Position = UDim2.new(0.5,0,0.5,0)
				ImageLogo.BackgroundTransparency = 1
				ImageLogo.Size = UDim2.new(0.95,0,1,0)
				ImageLogo.Image = GetIcon(Image)
				ImageLogo.ScaleType = Enum.ScaleType.Crop

				UICorner_1.Parent = ImageLogo
				UICorner_1.CornerRadius = UDim.new(0,3)

				local NewValue = {}

				function NewValue:SetVisible(a)
					Toggle.Visible = a
				end

				function NewValue:SetImage(b)
					ImageLogo.Image = GetIcon(b)
				end

				return NewValue
			end
			function Fetching.Main:CreateToggle(info)

				local Title = info.Title
				local Value = info.Value
				local Callback = info.CallBack or function() end

				local Toggle = Instance.new("Frame")
				local ListfunctionToggle_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Title_1 = Instance.new("TextLabel")
				local ToggleO_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local done_1 = Instance.new("ImageLabel")
				local UICorner_2 = Instance.new("UICorner")
				local UICorner_3 = Instance.new("UICorner")
				local Click_1 = Instance.new("TextButton")
				local Stroke = Instance.new("UIStroke")

				Toggle.Name = "Toggle"
				Toggle.Parent = Section_1
				Toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Toggle.BackgroundTransparency = 1
				Toggle.BorderColor3 = Color3.fromRGB(0,0,0)
				Toggle.BorderSizePixel = 0
				Toggle.LayoutOrder = 2
				Toggle.Size = UDim2.new(1, 0,0, 42)

				ListfunctionToggle_1.Name = "ListfunctionToggle"
				ListfunctionToggle_1.Parent = Toggle
				ListfunctionToggle_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ListfunctionToggle_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				ListfunctionToggle_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ListfunctionToggle_1.BorderSizePixel = 0
				ListfunctionToggle_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ListfunctionToggle_1.Size = UDim2.new(0.95, 0,0, 42)

				Stroke.Parent = ListfunctionToggle_1
				Stroke.Thickness = 0
				Stroke.Color = Color3.fromRGB(56,56,56)

				UIListLayout_1.Parent = ListfunctionToggle_1
				UIListLayout_1.Padding = UDim.new(0,0)
				UIListLayout_1.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				Title_1.Name = "Title"
				Title_1.Parent = ListfunctionToggle_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(0.800000012, 0,1, 0)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 13
				Title_1.TextTransparency = 0.5
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				ToggleO_1.Name = "ToggleO"
				ToggleO_1.Parent = ListfunctionToggle_1
				ToggleO_1.BackgroundColor3 = Color3.fromRGB(18,18,18)
				ToggleO_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ToggleO_1.BorderSizePixel = 0
				ToggleO_1.LayoutOrder = 1
				ToggleO_1.Size = UDim2.new(0, 20,0, 20)

				local UIGD = Instance.new("UIGradient")
				UIGD.Parent = ToggleO_1
				UIGD.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}
				UIGD.Offset = Vector2.new(0.200000003, 0)
				UIGD.Rotation = 6

				UICorner_1.Parent = ToggleO_1
				UICorner_1.CornerRadius = UDim.new(0,4)

				done_1.Name = "done"
				done_1.Parent = ToggleO_1
				done_1.AnchorPoint = Vector2.new(0.5, 0.5)
				done_1.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
				done_1.BackgroundTransparency = 1
				done_1.BorderColor3 = Color3.fromRGB(27,27,27)
				done_1.Position = UDim2.new(0.5, 0,0.5, 0)
				done_1.Size = UDim2.new(1, 0,1, 0)
				done_1.ZIndex = 2
				done_1.Image = "rbxassetid://3926305904"
				done_1.ImageColor3 = Color3.fromRGB(255, 255, 255)
				done_1.ImageRectOffset = Vector2.new(644, 204)
				done_1.ImageRectSize = Vector2.new(36, 36)
				done_1.ImageTransparency = 1

				UICorner_2.Parent = done_1
				UICorner_2.CornerRadius = UDim.new(0,4)

				UICorner_3.Parent = ListfunctionToggle_1
				UICorner_3.CornerRadius = UDim.new(0,5)

				Click_1.Name = "Click"
				Click_1.Parent = Toggle
				Click_1.Active = true
				Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Click_1.BackgroundTransparency = 1
				Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Click_1.BorderSizePixel = 0
				Click_1.Size = UDim2.new(1, 0,1, 0)
				Click_1.Font = Enum.Font.SourceSans
				Click_1.Text = ""
				Click_1.TextSize = 14

				local function ToggleC(Value)
					if not Value then 
						Callback(Value)
						tw({
							v = ToggleO_1,
							t = 0.15,
							s = "Linear",
							d = "Out",
							g = {BackgroundColor3 = Color3.fromRGB(25,25,25)}
						}):Play()
						tw({
							v = Stroke,
							t = 0.15,
							s = "Linear",
							d = "Out",
							g = {Thickness = 0}
						}):Play()
						tw({
							v = Title_1,
							t = 0.3,
							s = "Linear",
							d = "Out",
							g = {TextTransparency = 0.5}
						}):Play()
						tw({
							v = done_1,
							t = 0.3,
							s = "Elastic",
							d = "Out",
							g = {ImageTransparency = 1, Size = UDim2.new(0, 0,0, 0), Rotation = 360}
						}):Play()
					elseif Value then 
						Callback(Value)
						local blackgroundtoggle = tw({
							v = ToggleO_1,
							t = 0.15,
							s = "Linear",
							d = "Out",
							g = {BackgroundColor3 = Color3.fromRGB(255,255,255)}
						})
						tw({
							v = Stroke,
							t = 0.15,
							s = "Linear",
							d = "Out",
							g = {Thickness = 1}
						}):Play()
						blackgroundtoggle:Play()
						tw({
							v = Title_1,
							t = 0.3,
							s = "Linear",
							d = "Out",
							g = {TextTransparency = 0}
						}):Play()
						blackgroundtoggle.Completed:Connect(function()
							tw({
								v = done_1,
								t = 0.3,
								s = "Back",
								d = "Out",
								g = {ImageTransparency = 0, Size = UDim2.new(0.8, 0,0.8, 0), Rotation = 0}
							}):Play()
						end)
					end
				end

				Click_1.MouseButton1Click:Connect(function()
					Value = not Value
					ToggleC(Value)
				end)

				ToggleC(Value)

				local NewValue = {}

				function NewValue:SetValue(a)
					Value = a
					ToggleC(Value)
				end

				function NewValue:SetVisible(a)
					Toggle.Visible = a
				end

				function NewValue:Set(b)
					Title_1.Text = b
				end

				return NewValue
			end

			function Fetching.Main:ImageToggle(info)

				local Title = info.Title
				local Value = info.Value
				local Iconz = info.Icon
				local Callback = info.CallBack or function() end

				local Toggle = Instance.new("Frame")
				local ListfunctionToggle_1 = Instance.new("Frame")
				local Title_1 = Instance.new("TextLabel")
				local ToggleO_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local done_1 = Instance.new("ImageLabel")
				local UICorner_2 = Instance.new("UICorner")
				local UICorner_3 = Instance.new("UICorner")
				local Click_1 = Instance.new("TextButton")
				local Stroke = Instance.new("UIStroke")
				local Icon5 = Instance.new("ImageLabel")

				Toggle.Name = "Toggle"
				Toggle.Parent = Section_1
				Toggle.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Toggle.BackgroundTransparency = 1
				Toggle.BorderColor3 = Color3.fromRGB(0,0,0)
				Toggle.BorderSizePixel = 0
				Toggle.LayoutOrder = 2
				Toggle.Size = UDim2.new(1, 0,0, 42)

				ListfunctionToggle_1.Name = "ListfunctionToggle"
				ListfunctionToggle_1.Parent = Toggle
				ListfunctionToggle_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ListfunctionToggle_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				ListfunctionToggle_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ListfunctionToggle_1.BorderSizePixel = 0
				ListfunctionToggle_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ListfunctionToggle_1.Size = UDim2.new(0.95, 0,0, 42)

				Stroke.Parent = ListfunctionToggle_1
				Stroke.Thickness = 0
				Stroke.Color = Color3.fromRGB(56,56,56)

				Title_1.Name = "Title"
				Title_1.Parent = ListfunctionToggle_1
				Title_1.AnchorPoint = Vector2.new(0.5,0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(0.61, 0,0.5, 0)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.Position = UDim2.new(0.5,0,0.5,0)
				Title_1.TextSize = 11
				Title_1.TextTransparency = 0.5
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				ToggleO_1.Name = "ToggleO"
				ToggleO_1.Parent = ListfunctionToggle_1
				ToggleO_1.BackgroundColor3 = Color3.fromRGB(18,18,18)
				ToggleO_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ToggleO_1.BorderSizePixel = 0
				ToggleO_1.Position = UDim2.new(0.9,0,0.5,0)
				ToggleO_1.LayoutOrder = 1
				ToggleO_1.Size = UDim2.new(0, 20,0, 20)
				ToggleO_1.AnchorPoint = Vector2.new(0.5,0.5)

				local UIGD = Instance.new("UIGradient")
				UIGD.Parent = ToggleO_1
				UIGD.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}
				UIGD.Offset = Vector2.new(0.200000003, 0)
				UIGD.Rotation = 6

				UICorner_1.Parent = ToggleO_1
				UICorner_1.CornerRadius = UDim.new(0,4)

				done_1.Name = "done"
				done_1.Parent = ToggleO_1
				done_1.AnchorPoint = Vector2.new(0.5, 0.5)
				done_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				done_1.BackgroundTransparency = 1
				done_1.BorderColor3 = Color3.fromRGB(27,27,27)
				done_1.Position = UDim2.new(0.5, 0,0.5, 0)
				done_1.Size = UDim2.new(1, 0,1, 0)
				done_1.ZIndex = 2
				done_1.Image = "rbxassetid://3926305904"
				done_1.ImageColor3 = Color3.fromRGB(255, 255, 255)
				done_1.ImageRectOffset = Vector2.new(644, 204)
				done_1.ImageRectSize = Vector2.new(36, 36)
				done_1.ImageTransparency = 1

				UICorner_2.Parent = done_1
				UICorner_2.CornerRadius = UDim.new(0,4)

				UICorner_3.Parent = ListfunctionToggle_1
				UICorner_3.CornerRadius = UDim.new(0,5)

				Click_1.Name = "Click"
				Click_1.Parent = Toggle
				Click_1.Active = true
				Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Click_1.BackgroundTransparency = 1
				Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Click_1.BorderSizePixel = 0
				Click_1.Size = UDim2.new(1, 0,1, 0)
				Click_1.Font = Enum.Font.SourceSans
				Click_1.Text = ""
				Click_1.TextSize = 14

				Icon5.BackgroundTransparency = 1
				Icon5.AnchorPoint = Vector2.new(0.5,0.5)
				Icon5.Position = UDim2.new(0.1,0,0.5,0)
				Icon5.Parent = ListfunctionToggle_1
				Icon5.Image = Iconz
				Icon5.Size = UDim2.new(0,30,0,30)
				Icon5.ImageTransparency = 0.5

				local function ToggleC(Value)
					if not Value then 
						Callback(Value)
						tw({
							v = ToggleO_1,
							t = 0.15,
							s = "Linear",
							d = "Out",
							g = {BackgroundColor3 = Color3.fromRGB(25,25,25)}
						}):Play()
						tw({
							v = Stroke,
							t = 0.15,
							s = "Linear",
							d = "Out",
							g = {Thickness = 0}
						}):Play()
						tw({
							v = Title_1,
							t = 0.3,
							s = "Linear",
							d = "Out",
							g = {TextTransparency = 0.5}
						}):Play()
						tw({
							v = done_1,
							t = 0.3,
							s = "Linear",
							d = "Out",
							g = {ImageTransparency = 1, Size = UDim2.new(0, 0,0, 0), Rotation = 360}
						}):Play()
						tw({
							v = Icon5,
							t = 0.3,
							s = "Linear",
							d = "Out",
							g = {ImageTransparency = 0.5}
						}):Play()
					elseif Value then 
						Callback(Value)
						local blackgroundtoggle = tw({
							v = ToggleO_1,
							t = 0.15,
							s = "Linear",
							d = "Out",
							g = {BackgroundColor3 = Color3.fromRGB(255,255,255)}
						})
						tw({
							v = Stroke,
							t = 0.15,
							s = "Linear",
							d = "Out",
							g = {Thickness = 1}
						}):Play()
						blackgroundtoggle:Play()
						tw({
							v = Title_1,
							t = 0.3,
							s = "Linear",
							d = "Out",
							g = {TextTransparency = 0}
						}):Play()
						blackgroundtoggle.Completed:Connect(function()
							tw({
								v = done_1,
								t = 0.3,
								s = "Back",
								d = "Out",
								g = {ImageTransparency = 0, Size = UDim2.new(0.8, 0,0.8, 0), Rotation = 0}
							}):Play()
						end)
						tw({
							v = Icon5,
							t = 0.3,
							s = "Linear",
							d = "Out",
							g = {ImageTransparency = 0}
						}):Play()
					end
				end

				Click_1.MouseButton1Click:Connect(function()
					Value = not Value
					ToggleC(Value)
				end)

				ToggleC(Value)

				local NewValue = {}

				function NewValue:SetValue(a)
					Value = a
					ToggleC(Value)
				end

				function NewValue:SetImage(a)
					Icon5.Image = a
				end

				function NewValue:SetVisible(a)
					Toggle.Visible = a
				end

				function NewValue:Set(b)
					Title_1.Text = b
				end

				return NewValue
			end

			function Fetching.Main:CreateImage(info)

				local Title = info.Title
				local Desc = info.Desc
				local Icon = info.Icon

				local Image = Instance.new("Frame")
				local Inside_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local TextHub_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Desc_1 = Instance.new("TextLabel")
				local Title_1 = Instance.new("TextLabel")
				local ImageID_1 = Instance.new("ImageLabel")
				local UICorner_2 = Instance.new("UICorner")

				Image.Name = "Image"
				Image.Parent = Section_1
				Image.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Image.BackgroundTransparency = 1
				Image.BorderColor3 = Color3.fromRGB(0,0,0)
				Image.BorderSizePixel = 0
				Image.LayoutOrder = 2
				Image.Size = UDim2.new(1, 0,0, 50)

				Inside_1.Name = "Inside"
				Inside_1.Parent = Image
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inside_1.BorderSizePixel = 0
				Inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inside_1.Size = UDim2.new(0.95, 0,1, 0)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = Inside_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(56,56,56)

				UICorner_1.Parent = Inside_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				TextHub_1.Name = "TextHub"
				TextHub_1.Parent = Inside_1
				TextHub_1.AnchorPoint = Vector2.new(0, 0.5)
				TextHub_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextHub_1.BackgroundTransparency = 1
				TextHub_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextHub_1.BorderSizePixel = 0
				TextHub_1.Position = UDim2.new(0.2, 0,0.5, 0)
				TextHub_1.Size = UDim2.new(0.75, 0,0.800000012, 0)

				UIListLayout_1.Parent = TextHub_1
				UIListLayout_1.Padding = UDim.new(0,2)
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				Desc_1.Name = "Desc"
				Desc_1.Parent = TextHub_1
				Desc_1.AutomaticSize = Enum.AutomaticSize.Y
				Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Desc_1.BackgroundTransparency = 1
				Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Desc_1.BorderSizePixel = 0
				Desc_1.LayoutOrder = 1
				Desc_1.Position = UDim2.new(0.248750001, 0,0.0944999978, 0)
				Desc_1.Size = UDim2.new(0, 175,0, 11)
				Desc_1.Font = Enum.Font.GothamBold
				Desc_1.Text = tostring(Desc)
				Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
				Desc_1.TextSize = 8
				Desc_1.TextTransparency = 0
				Desc_1.TextXAlignment = Enum.TextXAlignment.Left
				Desc_1.TextWrapped = true
				Desc_1.RichText = true

				Title_1.Name = "Title"
				Title_1.Parent = TextHub_1
				Title_1.AutomaticSize = Enum.AutomaticSize.Y
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.248750001, 0,0.0644999966, 0)
				Title_1.Size = UDim2.new(0, 130,0, 11)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 12
				Title_1.TextXAlignment = Enum.TextXAlignment.Left
				Title_1.RichText = true

				ImageID_1.Parent = Inside_1
				ImageID_1.AnchorPoint = Vector2.new(1, 0.5)
				ImageID_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageID_1.BackgroundTransparency = 1
				ImageID_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageID_1.BorderSizePixel = 0
				ImageID_1.Position = UDim2.new(0.18, 0,0.5, 0)
				ImageID_1.Size = UDim2.new(0, 35,0, 35)
				ImageID_1.Image = Icon

				UICorner_2.Parent = ImageID_1

				UICorner_2.CornerRadius = UDim.new(0,4)

				UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					Image.Size = UDim2.new(1, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 22)
				end)

				local NewValue = {}

				function NewValue:SetImage(a)
					ImageID_1.Image = a
				end

				function NewValue:SetVisible(a)
					Image.Visible = a
				end

				function NewValue:SetTitle(b)
					Title_1.Text = b
				end

				function NewValue:SetDesc(c)
					Desc_1.Text = c
				end

				return NewValue
			end
			function Fetching.Main:ButtonImage(info)

				local Title = info.Title
				local Desc = info.Desc
				local Icon = info.Icon
				local c = info.Callback

				local Image = Instance.new("Frame")
				local Inside_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local TextHub_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Desc_1 = Instance.new("TextLabel")
				local Title_1 = Instance.new("TextLabel")
				local ImageID_1x = Instance.new("ImageLabel")
				local UICorner_2 = Instance.new("UICorner")

				Image.Name = "Image"
				Image.Parent = Section_1
				Image.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Image.BackgroundTransparency = 1
				Image.BorderColor3 = Color3.fromRGB(0,0,0)
				Image.BorderSizePixel = 0
				Image.LayoutOrder = 2
				Image.Size = UDim2.new(1, 0,0, 50)

				Inside_1.Name = "Inside"
				Inside_1.Parent = Image
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inside_1.BorderSizePixel = 0
				Inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inside_1.Size = UDim2.new(0.95, 0,1, 0)
				Inside_1.ClipsDescendants = true

				local b = click(Inside_1)
				b.MouseButton1Click:Connect(function()
					ButtoneffectClick(b, Inside_1)
					c()
				end)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = Inside_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(56,56,56)

				UICorner_1.Parent = Inside_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				TextHub_1.Name = "TextHub"
				TextHub_1.Parent = Inside_1
				TextHub_1.AnchorPoint = Vector2.new(0, 0.5)
				TextHub_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextHub_1.BackgroundTransparency = 1
				TextHub_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextHub_1.BorderSizePixel = 0
				TextHub_1.Position = UDim2.new(0.2, 0,0.5, 0)
				TextHub_1.Size = UDim2.new(0.75, 0,0.800000012, 0)

				UIListLayout_1.Parent = TextHub_1
				UIListLayout_1.Padding = UDim.new(0,2)
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				Desc_1.Name = "Desc"
				Desc_1.Parent = TextHub_1
				Desc_1.AutomaticSize = Enum.AutomaticSize.Y
				Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Desc_1.BackgroundTransparency = 1
				Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Desc_1.BorderSizePixel = 0
				Desc_1.LayoutOrder = 1
				Desc_1.Position = UDim2.new(0.248750001, 0,0.0944999978, 0)
				Desc_1.Size = UDim2.new(0, 175,0, 11)
				Desc_1.Font = Enum.Font.GothamBold
				Desc_1.Text = tostring(Desc)
				Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
				Desc_1.TextSize = 8
				Desc_1.TextTransparency = 0
				Desc_1.TextXAlignment = Enum.TextXAlignment.Left
				Desc_1.TextWrapped = true
				Desc_1.RichText = true

				Title_1.Name = "Title"
				Title_1.Parent = TextHub_1
				Title_1.AutomaticSize = Enum.AutomaticSize.Y
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.248750001, 0,0.0644999966, 0)
				Title_1.Size = UDim2.new(0, 130,0, 11)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 11
				Title_1.TextXAlignment = Enum.TextXAlignment.Left
				Title_1.RichText = true

				ImageID_1x.Parent = Inside_1
				ImageID_1x.AnchorPoint = Vector2.new(1, 0.5)
				ImageID_1x.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageID_1x.BackgroundTransparency = 1
				ImageID_1x.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageID_1x.BorderSizePixel = 0
				ImageID_1x.Position = UDim2.new(0.18, 0,0.5, 0)
				ImageID_1x.Size = UDim2.new(0, 35,0, 35)
				ImageID_1x.Image = Icon

				local ImageLabel_1 = Instance.new("ImageLabel")
				ImageLabel_1.Parent = Inside_1
				ImageLabel_1.AnchorPoint = Vector2.new(1, 0.5)
				ImageLabel_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ImageLabel_1.BackgroundTransparency = 1
				ImageLabel_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ImageLabel_1.BorderSizePixel = 0
				ImageLabel_1.Position = UDim2.new(0.95, 0,0.5, 0)
				ImageLabel_1.Rotation = 270
				ImageLabel_1.Size = UDim2.new(0, 15,0, 15)
				ImageLabel_1.Image = "rbxassetid://13858857904"
				ImageLabel_1.ImageTransparency = 0.5

				UICorner_2.Parent = ImageID_1x

				UICorner_2.CornerRadius = UDim.new(0,4)

				UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					Image.Size = UDim2.new(1, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 22)
				end)

				local NewValue = {}

				function NewValue:SetImage(a)
					ImageID_1x.Image = a
				end

				function NewValue:SetVisible(a)
					Image.Visible = a
				end

				function NewValue:SetTitle(b)
					Title_1.Text = b
				end

				function NewValue:SetDesc(c)
					Desc_1.Text = c
				end

				return NewValue
			end
			function Fetching.Main:Create(info)

				local Title = info.Title
				local Desc = info.Desc
				local Icon = info.Icon

				local Image = Instance.new("Frame")
				local Inside_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local TextHub_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Desc_1 = Instance.new("TextLabel")
				local Title_1 = Instance.new("TextLabel")

				Image.Name = "AA"
				Image.Parent = Section_1
				Image.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Image.BackgroundTransparency = 1
				Image.BorderColor3 = Color3.fromRGB(0,0,0)
				Image.BorderSizePixel = 0
				Image.LayoutOrder = 2
				Image.Size = UDim2.new(1, 0,0, 50)

				Inside_1.Name = "Inside"
				Inside_1.Parent = Image
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inside_1.BorderSizePixel = 0
				Inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inside_1.Size = UDim2.new(0.95, 0,1, 0)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = Inside_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(56,56,56)

				UICorner_1.Parent = Inside_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				TextHub_1.Name = "TextHub"
				TextHub_1.Parent = Inside_1
				TextHub_1.AnchorPoint = Vector2.new(0, 0.5)
				TextHub_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextHub_1.BackgroundTransparency = 1
				TextHub_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextHub_1.BorderSizePixel = 0
				TextHub_1.Position = UDim2.new(0.05, 0,0.5, 0)
				TextHub_1.Size = UDim2.new(0.75, 0,0.800000012, 0)

				UIListLayout_1.Parent = TextHub_1
				UIListLayout_1.Padding = UDim.new(0,2)
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				Desc_1.Name = "Desc"
				Desc_1.Parent = TextHub_1
				Desc_1.AutomaticSize = Enum.AutomaticSize.Y
				Desc_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Desc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Desc_1.BackgroundTransparency = 1
				Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Desc_1.BorderSizePixel = 0
				Desc_1.LayoutOrder = 1
				Desc_1.Position = UDim2.new(0.248750001, 0,0.0944999978, 0)
				Desc_1.Size = UDim2.new(0, 175,0, 11)
				Desc_1.Font = Enum.Font.GothamBold
				Desc_1.Text = tostring(Desc)
				Desc_1.TextColor3 = Color3.fromRGB(255,255,255)
				Desc_1.TextSize = 8
				Desc_1.TextTransparency = 0.5
				Desc_1.TextXAlignment = Enum.TextXAlignment.Left
				Desc_1.TextWrapped = true
				Desc_1.RichText = true

				Title_1.Name = "Title"
				Title_1.Parent = TextHub_1
				Title_1.AutomaticSize = Enum.AutomaticSize.Y
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.248750001, 0,0.0644999966, 0)
				Title_1.Size = UDim2.new(0, 130,0, 11)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 11
				Title_1.TextXAlignment = Enum.TextXAlignment.Left
				Title_1.RichText = true

				UIListLayout_1:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
					Image.Size = UDim2.new(1, 0, 0, UIListLayout_1.AbsoluteContentSize.Y + 15)
				end)

				local NewValue = {}

				function NewValue:SetVisible(a)
					Image.Visible = a
				end

				function NewValue:SetTitle(b)
					Title_1.Text = b
				end

				function NewValue:SetDesc(c)
					Desc_1.Text = c
				end

				return NewValue
			end
			function Fetching.Main:CreateLabel(info)

				local Title = info.Title
				local Side = info.Side

				local function GetAlignment(va)
					local sideLower = string.lower(tostring(va))
					if sideLower == "left" then
						return Enum.TextXAlignment.Left
					elseif sideLower == "right" then
						return Enum.TextXAlignment.Right
					else
						return Enum.TextXAlignment.Center
					end
				end

				local Label = Instance.new("Frame")
				local LabelFrame_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local Title_1 = Instance.new("TextLabel")
				local UIGradient_1 = Instance.new("UIGradient")

				Label.Name = "Label"
				Label.Parent = Section_1
				Label.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Label.BackgroundTransparency = 1
				Label.BorderColor3 = Color3.fromRGB(0,0,0)
				Label.BorderSizePixel = 0
				Label.LayoutOrder = 2
				Label.Size = UDim2.new(1, 0,0, 15)

				LabelFrame_1.Name = "LabelFrame"
				LabelFrame_1.Parent = Label
				LabelFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
				LabelFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				LabelFrame_1.BackgroundTransparency = 1
				LabelFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				LabelFrame_1.BorderSizePixel = 0
				LabelFrame_1.Position = UDim2.new(0.5, 0,0.5, 0)
				LabelFrame_1.Size = UDim2.new(0.899999976, 0,0, 25)

				UICorner_1.Parent = LabelFrame_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				Title_1.Name = "Title"
				Title_1.Parent = LabelFrame_1
				Title_1.AnchorPoint = Vector2.new(0 ,0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(1, 0,1, 0)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.RichText = true
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(204,204,204)
				Title_1.TextSize = 15
				Title_1.TextWrapped = true
				Title_1.TextXAlignment = GetAlignment(Side)
				Title_1.Position = UDim2.new(0, 0,0.5, 0)

				UIGradient_1.Parent = LabelFrame_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(113, 113, 113)), ColorSequenceKeypoint.new(1, Color3.fromRGB(94, 94, 94))}

				Title_1.Size = UDim2.new(1, 0, 0, Title_1.TextBounds.Y)
				LabelFrame_1.Size = UDim2.new(.9, 0, 0, Title_1.TextBounds.Y + 5)
				Label.Size = UDim2.new(1, 0, 0, Title_1.TextBounds.Y + 5)

				local NewText = {}

				function NewText:SetVisible(a)
					Label.Visible = a
				end

				function NewText:Set(b)
					Title_1.Text = tostring(b)
					Title_1.Size = UDim2.new(1, 0, 0, Title_1.TextBounds.Y)
					LabelFrame_1.Size = UDim2.new(.9, 0, 0, Title_1.TextBounds.Y + 5)
					Label.Size = UDim2.new(1, 0, 0, Title_1.TextBounds.Y + 10)
				end
				return NewText
			end
			function Fetching.Main:CreateButton(info)

				local Title = info.Title
				local Callback = info.Callback or function() end

				local Button = Instance.new("Frame")
				local ButtonFrame_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local Title_1 = Instance.new("TextLabel")
				local UIGradient_1 = Instance.new("UIGradient")
				local Click_1 = Instance.new("TextButton")

				Button.Name = "Button"
				Button.Parent = Section_1
				Button.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Button.BackgroundTransparency = 1
				Button.BorderColor3 = Color3.fromRGB(0,0,0)
				Button.BorderSizePixel = 0
				Button.LayoutOrder = 2
				Button.Size = UDim2.new(1, 0,0, 25)

				ButtonFrame_1.Name = "ButtonFrame"
				ButtonFrame_1.Parent = Button
				ButtonFrame_1.AnchorPoint = Vector2.new(0.5, 0.5)
				ButtonFrame_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ButtonFrame_1.BackgroundTransparency = 0
				ButtonFrame_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ButtonFrame_1.BorderSizePixel = 0
				ButtonFrame_1.Position = UDim2.new(0.5, 0,0.5, 0)
				ButtonFrame_1.Size = UDim2.new(0.95, 0,0, 25)
				ButtonFrame_1.ClipsDescendants = true

				UICorner_1.Parent = ButtonFrame_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				Title_1.Name = "Title"
				Title_1.Parent = ButtonFrame_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(1, 0,1, 0)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 11

				UIGradient_1.Parent = ButtonFrame_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}

				Click_1.Name = "Click"
				Click_1.Parent = Button
				Click_1.Active = true
				Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Click_1.BackgroundTransparency = 1
				Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Click_1.BorderSizePixel = 0
				Click_1.Size = UDim2.new(1, 0,1, 0)
				Click_1.Font = Enum.Font.SourceSans
				Click_1.Text = ""
				Click_1.TextSize = 14

				Click_1.MouseButton1Click:Connect(function()
					ButtoneffectClick(Click_1, ButtonFrame_1)
					Callback()
				end)

				local NewValue = {}

				function NewValue:SetVisible(a)
					Button.Visible = a
				end

				function NewValue:Set(b)
					Title_1.Text = b
				end

				return NewValue
			end

			function Fetching.Main:Line()
				local Line_2 = Instance.new("Frame")
				Line_2.Name = "Line"
				Line_2.Parent = Section_1
				Line_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Line_2.BackgroundTransparency = 0.9
				Line_2.BorderColor3 = Color3.fromRGB(0,0,0)
				Line_2.LayoutOrder = 2
				Line_2.BorderSizePixel = 0
				Line_2.Size = UDim2.new(1, 0,0, 1)
				local new = {}
				function new:SetVisible(a)
					Line_2.Visible = a
				end
				return new
			end
			UIListLayout_12:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				PageLeft_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_12.AbsoluteContentSize.Y + 20)
			end)
			UIListLayout_13:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				PageRight_1.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_13.AbsoluteContentSize.Y + 20)
			end)

			UIListLayout_9:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				Section_1.Size = UDim2.new(0.99000001, 0, 0, UIListLayout_9.AbsoluteContentSize.Y + 10)
			end)
			function Fetching.Main:CreateSlider(info)

				local Title = info.Title
				local Desc = info.Desc
				local Min = info.Min or 0
				local Max = info.Max or 100
				local Rounding = info.Rounding or 0
				local Value = info.Value or Min
				local Callback = info.CallBack or function() end

				local Slider = Instance.new("Frame")
				local Inslider_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local TextHub_1 = Instance.new("Frame")
				local Title_1 = Instance.new("TextLabel")
				local SliderBar_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local SliderBarValue_1 = Instance.new("Frame")
				local UICorner_3 = Instance.new("UICorner")
				local UIGradient_1 = Instance.new("UIGradient")
				local Click_1 = Instance.new("TextButton")
				local ValueBox_1 = Instance.new("TextBox")
				local UICorner_4 = Instance.new("UICorner")
				local stroke = Instance.new("UIStroke")

				Slider.Name = "Slider"
				Slider.Parent = Section_1
				Slider.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Slider.BackgroundTransparency = 1
				Slider.BorderColor3 = Color3.fromRGB(0,0,0)
				Slider.BorderSizePixel = 0
				Slider.LayoutOrder = 2
				Slider.Size = UDim2.new(1, 0,0, 40)

				Inslider_1.Name = "Inslider"
				Inslider_1.Parent = Slider
				Inslider_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inslider_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Inslider_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inslider_1.BorderSizePixel = 0
				Inslider_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inslider_1.Size = UDim2.new(0.95, 0,1, 0)

				UICorner_1.Parent = Inslider_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				stroke.Parent = Inslider_1
				stroke.Color = Color3.fromRGB(79,79,79)
				stroke.Thickness = 1

				TextHub_1.Name = "TextHub"
				TextHub_1.Parent = Inslider_1
				TextHub_1.AnchorPoint = Vector2.new(0, 0.5)
				TextHub_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextHub_1.BackgroundTransparency = 1
				TextHub_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextHub_1.BorderSizePixel = 0
				TextHub_1.Position = UDim2.new(0.0299999993, 0,0.5, 0)
				TextHub_1.Size = UDim2.new(1, 0,0.800000012, 0)

				Title_1.Name = "Title"
				Title_1.Parent = TextHub_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0, 0,0, 3)
				Title_1.Size = UDim2.new(0, 150,0, 11)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 11
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				SliderBar_1.Name = "SliderBar"
				SliderBar_1.Parent = Slider
				SliderBar_1.AnchorPoint = Vector2.new(0.5, 0.5)
				SliderBar_1.BackgroundColor3 = Color3.fromRGB(14,14,14)
				SliderBar_1.BorderColor3 = Color3.fromRGB(0,0,0)
				SliderBar_1.BorderSizePixel = 0
				SliderBar_1.Position = UDim2.new(0.5, 0,0.75, 0)
				SliderBar_1.Size = UDim2.new(0, 210,0, 5)

				UICorner_2.Parent = SliderBar_1
				UICorner_2.CornerRadius = UDim.new(1,0)

				SliderBarValue_1.Name = "SliderBarValue"
				SliderBarValue_1.Parent = SliderBar_1
				SliderBarValue_1.AnchorPoint = Vector2.new(0, 0.5)
				SliderBarValue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				SliderBarValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
				SliderBarValue_1.BorderSizePixel = 0
				SliderBarValue_1.Position = UDim2.new(0, 0,0.5, 0)
				SliderBarValue_1.Size = UDim2.new(0.800000012, 0,0, 8)

				local ValueLine = Instance.new("Frame")
				local UICornerBar_1 = Instance.new("UICorner")
				local sks = Instance.new("UIStroke")
				local gr = Instance.new("UIGradient")

				ValueLine.Name = "ValueLine"
				ValueLine.Parent = SliderBarValue_1
				ValueLine.AnchorPoint = Vector2.new(1, 0.5)
				ValueLine.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ValueLine.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueLine.BorderSizePixel = 0
				ValueLine.Position = UDim2.new(1, 0,0.5, 0)
				ValueLine.Size = UDim2.new(0, 8,0, 8)

				sks.Parent = ValueLine
				sks.Color = Color3.fromRGB(255, 255, 255)
				sks.Thickness = 2.5

				gr.Parent = sks
				gr.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}
				gr.Rotation = 180

				UICornerBar_1.Parent = ValueLine
				UICornerBar_1.CornerRadius = UDim.new(1,0)

				UICorner_3.Parent = SliderBarValue_1
				UICorner_3.CornerRadius = UDim.new(1,0)

				UIGradient_1.Parent = SliderBarValue_1
				UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)}
				UIGradient_1.Rotation = 0

				Click_1.Name = "Click"
				Click_1.Parent = SliderBar_1
				Click_1.Active = true
				Click_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Click_1.BackgroundTransparency = 1
				Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Click_1.BorderSizePixel = 0
				Click_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Click_1.Size = UDim2.new(1, 10,1, 10)
				Click_1.Font = Enum.Font.SourceSans
				Click_1.Text = ""
				Click_1.TextSize = 14

				ValueBox_1.Name = "ValueBox"
				ValueBox_1.Parent = Slider
				ValueBox_1.Active = true
				ValueBox_1.AnchorPoint = Vector2.new(1, 0.5)
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
				ValueBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.Position = UDim2.new(0.95, 0,0.349999994, 0)
				ValueBox_1.Size = UDim2.new(0, 30,0, 15)
				ValueBox_1.Font = Enum.Font.GothamBold
				ValueBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
				ValueBox_1.PlaceholderText = ""
				ValueBox_1.Text = tostring(Value)
				ValueBox_1.TextColor3 = Color3.fromRGB(255,255,255)
				ValueBox_1.TextSize = 10
				ValueBox_1.TextTransparency = 0.30000001192092896

				UICorner_4.Parent = ValueBox_1
				UICorner_4.CornerRadius = UDim.new(1,0)

				local function roundToDecimal(value, decimals)
					local factor = 10 ^ decimals
					return math.floor(value * factor + 0.5) / factor
				end

				local function updateSlider(value)
					value = math.clamp(value, Min, Max)
					value = roundToDecimal(value, Rounding)

					tw({
						v = SliderBarValue_1,
						t = 0.15,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new((value - Min) / (Max - Min), 0, 1, 0)}
					}):Play()

					local startValue = tonumber(ValueBox_1.Text) or 0
					local targetValue = value

					local steps = 5
					local currentValue = startValue
					for i = 1, steps do
						wait(0.1 / steps)
						currentValue = currentValue + (targetValue - startValue) / steps
						ValueBox_1.Text = tostring(roundToDecimal(currentValue, Rounding))
						ValueBox_1.Size = UDim2.new(0, ValueBox_1.TextBounds.X + 20, 0, 15)
					end

					ValueBox_1.Text = tostring(roundToDecimal(targetValue, Rounding))
					ValueBox_1.Size = UDim2.new(0, ValueBox_1.TextBounds.X + 20, 0, 15)

					Callback(value)
				end

				updateSlider(Value or 0)

				ValueBox_1.FocusLost:Connect(function()
					local value = tonumber(ValueBox_1.Text) or Min
					updateSlider(value)
				end)

				local function move(input)
					local sliderBar = SliderBar_1
					local relativeX = math.clamp((input.Position.X - sliderBar.AbsolutePosition.X) / sliderBar.AbsoluteSize.X, 0, 1)
					local value = relativeX * (Max - Min) + Min
					updateSlider(value)
				end

				local dragging = false

				Click_1.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						move(input)
					end
				end)

				Click_1.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = false
					end
				end)

				game:GetService("UserInputService").InputChanged:Connect(function(input)
					if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
						move(input)
					end
				end)

				local NewValue = {}

				function NewValue:SetValue(a)
					Value = a
					updateSlider(Value)
				end

				function NewValue:SetVisible(a)
					Slider.Visible = a
				end

				function NewValue:SetTitle(b)
					Title_1.Text = b
				end

				return NewValue
			end
			function Fetching.Main:CreateKeybind(info)
				local Title = info.Title
				local Key = info.Key or Enum.KeyCode.Q
				local Value = info.Value or false
				local Callback = info.Callback or function() end

				local Keybind = Instance.new("Frame")
				local Inside_1 = Instance.new("Frame")
				local UIPadding_1 = Instance.new("UIPadding")
				local Title_1 = Instance.new("TextLabel")
				local bind_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local Value_1 = Instance.new("TextLabel")
				local UICorner_2 = Instance.new("UICorner")
				local Click_1 = Instance.new("TextButton")

				Keybind.Name = "Keybind"
				Keybind.Parent = Section_1
				Keybind.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Keybind.BackgroundTransparency = 1
				Keybind.BorderColor3 = Color3.fromRGB(0,0,0)
				Keybind.BorderSizePixel = 0
				Keybind.LayoutOrder = 2
				Keybind.Size = UDim2.new(1, 0,0, 30)

				Inside_1.Name = "Inside"
				Inside_1.Parent = Keybind
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inside_1.BorderSizePixel = 0
				Inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inside_1.Size = UDim2.new(0.95, 0,0, 30)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = Inside_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(56,56,56)



				UIPadding_1.Parent = Inside_1
				UIPadding_1.PaddingLeft = UDim.new(0,8)
				UIPadding_1.PaddingRight = UDim.new(0,5)

				Title_1.Name = "Title"
				Title_1.Parent = Inside_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(0.800000012, 0,1, 0)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 10
				Title_1.TextXAlignment = Enum.TextXAlignment.Left
				Title_1.TextTransparency = 0.5

				bind_1.Name = "bind"
				bind_1.Parent = Inside_1
				bind_1.AnchorPoint = Vector2.new(1, 0.5)
				bind_1.BackgroundColor3 = Color3.fromRGB(17,17,17)
				bind_1.BorderColor3 = Color3.fromRGB(0,0,0)
				bind_1.BorderSizePixel = 0
				bind_1.LayoutOrder = 1
				bind_1.Size = UDim2.new(0, 20,0, 20)
				bind_1.Position = UDim2.new(1, 0, 0.5, 0)

				UICorner_1.Parent = bind_1
				UICorner_1.CornerRadius = UDim.new(0,4)

				Value_1.Name = "Value"
				Value_1.Parent = bind_1
				Value_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Value_1.BackgroundTransparency = 1
				Value_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Value_1.BorderSizePixel = 0
				Value_1.Size = UDim2.new(1, 0,1, 0)
				Value_1.Font = Enum.Font.GothamBold
				Value_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
				Value_1.TextColor3 = Color3.fromRGB(255,255,255)
				Value_1.TextSize = 10

				UICorner_2.Parent = Inside_1
				UICorner_2.CornerRadius = UDim.new(0,5)

				Click_1.Name = "Click"
				Click_1.Parent = Keybind
				Click_1.Active = true
				Click_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Click_1.BackgroundTransparency = 1
				Click_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Click_1.BorderSizePixel = 0
				Click_1.Size = UDim2.new(1, 0,1, 0)
				Click_1.Font = Enum.Font.SourceSans
				Click_1.Text = ""
				Click_1.TextSize = 14

				local function adjustBoxBindSize()
					local textSize = game:GetService("TextService"):GetTextSize(Value_1.Text, Value_1.TextSize, Value_1.Font, Vector2.new(1000, 1000))
					bind_1.Size = UDim2.new(0, textSize.X + 10, 0, 20)
				end

				adjustBoxBindSize()

				local function changeKey()
					Value_1.Text = "..."
					local inputConnection
					tw({
						v = Title_1,
						t = 0.15,
						s = "Linear",
						d = "Out",
						g = {TextTransparency = 0}
					}):Play()

					inputConnection = game:GetService("UserInputService").InputBegan:Connect(function(input)
						if input.UserInputType == Enum.UserInputType.Keyboard then
							Key = input.KeyCode
							Value_1.Text = tostring(Key):gsub("Enum.KeyCode.", "")
							adjustBoxBindSize()
							inputConnection:Disconnect()
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0.5}
							}):Play()
							Callback(Key, Value)
						end
					end)
				end

				game:GetService("UserInputService").InputEnded:Connect(function(input, gameProcessed)
					if input.KeyCode == Key then
						Value = not Value
						if Value then
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0}
							}):Play()
						else
							tw({
								v = Title_1,
								t = 0.15,
								s = "Linear",
								d = "Out",
								g = {TextTransparency = 0.5}
							}):Play()
						end
						Callback(Key, Value)
					end
				end)

				delay(0, function()
					Callback(Key, Value)
				end)

				Click_1.MouseButton1Click:Connect(function()
					changeKey()
				end)
			end
			function Fetching.Main:CreateSelect(info)
				local Title = info.Title
				local Desc = info.Desc
				local Value = info.Value
				local Callback = info.Callback or function() end
				local List = info.List

				local SelectMode = Instance.new("Frame")
				local inside_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local TextHub_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Title_1 = Instance.new("TextLabel")
				local ListFunc_1 = Instance.new("Frame")
				local ValueBox_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local UIPageLayout_1 = Instance.new("UIPageLayout")
				local UIListLayout_2 = Instance.new("UIListLayout")
				local Right_1 = Instance.new("ImageButton")
				local Left_1 = Instance.new("ImageButton")

				SelectMode.Name = "SelectMode"
				SelectMode.Parent = Section_1
				SelectMode.BackgroundColor3 = Color3.fromRGB(255,255,255)
				SelectMode.BackgroundTransparency = 1
				SelectMode.BorderColor3 = Color3.fromRGB(0,0,0)
				SelectMode.BorderSizePixel = 0
				SelectMode.LayoutOrder = 2
				SelectMode.Size = UDim2.new(1, 0,0, 35)

				inside_1.Name = "inside"
				inside_1.Parent = SelectMode
				inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				inside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				inside_1.BorderSizePixel = 0
				inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				inside_1.Size = UDim2.new(0.95, 0,1, 0)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = inside_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(56,56,56)

				UICorner_1.Parent = inside_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				TextHub_1.Name = "TextHub"
				TextHub_1.Parent = inside_1
				TextHub_1.AnchorPoint = Vector2.new(0, 0.5)
				TextHub_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextHub_1.BackgroundTransparency = 1
				TextHub_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextHub_1.BorderSizePixel = 0
				TextHub_1.Position = UDim2.new(0.0299999993, 0,0.5, 0)
				TextHub_1.Size = UDim2.new(1, 0,0.800000012, 0)

				UIListLayout_1.Parent = TextHub_1
				UIListLayout_1.Padding = UDim.new(0,2)
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center


				Title_1.Name = "Title"
				Title_1.Parent = TextHub_1
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.248750001, 0,0.0644999966, 0)
				Title_1.Size = UDim2.new(0, 90,0, 11)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 11
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				ListFunc_1.Name = "ListFunc"
				ListFunc_1.Parent = inside_1
				ListFunc_1.AnchorPoint = Vector2.new(1, 0.5)
				ListFunc_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ListFunc_1.BackgroundTransparency = 1
				ListFunc_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ListFunc_1.BorderSizePixel = 0
				ListFunc_1.Position = UDim2.new(0.980000019, 0,0.5, 0)
				ListFunc_1.Size = UDim2.new(0, 20,0, 20)

				ValueBox_1.Name = "ValueBox"
				ValueBox_1.Parent = ListFunc_1
				ValueBox_1.AnchorPoint = Vector2.new(1, 0.5)
				ValueBox_1.BackgroundColor3 = Color3.fromRGB(17,17,17)
				ValueBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
				ValueBox_1.BorderSizePixel = 0
				ValueBox_1.Position = UDim2.new(0.959999979, 0,0.5, 0)
				ValueBox_1.Size = UDim2.new(0, 60,0, 20)
				ValueBox_1.ClipsDescendants = true

				UICorner_2.Parent = ValueBox_1
				UICorner_2.CornerRadius = UDim.new(0,5)

				UIPageLayout_1.Parent = ValueBox_1
				UIPageLayout_1.EasingStyle = Enum.EasingStyle.Exponential
				UIPageLayout_1.TweenTime = 0.5
				UIPageLayout_1.HorizontalAlignment = Enum.HorizontalAlignment.Center
				UIPageLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center
				UIPageLayout_1.ScrollWheelInputEnabled = false

				UIListLayout_2.Parent = ListFunc_1
				UIListLayout_2.FillDirection = Enum.FillDirection.Horizontal
				UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Right
				UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Center

				Right_1.Name = "Right"
				Right_1.Parent = ListFunc_1
				Right_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Right_1.BackgroundTransparency = 1
				Right_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Right_1.BorderSizePixel = 0
				Right_1.LayoutOrder = -1
				Right_1.Size = UDim2.new(0, 20,0, 20)
				Right_1.Image = "rbxassetid://14916981327"

				Left_1.Name = "Left"
				Left_1.Parent = ListFunc_1
				Left_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Left_1.BackgroundTransparency = 1
				Left_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Left_1.BorderSizePixel = 0
				Left_1.LayoutOrder = 1
				Left_1.Size = UDim2.new(0, 20,0, 20)
				Left_1.Image = "rbxassetid://14929077622"

				local g = {}

				function g:addlist(item)
					local Value_1 = Instance.new("TextLabel")
					Value_1.Name = "Value"
					Value_1.Parent = ValueBox_1
					Value_1.BackgroundTransparency = 1
					Value_1.Size = UDim2.new(0.9, 0, 1, 0)
					Value_1.Font = Enum.Font.GothamBold
					Value_1.Text = item
					Value_1.TextColor3 = Color3.fromRGB(255,255,255)
					Value_1.TextSize = 9
				end

				for _, item in ipairs(List) do
					g:addlist(item)
				end

				Right_1.MouseButton1Click:Connect(function()
					UIPageLayout_1:Previous()
					Callback(UIPageLayout_1.CurrentPage.Text)
					tw({
						v = ValueBox_1,
						t = 0.15,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new(0, UIPageLayout_1.CurrentPage.TextBounds.X + 10,0, 20)}
					}):Play()
				end)

				Left_1.MouseButton1Click:Connect(function()
					UIPageLayout_1:Next()
					Callback(UIPageLayout_1.CurrentPage.Text)
					tw({
						v = ValueBox_1,
						t = 0.15,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new(0, UIPageLayout_1.CurrentPage.TextBounds.X + 10,0, 20)}
					}):Play()
				end)

				delay(0,function()
					for i, v in pairs(ValueBox_1:GetChildren()) do
						if v:IsA("TextLabel") and v.Text == Value then
							UIPageLayout_1:JumpTo(v)
						end
					end
					tw({
						v = ValueBox_1,
						t = 0.15,
						s = "Exponential",
						d = "Out",
						g = {Size = UDim2.new(0, UIPageLayout_1.CurrentPage.TextBounds.X + 10,0, 20)}
					}):Play()
					Callback(UIPageLayout_1.CurrentPage.Text)
				end)

				return g
			end
			function Fetching.Main:CreateTextbox(info)

				local Title = info.Title
				local Placeholder = info.Placeholder
				local Value = info.Value
				local Callback = info.Callback or function() end
				local ClearText = info.ClearText or false

				local TextBox = Instance.new("Frame")
				local Textboxinside_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local TextHub_1 = Instance.new("Frame")
				local UIListLayout_1 = Instance.new("UIListLayout")
				local Title_1 = Instance.new("TextLabel")
				local TextBoxBar_1 = Instance.new("Frame")
				local UICorner_2 = Instance.new("UICorner")
				local TextBoxValue_1 = Instance.new("TextBox")

				TextBox.Name = "TextBox"
				TextBox.Parent = Section_1
				TextBox.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBox.BackgroundTransparency = 1
				TextBox.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBox.BorderSizePixel = 0
				TextBox.LayoutOrder = 2
				TextBox.Size = UDim2.new(1, 0,0, 35)

				Textboxinside_1.Name = "Textboxinside"
				Textboxinside_1.Parent = TextBox
				Textboxinside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Textboxinside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Textboxinside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Textboxinside_1.BorderSizePixel = 0
				Textboxinside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Textboxinside_1.Size = UDim2.new(0.95, 0,1, 0)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = Textboxinside_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(56,56,56)

				UICorner_1.Parent = Textboxinside_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				TextHub_1.Name = "TextHub"
				TextHub_1.Parent = Textboxinside_1
				TextHub_1.AnchorPoint = Vector2.new(0, 0.5)
				TextHub_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextHub_1.BackgroundTransparency = 1
				TextHub_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextHub_1.BorderSizePixel = 0
				TextHub_1.Position = UDim2.new(0.0299999993, 0,0.5, 0)
				TextHub_1.Size = UDim2.new(1, 0,0.800000012, 0)

				UIListLayout_1.Parent = TextHub_1
				UIListLayout_1.Padding = UDim.new(0,2)
				UIListLayout_1.SortOrder = Enum.SortOrder.LayoutOrder
				UIListLayout_1.VerticalAlignment = Enum.VerticalAlignment.Center

				Title_1.Name = "Title"
				Title_1.Parent = TextHub_1
				Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Position = UDim2.new(0.248750001, 0,0.0644999966, 0)
				Title_1.Size = UDim2.new(0, 90,0, 11)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = tostring(Title)
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 11
				Title_1.TextXAlignment = Enum.TextXAlignment.Left

				TextBoxBar_1.Name = "TextBoxBar"
				TextBoxBar_1.Parent = Textboxinside_1
				TextBoxBar_1.AnchorPoint = Vector2.new(1, 0.5)
				TextBoxBar_1.BackgroundColor3 = Color3.fromRGB(17,17,17)
				TextBoxBar_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBoxBar_1.BorderSizePixel = 0
				TextBoxBar_1.Position = UDim2.new(0.959999979, 0,0.5, 0)
				TextBoxBar_1.Size = UDim2.new(0, 80,0, 20)
				TextBoxBar_1.ClipsDescendants = true

				UICorner_2.Parent = TextBoxBar_1
				UICorner_2.CornerRadius = UDim.new(0,4)

				TextBoxValue_1.Name = "TextBoxValue"
				TextBoxValue_1.Parent = TextBoxBar_1
				TextBoxValue_1.Active = true
				TextBoxValue_1.AnchorPoint = Vector2.new(0.5, 0.5)
				TextBoxValue_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				TextBoxValue_1.BackgroundTransparency = 1
				TextBoxValue_1.BorderColor3 = Color3.fromRGB(0,0,0)
				TextBoxValue_1.BorderSizePixel = 0
				TextBoxValue_1.Position = UDim2.new(0.5, 0,0.5, 0)
				TextBoxValue_1.Size = UDim2.new(0.899999976, 0,1, 0)
				TextBoxValue_1.Font = Enum.Font.Gotham
				TextBoxValue_1.PlaceholderColor3 = Color3.fromRGB(145,145,145)
				TextBoxValue_1.PlaceholderText = tostring(Placeholder)
				TextBoxValue_1.Text = tostring(Value)
				TextBoxValue_1.TextColor3 = Color3.fromRGB(255,255,255)
				TextBoxValue_1.TextSize = 9
				TextBoxValue_1.ClearTextOnFocus = ClearText

				TextBoxValue_1:GetPropertyChangedSignal("Text"):Connect(function()
					local textLength = math.clamp(TextBoxValue_1.TextBounds.X + 5, 30, 80)
					TextBoxBar_1.Size = UDim2.new(0, textLength, 0, 20)
				end)

				TextBoxValue_1.FocusLost:Connect(function()
					if #TextBoxValue_1.Text > 0 then
						pcall(Callback, TextBoxValue_1.Text)
					end
				end)

				delay(0, function()
					local textLength = math.clamp(TextBoxValue_1.TextBounds.X + 5, 30, 80)
					TextBoxBar_1.Size = UDim2.new(0, textLength, 0, 20)
				end)

				local NewValue = {}

				function NewValue:SetValue(a)
					Value = a
					TextBoxValue_1.Text = a
				end

				function NewValue:SetVisible(a)
					TextBox.Visible = a
				end

				function NewValue:SetTitle(b)
					Title_1.Text = b
				end

				return NewValue
			end
			function Fetching.Main:Icon(info)
				local Title = info.Title
				local Image = info.Image
				local Color = info.Color or Color3.fromRGB(255,255,255)

				local Keybind = Instance.new("Frame")
				local Inside_1 = Instance.new("Frame")
				local UIPadding_1 = Instance.new("UIPadding")
				local Title_1 = Instance.new("TextLabel")
				local im = Instance.new("ImageLabel")
				local UICorner_1 = Instance.new("UICorner")

				Keybind.Name = "Icon"
				Keybind.Parent = Section_1
				Keybind.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Keybind.BackgroundTransparency = 1
				Keybind.BorderColor3 = Color3.fromRGB(0,0,0)
				Keybind.BorderSizePixel = 0
				Keybind.LayoutOrder = 2
				Keybind.Size = UDim2.new(1, 0,0, 30)

				Inside_1.Name = "Inside"
				Inside_1.Parent = Keybind
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inside_1.BorderSizePixel = 0
				Inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inside_1.Size = UDim2.new(0.95, 0,0, 30)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = Inside_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(79,79,79)

				UIPadding_1.Parent = Inside_1
				UIPadding_1.PaddingLeft = UDim.new(0,8)
				UIPadding_1.PaddingRight = UDim.new(0,5)

				Title_1.Name = "Title"
				Title_1.Parent = Inside_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.AnchorPoint = Vector2.new(0.5,0.5)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(0.8, 0,1, 0)
				Title_1.Position = UDim2.new(0.53, 0,0.5, 0)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 10
				Title_1.TextXAlignment = Enum.TextXAlignment.Left
				Title_1.TextTransparency = 0
				Title_1.RichText = true

				im.Name = "@Ima"
				im.Parent = Inside_1
				im.AnchorPoint = Vector2.new(0.5, 0.5)
				im.BorderColor3 = Color3.fromRGB(0,0,0)
				im.BackgroundTransparency = 1
				im.Image = GetIcon(Image)
				im.BorderSizePixel = 0
				im.LayoutOrder = 1
				im.Size = UDim2.new(0, 17,0, 17)
				im.Position = UDim2.new(0.05, 0,0.5, 0)
				im.ImageColor3 = Color

				UICorner_1.Parent = Inside_1
				UICorner_1.CornerRadius = UDim.new(0,5)

				local NewValue = {}

				function NewValue:SetImage(a)
					im.Image = GetIcon(a)
				end

				function NewValue:ImageColor(a)
					im.ImageColor3 = a
				end

				function NewValue:SetVisible(a)
					Keybind.Visible = a
				end

				function NewValue:SetTitle(b)
					Title_1.Text = b
				end

				return NewValue
			end
			function Fetching.Main:CreateSpawn(info)
				local Title = info.Title
				local Color = info.Color

				local Keybind = Instance.new("Frame")
				local Inside_1 = Instance.new("Frame")
				local UIPadding_1 = Instance.new("UIPadding")
				local Title_1 = Instance.new("TextLabel")
				local bind_1 = Instance.new("Frame")
				local UICorner_1 = Instance.new("UICorner")
				local UICorner_2 = Instance.new("UICorner")

				Keybind.Name = "Keybind"
				Keybind.Parent = Section_1
				Keybind.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Keybind.BackgroundTransparency = 1
				Keybind.BorderColor3 = Color3.fromRGB(0,0,0)
				Keybind.BorderSizePixel = 0
				Keybind.LayoutOrder = 2
				Keybind.Size = UDim2.new(1, 0,0, 30)

				Inside_1.Name = "Inside"
				Inside_1.Parent = Keybind
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inside_1.BorderSizePixel = 0
				Inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inside_1.Size = UDim2.new(0.95, 0,0, 30)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = Inside_1
				Stroke.Thickness = 1
				Stroke.Color = Color

				UIPadding_1.Parent = Inside_1
				UIPadding_1.PaddingLeft = UDim.new(0,8)
				UIPadding_1.PaddingRight = UDim.new(0,5)

				Title_1.Name = "Title"
				Title_1.Parent = Inside_1
				Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1.AnchorPoint = Vector2.new(0.5,0.5)
				Title_1.BackgroundTransparency = 1
				Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1.BorderSizePixel = 0
				Title_1.Size = UDim2.new(0.8, 0,1, 0)
				Title_1.Position = UDim2.new(0.53, 0,0.5, 0)
				Title_1.Font = Enum.Font.GothamBold
				Title_1.Text = Title
				Title_1.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1.TextSize = 10
				Title_1.TextXAlignment = Enum.TextXAlignment.Left
				Title_1.TextTransparency = 0

				bind_1.Name = "bind"
				bind_1.Parent = Inside_1
				bind_1.AnchorPoint = Vector2.new(0.5, 0.5)
				bind_1.BackgroundColor3 = Color
				bind_1.BorderColor3 = Color3.fromRGB(0,0,0)
				bind_1.BorderSizePixel = 0
				bind_1.LayoutOrder = 1
				bind_1.Size = UDim2.new(0, 15,0, 10)
				bind_1.Position = UDim2.new(0.05, 0,0.5, 0)

				UICorner_1.Parent = bind_1
				UICorner_1.CornerRadius = UDim.new(1,0)

				UICorner_2.Parent = Inside_1
				UICorner_2.CornerRadius = UDim.new(0,5)

				local NewValue = {}

				function NewValue:SetColor(a)
					bind_1.BackgroundColor3 = a
					Stroke.Color = a
				end

				function NewValue:SetTransparency(a)
					Title_1.TextTransparency = a
				end

				function NewValue:SetVisible(a)
					Keybind.Visible = a
				end

				function NewValue:SetTitle(b)
					Title_1.Text = b
				end

				return NewValue
			end
			function Fetching.Main:Paragarp(info)
				local Title = info.Title

				local Keybind = Instance.new("Frame")
				local Inside_1 = Instance.new("Frame")
				local UIPadding_1 = Instance.new("UIPadding")
				local Title_1z = Instance.new("TextLabel")
				local UICorner_2 = Instance.new("UICorner")

				Keybind.Name = "Keybind"
				Keybind.Parent = Section_1
				Keybind.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Keybind.BackgroundTransparency = 1
				Keybind.BorderColor3 = Color3.fromRGB(0,0,0)
				Keybind.BorderSizePixel = 0
				Keybind.LayoutOrder = 2
				Keybind.Size = UDim2.new(1, 0,0, 30)

				Inside_1.Name = "Inside"
				Inside_1.Parent = Keybind
				Inside_1.AnchorPoint = Vector2.new(0.5, 0.5)
				Inside_1.BackgroundColor3 = Color3.fromRGB(27,27,27)
				Inside_1.BorderColor3 = Color3.fromRGB(0,0,0)
				Inside_1.BorderSizePixel = 0
				Inside_1.Position = UDim2.new(0.5, 0,0.5, 0)
				Inside_1.Size = UDim2.new(0.95, 0,0, 30)

				local Stroke = Instance.new("UIStroke")
				Stroke.Parent = Inside_1
				Stroke.Thickness = 1
				Stroke.Color = Color3.fromRGB(79,79,79)

				UIPadding_1.Parent = Inside_1
				UIPadding_1.PaddingLeft = UDim.new(0,8)
				UIPadding_1.PaddingRight = UDim.new(0,5)

				Title_1z.Name = "Title"
				Title_1z.Parent = Inside_1
				Title_1z.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Title_1z.AnchorPoint = Vector2.new(0.5,0.5)
				Title_1z.BackgroundTransparency = 1
				Title_1z.BorderColor3 = Color3.fromRGB(0,0,0)
				Title_1z.BorderSizePixel = 0
				Title_1z.Size = UDim2.new(0.8, 0,1, 0)
				Title_1z.Position = UDim2.new(0.4, 0,0.5, 0)
				Title_1z.Font = Enum.Font.GothamBold
				Title_1z.Text = Title
				Title_1z.TextColor3 = Color3.fromRGB(255,255,255)
				Title_1z.TextSize = 10
				Title_1z.TextXAlignment = Enum.TextXAlignment.Left
				Title_1z.TextTransparency = 0
				Title_1z.RichText = true

				UICorner_2.Parent = Inside_1
				UICorner_2.CornerRadius = UDim.new(0,5)

				local NewValue = {}

				function NewValue:SetVisible(a)
					Keybind.Visible = a
				end

				function NewValue:Set(b)
					Title_1z.Text = b
				end

				return NewValue
			end
			function Fetching.Main:Notfound(info)
				local Title = info.Title

				local Keybind = Instance.new("Frame")
				local Sad = Instance.new("ImageLabel")
				local ItTitle = Instance.new("TextLabel")

				Keybind.Name = "Keybind"
				Keybind.Parent = Section_1
				Keybind.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Keybind.BackgroundTransparency = 1
				Keybind.BorderColor3 = Color3.fromRGB(0,0,0)
				Keybind.BorderSizePixel = 0
				Keybind.LayoutOrder = 2
				Keybind.Size = UDim2.new(1, 0,0, 150)

				Sad.Parent = Keybind
				Sad.AnchorPoint = Vector2.new(0.5, 0.5)
				Sad.BackgroundColor3 = Color3.fromRGB(255,255,255)
				Sad.BackgroundTransparency = 1
				Sad.BorderColor3 = Color3.fromRGB(0,0,0)
				Sad.BorderSizePixel = 0
				Sad.Position = UDim2.new(0.5, 0,0.35, 0)
				Sad.Size = UDim2.new(0, 70,0, 70)
				Sad.Image = GetIcon(71289337214740)
				Sad.ImageTransparency = 0.5

				ItTitle.Name = "Title"
				ItTitle.Parent = Keybind
				ItTitle.BackgroundColor3 = Color3.fromRGB(255,255,255)
				ItTitle.AnchorPoint = Vector2.new(0.5,0.5)
				ItTitle.BackgroundTransparency = 1
				ItTitle.BorderColor3 = Color3.fromRGB(0,0,0)
				ItTitle.BorderSizePixel = 0
				ItTitle.Size = UDim2.new(0.8, 0,1, 0)
				ItTitle.Position = UDim2.new(0.5, 0,0.75, 0)
				ItTitle.Font = Enum.Font.GothamBold
				ItTitle.Text = Title
				ItTitle.TextColor3 = Color3.fromRGB(255,255,255)
				ItTitle.TextSize = 20
				ItTitle.TextXAlignment = Enum.TextXAlignment.Center
				ItTitle.TextTransparency = 0.5

				local NewValue = {}

				function NewValue:SetVisible(a)
					Keybind.Visible = a
				end

				function NewValue:SetTitle(b)
					ItTitle.Text = b
				end

				return NewValue
			end
			return Fetching.Main
		end
		return Fetching.Section
	end
	return Fetching.Tab
end
return Fetching
