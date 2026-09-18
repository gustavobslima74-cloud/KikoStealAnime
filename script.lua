--========================================================--
--  KIKO ANIME STEAL V9 - VERTICAL PROFISSIONAL            --
--========================================================--

local Players           = game:GetService("Players")
local TweenService      = game:GetService("TweenService")
local UserInputService  = game:GetService("UserInputService")
local RunService        = game:GetService("RunService")
local TeleportService   = game:GetService("TeleportService")
local HttpService       = game:GetService("HttpService")
local SoundService      = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer

--========================================================--
-- STATE (declarado ANTES de qualquer handler - fix do bug)
--========================================================--

local SelectedBase          = nil
local SelectedCharacter     = nil
local MenuOpen              = false
local SpeedEnabled          = true
local DetectedExpensiveList = {}
local StealTimeout          = 5
local AutoCollectCash       = false
local AutoLockBase          = false
local speedConnection       = nil

--========================================================--
-- CONFIG / PALETA
--========================================================--

local CONFIG = {
    Speed = 36,

    Background   = Color3.fromRGB(9, 9, 13),
    Surface      = Color3.fromRGB(18, 18, 25),
    SurfaceAlt   = Color3.fromRGB(24, 24, 32),
    SurfaceHover = Color3.fromRGB(30, 30, 41),
    Border       = Color3.fromRGB(40, 40, 54),

    Accent       = Color3.fromRGB(96, 148, 255),
    Accent2      = Color3.fromRGB(140, 180, 255),

    Text         = Color3.fromRGB(235, 235, 245),
    SubText      = Color3.fromRGB(128, 128, 150),

    Success      = Color3.fromRGB(80, 200, 130),
    Danger       = Color3.fromRGB(240, 80, 100),
    Warning      = Color3.fromRGB(255, 180, 60),
    Info         = Color3.fromRGB(96, 148, 255),
    Gold         = Color3.fromRGB(255, 200, 60),
}

local SOUNDS = {
    Click        = "rbxassetid://6895079853",
    Open         = "rbxassetid://6895079853",
    Close        = "rbxassetid://6895079853",
    RareFound    = "rbxassetid://4612375232",
    StealStart   = "rbxassetid://138090596",
    StealSuccess = "rbxassetid://2865227271",
    Notification = "rbxassetid://9119713951",
}

local function PlaySound(id, vol)
    task.spawn(function()
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId       = id
            s.Volume        = vol or 0.55
            s.PlayOnRemove  = true
            s.Parent        = SoundService
            s:Destroy()
        end)
    end)
end

--========================================================--
-- SPEED (definido cedo para ser usado em handlers)
--========================================================--

local function ApplySpeed()
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

--========================================================--
-- LIMPEZA
--========================================================--

pcall(function()
    local old = game:GetService("CoreGui"):FindFirstChild("KikoAnimeSteal")
    if old then old:Destroy() end
end)
pcall(function()
    local old = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("KikoAnimeSteal")
    if old then old:Destroy() end
end)

--========================================================--
-- SCREEN GUI
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name             = "KikoAnimeSteal"
ScreenGui.ResetOnSpawn     = false
ScreenGui.IgnoreGuiInset   = true
ScreenGui.ZIndexBehavior   = Enum.ZIndexBehavior.Sibling

