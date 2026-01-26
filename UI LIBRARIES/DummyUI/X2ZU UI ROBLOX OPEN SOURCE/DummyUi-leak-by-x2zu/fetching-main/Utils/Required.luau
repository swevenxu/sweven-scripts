export type Key = {
	Open: (self: Key, params: { key: string, callback: (() -> ())? }) -> ();
};

export type KeyParams = {
	key: string?;
	link: string?;
	callback: (() -> ())?;
}

local Key = {};
Key.__index = Key;

local TweenService: TweenService = game:GetService("TweenService");
local UserInputService: UserInputService = game:GetService("UserInputService");

function tw(info)
	return TweenService:Create(info.v, TweenInfo.new(info.t, info.s, info.d), info.g)
end;

function lak(a)
	local Dragging = nil
	local DragInput = nil
	local DragStart = nil
	local StartPosition = nil

	local function Update(input)
		local Delta = input.Position - DragStart
		local pos = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + Delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y)
		local Tween = TweenService:Create(a, TweenInfo.new(0.3), {Position = pos})
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

	UserInputService.InputChanged:Connect(function(input)
		if input == DragInput and Dragging then
			Update(input)
		end
	end)
end;

function click(p)
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
end;

function EffectUtils(c, p)
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

	local expandTween = TweenService:Create(ClickButtonCircle, tweenInfo, goal)

	expandTween.Completed:Connect(function()
		ClickButtonCircle:Destroy()
	end)

	expandTween:Play()
end;

