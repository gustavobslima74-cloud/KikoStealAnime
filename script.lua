--========================================================--
--  KIKO ANIME STEAL (V8 - REDESIGN)                       --
--========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local SoundService = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

--========================================================--
-- CONFIG / PALETA
--========================================================--

local CONFIG = {
    Speed = 36,

    Background    = Color3.fromRGB(13, 13, 18),
    Surface       = Color3.fromRGB(19, 19, 27),
    Surface2      = Color3.fromRGB(26, 26, 36),
    SurfaceHover  = Color3.fromRGB(35, 35, 48),
    Border        = Color3.fromRGB(45, 45, 62),

    Accent        = Color3.fromRGB(130, 100, 255),
    Accent2       = Color3.fromRGB(80, 200, 255),
    AccentGold    = Color3.fromRGB(255, 200, 50),

    Text          = Color3.fromRGB(240, 240, 250),
    SubText       = Color3.fromRGB(140, 140, 165),

    Success       = Color3.fromRGB(75, 210, 125),
    Danger        = Color3.fromRGB(255, 80, 100),
    Warning       = Color3.fromRGB(255, 170, 40),
    Info          = Color3.fromRGB(80, 160, 255)
}

local SOUNDS = {
    Click         = "rbxassetid://6895079853",
    Open          = "rbxassetid://6895079853",
    Close         = "rbxassetid://6895079853",
    RareFound     = "rbxassetid://4612375232",
    StealStart    = "rbxassetid://138090596",
    StealSuccess  = "rbxassetid://2865227271",
    Notification  = "rbxassetid://9119713951"
}

local function PlaySound(soundId, volume)
    task.spawn(function()
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = soundId
            sound.Volume = volume or 0.7
            sound.PlayOnRemove = true
            sound.Parent = SoundService
            sound:Destroy()
        end)
    end)
end

--========================================================--
-- LIMPEZA
--========================================================--

pcall(function()
    local Old = game:GetService("CoreGui"):FindFirstChild("KikoAnimeSteal")
    if Old then Old:Destroy() end
    local Old2 = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("KikoAnimeSteal")
    if Old2 then Old2:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KikoAnimeSteal"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--========================================================--
-- NOTIFICAÇÕES (TOASTS - TOP RIGHT)
--========================================================--

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 280, 1, -40)
NotifContainer.Position = UDim2.new(1, -300, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 2000
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Top
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifContainer

local function Notify(title, message, duration, themeColor, soundId)
    duration = duration or 4
    themeColor = themeColor or CONFIG.Info
    soundId = soundId or SOUNDS.Notification

    PlaySound(soundId, 0.55)

    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 0, 68)
    Toast.BackgroundColor3 = CONFIG.Surface
    Toast.BorderSizePixel = 0
    Toast.BackgroundTransparency = 1
    Toast.ClipsDescendants = true
    Toast.Parent = NotifContainer

    local c = Instance.new("UICorner", Toast)
    c.CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", Toast)
    stroke.Color = CONFIG.Border
    stroke.Thickness = 1
    stroke.Transparency = 1

    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 1, -16)
    accentBar.Position = UDim2.new(0, 0, 0, 8)
    accentBar.BackgroundColor3 = themeColor
    accentBar.BorderSizePixel = 0
    accentBar.BackgroundTransparency = 1
    accentBar.Parent = Toast
    Instance.new("UICorner", accentBar).CornerRadius = UDim.new(1, 0)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -22, 0, 18)
    titleLbl.Position = UDim2.new(0, 14, 0, 8)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = themeColor
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.TextTransparency = 1
    titleLbl.Parent = Toast

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Size = UDim2.new(1, -22, 0, 34)
    msgLbl.Position = UDim2.new(0, 14, 0, 27)
    msgLbl.BackgroundTransparency = 1
    msgLbl.Text = message
    msgLbl.TextColor3 = CONFIG.SubText
    msgLbl.Font = Enum.Font.Gotham
    msgLbl.TextSize = 10
    msgLbl.TextWrapped = true
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextYAlignment = Enum.TextYAlignment.Top
    msgLbl.TextTransparency = 1
    msgLbl.Parent = Toast

    Toast.Position = UDim2.new(0, 60, 0, 0)

    local tInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(Toast, tInfo, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(stroke, tInfo, {Transparency = 0.2}):Play()
    TweenService:Create(accentBar, tInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(titleLbl, tInfo, {TextTransparency = 0}):Play()
    TweenService:Create(msgLbl, tInfo, {TextTransparency = 0}):Play()

    task.delay(duration, function()
        if Toast and Toast.Parent then
            local out = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            TweenService:Create(Toast, out, {BackgroundTransparency = 1, Position = UDim2.new(0, 60, 0, 0)}):Play()
            TweenService:Create(stroke, out, {Transparency = 1}):Play()
            TweenService:Create(accentBar, out, {BackgroundTransparency = 1}):Play()
            TweenService:Create(titleLbl, out, {TextTransparency = 1}):Play()
            TweenService:Create(msgLbl, out, {TextTransparency = 1}):Play()
            task.wait(0.32)
            Toast:Destroy()
        end
    end)
end

--========================================================--
-- BOTÃO FLUTUANTE
--========================================================--

local Floating = Instance.new("TextButton")
Floating.Name = "FloatingButton"
Floating.Size = UDim2.new(0, 52, 0, 52)
Floating.Position = UDim2.new(1, -70, 0.4, -26)
Floating.BackgroundColor3 = Color3.new(1, 1, 1)
Floating.BorderSizePixel = 0
Floating.Text = "K"
Floating.TextColor3 = CONFIG.Text
Floating.TextSize = 22
Floating.Font = Enum.Font.GothamBold
Floating.AutoButtonColor = false
Floating.Active = true
Floating.ZIndex = 500
Floating.Parent = ScreenGui

Instance.new("UICorner", Floating).CornerRadius = UDim.new(1, 0)

local FloatGrad = Instance.new("UIGradient")
FloatGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.Accent),
    ColorSequenceKeypoint.new(1, CONFIG.Accent2)
}
FloatGrad.Rotation = 45
FloatGrad.Parent = Floating

local FloatStroke = Instance.new("UIStroke", Floating)
FloatStroke.Color = Color3.fromRGB(255, 255, 255)
FloatStroke.Thickness = 1
FloatStroke.Transparency = 0.6

