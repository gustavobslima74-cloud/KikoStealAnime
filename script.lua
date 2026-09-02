--========================================================--
--  KIKO ANIME STEAL (V6 - DRAGGABLE + AUTO COLLECT CASH) --
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
-- CONFIGURAÇÕES & CORES
--========================================================--

local CONFIG = {
    Speed = 36,
    SpeedEnabled = true,

    Background = Color3.fromRGB(12, 12, 12),
    Element = Color3.fromRGB(22, 22, 22),
    ElementHover = Color3.fromRGB(32, 32, 32),
    Accent = Color3.fromRGB(140, 140, 140),
    AccentGold = Color3.fromRGB(255, 200, 50),

    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(160, 160, 160),

    Success = Color3.fromRGB(75, 210, 125),
    Danger = Color3.fromRGB(255, 75, 75),
    Warning = Color3.fromRGB(255, 170, 40),
    Info = Color3.fromRGB(80, 160, 255)
}

-- EFEITOS SONOROS (ROBLOX SOUND IDs)
local SOUNDS = {
    Click = "rbxassetid://6895079853",
    Open = "rbxassetid://6895079853",
    Close = "rbxassetid://6895079853",
    RareFound = "rbxassetid://4612375232",
    StealStart = "rbxassetid://138090596",
    StealSuccess = "rbxassetid://2865227271",
    Notification = "rbxassetid://9119713951"
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
-- GUI INITIALIZATION
--========================================================--

pcall(function()
    local OldCore = game:GetService("CoreGui"):FindFirstChild("KikoAnimeSteal")
    if OldCore then OldCore:Destroy() end
    local OldPlayer = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("KikoAnimeSteal")
    if OldPlayer then OldPlayer:Destroy() end
end)

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KikoAnimeSteal"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local getHuiFunc = gethui or function() return game:GetService("CoreGui") end
local success = pcall(function()
    ScreenGui.Parent = getHuiFunc()
end)
if not success then
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

--========================================================--
-- SISTEMA DE NOTIFICAÇÕES (UI TOASTS)
--========================================================--

local NotifContainer = Instance.new("Frame")
NotifContainer.Name = "NotifContainer"
NotifContainer.Size = UDim2.new(0, 280, 1, -40)
NotifContainer.Position = UDim2.new(0, 10, 0, 20)
NotifContainer.BackgroundTransparency = 1
NotifContainer.ZIndex = 2000
NotifContainer.Parent = ScreenGui

local NotifLayout = Instance.new("UIListLayout")
NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifLayout.Padding = UDim.new(0, 8)
NotifLayout.Parent = NotifContainer

local function Notify(title, message, duration, themeColor, soundId)
    duration = duration or 4
    themeColor = themeColor or CONFIG.Info
    soundId = soundId or SOUNDS.Notification

    PlaySound(soundId, 0.6)

    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 0, 65)
    Toast.BackgroundColor3 = CONFIG.Background
    Toast.BorderSizePixel = 0
    Toast.BackgroundTransparency = 1
    Toast.ClipsDescendants = true
    Toast.Parent = NotifContainer

    local ToastCorner = Instance.new("UICorner")
    ToastCorner.CornerRadius = UDim.new(0, 8)
    ToastCorner.Parent = Toast

    local ToastStroke = Instance.new("UIStroke")
    ToastStroke.Color = themeColor
    ToastStroke.Thickness = 1.5
    ToastStroke.Transparency = 1
    ToastStroke.Parent = Toast

    local AccentBar = Instance.new("Frame")
    AccentBar.Size = UDim2.new(0, 4, 1, 0)
    AccentBar.BackgroundColor3 = themeColor
    AccentBar.BorderSizePixel = 0
    AccentBar.BackgroundTransparency = 1
    AccentBar.Parent = Toast

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -16, 0, 20)
    TitleLabel.Position = UDim2.new(0, 12, 0, 6)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = title
    TitleLabel.TextColor3 = themeColor
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 12
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.TextTransparency = 1
    TitleLabel.Parent = Toast

    local MsgLabel = Instance.new("TextLabel")
    MsgLabel.Size = UDim2.new(1, -16, 0, 34)
    MsgLabel.Position = UDim2.new(0, 12, 0, 24)
    MsgLabel.BackgroundTransparency = 1
    MsgLabel.Text = message
    MsgLabel.TextColor3 = CONFIG.Text
    MsgLabel.Font = Enum.Font.Gotham
    MsgLabel.TextSize = 10
    MsgLabel.TextWrapped = true
    MsgLabel.TextXAlignment = Enum.TextXAlignment.Left
    MsgLabel.TextTransparency = 1
    MsgLabel.Parent = Toast

    Toast.Position = UDim2.new(0, -50, 0, 0)
    
    local tweenInfo = TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    TweenService:Create(Toast, tweenInfo, {BackgroundTransparency = 0.05, Position = UDim2.new(0, 0, 0, 0)}):Play()
    TweenService:Create(ToastStroke, tweenInfo, {Transparency = 0.3}):Play()
    TweenService:Create(AccentBar, tweenInfo, {BackgroundTransparency = 0}):Play()
    TweenService:Create(TitleLabel, tweenInfo, {TextTransparency = 0}):Play()
    TweenService:Create(MsgLabel, tweenInfo, {TextTransparency = 0}):Play()

    task.delay(duration, function()
        if Toast and Toast.Parent then
            local fadeOut = TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            TweenService:Create(Toast, fadeOut, {BackgroundTransparency = 1, Position = UDim2.new(0, -60, 0, 0)}):Play()
            TweenService:Create(ToastStroke, fadeOut, {Transparency = 1}):Play()
            TweenService:Create(AccentBar, fadeOut, {BackgroundTransparency = 1}):Play()
            TweenService:Create(TitleLabel, fadeOut, {TextTransparency = 1}):Play()
            TweenService:Create(MsgLabel, fadeOut, {TextTransparency = 1}):Play()
            task.wait(0.32)
            Toast:Destroy()
        end
    end)
