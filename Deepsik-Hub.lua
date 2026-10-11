--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.0 - MM2              ║
    ║      ЧАСТЬ 1/6: Ядро + GUI               ║
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
local HttpService = game:GetService("HttpService")

local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- ============ ДЕФОЛТНЫЙ КОНФИГ ============
local DefaultConfig = {
    -- Main
    ESP = false, RoleESP = true, GunESP = false,
    ESPColor = Color3.fromRGB(0, 170, 255),
    TeamCheck = false,

    -- Movement
    Noclip = false,
    InfiniteJump = false,
    AntiFling = false,
    BombJump = false,
    Fly = false, FlySpeed = 50,
    Spin = false, SpinSpeed = 10,
    Bhop = false,
    Invis = false,
    InvisBind = false,

    -- Combat: Sheriff
    AutoPickupGun = false,
    SilentAim = false, SilentAimFOV = 100,
    AimAssistMurder = false, AimAssistMurderFOV = 100,

    -- Combat: Murder
    KillAura = false, AuraRange = 30,
    KillAll = false,
    KillOnlySheriff = false,
    KnifeAimbot = false,
    AimAssistAll = false, AimAssistAllFOV = 100,

    -- Teleport
    -- (кнопки)

    -- Trolling: Troll
    TouchFling = false,
    ClickFling = false,

    -- Trolling: Fun
    Emotes = false,
    FakeKorblox = false,
    FakeHeadless = false,
    FakeSpeed = false,
    FakeJump = false,
    WallHop = false,

    -- Visuals
    CustomSky = false, SkyID = "",
    BulletLaser = false,
    CameraFollowKnife = false,

    -- Settings
    DarkTheme = true,
    AntiAFK = true,
}

-- ============ ЗАГРУЗКА / СОХРАНЕНИЕ КОНФИГА ============
local ConfigFolder = "DeepsikHub"
local function SaveConfig(name)
    pcall(function()
        if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        local path = ConfigFolder .. "/" .. (name or "default") .. ".json"
        writefile(path, HttpService:JSONEncode(getgenv().DeepsikConfig))
    end)
end

local function LoadConfig(name)
    local ok, data = pcall(function()
        local path = ConfigFolder .. "/" .. (name or "default") .. ".json"
        if isfile and isfile(path) then
            return HttpService:JSONDecode(readfile(path))
        end
        return nil
    end)
    return ok and data or nil
end

local function ListConfigs()
    local list = {}
    pcall(function()
        if isfolder and isfolder(ConfigFolder) then
            for _, f in ipairs(listfiles(ConfigFolder)) do
                local n = f:match("([^/\\]+)%.json$")
                if n then table.insert(list, n) end
            end
        end
    end)
    return list
end

-- Инициализация
getgenv().DeepsikConfig = getgenv().DeepsikConfig or {}
for k, v in pairs(DefaultConfig) do
    if getgenv().DeepsikConfig[k] == nil then
        getgenv().DeepsikConfig[k] = v
    end
end
local Config = getgenv().DeepsikConfig

-- Очистка старых
if getgenv().DeepsikGui then pcall(function() getgenv().DeepsikGui:Destroy() end) end
for _, c in pairs(getgenv().DeepsikConns or {}) do pcall(function() c:Disconnect() end) end
getgenv().DeepsikConns = {}
getgenv().DeepsikESP = getgenv().DeepsikESP or {}

-- ============ УВЕДОМЛЕНИЯ ============
local function Notify(text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Deepsik Hub", Text = text, Duration = dur or 3
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
ScreenGui.Parent = LP:WaitForChild("PlayerGui")
getgenv().DeepsikGui = ScreenGui

-- Главное окно
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 620, 0, 420)
MainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
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
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local TitleMask = Instance.new("Frame")
TitleMask.Size = UDim2.new(1, 0, 0, 20)
TitleMask.Position = UDim2.new(0, 0, 1, -20)
TitleMask.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
TitleMask.BorderSizePixel = 0
TitleMask.Parent = TitleBar

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
VersionLabel.Text = "v3.0"
VersionLabel.TextColor3 = Color3.fromRGB(120, 120, 130)
VersionLabel.TextSize = 14
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.Parent = TitleBar

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

-- Плавающая кнопка
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

-- ===== САЙДБАР КАТЕГОРИЙ (слева) =====
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 130, 1, -65)
SideBar.Position = UDim2.new(0, 10, 0, 55)
SideBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
SideBar.BorderSizePixel = 0
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 8)
SideCorner.Parent = SideBar

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Size = UDim2.new(1, -6, 1, -10)
SideScroll.Position = UDim2.new(0, 3, 0, 5)
SideScroll.BackgroundTransparency = 1
SideScroll.BorderSizePixel = 0
SideScroll.ScrollBarThickness = 2
SideScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SideScroll.Parent = SideBar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 5)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideScroll

SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SideScroll.CanvasSize = UDim2.new(0, 0, 0, SideLayout.AbsoluteContentSize.Y + 10)
end)

-- ===== КОНТЕНТ (справа) =====
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -160, 1, -65)
ContentFrame.Position = UDim2.new(0, 150, 0, 55)
ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 8)
ContentCorner.Parent = ContentFrame

-- ============ СОХРАНЕНИЕ ССЫЛОК ============
getgenv().DeepsikRefs = {
    ScreenGui = ScreenGui,
    MainFrame = MainFrame,
    TitleBar = TitleBar,
    ContentFrame = ContentFrame,
    SideBar = SideBar,
    SideScroll = SideScroll,
    SideLayout = SideLayout,
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
    HttpService = HttpService,
    LocalPlayer = LP,
    Camera = Camera,
    Config = Config,
    Notify = Notify,
    SaveConfig = SaveConfig,
    LoadConfig = LoadConfig,
    ListConfigs = ListConfigs,
}

print("✅ [Deepsik v3.0] Часть 1/6 — Ядро + GUI готовы")
Notify("⏳ Загрузка 1/6...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.0                    ║
    ║      ЧАСТЬ 2/6: UI-компоненты            ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
if not R then warn("❌ Сначала запусти Часть 1!") return end

local TweenService = R.TweenService
local UserInputService = R.UserInputService
local ContentFrame = R.ContentFrame
local SideScroll = R.SideScroll

-- ============ ФАБРИКА ЭЛЕМЕНТОВ ============

-- Вкладка (сайдбар)
local function CreateCategory(name, icon)
    local Cat = Instance.new("TextButton")
    Cat.Size = UDim2.new(1, -6, 0, 32)
    Cat.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    Cat.Text = "  " .. icon .. "  " .. name
    Cat.TextColor3 = Color3.fromRGB(200, 200, 210)
    Cat.TextSize = 13
    Cat.Font = Enum.Font.GothamMedium
    Cat.TextXAlignment = Enum.TextXAlignment.Left
    Cat.AutoButtonColor = false
    Cat.Parent = SideScroll
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Cat
    return Cat
end

-- Страница категории
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
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 6)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = Page
    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, L.AbsoluteContentSize.Y + 10)
    end)
    return Page
