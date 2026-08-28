--========================================================--
--          KIKO ANIME STEAL (FULL ULTIMATE V2)          --
--========================================================--

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

-- DETECÇÃO UNIVERSAL DE INTERFACE (Previne crash e garante injeção)
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

-- Limpar execuções antigas
for _, child in ipairs(ParentGui:GetChildren()) do
    if child.Name == "KikoAnimeSteal" then
        child:Destroy()
    end
end

--========================================================--
-- CONFIGURAÇÕES E ASSETS (SEM IMAGENS CRASHÁVEIS)
--========================================================--

local CONFIG = {
    Speed = 36,
    SpeedEnabled = true,

    Background = Color3.fromRGB(15, 15, 20),
    Element = Color3.fromRGB(25, 25, 35),
    Accent = Color3.fromRGB(140, 90, 255),

    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 190),

    Danger = Color3.fromRGB(255, 70, 70),
    Success = Color3.fromRGB(70, 255, 140),
    Warning = Color3.fromRGB(255, 190, 60)
}

local SOUNDS = {
    Click = "rbxassetid://6895079853",
    Notify = "rbxassetid://6029745131",
    RareFound = "rbxassetid://9069609257",
    StealStart = "rbxassetid://5419098670"
}

local function PlaySFX(soundId)
    task.spawn(function()
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = soundId
            sound.Volume = 0.6
            sound.Parent = workspace
            sound:Play()
            sound.Ended:Connect(function() sound:Destroy() end)
        end)
    end)
end

--========================================================--
-- GUI BASE
--========================================================--

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KikoAnimeSteal"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = ParentGui

--========================================================--
-- SISTEMA DE NOTIFICAÇÕES VISUAIS
--========================================================--

local NotifyContainer = Instance.new("Frame")
NotifyContainer.Name = "NotifyContainer"
NotifyContainer.Size = UDim2.new(0, 280, 1, -40)
NotifyContainer.Position = UDim2.new(1, -290, 0, 20)
NotifyContainer.BackgroundTransparency = 1
NotifyContainer.ZIndex = 9000
NotifyContainer.Parent = ScreenGui

local NotifyLayout = Instance.new("UIListLayout")
NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifyLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifyLayout.Padding = UDim.new(0, 8)
NotifyLayout.Parent = NotifyContainer

local function CustomNotify(TitleText, MessageText, Duration, AccentColor, SoundAsset)
    Duration = Duration or 4
    AccentColor = AccentColor or CONFIG.Accent
    if SoundAsset then PlaySFX(SoundAsset) else PlaySFX(SOUNDS.Notify) end

    local Toast = Instance.new("Frame")
    Toast.Size = UDim2.new(1, 0, 0, 0)
    Toast.BackgroundColor3 = CONFIG.Background
    Toast.BorderSizePixel = 0
    Toast.ClipsDescendants = true
    Toast.ZIndex = 9001
    Toast.Parent = NotifyContainer

    Instance.new("UICorner", Toast).CornerRadius = UDim.new(0, 8)
    
    local ToastStroke = Instance.new("UIStroke")
    ToastStroke.Color = AccentColor
    ToastStroke.Thickness = 1.5
    ToastStroke.Parent = Toast

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -20, 0, 20)
    TitleLbl.Position = UDim2.new(0, 10, 0, 8)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Text = TitleText
    TitleLbl.TextColor3 = AccentColor
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.ZIndex = 9002
    TitleLbl.Parent = Toast

    local MsgLbl = Instance.new("TextLabel")
    MsgLbl.Size = UDim2.new(1, -20, 0, 30)
    MsgLbl.Position = UDim2.new(0, 10, 0, 26)
    MsgLbl.BackgroundTransparency = 1
    MsgLbl.Text = MessageText
    MsgLbl.TextColor3 = CONFIG.Text
    MsgLbl.Font = Enum.Font.Gotham
    MsgLbl.TextSize = 11
    MsgLbl.TextWrapped = true
    MsgLbl.TextXAlignment = Enum.TextXAlignment.Left
    MsgLbl.ZIndex = 9002
    MsgLbl.Parent = Toast

    TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(1, 0, 0, 65)}):Play()

    task.delay(Duration, function()
        if Toast and Toast.Parent then
            local TweenOut = TweenService:Create(Toast, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Size = UDim2.new(1, 0, 0, 0)})
            TweenOut:Play()
            TweenOut.Completed:Connect(function() Toast:Destroy() end)
        end
    end)
end

--========================================================--
-- BOTÃO FLUTUANTE (TEXTO K)
--========================================================--

