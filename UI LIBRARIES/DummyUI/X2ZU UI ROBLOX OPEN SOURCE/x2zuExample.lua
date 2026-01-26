
-- Discord Server x2zu best skid discord open source script everrrrrrrrrrrrrr : https://discord.gg/FmMuvkaWvG / discord.gg/x2zu Owner: @x2zu muhauhauhauhua


local x2zuLibrary = loadstring(game:HttpGet("paste ur url in here nigga don't be stupid"))()

local Window = x2zuLibrary:CreateWindow({Title = "x2zu"})

local Tab1 = Window:AddTab({Title = "General", Icon = "info"})
local Tab2 = Window:AddTab({Title = "Notification", Icon = "bell"})

local Options = x2zuLibrary.Options

-- Tab 1 --
do
	task.spawn(function()
		wait(.5)
		x2zuLibrary:Notify({
			Title = "Notification",
			Content = "This is a notification",
			Duration = 5 -- Set to nil to make the notification not disappear
		})
		wait(0.5)
		x2zuLibrary:Notify({
			Title = "Notification 2",
			Content = "This is a notification 2",
			SubContent = "btw i wont close, so click that X", -- Optional
			Duration = nil -- Set to nil to make the notification not disappear
		})
	end)
	-- ngentot jawa yatim jawa papale papale jawa

	-- print("Jawa jawa jawa")
	-- warn("awas ada jawa")
	
	local LeftSide = Tab1:AddSection({Title = "Left"})
	local RightSide = Tab1:AddSection({Title = "Right"})
	
	LeftSide:AddParagraph({
		Title = "lolnigga",
		Content = "A tool to help users to grind without getting bored of it.\n\nFully automated."
	})
	
	LeftSide:AddButton({
		Title = "Print 'HI'",
		Description = "Very important button", -- IGNORED
		Callback = function()
			print('HI')
		end
	})
	
	local ToggleLeft = LeftSide:AddToggle("ToggleLeft", {Title = "Toggle", Default = true })
	local ToggleRight = RightSide:AddToggle("ToggleRight", {Title = "Toggle (Opposite Left)", Default = false})

	ToggleLeft:OnChanged(function()
		
		print("Toggle changed:", Options.ToggleLeft.Value)
		Options.ToggleRight:SetValue(not Options.ToggleLeft.Value)
	end)
	
	ToggleRight:OnChanged(function()
		print("Toggle changed:", Options.ToggleRight.Value)
		
	end)

	local Slider = LeftSide:AddSlider("Slider", {
		Title = "Slider 1 - 10",
		Description = "This is a slider", -- IGNORED
		Default = 0,
		Min = 1,
		Max = 10,
		Rounding = 1,
		Callback = function(Value)
			print("Slider was changed:", Value)
		end
	})

	Slider:OnChanged(function(Value)
		print("Slider changed:", Value)
	end)

	Slider:SetValue(5)
	

	LeftSide:AddButton({
		Title = "Reset Slider to 1",
		Description = "Very important button", -- IGNORED
		Callback = function()
			Options.Slider:SetValue(1)
		end
	})
	
	local Dropdown = RightSide:AddDropdown("Dropdown", {
		Title = "Dropdown",
		Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
		Multi = false,
		Default = "three",
	})

	Dropdown:SetValue("four")

	Dropdown:OnChanged(function(Value)
		print("Dropdown changed:", Value)
	end)

	local MultiDropdown = RightSide:AddDropdown("Dropdown", {
		Title = "Dropdown",
		Values = {"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven", "twelve", "thirteen", "fourteen"},
		Multi = true,
		Default = {"eight", "nine", "ten"},
	})

	MultiDropdown:OnChanged(function(Value)
		local Values = {}
		for Value, State in next, Value do
			table.insert(Values, Value)
		end
		print("Mutlidropdown changed:", table.concat(Values, ", "))
	end)
	
	RightSide:AddButton({
		Title = "Reset MultiDD to 1,2,3",
		Description = "Very important button", -- IGNORED
		Callback = function()
			MultiDropdown:SetValue({
				one = true,
				two = true,
				three = true
			})
		end
	})
	
	local ANInput = RightSide:AddInput("ANInput", {
		Title = "AlphaNumeric",
		Default = "Default",
		Placeholder = "Placeholder",
		Numeric = false, -- Only allows numbers
		Finished = false, -- Only calls callback when you press enter, not for OnChanged
		Callback = function(Value)
			print("Input changed:", Value)
		end
	})

	ANInput:OnChanged(function()
		print("Input updated:", ANInput.Value)
	end)
	
	RightSide:AddButton({
		Title = "Change AN Input to LOL",
		Description = "Very important button", -- IGNORED
		Callback = function()
			ANInput:SetValue("LOL")
		end
	})
	
	local NInput = RightSide:AddInput("NInput", {
		Title = "Numeric",
		Default = "Default",
		Placeholder = "Placeholder",
		Numeric = true, -- Only allows numbers
		Finished = false, -- Only calls callback when you press enter, not for OnChanged
		Callback = function(Value)
			print("Input changed:", Value)
		end
	})

	NInput:OnChanged(function()
		print("Input updated:", NInput.Value)
	end)

	RightSide:AddButton({
		Title = "Change N Input to 1",
		Description = "Very important button", -- IGNORED
		Callback = function()
			NInput:SetValue("1")
		end
	})
	