pcall(function()
    ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--========================================================--
-- NOTIFICAÇÕES (TOASTS)
--========================================================--

local NotifBox = Instance.new("Frame")
NotifBox.Size = UDim2.new(0, 280, 1, -40)
NotifBox.Position = UDim2.new(1, -294, 0, 20)
NotifBox.BackgroundTransparency = 1
NotifBox.ZIndex = 2000
NotifBox.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment   = Enum.VerticalAlignment.Top
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
NotifLayout.Padding             = UDim.new(0, 8)
NotifLayout.SortOrder           = Enum.SortOrder.LayoutOrder
NotifLayout.Parent              = NotifBox

local function Notify(title, message, duration, color, soundId)
    duration = duration or 4
    color    = color or CONFIG.Info
    PlaySound(soundId or SOUNDS.Notification, 0.5)

    local toast = Instance.new("Frame")
    toast.Size = UDim2.new(1, 0, 0, 64)
    toast.BackgroundColor3 = CONFIG.Surface
    toast.BorderSizePixel = 0
    toast.BackgroundTransparency = 1
    toast.Position = UDim2.new(0, 50, 0, 0)
    toast.Parent = NotifBox
    Instance.new("UICorner", toast).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", toast)
    stroke.Color       = CONFIG.Border
    stroke.Thickness   = 1
    stroke.Transparency = 1

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 3, 1, -16)
    bar.Position = UDim2.new(0, 0, 0, 8)
    bar.BackgroundColor3 = color
    bar.BorderSizePixel = 0
    bar.BackgroundTransparency = 1
    bar.Parent = toast
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local tLbl = Instance.new("TextLabel")
    tLbl.Size = UDim2.new(1, -22, 0, 16)
    tLbl.Position = UDim2.new(0, 14, 0, 10)
    tLbl.BackgroundTransparency = 1
    tLbl.Text = title
    tLbl.TextColor3 = color
    tLbl.Font = Enum.Font.GothamBold
    tLbl.TextSize = 11
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.TextTransparency = 1
    tLbl.Parent = toast

    local mLbl = Instance.new("TextLabel")
    mLbl.Size = UDim2.new(1, -22, 0, 30)
    mLbl.Position = UDim2.new(0, 14, 0, 27)
    mLbl.BackgroundTransparency = 1
    mLbl.Text = message
    mLbl.TextColor3 = CONFIG.SubText
    mLbl.Font = Enum.Font.Gotham
    mLbl.TextSize = 10
    mLbl.TextWrapped = true
    mLbl.TextXAlignment = Enum.TextXAlignment.Left
    mLbl.TextYAlignment = Enum.TextYAlignment.Top
    mLbl.TextTransparency = 1
    mLbl.Parent = toast

    local ti = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(toast,  ti, {BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(stroke, ti, {Transparency = 0.2}):Play()
    TweenService:Create(bar,    ti, {BackgroundTransparency = 0}):Play()
    TweenService:Create(tLbl,   ti, {TextTransparency = 0}):Play()
    TweenService:Create(mLbl,   ti, {TextTransparency = 0}):Play()

    task.delay(duration, function()
        if toast and toast.Parent then
            local to = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            TweenService:Create(toast,  to, {BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 0)}):Play()
            TweenService:Create(stroke, to, {Transparency = 1}):Play()
            TweenService:Create(bar,    to, {BackgroundTransparency = 1}):Play()
            TweenService:Create(tLbl,   to, {TextTransparency = 1}):Play()
            TweenService:Create(mLbl,   to, {TextTransparency = 1}):Play()
            task.wait(0.32)
            toast:Destroy()
        end
    end)
end

--========================================================--
-- BOTÃO FLUTUANTE
--========================================================--

local Floating = Instance.new("TextButton")
Floating.Name            = "FloatingButton"
Floating.Size            = UDim2.new(0, 46, 0, 46)
Floating.Position        = UDim2.new(1, -62, 0.4, -23)
Floating.BackgroundColor3 = CONFIG.Surface
Floating.BorderSizePixel = 0
Floating.Text            = "K"
Floating.TextColor3      = CONFIG.Accent
Floating.TextSize        = 20
Floating.Font            = Enum.Font.GothamBlack
Floating.AutoButtonColor = false
Floating.Active          = true
Floating.ZIndex          = 500
Floating.Parent          = ScreenGui

Instance.new("UICorner", Floating).CornerRadius = UDim.new(1, 0)

local FloatStroke = Instance.new("UIStroke", Floating)
FloatStroke.Color        = CONFIG.Accent
FloatStroke.Thickness    = 1.5
FloatStroke.Transparency = 0.3

local dragging, dragInput, dragStart, startPos
local isDraggingAction = false

Floating.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
    or input.UserInputType == Enum.UserInputType.Touch then
        dragging          = true
        dragStart         = input.Position
        startPos          = Floating.Position
        isDraggingAction  = false
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Floating.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement
    or input.UserInputType == Enum.UserInputType.Touch then
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

Floating.MouseEnter:Connect(function()
    TweenService:Create(FloatStroke, TweenInfo.new(0.15), {Transparency = 0}):Play()
end)
Floating.MouseLeave:Connect(function()
    TweenService:Create(FloatStroke, TweenInfo.new(0.15), {Transparency = 0.3}):Play()
end)

--========================================================--
-- JANELA PRINCIPAL
--========================================================--

local WINDOW_W, WINDOW_H = 300, 500

local Main = Instance.new("Frame")
Main.Name = "MainWindow"
Main.Size = UDim2.new(0, WINDOW_W, 0, WINDOW_H)
Main.Position = UDim2.new(0.5, -WINDOW_W/2, 0.5, -WINDOW_H/2)
Main.BackgroundColor3 = CONFIG.Background
Main.BorderSizePixel = 0
Main.BackgroundTransparency = 1
Main.Visible = false
Main.ZIndex = 100
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)