local Floating = Instance.new("TextButton")
Floating.Name = "FloatingButton"
Floating.Size = UDim2.new(0, 52, 0, 52)
Floating.Position = UDim2.new(1, -70, 0.4, -26)
Floating.BackgroundColor3 = CONFIG.Background
Floating.BorderSizePixel = 0
Floating.Text = "K"
Floating.TextColor3 = CONFIG.Accent
Floating.Font = Enum.Font.GothamBold
Floating.TextSize = 22
Floating.ZIndex = 9999
Floating.Active = true
Floating.Parent = ScreenGui

Instance.new("UICorner", Floating).CornerRadius = UDim.new(1, 0)
local FloatingStroke = Instance.new("UIStroke")
FloatingStroke.Color = CONFIG.Accent
FloatingStroke.Thickness = 2
FloatingStroke.Parent = Floating

--========================================================--
-- MENU E ESTRUTURA
--========================================================--

local Menu = Instance.new("Frame")
Menu.Name = "MainMenu"
Menu.Size = UDim2.new(0, 280, 0, 0)
Menu.Position = UDim2.new(0.5, -140, 0.5, -160)
Menu.BackgroundColor3 = CONFIG.Background
Menu.BorderSizePixel = 0
Menu.ClipsDescendants = true
Menu.Visible = false
Menu.ZIndex = 10000
Menu.Parent = ScreenGui

Instance.new("UICorner", Menu).CornerRadius = UDim.new(0, 10)
local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = CONFIG.Accent
MenuStroke.Thickness = 1.5
MenuStroke.Parent = Menu

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = CONFIG.Element
Header.BorderSizePixel = 0
Header.ZIndex = 10001
Header.Active = true
Header.Parent = Menu

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
Title.ZIndex = 10002
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
Close.ZIndex = 10003
Close.Parent = Header
Instance.new("UICorner", Close).CornerRadius = UDim.new(0, 6)

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, -20, 1, -52)
Content.Position = UDim2.new(0, 10, 0, 48)
Content.BackgroundTransparency = 1
Content.ZIndex = 10001
Content.Parent = Menu

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
    Button.ZIndex = 10002
    Button.Parent = Content

    Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 7)
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = CONFIG.Accent
    Stroke.Transparency = 0.6
    Stroke.Thickness = 1
    Stroke.Parent = Button

    Button.MouseEnter:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
    end)
    Button.MouseLeave:Connect(function()
        TweenService:Create(Button, TweenInfo.new(0.15), {BackgroundColor3 = CONFIG.Element}):Play()
    end)

    return Button
end

local BaseButton = CreateButton("Selecionar Base", 0)
local BaseList = Instance.new("ScrollingFrame")
BaseList.Size = UDim2.new(1, 0, 0, 115)
BaseList.Position = UDim2.new(0, 0, 0, 39)
BaseList.BackgroundColor3 = CONFIG.Background
BaseList.BorderSizePixel = 0
BaseList.ScrollBarThickness = 3
BaseList.ScrollBarImageColor3 = CONFIG.Accent
BaseList.Visible = false
BaseList.ZIndex = 10500
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
CharacterList.ZIndex = 10500
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
-- LÓGICA DE DADOS & SCANNER 100M+
--========================================================--

local SelectedBase = nil
local SelectedCharacter = nil
local MenuOpen = false
local SpeedEnabled = true
local NotifiedBases = {}

local function ClearList(List)
    for _, Object in ipairs(List:GetChildren()) do
        if Object:IsA("TextButton") then Object:Destroy() end
    end
end