end

-- Заголовок секции
local function CreateSection(parent, text)
    local Sec = Instance.new("TextLabel")
    Sec.Size = UDim2.new(1, -10, 0, 26)
    Sec.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Sec.Text = "  " .. text
    Sec.TextColor3 = Color3.fromRGB(0, 170, 255)
    Sec.TextSize = 13
    Sec.Font = Enum.Font.GothamBold
    Sec.TextXAlignment = Enum.TextXAlignment.Left
    Sec.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 5)
    C.Parent = Sec
    return Sec
end

-- Тумблер
local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 32)
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
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 38, 0, 18)
    Bg.Position = UDim2.new(1, -50, 0.5, -9)
    Bg.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(60, 60, 70)
    Bg.BorderSizePixel = 0
    Bg.Parent = Frame
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = Bg

    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 14, 0, 14)
    Ind.Position = default and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
    Ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ind.BorderSizePixel = 0
    Ind.Parent = Bg
    local IC = Instance.new("UICorner")
    IC.CornerRadius = UDim.new(0, 10)
    IC.Parent = Ind

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
            Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
        }):Play()
        if callback then callback(state) end
    end)

    -- Возвращаем объект с методом set для конфига
    return {
        Frame = Frame,
        Set = function(v)
            if v ~= state then Btn.MouseButton1Click:Fire? end
        end
    }, Btn
end

-- Слайдер
local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 48)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 0, 20)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ValueL = Instance.new("TextLabel")
    ValueL.Size = UDim2.new(0, 50, 0, 20)
    ValueL.Position = UDim2.new(1, -60, 0, 4)
    ValueL.BackgroundTransparency = 1
    ValueL.Text = tostring(default)
    ValueL.TextColor3 = Color3.fromRGB(0, 170, 255)
    ValueL.TextSize = 13
    ValueL.Font = Enum.Font.GothamBold
    ValueL.TextXAlignment = Enum.TextXAlignment.Right
    ValueL.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -24, 0, 8)
    Bar.Position = UDim2.new(0, 12, 0, 30)
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
            local m = UserInputService:GetMouseLocation()
            local bp = Bar.AbsolutePosition
            local bs = Bar.AbsoluteSize
            local rel = math.clamp((m.X - bp.X) / bs.X, 0, 1)
            local v = math.floor(min + (max - min) * rel)
            Fill.Size = UDim2.new(rel, 0, 1, 0)
            ValueL.Text = tostring(v)
            if callback then callback(v) end
        end
    end)
    return Frame
end

-- Кнопка
local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 32)
    Btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 200)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
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

-- Текстовое поле (ввод)
local function CreateInput(parent, placeholder, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 32)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -20, 1, -8)
    Box.Position = UDim2.new(0, 10, 0, 4)
    Box.BackgroundTransparency = 1
    Box.Text = default or ""
    Box.PlaceholderText = placeholder or "Введите..."
    Box.PlaceholderColor3 = Color3.fromRGB(120, 120, 130)
    Box.TextColor3 = Color3.fromRGB(220, 220, 230)
    Box.TextSize = 13
    Box.Font = Enum.Font.GothamMedium
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false
    Box.Parent = Frame

    Box.FocusLost:Connect(function()
        if callback then callback(Box.Text) end
    end)
    return Frame, Box
end

-- Дропдаун (список выбора)
local function CreateDropdown(parent, text, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 32)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, -10, 0, 32)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Selected = Instance.new("TextButton")
    Selected.Size = UDim2.new(0.5, -10, 0, 24)
    Selected.Position = UDim2.new(0.5, 0, 0, 4)
    Selected.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    Selected.Text = default or options[1] or "—"
    Selected.TextColor3 = Color3.fromRGB(255, 255, 255)
    Selected.TextSize = 12
    Selected.Font = Enum.Font.GothamBold
    Selected.Parent = Frame
    local SC = Instance.new("UICorner")
    SC.CornerRadius = UDim.new(0, 5)
    SC.Parent = Selected

    local open = false
    local optionFrames = {}

    Selected.MouseButton1Click:Connect(function()
        open = not open
        for _, of in ipairs(optionFrames) do of.Visible = open end
        Frame.Size = open and UDim2.new(1, -10, 0, 32 + #options * 26) or UDim2.new(1, -10, 0, 32)
    end)

    local currentValue = default or options[1] or "—"

    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, -10, 0, 24)
        OptBtn.Position = UDim2.new(0, 5, 0, 32 + (i - 1) * 26)
        OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
        OptBtn.TextSize = 12
        OptBtn.Font = Enum.Font.GothamMedium
        OptBtn.Visible = false
        OptBtn.Parent = Frame
        local OC = Instance.new("UICorner")
        OC.CornerRadius = UDim.new(0, 5)
        OC.Parent = OptBtn

        OptBtn.MouseButton1Click:Connect(function()
            currentValue = opt
            Selected.Text = opt
            open = false
            for _, of in ipairs(optionFrames) do of.Visible = false end
            Frame.Size = UDim2.new(1, -10, 0, 32)
            if callback then callback(opt) end
        end)
        table.insert(optionFrames, OptBtn)
    end

    return Frame
end

-- ============ ЭКСПОРТ ============
getgenv().DeepsikUI = {
    CreateCategory = CreateCategory,
    CreatePage = CreatePage,
    CreateSection = CreateSection,
    CreateToggle = CreateToggle,
    CreateSlider = CreateSlider,
    CreateButton = CreateButton,
    CreateInput = CreateInput,
    CreateDropdown = CreateDropdown,
}

print("✅ [Deepsik v3.0] Часть 2/6 — UI-компоненты готовы")
R.Notify("⏳ Загрузка 2/6...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.0                    ║
    ║      ЧАСТЬ 3/6: Категории + Main/Movement
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-2!") return end

local Config = R.Config
local LP = R.LocalPlayer
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera
local ContentFrame = R.ContentFrame

-- ============ СОЗДАНИЕ КАТЕГОРИЙ ============
local CatMain = UI.CreateCategory("Main", "🏠")
local CatCombat = UI.CreateCategory("Combat", "⚔️")
local CatMovement = UI.CreateCategory("Movement", "🏃")
local CatTeleport = UI.CreateCategory("Teleport", "🌐")
local CatTrolling = UI.CreateCategory("Trolling", "🎭")
local CatVisuals = UI.CreateCategory("Visuals", "🎨")
local CatSettings = UI.CreateCategory("Settings", "⚙️")

local PageMain = UI.CreatePage(ContentFrame)
local PageCombat = UI.CreatePage(ContentFrame)
local PageMovement = UI.CreatePage(ContentFrame)
local PageTeleport = UI.CreatePage(ContentFrame)
local PageTrolling = UI.CreatePage(ContentFrame)
local PageVisuals = UI.CreatePage(ContentFrame)
local PageSettings = UI.CreatePage(ContentFrame)

local categories = {
    {Tab = CatMain, Page = PageMain},
    {Tab = CatCombat, Page = PageCombat},
    {Tab = CatMovement, Page = PageMovement},
    {Tab = CatTeleport, Page = PageTeleport},
    {Tab = CatTrolling, Page = PageTrolling},
    {Tab = CatVisuals, Page = PageVisuals},
    {Tab = CatSettings, Page = PageSettings},
}

local function SwitchCategory(idx)
    for i, c in ipairs(categories) do
        c.Page.Visible = (i == idx)
        c.Tab.BackgroundColor3 = (i == idx) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 40)
        c.Tab.TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 210)
    end