function Key:Open(params: table)
	local key: string = params.key or "9sixt";
	local callback: func = params.callback or function()end;
	local link: string = params.link or "pornhub.org";
	local limit = params.limit_rate or 9e9

	local Keyz = Instance.new("ScreenGui")
	local Background_1 = Instance.new("Frame")
	local DropShadow_1 = Instance.new("ImageLabel")
	local GridLine_1 = Instance.new("ImageLabel")
	local UIGradient_1 = Instance.new("UIGradient")
	local UICorner_1 = Instance.new("UICorner")
	local UIGradient_2 = Instance.new("UIGradient")
	local Effect_1 = Instance.new("Frame")
	local Orb1_1 = Instance.new("ImageLabel")
	local UIGradient_3 = Instance.new("UIGradient")
	local Orb1_2 = Instance.new("ImageLabel")
	local UIGradient_4 = Instance.new("UIGradient")
	local Lowereffect_1 = Instance.new("ImageLabel")
	local UIGradient_5 = Instance.new("UIGradient")
	local UICorner_2 = Instance.new("UICorner")
	local Logo_1 = Instance.new("ImageLabel")
	local UICorner_3 = Instance.new("UICorner")
	local UIGradient_6 = Instance.new("UIGradient")
	local GetKey_1 = Instance.new("Frame")
	local GetKeybutton_1 = Instance.new("Frame")
	local UICorner_4 = Instance.new("UICorner")
	local UIStroke_1 = Instance.new("UIStroke")
	local effecttype_1 = Instance.new("ImageLabel")
	local Lowereffect_2 = Instance.new("ImageLabel")
	local UIGradient_7 = Instance.new("UIGradient")
	local Icon_1 = Instance.new("Frame")
	local iconInside_1 = Instance.new("Frame")
	local UICorner_5 = Instance.new("UICorner")
	local RealIcon_1 = Instance.new("ImageLabel")
	local Text_1 = Instance.new("Frame")
	local Titlekey_1 = Instance.new("TextLabel")
	local UIGradient_8 = Instance.new("UIGradient")
	local Desc_1 = Instance.new("TextLabel")
	local Next_1 = Instance.new("Frame")
	local nexticon_1 = Instance.new("ImageLabel")
	local Box_1 = Instance.new("Frame")
	local Title_1 = Instance.new("Frame")
	local RealTitle_1 = Instance.new("TextLabel")
	local UIGradient_9 = Instance.new("UIGradient")
	local Line_1 = Instance.new("Frame")
	local RealDeac_1 = Instance.new("TextLabel")
	local Textb_1 = Instance.new("Frame")
	local Textbox_1 = Instance.new("Frame")
	local TextBox_1 = Instance.new("TextBox")
	local UICorner_6 = Instance.new("UICorner")
	local UIStroke_2 = Instance.new("UIStroke")
	local RealDeac_2 = Instance.new("TextLabel")
	local Submit_1 = Instance.new("Frame")
	local UICorner_7 = Instance.new("UICorner")
	local UIGradient_10 = Instance.new("UIGradient")
	local bt_1 = Instance.new("TextLabel")
	local DropShadow_2 = Instance.new("ImageLabel")
	local UIStroke_3 = Instance.new("UIStroke")
	local UIGradient_11 = Instance.new("UIGradient")

	Keyz.Name = "Key"
	Keyz.Parent = (syn and syn.gethui and gethui and pcall(gethui) and gethui()) or (not game:GetService("RunService"):IsStudio() and game:GetService("CoreGui")) or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
	Keyz.ZIndexBehavior = Enum.ZIndexBehavior.Global

	Background_1.Name = "Background"
	Background_1.Parent = Keyz
	Background_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Background_1.BackgroundColor3 = Color3.fromRGB(0,0,0)
	Background_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Background_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Background_1.Size = UDim2.new(0, 500,0, 375)
	pcall(lak, Background_1)

	DropShadow_1.Name = "DropShadow"
	DropShadow_1.Parent = Background_1
	DropShadow_1.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow_1.BackgroundColor3 = Color3.fromRGB(28,28,30)
	DropShadow_1.BackgroundTransparency = 1
	DropShadow_1.BorderColor3 = Color3.fromRGB(0,0,0)
	DropShadow_1.BorderSizePixel = 0
	DropShadow_1.Position = UDim2.new(0.5, 0,0.5, 0)
	DropShadow_1.Size = UDim2.new(1, 100,1, 100)
	DropShadow_1.ZIndex = 0
	DropShadow_1.Image = "rbxassetid://8992230677"
	DropShadow_1.ImageColor3 = Color3.fromRGB(85,170,255)
	DropShadow_1.ImageTransparency = 0.7099999785423279
	DropShadow_1.ScaleType = Enum.ScaleType.Slice
	DropShadow_1.SliceCenter = Rect.new(99, 99, 99, 99)

	GridLine_1.Name = "GridLine"
	GridLine_1.Parent = Background_1
	GridLine_1.AnchorPoint = Vector2.new(0.5, 0.5)
	GridLine_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	GridLine_1.BackgroundTransparency = 1
	GridLine_1.BorderColor3 = Color3.fromRGB(0,0,0)
	GridLine_1.BorderSizePixel = 0
	GridLine_1.Position = UDim2.new(0.5, 0,0.5, 0)
	GridLine_1.Size = UDim2.new(1, 0,1.00000012, 0)
	GridLine_1.Image = "rbxassetid://81636524121900"
	GridLine_1.ImageTransparency = 0.8500000238418579
	GridLine_1.ScaleType = Enum.ScaleType.Crop

	UIGradient_1.Parent = GridLine_1
	UIGradient_1.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
	UIGradient_1.Rotation = -97
	UIGradient_1.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0.225), NumberSequenceKeypoint.new(0.991272,1), NumberSequenceKeypoint.new(1,0)}

	UICorner_1.Parent = GridLine_1
	UICorner_1.CornerRadius = UDim.new(0,0)

	UIGradient_2.Parent = Background_1

	Effect_1.Name = "Effect"
	Effect_1.Parent = Background_1
	Effect_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Effect_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Effect_1.BackgroundTransparency = 1
	Effect_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Effect_1.BorderSizePixel = 0
	Effect_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Effect_1.Size = UDim2.new(1, 0,1, 0)
	Effect_1.ClipsDescendants = true

	Orb1_1.Name = "Orb1"
	Orb1_1.Parent = Effect_1
	Orb1_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Orb1_1.BackgroundTransparency = 1
	Orb1_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Orb1_1.BorderSizePixel = 0
	Orb1_1.Position = UDim2.new(0.230000004, 0,-0.49333334, 0)
	Orb1_1.Size = UDim2.new(0, 639,0, 651)
	Orb1_1.Image = "rbxassetid://110890831577968"
	Orb1_1.ImageTransparency = 0.2800000011920929
	Orb1_1.ScaleType = Enum.ScaleType.Crop

	UIGradient_3.Parent = Orb1_1
	UIGradient_3.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
	UIGradient_3.Rotation = -21
	UIGradient_3.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0.225), NumberSequenceKeypoint.new(0.991272,1), NumberSequenceKeypoint.new(1,0)}

	Orb1_2.Name = "Orb1"
	Orb1_2.Parent = Effect_1
	Orb1_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Orb1_2.BackgroundTransparency = 1
	Orb1_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Orb1_2.BorderSizePixel = 0
	Orb1_2.Position = UDim2.new(-0.381999999, 0,-0.378666669, 0)
	Orb1_2.Size = UDim2.new(0, 600,0, 600)
	Orb1_2.Image = "rbxassetid://110890831577968"
	Orb1_2.ImageTransparency = 0.3700000047683716
	Orb1_2.ScaleType = Enum.ScaleType.Crop

	UIGradient_4.Parent = Orb1_2
	UIGradient_4.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
	UIGradient_4.Rotation = -21
	UIGradient_4.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0.225), NumberSequenceKeypoint.new(0.991272,1), NumberSequenceKeypoint.new(1,0)}

	Lowereffect_1.Name = "Lowereffect"
	Lowereffect_1.Parent = Background_1
	Lowereffect_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Lowereffect_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Lowereffect_1.BackgroundTransparency = 1
	Lowereffect_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Lowereffect_1.BorderSizePixel = 0
	Lowereffect_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Lowereffect_1.Size = UDim2.new(1, 0,1.00000012, 0)
	Lowereffect_1.Image = "rbxassetid://90214029184922"
	Lowereffect_1.ScaleType = Enum.ScaleType.Crop

	UIGradient_5.Parent = Lowereffect_1
	UIGradient_5.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
	UIGradient_5.Rotation = -21
	UIGradient_5.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0.225), NumberSequenceKeypoint.new(0.991272,1), NumberSequenceKeypoint.new(1,0)}

	UICorner_2.Parent = Lowereffect_1
	UICorner_2.CornerRadius = UDim.new(0,0)

	Logo_1.Name = "Logo"
	Logo_1.Parent = Background_1
	Logo_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Logo_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Logo_1.BackgroundTransparency = 1
	Logo_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Logo_1.BorderSizePixel = 0
	Logo_1.Position = UDim2.new(0.5, 0,0.5, 0)
	Logo_1.Size = UDim2.new(1, 0,1, 0)
	Logo_1.Image = "rbxassetid://128185233852701"
	Logo_1.ImageTransparency = 0.800000011920929
	Logo_1.ScaleType = Enum.ScaleType.Crop

	UICorner_3.Parent = Logo_1
	UICorner_3.CornerRadius = UDim.new(0,0)

	UIGradient_6.Parent = Logo_1
	UIGradient_6.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
	UIGradient_6.Rotation = -97
	UIGradient_6.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0.7125), NumberSequenceKeypoint.new(0.992519,1), NumberSequenceKeypoint.new(1,0)}

	GetKey_1.Name = "GetKey"
	GetKey_1.Parent = Background_1
	GetKey_1.AnchorPoint = Vector2.new(0.5, 1)
	GetKey_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	GetKey_1.BackgroundTransparency = 1
	GetKey_1.BorderColor3 = Color3.fromRGB(0,0,0)
	GetKey_1.BorderSizePixel = 0
	GetKey_1.Position = UDim2.new(0.5, 0,0.970666647, 0)
	GetKey_1.Size = UDim2.new(0.949999988, 0,-0.0719999969, 110)

	GetKeybutton_1.Name = "GetKeybutton"
	GetKeybutton_1.Parent = GetKey_1
	GetKeybutton_1.AnchorPoint = Vector2.new(0.5, 0.5)
	GetKeybutton_1.BackgroundColor3 = Color3.fromRGB(111,185,255)
	GetKeybutton_1.BackgroundTransparency = 0.8500000238418579
	GetKeybutton_1.BorderColor3 = Color3.fromRGB(0,0,0)
	GetKeybutton_1.BorderSizePixel = 0
	GetKeybutton_1.Position = UDim2.new(0.5, 0,0.5, 0)
	GetKeybutton_1.Size = UDim2.new(1, 0,1, 0)
	GetKeybutton_1.ClipsDescendants = true

	UICorner_4.Parent = GetKeybutton_1
	UICorner_4.CornerRadius = UDim.new(0,7)

	UIStroke_1.Parent = GetKeybutton_1
	UIStroke_1.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_1.Color = Color3.fromRGB(85,170,255)
	UIStroke_1.Thickness = 1

	effecttype_1.Name = "effecttype"
	effecttype_1.Parent = GetKeybutton_1
	effecttype_1.AnchorPoint = Vector2.new(0.5, 0.5)
	effecttype_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	effecttype_1.BackgroundTransparency = 1
	effecttype_1.BorderColor3 = Color3.fromRGB(0,0,0)
	effecttype_1.BorderSizePixel = 0
	effecttype_1.Position = UDim2.new(0.269473672, 0,0.036144577, 0)
	effecttype_1.Size = UDim2.new(0, 593,0, 277)
	effecttype_1.Image = "rbxassetid://110890831577968"
	effecttype_1.ImageTransparency = 0.9200000166893005
	effecttype_1.ScaleType = Enum.ScaleType.Crop

	Lowereffect_2.Name = "Lowereffect"
	Lowereffect_2.Parent = GetKeybutton_1
	Lowereffect_2.AnchorPoint = Vector2.new(0.5, 0.5)
	Lowereffect_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Lowereffect_2.BackgroundTransparency = 1
	Lowereffect_2.BorderColor3 = Color3.fromRGB(0,0,0)
	Lowereffect_2.BorderSizePixel = 0
	Lowereffect_2.Position = UDim2.new(0.5, 0,0.0903615355, 0)
	Lowereffect_2.Size = UDim2.new(1, 0,1.81927729, 0)
	Lowereffect_2.Image = "rbxassetid://90214029184922"
	Lowereffect_2.ScaleType = Enum.ScaleType.Crop

	UIGradient_7.Parent = Lowereffect_2
	UIGradient_7.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 85, 255))}
	UIGradient_7.Rotation = -21
	UIGradient_7.Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0,0.225), NumberSequenceKeypoint.new(0.991272,1), NumberSequenceKeypoint.new(1,0)}

	Icon_1.Name = "Icon"
	Icon_1.Parent = GetKeybutton_1
	Icon_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Icon_1.BackgroundTransparency = 1
	Icon_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Icon_1.BorderSizePixel = 0
	Icon_1.Position = UDim2.new(0.0873684213, 0,0.5, 0)
	Icon_1.Size = UDim2.new(0.174736843, 0,1, 0)

	iconInside_1.Name = "iconInside"
	iconInside_1.Parent = Icon_1
	iconInside_1.AnchorPoint = Vector2.new(0.5, 0.5)
	iconInside_1.BackgroundColor3 = Color3.fromRGB(0,10,15)
	iconInside_1.BackgroundTransparency = 0.6000000238418579
	iconInside_1.BorderColor3 = Color3.fromRGB(0,0,0)
	iconInside_1.BorderSizePixel = 0
	iconInside_1.Position = UDim2.new(0.5, 0,0.5, 0)
	iconInside_1.Size = UDim2.new(0, 60,0, 60)

	UICorner_5.Parent = iconInside_1

	RealIcon_1.Name = "RealIcon"
	RealIcon_1.Parent = iconInside_1
	RealIcon_1.AnchorPoint = Vector2.new(0.5, 0.5)
	RealIcon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	RealIcon_1.BackgroundTransparency = 1
	RealIcon_1.BorderColor3 = Color3.fromRGB(0,0,0)
	RealIcon_1.BorderSizePixel = 0
	RealIcon_1.Position = UDim2.new(0.5, 0,0.5, 0)
	RealIcon_1.Size = UDim2.new(0, 35,0, 35)
	RealIcon_1.Image = "rbxassetid://108747755935986"
	RealIcon_1.ImageColor3 = Color3.fromRGB(85,170,255)
	RealIcon_1.ScaleType = Enum.ScaleType.Crop

	Text_1.Name = "Text"
	Text_1.Parent = GetKeybutton_1
	Text_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Text_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Text_1.BackgroundTransparency = 1
	Text_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Text_1.BorderSizePixel = 0
	Text_1.Position = UDim2.new(0.507894754, 0,0.5, 0)
	Text_1.Size = UDim2.new(0.653684199, 0,1, 0)

	Titlekey_1.Name = "Titlekey"
	Titlekey_1.Parent = Text_1
	Titlekey_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Titlekey_1.BackgroundTransparency = 1
	Titlekey_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Titlekey_1.BorderSizePixel = 0
	Titlekey_1.Position = UDim2.new(0, 0,0.210843369, 0)
	Titlekey_1.Size = UDim2.new(1, 0,-0.52409637, 50)
	Titlekey_1.Font = Enum.Font.GothamBold
	Titlekey_1.RichText = true
	Titlekey_1.Text = "Get Licence Key"
	Titlekey_1.TextColor3 = Color3.fromRGB(255,255,255)
	Titlekey_1.TextSize = 20
	Titlekey_1.TextXAlignment = Enum.TextXAlignment.Left

	UIGradient_8.Parent = Titlekey_1
	UIGradient_8.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 170, 255))}
	UIGradient_8.Offset = Vector2.new(0, 0.5)
	UIGradient_8.Rotation = 90

	Desc_1.Name = "Desc"
	Desc_1.Parent = Text_1
	Desc_1.BackgroundColor3 = Color3.fromRGB(181,213,255)
	Desc_1.BackgroundTransparency = 1
	Desc_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Desc_1.BorderSizePixel = 0
	Desc_1.Position = UDim2.new(0, 0,0.391566277, 0)
	Desc_1.Size = UDim2.new(1, 0,-0.132530123, 50)
	Desc_1.Font = Enum.Font.GothamSemibold
	Desc_1.RichText = true
	Desc_1.Text = "After copying the link, please open Chrome, paste the link, and complete 2 advertisement steps. Your licence will expire within 24 hours."
	Desc_1.TextColor3 = Color3.fromRGB(161,203,255)
	Desc_1.TextSize = 12
	Desc_1.TextTransparency = 0.25
	Desc_1.TextWrapped = true
	Desc_1.TextXAlignment = Enum.TextXAlignment.Left
	Desc_1.TextYAlignment = Enum.TextYAlignment.Top

	Next_1.Name = "Next"
	Next_1.Parent = GetKeybutton_1
	Next_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Next_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Next_1.BackgroundTransparency = 1
	Next_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Next_1.BorderSizePixel = 0
	Next_1.Position = UDim2.new(0.930000007, 0,0.5, 0)
	Next_1.Size = UDim2.new(0.174736843, 0,1, 0)

	nexticon_1.Name = "nexticon"
	nexticon_1.Parent = Next_1
	nexticon_1.AnchorPoint = Vector2.new(0.5, 0.5)
	nexticon_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	nexticon_1.BackgroundTransparency = 1
	nexticon_1.BorderColor3 = Color3.fromRGB(0,0,0)
	nexticon_1.BorderSizePixel = 0
	nexticon_1.Position = UDim2.new(0.5, 0,0.5, 0)
	nexticon_1.Size = UDim2.new(0, 38,0, 38)
	nexticon_1.Image = "rbxassetid://108028847031522"
	nexticon_1.ImageColor3 = Color3.fromRGB(121,192,255)

	Box_1.Name = "Box"
	Box_1.Parent = Background_1
	Box_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Box_1.BackgroundTransparency = 1
	Box_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Box_1.BorderSizePixel = 0
	Box_1.Position = UDim2.new(0.0250000004, 0,0.0293333326, 0)
	Box_1.Size = UDim2.new(0, 474,0, 261)

	Title_1.Name = "Title"
	Title_1.Parent = Box_1
	Title_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Title_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Title_1.BackgroundTransparency = 1
	Title_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Title_1.BorderSizePixel = 0
	Title_1.Position = UDim2.new(0.5, 0,0.200000003, 0)
	Title_1.Size = UDim2.new(1, 0,0, 100)

	RealTitle_1.Name = "RealTitle"
	RealTitle_1.Parent = Title_1
	RealTitle_1.AnchorPoint = Vector2.new(0.5, 0)
	RealTitle_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	RealTitle_1.BackgroundTransparency = 1
	RealTitle_1.BorderColor3 = Color3.fromRGB(0,0,0)
	RealTitle_1.BorderSizePixel = 0
	RealTitle_1.Position = UDim2.new(0.5, 0,0.100000001, 0)
	RealTitle_1.Size = UDim2.new(0.899999976, 0,0.0399999991, 30)
	RealTitle_1.Font = Enum.Font.GothamBold
	RealTitle_1.Text = "Fetching's Script"
	RealTitle_1.TextColor3 = Color3.fromRGB(255,255,255)
	RealTitle_1.TextSize = 40

	UIGradient_9.Parent = RealTitle_1
	UIGradient_9.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(85, 170, 255))}
	UIGradient_9.Offset = Vector2.new(0, 0.300000012)
	UIGradient_9.Rotation = 90

	Line_1.Name = "Line"
	Line_1.Parent = Title_1
	Line_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Line_1.BackgroundColor3 = Color3.fromRGB(85,170,255)
	Line_1.BackgroundTransparency = 0.30000001192092896
	Line_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Line_1.BorderSizePixel = 0
	Line_1.Position = UDim2.new(0.5, 0,0.829999983, 0)
	Line_1.Size = UDim2.new(0, 100,0, 3)

	RealDeac_1.Name = "RealDeac"
	RealDeac_1.Parent = Title_1
	RealDeac_1.AnchorPoint = Vector2.new(0.5, 0)
	RealDeac_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	RealDeac_1.BackgroundTransparency = 1
	RealDeac_1.BorderColor3 = Color3.fromRGB(0,0,0)
	RealDeac_1.BorderSizePixel = 0
	RealDeac_1.Position = UDim2.new(0.5, 0,0.529999971, 0)
	RealDeac_1.Size = UDim2.new(0.899999976, 0,-0.0449998267, 30)
	RealDeac_1.Font = Enum.Font.Unknown
	RealDeac_1.Text = "Official"
	RealDeac_1.TextColor3 = Color3.fromRGB(161,203,255)
	RealDeac_1.TextSize = 20

	Textb_1.Name = "Textb"
	Textb_1.Parent = Box_1
	Textb_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Textb_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Textb_1.BackgroundTransparency = 1
	Textb_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Textb_1.BorderSizePixel = 0
	Textb_1.Position = UDim2.new(0.5, 0,0.604674339, 0)
	Textb_1.Size = UDim2.new(0, 449,0, 192)

	Textbox_1.Name = "Textbox"
	Textbox_1.Parent = Textb_1
	Textbox_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Textbox_1.BackgroundColor3 = Color3.fromRGB(161,203,255)
	Textbox_1.BackgroundTransparency = 1
	Textbox_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Textbox_1.BorderSizePixel = 0
	Textbox_1.Position = UDim2.new(0.5, 0,0.495999992, 0)
	Textbox_1.Size = UDim2.new(0, 363,0, 41)

	TextBox_1.Parent = Textbox_1
	TextBox_1.Active = true
	TextBox_1.AnchorPoint = Vector2.new(0.5, 0.5)
	TextBox_1.BackgroundColor3 = Color3.fromRGB(161,203,255)
	TextBox_1.BackgroundTransparency = 0.8500000238418579
	TextBox_1.BorderColor3 = Color3.fromRGB(0,0,0)
	TextBox_1.BorderSizePixel = 0
	TextBox_1.Position = UDim2.new(0.5, 0,0.5, 0)
	TextBox_1.Size = UDim2.new(1, 0,1, 0)
	TextBox_1.Font = Enum.Font.GothamMedium
	TextBox_1.PlaceholderColor3 = Color3.fromRGB(178,178,178)
	TextBox_1.PlaceholderText = ""
	TextBox_1.Text = "Paste your licence here."
	TextBox_1.TextColor3 = Color3.fromRGB(161,203,255)
	TextBox_1.TextSize = 14

	local Button = click(GetKeybutton_1)

	Button.MouseButton1Click:Connect(function()
		pcall(setclipboard, link)
		EffectUtils(Button, GetKeybutton_1)
		tw({
			v = GetKeybutton_1,
			t = 0.15,
			s = Enum.EasingStyle.Bounce,
			d = Enum.EasingDirection.Out,
			g = {Size = UDim2.new(0.92, 0, 0.92, 0)}
		}):Play()

		delay(0.06, function()
			tw({
				v = GetKeybutton_1,
				t = 0.15,
				s = Enum.EasingStyle.Back,
				d = Enum.EasingDirection.Out,
				g = {Size = UDim2.new(1, 0, 1, 0)}
			}):Play()
		end)
	end)


	UICorner_6.Parent = TextBox_1

	UIStroke_2.Parent = TextBox_1
	UIStroke_2.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke_2.Color = Color3.fromRGB(85,170,255)
	UIStroke_2.Thickness = 1

	RealDeac_2.Name = "RealDeac"
	RealDeac_2.Parent = Textb_1
	RealDeac_2.AnchorPoint = Vector2.new(0.5, 0)
	RealDeac_2.BackgroundColor3 = Color3.fromRGB(255,255,255)
	RealDeac_2.BackgroundTransparency = 1
	RealDeac_2.BorderColor3 = Color3.fromRGB(0,0,0)
	RealDeac_2.BorderSizePixel = 0
	RealDeac_2.Position = UDim2.new(0.5, 0,0.197999999, 0)
	RealDeac_2.Size = UDim2.new(0.808463097, 0,-0.00999996997, 30)
	RealDeac_2.Font = Enum.Font.GothamMedium
	RealDeac_2.Text = "Hello, " .. tostring(game:GetService('Players').LocalPlayer.Name)
	RealDeac_2.TextColor3 = Color3.fromRGB(161,203,255)
	RealDeac_2.TextSize = 15

	Submit_1.Name = "Submit"
	Submit_1.Parent = Textb_1
	Submit_1.AnchorPoint = Vector2.new(0.5, 0.5)
	Submit_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	Submit_1.BorderColor3 = Color3.fromRGB(0,0,0)
	Submit_1.BorderSizePixel = 0
	Submit_1.Position = UDim2.new(0.5, 0,0.836000025, 0)
	Submit_1.Size = UDim2.new(0, 200,0, 43)

	UICorner_7.Parent = Submit_1
	UICorner_7.CornerRadius = UDim.new(1,0)

	UIGradient_10.Parent = Submit_1
	UIGradient_10.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(85, 170, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 91, 136))}
	UIGradient_10.Offset = Vector2.new(0, 0.300000012)
	UIGradient_10.Rotation = 90

	bt_1.Name = "bt"
	bt_1.Parent = Submit_1
	bt_1.AnchorPoint = Vector2.new(0.5, 0.5)
	bt_1.BackgroundColor3 = Color3.fromRGB(255,255,255)
	bt_1.BackgroundTransparency = 1
	bt_1.BorderColor3 = Color3.fromRGB(0,0,0)
	bt_1.BorderSizePixel = 0
	bt_1.Position = UDim2.new(0.5, 0,0.5, 0)
	bt_1.Size = UDim2.new(1, 0,1, 0)
	bt_1.Font = Enum.Font.GothamBold
	bt_1.Text = "Unlock"
	bt_1.TextColor3 = Color3.fromRGB(255,255,255)
	bt_1.TextSize = 18
	bt_1.ClipsDescendants = true

	local ButtonSub = click(bt_1)
	local Count = 0
	
	ButtonSub.MouseButton1Click:Connect(function()
		tw({
			v = Submit_1,
			t = 0.15,
			s = Enum.EasingStyle.Bounce,
			d = Enum.EasingDirection.Out,
			g = {Size = UDim2.new(0, 150,0, 30)}
		}):Play()
		delay(0.06, function()
			tw({
				v = Submit_1,
				t = 0.15,
				s = Enum.EasingStyle.Back,
				d = Enum.EasingDirection.Out,
				g = {Size = UDim2.new(0, 200,0, 43)}
			}):Play()
		end)
		if TextBox_1.Text == (key or tostring(key)) then
			pcall(callback)
			TextBox_1.Text = "Success"
			TextBox_1.TextColor3 = Color3.fromRGB(0, 255, 127)
			delay(1.5, function()
				Box_1:Destroy()
				GetKey_1:Destroy()
				tw({
					v = Logo_1,
					t = 2,
					s = Enum.EasingStyle.Back,
					d = Enum.EasingDirection.Out,
					g = {ImageTransparency = 0}
				}):Play()
				UIGradient_6.Transparency = NumberSequence.new(0.5)
				task.wait(0.3)
				tw({
					v = Logo_1,
					t = 1,
					s = Enum.EasingStyle.Bounce,
					d = Enum.EasingDirection.Out,
					g = {Size = UDim2.new(0.5, 0, 0.5, 0)}
				}):Play()
				task.wait(0.3)
				tw({
					v = Logo_1,
					t = .5,
					s = Enum.EasingStyle.Exponential,
					d = Enum.EasingDirection.Out,
					g = {Size = UDim2.new(1.05, 0, 1.05, 0)}
				}):Play()
				task.wait(.7)
				tw({
					v = Logo_1,
					t = 0.3,
					s = Enum.EasingStyle.Bounce,
					d = Enum.EasingDirection.Out,
					g = {ImageTransparency = 1}
				}):Play()
				tw({
					v = Background_1,
					t = 0.5,
					s = Enum.EasingStyle.Bounce,
					d = Enum.EasingDirection.Out,
					g = {Size = UDim2.new(0, 0, 0, 0)}
				}):Play()
				DropShadow_1:Destroy()
				task.wait(.5)
				Keyz:Destroy()
			end)
		else
			TextBox_1.Text = "Licence is Not Valid, Try Again."
			TextBox_1.TextColor3 = Color3.fromRGB(255, 64, 64)
			Count += 1
			if Count > limit then
				game.Players.LocalPlayer:Kick("Late Limit Time.")
				game:Shutdown()
			end
			delay(5, function()
				TextBox_1.TextColor3 = Color3.fromRGB(161,203,255)
				TextBox_1.Text = "Paste your licence here."
			end)
		end
	end)

	DropShadow_2.Name = "DropShadow"
	DropShadow_2.Parent = Submit_1
	DropShadow_2.AnchorPoint = Vector2.new(0.5, 0.5)
	DropShadow_2.BackgroundColor3 = Color3.fromRGB(28,28,30)
	DropShadow_2.BackgroundTransparency = 1
	DropShadow_2.BorderColor3 = Color3.fromRGB(0,0,0)
	DropShadow_2.BorderSizePixel = 0
	DropShadow_2.Position = UDim2.new(0.5, 0,0.5, 0)
	DropShadow_2.Size = UDim2.new(1, 80,1, 80)
	DropShadow_2.Image = "rbxassetid://8992230677"
	DropShadow_2.ImageColor3 = Color3.fromRGB(85,170,255)
	DropShadow_2.ImageTransparency = 0.7099999785423279
	DropShadow_2.ScaleType = Enum.ScaleType.Slice
	DropShadow_2.SliceCenter = Rect.new(99, 99, 99, 99)

	UIStroke_3.Parent = Background_1
	UIStroke_3.Color = Color3.fromRGB(18,18,18)
	UIStroke_3.LineJoinMode = Enum.LineJoinMode.Miter
	UIStroke_3.Thickness = 7
	UIStroke_3.Transparency = 0.5

	UIGradient_11.Parent = UIStroke_3
	UIGradient_11.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)), ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 0, 0))}
	UIGradient_11.Rotation = -107
end

return Key
