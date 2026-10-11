--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v2.0 - MM2 SCRIPT       ║
    ║      ЧАСТЬ 1/4: Инициализация + GUI      ║
    ╚══════════════════════════════════════════╝
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============ КОНФИГ ============
getgenv().DeepsikConfig = getgenv().DeepsikConfig or {
    -- Combat
    ESP = false,
    ESPColor = Color3.fromRGB(0, 170, 255),
    Tracers = false,
    TeamCheck = false,
    BoxESP = true,
    NameESP = true,
    DistanceESP = true,

    -- Visual
    FullBright = false,
    NoFog = false,

    -- Movement
    SpeedHack = false,
    SpeedValue = 60,
    JumpPower = false,
    JumpValue = 120,
    InfiniteJump = false,
    Noclip = false,
    Fly = false,
    FlySpeed = 50,
    AntiAFK = false,

    -- Farm
    AutoFarm = false,
    AutoFarmRange = 200,
    AutoShoot = false,
    AutoCollectGuns = false,
    CoinFarm = false,
    KillAura = false,
    AuraRange = 30,
    FarmDelay = 0.1,

    -- Misc
    DarkTheme = true,
}

local Config = getgenv().DeepsikConfig

-- Уничтожаем старые экземпляры
if getgenv().DeepsikGui then
    pcall(function() getgenv().DeepsikGui:Destroy() end)
end
for _, conn in pairs(getgenv().DeepsikConns or {}) do
    pcall(function() conn:Disconnect() end)
end
getgenv().DeepsikConns = {}
getgenv().DeepsikESP = getgenv().DeepsikESP or {}

-- ============ ХЕЛПЕР: УВЕДОМЛЕНИЕ ============
local function Notify(text, duration)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Deepsik Hub",
            Text = text,
            Duration = duration or 3
        })
    end)
end
getgenv().DeepsikNotify = Notify

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeepsikHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
getgenv().DeepsikGui = ScreenGui

-- Главный фрейм
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 540, 0, 400)
MainFrame.Position = UDim2.new(0.5, -270, 0.5, -200)
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

-- ===== ЗАГОЛОВОК =====
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
VersionLabel.Text = "v2.0"
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

-- Плавающая кнопка показа
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 120, 0, 45)
ToggleBtn.Position = UDim2.new(0.5, -60, 1, -70)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Text = "🔫 DEEPSIK"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Visible = false
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

-- ===== КОНТЕЙНЕР ВКЛАДОК (ИСПРАВЛЕН: СКРОЛЛ) =====
local TabBar = Instance.new("Frame")
TabBar.Size = UDim2.new(1, -20, 0, 38)
TabBar.Position = UDim2.new(0, 10, 0, 55)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TabBar.BorderSizePixel = 0
TabBar.ClipsDescendants = true
TabBar.Parent = MainFrame

local TabCorner = Instance.new("UICorner")
TabCorner.CornerRadius = UDim.new(0, 8)
TabCorner.Parent = TabBar

-- Скролл для вкладок (если их больше, чем влезает)
local TabScroll = Instance.new("ScrollingFrame")
TabScroll.Size = UDim2.new(1, -8, 1, 0)
TabScroll.Position = UDim2.new(0, 4, 0, 0)
TabScroll.BackgroundTransparency = 1
TabScroll.BorderSizePixel = 0
TabScroll.ScrollBarThickness = 2
TabScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
TabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
TabScroll.ScrollingDirection = Enum.ScrollingDirection.X
TabScroll.Parent = TabBar

local TabList = Instance.new("UIListLayout")
TabList.FillDirection = Enum.FillDirection.Horizontal
TabList.Padding = UDim.new(0, 5)
TabList.HorizontalAlignment = Enum.HorizontalAlignment.Left
TabList.VerticalAlignment = Enum.VerticalAlignment.Center
TabList.SortOrder = Enum.SortOrder.LayoutOrder
TabList.Parent = TabScroll

TabList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    TabScroll.CanvasSize = UDim2.new(0, TabList.AbsoluteContentSize.X + 8, 0, 0)
end)

