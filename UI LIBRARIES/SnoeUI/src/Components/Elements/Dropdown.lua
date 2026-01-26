--[[
    Dropdown Element - Selection menu
]]

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(Tab, Parent, config)
    local self = setmetatable({}, Dropdown)
    
    self.Tab = Tab
    self.SnoeUI = Tab.SnoeUI
    self.Title = config.Title or "Dropdown"
    self.Desc = config.Desc
    self.Options = config.Options or {}
    self.Value = config.Default
    self.Multi = config.Multi or false
    self.Selected = self.Multi and {} or nil
    self.Callback = config.Callback or function() end
    self.Theme = Tab.Theme
    self.Opened = false
    
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    
    local baseHeight = self.Desc and 52 or 40
    
    -- Container
    self.Frame = create("Frame", {
        Name = self.Title,
        Parent = Parent,
        Size = UDim2.new(1, 0, 0, baseHeight),
        BackgroundColor3 = self.Theme.Surface,
        BackgroundTransparency = 0.3,
        ClipsDescendants = true,
    }, {
        create("UICorner", { CornerRadius = UDim.new(0, 6) }),
    })
    
    -- Header (clickable)
    self.Header = create("TextButton", {
        Name = "Header",
        Parent = self.Frame,
        Size = UDim2.new(1, 0, 0, baseHeight),
        BackgroundTransparency = 1,
        Text = "",
    })
    
    -- Title
    self.TitleLabel = create("TextLabel", {
        Name = "Title",
        Parent = self.Header,
        Position = UDim2.fromOffset(10, self.Desc and 6 or 0),
        Size = UDim2.new(0.6, -10, 0, self.Desc and 16 or baseHeight),
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
            Parent = self.Header,
            Position = UDim2.fromOffset(10, 24),
            Size = UDim2.new(1, -80, 0, 12),
            BackgroundTransparency = 1,
            Text = self.Desc,
            TextColor3 = self.Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 11,
        })
    end
    
    -- Selected value display
    self.ValueLabel = create("TextLabel", {
        Name = "Value",
        Parent = self.Header,
        Position = UDim2.new(1, -30, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Size = UDim2.new(0.4, -20, 0, 16),
        BackgroundTransparency = 1,
        Text = self.Value or "Select...",
        TextColor3 = self.Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Right,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextTruncate = Enum.TextTruncate.AtEnd,
    })
    
    -- Arrow
    self.Arrow = create("TextLabel", {
        Name = "Arrow",
        Parent = self.Header,
        Position = UDim2.new(1, -18, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        Size = UDim2.fromOffset(12, 12),
        BackgroundTransparency = 1,
        Text = "▼",
        TextColor3 = self.Theme.TextSecondary,
        Font = Enum.Font.GothamMedium,
        TextSize = 8,
    })
    
    -- Options container
    self.OptionsContainer = create("Frame", {
        Name = "Options",
        Parent = self.Frame,
        Position = UDim2.new(0, 0, 0, baseHeight),
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
    }, {
        create("UIListLayout", {
            Padding = UDim.new(0, 2),
        }),
        create("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 6),
            PaddingRight = UDim.new(0, 6),
        }),
    })
    
    -- Create option buttons
    self:BuildOptions()
    
    -- Toggle dropdown
    self.Header.MouseButton1Click:Connect(function()
        self:Toggle()
    end)
    
    -- Hover
    self.Header.MouseEnter:Connect(function()
        spring(self.Frame, { BackgroundTransparency = 0.1 }, 0.15):Play()
    end)
    
    self.Header.MouseLeave:Connect(function()
        spring(self.Frame, { BackgroundTransparency = 0.3 }, 0.15):Play()
    end)
    
    -- Set initial value
    if self.Value then
        self:Set(self.Value, true)
    end
    
    return self
end

function Dropdown:BuildOptions()
    local create = self.SnoeUI.Create
    local spring = self.SnoeUI.Spring
    
    -- Clear existing
    for _, child in ipairs(self.OptionsContainer:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    for _, option in ipairs(self.Options) do
        local optionBtn = create("TextButton", {
            Name = option,
            Parent = self.OptionsContainer,
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = self.Theme.SurfaceHover,
            BackgroundTransparency = 0.5,
            Text = "",
        }, {
            create("UICorner", { CornerRadius = UDim.new(0, 4) }),
        })
        
        create("TextLabel", {
            Name = "Label",
            Parent = optionBtn,
            Position = UDim2.fromOffset(8, 0),
            Size = UDim2.new(1, -16, 1, 0),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = self.Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            Font = Enum.Font.Gotham,
            TextSize = 12,
        })
        
        optionBtn.MouseEnter:Connect(function()
            spring(optionBtn, { BackgroundTransparency = 0.2 }, 0.1):Play()
        end)
        
        optionBtn.MouseLeave:Connect(function()
            spring(optionBtn, { BackgroundTransparency = 0.5 }, 0.1):Play()
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            if self.Multi then
                if self.Selected[option] then
                    self.Selected[option] = nil
                else
                    self.Selected[option] = true
                end
                self:UpdateDisplay()
                self.Callback(self:GetSelected())
            else
                self:Set(option)
                self:Toggle()
            end
        end)
    end
end

function Dropdown:Toggle()
    local spring = self.SnoeUI.Spring
    self.Opened = not self.Opened
    
    local baseHeight = self.Desc and 52 or 40
    local optionsHeight = #self.Options * 28 + 8
    
    if self.Opened then
        spring(self.Frame, { Size = UDim2.new(1, 0, 0, baseHeight + optionsHeight) }, 0.25, Enum.EasingStyle.Back):Play()
        spring(self.Arrow, { Rotation = 180 }, 0.2):Play()
    else
        spring(self.Frame, { Size = UDim2.new(1, 0, 0, baseHeight) }, 0.2):Play()
        spring(self.Arrow, { Rotation = 0 }, 0.2):Play()
    end
end

function Dropdown:UpdateDisplay()
    if self.Multi then
        local selected = {}
        for opt, _ in pairs(self.Selected) do
            table.insert(selected, opt)
        end
        self.ValueLabel.Text = #selected > 0 and table.concat(selected, ", ") or "Select..."
    else
        self.ValueLabel.Text = self.Value or "Select..."
    end
end

function Dropdown:Set(value, skipCallback)
    self.Value = value
    self:UpdateDisplay()
    
    if not skipCallback then
        self.Callback(value)
    end
end

function Dropdown:GetSelected()
    if self.Multi then
        local result = {}
        for opt, _ in pairs(self.Selected) do
            table.insert(result, opt)
        end
        return result
    end
    return self.Value
end

function Dropdown:Refresh(options)
    self.Options = options
    self:BuildOptions()
end

return Dropdown
