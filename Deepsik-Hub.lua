--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB - MM2 SCRIPT            ║
    ║      ЧАСТЬ 1/3: Инициализация + GUI      ║
    ║      Version: 1.0.0                      ║
    ╚══════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============ НАСТРОЙКИ ============
getgenv().DeepsikConfig = getgenv().DeepsikConfig or {
    ESP = false,
    ESPColor = Color3.fromRGB(0, 170, 255),
    Tracers = false,
    FullBright = false,
    SpeedHack = false,
    SpeedValue = 60,
    JumpPower = false,
    JumpValue = 120,
    InfiniteJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    AutoFarm = false,
    TeamCheck = false,
}

local Config = getgenv().DeepsikConfig
local ESPObjects = getgenv().DeepsikESP or {}
getgenv().DeepsikESP = ESPObjects
local FlyConnection = getgenv().DeepsikFly or nil

-- Удаляем старое GUI, если есть
if getgenv().DeepsikGui then
    pcall(function() getgenv().DeepsikGui:Destroy() end)
end

-- ============ СОЗДАНИЕ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeepsikHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
getgenv().DeepsikGui = ScreenGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 520, 0, 380)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -190)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 2
MainStroke.Parent = MainFrame

-- Заголовок
local TitleBar = Instance.new("Frame")
TitleBar.Name = "TitleBar"
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleFrame = Instance.new("Frame")
TitleFrame.Size = UDim2.new(1, 0, 0, 20)
TitleFrame.Position = UDim2.new(0, 0, 1, -20)
TitleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TitleFrame.BorderSizePixel = 0
TitleFrame.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 15, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🔫 DEEPSIK HUB"
TitleLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
TitleLabel.TextSize = 22
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 80, 1, 0)
VersionLabel.Position = UDim2.new(1, -130, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v1.0.0"
VersionLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
VersionLabel.TextSize = 14
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.Parent = TitleBar

-- Кнопка закрытия
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
CloseBtn.TextSize = 18
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Parent = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- Кнопка минимизации
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 35, 0, 35)
MinBtn.Position = UDim2.new(1, -85, 0, 5)
MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
MinBtn.Text = "—"
MinBtn.TextColor3 = Color3.fromRGB(255, 200, 80)
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Parent = TitleBar

local MinCorner = Instance.new("UICorner")
MinCorner.CornerRadius = UDim.new(0, 8)
MinCorner.Parent = MinBtn

-- Кнопка показа (когда меню скрыто)
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 120, 0, 45)
ToggleBtn.Position = UDim2.new(0.5, -60, 1, -70)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Text = "🔫 DEEPSIK"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Visible = false
ToggleBtn.Parent = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

-- Контейнер вкладок
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 35)
TabBar.Position = UDim2.new(0, 10, 0, 55)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel = 0
TabBar.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 8)
TabCorner.Parent = TabBar

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Center
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.Parent = TabBar

-- Контейнер контента
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -105)
ContentFrame.Position = UDim2.new(0, 10, 0, 95)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentFrame.BorderSizePixel = 0
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- Сохраняем ссылки в глобал для 2 и 3 части
getgenv().DeepsikRefs = {
    ScreenGui = ScreenGui,
    MainFrame = MainFrame,
    TitleBar = TitleBar,
    TitleFrame = TitleFrame,
    ContentFrame = ContentFrame,
    TabBar = TabBar,
    CloseBtn = CloseBtn,
    MinBtn = MinBtn,
    ToggleBtn = ToggleBtn,
    TweenService = TweenService,
    Players = Players,
    RunService = RunService,
    UserInputService = UserInputService,
    Lighting = Lighting,
    Workspace = Workspace,
    TeleportService = TeleportService,
    LocalPlayer = LocalPlayer,
    Camera = Camera,
    Config = Config,
    ESPObjects = ESPObjects,
}

print("✅ [Deepsik Hub] Часть 1/3 загружена — GUI создан")

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB - MM2 SCRIPT            ║
    ║      ЧАСТЬ 2/3: UI + Функционал          ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
if not R then
    warn("❌ [Deepsik Hub] Сначала запусти Часть 1!")
    return
end