end

--========================================================--
-- BOTÃO FLUTUANTE (MÓVEL / ARRASTÁVEL)
--========================================================--

local Floating = Instance.new("TextButton")
Floating.Name = "FloatingButton"
Floating.Size = UDim2.new(0, 48, 0, 48)
Floating.Position = UDim2.new(1, -65, 0.4, -24)
Floating.BackgroundColor3 = CONFIG.Background
Floating.BorderSizePixel = 0
Floating.Text = "K"
Floating.TextColor3 = CONFIG.Text
Floating.TextSize = 22
Floating.Font = Enum.Font.GothamBold
Floating.AutoButtonColor = false
Floating.Active = true
Floating.ZIndex = 500
Floating.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(1, 0)
FloatingCorner.Parent = Floating

local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = CONFIG.Accent
FloatingStroke.Thickness = 2
FloatingStroke.Parent = Floating

local dragging
local dragInput
local dragStart
local startPos
local isDraggingAction = false 

Floating.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Floating.Position
        isDraggingAction = false
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
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
        if delta.Magnitude > 3 then 
            isDraggingAction = true 
        end
        Floating.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--========================================================--
-- MENU PRINCIPAL
--========================================================--

local MenuContainer = Instance.new("CanvasGroup")
MenuContainer.Name = "MainMenu"
MenuContainer.Size = UDim2.new(0, 280, 0, 440)
MenuContainer.Position = UDim2.new(0.85, -140, 0.35, -175)
MenuContainer.BackgroundColor3 = CONFIG.Background
MenuContainer.BorderSizePixel = 0
MenuContainer.GroupTransparency = 1
MenuContainer.Visible = false
MenuContainer.ZIndex = 100
MenuContainer.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = MenuContainer

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = CONFIG.Accent
MenuStroke.Thickness = 1
MenuStroke.Parent = MenuContainer