-- ===== КОНТЕНТ =====
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -20, 1, -108)
ContentFrame.Position = UDim2.new(0, 10, 0, 98)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- ============ СОХРАНЯЕМ В ГЛОБАЛ ============
getgenv().DeepsikRefs = {
    ScreenGui = ScreenGui,
    MainFrame = MainFrame,
    TitleBar = TitleBar,
    TitleFrame = TitleFrame,
    ContentFrame = ContentFrame,
    TabBar = TabBar,
    TabScroll = TabScroll,
    TabList = TabList,
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
    StarterGui = StarterGui,
    LocalPlayer = LocalPlayer,
    Camera = Camera,
    Config = Config,
    Notify = Notify,
}

print("✅ [Deepsik Hub v2.0] Часть 1/4 — GUI готов")
Notify("⏳ Загрузка 1/4...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v2.0                    ║
    ║      ЧАСТЬ 2/4: UI-компоненты + Combat/Visual
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
if not R then
    warn("❌ [Deepsik] Сначала запусти Часть 1!")
    return
end

local Config = R.Config
local TweenService = R.TweenService
local UserInputService = R.UserInputService
local Lighting = R.Lighting
local Players = R.Players

local ContentFrame = R.ContentFrame
local TabScroll = R.TabScroll

-- ============ ФУНКЦИИ СОЗДАНИЯ ============
local function CreateTab(name, icon)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(0, 100, 0, 28)
    Tab.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Tab.Text = icon .. " " .. name
    Tab.TextColor3 = Color3.fromRGB(200, 200, 210)
    Tab.TextSize = 13
    Tab.Font = Enum.Font.GothamMedium
    Tab.AutoButtonColor = false
    Tab.Parent = TabScroll
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
        TweenService:Create(Bg, TweenInfo.new(0.15), {
            BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
        }):Play()
        TweenService:Create(Ind, TweenInfo.new(0.15), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if callback then callback(state) end
    end)
    return Frame
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 5)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueL = Instance.new("TextLabel")
    ValueL.Size = UDim2.new(0, 50, 0, 20)
    ValueL.Position = UDim2.new(1, -60, 0, 5)
    ValueL.BackgroundTransparency = 1
    ValueL.Text = tostring(default)
    ValueL.TextColor3 = Color3.fromRGB(0, 170, 255)
    ValueL.TextSize = 13
    ValueL.Font = Enum.Font.GothamBold
    ValueL.TextXAlignment = Enum.TextXAlignment.Right
    ValueL.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 8)
    Bar.Position = UDim2.new(0, 12, 0, 32)
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Bar.BorderSizePixel = 0
    Bar.Parent = Frame
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 4)
    BC.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Fill.BorderSizePixel = 0
    Fill.Parent = Bar
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(0, 4)
    FC.Parent = Fill

    local dragging = false
    Bar.InputBegan:Connect(function(input)
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
            local barPos = Bar.AbsolutePosition
            local barSize = Bar.AbsoluteSize
            local rel = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
            local value = math.floor(min + (max - min) * rel)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            ValueL.Text = tostring(value)
            if callback then callback(value) end
        end
    end)
    return Frame
end

local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 200)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 14
    Btn.Font = Enum.Font.GothamBold
    Btn.AutoButtonColor = true
    Btn.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Btn
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
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Label
    return Label
end

-- Экспорт хелперов в глобал (для частей 3 и 4)
getgenv().DeepsikUI = {
    CreateTab = CreateTab,
    CreatePage = CreatePage,
    CreateToggle = CreateToggle,
    CreateSlider = CreateSlider,
    CreateButton = CreateButton,
    CreateLabel = CreateLabel,
}

-- ============ СОЗДАНИЕ ВКЛАДОК ============
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

-- Переключение вкладок (ЕДИНАЯ ФУНКЦИЯ, без конфликтов)
local function SwitchTab(index)
    for i, t in ipairs(tabs) do
        t.Page.Visible = (i == index)
        t.Tab.BackgroundColor3 = (i == index) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 40)
        t.Tab.TextColor3 = (i == index) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
    end
end

for i, t in ipairs(tabs) do
    t.Tab.MouseButton1Click:Connect(function()
        SwitchTab(i)
    end)
end