local Config = R.Config
local ESPObjects = R.ESPObjects
local LocalPlayer = R.LocalPlayer
local Camera = R.Camera
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Lighting = R.Lighting
local Workspace = R.Workspace
local TweenService = R.TweenService
local ContentFrame = R.ContentFrame
local TabBar = R.TabBar

-- ============ ФУНКЦИИ СОЗДАНИЯ ЭЛЕМЕНТОВ ============
local function CreateTab(name, icon)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(0, 110, 0, 27)
    Tab.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Tab.Text = icon .. " " .. name
    Tab.TextColor3 = Color3.fromRGB(200, 200, 210)
    Tab.TextSize = 13
    Tab.Font = Enum.Font.GothamMedium
    Tab.Parent = TabBar
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Tab
    return Tab
end

local function CreatePage(parent)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 4
    Page.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.Parent = parent
    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 8)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Page
    Layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, Layout.AbsoluteContentSize.Y + 10)
    end)
    return Page
end

local function CreateToggle(parent, text, default, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Size = UDim2.new(1, -10, 0, 35)
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    ToggleFrame.BorderSizePixel = 0
    ToggleFrame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = ToggleFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = ToggleFrame

    local ToggleBtnBg = Instance.new("Frame")
    ToggleBtnBg.Size = UDim2.new(0, 40, 0, 20)
    ToggleBtnBg.Position = UDim2.new(1, -52, 0.5, -10)
    ToggleBtnBg.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
    ToggleBtnBg.BorderSizePixel = 0
    ToggleBtnBg.Parent = ToggleFrame
    local TC = Instance.new("UICorner")
    TC.CornerRadius = UDim.new(0, 10)
    TC.Parent = ToggleBtnBg

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 16, 0, 16)
    Indicator.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.BorderSizePixel = 0
    Indicator.Parent = ToggleBtnBg
    local IC = Instance.new("UICorner")
    IC.CornerRadius = UDim.new(0, 10)
    IC.Parent = Indicator

    local ClickBtn = Instance.new("TextButton")
    ClickBtn.Size = UDim2.new(1, 0, 1, 0)
    ClickBtn.BackgroundTransparency = 1
    ClickBtn.Text = ""
    ClickBtn.Parent = ToggleFrame

    local state = default
    ClickBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(ToggleBtnBg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if callback then callback(state) end
    end)
    return ToggleFrame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Size = UDim2.new(1, -10, 0, 50)
    SliderFrame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    SliderFrame.BorderSizePixel = 0
    SliderFrame.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = SliderFrame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = SliderFrame

    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Size = UDim2.new(0, 50, 0, 20)
    ValueLabel.Position = UDim2.new(1, -60, 0, 5)
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(0, 170, 255)
    ValueLabel.TextSize = 13
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    ValueLabel.Parent = SliderFrame

    local BarBg = Instance.new("Frame")
    BarBg.Size = UDim2.new(1, -24, 0, 8)
    BarBg.Position = UDim2.new(0, 12, 0, 32)
    BarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    BarBg.BorderSizePixel = 0
    BarBg.Parent = SliderFrame
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 4)
    BC.Parent = BarBg

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = BarBg
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(0, 4)
    FC.Parent = Fill

    local value = default
    local dragging = false

    BarBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local mousePos = UserInputService:GetMouseLocation()
            local barPos = BarBg.AbsolutePosition
            local barSize = BarBg.AbsoluteSize
            local relative = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
            value = math.floor(min + (max - min) * relative)
            Fill.Size = UDim2.new(relative, 0, 1, 0)
            ValueLabel.Text = tostring(value)
            if callback then callback(value) end
        end
    end)
    return SliderFrame
end

local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 200)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Btn
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return Btn
end