local dragging, dragInput, dragStart, startPos
local isDraggingAction = false

Floating.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Floating.Position
        isDraggingAction = false

        TweenService:Create(Floating, TweenInfo.new(0.15), {Size = UDim2.new(0, 46, 0, 46)}):Play()

        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
                TweenService:Create(Floating, TweenInfo.new(0.2, Enum.EasingStyle.Back), {Size = UDim2.new(0, 52, 0, 52)}):Play()
            end
        end)
    end
end)

Floating.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        if delta.Magnitude > 3 then isDraggingAction = true end
        Floating.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--========================================================--
-- JANELA PRINCIPAL
--========================================================--

local Main = Instance.new("CanvasGroup")
Main.Name = "MainWindow"
Main.Size = UDim2.new(0, 540, 0, 340)
Main.Position = UDim2.new(0.5, -270, 0.5, -170)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.GroupTransparency = 1
Main.Visible = false
Main.ZIndex = 100
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 14)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 1

-- Bolinha de luz decorativa (top-left)
local Glow = Instance.new("Frame")
Glow.Size = UDim2.new(0, 200, 0, 200)
Glow.Position = UDim2.new(0, -80, 0, -80)
Glow.BackgroundColor3 = CONFIG.Accent
Glow.BorderSizePixel = 0
Glow.BackgroundTransparency = 0.9
Glow.ZIndex = 0
Glow.Parent = Main
Instance.new("UICorner", Glow).CornerRadius = UDim.new(1, 0)

local Glow2 = Instance.new("Frame")
Glow2.Size = UDim2.new(0, 200, 0, 200)
Glow2.Position = UDim2.new(1, -120, 1, -120)
Glow2.BackgroundColor3 = CONFIG.Accent2
Glow2.BorderSizePixel = 0
Glow2.BackgroundTransparency = 0.92
Glow2.ZIndex = 0
Glow2.Parent = Main
Instance.new("UICorner", Glow2).CornerRadius = UDim.new(1, 0)

--========================================================--
-- SIDEBAR
--========================================================--

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 130, 1, -20)
Sidebar.Position = UDim2.new(0, 10, 0, 10)
Sidebar.BackgroundColor3 = CONFIG.Surface
Sidebar.BorderSizePixel = 0
Sidebar.ZIndex = 1
Sidebar.Parent = Main

Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 10)

-- Logo
local LogoBox = Instance.new("Frame")
LogoBox.Size = UDim2.new(1, -16, 0, 48)
LogoBox.Position = UDim2.new(0, 8, 0, 8)
LogoBox.BackgroundTransparency = 1
LogoBox.Parent = Sidebar

local LogoMark = Instance.new("Frame")
LogoMark.Size = UDim2.new(0, 32, 0, 32)
LogoMark.Position = UDim2.new(0, 0, 0.5, -16)
LogoMark.BackgroundColor3 = Color3.new(1, 1, 1)
LogoMark.BorderSizePixel = 0
LogoMark.Parent = LogoBox
Instance.new("UICorner", LogoMark).CornerRadius = UDim.new(0, 8)

local LogoGrad = Instance.new("UIGradient")
LogoGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.Accent),
    ColorSequenceKeypoint.new(1, CONFIG.Accent2)
}
LogoGrad.Rotation = 45
LogoGrad.Parent = LogoMark

local LogoLetter = Instance.new("TextLabel")
LogoLetter.Size = UDim2.new(1, 0, 1, 0)
LogoLetter.BackgroundTransparency = 1
LogoLetter.Text = "K"
LogoLetter.TextColor3 = Color3.new(1, 1, 1)
LogoLetter.Font = Enum.Font.GothamBlack
LogoLetter.TextSize = 18
LogoLetter.Parent = LogoMark

local LogoText = Instance.new("TextLabel")
LogoText.Size = UDim2.new(1, -40, 1, 0)
LogoText.Position = UDim2.new(0, 40, 0, 0)
LogoText.BackgroundTransparency = 1
LogoText.Text = "KIKO"
LogoText.TextColor3 = CONFIG.Text
LogoText.Font = Enum.Font.GothamBlack
LogoText.TextSize = 14
LogoText.TextXAlignment = Enum.TextXAlignment.Left
LogoText.Parent = LogoBox

-- Divisor
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -16, 0, 1)
Divider.Position = UDim2.new(0, 8, 0, 66)
Divider.BackgroundColor3 = CONFIG.Border
Divider.BorderSizePixel = 0
Divider.Parent = Sidebar

-- Container de navegação
local NavContainer = Instance.new("Frame")
NavContainer.Size = UDim2.new(1, -16, 1, -120)
NavContainer.Position = UDim2.new(0, 8, 0, 78)
NavContainer.BackgroundTransparency = 1
NavContainer.Parent = Sidebar

local NavLayout = Instance.new("UIListLayout")
NavLayout.Padding = UDim.new(0, 4)
NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
NavLayout.Parent = NavContainer

-- Versão
local Version = Instance.new("TextLabel")
Version.Size = UDim2.new(1, -16, 0, 20)
Version.Position = UDim2.new(0, 8, 1, -28)
Version.BackgroundTransparency = 1
Version.Text = "v8.0 • redesign"
Version.TextColor3 = CONFIG.SubText
Version.Font = Enum.Font.Gotham
Version.TextSize = 9
Version.TextXAlignment = Enum.TextXAlignment.Left
Version.Parent = Sidebar

--========================================================--
-- PAINEL DIREITO / HEADER / CONTEÚDO
--========================================================--

local RightPanel = Instance.new("Frame")
RightPanel.Size = UDim2.new(1, -150, 1, -20)
RightPanel.Position = UDim2.new(0, 148, 0, 10)
RightPanel.BackgroundTransparency = 1
RightPanel.ZIndex = 1
RightPanel.Parent = Main

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 40)
Header.BackgroundTransparency = 1
Header.Parent = RightPanel

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -50, 1, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "STEAL"
HeaderTitle.TextColor3 = CONFIG.Text
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 15
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local HeaderSub = Instance.new("TextLabel")
HeaderSub.Name = "Sub"
HeaderSub.Size = UDim2.new(1, -50, 0, 14)
HeaderSub.Position = UDim2.new(0, 0, 0, 22)
HeaderSub.BackgroundTransparency = 1
HeaderSub.Text = "Selecione base e personagem para roubar"
HeaderSub.TextColor3 = CONFIG.SubText
HeaderSub.Font = Enum.Font.Gotham
HeaderSub.TextSize = 10
HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
HeaderSub.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 32, 0, 32)
Close.Position = UDim2.new(1, -32, 0, 4)
Close.BackgroundColor3 = CONFIG.Surface2
Close.BorderSizePixel = 0
Close.Text = "✕"
Close.TextColor3 = CONFIG.SubText
Close.Font = Enum.Font.GothamBold
Close.TextSize = 14
Close.AutoButtonColor = false
Close.Parent = Header
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 8)