local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = CONFIG.Border
MainStroke.Thickness = 1
MainStroke.Transparency = 1

-- Header
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 44)
Header.BackgroundColor3 = CONFIG.Surface
Header.BorderSizePixel = 0
Header.BackgroundTransparency = 1
Header.ZIndex = 101
Header.Parent = Main

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 12)

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = CONFIG.Border
HeaderLine.BorderSizePixel = 0
HeaderLine.BackgroundTransparency = 1
HeaderLine.ZIndex = 102
HeaderLine.Parent = Header

local AccentDot = Instance.new("Frame")
AccentDot.Size = UDim2.new(0, 6, 0, 6)
AccentDot.Position = UDim2.new(0, 14, 0.5, -3)
AccentDot.BackgroundColor3 = CONFIG.Accent
AccentDot.BorderSizePixel = 0
AccentDot.BackgroundTransparency = 1
AccentDot.ZIndex = 102
AccentDot.Parent = Header
Instance.new("UICorner", AccentDot).CornerRadius = UDim.new(1, 0)

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -70, 1, 0)
HeaderTitle.Position = UDim2.new(0, 28, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "KIKO ANIME STEAL"
HeaderTitle.TextColor3 = CONFIG.Text
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextSize = 12
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.TextTransparency = 1
HeaderTitle.ZIndex = 102
HeaderTitle.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -36, 0.5, -14)
Close.BackgroundColor3 = CONFIG.SurfaceAlt
Close.BackgroundTransparency = 1
Close.BorderSizePixel = 0
Close.Text = "✕"
Close.TextColor3 = CONFIG.SubText
Close.Font = Enum.Font.GothamBold
Close.TextSize = 12
Close.AutoButtonColor = false
Close.ZIndex = 103
Close.Parent = Header
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

Close.MouseEnter:Connect(function()
    TweenService:Create(Close, TweenInfo.new(0.15), {BackgroundTransparency = 0, TextColor3 = CONFIG.Danger}):Play()
end)
Close.MouseLeave:Connect(function()
    TweenService:Create(Close, TweenInfo.new(0.15), {BackgroundTransparency = 1, TextColor3 = CONFIG.SubText}):Play()
end)

-- Body (scrollable)
local Body = Instance.new("ScrollingFrame")
Body.Size = UDim2.new(1, -20, 1, -58)
Body.Position = UDim2.new(0, 10, 0, 50)
Body.BackgroundTransparency = 1
Body.BorderSizePixel = 0
Body.ScrollBarThickness = 3
Body.ScrollBarImageColor3 = CONFIG.Border
Body.CanvasSize = UDim2.new(0, 0, 0, 0)
Body.ScrollingDirection = Enum.ScrollingDirection.Y
Body.ZIndex = 101
Body.Parent = Main

local BodyLayout = Instance.new("UIListLayout", Body)
BodyLayout.Padding = UDim.new(0, 6)
BodyLayout.SortOrder = Enum.SortOrder.LayoutOrder

local BodyPad = Instance.new("UIPadding", Body)
BodyPad.PaddingTop = UDim.new(0, 4)
BodyPad.PaddingBottom = UDim.new(0, 12)

--========================================================--
-- HELPERS DE UI
--========================================================--

local orderCounter = 0
local function nextOrder()
    orderCounter = orderCounter + 1
    return orderCounter
end

local function Section(text)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 18)
    f.BackgroundTransparency = 1
    f.LayoutOrder = nextOrder()
    f.Parent = Body

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(0, 2, 0, 10)
    bar.Position = UDim2.new(0, 0, 0.5, -5)
    bar.BackgroundColor3 = CONFIG.Accent
    bar.BorderSizePixel = 0
    bar.Parent = f
    Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = string.upper(text)
    lbl.TextColor3 = CONFIG.SubText
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 9
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = f
end