local function CreateLabel(parent, text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 30)
    Label.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Label.Text = text
    Label.TextColor3 = color or Color3.fromRGB(220, 220, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Label
    return Label
end

-- ============ ВКЛАДКИ ============
local CombatTab = CreateTab("Combat", "⚔️")
local VisualTab = CreateTab("Visual", "👁️")
local MovementTab = CreateTab("Move", "🏃")
local FarmTab = CreateTab("Farm", "🌾")
local MiscTab = CreateTab("Misc", "⚙️")

local CombatPage = CreatePage(ContentFrame)
local VisualPage = CreatePage(ContentFrame)
local MovementPage = CreatePage(ContentFrame)
local FarmPage = CreatePage(ContentFrame)
local MiscPage = CreatePage(ContentFrame)

local tabs = {
    {Tab = CombatTab, Page = CombatPage},
    {Tab = VisualTab, Page = VisualPage},
    {Tab = MovementTab, Page = MovementPage},
    {Tab = FarmTab, Page = FarmPage},
    {Tab = MiscTab, Page = MiscPage},
}

for _, tabData in ipairs(tabs) do
    tabData.Tab.MouseButton1Click:Connect(function()
        for _, other in ipairs(tabs) do
            other.Page.Visible = false
            other.Tab.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
            other.Tab.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
        tabData.Page.Visible = true
        tabData.Tab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        tabData.Tab.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
end

-- ============ ESP ============
local function CreateESP(player)
    if player == LocalPlayer then return end
    if ESPObjects[player] then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2
    Box.Color = Config.ESPColor
    Box.Filled = false
    Box.Transparency = 1
    Box.Visible = false

    local NameTag = Drawing.new("Text")
    NameTag.Size = 14
    NameTag.Center = true
    NameTag.Outline = true
    NameTag.Color = Color3.fromRGB(255, 255, 255)
    NameTag.Visible = false

    local DistanceTag = Drawing.new("Text")
    DistanceTag.Size = 12
    DistanceTag.Center = true
    DistanceTag.Outline = true
    DistanceTag.Color = Color3.fromRGB(0, 170, 255)
    DistanceTag.Visible = false

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1
    Tracer.Color = Config.ESPColor
    Tracer.Visible = false

    ESPObjects[player] = {Box = Box, NameTag = NameTag, DistanceTag = DistanceTag, Tracer = Tracer}
end

local function RemoveESP(player)
    if ESPObjects[player] then
        for _, obj in pairs(ESPObjects[player]) do
            pcall(function() obj:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

getgenv().DeepsikCreateESP = CreateESP
getgenv().DeepsikRemoveESP = RemoveESP

local function UpdateESP()
    for player, objs in pairs(ESPObjects) do
        if not Config.ESP or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") or not player.Character:FindFirstChild("Head") then
            objs.Box.Visible = false
            objs.NameTag.Visible = false
            objs.DistanceTag.Visible = false
            objs.Tracer.Visible = false
            continue
        end

        local hrp = player.Character.HumanoidRootPart
        local head = player.Character.Head
        local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

        if not humanoid or humanoid.Health <= 0 then
            objs.Box.Visible = false
            objs.NameTag.Visible = false
            objs.DistanceTag.Visible = false
            objs.Tracer.Visible = false
            continue
        end

        if Config.TeamCheck and player.Team == LocalPlayer.Team then
            objs.Box.Visible = false
            objs.NameTag.Visible = false
            objs.DistanceTag.Visible = false
            objs.Tracer.Visible = false
            continue
        end

        local headPos, headOnScreen = Camera:WorldToViewportPoint(head.Position)
        local hrpPos, hrpOnScreen = Camera:WorldToViewportPoint(hrp.Position)

        if headOnScreen and hrpOnScreen then
            local height = math.abs(headPos.Y - hrpPos.Y) * 2
            local width = height * 0.6

            objs.Box.Size = Vector2.new(width, height)
            objs.Box.Position = Vector2.new(headPos.X - width/2, headPos.Y)
            objs.Box.Color = Config.ESPColor
            objs.Box.Visible = Config.ESP

            local distance = (Camera.CFrame.Position - hrp.Position).Magnitude
            objs.NameTag.Text = player.Name
            objs.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 20)
            objs.NameTag.Visible = Config.ESP

            objs.DistanceTag.Text = string.format("[%d studs]", math.floor(distance))
            objs.DistanceTag.Position = Vector2.new(headPos.X, headPos.Y + height + 2)
            objs.DistanceTag.Visible = Config.ESP

            if Config.Tracers then
                objs.Tracer.From = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y)
                objs.Tracer.To = Vector2.new(headPos.X, headPos.Y + height)
                objs.Tracer.Color = Config.ESPColor
                objs.Tracer.Visible = true
            else
                objs.Tracer.Visible = false
            end
        else
            objs.Box.Visible = false
            objs.NameTag.Visible = false
            objs.DistanceTag.Visible = false
            objs.Tracer.Visible = false
        end
    end
end

for _, player in ipairs(Players:GetPlayers()) do
    CreateESP(player)
end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
end)

