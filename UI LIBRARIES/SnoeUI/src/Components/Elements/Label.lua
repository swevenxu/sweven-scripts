--[[
    Label Element - Simple text display
]]

local Label = {}
Label.__index = Label

function Label.new(Tab, Parent, config)
    local self = setmetatable({}, Label)
    
    self.Tab = Tab
    self.SnoeUI = Tab.SnoeUI
    self.Text = config.Text or "Label"
    self.Color = config.Color
    self.Theme = Tab.Theme
    
    local create = self.SnoeUI.Create
    
    -- Label
    self.Frame = create("TextLabel", {
        Name = "Label",
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, 20),
        BackgroundTransparency = 1,
        Text = self.Text,
        TextColor3 = self.Color or self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
    })
    
    return self
end

function Label:Set(text)
    self.Frame.Text = text
end

function Label:SetColor(color)
    self.Frame.TextColor3 = color
end

return Label