--========================================================--
-- HEADER
--========================================================--

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = CONFIG.Element
Header.BorderSizePixel = 0
Header.ZIndex = 101
Header.Parent = MenuContainer

Instance.new("UICorner", Header).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "KIKO ANIME STEAL"
Title.TextColor3 = CONFIG.Text
Title.Font = Enum.Font.GothamBold
Title.TextSize = 13
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 102
Title.Parent = Header

local Close = Instance.new("TextButton")
Close.Size = UDim2.new(0, 28, 0, 28)
Close.Position = UDim2.new(1, -35, 0, 7)
Close.BackgroundColor3 = CONFIG.Background
Close.BorderSizePixel = 0
Close.Text = "×"
Close.TextColor3 = CONFIG.Danger
Close.Font = Enum.Font.GothamBold
Close.TextSize = 18
Close.AutoButtonColor = false
Close.ZIndex = 103
Close.Parent = Header

Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

--========================================================--
-- CONTAINER DE CONTEÚDO
--========================================================--

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -52)
Content.Position = UDim2.new(0, 10, 0, 48)
Content.BackgroundTransparency = 1
Content.ZIndex = 101
Content.Parent = MenuContainer

local function CreateButton(Text, Y)
    local Button = Instance.new("TextButton")
    Button.Size = UDim2.new(1, 0, 0, 38)
    Button.Position = UDim2.new(0, 0, 0, Y)
    Button.BackgroundColor3 = CONFIG.Element
    Button.BorderSizePixel = 0
    Button.Text = Text
    Button.TextColor3 = CONFIG.Text
    Button.Font = Enum.Font.GothamSemibold
    Button.TextSize = 11
    Button.AutoButtonColor = false
    Button.ZIndex = 102
    Button.Parent = Content

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 7)

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CONFIG.Accent
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.ElementHover}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.Element}):Play()
    end)

    return Button
end

--========================================================--
-- ELEMENTOS DA INTERFACE
--========================================================--

local BaseButton = CreateButton("Selecionar Base", 0)

local BaseList = Instance.new("ScrollingFrame")
BaseList.Size = UDim2.new(1, 0, 0, 115)
BaseList.Position = UDim2.new(0, 0, 0, 39)
BaseList.BackgroundColor3 = CONFIG.Background
BaseList.BorderSizePixel = 0
BaseList.ScrollBarThickness = 3
BaseList.ScrollBarImageColor3 = CONFIG.Accent
BaseList.Visible = false
BaseList.ZIndex = 300
BaseList.Parent = Content

Instance.new("UICorner", BaseList).CornerRadius = UDim.new(0, 7)
local BaseLayout = Instance.new("UIListLayout")
BaseLayout.Padding = UDim.new(0, 1)
BaseLayout.Parent = BaseList

local CharacterButton = CreateButton("Selecionar Personagem", 46)

local CharacterList = Instance.new("ScrollingFrame")
CharacterList.Size = UDim2.new(1, 0, 0, 115)
CharacterList.Position = UDim2.new(0, 0, 0, 85)
CharacterList.BackgroundColor3 = CONFIG.Background
CharacterList.BorderSizePixel = 0
CharacterList.ScrollBarThickness = 3
CharacterList.ScrollBarImageColor3 = CONFIG.Accent
CharacterList.Visible = false
CharacterList.ZIndex = 300
CharacterList.Parent = Content

Instance.new("UICorner", CharacterList).CornerRadius = UDim.new(0, 7)
local CharacterLayout = Instance.new("UIListLayout")
CharacterLayout.Padding = UDim.new(0, 1)
CharacterLayout.Parent = CharacterList