-- ============ SPEED / JUMP ============
local function UpdateSpeed()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").WalkSpeed = Config.SpeedHack and Config.SpeedValue or 16
    end
end

local function UpdateJump()
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid").JumpPower = Config.JumpPower and Config.JumpValue or 50
    end
end

LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    UpdateSpeed()
    UpdateJump()
end)

UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump and LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
        LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
    end
end)

RunService.Stepped:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

-- ============ FLY ============
local function StartFly()
    if FlyConnection then FlyConnection:Disconnect() end
    local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bodyVelocity = Instance.new("BodyVelocity")
    bodyVelocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    bodyVelocity.Velocity = Vector3.new(0, 0, 0)
    bodyVelocity.Parent = hrp

    local bodyGyro = Instance.new("BodyGyro")
    bodyGyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    bodyGyro.P = 10000
    bodyGyro.Parent = hrp

    FlyConnection = RunService.RenderStepped:Connect(function()
        if not Config.Fly or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            if bodyVelocity then bodyVelocity:Destroy() end
            if bodyGyro then bodyGyro:Destroy() end
            return
        end

        local direction = Vector3.new(0, 0, 0)
        local cam = Workspace.CurrentCamera

        if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction = direction + cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction = direction - cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction = direction - cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction = direction + cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction = direction + Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction = direction - Vector3.new(0, 1, 0) end

        if direction.Magnitude > 0 then
            direction = direction.Unit * Config.FlySpeed
        end

        bodyVelocity.Velocity = direction
        bodyGyro.CFrame = cam.CFrame
    end)
end

-- ============ ВКЛАДКА COMBAT ============
CreateLabel(CombatPage, "⚔️ COMBAT SETTINGS", Color3.fromRGB(0, 170, 255))
CreateToggle(CombatPage, "ESP игроков", Config.ESP, function(state) Config.ESP = state end)
CreateToggle(CombatPage, "Tracers (линии)", Config.Tracers, function(state) Config.Tracers = state end)
CreateToggle(CombatPage, "Team Check", Config.TeamCheck, function(state) Config.TeamCheck = state end)
CreateButton(CombatPage, "🎯 Обновить ESP", Color3.fromRGB(0, 120, 200), function()
    for _, player in ipairs(Players:GetPlayers()) do
        RemoveESP(player)
        CreateESP(player)
    end
end)

-- ============ ВКЛАДКА VISUAL ============
CreateLabel(VisualPage, "👁️ VISUAL SETTINGS", Color3.fromRGB(0, 170, 255))
CreateToggle(VisualPage, "FullBright (яркость)", Config.FullBright, function(state)
    Config.FullBright = state
    if state then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)
CreateButton(VisualPage, "🌫️ Убрать туман", Color3.fromRGB(100, 100, 120), function()
    Lighting.FogEnd = 100000
    Lighting.FogStart = 0
end)
CreateButton(VisualPage, "⏰ Время: День", Color3.fromRGB(255, 200, 80), function()
    Lighting.ClockTime = 12
end)
CreateButton(VisualPage, "🌙 Время: Ночь", Color3.fromRGB(50, 50, 100), function()
    Lighting.ClockTime = 0
end)

-- ============ ВКЛАДКА MOVEMENT ============
CreateLabel(MovementPage, "🏃 MOVEMENT SETTINGS", Color3.fromRGB(0, 170, 255))
CreateToggle(MovementPage, "Speed Hack", Config.SpeedHack, function(state)
    Config.SpeedHack = state
    UpdateSpeed()
end)
CreateSlider(MovementPage, "Скорость ходьбы", 16, 200, 60, function(value)
    Config.SpeedValue = value
    UpdateSpeed()
end)
CreateToggle(MovementPage, "Jump Power", Config.JumpPower, function(state)
    Config.JumpPower = state
    UpdateJump()
end)
CreateSlider(MovementPage, "Сила прыжка", 50, 500, 120, function(value)
    Config.JumpValue = value
    UpdateJump()
end)
CreateToggle(MovementPage, "Infinite Jump", Config.InfiniteJump, function(state) Config.InfiniteJump = state end)
CreateToggle(MovementPage, "Noclip", Config.Noclip, function(state) Config.Noclip = state end)
CreateToggle(MovementPage, "Fly (полёт)", Config.Fly, function(state)
    Config.Fly = state
    if state and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        StartFly()
    end
end)
CreateSlider(MovementPage, "Скорость полёта", 10, 300, 50, function(value) Config.FlySpeed = value end)