end
-- ----- --

-- Tab 2 --
do
	local Notip = Tab2:AddSection({Title = "Notification Test"})
	
	local Title
	local Content
	local EnableSubContent = false
	local SubContent
	local EnableDuration = true
	local Duration
	
	local TitleInput = Notip:AddInput("TItle", {
		Title = "Title",
		Default = "Notification",
		Placeholder = "Title",
		Numeric = false, -- Only allows numbers
		Finished = true, -- Only calls callback when you press enter, not for OnChanged
		Callback = function(Value)
			Title = Value
		end
	})
	local ContentInput = Notip:AddInput("Content", {
		Title = "Content",
		Default = "Hello There :D",
		Placeholder = "Content",
		Numeric = false, -- Only allows numbers
		Finished = true, -- Only calls callback when you press enter, not for OnChanged
		Callback = function(Value)
			Content = Value
		end
	})
	
	local AllowSubContent = Notip:AddToggle("AllowSubContent", {Title = "Enable SubContent", Default = EnableSubContent})
	AllowSubContent:OnChanged(function(state)
		EnableSubContent = state
	end)
	
	local SubContentInput = Notip:AddInput("SubContent", {
		Title = "SubContent",
		Default = "I'm a SubContent :0",
		Placeholder = "Content",
		Numeric = false, -- Only allows numbers
		Finished = true, -- Only calls callback when you press enter, not for OnChanged
		Callback = function(Value)
			SubContent = Value
		end
	})
	
	local AllowDuration = Notip:AddToggle("AllowDuration", {Title = "Enable Duration", Default = EnableDuration})
	AllowDuration:OnChanged(function(state)
		EnableDuration = state
	end)
	
	local DurationSlider = Notip:AddSlider("DurationSlider", {
		Title = "Duration To Close",
		Description = "This is a slider",
		Default = 1,
		Min = 0,
		Max = 10,
		Rounding = 1,
		Callback = function(Value)
			Duration = Value
		end
	})
	
	Notip:AddButton({Title = "Send Notification",
		Callback = function()
			if EnableSubContent and EnableDuration then
				print("Sending With SubContent + Duration")
				x2zuLibrary:Notify({
					Title = Title,
					Content = Content,
					SubContent = SubContent,
					Duration = Duration
				})
			elseif EnableSubContent then
				print("Sending With SubContent")
				x2zuLibrary:Notify({
					Title = Title,
					Content = Content,
					SubContent = SubContent,
					Duration = nil
				})
			elseif EnableDuration then
				print("Sending With Duration")
				x2zuLibrary:Notify({
					Title = Title,
					Content = Content,
					Duration = Duration
				})
			else
				print("Sending")
				x2zuLibrary:Notify({
					Title = Title,
					Content = Content,
					Duration = nil
				})
			end
		end,
	})
	
	
end

-- NOTES --
local Notes = Tab2:AddSection({Title = "Note"})
Notes:AddParagraph({
	Title = "Duration",
	Content = "Disabling Duration will make notification last forever until you close it.\n\nSame goes by enabling it, it will last as you set the duration."
})
--                                         ,----,
--  ,--,     ,--,        ,----,          .'   .`|
--  |'. \   / .`|      .'   .' \      .'   .'   ;          ,--,
--  ; \ `\ /' / ;    ,----,'    |   ,---, '    .'        ,'_ /|
--  `. \  /  / .'    |    :  .  ;   |   :     ./    .--. |  | :
--   \  \/  / ./     ;    |.'  /    ;   | .'  /   ,'_ /| :  . |
--    \  \.'  /      `----'/  ;     `---' /  ;    |  ' | |  . .
--     \  ;  ;         /  ;  /        /  ;  /     |  | ' |  | |
--    / \  \  \       ;  /  /-,      ;  /  /--,   :  | | :  ' ;
--   ;  /\  \  \     /  /  /.`|     /  /  / .`|   |  ; ' |  | '
-- ./__;  \  ;  \  ./__;      :   ./__;       :   :  | : ;  ; |
-- |   : / \  \  ; |   :    .'    |   :     .'    '  :  `--'   \
-- ;   |/   \  ' | ;   | .'       ;   |  .'       :  ,      .-./
-- `---'     `--`  `---'          `---'            `--`----'

-- ngaku ngaku yatim ngentot di kasi gratis ngelunjak memek
-- 03-02-2025 > Changed UI Color Purple to blue gradient
-- Revolution : Ancestral > Stellar Create by x2zu
-- don't be stupid and be smart just give credit @x2zu
-- Discord Server x2zu best skid discord open source script everrrrrrrrrrrrrr : https://discord.gg/FmMuvkaWvG / discord.gg/x2zu Owner: @x2zu muhauhauhauhua