Close.MouseEnter:Connect(function()
    TweenService:Create(Close, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Danger, TextColor3 = Color3.new(1,1,1)}):Play()
end)
Close.MouseLeave:Connect(function()
    TweenService:Create(Close, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Surface2, TextColor3 = CONFIG.SubText}):Play()
end)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -44)
Content.Position = UDim2.new(0, 0, 0, 44)
Content.BackgroundTransparency = 1
Content.ClipsDescendants = false
Content.Parent = RightPanel

--========================================================--
-- HELPERS DE UI
--========================================================--

local function MakeBtn(parent, text, height, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, height or 40)
    btn.Position = UDim2.new(0, 0, 0, yPos or 0)
    btn.BackgroundColor3 = CONFIG.Surface2
    btn.BorderSizePixel = 0
    btn.Text = text
    btn.TextColor3 = CONFIG.Text
    btn.Font = Enum.Font.GothamSemibold
    btn.TextSize = 11
    btn.AutoButtonColor = false
    btn.Parent = parent
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local st = Instance.new("UIStroke", btn)
    st.Color = CONFIG.Border
    st.Thickness = 1
    st.Transparency = 0.3

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.SurfaceHover}):Play()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = CONFIG.Accent, Transparency = 0.5}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Surface2}):Play()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = CONFIG.Border, Transparency = 0.3}):Play()
    end)

    return btn, st
end

local function MakeToggleCard(parent, title, subtitle, layoutOrder)
    local card = Instance.new("TextButton")
    card.Size = UDim2.new(1, 0, 0, 54)
    card.LayoutOrder = layoutOrder or 0
    card.BackgroundColor3 = CONFIG.Surface2
    card.BorderSizePixel = 0
    card.Text = ""
    card.AutoButtonColor = false
    card.Parent = parent
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)

    local st = Instance.new("UIStroke", card)
    st.Color = CONFIG.Border
    st.Thickness = 1
    st.Transparency = 0.3

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -70, 0, 18)
    tLbl.Position = UDim2.new(0, 14, 0, 9)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = CONFIG.Text
    tLbl.Font = Enum.Font.GothamSemibold
    tLbl.TextSize = 12
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.Parent = card

    local sLbl = Instance.new("TextLabel")
    sLbl.Size = UDim2.new(1, -70, 0, 14)
    sLbl.Position = UDim2.new(0, 14, 0, 28)
    sLbl.BackgroundTransparency = 1
    sLbl.Text = subtitle
    sLbl.TextColor3 = CONFIG.SubText
    sLbl.Font = Enum.Font.Gotham
    sLbl.TextSize = 10
    sLbl.TextXAlignment = Enum.TextXAlignment.Left
    sLbl.Parent = card

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 38, 0, 20)
    track.Position = UDim2.new(1, -52, 0.5, -10)
    track.BackgroundColor3 = CONFIG.SurfaceHover
    track.BorderSizePixel = 0
    track.Parent = card
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = CONFIG.Text
    dot.BorderSizePixel = 0
    dot.Parent = track
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    card.MouseEnter:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.SurfaceHover}):Play()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = CONFIG.Accent}):Play()
    end)
    card.MouseLeave:Connect(function()
        TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Surface2}):Play()
        TweenService:Create(st, TweenInfo.new(0.15), {Color = CONFIG.Border}):Play()
    end)

    local state = false
    local function setState(on, silent)
        state = on
        TweenService:Create(track, TweenInfo.new(0.25), {
            BackgroundColor3 = on and CONFIG.Success or CONFIG.SurfaceHover
        }):Play()
        TweenService:Create(dot, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Position = on and UDim2.new(0, 21, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
    end

    return card, setState, function() return state end
end

--========================================================--
-- PÁGINAS (TABS)
--========================================================--

local Pages = {}
local NavButtons = {}
local ActiveTab = nil

local function SwitchTab(name)
    if ActiveTab == name then return end
    ActiveTab = name
    for tabName, page in pairs(Pages) do
        local on = (tabName == name)
        page.Visible = on
        if on then
            page.GroupTransparency = 1
            TweenService:Create(page, TweenInfo.new(0.25, Enum.EasingStyle.Quart), {GroupTransparency = 0}):Play()
        end
    end
    for n, btn in pairs(NavButtons) do
        local on = (n == name)
        TweenService:Create(btn, TweenInfo.new(0.2), {
            BackgroundColor3 = on and CONFIG.Accent or CONFIG.Surface2,
            BackgroundTransparency = on and 0 or 1
        }):Play()
        local lbl = btn:FindFirstChild("Label")
        if lbl then
            TweenService:Create(lbl, TweenInfo.new(0.2), {
                TextColor3 = on and Color3.new(1,1,1) or CONFIG.SubText
            }):Play()
        end
    end
end

local function CreateNavButton(name, icon, text, order)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 36)
    btn.LayoutOrder = order
    btn.BackgroundColor3 = CONFIG.Surface2
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.Parent = NavContainer
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Size = UDim2.new(1, -20, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = icon .. "   " .. text
    lbl.TextColor3 = CONFIG.SubText
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    btn.MouseEnter:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.5}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if ActiveTab ~= name then
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
        end
    end)
    btn.MouseButton1Click:Connect(function()
        PlaySound(SOUNDS.Click, 0.4)
        SwitchTab(name)
    end)

    NavButtons[name] = btn
    return btn
end

local function CreatePage(name)
    local page = Instance.new("CanvasGroup")
    page.Name = name
    page.Size = UDim2.new(1, 0, 1, 0)
    page.BackgroundTransparency = 1
    page.GroupTransparency = 1
    page.Visible = false
    page.Parent = Content
    Pages[name] = page
    return page
end

--========================================================--
-- PÁGINA: STEAL
--========================================================--

local PageSteal = CreatePage("Steal")

