--[[
    SnoeUI - A minimal, SwiftUI-inspired UI library for Roblox
    Clean glassmorphism aesthetic with smooth spring animations
]]

local SnoeUI = {
    Version = "1.0.0",
    Windows = {},
    Theme = nil,
    ScreenGui = nil,
}

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

-- Icons from WindUI
local IconsURL = "https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua"
local Icons = loadstring(game:HttpGet(IconsURL))()
Icons.SetIconsType("lucide")

-- Utility: Spring animation
local function spring(obj, props, duration, style)
    style = style or Enum.EasingStyle.Quint
    return TweenService:Create(obj, TweenInfo.new(duration or 0.3, style, Enum.EasingDirection.Out), props)
end

-- Utility: Create instance with defaults
local function create(class, props, children)
    local obj = Instance.new(class)
    
    -- Default properties
    if class == "Frame" or class == "TextLabel" or class == "TextButton" or class == "TextBox" then
        obj.BorderSizePixel = 0
        obj.BackgroundColor3 = Color3.new(1, 1, 1)
    end
    if class == "TextLabel" or class == "TextButton" or class == "TextBox" then
        obj.TextColor3 = Color3.new(1, 1, 1)
        obj.Font = Enum.Font.GothamMedium
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

-- Default dark theme
local DefaultTheme = {
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

SnoeUI.Theme = DefaultTheme
SnoeUI.Create = create
SnoeUI.Spring = spring
SnoeUI.Icons = Icons

-- Initialize ScreenGui
local function initGui()
    local parent = (syn and syn.protect_gui) and CoreGui or Players.LocalPlayer:WaitForChild("PlayerGui")
    
    SnoeUI.ScreenGui = create("ScreenGui", {
        Name = "SnoeUI",
        Parent = parent,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        IgnoreGuiInset = true,
    })
    
    if syn and syn.protect_gui then
        syn.protect_gui(SnoeUI.ScreenGui)
    end
end

initGui()

-- Create Window
function SnoeUI:CreateWindow(config)
    local Window = require(script.Parent.Components.Window)
    return Window.new(self, config)
end

-- Set theme
function SnoeUI:SetTheme(theme)
    for k, v in pairs(theme) do
        self.Theme[k] = v
    end
end

-- Notify
function SnoeUI:Notify(config)
    local Notification = require(script.Parent.Components.Notification)
    return Notification.new(self, config)
end

-- Destroy all
function SnoeUI:Destroy()
    if self.ScreenGui then
        self.ScreenGui:Destroy()
    end
end

return SnoeUI