end

for i, c in ipairs(categories) do
    c.Tab.MouseButton1Click:Connect(function() SwitchCategory(i) end)
end

-- Экспорт
R.PageMain = PageMain
R.PageCombat = PageCombat
R.PageMovement = PageMovement
R.PageTeleport = PageTeleport
R.PageTrolling = PageTrolling
R.PageVisuals = PageVisuals
R.PageSettings = PageSettings
R.SwitchCategory = SwitchCategory

-- ==================================================================
-- КАТЕГОРИЯ MAIN
-- ==================================================================
UI.CreateSection(PageMain, "🎯 ESP (Player & Role)")
UI.CreateToggle(PageMain, "ESP игроков", Config.ESP, function(s) Config.ESP = s end)
UI.CreateToggle(PageMain, "Role ESP (роль: Innocent/Sheriff/Murder)", Config.RoleESP, function(s) Config.RoleESP = s end)
UI.CreateToggle(PageMain, "Gun ESP (оружие на полу)", Config.GunESP, function(s) Config.GunESP = s end)
UI.CreateToggle(PageMain, "Team Check", Config.TeamCheck, function(s) Config.TeamCheck = s end)

UI.CreateSection(PageMain, "🎨 Цвет ESP")
UI.CreateSlider(PageMain, "R", 0, 255, 0, function(v) Config.ESPColor = Color3.fromRGB(v, Config.ESPColor.G * 255, Config.ESPColor.B * 255) end)
UI.CreateSlider(PageMain, "G", 0, 255, 170, function(v) Config.ESPColor = Color3.fromRGB(Config.ESPColor.R * 255, v, Config.ESPColor.B * 255) end)
UI.CreateSlider(PageMain, "B", 0, 255, 255, function(v) Config.ESPColor = Color3.fromRGB(Config.ESPColor.R * 255, Config.ESPColor.G * 255, v) end)

-- ==================================================================
-- КАТЕГОРИЯ MOVEMENT
-- ==================================================================
UI.CreateSection(PageMovement, "🏃 BASIC")

UI.CreateToggle(PageMovement, "Noclip", Config.Noclip, function(s) Config.Noclip = s end)
UI.CreateToggle(PageMovement, "Infinite Jump", Config.InfiniteJump, function(s) Config.InfiniteJump = s end)
UI.CreateToggle(PageMovement, "Anti-Fling (анти-откидывание)", Config.AntiFling, function(s) Config.AntiFling = s end)
UI.CreateToggle(PageMovement, "Bomb Jump (прыжок от взрыва)", Config.BombJump, function(s) Config.BombJump = s end)

UI.CreateSection(PageMovement, "🕊️ FLY")
UI.CreateToggle(PageMovement, "Fly (полёт)", Config.Fly, function(s)
    Config.Fly = s
    if s and getgenv().DeepsikStartFly then getgenv().DeepsikStartFly()
    elseif getgenv().DeepsikStopFly then getgenv().DeepsikStopFly() end
end)
UI.CreateSlider(PageMovement, "Скорость полёта", 10, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end)

UI.CreateSection(PageMovement, "🌀 ДОПОЛНИТЕЛЬНО")
UI.CreateToggle(PageMovement, "Spin (вращение)", Config.Spin, function(s) Config.Spin = s end)
UI.CreateSlider(PageMovement, "Скорость Spin", 1, 50, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)

UI.CreateToggle(PageMovement, "Bhop (авто-прыжок)", Config.Bhop, function(s) Config.Bhop = s end)

UI.CreateSection(PageMovement, "👻 INVIS")
UI.CreateToggle(PageMovement, "Invis (невидимость)", Config.Invis, function(s) Config.Invis = s end)
UI.CreateToggle(PageMovement, "Invis Bind (кнопка привязки)", Config.InvisBind, function(s) Config.InvisBind = s end)

UI.CreateSection(PageMovement, "⚡ SPEED")

-- Логика движений
local function UpdateSpeed()
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = Config.SpeedHack and Config.SpeedValue or 16
    end
end
Config.SpeedHack = Config.SpeedHack or false
Config.SpeedValue = Config.SpeedValue or 60
UI.CreateToggle(PageMovement, "Speed Hack", Config.SpeedHack, function(s) Config.SpeedHack = s; UpdateSpeed() end)
UI.CreateSlider(PageMovement, "Скорость", 16, 250, Config.SpeedValue, function(v) Config.SpeedValue = v; UpdateSpeed() end)

-- ===== CONNECTIONS =====

-- Обновление скорости при респавне
table.insert(getgenv().DeepsikConns, LP.CharacterAdded:Connect(function(char)
    char:WaitForChild("Humanoid")
    task.wait(0.3)
    UpdateSpeed()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.JumpPower = Config.JumpPower and Config.JumpValue or 50
    end
end))

-- Infinite Jump
table.insert(getgenv().DeepsikConns, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- Noclip
table.insert(getgenv().DeepsikConns, RunService.Stepped:Connect(function()
    if Config.Noclip and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

-- Bhop
table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.Bhop and input.KeyCode == Enum.KeyCode.Space then
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
    end
end))

-- Spin
local spinAngle = 0
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function(dt)
    if not Config.Spin then return end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        spinAngle = spinAngle + math.rad(Config.SpinSpeed) * dt * 60
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, spinAngle, 0)
    end
end))

-- Invis
local function ApplyInvis()
    if not LP.Character then return end
    for _, part in ipairs(LP.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function()
                part.LocalTransparencyModifier = Config.Invis and 1 or 0
                part.Transparency = Config.Invis and 1 or 0
            end)
        end
    end
end
table.insert(getgenv().DeepsikConns, RunService.Stepped:Connect(function()
    if Config.Invis then
        ApplyInvis()
    end
end))

-- Anti-Fling
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.AntiFling then return end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        -- Ограничиваем скорость
        if hrp.Velocity.Magnitude > 200 then
            hrp.Velocity = hrp.Velocity.Unit * 200
        end
    end