local BaseButton, _ = MakeBtn(PageSteal, "🎯  Selecionar Base", 42, 0)
local CharacterButton, _ = MakeBtn(PageSteal, "🧩  Selecionar Personagem", 42, 50)

-- Steal button com gradiente
local StealButton = Instance.new("TextButton")
StealButton.Size = UDim2.new(1, 0, 0, 46)
StealButton.Position = UDim2.new(0, 0, 0, 105)
StealButton.BackgroundColor3 = Color3.new(1, 1, 1)
StealButton.BorderSizePixel = 0
StealButton.Text = "⚡  EXECUTAR STEAL"
StealButton.TextColor3 = Color3.new(1, 1, 1)
StealButton.Font = Enum.Font.GothamBold
StealButton.TextSize = 13
StealButton.AutoButtonColor = false
StealButton.Parent = PageSteal
Instance.new("UICorner", StealButton).CornerRadius = UDim.new(0, 10)

local StealGrad = Instance.new("UIGradient")
StealGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, CONFIG.Accent),
    ColorSequenceKeypoint.new(1, CONFIG.Accent2)
}
StealGrad.Rotation = 0
StealGrad.Parent = StealButton

StealButton.MouseEnter:Connect(function()
    TweenService:Create(StealGrad, TweenInfo.new(0.2), {Offset = Vector2.new(0.05, 0)}):Play()
end)
StealButton.MouseLeave:Connect(function()
    TweenService:Create(StealGrad, TweenInfo.new(0.2), {Offset = Vector2.new(0, 0)}):Play()
end)

-- Tempo de espera (pill)
local TimeoutPill = Instance.new("TextButton")
TimeoutPill.Size = UDim2.new(1, 0, 0, 34)
TimeoutPill.Position = UDim2.new(0, 0, 0, 160)
TimeoutPill.BackgroundColor3 = CONFIG.Surface2
TimeoutPill.BorderSizePixel = 0
TimeoutPill.Text = "⏱   TEMPO DE ESPERA  •  5s"
TimeoutPill.TextColor3 = CONFIG.SubText
TimeoutPill.Font = Enum.Font.GothamSemibold
TimeoutPill.TextSize = 10
TimeoutPill.AutoButtonColor = false
TimeoutPill.Parent = PageSteal
Instance.new("UICorner", TimeoutPill).CornerRadius = UDim.new(0, 8)

local ts = Instance.new("UIStroke", TimeoutPill)
ts.Color = CONFIG.Border
ts.Thickness = 1
ts.Transparency = 0.5

-- Dica
local TipLabel = Instance.new("TextLabel")
TipLabel.Size = UDim2.new(1, 0, 0, 30)
TipLabel.Position = UDim2.new(0, 0, 0, 200)
TipLabel.BackgroundTransparency = 1
TipLabel.Text = "💡 Segure 'E' no alvo durante o roubo."
TipLabel.TextColor3 = CONFIG.SubText
TipLabel.Font = Enum.Font.Gotham
TipLabel.TextSize = 10
TipLabel.TextXAlignment = Enum.TextXAlignment.Left
TipLabel.Parent = PageSteal

--========================================================--
-- PÁGINA: AUTO
--========================================================--

local PageAuto = CreatePage("Auto")
local AutoList = Instance.new("Frame")
AutoList.Size = UDim2.new(1, 0, 1, 0)
AutoList.BackgroundTransparency = 1
AutoList.Parent = PageAuto

local AutoLayout = Instance.new("UIListLayout")
AutoLayout.Padding = UDim.new(0, 8)
AutoLayout.SortOrder = Enum.SortOrder.LayoutOrder
AutoLayout.Parent = AutoList

local AutoCollectCard, AutoCollectSet, AutoCollectGet = MakeToggleCard(AutoList, "💰  Auto Collect Cash", "Coleta dinheiro automaticamente na sua base", 1)
local AutoLockCard, AutoLockSet, AutoLockGet = MakeToggleCard(AutoList, "🔒  Auto Lock Base", "Tranca sua base automaticamente", 2)

AutoCollectCard.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    AutoCollectCash = not AutoCollectCash
    AutoCollectSet(AutoCollectCash)
    if AutoCollectCash then
        Notify("Auto Collect", "Coleta de dinheiro ativada.", 3, CONFIG.Success)
    else
        Notify("Auto Collect", "Coleta desativada.", 3, CONFIG.Warning)
    end
end)

AutoLockCard.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    AutoLockBase = not AutoLockBase
    AutoLockSet(AutoLockBase)
    if AutoLockBase then
        Notify("Auto Lock", "Sua base ficará trancada.", 3, CONFIG.Success)
    else
        Notify("Auto Lock", "Auto Lock desativado.", 3, CONFIG.Warning)
    end
end)

--========================================================--
-- PÁGINA: CONFIG
--========================================================--

local PageConfig = CreatePage("Config")
local ConfigList = Instance.new("Frame")
ConfigList.Size = UDim2.new(1, 0, 1, 0)
ConfigList.BackgroundTransparency = 1
ConfigList.Parent = PageConfig

local ConfigLayout = Instance.new("UIListLayout")
ConfigLayout.Padding = UDim.new(0, 8)
ConfigLayout.SortOrder = Enum.SortOrder.LayoutOrder
ConfigLayout.Parent = ConfigList

local SpeedCard, SpeedSet, SpeedGet = MakeToggleCard(ConfigList, "⚡  Speed Boost", "WalkSpeed " .. CONFIG.Speed .. " com proteção anti-reset", 1)

SpeedCard.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    SpeedEnabled = not SpeedEnabled
    SpeedSet(SpeedEnabled)
    if SpeedEnabled then
        Notify("Speed", "Velocidade ativada (" .. CONFIG.Speed .. ")", 2.5, CONFIG.Success)
    else
        Notify("Speed", "Velocidade desativada", 2.5, CONFIG.Warning)
    end
    ApplySpeed()
end)

--========================================================--
-- PÁGINA: SERVER
--========================================================--

local PageServer = CreatePage("Server")

local RejoinButton, _ = MakeBtn(PageServer, "↻   REJOIN SERVER", 46, 0)
RejoinButton.BackgroundColor3 = CONFIG.Surface2

local ServerHopButton, _ = MakeBtn(PageServer, "🌐   MUDAR DE SERVIDOR", 46, 56)

