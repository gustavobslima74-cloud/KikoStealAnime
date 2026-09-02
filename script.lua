--========================================================--
-- KIKO MENU (SEM AUTO LOCK / APENAS MANUAL)
--========================================================--

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- UI Cleanup
for _, folder in ipairs({LocalPlayer:FindFirstChild("PlayerGui"), (gethui and gethui()) or game:GetService("CoreGui")}) do
    if folder then
        local old = folder:FindFirstChild("KikoMenuGui")
        if old then old:Destroy() end
    end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KikoMenuGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 99999

local guiParent = (gethui and gethui()) or game:GetService("CoreGui")
pcall(function() ScreenGui.Parent = guiParent end)
if not ScreenGui.Parent then ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 230, 0, 110)
Frame.Position = UDim2.new(0.5, -115, 0.15, 0)
Frame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true

Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 8)
local Stroke = Instance.new("UIStroke", Frame)
Stroke.Color = Color3.fromRGB(0, 170, 255)
Stroke.Thickness = 1.5

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.Text = "👑 KIKO MENU"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 11

local ActionBtn = Instance.new("TextButton", Frame)
ActionBtn.Size = UDim2.new(1, -20, 0, 32)
ActionBtn.Position = UDim2.new(0, 10, 0, 35)
ActionBtn.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
ActionBtn.Text = "⚡ BOTÃO MANUAL"
ActionBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActionBtn.Font = Enum.Font.GothamBold
ActionBtn.TextSize = 11
Instance.new("UICorner", ActionBtn).CornerRadius = UDim.new(0, 4)

local StatusLabel = Instance.new("TextLabel", Frame)
StatusLabel.Size = UDim2.new(1, -10, 0, 25)
StatusLabel.Position = UDim2.new(0, 5, 0, 75)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Auto Lock completamente removido."
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 9.5

ActionBtn.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Clicado manualmente!"
    StatusLabel.TextColor3 = Color3.fromRGB(75, 210, 125)
    task.wait(1.5)
    StatusLabel.Text = "Aguardando ação..."
    StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
end)