end))

-- Anti-AFK
table.insert(getgenv().DeepsikConns, LP.Idled:Connect(function()
    if not Config.AntiAFK then return end
    local vu = game:GetService("VirtualUser")
    vu:CaptureController()
    vu:ClickButton2(Vector2.new())
end))

-- Bomb Jump
table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.BombJump and input.KeyCode == Enum.KeyCode.Space then
        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.Velocity = Vector3.new(0, 100, 0) end
    end
end))

-- Invis Bind
table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.InvisBind and input.KeyCode == Enum.KeyCode.G then
        Config.Invis = not Config.Invis
        R.Notify("👻 Invis: " .. (Config.Invis and "ВКЛ" or "ВЫКЛ"), 2)
    end
end))

-- Fly (заглушки, реализация в 4 части)
getgenv().DeepsikStartFly = getgenv().DeepsikStartFly or function() end
getgenv().DeepsikStopFly = getgenv().DeepsikStopFly or function() end

print("✅ [Deepsik v3.0] Часть 3/6 — Категории + Main/Movement готовы")
R.Notify("⏳ Загрузка 3/6...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.0                    ║
    ║      ЧАСТЬ 4/6: Combat + Teleport        ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-3!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local Workspace = R.Workspace
local Camera = R.Camera
local TeleportService = R.TeleportService
local PageCombat = R.PageCombat
local PageTeleport = R.PageTeleport

-- ============ ХЕЛПЕРЫ ============
local function GetChar() 
    local c = LP.Character
    return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

local function GetTargets(filter)
    local targets = {}
    local _, myHrp = GetChar()
    if not myHrp then return targets end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum.Health > 0 then
                if not (Config.TeamCheck and plr.Team == LP.Team and plr.Team ~= nil) then
                    if not filter or filter(plr) then
                        table.insert(targets, {
                            player = plr, hrp = hrp, humanoid = hum,
                            dist = (myHrp.Position - hrp.Position).Magnitude
                        })
                    end
                end
            end
        end
    end
    table.sort(targets, function(a, b) return a.dist < b.dist end)
    return targets
end

-- Определяем роль игрока (MM2: Murder/Sheriff/Innocent)
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local char = plr.Character
    if char:FindFirstChild("Knife") then return "Murder"
    elseif char:FindFirstChild("Gun") then return "Sheriff"
    elseif char:FindFirstChild("Revolver") then return "Sheriff"
    else return "Innocent" end
end

local function GetEquippedTool()
    local char = LP.Character
    if not char then return nil end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return c end
    end
end

-- ============ AUTO PICKUP GUN ============
local function StartAutoPickupGun()
    table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
        if not Config.AutoPickupGun then return end
        local _, myHrp, hum = GetChar()
        if not myHrp or not hum then return end
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if obj:IsA("Tool") then
                local h = obj:FindFirstChild("Handle")
                if h and (myHrp.Position - h.Position).Magnitude < 15 then
                    pcall(function() hum:EquipTool(obj) end)
                end
            end
        end
    end))
end
StartAutoPickupGun()

-- ============ SILENT AIM ============
local function StartSilentAim()
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        if not Config.SilentAim then return end
        local tool = GetEquippedTool()
        if not tool or tool.Name:lower():find("knife") then return end

        local targets = GetTargets()
        if #targets == 0 then return end

        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local best, bestDist = nil, Config.SilentAimFOV

        for _, t in ipairs(targets) do
            local sp, on = Camera:WorldToViewportPoint(t.hrp.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                if d < bestDist then best, bestDist = t, d end
            end
        end
        if best then
            -- Поворот камеры на цель (Silent = мгновенно)
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, best.hrp.Position)
        end
    end))
end
StartSilentAim()

-- ============ AIM ASSIST (только на Murder) ============
local function StartAimAssistMurder()
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        if not Config.AimAssistMurder then return end
        local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
        if #targets == 0 then return end

        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end

        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local best, bestDist = nil, Config.AimAssistMurderFOV

        for _, t in ipairs(targets) do
            local sp, on = Camera:WorldToViewportPoint(t.hrp.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                if d < bestDist then best, bestDist = t, d end
            end
        end
        if best then
            local goal = CFrame.new(Camera.CFrame.Position, best.hrp.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, 0.15)
        end
    end))
end
StartAimAssistMurder()

-- ============ KILL AURA ============
local function StartKillAura()
    table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
        if not Config.KillAura then return end
        local tool = GetEquippedTool()
        if not tool then return end
        local targets = GetTargets(function(p)
            return not Config.KillOnlySheriff or GetRole(p) == "Sheriff"
        end)
        for _, t in ipairs(targets) do
            if t.dist <= Config.AuraRange then
                pcall(function() tool:Activate() end)
                task.wait(0.05)
            end
        end
    end))
end
StartKillAura()

-- ============ KNIFE AIMBOT ============
local function StartKnifeAimbot()
    table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
        if not Config.KnifeAimbot then return end
        local tool = GetEquippedTool()
        if not tool or not tool.Name:lower():find("knife") then return end
        local targets = GetTargets()
        if #targets == 0 then return end
        local _, myHrp = GetChar()
        if not myHrp then return end
        local t = targets[1]
        myHrp.CFrame = CFrame.new(t.hrp.Position + (t.hrp.CFrame.LookVector * 3), t.hrp.Position)
        pcall(function() tool:Activate() end)
    end))
end
StartKnifeAimbot()

-- ============ AIM ASSIST ALL ============
local function StartAimAssistAll()
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        if not Config.AimAssistAll then return end
        local targets = GetTargets()
        if #targets == 0 then return end
        local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local best, bestDist = nil, Config.AimAssistAllFOV
        for _, t in ipairs(targets) do
            local sp, on = Camera:WorldToViewportPoint(t.hrp.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - screenCenter).Magnitude
                if d < bestDist then best, bestDist = t, d end
            end
        end
        if best then
            local goal = CFrame.new(Camera.CFrame.Position, best.hrp.Position)
            Camera.CFrame = Camera.CFrame:Lerp(goal, 0.12)
        end
    end))
end
StartAimAssistAll()