local ServerInfo = Instance.new("TextLabel")
ServerInfo.Size = UDim2.new(1, 0, 0, 40)
ServerInfo.Position = UDim2.new(0, 0, 0, 115)
ServerInfo.BackgroundTransparency = 1
ServerInfo.Text = "Rejoin volta para o mesmo servidor.\nServer Hop busca um servidor com vaga."
ServerInfo.TextColor3 = CONFIG.SubText
ServerInfo.Font = Enum.Font.Gotham
ServerInfo.TextSize = 10
ServerInfo.TextXAlignment = Enum.TextXAlignment.Left
ServerInfo.TextYAlignment = Enum.TextYAlignment.Top
ServerInfo.TextWrapped = true
ServerInfo.Parent = PageServer

--========================================================--
-- NAVEGAÇÃO
--========================================================--

CreateNavButton("Steal", "🎯", "Steal", 1)
CreateNavButton("Auto", "💰", "Auto", 2)
CreateNavButton("Config", "⚙️", "Config", 3)
CreateNavButton("Server", "🌐", "Servidor", 4)

local HEADER_TITLES = {
    Steal  = {"STEAL", "Selecione base e personagem para roubar"},
    Auto   = {"AUTOMAÇÃO", "Coleta e trava automática da base"},
    Config = {"CONFIGURAÇÕES", "Ajustes gerais do script"},
    Server = {"SERVIDOR", "Reconectar ou trocar de servidor"},
}

local function UpdateHeaderForTab(name)
    local data = HEADER_TITLES[name]
    if not data then return end
    HeaderTitle.Text = data[1]
    HeaderSub.Text = data[2]
end

-- Substitui SwitchTab para também atualizar header
local _OldSwitch = SwitchTab
SwitchTab = function(name)
    _OldSwitch(name)
    UpdateHeaderForTab(name)
end

SwitchTab("Steal")

--========================================================--
-- ESTADO
--========================================================--

local SelectedBase = nil
local SelectedCharacter = nil
local MenuOpen = false
local SpeedEnabled = true
local DetectedExpensiveList = {}
local StealTimeout = 5
local AutoCollectCash = false
local AutoLockBase = false

--========================================================--
-- FUNÇÕES DE SUPORTE (INALTERADAS)
--========================================================--

local function ClearList(List)
    for _, Object in ipairs(List:GetChildren()) do
        if Object:IsA("TextButton") then Object:Destroy() end
    end
end

local function ParseValueString(str)
    if not str then return 0 end
    local clean = string.gsub(string.lower(str), "/s", "")
    clean = string.gsub(clean, "/sec", "")
    clean = string.gsub(clean, "[%$%,%s]", "")
    local numStr, suffix = string.match(clean, "([%d%.]+)([kkmmbbtt]?)")
    if not numStr then return 0 end
    local num = tonumber(numStr) or 0
    suffix = string.upper(suffix or "")
    local multipliers = { [""] = 1, ["K"] = 1e3, ["M"] = 1e6, ["B"] = 1e9, ["T"] = 1e12 }
    return num * (multipliers[suffix] or 1)
end

local function GetCharacterStats(Character)
    if not Character then return nil, nil, 0, 0 end
    local valueStr, incomeStr = nil, nil

    for _, Object in ipairs(Character:GetDescendants()) do
        if Object:IsA("TextLabel") or Object:IsA("TextButton") then
            local text = Object.Text
            if text and text ~= "" then
                local lowerText = string.lower(text)
                if string.find(lowerText, "/s") or string.find(lowerText, "/sec") then
                    if not incomeStr then incomeStr = text end
                elseif string.match(text, "%d[%d%.]*[KkMmBbTt]?") then
                    if not valueStr then valueStr = text end
                end
            end
        end
    end

    local rawValue = ParseValueString(valueStr)
    local rawIncome = ParseValueString(incomeStr)
    return valueStr, incomeStr, rawValue, rawIncome
end

local function MatchesPlayer(text)
    if not text then return false end
    local lower = string.lower(text)
    local pName = string.lower(LocalPlayer.Name)
    local pDisplay = string.lower(LocalPlayer.DisplayName)
    return string.find(lower, pName, 1, true) ~= nil or string.find(lower, pDisplay, 1, true) ~= nil
end

local function GetMyBase()
    local Bases = workspace:FindFirstChild("Bases")
    if Bases then
        for _, Base in ipairs(Bases:GetChildren()) do
            local Sign = Base:FindFirstChild("Sign")
            if Sign then
                local SignPart = Sign:FindFirstChild("SignPart")
                if SignPart then
                    local SurfaceGui = SignPart:FindFirstChild("SurfaceGui")
                    if SurfaceGui then
                        local Label = SurfaceGui:FindFirstChild("TextLabel")
                        if Label and MatchesPlayer(Label.Text) then
                            return Base
                        end
                    end
                end
            end
        end
    end
    return nil
end

local function GetBaseHighestValue(Base)
    local highestValue = 0
    local highestValStr = ""
    local highestIncStr = ""
    local FolderNames = {"Characters", "RainbowCharacters", "CosmicCharacters"}
    for _, FolderName in ipairs(FolderNames) do
        local Folder = Base:FindFirstChild(FolderName)
        if Folder then
            for _, Character in ipairs(Folder:GetChildren()) do
                if Character:IsA("Model") then
                    local valStr, incStr, rawVal, rawInc = GetCharacterStats(Character)
                    if rawVal > highestValue then
                        highestValue = rawVal
                        highestValStr = valStr or ""
                        highestIncStr = incStr or ""
                    end
                end
            end
        end
    end
    return highestValue, highestValStr, highestIncStr
end

local function CheckExpensiveAnimes(baseName, baseObject)
    local FolderNames = {"Characters", "RainbowCharacters", "CosmicCharacters"}
    for _, FolderName in ipairs(FolderNames) do
        local Folder = baseObject:FindFirstChild(FolderName)
        if Folder then
            for _, Character in ipairs(Folder:GetChildren()) do
                if Character:IsA("Model") then
                    local valStr, incStr, rawVal, rawInc = GetCharacterStats(Character)
                    if rawVal >= 100000000 or rawInc >= 100000000 then
                        local charId = Character:GetDebugId()
                        if not DetectedExpensiveList[charId] then
                            DetectedExpensiveList[charId] = true
                            local detailText = "Base: " .. baseName .. "\nItem: " .. Character.Name
                            if valStr then detailText = detailText .. "\nValor: " .. valStr end
                            if incStr then detailText = detailText .. " (" .. incStr .. ")" end
                            Notify("🔥 ANIME RARO ENCONTRADO!", detailText, 7, CONFIG.AccentGold, SOUNDS.RareFound)
                        end
                    end
                end
            end
        end
    end
