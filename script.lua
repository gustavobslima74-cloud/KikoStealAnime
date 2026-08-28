--========================================================--
--          KIKO ANIME STEAL (UNIVERSAL FAILSAFE)        --
--========================================================--

print("[KIKO STEAL] Iniciando carregamento...")

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- DETECÇÃO UNIVERSAL DE INTERFACE (Evita crash do executor)
local function GetSafeGuiParent()
    if gethui then
        local success, result = pcall(gethui)
        if success and result then return result end
    end
    local successCore, coreGui = pcall(function() return game:GetService("CoreGui") end)
    if successCore and coreGui then return coreGui end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local ParentGui = GetSafeGuiParent()

-- Limpar versões antigas
for _, child in ipairs(ParentGui:GetChildren()) do
    if child.Name == "KikoAnimeSteal" then
        child:Destroy()
    end
end

local CONFIG = {
    Speed = 36,
    SpeedEnabled = true,
    Background = Color3.fromRGB(15, 15, 20),
    Element = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(140, 90, 255),
    Text = Color3.fromRGB(255, 255, 255),
    Danger = Color3.fromRGB(255, 70, 70),
    Success = Color3.fromRGB(70, 255, 140),
    Warning = Color3.fromRGB(255, 190, 60)
}

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KikoAnimeSteal"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

-- BOTÃO FLUTUANTE ULTRA-COMPATÍVEL
local Floating = Instance.new("TextButton")
Floating.Name = "FloatingButton"
Floating.Size = UDim2.new(0, 55, 0, 55)
Floating.Position = UDim2.new(0.9, -60, 0.3, 0)
Floating.BackgroundColor3 = CONFIG.Background
Floating.BorderSizePixel = 0
Floating.Text = "KIKO"
Floating.TextColor3 = CONFIG.Accent
Floating.Font = Enum.Font.GothamBold
Floating.TextSize = 12
Floating.ZIndex = 9999
Floating.Active = true
Floating.Parent = ScreenGui

Instance.new("UICorner", Floating).CornerRadius = UDim.new(1, 0)
local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = CONFIG.Accent
FloatingStroke.Thickness = 2
FloatingStroke.Parent = Floating

-- MENU PRINCIPAL
local Menu = Instance.new("Frame")
Menu.Name = "MainMenu"
Menu.Size = UDim2.new(0, 280, 0, 320)
Menu.Position = UDim2.new(0.5, -140, 0.5, -160)
Menu.BackgroundColor3 = CONFIG.Background
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.ZIndex = 10000
Menu.Parent = ScreenGui

Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 10)
local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = CONFIG.Accent
MenuStroke.Thickness = 1.5
MenuStroke.Parent = Menu

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundColor3 = CONFIG.Element
Header.Parent = Menu
Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -40, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIKO ANIME STEAL"
Title.TextColor3 = CONFIG.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -35, 0, 5)
Close.BackgroundTransparency = 1
Close.Text = "X"
Close.TextColor3 = CONFIG.Danger
Close.Font = Enum.Font.GothamBold
Close.TextSize = 16
Close.Parent = Header

-- CLIQUE DO BOTÃO FLUTUANTE
local MenuOpen = false
local function ToggleMenu()
    MenuOpen = not MenuOpen
    Menu.Visible = MenuOpen
end

Floating.MouseButton1Click:Connect(ToggleMenu)
Close.MouseButton1Click:Connect(function()
    MenuOpen = false
    Menu.Visible = false
end)

print("[KIKO STEAL] Interface carregada com sucesso!")