-- ============ KILL ALL ============
local function KillAll()
    local _, myHrp = GetChar()
    local tool = GetEquippedTool()
    if not myHrp then R.Notify("❌ Нет персонажа", 2) return end
    if not tool then R.Notify("❌ Возьми нож в руки", 2) return end

    local orig = myHrp.CFrame
    local targets = GetTargets()
    R.Notify("💀 Kill All: " .. #targets .. " целей", 2)
    for _, t in ipairs(targets) do
        pcall(function() myHrp.CFrame = t.hrp.CFrame * CFrame.new(0, 0, 2) end)
        task.wait(0.08)
        pcall(function() tool:Activate() end)
    end
    task.wait(0.1)
    pcall(function() myHrp.CFrame = orig end)
    R.Notify("✅ Kill All завершён", 2)
end

-- ==================================================================
-- UI COMBAT
-- ==================================================================
UI.CreateSection(PageCombat, "🚔 SHERIFF")

UI.CreateToggle(PageCombat, "Auto Pickup Gun (авто-подъём оружия)", Config.AutoPickupGun, function(s) Config.AutoPickupGun = s end)
UI.CreateToggle(PageCombat, "Silent Aim", Config.SilentAim, function(s) Config.SilentAim = s end)
UI.CreateSlider(PageCombat, "Silent Aim FOV", 10, 500, Config.SilentAimFOV, function(v) Config.SilentAimFOV = v end)
UI.CreateToggle(PageCombat, "Aim Assist (только Murder)", Config.AimAssistMurder, function(s) Config.AimAssistMurder = s end)
UI.CreateSlider(PageCombat, "Aim Assist FOV (Murder)", 10, 500, Config.AimAssistMurderFOV, function(v) Config.AimAssistMurderFOV = v end)

UI.CreateSection(PageCombat, "🔪 MURDER")

UI.CreateToggle(PageCombat, "Kill Aura", Config.KillAura, function(s) Config.KillAura = s end)
UI.CreateSlider(PageCombat, "Kill Aura Radius", 5, 100, Config.AuraRange, function(v) Config.AuraRange = v end)
UI.CreateToggle(PageCombat, "Kill Only Sheriff", Config.KillOnlySheriff, function(s) Config.KillOnlySheriff = s end)
UI.CreateToggle(PageCombat, "Knife Aimbot", Config.KnifeAimbot, function(s) Config.KnifeAimbot = s end)
UI.CreateToggle(PageCombat, "Aim Assist All (все цели)", Config.AimAssistAll, function(s) Config.AimAssistAll = s end)
UI.CreateSlider(PageCombat, "Aim Assist FOV (All)", 10, 500, Config.AimAssistAllFOV, function(v) Config.AimAssistAllFOV = v end)

UI.CreateButton(PageCombat, "💀 KILL ALL", Color3.fromRGB(200, 50, 50), KillAll)

-- ==================================================================
-- TELEPORT
-- ==================================================================
UI.CreateSection(PageTeleport, "🌐 TELEPORT")

UI.CreateButton(PageTeleport, "🏠 TP to Lobby", Color3.fromRGB(0, 120, 200), function()
    local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbySpawn")
    if lobby then
        local pos = lobby.Position or Vector3.new(0, 100, 0)
        local _, myHrp = GetChar()
        if myHrp then myHrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0)) end
        R.Notify("🏠 Телепорт в лобби", 2)
    else
        R.Notify("❌ Лобби не найдено", 2)
    end
end)

UI.CreateButton(PageTeleport, "🔪 TP to Murder", Color3.fromRGB(200, 50, 50), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
    local _, myHrp = GetChar()
    if myHrp and #targets > 0 then
        myHrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🔪 Телепорт к Murder", 2)
    else
        R.Notify("❌ Murder не найден", 2)
    end
end)

UI.CreateButton(PageTeleport, "🚔 TP to Sheriff", Color3.fromRGB(50, 120, 255), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Sheriff" end)
    local _, myHrp = GetChar()
    if myHrp and #targets > 0 then
        myHrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🚔 Телепорт к Sheriff", 2)
    else
        R.Notify("❌ Sheriff не найден", 2)
    end
end)

-- Выбор игрока для ТП
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(playerList, p.Name) end
end

local selectedPlayer = playerList[1] or "—"
local dropPlayer = UI.CreateDropdown(PageTeleport, "TP to Player", playerList, selectedPlayer, function(v)
    selectedPlayer = v
end)

UI.CreateButton(PageTeleport, "🎯 Teleport to Selected", Color3.fromRGB(100, 50, 200), function()
    local target = Players:FindFirstChild(selectedPlayer)
    local _, myHrp = GetChar()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and myHrp then
        myHrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🎯 ТП к " .. selectedPlayer, 2)
    else
        R.Notify("❌ Игрок не найден", 2)
    end
end)

UI.CreateButton(PageTeleport, "🔄 Обновить список игроков", Color3.fromRGB(100, 100, 120), function()
    R.Notify("🔄 Список обновлён (перезапусти скрипт)", 3)
end)

print("✅ [Deepsik v3.0] Часть 4/6 — Combat + Teleport готовы")
R.Notify("⏳ Загрузка 4/6...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.0                    ║
    ║      ЧАСТЬ 5/6: Trolling + Visuals       ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-4!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera
local Lighting = R.Lighting
local TweenService = R.TweenService
local PageTrolling = R.PageTrolling
local PageVisuals = R.PageVisuals

local function GetChar()
    local c = LP.Character
    return c, c and c:FindFirstChild("HumanoidRootPart"), c and c:FindFirstChildOfClass("Humanoid")
end

-- ==================================================================
-- TROLLING: Troll
-- ==================================================================
UI.CreateSection(PageTrolling, "😈 TROLL")

-- Touch Fling (подлетаешь к игроку → он отлетает)
local touchFlingActive = false
local function StartTouchFling()
    table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
        if not Config.TouchFling then return end
        local _, myHrp = GetChar()
        if not myHrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local theirHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if theirHrp and (myHrp.Position - theirHrp.Position).Magnitude < 5 then
                    pcall(function()
                        theirHrp.Velocity = theirHrp.Velocity + Vector3.new(500, 500, 500)
                    end)
                end
            end
        end
    end))
end
StartTouchFling()

-- Click Fling (клик по игроку → отлетает)
local function StartClickFling()
    table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if not Config.ClickFling then return end
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

        local mouse = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
        local params = RaycastParams.new()
        params.FilterDescendantsInstances = {LP.Character}
        params.FilterType = Enum.RaycastFilterType.Exclude
        local hit = Workspace:Raycast(ray.Origin, ray.Direction * 500, params)
        if hit and hit.Instance then
            local char = hit.Instance:FindFirstAncestorOfClass("Model")
            if char then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local hrp = char:FindFirstChild("HumanoidRootPart")
                if hum and hrp and Players:GetPlayerFromCharacter(char) then
                    pcall(function()
                        hrp.Velocity = hrp.Velocity + Vector3.new(800, 800, 800)
                    end)
                    R.Notify("😈 Fling: " .. Players:GetPlayerFromCharacter(char).Name, 2)
                end
            end
        end
    end))
end
StartClickFling()

-- ==================================================================
-- TROLLING: Fun
-- ==================================================================
UI.CreateSection(PageTrolling, "🎉 FUN")