-- Сохраняем для частей 3-4
R.CombatTab = CombatTab
R.VisualTab = VisualTab
R.MovementTab = MovementTab
R.FarmTab = FarmTab
R.MiscTab = MiscTab
R.CombatPage = CombatPage
R.VisualPage = VisualPage
R.MovementPage = MovementPage
R.FarmPage = FarmPage
R.MiscPage = MiscPage
R.SwitchTab = SwitchTab

-- ============ ВКЛАДКА COMBAT ============
CreateLabel(CombatPage, "⚔️ COMBAT SETTINGS", Color3.fromRGB(0, 170, 255))
CreateToggle(CombatPage, "ESP игроков", Config.ESP, function(s) Config.ESP = s end)
CreateToggle(CombatPage, "Box ESP (рамка)", Config.BoxESP, function(s) Config.BoxESP = s end)
CreateToggle(CombatPage, "Name ESP (имя)", Config.NameESP, function(s) Config.NameESP = s end)
CreateToggle(CombatPage, "Distance ESP (дистанция)", Config.DistanceESP, function(s) Config.DistanceESP = s end)
CreateToggle(CombatPage, "Tracers (линии)", Config.Tracers, function(s) Config.Tracers = s end)
CreateToggle(CombatPage, "Team Check", Config.TeamCheck, function(s) Config.TeamCheck = s end)

-- ============ ВКЛАДКА VISUAL ============
CreateLabel(VisualPage, "👁️ VISUAL SETTINGS", Color3.fromRGB(0, 170, 255))
CreateToggle(VisualPage, "FullBright (яркость)", Config.FullBright, function(s)
    Config.FullBright = s
    if s then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 3
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        Lighting.Brightness = 2
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)
CreateToggle(VisualPage, "Убрать туман", Config.NoFog, function(s)
    Config.NoFog = s
    if s then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 0
    end
end)
CreateButton(VisualPage, "⏰ Время: День", Color3.fromRGB(255, 200, 80), function()
    Lighting.ClockTime = 12
end)
CreateButton(VisualPage, "🌙 Время: Ночь", Color3.fromRGB(50, 50, 100), function()
    Lighting.ClockTime = 0
end)

print("✅ [Deepsik Hub v2.0] Часть 2/4 — Combat/Visual готовы")
R.Notify("⏳ Загрузка 2/4...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v2.0                    ║
    ║      ЧАСТЬ 3/4: Movement + Farm          ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then
    warn("❌ [Deepsik] Сначала запусти Части 1 и 2!")
    return
end

local Config = R.Config
local LocalPlayer = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera
local TeleportService = R.TeleportService
local MovementPage = R.MovementPage
local FarmPage = R.FarmPage

-- ============ SPEED / JUMP / NOCLIP / FLY ============
local function UpdateSpeed()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.SpeedHack and Config.SpeedValue or 16
    end
end

local function UpdateJump()
    local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = Config.JumpPower and Config.JumpValue or 50
        hum.UseJumpPower = true
    end
end

-- Обновление при респавне
local charConn = LocalPlayer.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.5)
    UpdateSpeed()
    UpdateJump()
end)
table.insert(getgenv().DeepsikConns, charConn)

-- Infinite Jump
local jumpConn = UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end)
table.insert(getgenv().DeepsikConns, jumpConn)

-- Noclip
local noclipConn = RunService.Stepped:Connect(function()
    if Config.Noclip and LocalPlayer.Character then
        for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)
table.insert(getgenv().DeepsikConns, noclipConn)

-- Fly
local flyConns = {render = nil, vel = nil, gyro = nil}

local function StopFly()
    if flyConns.render then flyConns.render:Disconnect(); flyConns.render = nil end
    if flyConns.vel and flyConns.vel.Parent then flyConns.vel:Destroy() end
    if flyConns.gyro and flyConns.gyro.Parent then flyConns.gyro:Destroy() end
    flyConns.vel = nil
    flyConns.gyro = nil
end