local function ParseValueString(str)
    if not str then return 0 end
    local clean = string.gsub(str, "[%$%,%s]", "")
    local numStr, suffix = string.match(clean, "^([%d%.]+)([KkMmBbTt]?)$")
    if not numStr then return 0 end
    local num = tonumber(numStr) or 0
    suffix = string.upper(suffix or "")
    local multipliers = { [""] = 1, ["K"] = 1e3, ["M"] = 1e6, ["B"] = 1e9, ["T"] = 1e12 }
    return num * (multipliers[suffix] or 1)
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
                        if Label and string.find(string.lower(Label.Text), string.lower(LocalPlayer.Name), 1, true) then
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
            if Text and Text ~= "" and string.match(Text, "^%$?%d[%d%.]*[KkMmBbTt]?$") then
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
                        PlayerName = string.match(Text, "(.+)'s Base") or string.match(Text, "(.+)'s base")
                        if not PlayerName then PlayerName = Text end
                    end
                end
            end
        end
        
        if PlayerName and PlayerName ~= "" then
            local maxRaw, maxStr = GetBaseHighestValue(Base)
            
            if maxRaw >= 100000000 and not NotifiedBases[Base.Name] then
                NotifiedBases[Base.Name] = true
                CustomNotify("🔥 ANIME RARO ENCONTRADO!", "Base de " .. PlayerName .. " tem um anime de " .. maxStr .. "!", 7, CONFIG.Warning, SOUNDS.RareFound)
            end

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
        Button.ZIndex = 10501
        Button.Parent = BaseList
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)

        Button.MouseButton1Click:Connect(function()
            PlaySFX(SOUNDS.Click)
            SelectedBase = Data.Object
            SelectedCharacter = nil
            BaseButton.Text = "Base: " .. Data.Name
            CharacterButton.Text = "Selecionar Personagem"
            BaseList.Visible = false
            CharacterList.Visible = false
            CustomNotify("Base Selecionada", Data.Name, 2)
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
        if Data.Value then DisplayName = DisplayName .. "  [" .. Data.Value .. "]" end

        local Button = Instance.new("TextButton")
        Button.Size = UDim2.new(1, -4, 0, 28)
        Button.BackgroundColor3 = CONFIG.Element
        Button.BorderSizePixel = 0
        Button.Text = "  " .. DisplayName
        Button.TextColor3 = CONFIG.Text
        Button.Font = Enum.Font.Gotham
        Button.TextSize = 10
        Button.TextXAlignment = Enum.TextXAlignment.Left
        Button.ZIndex = 10501
        Button.Parent = CharacterList
        Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 5)

        Button.MouseButton1Click:Connect(function()
            PlaySFX(SOUNDS.Click)
            SelectedCharacter = Data.Object
            CharacterButton.Text = DisplayName
            CharacterList.Visible = false
            CustomNotify("Alvo Selecionado", DisplayName, 2)
        end)
    end
    CharacterList.CanvasSize = UDim2.new(0, 0, 0, CharacterLayout.AbsoluteContentSize.Y + 5)
end

--========================================================--
-- EVENTOS DE BOTÕES E FUNÇÕES
--========================================================--

BaseButton.MouseButton1Click:Connect(function()
    PlaySFX(SOUNDS.Click)
    CharacterList.Visible = false
    BaseList.Visible = not BaseList.Visible
    if BaseList.Visible then UpdateBases() end
end)

CharacterButton.MouseButton1Click:Connect(function()
    PlaySFX(SOUNDS.Click)
    if not SelectedBase then
        CustomNotify("Aviso", "Selecione uma base primeiro!", 3, CONFIG.Danger)
        return
    end
    BaseList.Visible = false
    CharacterList.Visible = not CharacterList.Visible
    if CharacterList.Visible then UpdateCharacters() end
end)

local function ApplySpeed()
    if not SpeedEnabled then return end
    local Character = LocalPlayer.Character
    if not Character then return end
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    if Humanoid then Humanoid.WalkSpeed = CONFIG.Speed end
end

SpeedButton.MouseButton1Click:Connect(function()
    PlaySFX(SOUNDS.Click)
    SpeedEnabled = not SpeedEnabled
    if SpeedEnabled then
        SpeedButton.Text = "⚡ SPEED: " .. CONFIG.Speed .. " | ON"
        ApplySpeed()
        CustomNotify("Velocidade", "Speed ativado!", 2, CONFIG.Success)
    else
        SpeedButton.Text = "⚡ SPEED: " .. CONFIG.Speed .. " | OFF"
        local Character = LocalPlayer.Character
        if Character then
            local Humanoid = Character:FindFirstChildOfClass("Humanoid")
            if Humanoid then Humanoid.WalkSpeed = 16 end
        end
        CustomNotify("Velocidade", "Speed desativado.", 2)
    end
end)