-- Эмоции (простая симуляция — поворот/наклон)
local function DoEmote(name)
    local _, myHrp = GetChar()
    if not myHrp then return end
    R.Notify("💃 Эмоция: " .. name, 2)
    -- Простой танец: наклон в стороны
    for i = 1, 6 do
        myHrp.CFrame = myHrp.CFrame * CFrame.Angles(0, 0, math.rad(20))
        task.wait(0.15)
        myHrp.CFrame = myHrp.CFrame * CFrame.Angles(0, 0, math.rad(-40))
        task.wait(0.15)
        myHrp.CFrame = myHrp.CFrame * CFrame.Angles(0, 0, math.rad(20))
        task.wait(0.15)
    end
end

UI.CreateButton(PageTrolling, "💃 Танец 1", Color3.fromRGB(150, 100, 200), function() DoEmote("Танец 1") end)
UI.CreateButton(PageTrolling, "🕺 Танец 2", Color3.fromRGB(150, 100, 200), function() DoEmote("Танец 2") end)
UI.CreateButton(PageTrolling, "🎭 Приседание", Color3.fromRGB(150, 100, 200), function()
    local _, myHrp = GetChar()
    if myHrp then
        for i = 1, 10 do
            myHrp.CFrame = myHrp.CFrame * CFrame.new(0, -0.3, 0)
            task.wait(0.05)
        end
        task.wait(1)
        for i = 1, 10 do
            myHrp.CFrame = myHrp.CFrame * CFrame.new(0, 0.3, 0)
            task.wait(0.05)
        end
    end
end)

-- Fake Korblox (fake leg)
local fakeKorblox = false
UI.CreateToggle(PageTrolling, "Fake Korblox (правая нога)", Config.FakeKorblox, function(s)
    Config.FakeKorblox = s
    if not LP.Character then return end
    local leg = LP.Character:FindFirstChild("Right Leg") or LP.Character:FindFirstChild("RightUpperLeg")
    if leg then
        pcall(function()
            leg.Transparency = s and 1 or 0
            leg.Color = s and Color3.fromRGB(35, 35, 35) or leg.Color
        end)
    end
end)

-- Fake Headless
UI.CreateToggle(PageTrolling, "Fake Headless", Config.FakeHeadless, function(s)
    Config.FakeHeadless = s
    if not LP.Character then return end
    local head = LP.Character:FindFirstChild("Head")
    if head then
        pcall(function()
            head.Transparency = s and 1 or 0
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if mesh then mesh.Scale = s and Vector3.new(0, 0, 0) or Vector3.new(1.25, 1.25, 1.25) end
        end)
    end
end)

-- Fake Speed / Jump
UI.CreateToggle(PageTrolling, "Fake Speed (визуально)", Config.FakeSpeed, function(s) Config.FakeSpeed = s end)
UI.CreateToggle(PageTrolling, "Fake Jump (визуально)", Config.FakeJump, function(s) Config.FakeJump = s end)

-- Wall Hop (прыжок от стен)
UI.CreateToggle(PageTrolling, "Wall Hop (прыжок от стены)", Config.WallHop, function(s) Config.WallHop = s end)

table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.WallHop then return end
    local char, hrp, hum = GetChar()
    if not hrp or not hum then return end
    if hum:GetState() == Enum.HumanoidStateType.Freefall then
        local ray = Ray.new(hrp.Position, hrp.CFrame.LookVector * 3)
        local hit = Workspace:FindPartOnRay(ray, char)
        if hit then
            hrp.Velocity = Vector3.new(hrp.Velocity.X, 60, hrp.Velocity.Z)
        end
    end
end))

-- ==================================================================
-- VISUALS
-- ==================================================================
UI.CreateSection(PageVisuals, "🌈 CUSTOM SKIES")

UI.CreateToggle(PageVisuals, "Custom Sky", Config.CustomSky, function(s)
    Config.CustomSky = s
    if not s then
        Lighting:FindFirstChildOfClass("Sky"):Destroy()
    end
end)

UI.CreateInput(PageVisuals, "Sky Texture ID (rbxassetid://...)", Config.SkyID, function(text)
    Config.SkyID = text
    if Config.CustomSky then
        local old = Lighting:FindFirstChildOfClass("Sky")
        if old then old:Destroy() end
        local sky = Instance.new("Sky")
        sky.SkyboxBk = text
        sky.SkyboxDn = text
        sky.SkyboxFt = text
        sky.SkyboxLf = text
        sky.SkyboxRt = text
        sky.SkyboxUp = text
        sky.Parent = Lighting
        R.Notify("🌈 Sky применён", 2)
    end
end)

UI.CreateButton(PageVisuals, "🌌 Скай: Космос", Color3.fromRGB(50, 50, 150), function()
    local old = Lighting:FindFirstChildOfClass("Sky")
    if old then old:Destroy() end
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://159454299"
    sky.SkyboxDn = "rbxassetid://159454296"
    sky.SkyboxFt = "rbxassetid://159454293"
    sky.SkyboxLf = "rbxassetid://159454286"
    sky.SkyboxRt = "rbxassetid://159454300"
    sky.SkyboxUp = "rbxassetid://159454288"
    sky.Parent = Lighting
    R.Notify("🌌 Космос установлен", 2)
end)

UI.CreateButton(PageVisuals, "☀️ Скай: Закат", Color3.fromRGB(255, 150, 80), function()
    local old = Lighting:FindFirstChildOfClass("Sky")
    if old then old:Destroy() end
    local sky = Instance.new("Sky")
    sky.SkyboxBk = "rbxassetid://271042910"
    sky.SkyboxDn = "rbxassetid://271042910"
    sky.SkyboxFt = "rbxassetid://271042910"
    sky.SkyboxLf = "rbxassetid://271042910"
    sky.SkyboxRt = "rbxassetid://271042910"
    sky.SkyboxUp = "rbxassetid://271042910"
    sky.Parent = Lighting
    R.Notify("☀️ Закат установлен", 2)
end)

UI.CreateButton(PageVisuals, "❌ Убрать скай", Color3.fromRGB(200, 50, 50), function()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky then sky:Destroy() end
    R.Notify("❌ Sky убран", 2)
end)

UI.CreateSection(PageVisuals, "🔫 BULLET LASER")
UI.CreateToggle(PageVisuals, "Bullet Laser (лазер при выстреле)", Config.BulletLaser, function(s) Config.BulletLaser = s end)

UI.CreateSection(PageVisuals, "🎥 CAMERA")
UI.CreateToggle(PageVisuals, "Camera Follow Knife (камера следит за ножом)", Config.CameraFollowKnife, function(s) Config.CameraFollowKnife = s end)

-- ============ ЛОГИКА: BULLET LASER + CAMERA FOLLOW ============
local laserFolder = Instance.new("Folder")
laserFolder.Name = "DeepsikLasers"
laserFolder.Parent = Workspace