end

local function GetBases()
    local Result = {}
    local Bases = workspace:FindFirstChild("Bases")
    if not Bases then return Result end

    for _, Base in ipairs(Bases:GetChildren()) do
        local PlayerName
        local Sign = Base:FindFirstChild("Sign")
        if Sign then
            local SignPart = Sign:FindFirstChild("SignPart")
            if SignPart then
                local SurfaceGui = SignPart:FindFirstChild("SurfaceGui")
                if SurfaceGui then
                    local Label = SurfaceGui:FindFirstChild("TextLabel")
                    if Label then
                        local Text = Label.Text
                        PlayerName = string.match(Text, "(.+)'s [Bb]ase") or Text
                    end
                end
            end
        end

        if PlayerName and PlayerName ~= "" then
            local maxRaw, maxValStr, maxIncStr = GetBaseHighestValue(Base)
            CheckExpensiveAnimes(PlayerName, Base)
            table.insert(Result, {
                Object = Base, Name = PlayerName,
                HighestRaw = maxRaw, HighestValStr = maxValStr, HighestIncStr = maxIncStr
            })
        end
    end
    table.sort(Result, function(a, b) return a.HighestRaw > b.HighestRaw end)
    return Result
end

local function GetCharacters(Base)
    local Result = {}
    if not Base then return Result end
    local FolderNames = {"Characters", "RainbowCharacters", "CosmicCharacters"}
    for _, FolderName in ipairs(FolderNames) do
        local Folder = Base:FindFirstChild(FolderName)
        if Folder then
            for _, Character in ipairs(Folder:GetChildren()) do
                if Character:IsA("Model") then
                    local valStr, incStr, rawVal, rawInc = GetCharacterStats(Character)
                    table.insert(Result, {
                        Object = Character, Name = Character.Name,
                        Folder = FolderName, ValueStr = valStr, IncomeStr = incStr,
                        RawValue = rawVal, RawIncome = rawInc
                    })
                end
            end
        end
    end
    table.sort(Result, function(a, b) return a.RawValue > b.RawValue end)
    return Result
end

--========================================================--
-- LISTS (OVERLAY DROPDOWNS)
--========================================================--

local function BuildOverlayList(name)
    local overlay = Instance.new("Frame")
    overlay.Name = name
    overlay.Size = UDim2.new(1, 0, 1, 0)
    overlay.Position = UDim2.new(0, 0, 0, 0)
    overlay.BackgroundColor3 = CONFIG.Background
    overlay.BackgroundTransparency = 0.05
    overlay.BorderSizePixel = 0
    overlay.Visible = false
    overlay.ZIndex = 600
    overlay.Parent = Content
    Instance.new("UICorner", overlay).CornerRadius = UDim.new(0, 10)

    local stroke = Instance.new("UIStroke", overlay)
    stroke.Color = CONFIG.Accent
    stroke.Thickness = 1
    stroke.Transparency = 0.6

    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -12, 1, -50)
    scroll.Position = UDim2.new(0, 6, 0, 44)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = CONFIG.Accent
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.ZIndex = 601
    scroll.Parent = overlay

    local layout = Instance.new("UIListLayout", scroll)
    layout.Padding = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    -- Header
    local headerBar = Instance.new("Frame")
    headerBar.Size = UDim2.new(1, -12, 0, 36)
    headerBar.Position = UDim2.new(0, 6, 0, 6)
    headerBar.BackgroundColor3 = CONFIG.Surface2
    headerBar.BorderSizePixel = 0
    headerBar.ZIndex = 601
    headerBar.Parent = overlay
    Instance.new("UICorner", headerBar).CornerRadius = UDim.new(0, 8)

    local hdrTitle = Instance.new("TextLabel")
    hdrTitle.Size = UDim2.new(1, -50, 1, 0)
    hdrTitle.Position = UDim2.new(0, 12, 0, 0)
    hdrTitle.BackgroundTransparency = 1
    hdrTitle.Text = "Selecione"
    hdrTitle.TextColor3 = CONFIG.Text
    hdrTitle.Font = Enum.Font.GothamBold
    hdrTitle.TextSize = 11
    hdrTitle.TextXAlignment = Enum.TextXAlignment.Left
    hdrTitle.ZIndex = 602
    hdrTitle.Parent = headerBar

    local backBtn = Instance.new("TextButton")
    backBtn.Size = UDim2.new(0, 26, 0, 26)
    backBtn.Position = UDim2.new(1, -30, 0, 5)
    backBtn.BackgroundColor3 = CONFIG.SurfaceHover
    backBtn.BorderSizePixel = 0
    backBtn.Text = "←"
    backBtn.TextColor3 = CONFIG.Text
    backBtn.Font = Enum.Font.GothamBold
    backBtn.TextSize = 14
    backBtn.AutoButtonColor = false
    backBtn.ZIndex = 602
    backBtn.Parent = headerBar
    Instance.new("UICorner", backBtn).CornerRadius = UDim.new(0, 6)

    backBtn.MouseButton1Click:Connect(function()
        PlaySound(SOUNDS.Click, 0.4)
        overlay.Visible = false
    end)

    return overlay, scroll, layout, hdrTitle
end

local BaseOverlay, BaseList, BaseLayout, BaseHeader = BuildOverlayList("BaseOverlay")
local CharOverlay, CharList, CharLayout, CharHeader = BuildOverlayList("CharOverlay")