-- ==================================================================
-- ==================== ВКЛАДКА FARM ================================
-- ==================================================================

-- Дополнительные настройки Farm
Config.AutoFarm = Config.AutoFarm or false
Config.AutoFarmRange = Config.AutoFarmRange or 200
Config.AutoShoot = Config.AutoShoot or false
Config.AutoCollectGuns = Config.AutoCollectGuns or false
Config.CoinFarm = Config.CoinFarm or false
Config.KillAura = Config.KillAura or false
Config.AuraRange = Config.AuraRange or 30
Config.FarmDelay = Config.FarmDelay or 0.1

-- ============ ХЕЛПЕРЫ ============
local function GetMyChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
    return char, hrp, hum
end

local function GetTargets()
    local targets = {}
    local _, myHrp = GetMyChar()
    if not myHrp then return targets end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if not (Config.TeamCheck and plr.Team == LocalPlayer.Team) then
                    local dist = (myHrp.Position - hrp.Position).Magnitude
                    table.insert(targets, {
                        player = plr,
                        hrp = hrp,
                        humanoid = hum,
                        dist = dist
                    })
                end
            end
        end
    end
    table.sort(targets, function(a, b) return a.dist < b.dist end)
    return targets
end

local function GetEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, child in ipairs(char:GetChildren()) do
        if child:IsA("Tool") then
            return child
        end
    end
    return nil
end

-- ============ AUTO FARM ============
local AutoFarmConn = nil

local function StartAutoFarm()
    if AutoFarmConn then AutoFarmConn:Disconnect() end
    AutoFarmConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm then return end
        local _, myHrp, myHum = GetMyChar()
        if not myHrp or not myHum or myHum.Health <= 0 then return end

        local targets = GetTargets()
        if #targets == 0 then return end

        local target = targets[1]
        if target.dist > Config.AutoFarmRange then return end

        pcall(function()
            myHrp.CFrame = target.hrp.CFrame * CFrame.new(0, 0, 2)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end)

        local tool = GetEquippedTool()
        if tool then
            pcall(function() tool:Activate() end)
        end
    end)
end

-- ============ AUTO SHOOT ============
local AutoShootConn = nil

local function StartAutoShoot()
    if AutoShootConn then AutoShootConn:Disconnect() end
    AutoShootConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoShoot then return end
        local _, _, myHum = GetMyChar()
        if not myHum or myHum.Health <= 0 then return end

        local tool = GetEquippedTool()
        if not tool then return end

        local targets = GetTargets()
        if #targets == 0 then return end

        local target = targets[1]
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.hrp.Position)
        pcall(function() tool:Activate() end)
    end)
end

-- ============ AUTO COLLECT GUNS ============
local AutoCollectConn = nil

local function StartAutoCollect()
    if AutoCollectConn then AutoCollectConn:Disconnect() end
    AutoCollectConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoCollectGuns then return end
        local _, myHrp = GetMyChar()
        if not myHrp then return end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") and obj.Parent ~= LocalPlayer.Character then
                local handle = obj:FindFirstChild("Handle")
                if handle then
                    local dist = (myHrp.Position - handle.Position).Magnitude
                    if dist < 60 then
                        pcall(function() handle.CFrame = myHrp.CFrame end)
                    end
                end
            end
        end
    end)
end

-- ============ KILL AURA ============
local AuraConn = nil

local function StartKillAura()
    if AuraConn then AuraConn:Disconnect() end
    AuraConn = RunService.Heartbeat:Connect(function()
        if not Config.KillAura then return end
        local _, myHrp = GetMyChar()
        if not myHrp then return end

        local tool = GetEquippedTool()
        if not tool then return end

        local targets = GetTargets()
        for _, target in ipairs(targets) do
            if target.dist <= Config.AuraRange then
                pcall(function() tool:Activate() end)
                task.wait(Config.FarmDelay)
            end
        end
    end)
end