local function CreateLaser(fromPos, toPos)
    local dist = (toPos - fromPos).Magnitude
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.1, 0.1, dist)
    part.CFrame = CFrame.new(fromPos, toPos) * CFrame.new(0, 0, -dist / 2)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 0, 0)
    part.Transparency = 0.2
    part.Parent = laserFolder

    TweenService:Create(part, TweenInfo.new(0.4), {Transparency = 1}):Play()
    task.delay(0.5, function() pcall(function() part:Destroy() end) end)
end

-- Проверка выстрела (следим за Tool.Activated)
local function HookTools()
    table.insert(getgenv().DeepsikConns, LP.CharacterAdded:Connect(function(char)
        task.wait(0.5)
        for _, tool in ipairs(char:GetChildren()) do
            if tool:IsA("Tool") then
                tool.Activated:Connect(function()
                    if Config.BulletLaser then
                        local handle = tool:FindFirstChild("Handle")
                        if handle then
                            local mouse = UserInputService:GetMouseLocation()
                            local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
                            CreateLaser(handle.Position, ray.Origin + ray.Direction * 500)
                        end
                    end
                end)
            end
        end
    end))
end
HookTools()

-- Следить за ножом (если его кто-то кинул)
table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
    if not Config.CameraFollowKnife then return end
    -- Ищем летящий нож в Workspace
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("knife") and not obj.Anchored then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, obj.Position)
            break
        end
    end
end))

print("✅ [Deepsik v3.0] Часть 5/6 — Trolling + Visuals готовы")
R.Notify("⏳ Загрузка 5/6...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.0                    ║
    ║      ЧАСТЬ 6/6: ESP + Settings + Управление
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-5!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Camera = R.Camera
local TweenService = R.TweenService
local TeleportService = R.TeleportService
local HttpService = R.HttpService
local PageSettings = R.PageSettings
local PageMain = R.PageMain
local MainFrame = R.MainFrame
local ScreenGui = R.ScreenGui
local CloseBtn = R.CloseBtn
local MinBtn = R.MinBtn
local ToggleBtn = R.ToggleBtn
local TitleBar = R.TitleBar
local ContentFrame = R.ContentFrame
local ESPObjects = getgenv().DeepsikESP

-- ==================================================================
-- ESP (Player, Role, Gun)
-- ==================================================================
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local char = plr.Character
    if char:FindFirstChild("Knife") then return "Murder"
    elseif char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then return "Sheriff"
    else return "Innocent" end
end

local ROLE_COLORS = {
    Murder = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 150, 255),
    Innocent = Color3.fromRGB(50, 255, 100),
}

local function CreateESPPlayer(player)
    if player == LP then return end
    if ESPObjects[player] then return end

    local Box = Drawing.new("Square")
    Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1; Box.Visible = false

    local NameTag = Drawing.new("Text")
    NameTag.Size = 14; NameTag.Center = true; NameTag.Outline = true; NameTag.Color = Color3.fromRGB(255,255,255); NameTag.Visible = false

    local DistanceTag = Drawing.new("Text")
    DistanceTag.Size = 12; DistanceTag.Center = true; DistanceTag.Outline = true; DistanceTag.Color = Color3.fromRGB(0,170,255); DistanceTag.Visible = false

    local RoleTag = Drawing.new("Text")
    RoleTag.Size = 12; RoleTag.Center = true; RoleTag.Outline = true; RoleTag.Color = Color3.fromRGB(255,255,255); RoleTag.Visible = false

    local Tracer = Drawing.new("Line")
    Tracer.Thickness = 1; Tracer.Visible = false

    ESPObjects[player] = {Box = Box, NameTag = NameTag, DistanceTag = DistanceTag, RoleTag = RoleTag, Tracer = Tracer}
end

local function RemoveESPPlayer(player)
    if ESPObjects[player] then
        for _, o in pairs(ESPObjects[player]) do
            pcall(function() o:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- Gun ESP (оружие на полу)
local GunESPObjects = {}
local function CreateGunESP()
    if not Config.GunESP then
        for _, o in pairs(GunESPObjects) do pcall(function() o:Remove() end) end
        GunESPObjects = {}
        return
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and not GunESPObjects[obj] then
            local tag = Drawing.new("Text")
            tag.Size = 12; tag.Center = true; tag.Outline = true
            tag.Color = Color3.fromRGB(255, 200, 0)
            tag.Text = obj.Name
            tag.Visible = false
            GunESPObjects[obj] = tag
        end
    end
end

-- Обновление ESP
local function UpdateESP()
    for player, objs in pairs(ESPObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        local show = Config.ESP and hum and hum.Health > 0 and hrp and head
        if show and Config.TeamCheck and player.Team == LP.Team and player.Team ~= nil then
            show = false
        end

        if not show then
            objs.Box.Visible = false; objs.NameTag.Visible = false
            objs.DistanceTag.Visible = false; objs.RoleTag.Visible = false; objs.Tracer.Visible = false
            continue
        end

        local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
        local hrpPos, hrpOn = Camera:WorldToViewportPoint(hrp.Position)

        if headOn and hrpOn then
            local h = math.abs(headPos.Y - hrpPos.Y) * 2
            local w = h * 0.6

            objs.Box.Size = Vector2.new(w, h)
            objs.Box.Position = Vector2.new(headPos.X - w/2, headPos.Y)

            local role = GetRole(player)
            local col = Config.RoleESP and ROLE_COLORS[role] or Config.ESPColor

            objs.Box.Color = col
            objs.Box.Visible = true

            local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
            objs.NameTag.Text = player.Name
            objs.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 20)
            objs.NameTag.Visible = true

            objs.DistanceTag.Text = string.format("[%d studs]", math.floor(dist))
            objs.DistanceTag.Position = Vector2.new(headPos.X, headPos.Y + h + 2)
            objs.DistanceTag.Visible = true

            if Config.RoleESP then
                objs.RoleTag.Text = role
                objs.RoleTag.Color = ROLE_COLORS[role]
                objs.RoleTag.Position = Vector2.new(headPos.X, headPos.Y + h + 16)
                objs.RoleTag.Visible = true
            else
                objs.RoleTag.Visible = false
            end

            if Config.Tracers then
                objs.Tracer.From = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y)
                objs.Tracer.To = Vector2.new(headPos.X, headPos.Y + h)
                objs.Tracer.Color = col
                objs.Tracer.Visible = true
            else
                objs.Tracer.Visible = false
            end
        else
            objs.Box.Visible = false; objs.NameTag.Visible = false
            objs.DistanceTag.Visible = false; objs.RoleTag.Visible = false; objs.Tracer.Visible = false
        end
    end

    -- Gun ESP
    for gun, tag in pairs(GunESPObjects) do
        if not Config.GunESP or not gun.Parent then
            tag.Visible = false
        else
            local handle = gun:FindFirstChild("Handle")
            if handle then
                local sp, on = Camera:WorldToViewportPoint(handle.Position)
                if on then
                    tag.Position = Vector2.new(sp.X, sp.Y)
                    tag.Text = gun.Name .. string.format(" [%d]", math.floor((Camera.CFrame.Position - handle.Position).Magnitude))
                    tag.Visible = true
                else
                    tag.Visible = false
                end
            end
        end
    end