local function StartFly()
    StopFly()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyConns.vel = Instance.new("BodyVelocity")
    flyConns.vel.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyConns.vel.Velocity = Vector3.new(0, 0, 0)
    flyConns.vel.Parent = hrp

    flyConns.gyro = Instance.new("BodyGyro")
    flyConns.gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyConns.gyro.P = 10000
    flyConns.gyro.Parent = hrp

    flyConns.render = RunService.RenderStepped:Connect(function()
        if not Config.Fly then StopFly(); return end
        local char = LocalPlayer.Character
        local h = char and char:FindFirstChild("HumanoidRootPart")
        if not h then StopFly(); return end

        local dir = Vector3.new(0, 0, 0)
        local cam = Workspace.CurrentCamera
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit * Config.FlySpeed end

        flyConns.vel.Velocity = dir
        flyConns.gyro.CFrame = cam.CFrame
    end)
end
getgenv().DeepsikStopFly = StopFly

-- Anti-AFK
local afkConn = LocalPlayer.Idled:Connect(function()
    if not Config.AntiAFK then return end
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end)
table.insert(getgenv().DeepsikConns, afkConn)

-- ============ UI: MOVEMENT ============
UI.CreateLabel(MovementPage, "🏃 MOVEMENT SETTINGS", Color3.fromRGB(0, 170, 255))

UI.CreateToggle(MovementPage, "Speed Hack", Config.SpeedHack, function(s)
    Config.SpeedHack = s
    UpdateSpeed()
end)
UI.CreateSlider(MovementPage, "Скорость", 16, 250, Config.SpeedValue, function(v)
    Config.SpeedValue = v
    UpdateSpeed()
end)
UI.CreateToggle(MovementPage, "Jump Power", Config.JumpPower, function(s)
    Config.JumpPower = s
    UpdateJump()
end)
UI.CreateSlider(MovementPage, "Сила прыжка", 50, 500, Config.JumpValue, function(v)
    Config.JumpValue = v
    UpdateJump()
end)
UI.CreateToggle(MovementPage, "Infinite Jump", Config.InfiniteJump, function(s) Config.InfiniteJump = s end)
UI.CreateToggle(MovementPage, "Noclip", Config.Noclip, function(s) Config.Noclip = s end)
UI.CreateToggle(MovementPage, "Fly (полёт)", Config.Fly, function(s)
    Config.Fly = s
    if s then
        StartFly()
    else
        StopFly()
    end
end)
UI.CreateSlider(MovementPage, "Скорость полёта", 10, 300, Config.FlySpeed, function(v)
    Config.FlySpeed = v
end)
UI.CreateToggle(MovementPage, "Anti-AFK", Config.AntiAFK, function(s) Config.AntiAFK = s end)

-- ==================================================================
-- ==================== FARM ========================================
-- ==================================================================
local function GetMyChar()
    local char = LocalPlayer.Character
    if not char then return nil, nil, nil end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
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
                if not (Config.TeamCheck and plr.Team == LocalPlayer.Team and plr.Team ~= nil) then
                    table.insert(targets, {
                        player = plr, hrp = hrp, humanoid = hum,
                        dist = (myHrp.Position - hrp.Position).Magnitude
                    })
                end
            end
        end
    end
    table.sort(targets, function(a, b) return a.dist < b.dist end)
    return targets
end
getgenv().DeepsikGetTargets = GetTargets

local function GetEquippedTool()
    local char = LocalPlayer.Character
    if not char then return nil end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return c end
    end
    return nil
end

-- ===== AUTO FARM =====
local autoFarmConn = nil
local function StartAutoFarm()
    if autoFarmConn then autoFarmConn:Disconnect() end
    autoFarmConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoFarm then return end
        local _, myHrp, myHum = GetMyChar()
        if not myHrp or not myHum or myHum.Health <= 0 then return end
        local targets = GetTargets()
        if #targets == 0 then return end
        local t = targets[1]
        if t.dist > Config.AutoFarmRange then return end
        pcall(function()
            myHrp.CFrame = t.hrp.CFrame * CFrame.new(0, 0, 2)
            myHrp.Velocity = Vector3.new(0, 0, 0)
        end)
        local tool = GetEquippedTool()
        if tool then pcall(function() tool:Activate() end) end
    end)
end

-- ===== AUTO SHOOT =====
local autoShootConn = nil
local function StartAutoShoot()
    if autoShootConn then autoShootConn:Disconnect() end
    autoShootConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoShoot then return end
        local tool = GetEquippedTool()
        if not tool then return end
        local targets = GetTargets()
        if #targets == 0 then return end
        local t = targets[1]
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, t.hrp.Position)
        pcall(function() tool:Activate() end)
    end)