-- ============ KILL ALL ============
local function KillAll()
    local _, myHrp = GetMyChar()
    local tool = GetEquippedTool()

    if not myHrp then
        warn("[Deepsik] Нет персонажа")
        return
    end
    if not tool then
        warn("[Deepsik] Возьми нож/оружие в руки")
        return
    end

    local originalCFrame = myHrp.CFrame
    local targets = GetTargets()
    print(string.format("[Deepsik] Kill All: %d целей", #targets))

    for _, target in ipairs(targets) do
        pcall(function()
            myHrp.CFrame = target.hrp.CFrame * CFrame.new(0, 0, 2)
        end)
        task.wait(Config.FarmDelay)
        pcall(function() tool:Activate() end)
    end

    task.wait(0.1)
    pcall(function() myHrp.CFrame = originalCFrame end)
    print("[Deepsik] Kill All завершён")
end

-- ============ COIN FARM ============
local CoinFarmConn = nil

local function StartCoinFarm()
    if CoinFarmConn then CoinFarmConn:Disconnect() end
    CoinFarmConn = RunService.Heartbeat:Connect(function()
        if not Config.CoinFarm then return end
        local _, myHrp = GetMyChar()
        if not myHrp then return end

        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") then
                local name = obj.Name:lower()
                if name:find("coin") or name:find("монет") then
                    local dist = (myHrp.Position - obj.Position).Magnitude
                    if dist < 100 and dist > 3 then
                        pcall(function()
                            myHrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                        end)
                    end
                end
            end
        end
    end)
end

-- ============ UI FARM ============
CreateLabel(FarmPage, "🌾 FARM - AUTO SETTINGS", Color3.fromRGB(0, 170, 255))

CreateToggle(FarmPage, "Auto Farm (телепорт + удар)", Config.AutoFarm, function(state)
    Config.AutoFarm = state
    if state then StartAutoFarm()
    elseif AutoFarmConn then AutoFarmConn:Disconnect() end
end)

CreateSlider(FarmPage, "Дистанция Farm", 50, 500, 200, function(value)
    Config.AutoFarmRange = value
end)

CreateToggle(FarmPage, "Auto Shoot (авто-выстрел)", Config.AutoShoot, function(state)
    Config.AutoShoot = state
    if state then StartAutoShoot()
    elseif AutoShootConn then AutoShootConn:Disconnect() end
end)

CreateToggle(FarmPage, "Auto Collect Guns (подбор)", Config.AutoCollectGuns, function(state)
    Config.AutoCollectGuns = state
    if state then StartAutoCollect()
    elseif AutoCollectConn then AutoCollectConn:Disconnect() end
end)

CreateToggle(FarmPage, "Kill Aura (убийство в радиусе)", Config.KillAura, function(state)
    Config.KillAura = state
    if state then StartKillAura()
    elseif AuraConn then AuraConn:Disconnect() end
end)

CreateSlider(FarmPage, "Радиус Aura", 5, 100, 30, function(value)
    Config.AuraRange = value
end)

CreateToggle(FarmPage, "Coin Farm (сбор монет)", Config.CoinFarm, function(state)
    Config.CoinFarm = state
    if state then StartCoinFarm()
    elseif CoinFarmConn then CoinFarmConn:Disconnect() end
end)

CreateSlider(FarmPage, "Задержка удара (сек)", 0, 1, 0.1, function(value)
    Config.FarmDelay = value
end)

CreateButton(FarmPage, "💀 KILL ALL (нужен нож)", Color3.fromRGB(200, 50, 50), function()
    KillAll()
end)

CreateButton(FarmPage, "🔄 Rejoin сервер", Color3.fromRGB(0, 120, 200), function()
    R.TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

CreateButton(FarmPage, "📊 Информация о сервере", Color3.fromRGB(100, 100, 120), function()
    print("=== DEEPSIK HUB INFO ===")
    print(string.format("Игроков: %d", #Players:GetPlayers()))
    print(string.format("Ping: %d ms", math.floor(LocalPlayer:GetNetworkPing() * 1000)))
    print(string.format("Целей рядом: %d", #GetTargets()))
end)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB - MM2 SCRIPT            ║
    ║      ЧАСТЬ 3/3: Misc + Управление        ║
    ║      Version: 1.0.0                      ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
if not R or not R.CombatTab then
    warn("❌ [Deepsik Hub] Сначала запусти Части 1 и 2!")
    return
end

local Config = R.Config
local ScreenGui = R.ScreenGui
local MainFrame = R.MainFrame
local TitleBar = R.TitleBar
local TitleFrame = R.TitleFrame
local ContentFrame = R.ContentFrame
local TabBar = R.TabBar
local CloseBtn = R.CloseBtn
local MinBtn = R.MinBtn
local ToggleBtn = R.ToggleBtn
local UserInputService = R.UserInputService
local LocalPlayer = R.LocalPlayer
local TweenService = R.TweenService
local ESPObjects = R.ESPObjects
local CombatTab = R.CombatTab
local CombatPage = R.CombatPage

-- ============ ХЕЛПЕРЫ ДЛЯ MISC ============
local function MakeLabel(parent, text, color)
    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -10, 0, 30)
    Label.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Label.Text = text
    Label.TextColor3 = color or Color3.fromRGB(220, 220, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.Parent = parent
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Label
    return Label
end

local function MakeToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 35)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 40, 0, 20)
    Bg.Position = UDim2.new(1, -52, 0.5, -10)
    Bg.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
    Bg.BorderSizePixel = 0
    Bg.Parent = Frame
    local BgC = Instance.new("UICorner")
    BgC.CornerRadius = UDim.new(0, 10)
    BgC.Parent = Bg

    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 16, 0, 16)
    Ind.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ind.BorderSizePixel = 0
    Ind.Parent = Bg
    local IndC = Instance.new("UICorner")
    IndC.CornerRadius = UDim.new(0, 10)
    IndC.Parent = Ind

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.Parent = Frame

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Bg, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(Ind, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if callback then callback(state) end
    end)
    return Frame
end

local function MakeButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 200)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Btn
    Btn.MouseButton1Click:Connect(function()
        if callback then callback() end
    end)
    return Btn
end

-- ============ СОЗДАЁМ MISC PAGE ============
local MiscPage = Instance.new("ScrollingFrame")
MiscPage.Size = UDim2.new(1, -20, 1, -20)
MiscPage.Position = UDim2.new(0, 10, 0, 10)
MiscPage.BackgroundTransparency = 1
MiscPage.BorderSizePixel = 0
MiscPage.ScrollBarThickness = 4
MiscPage.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
MiscPage.CanvasSize = UDim2.new(0, 0, 0, 0)
MiscPage.Visible = false
MiscPage.Parent = ContentFrame

local MiscLayout = Instance.new("UIListLayout")
MiscLayout.Padding = UDim.new(0, 8)
MiscLayout.SortOrder = Enum.SortOrder.LayoutOrder
MiscLayout.Parent = MiscPage
MiscLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    MiscPage.CanvasSize = UDim2.new(0, 0, 0, MiscLayout.AbsoluteContentSize.Y + 10)
end)

-- Привязываем MiscPage к вкладке Misc (если она уже есть во 2 части)
if R.MiscTab and R.MiscPage then
    -- Удаляем старую пустую страницу и заменяем на новую
    pcall(function() R.MiscPage:Destroy() end)
    R.MiscPage = MiscPage
end

-- Переподключаем кнопку Misc-вкладки к новой странице
if R.MiscTab then
    R.MiscTab.MouseButton1Click:Connect(function()
        MiscPage.Visible = true
    end)
    -- Скрываем при переходе на другие вкладки
    for _, ref in pairs({R.CombatTab, R.VisualTab, R.MovementTab, R.FarmTab}) do
        if ref then
            ref.MouseButton1Click:Connect(function()
                MiscPage.Visible = false
            end)
        end
    end
end

-- ============ ВКЛАДКА MISC ============
MakeLabel(MiscPage, "⚙️ MISC SETTINGS", Color3.fromRGB(0, 170, 255))

MakeToggle(MiscPage, "Тёмная тема", true, function(state)
    if state then
        MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        TitleFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    else
        MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        TitleFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        ContentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        TabBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end
end)

MakeToggle(MiscPage, "Скрыть UI (F1)", false, function(state)
    MainFrame.Visible = not state
    ToggleBtn.Visible = state
end)

MakeLabel(MiscPage, "📊 СТАТИСТИКА", Color3.fromRGB(0, 170, 255))

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -10, 0, 80)
StatsLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
StatsLabel.Text = "Загрузка..."
StatsLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
StatsLabel.TextSize = 13
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.Parent = MiscPage
local StatsCorner = Instance.new("UICorner")
StatsCorner.CornerRadius = UDim.new(0, 6)
StatsCorner.Parent = StatsLabel

local StatsPadding = Instance.new("UIPadding")
StatsPadding.PaddingTop = UDim.new(0, 8)
StatsPadding.PaddingLeft = UDim.new(0, 12)
StatsPadding.Parent = StatsLabel

-- Обновление статистики
task.spawn(function()
    while StatsLabel.Parent do
        local players = #R.Players:GetPlayers()
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local fps = math.floor(1 / R.RunService.RenderStepped:Wait())

        StatsLabel.Text = string.format(
            "👥 Игроков: %d\n📡 Ping: %d ms\n🎮 FPS: %d\n🔫 ESP активен: %s",
            players,
            ping,
            fps,
            Config.ESP and "Да" or "Нет"
        )
        task.wait(1)
    end
end)

MakeLabel(MiscPage, "🔧 ДЕЙСТВИЯ", Color3.fromRGB(0, 170, 255))

MakeButton(MiscPage, "🔄 Перезагрузить скрипт", Color3.fromRGB(200, 120, 0), function()
    ScreenGui:Destroy()
    if getgenv().DeepsikFly then getgenv().DeepsikFly:Disconnect() end
    getgenv().DeepsikGui = nil
    getgenv().DeepsikRefs = nil
    print("[Deepsik] Скрипт выгружен. Запусти заново.")
end)

MakeButton(MiscPage, "🔫 Отключить ESP", Color3.fromRGB(150, 100, 200), function()
    Config.ESP = false
    Config.Tracers = false
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do
            pcall(function() obj.Visible = false end)
        end
    end
    print("[Deepsik] ESP выключен")
end)

MakeButton(MiscPage, "🌍 Rejoin сервер", Color3.fromRGB(0, 120, 200), function()
    R.TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

MakeButton(MiscPage, "❌ Выгрузить Deepsik Hub", Color3.fromRGB(200, 50, 50), function()
    if getgenv().DeepsikFly then getgenv().DeepsikFly:Disconnect() end
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do
            pcall(function() obj:Remove() end)
        end
    end
    ScreenGui:Destroy()
    getgenv().DeepsikGui = nil
    getgenv().DeepsikRefs = nil
    print("[Deepsik] Hub полностью выгружен")
end)

MakeLabel(MiscPage, "💙 Deepsik Hub v1.0.0 | Made by Deepsik", Color3.fromRGB(0, 170, 255))

-- ============ КНОПКИ УПРАВЛЕНИЯ ============
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end)

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleBtn.Visible = false
end)

