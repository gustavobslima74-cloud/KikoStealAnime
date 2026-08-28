--========================================================--
--            KIKO ANIME STEAL (CLEAN V2 - FIXED)         --
--========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

--========================================================--
-- CONFIG
--========================================================--

local CONFIG = {
    Speed = 36,
    SpeedEnabled = true,

    Background = Color3.fromRGB(0, 0, 0),
    Element = Color3.fromRGB(15, 15, 15),
    Accent = Color3.fromRGB(120, 120, 120),

    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 170),

    Danger = Color3.fromRGB(255, 70, 70)
}

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
-- BOTÃO FLUTUANTE
--========================================================--

local Floating = Instance.new("TextButton")
Floating.Name = "FloatingButton"
Floating.Size = UDim2.new(0, 50, 0, 50)
Floating.Position = UDim2.new(1, -70, 0.4, -25)
Floating.BackgroundColor3 = CONFIG.Background
Floating.BorderSizePixel = 0
Floating.Text = "K"
Floating.TextColor3 = CONFIG.Text
Floating.TextSize = 22
Floating.Font = Enum.Font.GothamBold
Floating.AutoButtonColor = false
Floating.ZIndex = 500
Floating.Parent = ScreenGui

local FloatingCorner = Instance.new("UICorner")
FloatingCorner.CornerRadius = UDim.new(1, 0)
FloatingCorner.Parent = Floating

local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = CONFIG.Accent
FloatingStroke.Thickness = 2
FloatingStroke.Parent = Floating

--========================================================--
-- MENU
--========================================================--

local Menu = Instance.new("Frame")
Menu.Name = "MainMenu"
Menu.Size = UDim2.new(0, 280, 0, 350)
Menu.Position = UDim2.new(0.85, -140, 0.35, -175)
Menu.BackgroundColor3 = CONFIG.Background
Menu.BorderSizePixel = 0
Menu.ClipsDescendants = true
Menu.Visible = false
Menu.ZIndex = 100
Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 10)
MenuCorner.Parent = Menu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = CONFIG.Accent
MenuStroke.Thickness = 1
MenuStroke.Parent = Menu

--========================================================--
-- HEADER
--========================================================--

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = CONFIG.Element
Header.BorderSizePixel = 0
Header.ZIndex = 101
Header.Parent = Menu

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 10)
HeaderCorner.Parent = Header

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
-- CONTAINER
--========================================================--

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -52)
Content.Position = UDim2.new(0, 10, 0, 48)
Content.BackgroundTransparency = 1
Content.ZIndex = 101
Content.Parent = Menu

--========================================================--
-- BOTÃO PADRÃO
--========================================================--

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

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 7)
    Corner.Parent = Button

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CONFIG.Accent
    Stroke.Transparency = 0.5
    Stroke.Thickness = 1
    Stroke.Parent = Button

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

local StealButton = CreateButton("⚡ STEAL", 92)
local SpeedButton = CreateButton("⚡ SPEED: 36 | ON", 138)
local RejoinButton = CreateButton("↻ REJOIN SERVER", 184)
local ServerHopButton = CreateButton("🌐 MUDAR DE SERVIDOR", 230)

--========================================================--
-- VARIÁVEIS DE ESTADO
--========================================================--

local SelectedBase = nil
local SelectedCharacter = nil
local MenuOpen = false
local SpeedEnabled = true

--========================================================--
-- FUNÇÕES DE SUPORTE
--========================================================--

local function Notify(Text)
    print("[Kiko Anime Steal] " .. tostring(Text))
end

local function ClearList(List)
    for _, Object in ipairs(List:GetChildren()) do
        if Object:IsA("TextButton") then
            Object:Destroy()
        end
    end
end

local function ParseValueString(str)
    if not str then return 0 end
    local clean = string.gsub(str, "[%$%,%s]", "")
    local numStr, suffix = string.match(clean, "([%d%.]+)([KkMmBbTt]?)")
    if not numStr then return 0 end
    local num = tonumber(numStr) or 0
    suffix = string.upper(suffix or "")
    local multipliers = { [""] = 1, ["K"] = 1e3, ["M"] = 1e6, ["B"] = 1e9, ["T"] = 1e12 }
    return num * (multipliers[suffix] or 1)
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

local function GetCharacterValue(Character)
    if not Character then return nil end
    for _, Object in ipairs(Character:GetDescendants()) do
        if Object:IsA("TextLabel") or Object:IsA("TextButton") then
            local Text = Object.Text
            if Text and Text ~= "" and string.match(Text, "%d[%d%.]*[KkMmBbTt]?") then
                return Text
            end
        end
    end
    return nil
end