end

-- ===== AUTO COLLECT GUNS =====
local autoCollectConn = nil
local function StartAutoCollect()
    if autoCollectConn then autoCollectConn:Disconnect() end
    autoCollectConn = RunService.Heartbeat:Connect(function()
        if not Config.AutoCollectGuns then return end
        local _, myHrp = GetMyChar()
        if not myHrp then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") and obj.Parent ~= LocalPlayer.Character then
                local h = obj:FindFirstChild("Handle")
                if h and (myHrp.Position - h.Position).Magnitude < 60 then
                    pcall(function() h.CFrame = myHrp.CFrame end)
                end
            end
        end
    end)
end

-- ===== KILL AURA =====
local auraConn = nil
local function StartKillAura()
    if auraConn then auraConn:Disconnect() end
    auraConn = RunService.Heartbeat:Connect(function()
        if not Config.KillAura then return end
        local tool = GetEquippedTool()
        if not tool then return end
        local targets = GetTargets()
        for _, t in ipairs(targets) do
            if t.dist <= Config.AuraRange then
                pcall(function() tool:Activate() end)
                task.wait(Config.FarmDelay)
            end
        end
    end)
end

-- ===== KILL ALL =====
local function KillAll()
    local _, myHrp = GetMyChar()
    local tool = GetEquippedTool()
    if not myHrp then R.Notify("❌ Нет персонажа", 3); return end
    if not tool then R.Notify("❌ Возьми нож в руки", 3); return end

    local orig = myHrp.CFrame
    local targets = GetTargets()
    R.Notify(string.format("💀 Kill All: %d целей", #targets), 3)
    for _, t in ipairs(targets) do
        pcall(function() myHrp.CFrame = t.hrp.CFrame * CFrame.new(0, 0, 2) end)
        task.wait(Config.FarmDelay)
        pcall(function() tool:Activate() end)
    end
    task.wait(0.1)
    pcall(function() myHrp.CFrame = orig end)
    R.Notify("✅ Kill All завершён", 3)
end

-- ===== COIN FARM =====
local coinConn = nil
local function StartCoinFarm()
    if coinConn then coinConn:Disconnect() end
    coinConn = RunService.Heartbeat:Connect(function()
        if not Config.CoinFarm then return end
        local _, myHrp = GetMyChar()
        if not myHrp then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Name:lower():find("coin") then
                local d = (myHrp.Position - obj.Position).Magnitude
                if d < 100 and d > 3 then
                    pcall(function()
                        myHrp.CFrame = CFrame.new(obj.Position + Vector3.new(0, 3, 0))
                    end)
                end
            end
        end
    end)
end

-- ============ UI: FARM ============
UI.CreateLabel(FarmPage, "🌾 FARM - AUTO SETTINGS", Color3.fromRGB(0, 170, 255))

UI.CreateToggle(FarmPage, "Auto Farm (телепорт + удар)", Config.AutoFarm, function(s)
    Config.AutoFarm = s
    if s then StartAutoFarm() elseif autoFarmConn then autoFarmConn:Disconnect() end
end)
UI.CreateSlider(FarmPage, "Дистанция Farm", 50, 500, Config.AutoFarmRange, function(v) Config.AutoFarmRange = v end)

UI.CreateToggle(FarmPage, "Auto Shoot (авто-выстрел)", Config.AutoShoot, function(s)
    Config.AutoShoot = s
    if s then StartAutoShoot() elseif autoShootConn then autoShootConn:Disconnect() end
end)
UI.CreateToggle(FarmPage, "Auto Collect Guns", Config.AutoCollectGuns, function(s)
    Config.AutoCollectGuns = s
    if s then StartAutoCollect() elseif autoCollectConn then autoCollectConn:Disconnect() end
end)
UI.CreateToggle(FarmPage, "Kill Aura", Config.KillAura, function(s)
    Config.KillAura = s
    if s then StartKillAura() elseif auraConn then auraConn:Disconnect() end
end)
UI.CreateSlider(FarmPage, "Радиус Aura", 5, 100, Config.AuraRange, function(v) Config.AuraRange = v end)

UI.CreateToggle(FarmPage, "Coin Farm", Config.CoinFarm, function(s)
    Config.CoinFarm = s
    if s then StartCoinFarm() elseif coinConn then coinConn:Disconnect() end
end)
UI.CreateSlider(FarmPage, "Задержка удара (сек ×10)", 0, 10, math.floor(Config.FarmDelay * 10), function(v)
    Config.FarmDelay = v / 10
end)

UI.CreateButton(FarmPage, "💀 KILL ALL (нужен нож)", Color3.fromRGB(200, 50, 50), KillAll)

print("✅ [Deepsik Hub v2.0] Часть 3/4 — Movement/Farm готовы")
R.Notify("⏳ Загрузка 3/4...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v2.0                    ║
    ║      ЧАСТЬ 4/4: ESP + Misc + Управление  ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then
    warn("❌ [Deepsik] Сначала запусти Части 1-3!")
    return
end

local Config = R.Config
local LocalPlayer = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Camera = R.Camera
local Lighting = R.Lighting
local TweenService = R.TweenService
local TeleportService = R.TeleportService
local MiscPage = R.MiscPage
local MainFrame = R.MainFrame
local TitleBar = R.TitleBar
local TitleFrame = R.TitleFrame
local ContentFrame = R.ContentFrame
local TabBar = R.TabBar
local ScreenGui = R.ScreenGui
local CloseBtn = R.CloseBtn
local MinBtn = R.MinBtn
local ToggleBtn = R.ToggleBtn
local ESPObjects = getgenv().DeepsikESP

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

local function UpdateESP()
    for player, objs in pairs(ESPObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        local show = Config.ESP and hum and hum.Health > 0 and hrp and head
        if show and Config.TeamCheck and player.Team == LocalPlayer.Team and player.Team ~= nil then
            show = false
        end

        if not show then
            objs.Box.Visible = false
            objs.NameTag.Visible = false
            objs.DistanceTag.Visible = false
            objs.Tracer.Visible = false
            continue
        end

        local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
        local hrpPos, hrpOn = Camera:WorldToViewportPoint(hrp.Position)

        if headOn and hrpOn then
            local height = math.abs(headPos.Y - hrpPos.Y) * 2
            local width = height * 0.6

            if Config.BoxESP then
                objs.Box.Size = Vector2.new(width, height)
                objs.Box.Position = Vector2.new(headPos.X - width / 2, headPos.Y)
                objs.Box.Color = Config.ESPColor
                objs.Box.Visible = true
            else
                objs.Box.Visible = false
            end

            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude

            if Config.NameESP then
                objs.NameTag.Text = player.Name
                objs.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 20)
                objs.NameTag.Visible = true
            else
                objs.NameTag.Visible = false
            end

            if Config.DistanceESP then
                objs.DistanceTag.Text = string.format("[%d studs]", math.floor(dist))
                objs.DistanceTag.Position = Vector2.new(headPos.X, headPos.Y + height + 2)
                objs.DistanceTag.Visible = true
            else
                objs.DistanceTag.Visible = false
            end

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

-- Инициализация ESP
for _, plr in ipairs(Players:GetPlayers()) do CreateESP(plr) end

table.insert(getgenv().DeepsikConns, Players.PlayerAdded:Connect(CreateESP))
table.insert(getgenv().DeepsikConns, Players.PlayerRemoving:Connect(RemoveESP))
table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
    pcall(UpdateESP)
end))

-- ============ ВКЛАДКА MISC ============
UI.CreateLabel(MiscPage, "⚙️ MISC SETTINGS", Color3.fromRGB(0, 170, 255))

UI.CreateToggle(MiscPage, "Тёмная тема", Config.DarkTheme, function(state)
    Config.DarkTheme = state
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

UI.CreateLabel(MiscPage, "📊 СТАТИСТИКА", Color3.fromRGB(0, 170, 255))

local StatsLabel = Instance.new("TextLabel")
StatsLabel.Size = UDim2.new(1, -10, 0, 90)
StatsLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
StatsLabel.Text = "Загрузка..."
StatsLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
StatsLabel.TextSize = 13
StatsLabel.Font = Enum.Font.GothamMedium
StatsLabel.TextXAlignment = Enum.TextXAlignment.Left
StatsLabel.TextYAlignment = Enum.TextYAlignment.Top
StatsLabel.Parent = MiscPage
local SCorner = Instance.new("UICorner")
SCorner.CornerRadius = UDim.new(0, 6)
SCorner.Parent = StatsLabel
local SPad = Instance.new("UIPadding")
SPad.PaddingTop = UDim.new(0, 8)
SPad.PaddingLeft = UDim.new(0, 12)
SPad.Parent = StatsLabel

-- Обновление статистики
task.spawn(function()
    while StatsLabel.Parent do
        local players = #Players:GetPlayers()
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        StatsLabel.Text = string.format(
            "👥 Игроков: %d\n📡 Ping: %d ms\n🔫 ESP: %s\n⚡ Speed: %s",
            players, ping,
            Config.ESP and "ВКЛ" or "ВЫКЛ",
            Config.SpeedHack and "ВКЛ" or "ВЫКЛ"
        )
        task.wait(1)
    end
end)

UI.CreateLabel(MiscPage, "🔧 ДЕЙСТВИЯ", Color3.fromRGB(0, 170, 255))

UI.CreateButton(MiscPage, "🔄 Перезагрузить скрипт", Color3.fromRGB(200, 120, 0), function()
    R.Notify("🔄 Перезагрузка... Запусти скрипт заново", 4)
    ScreenGui:Destroy()
end)

UI.CreateButton(MiscPage, "🔫 Отключить ESP", Color3.fromRGB(150, 100, 200), function()
    Config.ESP = false
    Config.Tracers = false
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do
            pcall(function() obj.Visible = false end)
        end
    end
    R.Notify("🔫 ESP выключен", 2)
end)

UI.CreateButton(MiscPage, "🌍 Rejoin сервер", Color3.fromRGB(0, 120, 200), function()
    R.Notify("🌍 Перезаход...", 2)
    TeleportService:Teleport(game.PlaceId, LocalPlayer)
end)

UI.CreateButton(MiscPage, "❌ Выгрузить Deepsik Hub", Color3.fromRGB(200, 50, 50), function()
    if getgenv().DeepsikStopFly then getgenv().DeepsikStopFly() end
    for _, objs in pairs(ESPObjects) do
        for _, obj in pairs(objs) do
            pcall(function() obj:Remove() end)
        end
    end
    for _, conn in pairs(getgenv().DeepsikConns or {}) do
        pcall(function() conn:Disconnect() end)
    end
    ScreenGui:Destroy()
    getgenv().DeepsikGui = nil
    getgenv().DeepsikRefs = nil
    R.Notify("❌ Hub выгружен", 2)
end)

UI.CreateLabel(MiscPage, "💙 Deepsik Hub v2.0 | Made by Deepsik", Color3.fromRGB(0, 170, 255))

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
local hotkeyConn = UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end

    if input.KeyCode == Enum.KeyCode.RightShift then
        MainFrame.Visible = not MainFrame.Visible
        ToggleBtn.Visible = not MainFrame.Visible
    end

    if input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
        ToggleBtn.Visible = not MainFrame.Visible
    end

    if input.KeyCode == Enum.KeyCode.Delete then
        if getgenv().DeepsikStopFly then getgenv().DeepsikStopFly() end
        for _, objs in pairs(ESPObjects) do
            for _, obj in pairs(objs) do
                pcall(function() obj:Remove() end)
            end
        end
        for _, conn in pairs(getgenv().DeepsikConns or {}) do
            pcall(function() conn:Disconnect() end)
        end
        ScreenGui:Destroy()
        getgenv().DeepsikGui = nil
        getgenv().DeepsikRefs = nil
    end
end)
table.insert(getgenv().DeepsikConns, hotkeyConn)

-- ============ ИНИЦИАЛИЗАЦИЯ ============
R.SwitchTab(1)

print([[
╔══════════════════════════════════════════╗
║     🔫 DEEPSIK HUB v2.0 ЗАГРУЖЕН! 🔫     ║
║     ─────────────────────────────        ║
║     RightShift / F1 — открыть/закрыть    ║
║     Delete — выгрузить скрипт            ║
╚══════════════════════════════════════════╝
]])
R.Notify("✅ Deepsik Hub v2.0 запущен!", 3)