-- BOTÕES RESTANTES
local StealButton = CreateButton("⚡ STEAL", 92)
local TimeoutButton = CreateButton("⏱️ TEMPO DE ESPERA: 5s", 138)
local AutoCollectButton = CreateButton("💰 AUTO COLLECT CASH: OFF", 184)
local SpeedButton = CreateButton("⚡ SPEED: 36 | ON", 230)
local RejoinButton = CreateButton("↻ REJOIN SERVER", 276)
local ServerHopButton = CreateButton("🌐 MUDAR DE SERVIDOR", 322)

--========================================================--
-- VARIÁVEIS DE ESTADO
--========================================================--

local SelectedBase = nil
local SelectedCharacter = nil
local MenuOpen = false
local SpeedEnabled = true
local DetectedExpensiveList = {}
local StealTimeout = 5
local AutoCollectCash = false

--========================================================--
-- FUNÇÕES DE SUPORTE
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

local function UpdateBases()
    ClearList(BaseList)
    local Bases = GetBases()
    for _, Data in ipairs(Bases) do
        local DisplayName = Data.Name
        local tagParts = {}
        if Data.HighestValStr ~= "" then table.insert(tagParts, Data.HighestValStr) end
        if Data.HighestIncStr ~= "" then table.insert(tagParts, Data.HighestIncStr) end
        if #tagParts > 0 then DisplayName = DisplayName .. "  [" .. table.concat(tagParts, " | ") .. "]" end

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -4, 0, 28)
        Button.BackgroundColor3 = CONFIG.Element
        Button.BorderSizePixel = 0
        Button.Text = "  " .. DisplayName
        Button.TextColor3 = CONFIG.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 10
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.AutoButtonColor = false
        Button.ZIndex = 301
        Button.Parent = BaseList
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)

        Button.MouseButton1Click:Connect(function()
            PlaySound(SOUNDS.Click, 0.5)
            SelectedBase = Data.Object
            SelectedCharacter = nil
            BaseButton.Text = "Base: " .. Data.Name
            CharacterButton.Text = "Selecionar Personagem"
            BaseList.Visible = false
            CharacterList.Visible = false
            Notify("Base Selecionada", Data.Name, 3, CONFIG.Info)
        end)
    end
    BaseList.CanvasSize = UDim2.new(0, 0, 0, BaseLayout.AbsoluteContentSize.Y + 5)
end

local function UpdateCharacters()
    ClearList(CharacterList)
    if not SelectedBase then return end

    local Characters = GetCharacters(SelectedBase)
    for _, Data in ipairs(Characters) do
        local DisplayName = Data.Name
        local tagParts = {}
        if Data.ValueStr then table.insert(tagParts, "Val: " .. Data.ValueStr) end
        if Data.IncomeStr then table.insert(tagParts, Data.IncomeStr) end
        if #tagParts > 0 then DisplayName = DisplayName .. "  [" .. table.concat(tagParts, " | ") .. "]" end

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -4, 0, 28)
        Button.BackgroundColor3 = CONFIG.Element
        Button.BorderSizePixel = 0
        Button.Text = "  " .. DisplayName
        Button.TextColor3 = CONFIG.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 10
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.AutoButtonColor = false
        Button.ZIndex = 301
        Button.Parent = CharacterList
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)

        Button.MouseButton1Click:Connect(function()
            PlaySound(SOUNDS.Click, 0.5)
            SelectedCharacter = Data.Object
            CharacterButton.Text = DisplayName
            CharacterList.Visible = false
            Notify("Personagem Selecionado", DisplayName, 3, CONFIG.Info)
        end)
    end
    CharacterList.CanvasSize = UDim2.new(0, 0, 0, CharacterLayout.AbsoluteContentSize.Y + 5)
end

task.spawn(function()
    while true do
        task.wait(10)
        pcall(function() GetBases() end)
    end
end)

--========================================================--
-- LOOP DE AUTO COLLECT CASH
--========================================================--