local function UpdateBases()
    ClearList(BaseList)
    BaseHeader.Text = "🎯  Bases Disponíveis"
    local Bases = GetBases()
    for _, Data in ipairs(Bases) do
        local DisplayName = Data.Name
        local tagParts = {}
        if Data.HighestValStr ~= "" then table.insert(tagParts, Data.HighestValStr) end
        if Data.HighestIncStr ~= "" then table.insert(tagParts, Data.HighestIncStr) end
        if #tagParts > 0 then DisplayName = DisplayName .. "  [" .. table.concat(tagParts, " | ") .. "]" end

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -8, 0, 34)
        Button.BackgroundColor3 = CONFIG.Surface2
        Button.BorderSizePixel = 0
        Button.Text = "  " .. DisplayName
        Button.TextColor3 = CONFIG.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 10
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.AutoButtonColor = false
        Button.ZIndex = 602
        Button.Parent = BaseList
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.SurfaceHover}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Surface2}):Play()
        end)

        Button.MouseButton1Click:Connect(function()
            PlaySound(SOUNDS.Click, 0.5)
            SelectedBase = Data.Object
            SelectedCharacter = nil
            BaseButton.Text = "🎯  " .. Data.Name
            CharacterButton.Text = "🧩  Selecionar Personagem"
            BaseOverlay.Visible = false
            Notify("Base Selecionada", Data.Name, 3, CONFIG.Info)
        end)
    end
    BaseList.CanvasSize = UDim2.new(0, 0, 0, BaseLayout.AbsoluteContentSize.Y + 10)
end

local function UpdateCharacters()
    ClearList(CharList)
    if not SelectedBase then return end
    CharHeader.Text = "🧩  Personagens"
    local Characters = GetCharacters(SelectedBase)
    for _, Data in ipairs(Characters) do
        local DisplayName = Data.Name
        local tagParts = {}
        if Data.ValueStr then table.insert(tagParts, "Val: " .. Data.ValueStr) end
        if Data.IncomeStr then table.insert(tagParts, Data.IncomeStr) end
        if #tagParts > 0 then DisplayName = DisplayName .. "  [" .. table.concat(tagParts, " | ") .. "]" end

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -8, 0, 34)
        Button.BackgroundColor3 = CONFIG.Surface2
        Button.BorderSizePixel = 0
        Button.Text = "  " .. DisplayName
        Button.TextColor3 = CONFIG.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 10
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.AutoButtonColor = false
        Button.ZIndex = 602
        Button.Parent = CharList
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)

        Button.MouseEnter:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.SurfaceHover}):Play()
        end)
        Button.MouseLeave:Connect(function()
            TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Surface2}):Play()
        end)

        Button.MouseButton1Click:Connect(function()
            PlaySound(SOUNDS.Click, 0.5)
            SelectedCharacter = Data.Object
            CharacterButton.Text = "🧩  " .. Data.Name
            CharOverlay.Visible = false
            Notify("Personagem Selecionado", Data.Name, 3, CONFIG.Info)
        end)
    end
    CharList.CanvasSize = UDim2.new(0, 0, 0, CharLayout.AbsoluteContentSize.Y + 10)
end

task.spawn(function()
    while true do
        task.wait(10)
        pcall(function() GetBases() end)
    end
end)

--========================================================--
-- LOOP: AUTO COLLECT & AUTO LOCK (INALTERADO)
--========================================================--

task.spawn(function()
    while true do
        task.wait(1)

        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local MyBase = GetMyBase()

        if hrp and MyBase then
            if AutoCollectCash and firetouchinterest then
                for _, obj in ipairs(MyBase:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") then
                        local part = obj.Parent
                        if part and part:IsA("BasePart") then
                            local name = string.lower(part.Name)
                            local parentName = part.Parent and string.lower(part.Parent.Name) or ""

                            local isCash = string.find(name, "collect") or string.find(name, "giver") or string.find(name, "cash") or string.find(name, "money") or string.find(name, "claim") or string.find(name, "income")
                                        or string.find(parentName, "collect") or string.find(parentName, "giver") or string.find(parentName, "cash") or string.find(parentName, "money")

                            local isUpgrade = string.find(name, "buy") or string.find(name, "upgrade") or string.find(name, "purchase")
                                           or string.find(parentName, "buy") or string.find(parentName, "upgrade")

                            if isCash and not isUpgrade then
                                pcall(function()
                                    firetouchinterest(hrp, part, 0)
                                    task.wait(0.01)
                                    firetouchinterest(hrp, part, 1)
                                end)
                            end
                        end
                    end
                end
            end

            if AutoLockBase then
                for _, obj in ipairs(MyBase:GetDescendants()) do
                    local shouldTrigger = false

                    local name = string.lower(obj.Name)
                    if string.find(name, "lock") and not string.find(name, "unlock") then
                        shouldTrigger = true
                    end

                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local text = string.lower(obj.Text)
                        if (string.find(text, "lock") or string.find(text, "trancar")) and not string.find(text, "unlock") then
                            shouldTrigger = true
                            obj = obj.Parent
                        end
                    end

                    if shouldTrigger then
                        local touch = obj:FindFirstChildOfClass("TouchTransmitter") or (obj.Parent and obj.Parent:FindFirstChildOfClass("TouchTransmitter"))
                        local click = obj:FindFirstChildOfClass("ClickDetector") or (obj.Parent and obj.Parent:FindFirstChildOfClass("ClickDetector"))
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt") or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt"))

                        if touch and firetouchinterest then
                            pcall(function()
                                firetouchinterest(hrp, touch.Parent, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, touch.Parent, 1)
                            end)
                        end
                        if click and fireclickdetector then
                            pcall(function() fireclickdetector(click) end)
                        end
                        if prompt and fireproximityprompt then
                            pcall(function() fireproximityprompt(prompt) end)
                        end
                    end
                end
            end
        end
    end
end)

--========================================================--
-- EVENTOS DOS BOTÕES
--========================================================--

BaseButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    CharOverlay.Visible = false
    if BaseOverlay.Visible then
        BaseOverlay.Visible = false
    else
        UpdateBases()
        BaseOverlay.Visible = true
    end
end)

CharacterButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    if not SelectedBase then
        return Notify("Aviso", "Selecione uma base primeiro!", 3, CONFIG.Warning)
    end
    BaseOverlay.Visible = false
    if CharOverlay.Visible then
        CharOverlay.Visible = false
    else
        UpdateCharacters()
        CharOverlay.Visible = true
    end
end)

TimeoutPill.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    if StealTimeout == 5 then
        StealTimeout = 3
        TimeoutPill.Text = "⏱   TEMPO DE ESPERA  •  3s"
    else
        StealTimeout = 5
        TimeoutPill.Text = "⏱   TEMPO DE ESPERA  •  5s"
    end
end)

-- Speed
local speedConnection
function ApplySpeed()
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if not Humanoid then return end

    if SpeedEnabled then
        Humanoid.WalkSpeed = CONFIG.Speed
        if speedConnection then speedConnection:Disconnect() end
        speedConnection = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if SpeedEnabled and Humanoid.WalkSpeed ~= CONFIG.Speed then
                Humanoid.WalkSpeed = CONFIG.Speed
            end
        end)
    else
        if speedConnection then speedConnection:Disconnect() end
        Humanoid.WalkSpeed = 16
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed()
end)