RejoinButton.MouseButton1Click:Connect(function()
    PlaySFX(SOUNDS.Click)
    CustomNotify("Reconnecting", "Reconectando ao servidor...", 4, CONFIG.Warning)
    task.wait(1)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

ServerHopButton.MouseButton1Click:Connect(function()
    PlaySFX(SOUNDS.Click)
    CustomNotify("Server Hop", "Buscando servidores disponíveis...", 3)
    
    local Success, Response = pcall(function()
        return game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")
    end)
    
    if not Success then
        CustomNotify("Erro", "Falha ao buscar servidores!", 3, CONFIG.Danger)
        return
    end

    local SuccessDecode, Data = pcall(function() return HttpService:JSONDecode(Response) end)
    if not SuccessDecode or not Data then
        CustomNotify("Erro", "Falha ao ler dados do servidor.", 3, CONFIG.Danger)
        return
    end

    local Available = {}
    for _, Server in ipairs(Data.data or {}) do
        if Server.id ~= game.JobId and Server.playing < Server.maxPlayers then
            table.insert(Available, Server.id)
        end
    end

    if #Available > 0 then
        local ServerId = Available[math.random(1, #Available)]
        CustomNotify("Sucesso!", "Servidor encontrado! Teleportando...", 3, CONFIG.Success)
        task.wait(1)
        TeleportService:TeleportToPlaceInstance(game.PlaceId, ServerId, LocalPlayer)
    else
        CustomNotify("Servidores Cheios", "Nenhum servidor vago encontrado. Tente novamente!", 4, CONFIG.Warning)
    end
end)

StealButton.MouseButton1Click:Connect(function()
    PlaySFX(SOUNDS.Click)
    if not SelectedBase then
        CustomNotify("Erro", "Selecione uma base primeiro!", 3, CONFIG.Danger)
        return
    end
    if not SelectedCharacter then
        CustomNotify("Erro", "Selecione um personagem!", 3, CONFIG.Danger)
        return
    end

    local Character = LocalPlayer.Character
    if not Character then return end
    local HRP = Character:FindFirstChild("HumanoidRootPart")
    local Humanoid = Character:FindFirstChildOfClass("Humanoid")
    local TargetHRP = SelectedCharacter:FindFirstChild("HumanoidRootPart")

    if not HRP or not Humanoid or not TargetHRP then
        CustomNotify("Erro", "Alvo não possui HumanoidRootPart.", 3, CONFIG.Danger)
        return
    end

    PlaySFX(SOUNDS.StealStart)
    CustomNotify("Steal Iniciado", "Teleportado ao alvo. Roubando...", 3, CONFIG.Success)

    local OldCFrame = HRP.CFrame
    local Noclip = RunService.Stepped:Connect(function()
        for _, Part in ipairs(Character:GetDescendants()) do
            if Part:IsA("BasePart") then Part.CanCollide = false end
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
        if TargetHRP and TargetHRP.Parent then
            Gyro.CFrame = CFrame.lookAt(HRP.Position, TargetHRP.Position) * CFrame.Angles(math.rad(-90), 0, 0)
        end
    end)

    task.spawn(function()
        for i = 6, 1, -1 do
            CustomNotify("Aguarde...", "Retornando à base em " .. i .. "s", 1, CONFIG.Warning)
            task.wait(1)
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
    Humanoid.PlatformStand = false

    for _, Part in ipairs(Character:GetDescendants()) do
        if Part:IsA("BasePart") then Part.CanCollide = true end
    end

    ApplySpeed()
    CustomNotify("Sucesso", "Steal concluído com sucesso!", 3, CONFIG.Success)
end)

--========================================================--
-- ANIMAÇÕES CLEAN DE ABRIR / FECHAR MENU
--========================================================--

local function OpenMenu()
    PlaySFX(SOUNDS.Click)
    MenuOpen = true
    Menu.Visible = true
    Menu.Size = UDim2.new(0, 280, 0, 0)
    
    TweenService:Create(Menu, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 280, 0, 320)
    }):Play()
end

local function CloseMenu()
    PlaySFX(SOUNDS.Click)
    MenuOpen = false
    BaseList.Visible = false
    CharacterList.Visible = false
    
    local TweenClose = TweenService:Create(Menu, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
        Size = UDim2.new(0, 280, 0, 0)
    })
    TweenClose:Play()
    TweenClose.Completed:Connect(function()
        if not MenuOpen then Menu.Visible = false end
    end)
end

Close.MouseButton1Click:Connect(CloseMenu)

UserInputService.InputBegan:Connect(function(Input, GameProcessed)
    if GameProcessed then return end
    if Input.KeyCode == Enum.KeyCode.K then
        if MenuOpen then CloseMenu() else OpenMenu() end
    end
end)

-- ARRASTAR O MENU
local MenuDragging, MenuDragStart, MenuStartPos
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

-- ARRASTAR E CLICAR BOTÃO FLUTUANTE (Sem travar)
local Dragging, DragStart, StartPosition, HasMoved = false, nil, nil, false

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
        if Delta.Magnitude > 12 then
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
CustomNotify("Kiko Steal", "Script Carregado com Sucesso!", 4, CONFIG.Accent)

task.spawn(function()
    while task.wait(5) do
        pcall(GetBases)
    end
end)