local function GetBaseHighestValue(Base)
    local highestValue = 0
    local highestString = ""
    local FolderNames = {"Characters", "RainbowCharacters", "CosmicCharacters"}
    for _, FolderName in ipairs(FolderNames) do
        local Folder = Base:FindFirstChild(FolderName)
        if Folder then
            for _, Character in ipairs(Folder:GetChildren()) do
                if Character:IsA("Model") then
                    local valStr = GetCharacterValue(Character)
                    local rawVal = ParseValueString(valStr)
                    if rawVal > highestValue then
                        highestValue = rawVal
                        highestString = valStr or ""
                    end
                end
            end
        end
    end
    return highestValue, highestString
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
            local maxRaw, maxStr = GetBaseHighestValue(Base)
            table.insert(Result, {
                Object = Base, Name = PlayerName,
                HighestRaw = maxRaw, HighestStr = maxStr
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
                    local valStr = GetCharacterValue(Character)
                    table.insert(Result, {
                        Object = Character, Name = Character.Name,
                        Folder = FolderName, Value = valStr,
                        RawValue = ParseValueString(valStr)
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
        if Data.HighestStr and Data.HighestStr ~= "" then
            DisplayName = DisplayName .. "  [Top: " .. Data.HighestStr .. "]"
        end

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
            SelectedBase = Data.Object
            SelectedCharacter = nil
            BaseButton.Text = "Base: " .. Data.Name
            CharacterButton.Text = "Selecionar Personagem"
            BaseList.Visible = false
            CharacterList.Visible = false
            Notify("Base selecionada: " .. Data.Name)
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
        if Data.Value then
            DisplayName = DisplayName .. "  [" .. Data.Value .. "]"
        end

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
            SelectedCharacter = Data.Object
            CharacterButton.Text = DisplayName
            CharacterList.Visible = false
            Notify("Personagem selecionado: " .. DisplayName)
        end)
    end
    CharacterList.CanvasSize = UDim2.new(0, 0, 0, CharacterLayout.AbsoluteContentSize.Y + 5)
end

--========================================================--
-- BOTÕES DE AÇÃO E LÓGICA
--========================================================--

BaseButton.MouseButton1Click:Connect(function()
    CharacterList.Visible = false
    BaseList.Visible = not BaseList.Visible
    if BaseList.Visible then UpdateBases() end
end)

CharacterButton.MouseButton1Click:Connect(function()
    if not SelectedBase then Notify("Selecione uma base primeiro.") return end
    BaseList.Visible = false
    CharacterList.Visible = not CharacterList.Visible
    if CharacterList.Visible then UpdateCharacters() end
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
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SpeedButton.Text = "⚡ SPEED: " .. CONFIG.Speed .. " | ON"
    else
        SpeedButton.Text = "⚡ SPEED: " .. CONFIG.Speed .. " | OFF"
    end
    ApplySpeed()
end)

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    ApplySpeed()
end)

RejoinButton.MouseButton1Click:Connect(function()
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

ServerHopButton.MouseButton1Click:Connect(function()
    Notify("Procurando servidor...")
    local Success, Response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100")
    end)
    if not Success then return end

    local SuccessDecode, Data = pcall(function() return HttpService:JSONDecode(Response) end)
    if not SuccessDecode or not Data then return end

    local Available = {}
    for _, Server in ipairs(Data.data or {}) do
        if Server.id ~= game.JobId and Server.playing < Server.maxPlayers then
            table.insert(Available, Server.id)
        end
    end
    if #Available > 0 then
        local ServerId = Available[math.random(1, #Available)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, ServerId, LocalPlayer)
    end
end)

StealButton.MouseButton1Click:Connect(function()
    if not SelectedBase then Notify("Selecione uma base.") return end
    if not SelectedCharacter then Notify("Selecione um personagem.") return end
    local Character = LocalPlayer.Character
    if not Character then return end

    local HRP = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local TargetHRP = SelectedCharacter:FindFirstChild("HumanoidRootPart")

    if not HRP or not Humanoid or not TargetHRP then Notify("Personagem sem RootPart.") return end
    Notify("Iniciando Steal...")
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

    task.wait(6)

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
    Notify("Steal finalizado.")
end)

--========================================================--
-- ABRIR / FECHAR MENU
--========================================================--

local function OpenMenu()
    MenuOpen = true
    Menu.Visible = true
    Menu.Size = UDim2.new(0, 280, 0, 0)
    TweenService:Create(Menu, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Size = UDim2.new(0, 280, 0, 350)}):Play()
end

local function CloseMenu()
    MenuOpen = false
    BaseList.Visible = false
    CharacterList.Visible = false
    TweenService:Create(Menu, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(0, 280, 0, 0)}):Play()
    task.delay(0.21, function()
        if not MenuOpen then Menu.Visible = false end
    end)
end

Close.MouseButton1Click:Connect(CloseMenu)

--========================================================--
-- ATALHO NO TECLADO (TECLA K)
--========================================================--

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.K then
        if MenuOpen then CloseMenu() else OpenMenu() end
    end
end)

--========================================================--
-- ARRASTAR O MENU LIVREMENTE
--========================================================--

local MenuDragging = false
local MenuDragStart, MenuStartPos

Header.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        MenuDragging = true
        MenuDragStart = Input.Position
        MenuStartPos = Menu.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if MenuDragging and (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
        local Delta = Input.Position - MenuDragStart
        Menu.Position = UDim2.new(
            MenuStartPos.X.Scale, MenuStartPos.X.Offset + Delta.X,
            MenuStartPos.Y.Scale, MenuStartPos.Y.Offset + Delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        MenuDragging = false
    end
end)

--========================================================--
-- ARRASTAR E CLICAR BOTÃO FLUTUANTE "K"
--========================================================--

local Dragging = false
local DragStart, StartPosition, HasMoved = false

Floating.InputBegan:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        Dragging = true
        HasMoved = false
        DragStart = Input.Position
        StartPosition = Floating.Position
    end
end)

UserInputService.InputChanged:Connect(function(Input)
    if not Dragging then return end
    if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
        local Delta = Input.Position - DragStart
        if Delta.Magnitude > 5 then
            HasMoved = true
            Floating.Position = UDim2.new(
                StartPosition.X.Scale, StartPosition.X.Offset + Delta.X,
                StartPosition.Y.Scale, StartPosition.Y.Offset + Delta.Y
            )
        end
    end
end)

Floating.InputEnded:Connect(function(Input)
    if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
        if Dragging then
            Dragging = false
            if not HasMoved then
                if MenuOpen then CloseMenu() else OpenMenu() end
            end
        end
    end
end)

--========================================================--
-- INICIALIZAÇÃO
--========================================================--

ApplySpeed()
print("Kiko Anime Steal - Versão v2 Atualizada e Carregada.")