local function Button(parent, text, height, opts)
    opts = opts or {}
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, height or 38)
    btn.BackgroundColor3 = opts.color or CONFIG.Surface
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = nextOrder()
    btn.Parent = parent

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = opts.stroke or CONFIG.Border
    stroke.Thickness = 1
    stroke.Transparency = opts.strokeTransparency or 0.4

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -24, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = opts.textColor or CONFIG.Text
    lbl.Font = opts.font or Enum.Font.GothamSemibold
    lbl.TextSize = opts.textSize or 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    if opts.chevron then
        local chev = Instance.new("TextLabel")
        chev.Size = UDim2.new(0, 20, 1, 0)
        chev.Position = UDim2.new(1, -26, 0, 0)
        chev.BackgroundTransparency = 1
        chev.Text = "›"
        chev.TextColor3 = CONFIG.SubText
        chev.Font = Enum.Font.GothamBold
        chev.TextSize = 14
        chev.Parent = btn
    end

    local hoverColor = opts.hoverColor or CONFIG.SurfaceHover
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = hoverColor}):Play()
        if not opts.accentFill then
            TweenService:Create(stroke, TweenInfo.new(0.15), {Color = CONFIG.Accent, Transparency = 0.6}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = opts.color or CONFIG.Surface}):Play()
        if not opts.accentFill then
            TweenService:Create(stroke, TweenInfo.new(0.15), {Color = opts.stroke or CONFIG.Border, Transparency = opts.strokeTransparency or 0.4}):Play()
        end
    end)

    return btn, lbl, stroke
end

local function Toggle(parent, label, initialState, onChange)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = CONFIG.Surface
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = nextOrder()
    btn.Parent = parent

    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

    local stroke = Instance.new("UIStroke", btn)
    stroke.Color = CONFIG.Border
    stroke.Thickness = 1
    stroke.Transparency = 0.4

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -70, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = CONFIG.Text
    lbl.Font = Enum.Font.GothamSemibold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = btn

    local track = Instance.new("Frame")
    track.Size = UDim2.new(0, 36, 0, 20)
    track.Position = UDim2.new(1, -48, 0.5, -10)
    track.BackgroundColor3 = CONFIG.SurfaceAlt
    track.BorderSizePixel = 0
    track.Parent = btn
    Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

    local trackStroke = Instance.new("UIStroke", track)
    trackStroke.Color = CONFIG.Border
    trackStroke.Thickness = 1
    trackStroke.Transparency = 0.3

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(0, 14, 0, 14)
    dot.Position = UDim2.new(0, 3, 0.5, -7)
    dot.BackgroundColor3 = CONFIG.SubText
    dot.BorderSizePixel = 0
    dot.Parent = track
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local state = initialState
    local function apply(on, silent)
        state = on
        local ti = TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
        if on then
            TweenService:Create(track, ti, {BackgroundColor3 = CONFIG.Accent}):Play()
            TweenService:Create(trackStroke, ti, {Color = CONFIG.Accent, Transparency = 0}):Play()
            TweenService:Create(dot, ti, {
                Position = UDim2.new(1, -17, 0.5, -7),
                BackgroundColor3 = Color3.new(1, 1, 1)
            }):Play()
        else
            TweenService:Create(track, ti, {BackgroundColor3 = CONFIG.SurfaceAlt}):Play()
            TweenService:Create(trackStroke, ti, {Color = CONFIG.Border, Transparency = 0.3}):Play()
            TweenService:Create(dot, ti, {
                Position = UDim2.new(0, 3, 0.5, -7),
                BackgroundColor3 = CONFIG.SubText
            }):Play()
        end
        if not silent and onChange then onChange(on) end
    end

    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.SurfaceHover}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Color = CONFIG.Accent, Transparency = 0.5}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Surface}):Play()
        TweenService:Create(stroke, TweenInfo.new(0.15), {Color = CONFIG.Border, Transparency = 0.4}):Play()
    end)

    btn.MouseButton1Click:Connect(function()
        PlaySound(SOUNDS.Click, 0.4)
        apply(not state)
    end)

    apply(initialState, true)
    return apply, lbl
end

--========================================================--
-- CONTEÚDO DO BODY
--========================================================--

Section("Seleção")
local BaseButton, BaseLabel           = Button(Body, "Selecionar Base",       40, {chevron = true})
local CharacterButton, CharacterLabel = Button(Body, "Selecionar Personagem", 40, {chevron = true})

Section("Ações")
local StealButton, StealLabel = Button(Body, "⚡  EXECUTAR STEAL", 42, {
    color = CONFIG.Accent,
    hoverColor = CONFIG.Accent2,
    stroke = CONFIG.Accent,
    strokeTransparency = 0.6,
    textColor = Color3.new(1, 1, 1),
    font = Enum.Font.GothamBold,
    textSize = 12,
    accentFill = true,
})

local TimeoutPill, TimeoutLabel = Button(Body, "⏱  Tempo de espera · 5s", 34, {
    color = CONFIG.SurfaceAlt,
    textColor = CONFIG.SubText,
    font = Enum.Font.Gotham,
    textSize = 10,
})

Section("Automação")
Toggle(Body, "💰  Auto Collect Cash", AutoCollectCash, function(on)
    AutoCollectCash = on
    if on then
        Notify("Auto Collect", "Coleta de dinheiro ativada.", 3, CONFIG.Success)
    else
        Notify("Auto Collect", "Coleta desativada.", 3, CONFIG.Warning)
    end
end)