end

-- Инициализация ESP
for _, plr in ipairs(Players:GetPlayers()) do CreateESPPlayer(plr) end
table.insert(getgenv().DeepsikConns, Players.PlayerAdded:Connect(CreateESPPlayer))
table.insert(getgenv().DeepsikConns, Players.PlayerRemoving:Connect(RemoveESPPlayer))
table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function() pcall(UpdateESP) end))

-- Периодическое обновление Gun ESP
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if Config.GunESP and tick() % 1 < 0.02 then
        CreateGunESP()
    end
end))

-- ==================================================================
-- ВКЛАДКА MAIN: ColorPicker (уже создана в 3 части, доп. функции)
-- ==================================================================
UI.CreateSection(PageMain, "🔫 TRACERS & TYPE")
Config.Tracers = Config.Tracers or false
UI.CreateToggle(PageMain, "Tracers (линии от центра)", Config.Tracers, function(s) Config.Tracers = s end)

-- ==================================================================
-- SETTINGS
-- ==================================================================
UI.CreateSection(PageSettings, "🎨 UI")

UI.CreateToggle(PageSettings, "Dark Theme", Config.DarkTheme, function(s)
    Config.DarkTheme = s
    if s then
        MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
        ContentFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    else
        MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        TitleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
        ContentFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
    end
end)

UI.CreateToggle(PageSettings, "Anti-AFK", Config.AntiAFK, function(s) Config.AntiAFK = s end)

UI.CreateSection(PageSettings, "💾 КОНФИГИ")

local configName = "default"
UI.CreateInput(PageSettings, "Название конфига", "my_config", function(text)
    configName = text
end)

UI.CreateButton(PageSettings, "💾 Сохранить конфиг", Color3.fromRGB(0, 150, 0), function()
    pcall(function()
        R.SaveConfig(configName)
        R.Notify("💾 Конфиг сохранён: " .. configName, 3)
    end)
end)

UI.CreateButton(PageSettings, "📥 Загрузить конфиг", Color3.fromRGB(0, 120, 200), function()
    local data = R.LoadConfig(configName)
    if data then
        for k, v in pairs(data) do
            Config[k] = v
        end
        R.Notify("📥 Конфиг загружен: " .. configName .. " (перезапусти скрипт)", 4)
    else
        R.Notify("❌ Конфиг не найден: " .. configName, 3)
    end
end)

UI.CreateButton(PageSettings, "📂 Список конфигов", Color3.fromRGB(100, 100, 120), function()
    local list = R.ListConfigs()
    if #list == 0 then
        R.Notify("📂 Нет сохранённых конфигов", 3)
    else
        R.Notify("📂 Конфиги: " .. table.concat(list, ", "), 5)
    end
end)

UI.CreateSection(PageSettings, "🔧 ДЕЙСТВИЯ")

UI.CreateButton(PageSettings, "🔄 Rejoin сервер", Color3.fromRGB(0, 120, 200), function()
    R.Notify("🌍 Rejoin...", 2)
    TeleportService:Teleport(game.PlaceId, LP)
end)

UI.CreateButton(PageSettings, "❌ Выгрузить Hub", Color3.fromRGB(200, 50, 50), function()
    if getgenv().DeepsikStopFly then getgenv().DeepsikStopFly() end
    for _, objs in pairs(ESPObjects) do
        for _, o in pairs(objs) do pcall(function() o:Remove() end) end
    end
    for _, o in pairs(GunESPObjects) do pcall(function() o:Remove() end) end
    for _, c in pairs(getgenv().DeepsikConns or {}) do pcall(function() c:Disconnect() end) end
    ScreenGui:Destroy()
    getgenv().DeepsikGui = nil
    getgenv().DeepsikRefs = nil
    R.Notify("❌ Hub выгружен", 2)
end)

UI.CreateSection(PageSettings, "📊 ИНФОРМАЦИЯ")

local InfoLabel = Instance.new("TextLabel")
InfoLabel.Size = UDim2.new(1, -10, 0, 70)
InfoLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 38)
InfoLabel.Text = "Загрузка..."
InfoLabel.TextColor3 = Color3.fromRGB(220, 220, 230)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.Parent = PageSettings
local ILC = Instance.new("UICorner")
ILC.CornerRadius = UDim.new(0, 6)
ILC.Parent = InfoLabel
local ILP = Instance.new("UIPadding")
ILP.PaddingTop = UDim.new(0, 6)
ILP.PaddingLeft = UDim.new(0, 10)
ILP.Parent = InfoLabel

task.spawn(function()
    while InfoLabel.Parent do
        InfoLabel.Text = string.format(
            "👥 Игроков: %d  |  📡 Ping: %d ms\n🔫 ESP: %s  |  ⚡ Speed: %s\n💙 Deepsik Hub v3.0",
            #Players:GetPlayers(),
            math.floor(LP:GetNetworkPing() * 1000),
            Config.ESP and "ON" or "OFF",
            Config.SpeedHack and "ON" or "OFF"
        )
        task.wait(1)
    end
end)

UI.CreateLabelFinal = nil

-- ==================================================================
-- УПРАВЛЕНИЕ
-- ==================================================================
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

-- Хоткеи
table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
        ToggleBtn.Visible = not MainFrame.Visible
    end

    if input.KeyCode == Enum.KeyCode.Delete then
        if getgenv().DeepsikStopFly then getgenv().DeepsikStopFly() end
        for _, objs in pairs(ESPObjects) do
            for _, o in pairs(objs) do pcall(function() o:Remove() end) end
        end
        for _, o in pairs(GunESPObjects) do pcall(function() o:Remove() end) end
        for _, c in pairs(getgenv().DeepsikConns or {}) do pcall(function() c:Disconnect() end) end
        ScreenGui:Destroy()
        getgenv().DeepsikGui = nil
        getgenv().DeepsikRefs = nil
    end
end))

-- ==================================================================
-- ИНИЦИАЛИЗАЦИЯ
-- ==================================================================
R.SwitchCategory(1)

print([[
╔══════════════════════════════════════════╗
║     🔫 DEEPSIK HUB v3.0 ЗАГРУЖЕН! 🔫     ║
║     ─────────────────────────────        ║
║     RightShift / F1 — открыть/закрыть    ║
║     Delete — выгрузить скрипт            ║
║     G — привязка Invis                   ║
╚══════════════════════════════════════════╝
]])
R.Notify("✅ Deepsik Hub v3.0 запущен!", 3)