task.spawn(function()
    while true do
        task.wait(1)
        if AutoCollectCash and firetouchinterest then
            local character = LocalPlayer.Character
            local hrp = character and character:FindFirstChild("HumanoidRootPart")
            local MyBase = GetMyBase()
            
            if hrp and MyBase then
                -- Procura componentes 'TouchTransmitter' (Pads de contato) dentro da sua base
                for _, obj in ipairs(MyBase:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") then
                        local part = obj.Parent
                        if part and part:IsA("BasePart") then
                            local name = string.lower(part.Name)
                            local parentName = part.Parent and string.lower(part.Parent.Name) or ""
                            
                            -- Confirma se é de dinheiro
                            local isCash = string.find(name, "collect") or string.find(name, "giver") or string.find(name, "cash") or string.find(name, "money") or string.find(name, "claim") or string.find(name, "income")
                                        or string.find(parentName, "collect") or string.find(parentName, "giver") or string.find(parentName, "cash") or string.find(parentName, "money")
                                        
                            -- Evita comprar droppers/upgrades que gastem seu dinheiro
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
        end
    end
end)

--========================================================--
-- LÓGICA DE AÇÕES DOS BOTÕES
--========================================================--

BaseButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    CharacterList.Visible = false
    BaseList.Visible = not BaseList.Visible
    if BaseList.Visible then UpdateBases() end
end)

CharacterButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    if not SelectedBase then return Notify("Aviso", "Selecione uma base primeiro!", 3, CONFIG.Warning) end
    BaseList.Visible = false
    CharacterList.Visible = not CharacterList.Visible
    if CharacterList.Visible then UpdateCharacters() end
end)

TimeoutButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    if StealTimeout == 5 then
        StealTimeout = 3
        TimeoutButton.Text = "⏱️ TEMPO DE ESPERA: 3s"
    else
        StealTimeout = 5
        TimeoutButton.Text = "⏱️ TEMPO DE ESPERA: 5s"
    end
end)

AutoCollectButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    AutoCollectCash = not AutoCollectCash
    
    if AutoCollectCash then
        AutoCollectButton.Text = "💰 AUTO COLLECT CASH: ON"
        Notify("Auto Collect", "Coletando dinheiro na sua base...", 3, CONFIG.Success)
    else
        AutoCollectButton.Text = "💰 AUTO COLLECT CASH: OFF"
        Notify("Auto Collect", "Coleta desativada.", 3, CONFIG.Warning)
    end
end)

local speedConnection
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

SpeedButton.MouseButton1Click:Connect(function()
    PlaySound(SOUNDS.Click, 0.5)
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SpeedButton.Text = "⚡ SPEED: " .. CONFIG.Speed .. " | ON"
        Notify("Speed", "Velocidade ativada (" .. CONFIG.Speed .. ")", 2.5, CONFIG.Success)
    else
        SpeedButton.Text = "⚡ SPEED: " .. CONFIG.Speed .. " | OFF"
        Notify("Speed", "Velocidade desativada", 2.5, CONFIG.Warning)
    end
    ApplySpeed()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed()
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
-- STEAL LOGIC LIMPADO E SIMPLIFICADO
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

        if hasToolInHand or targetGone then
            break
        end

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
-- ANIMAÇÕES DO MENU E INTERAÇÕES (CLOSE/OPEN)
--========================================================--

local function OpenMenu()
    PlaySound(SOUNDS.Open, 0.5)
    MenuOpen = true
    MenuContainer.Visible = true
    MenuContainer.Size = UDim2.new(0, 280, 0, 390)
    MenuContainer.GroupTransparency = 1

    TweenService:Create(MenuContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        GroupTransparency = 0,
        Size = UDim2.new(0, 280, 0, 440)
    }):Play()
end

local function CloseMenu()
    PlaySound(SOUNDS.Close, 0.5)
    MenuOpen = false
    BaseList.Visible = false
    CharacterList.Visible = false

    TweenService:Create(MenuContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        GroupTransparency = 1,
        Size = UDim2.new(0, 280, 0, 390)
    }):Play()

    task.delay(0.25, function() if not MenuOpen then MenuContainer.Visible = false end end)
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