Toggle(Body, "🔒  Auto Lock Base", AutoLockBase, function(on)
    AutoLockBase = on
    if on then
        Notify("Auto Lock", "Sua base ficará trancada.", 3, CONFIG.Success)
    else
        Notify("Auto Lock", "Auto Lock desativado.", 3, CONFIG.Warning)
    end
end)

Section("Sistema")
Toggle(Body, "⚡  Speed Boost (36)", SpeedEnabled, function(on)
    SpeedEnabled = on
    if on then
        Notify("Speed", "Velocidade ativada (" .. CONFIG.Speed .. ")", 2.5, CONFIG.Success)
    else
        Notify("Speed", "Velocidade desativada", 2.5, CONFIG.Warning)
    end
    ApplySpeed()
end)

local RejoinButton    = Button(Body, "↻  Rejoin Server",     38, {chevron = true})
local ServerHopButton = Button(Body, "🌐  Mudar de Servidor", 38, {chevron = true})

BodyLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    Body.CanvasSize = UDim2.new(0, 0, 0, BodyLayout.AbsoluteContentSize.Y + 20)
end)
task.defer(function()
    Body.CanvasSize = UDim2.new(0, 0, 0, BodyLayout.AbsoluteContentSize.Y + 20)
end)

--========================================================--
-- OVERLAYS (Base / Personagem)
--========================================================--

local function BuildOverlay(name, title)
    local ov = Instance.new("Frame")
    ov.Name = name
    ov.Size = UDim2.new(1, -20, 1, -58)
    ov.Position = UDim2.new(0, 10, 0, 50)
    ov.BackgroundColor3 = CONFIG.Background
    ov.BorderSizePixel = 0
    ov.Visible = false
    ov.ZIndex = 300
    ov.Parent = Main
    Instance.new("UICorner", ov).CornerRadius = UDim.new(0, 8)

    local bar = Instance.new("Frame")
    bar.Size = UDim2.new(1, 0, 0, 32)
    bar.BackgroundColor3 = CONFIG.Surface
    bar.BorderSizePixel = 0
    bar.ZIndex = 301
    bar.Parent = ov
    Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 8)

    local fixBottom = Instance.new("Frame")
    fixBottom.Size = UDim2.new(1, 0, 0, 10)
    fixBottom.Position = UDim2.new(0, 0, 1, -10)
    fixBottom.BackgroundColor3 = CONFIG.Surface
    fixBottom.BorderSizePixel = 0
    fixBottom.ZIndex = 301
    fixBottom.Parent = bar

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Size = UDim2.new(1, -50, 1, 0)
    titleLbl.Position = UDim2.new(0, 12, 0, 0)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Text = title
    titleLbl.TextColor3 = CONFIG.Text
    titleLbl.Font = Enum.Font.GothamBold
    titleLbl.TextSize = 11
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 302
    titleLbl.Parent = bar

    local back = Instance.new("TextButton")
    back.Size = UDim2.new(0, 24, 0, 24)
    back.Position = UDim2.new(1, -30, 0.5, -12)
    back.BackgroundColor3 = CONFIG.SurfaceAlt
    back.BorderSizePixel = 0
    back.Text = "←"
    back.TextColor3 = CONFIG.Text
    back.Font = Enum.Font.GothamBold
    back.TextSize = 12
    back.AutoButtonColor = false
    back.ZIndex = 302
    back.Parent = bar
    Instance.new("UICorner", back).CornerRadius = UDim.new(0, 6)

    local list = Instance.new("ScrollingFrame")
    list.Size = UDim2.new(1, -8, 1, -44)
    list.Position = UDim2.new(0, 4, 0, 38)
    list.BackgroundTransparency = 1
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 3
    list.ScrollBarImageColor3 = CONFIG.Border
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.ZIndex = 302
    list.Parent = ov

    local layout = Instance.new("UIListLayout", list)
    layout.Padding   = UDim.new(0, 4)
    layout.SortOrder = Enum.SortOrder.LayoutOrder

    back.MouseButton1Click:Connect(function()
        PlaySound(SOUNDS.Click, 0.4)
        ov.Visible = false
    end)

    return ov, list, layout, titleLbl
end

local BaseOverlay, BaseList, BaseLayout, BaseHeader = BuildOverlay("BaseOverlay", "Bases Disponíveis")
local CharOverlay, CharList, CharLayout, CharHeader = BuildOverlay("CharOverlay", "Personagens")