-- ============ ГОРЯЧИЕ КЛАВИШИ ============
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    -- RightShift: открыть/закрыть меню
    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        ToggleBtn.Visible = not MainFrame.Visible
    end

    -- F1: быстрое скрытие UI
    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
        ToggleBtn.Visible = not MainFrame.Visible
    end

    -- Delete: полная выгрузка
    if input.KeyCode == Enum.KeyCode.Delete then
        if getgenv().DeepsikFly then getgenv().DeepsikFly:Disconnect() end
        for _, objs in pairs(ESPObjects) do
            for _, obj in pairs(objs) do
                pcall(function() obj:Remove() end)
            end
        end
        ScreenGui:Destroy()
        getgenv().DeepsikGui = nil
        getgenv().DeepsikRefs = nil
        print("[Deepsik] Hub выгружен через Delete")
    end
end)

-- ============ ИНИЦИАЛИЗАЦИЯ ============
CombatTab.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
CombatTab.TextColor3 = Color3.fromRGB(255, 255, 255)
CombatPage.Visible = true

print([[
╔══════════════════════════════════════════╗
║     🔫 DEEPSIK HUB ЗАГРУЖЕН! 🔫          ║
║     Версия: 1.0.0                        ║
║     Правый Shift - открыть/закрыть       ║
║     F1 - скрыть/показать UI              ║
║     Delete - выгрузить скрипт            ║
╚══════════════════════════════════════════╝
]])
