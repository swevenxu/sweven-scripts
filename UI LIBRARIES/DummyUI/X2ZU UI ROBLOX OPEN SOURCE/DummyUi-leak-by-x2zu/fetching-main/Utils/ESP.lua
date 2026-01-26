round = function(n)
	return math.floor(tonumber(n) + 0.5)
end
return function(meta)
	local v = meta.Instance
	local title = meta.Name or v.Name
	local MainColor = meta.Color or Color3.fromRGB(255, 255, 255)
	local DropColor = meta.Drop or Color3.fromRGB(127, 127, 127)
	if not v:FindFirstChild('Constant') then
		local bill = Instance.new('BillboardGui',v)
		bill.Name = 'Constant'
		bill.Size = UDim2.fromOffset(100, 100)
		bill.MaxDistance = math.huge
		bill.Adornee = v
		bill.AlwaysOnTop = true

		local circle = Instance.new("Frame", bill)
		circle.Position = UDim2.fromScale(0.5, 0.5)
		circle.AnchorPoint = Vector2.new(0.5, 0.5)
		circle.Size = UDim2.fromOffset(6, 6)
		circle.BackgroundColor3 = Color3.fromRGB(255,255,255)

		local gradient = Instance.new("UIGradient", circle)
		gradient.Rotation = 90
		gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)})

		local stroke = Instance.new("UIStroke", circle)
		stroke.Thickness = 0.5

		local name = Instance.new('TextLabel',bill)
		name.Font = Enum.Font.GothamBold
		name.AnchorPoint = Vector2.new(0, 0.5)
		name.Size = UDim2.fromScale(1, 0.3)
		name.TextScaled = true
		name.BackgroundTransparency = 1
		name.TextStrokeTransparency = 0
		name.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		name.Position = UDim2.new(0, 0, 0.5, 24)
		name.TextColor3 = Color3.fromRGB(255, 255, 255)
		name.Text = "nil"

		local gradient = Instance.new("UIGradient", name)
		gradient.Rotation = 0
		gradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, MainColor), ColorSequenceKeypoint.new(1, DropColor)})
	else
		local dist = 0
		if v:IsA("Model") then
			dist = (game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.Position - v:GetPivot().Position).Magnitude
		elseif v:IsA("BasePart") then
			dist = (game:GetService('Players').LocalPlayer.Character.HumanoidRootPart.Position - v.Position).Magnitude
		end
		v:FindFirstChild('Constant'):FindFirstChild("TextLabel").Text = title .. '\n[ ' .. round(dist / 3) .. ' ]'
	end
end