--========================================================--
-- FUNÇÕES DE SUPORTE
--========================================================--

local function ClearList(list)
    for _, obj in ipairs(list:GetChildren()) do
        if obj:IsA("TextButton") then obj:Destroy() end
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
    local mult = { [""] = 1, ["K"] = 1e3, ["M"] = 1e6, ["B"] = 1e9, ["T"] = 1e12 }
    return num * (mult[suffix] or 1)
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
    return valueStr, incomeStr, ParseValueString(valueStr), ParseValueString(incomeStr)
end

local function MatchesPlayer(text)
    if not text then return false end
    local lower    = string.lower(text)
    local pName    = string.lower(LocalPlayer.Name)
    local pDisplay = string.lower(LocalPlayer.DisplayName)
    return string.find(lower, pName, 1, true) ~= nil
        or string.find(lower, pDisplay, 1, true) ~= nil
end

local function GetMyBase()
    local Bases = workspace:FindFirstChild("Bases")
    if not Bases then return nil end
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
    return nil
end

local function GetBaseHighestValue(Base)
    local highest, valStr, incStr = 0, "", ""
    for _, folderName in ipairs({"Characters", "RainbowCharacters", "CosmicCharacters"}) do
        local folder = Base:FindFirstChild(folderName)
        if folder then
            for _, Character in ipairs(folder:GetChildren()) do
                if Character:IsA("Model") then
                    local vs, is_, rawVal = GetCharacterStats(Character)
                    if rawVal > highest then
                        highest = rawVal
                        valStr  = vs or ""
                        incStr  = is_ or ""
                    end
                end
            end
        end
    end
    return highest, valStr, incStr
end