-- Rejoin
RejoinButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    Notify("Reconectando...", "Conectando ao mesmo servidor...", 4, CONFIG.Info)
    task.wait(0.5)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

-- Server Hop
ServerHopButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    Notify("Mudar de Servidor", "Buscando servidores...", 3, CONFIG.Info)

    local Success, Response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
    end)

    if not Success then return Notify("Erro", "Falha ao carregar lista.", 4, CONFIG.Danger) end
    local SuccessDecode, Data = pcall(function() return HttpService:JSONDecode(Response) end)
    if not SuccessDecode or not Data then return Notify("Erro", "Erro ao processar dados.", 4, CONFIG.Danger) end

    local Available = {}
    for _, Server in ipairs(Data.data or {}) do
        if Server.id ~= game.JobId and Server.playing < Server.maxPlayers then
            table.insert(Available, Server.id)
        end
    end

    if #Available > 0 then
        local ServerId = Available[math.random(1, #Available)]
        Notify("Servidor Encontrado!", "Entrando...", 4, CONFIG.Success)
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, ServerId, LocalPlayer)
    else
        Notify("Servidores Cheios", "Nenhuma vaga no momento.", 4, CONFIG.Warning)
    end
end)

--========================================================--
-- STEAL LOGIC (INALTERADO)
--========================================================--

StealButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    if not SelectedBase then return Notify("Aviso", "Selecione uma base!", 3, CONFIG.Warning) end
    if not SelectedCharacter then return Notify("Aviso", "Selecione um personagem!", 3, CONFIG.Warning) end

    local Character = LocalPlayer.Character
    if not Character then return end

    local HRP = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local TargetHRP = SelectedCharacter:FindFirstChild("HumanoidRootPart")

    if not HRP or not Humanoid or not TargetHRP then return Notify("Erro", "Alvo não localizado.", 3, CONFIG.Danger) end

    PlaySound(SOUNDS.StealStart, 0.8)
    local OldCFrame = HRP.CFrame

    local Noclip = RunService.Stepped:Connect(function()
        if Character then
            for _, Part in ipairs(Character:GetDescendants()) do
                if Part:IsA("BasePart") then Part.CanCollide = false end
            end
        end
    end)

    Humanoid.PlatformStand = true
    HRP.CFrame = TargetHRP.CFrame * CFrame.new(0, 3, 6)

    local Gyro = Instance.new("BodyGyro")
    Gyro.MaxTorque = Vector3.new(400000, 400000, 400000)
    Gyro.P = 10000
    Gyro.Parent = HRP

    local Velocity = Instance.new("BodyVelocity")
    Velocity.MaxForce = Vector3.new(400000, 400000, 400000)
    Velocity.Velocity = Vector3.zero
    Velocity.Parent = HRP

    local Fly = RunService.Heartbeat:Connect(function()
        if TargetHRP and TargetHRP.Parent and HRP then
            Gyro.CFrame = CFrame.lookAt(HRP.Position, TargetHRP.Position) * CFrame.Angles(math.rad(-90), 0, 0)
        end
    end)

    local tickRate = 0.2
    local timeWaited = 0
    local isStealing = true

    task.spawn(function()
        for i = StealTimeout, 1, -1 do
            if not isStealing then break end
            Notify("⚡ ROUBANDO...", "Segure 'E' no alvo! Voltando em " .. i .. "s", 1, CONFIG.Warning)
            task.wait(1)
        end
    end)

    while timeWaited < StealTimeout do
        local hasToolInHand = Character:FindFirstChildOfClass("Tool")
        local targetGone = (not SelectedCharacter or not SelectedCharacter.Parent)

        if hasToolInHand or targetGone then break end
        task.wait(tickRate)
        timeWaited = timeWaited + tickRate
    end

    isStealing = false

    local MyBase = GetMyBase()
    if MyBase then
        local Collect = MyBase:FindFirstChild("StealCollect2")
        if Collect and Collect:IsA("BasePart") then
            HRP.CFrame = Collect.CFrame + Vector3.new(0, 3, 0)
        else
            HRP.CFrame = OldCFrame
        end
    else
        HRP.CFrame = OldCFrame
    end

    if Fly then Fly:Disconnect() end
    if Noclip then Noclip:Disconnect() end
    if Gyro then Gyro:Destroy() end
    if Velocity then Velocity:Destroy() end
    if Humanoid then Humanoid.PlatformStand = false end

    if Character then
        for _, Part in ipairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") then Part.CanCollide = true end
        end
    end

    ApplySpeed()
    PlaySound(SOUNDS.StealSuccess, 0.8)
    Notify("STEAL CONCLUÍDO!", "Retornando para a base...", 4, CONFIG.Success)
end)

--========================================================--
-- ABRIR / FECHAR
--========================================================--

local function OpenMenu()
    PlaySound(SOUNDS.Open, 0.5)
    MenuOpen = true
    Main.Visible = true
    Main.Size = UDim2.new(0, 500, 0, 320)
    Main.GroupTransparency = 1

    TweenService:Create(Main, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        Size = UDim2.new(0, 540, 0, 340)
    }):Play()

    TweenService:Create(FloatGrad, TweenInfo.new(0.3), {Rotation = 225}):Play()
end

local function CloseMenu()
    PlaySound(SOUNDS.Close, 0.5)
    MenuOpen = false
    BaseOverlay.Visible = false
    CharOverlay.Visible = false

    TweenService:Create(Main, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        GroupTransparency = 1,
        Size = UDim2.new(0, 500, 0, 320)
    }):Play()

    TweenService:Create(FloatGrad, TweenInfo.new(0.3), {Rotation = 45}):Play()

    task.delay(0.25, function()
        if not MenuOpen then Main.Visible = false end
    end)
end

Close.MouseButton1Click:Connect(CloseMenu)

Floating.MouseButton1Click:Connect(function()
    if not isDraggingAction then
        if MenuOpen then CloseMenu() else OpenMenu() end
    end
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.K then
        if MenuOpen then CloseMenu() else OpenMenu() end
    end
end)

-- Aplica speed inicial
task.spawn(function()
    task.wait(1)
    ApplySpeed()
end)