local function CheckExpensiveAnimes(baseName, baseObject)
    for _, folderName in ipairs({"Characters", "RainbowCharacters", "CosmicCharacters"}) do
        local folder = baseObject:FindFirstChild(folderName)
        if folder then
            for _, Character in ipairs(folder:GetChildren()) do
                if Character:IsA("Model") then
                    local vs, is_, rawVal, rawInc = GetCharacterStats(Character)
                    if rawVal >= 1e8 or rawInc >= 1e8 then
                        local id = Character:GetDebugId()
                        if not DetectedExpensiveList[id] then
                            DetectedExpensiveList[id] = true
                            local detail = "Base: " .. baseName .. "\nItem: " .. Character.Name
                            if vs then detail = detail .. "\nValor: " .. vs end
                            if is_ then detail = detail .. " (" .. is_ .. ")" end
                            Notify("🔥 ANIME RARO!", detail, 7, CONFIG.Gold, SOUNDS.RareFound)
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
        local playerName
        local Sign = Base:FindFirstChild("Sign")
        if Sign then
            local SignPart = Sign:FindFirstChild("SignPart")
            if SignPart then
                local SurfaceGui = SignPart:FindFirstChild("SurfaceGui")
                if SurfaceGui then
                    local Label = SurfaceGui:FindFirstChild("TextLabel")
                    if Label then
                        playerName = string.match(Label.Text, "(.+)'s [Bb]ase") or Label.Text
                    end
                end
            end
        end
        if playerName and playerName ~= "" then
            local maxRaw, maxValStr, maxIncStr = GetBaseHighestValue(Base)
            CheckExpensiveAnimes(playerName, Base)
            table.insert(Result, {
                Object = Base, Name = playerName,
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
    for _, folderName in ipairs({"Characters", "RainbowCharacters", "CosmicCharacters"}) do
        local folder = Base:FindFirstChild(folderName)
        if folder then
            for _, Character in ipairs(folder:GetChildren()) do
                if Character:IsA("Model") then
                    local vs, is_, rawVal, rawInc = GetCharacterStats(Character)
                    table.insert(Result, {
                        Object = Character, Name = Character.Name,
                        ValueStr = vs, IncomeStr = is_,
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
-- POPULAR LISTAS
--========================================================--

local function UpdateBases()
    ClearList(BaseList)
    BaseHeader.Text = "Bases Disponíveis (" .. #GetBases() .. ")"
    local Bases = GetBases()
    for _, Data in ipairs(Bases) do
        local displayName = Data.Name
        local tags = {}
        if Data.HighestValStr ~= "" then table.insert(tags, Data.HighestValStr) end
        if Data.HighestIncStr ~= "" then table.insert(tags, Data.HighestIncStr) end
        if #tags > 0 then displayName = displayName .. "  [" .. table.concat(tags, " | ") .. "]" end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 34)
        btn.BackgroundColor3 = CONFIG.Surface
        btn.BorderSizePixel = 0
        btn.Text = "  " .. displayName
        btn.TextColor3 = CONFIG.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.ZIndex = 302
        btn.Parent = BaseList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.SurfaceHover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Surface}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            PlaySound(SOUNDS.Click, 0.5)
            SelectedBase = Data.Object
            SelectedCharacter = nil
            BaseLabel.Text = Data.Name
            CharacterLabel.Text = "Selecionar Personagem"
            BaseOverlay.Visible = false
            Notify("Base Selecionada", Data.Name, 3, CONFIG.Info)
        end)
    end
    BaseList.CanvasSize = UDim2.new(0, 0, 0, BaseLayout.AbsoluteContentSize.Y + 10)
end

local function UpdateCharacters()
    ClearList(CharList)
    if not SelectedBase then return end
    local Characters = GetCharacters(SelectedBase)
    CharHeader.Text = "Personagens (" .. #Characters .. ")"
    for _, Data in ipairs(Characters) do
        local displayName = Data.Name
        local tags = {}
        if Data.ValueStr then table.insert(tags, "Val: " .. Data.ValueStr) end
        if Data.IncomeStr then table.insert(tags, Data.IncomeStr) end
        if #tags > 0 then displayName = displayName .. "  [" .. table.concat(tags, " | ") .. "]" end

        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -8, 0, 34)
        btn.BackgroundColor3 = CONFIG.Surface
        btn.BorderSizePixel = 0
        btn.Text = "  " .. displayName
        btn.TextColor3 = CONFIG.Text
        btn.Font = Enum.Font.Gotham
        btn.TextSize = 10
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.AutoButtonColor = false
        btn.ZIndex = 302
        btn.Parent = CharList
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.SurfaceHover}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Surface}):Play()
        end)

        btn.MouseButton1Click:Connect(function()
            PlaySound(SOUNDS.Click, 0.5)
            SelectedCharacter = Data.Object
            CharacterLabel.Text = Data.Name
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
-- LOOP: AUTO COLLECT & AUTO LOCK
-- (lógica original mantida — agora as vars são atualizadas
--  corretamente pelos closures acima)
--========================================================--

task.spawn(function()
    while true do
        task.wait(1)

        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")
        local MyBase = GetMyBase()

        if hrp and MyBase then
            -- AUTO COLLECT
            if AutoCollectCash and firetouchinterest then
                for _, obj in ipairs(MyBase:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") then
                        local part = obj.Parent
                        if part and part:IsA("BasePart") then
                            local name       = string.lower(part.Name)
                            local parentName = part.Parent and string.lower(part.Parent.Name) or ""

                            local isCash = string.find(name, "collect")
                                        or string.find(name, "giver")
                                        or string.find(name, "cash")
                                        or string.find(name, "money")
                                        or string.find(name, "claim")
                                        or string.find(name, "income")
                                        or string.find(parentName, "collect")
                                        or string.find(parentName, "giver")
                                        or string.find(parentName, "cash")
                                        or string.find(parentName, "money")

                            local isUpgrade = string.find(name, "buy")
                                           or string.find(name, "upgrade")
                                           or string.find(name, "purchase")
                                           or string.find(parentName, "buy")
                                           or string.find(parentName, "upgrade")

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

            -- AUTO LOCK
            if AutoLockBase then
                for _, obj in ipairs(MyBase:GetDescendants()) do
                    local shouldTrigger = false
                    local name = string.lower(obj.Name)
                    if string.find(name, "lock") and not string.find(name, "unlock") then
                        shouldTrigger = true
                    end

                    if obj:IsA("TextLabel") or obj:IsA("TextButton") then
                        local text = string.lower(obj.Text)
                        if (string.find(text, "lock") or string.find(text, "trancar"))
                        and not string.find(text, "unlock") then
                            shouldTrigger = true
                            obj = obj.Parent
                        end
                    end

                    if shouldTrigger then
                        local touch  = obj:FindFirstChildOfClass("TouchTransmitter")
                                    or (obj.Parent and obj.Parent:FindFirstChildOfClass("TouchTransmitter"))
                        local click  = obj:FindFirstChildOfClass("ClickDetector")
                                    or (obj.Parent and obj.Parent:FindFirstChildOfClass("ClickDetector"))
                        local prompt = obj:FindFirstChildOfClass("ProximityPrompt")
                                    or (obj.Parent and obj.Parent:FindFirstChildOfClass("ProximityPrompt"))

                        if touch and firetouchinterest then
                            pcall(function()
                                firetouchinterest(hrp, touch.Parent, 0)
                                task.wait(0.01)
                                firetouchinterest(hrp, touch.Parent, 1)
                            end)
                        end
                        if click  and fireclickdetector    then pcall(function() fireclickdetector(click) end)       end
                        if prompt and fireproximityprompt  then pcall(function() fireproximityprompt(prompt) end)   end
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
        TimeoutLabel.Text = "⏱  Tempo de espera · 3s"
    else
        StealTimeout = 5
        TimeoutLabel.Text = "⏱  Tempo de espera · 5s"
    end
end)

RejoinButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    Notify("Reconectando...", "Conectando ao mesmo servidor...", 4, CONFIG.Info)
    task.wait(0.5)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

ServerHopButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    Notify("Mudar de Servidor", "Buscando servidores...", 3, CONFIG.Info)

    local ok, response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
    end)
    if not ok then return Notify("Erro", "Falha ao carregar lista.", 4, CONFIG.Danger) end

    local ok2, data = pcall(function() return HttpService:JSONDecode(response) end)
    if not ok2 or not data then return Notify("Erro", "Erro ao processar dados.", 4, CONFIG.Danger) end

    local available = {}
    for _, server in ipairs(data.data or {}) do
        if server.id ~= game.JobId and server.playing < server.maxPlayers then
            table.insert(available, server.id)
        end
    end

    if #available > 0 then
        local id = available[math.random(1, #available)]
        Notify("Servidor Encontrado!", "Entrando...", 4, CONFIG.Success)
        task.wait(0.5)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, id, LocalPlayer)
    else
        Notify("Servidores Cheios", "Nenhuma vaga no momento.", 4, CONFIG.Warning)
    end
end)

--========================================================--
-- STEAL LOGIC
--========================================================--

StealButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    if not SelectedBase      then return Notify("Aviso", "Selecione uma base!", 3, CONFIG.Warning) end
    if not SelectedCharacter then return Notify("Aviso", "Selecione um personagem!", 3, CONFIG.Warning) end

    local Character = LocalPlayer.Character
    if not Character then return end

    local HRP       = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid  = Character:FindFirstChildOfClass("Humanoid")
    local TargetHRP = SelectedCharacter:FindFirstChild("HumanoidRootPart")

    if not HRP or not Humanoid or not TargetHRP then
        return Notify("Erro", "Alvo não localizado.", 3, CONFIG.Danger)
    end

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

    local tickRate, timeWaited, isStealing = 0.2, 0, true

    task.spawn(function()
        for i = StealTimeout, 1, -1 do
            if not isStealing then break end
            Notify("⚡ ROUBANDO...", "Segure 'E' no alvo! Voltando em " .. i .. "s", 1, CONFIG.Warning)
            task.wait(1)
        end
    end)

    while timeWaited < StealTimeout do
        local hasTool   = Character:FindFirstChildOfClass("Tool")
        local targetGone = (not SelectedCharacter or not SelectedCharacter.Parent)
        if hasTool or targetGone then break end
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

    if Fly      then Fly:Disconnect()      end
    if Noclip   then Noclip:Disconnect()   end
    if Gyro     then Gyro:Destroy()        end
    if Velocity then Velocity:Destroy()    end
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

    local ti = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)

    TweenService:Create(Main,       ti, {BackgroundTransparency = 0}):Play()
    TweenService:Create(MainStroke, ti, {Transparency = 0.2}):Play()
    TweenService:Create(Header,     ti, {BackgroundTransparency = 0}):Play()
    TweenService:Create(HeaderLine, ti, {BackgroundTransparency = 0.4}):Play()
    TweenService:Create(AccentDot,  ti, {BackgroundTransparency = 0}):Play()
    TweenService:Create(HeaderTitle,ti, {TextTransparency = 0}):Play()
end

local function CloseMenu()
    PlaySound(SOUNDS.Close, 0.5)
    MenuOpen = false
    BaseOverlay.Visible = false
    CharOverlay.Visible = false

    local to = TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)

    TweenService:Create(Main,       to, {BackgroundTransparency = 1}):Play()
    TweenService:Create(MainStroke, to, {Transparency = 1}):Play()
    TweenService:Create(Header,     to, {BackgroundTransparency = 1}):Play()
    TweenService:Create(HeaderLine, to, {BackgroundTransparency = 1}):Play()
    TweenService:Create(AccentDot,  to, {BackgroundTransparency = 1}):Play()
    TweenService:Create(HeaderTitle,to, {TextTransparency = 1}):Play()

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

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed()
end)

task.spawn(function()
    task.wait(1)
    ApplySpeed()
end)
