--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.1 - MM2              ║
    ║      ЧАСТЬ 1/5: Ядро + GUI               ║
    ╚══════════════════════════════════════════╝
]]

-- ============ ЗАЩИТНЫЙ БЛОК ============
if not game:IsLoaded() then game.Loaded:Wait() end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TeleportService = game:GetService("TeleportService")
local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

-- Ждём LocalPlayer
local _t = tick()
while not Players.LocalPlayer and tick() - _t < 30 do task.wait(0.1) end
if not Players.LocalPlayer then warn("[Deepsik] LocalPlayer не найден") return end

local LP = Players.LocalPlayer

-- Ждём PlayerGui
local PlayerGui
_t = tick()
repeat
    task.wait(0.1)
    PlayerGui = LP:FindFirstChild("PlayerGui")
until PlayerGui or tick() - _t > 30
if not PlayerGui then warn("[Deepsik] PlayerGui не найден") return end

local Camera = Workspace.CurrentCamera

-- Проверка Drawing API
getgenv().DeepsikNoDrawing = (not Drawing)
if getgenv().DeepsikNoDrawing then
    warn("[Deepsik] Drawing API недоступен — ESP будет отключён")
end

-- ============ ДЕФОЛТНЫЙ КОНФИГ ============
local DefaultConfig = {
    ESP = false, RoleESP = true, GunESP = false,
    ESPColor = Color3.fromRGB(0, 170, 255),
    Tracers = false, TeamCheck = false,

    -- Movement
    Noclip = false, InfiniteJump = false, AntiFling = false,
    BombJump = false, Fly = false, FlySpeed = 50,
    Spin = false, SpinSpeed = 10, Bhop = false,
    Invis = false, InvisBind = false,
    SpeedHack = false, SpeedValue = 60,
    JumpPower = false, JumpValue = 120,
    AntiRagdoll = false,

    -- Sheriff
    AutoPickupGun = false,
    SilentAim = false, SilentAimFOV = 100,
    AimAssistMurder = false, AimAssistMurderFOV = 100,

    -- Murder
    KillAura = false, AuraRange = 30,
    KillOnlySheriff = false,
    KnifeAimbot = false,
    AimAssistAll = false, AimAssistAllFOV = 100,

    -- Trolling
    TouchFling = false, ClickFling = false,
    FakeKorblox = false, FakeHeadless = false,
    FakeSpeed = false, FakeJump = false, WallHop = false,

    -- Visuals
    CustomSky = false, SkyID = "",
    BulletLaser = false, CameraFollowKnife = false,

    -- Misc
    DarkTheme = true, AntiAFK = true,
    KillNotifier = false, RoleNotifier = false,
}

getgenv().DeepsikConfig = getgenv().DeepsikConfig or {}
for k, v in pairs(DefaultConfig) do
    if getgenv().DeepsikConfig[k] == nil then
        getgenv().DeepsikConfig[k] = v
    end
end
local Config = getgenv().DeepsikConfig

-- Очистка старого
if getgenv().DeepsikGui then pcall(function() getgenv().DeepsikGui:Destroy() end) end
for _, c in pairs(getgenv().DeepsikConns or {}) do pcall(function() c:Disconnect() end) end
getgenv().DeepsikConns = {}
getgenv().DeepsikESP = getgenv().DeepsikESP or {}

-- ============ NOTIFY ============
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
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui
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
VersionLabel.Text = "v3.1"
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

-- Сайдбар категорий
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

-- Контент
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

-- ============ КОНФИГ ФАЙЛЫ ============
local ConfigFolder = "DeepsikHub"

local function SaveConfig(name)
    pcall(function()
        if isfolder and not isfolder(ConfigFolder) then makefolder(ConfigFolder) end
        local path = ConfigFolder .. "/" .. (name or "default") .. ".json"
        local data = {}
        for k, v in pairs(Config) do
            if typeof(v) == "Color3" then
                data[k] = {__color = true, r = v.R, g = v.G, b = v.B}
            else
                data[k] = v
            end
        end
        writefile(path, HttpService:JSONEncode(data))
        Notify("💾 Сохранено: " .. name, 2)
    end)
end

local function LoadConfig(name)
    local ok, data = pcall(function()
        local path = ConfigFolder .. "/" .. (name or "default") .. ".json"
        if isfile and isfile(path) then
            return HttpService:JSONDecode(readfile(path))
        end
    end)
    if ok and data then
        for k, v in pairs(data) do
            if type(v) == "table" and v.__color then
                Config[k] = Color3.fromRGB(v.r * 255, v.g * 255, v.b * 255)
            else
                Config[k] = v
            end
        end
        Notify("📥 Загружено: " .. name, 2)
        return true
    end
    Notify("❌ Конфиг не найден: " .. name, 2)
    return false
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

-- ============ СОХРАНЕНИЕ ССЫЛОК ============
getgenv().DeepsikRefs = {
    ScreenGui = ScreenGui, MainFrame = MainFrame, TitleBar = TitleBar,
    ContentFrame = ContentFrame, SideBar = SideBar, SideScroll = SideScroll,
    CloseBtn = CloseBtn, MinBtn = MinBtn, ToggleBtn = ToggleBtn,
    TweenService = TweenService, Players = Players, RunService = RunService,
    UserInputService = UserInputService, Lighting = Lighting, Workspace = Workspace,
    TeleportService = TeleportService, StarterGui = StarterGui, HttpService = HttpService,
    LocalPlayer = LP, Camera = Camera, Config = Config, Notify = Notify,
    SaveConfig = SaveConfig, LoadConfig = LoadConfig, ListConfigs = ListConfigs,
}

print("✅ [Deepsik v3.1] Часть 1/5 — Ядро + GUI готовы")
Notify("⏳ Загрузка 1/5...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.1                    ║
    ║      ЧАСТЬ 2/5: UI-компоненты            ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
if not R then warn("❌ Сначала запусти Часть 1!") return end

local TweenService = R.TweenService
local UserInputService = R.UserInputService
local SideScroll = R.SideScroll

-- Категория
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

-- Страница
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

-- Секция
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

-- Тумблер (ИСПРАВЛЕН — возвращает Frame)
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
        if callback then pcall(callback, state) end
    end)
    return Frame
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
            if callback then pcall(callback, v) end
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
        if callback then pcall(callback) end
    end)
    return Btn
end

-- Ввод
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
        if callback then pcall(callback, Box.Text) end
    end)
    return Frame, Box
end

-- Дропдаун
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
            Selected.Text = opt
            open = false
            for _, of in ipairs(optionFrames) do of.Visible = false end
            Frame.Size = UDim2.new(1, -10, 0, 32)
            if callback then pcall(callback, opt) end
        end)
        table.insert(optionFrames, OptBtn)
    end
    return Frame
end

-- Экспорт
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

print("✅ [Deepsik v3.1] Часть 2/5 — UI-компоненты готовы")
R.Notify("⏳ Загрузка 2/5...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.1                    ║
    ║      ЧАСТЬ 3A: Категории + Main          ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-2!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
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

-- Сохраняем ссылки
R.PageMain = PageMain
R.PageCombat = PageCombat
R.PageMovement = PageMovement
R.PageTeleport = PageTeleport
R.PageTrolling = PageTrolling
R.PageVisuals = PageVisuals
R.PageSettings = PageSettings
R.SwitchCategory = SwitchCategory

-- ============ ХЕЛПЕРЫ ============
local function GetChar()
    local c = LP.Character
    if not c or not c.Parent then return nil, nil, nil end
    return c, c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
end
getgenv().DeepsikGetChar = GetChar

local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local char = plr.Character
    if char:FindFirstChild("Knife") then return "Murder"
    elseif char:FindFirstChild("Gun") or char:FindFirstChild("Revolver") then return "Sheriff"
    else return "Innocent" end
end
getgenv().DeepsikGetRole = GetRole

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
getgenv().DeepsikGetTargets = GetTargets

local function GetEquippedTool()
    local char = LP.Character
    if not char then return nil end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return c end
    end
end
getgenv().DeepsikGetTool = GetEquippedTool

-- ==================================================================
-- КАТЕГОРИЯ MAIN
-- ==================================================================
UI.CreateSection(PageMain, "🎯 ESP")
UI.CreateToggle(PageMain, "ESP игроков", Config.ESP, function(s) Config.ESP = s end)
UI.CreateToggle(PageMain, "Role ESP (роль цветом)", Config.RoleESP, function(s) Config.RoleESP = s end)
UI.CreateToggle(PageMain, "Gun ESP (оружие)", Config.GunESP, function(s) Config.GunESP = s end)
UI.CreateToggle(PageMain, "Tracers (линии)", Config.Tracers, function(s) Config.Tracers = s end)
UI.CreateToggle(PageMain, "Team Check", Config.TeamCheck, function(s) Config.TeamCheck = s end)

UI.CreateSection(PageMain, "🎨 ЦВЕТ ESP")
UI.CreateSlider(PageMain, "R", 0, 255, 0, function(v)
    Config.ESPColor = Color3.fromRGB(v, Config.ESPColor.G * 255, Config.ESPColor.B * 255)
end)
UI.CreateSlider(PageMain, "G", 0, 255, 170, function(v)
    Config.ESPColor = Color3.fromRGB(Config.ESPColor.R * 255, v, Config.ESPColor.B * 255)
end)
UI.CreateSlider(PageMain, "B", 0, 255, 255, function(v)
    Config.ESPColor = Color3.fromRGB(Config.ESPColor.R * 255, Config.ESPColor.G * 255, v)
end)

UI.CreateSection(PageMain, "🔔 NOTIFIER")
UI.CreateToggle(PageMain, "Kill Notifier (кто кого убил)", Config.KillNotifier, function(s) Config.KillNotifier = s end)
UI.CreateToggle(PageMain, "Role Notifier (кто какая роль)", Config.RoleNotifier, function(s) Config.RoleNotifier = s end)

print("✅ [Deepsik v3.1] Часть 3A — Категории + Main готовы")
R.Notify("⏳ Загрузка 3A...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.1                    ║
    ║      ЧАСТЬ 3B: Combat + Movement         ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-3A!") return end

local Config = R.Config
local LP = R.LocalPlayer
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera

local PageCombat = R.PageCombat
local PageMovement = R.PageMovement

-- Берём хелперы из 3A
local GetChar = getgenv().DeepsikGetChar
local GetTargets = getgenv().DeepsikGetTargets
local GetRole = getgenv().DeepsikGetRole
local GetEquippedTool = getgenv().DeepsikGetTool

if not GetChar or not GetTargets then
    warn("❌ [Deepsik] Хелперы не найдены. Проверь, что запустил Часть 3A!")
    return
end

-- ==================================================================
-- КАТЕГОРИЯ COMBAT
-- ==================================================================
UI.CreateSection(PageCombat, "🚔 SHERIFF")
UI.CreateToggle(PageCombat, "Auto Pickup Gun", Config.AutoPickupGun, function(s) Config.AutoPickupGun = s end)
UI.CreateToggle(PageCombat, "Silent Aim", Config.SilentAim, function(s) Config.SilentAim = s end)
UI.CreateSlider(PageCombat, "Silent Aim FOV", 10, 500, Config.SilentAimFOV, function(v) Config.SilentAimFOV = v end)
UI.CreateToggle(PageCombat, "Aim Assist (Murder)", Config.AimAssistMurder, function(s) Config.AimAssistMurder = s end)
UI.CreateSlider(PageCombat, "Aim Assist FOV (Murder)", 10, 500, Config.AimAssistMurderFOV, function(v) Config.AimAssistMurderFOV = v end)

UI.CreateSection(PageCombat, "🔪 MURDER")
UI.CreateToggle(PageCombat, "Kill Aura", Config.KillAura, function(s) Config.KillAura = s end)
UI.CreateSlider(PageCombat, "Kill Aura Radius", 5, 100, Config.AuraRange, function(v) Config.AuraRange = v end)
UI.CreateToggle(PageCombat, "Kill Only Sheriff", Config.KillOnlySheriff, function(s) Config.KillOnlySheriff = s end)
UI.CreateToggle(PageCombat, "Knife Aimbot", Config.KnifeAimbot, function(s) Config.KnifeAimbot = s end)
UI.CreateToggle(PageCombat, "Aim Assist All", Config.AimAssistAll, function(s) Config.AimAssistAll = s end)
UI.CreateSlider(PageCombat, "Aim Assist FOV (All)", 10, 500, Config.AimAssistAllFOV, function(v) Config.AimAssistAllFOV = v end)

UI.CreateButton(PageCombat, "💀 KILL ALL", Color3.fromRGB(200, 50, 50), function()
    local _, myHrp = GetChar()
    local tool = GetEquippedTool()
    if not myHrp then R.Notify("❌ Нет персонажа", 2) return end
    if not tool then R.Notify("❌ Возьми нож в руки", 2) return end
    local orig = myHrp.CFrame
    local targets = GetTargets()
    R.Notify("💀 Kill All: " .. #targets, 2)
    for _, t in ipairs(targets) do
        pcall(function() myHrp.CFrame = t.hrp.CFrame * CFrame.new(0, 0, 2) end)
        task.wait(0.08)
        pcall(function() tool:Activate() end)
    end
    task.wait(0.1)
    pcall(function() myHrp.CFrame = orig end)
    R.Notify("✅ Готово", 2)
end)

-- ============ COMBAT ЛОГИКА ============
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

local function StartSilentAim()
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        if not Config.SilentAim then return end
        local tool = GetEquippedTool()
        if not tool or tool.Name:lower():find("knife") then return end
        local targets = GetTargets()
        if #targets == 0 then return end
        local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local best, bestDist = nil, Config.SilentAimFOV
        for _, t in ipairs(targets) do
            local sp, on = Camera:WorldToViewportPoint(t.hrp.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - sc).Magnitude
                if d < bestDist then best, bestDist = t, d end
            end
        end
        if best then
            pcall(function()
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, best.hrp.Position)
            end)
        end
    end))
end
StartSilentAim()

local function StartAimAssistMurder()
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        if not Config.AimAssistMurder then return end
        local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
        if #targets == 0 then return end
        local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local best, bestDist = nil, Config.AimAssistMurderFOV
        for _, t in ipairs(targets) do
            local sp, on = Camera:WorldToViewportPoint(t.hrp.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - sc).Magnitude
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
        pcall(function()
            myHrp.CFrame = CFrame.new(t.hrp.Position + (t.hrp.CFrame.LookVector * 3), t.hrp.Position)
            tool:Activate()
        end)
    end))
end
StartKnifeAimbot()

local function StartAimAssistAll()
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        if not Config.AimAssistAll then return end
        local targets = GetTargets()
        if #targets == 0 then return end
        local sc = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local best, bestDist = nil, Config.AimAssistAllFOV
        for _, t in ipairs(targets) do
            local sp, on = Camera:WorldToViewportPoint(t.hrp.Position)
            if on then
                local d = (Vector2.new(sp.X, sp.Y) - sc).Magnitude
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

-- ==================================================================
-- КАТЕГОРИЯ MOVEMENT
-- ==================================================================
UI.CreateSection(PageMovement, "🏃 BASIC")
UI.CreateToggle(PageMovement, "Noclip", Config.Noclip, function(s) Config.Noclip = s end)
UI.CreateToggle(PageMovement, "Infinite Jump", Config.InfiniteJump, function(s) Config.InfiniteJump = s end)
UI.CreateToggle(PageMovement, "Anti-Fling", Config.AntiFling, function(s) Config.AntiFling = s end)
UI.CreateToggle(PageMovement, "Anti-Ragdoll", Config.AntiRagdoll, function(s) Config.AntiRagdoll = s end)
UI.CreateToggle(PageMovement, "Bomb Jump", Config.BombJump, function(s) Config.BombJump = s end)
UI.CreateToggle(PageMovement, "Bhop", Config.Bhop, function(s) Config.Bhop = s end)

UI.CreateSection(PageMovement, "⚡ SPEED / JUMP")
UI.CreateToggle(PageMovement, "Speed Hack", Config.SpeedHack, function(s)
    Config.SpeedHack = s
    local hum = select(3, GetChar())
    if hum then hum.WalkSpeed = s and Config.SpeedValue or 16 end
end)
UI.CreateSlider(PageMovement, "Скорость", 16, 250, Config.SpeedValue, function(v)
    Config.SpeedValue = v
    local hum = select(3, GetChar())
    if hum and Config.SpeedHack then hum.WalkSpeed = v end
end)
UI.CreateToggle(PageMovement, "Jump Power", Config.JumpPower, function(s)
    Config.JumpPower = s
    local hum = select(3, GetChar())
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = s and Config.JumpValue or 50
    end
end)
UI.CreateSlider(PageMovement, "Сила прыжка", 50, 500, Config.JumpValue, function(v)
    Config.JumpValue = v
    local hum = select(3, GetChar())
    if hum and Config.JumpPower then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end)

UI.CreateSection(PageMovement, "🕊️ FLY / SPIN")
UI.CreateToggle(PageMovement, "Fly", Config.Fly, function(s)
    Config.Fly = s
    if s and getgenv().DeepsikStartFly then getgenv().DeepsikStartFly()
    elseif getgenv().DeepsikStopFly then getgenv().DeepsikStopFly() end
end)
UI.CreateSlider(PageMovement, "Скорость полёта", 10, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end)
UI.CreateToggle(PageMovement, "Spin", Config.Spin, function(s) Config.Spin = s end)
UI.CreateSlider(PageMovement, "Скорость Spin", 1, 50, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)

UI.CreateSection(PageMovement, "👻 INVIS")
UI.CreateToggle(PageMovement, "Invis", Config.Invis, function(s) Config.Invis = s end)
UI.CreateToggle(PageMovement, "Invis Bind (G)", Config.InvisBind, function(s) Config.InvisBind = s end)

-- ============ MOVEMENT ЛОГИКА ============
local function UpdateSpeed()
    local hum = select(3, GetChar())
    if hum then hum.WalkSpeed = Config.SpeedHack and Config.SpeedValue or 16 end
end
local function UpdateJump()
    local hum = select(3, GetChar())
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = Config.JumpPower and Config.JumpValue or 50
    end
end

table.insert(getgenv().DeepsikConns, LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateSpeed(); UpdateJump()
end))

table.insert(getgenv().DeepsikConns, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local hum = select(3, GetChar())
        if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end))

table.insert(getgenv().DeepsikConns, RunService.Stepped:Connect(function()
    if Config.Noclip and LP.Character then
        for _, part in ipairs(LP.Character:GetDescendants()) do
            if part:IsA("BasePart") and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end))

table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.Bhop and input.KeyCode == Enum.KeyCode.Space then
        local hum = select(3, GetChar())
        if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
    if Config.BombJump and input.KeyCode == Enum.KeyCode.Space then
        local _, hrp = GetChar()
        if hrp then hrp.Velocity = Vector3.new(0, 100, 0) end
    end
    if Config.InvisBind and input.KeyCode == Enum.KeyCode.G then
        Config.Invis = not Config.Invis
        R.Notify("👻 Invis: " .. (Config.Invis and "ВКЛ" or "ВЫКЛ"), 2)
    end
end))

local spinAngle = 0
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function(dt)
    if not Config.Spin then return end
    local _, hrp = GetChar()
    if hrp then
        spinAngle = spinAngle + math.rad(Config.SpinSpeed) * dt * 60
        hrp.CFrame = hrp.CFrame * CFrame.Angles(0, spinAngle, 0)
    end
end))

table.insert(getgenv().DeepsikConns, RunService.Stepped:Connect(function()
    if not Config.Invis or not LP.Character then return end
    for _, part in ipairs(LP.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            pcall(function() part.LocalTransparencyModifier = 1 end)
        end
    end
end))

table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.AntiFling then return end
    local _, hrp = GetChar()
    if hrp and hrp.Velocity.Magnitude > 200 then
        hrp.Velocity = hrp.Velocity.Unit * 200
    end
end))

-- Anti-Ragdoll
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.AntiRagdoll then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end)
    end
end))

-- Anti-AFK
table.insert(getgenv().DeepsikConns, LP.Idled:Connect(function()
    if not Config.AntiAFK then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end))

-- ============ FLY ============
local flyConns = {render = nil, vel = nil, gyro = nil}
local function StopFly()
    if flyConns.render then flyConns.render:Disconnect(); flyConns.render = nil end
    if flyConns.vel then pcall(function() flyConns.vel:Destroy() end) end
    if flyConns.gyro then pcall(function() flyConns.gyro:Destroy() end) end
    flyConns.vel = nil; flyConns.gyro = nil
end

local function StartFly()
    StopFly()
    local _, hrp = GetChar()
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
        local _, h = GetChar()
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

getgenv().DeepsikStartFly = StartFly
getgenv().DeepsikStopFly = StopFly

print("✅ [Deepsik v3.1] Часть 3B — Combat + Movement готовы")
R.Notify("⏳ Загрузка 3B...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.1                    ║
    ║      ЧАСТЬ 4/5: Teleport + Trolling + Visuals
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-3!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera
local Lighting = R.Lighting
local TweenService = R.TweenService
local PageTeleport = R.PageTeleport
local PageTrolling = R.PageTrolling
local PageVisuals = R.PageVisuals

local GetChar = getgenv().DeepsikGetChar
local GetTargets = getgenv().DeepsikGetTargets
local GetRole = getgenv().DeepsikGetRole

-- ==================================================================
-- TELEPORT
-- ==================================================================
UI.CreateSection(PageTeleport, "🌐 TP")
UI.CreateButton(PageTeleport, "🏠 TP to Lobby", Color3.fromRGB(0, 120, 200), function()
    local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbySpawn")
    local _, hrp = GetChar()
    if lobby and hrp then
        local pos = lobby.Position or Vector3.new(0, 100, 0)
        hrp.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
        R.Notify("🏠 В лобби", 2)
    else
        R.Notify("❌ Лобби не найдено", 2)
    end
end)

UI.CreateButton(PageTeleport, "🔪 TP to Murder", Color3.fromRGB(200, 50, 50), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
    local _, hrp = GetChar()
    if hrp and #targets > 0 then
        hrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🔪 К Murder", 2)
    else
        R.Notify("❌ Murder не найден", 2)
    end
end)

UI.CreateButton(PageTeleport, "🚔 TP to Sheriff", Color3.fromRGB(50, 120, 255), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Sheriff" end)
    local _, hrp = GetChar()
    if hrp and #targets > 0 then
        hrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🚔 К Sheriff", 2)
    else
        R.Notify("❌ Sheriff не найден", 2)
    end
end)

-- Список игроков
local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(playerList, p.Name) end
end
if #playerList == 0 then playerList = {"—"} end

local selectedPlayer = playerList[1]
UI.CreateDropdown(PageTeleport, "TP to Player", playerList, selectedPlayer, function(v)
    selectedPlayer = v
end)

UI.CreateButton(PageTeleport, "🎯 TP Selected", Color3.fromRGB(100, 50, 200), function()
    local target = Players:FindFirstChild(selectedPlayer)
    local _, hrp = GetChar()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🎯 К " .. selectedPlayer, 2)
    else
        R.Notify("❌ Игрок не найден", 2)
    end
end)

-- ==================================================================
-- TROLLING
-- ==================================================================
UI.CreateSection(PageTrolling, "😈 TROLL")

UI.CreateToggle(PageTrolling, "Touch Fling", Config.TouchFling, function(s) Config.TouchFling = s end)
UI.CreateToggle(PageTrolling, "Click Fling", Config.ClickFling, function(s) Config.ClickFling = s end)

-- Touch Fling
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

-- Click Fling
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
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and Players:GetPlayerFromCharacter(char) then
                pcall(function()
                    hrp.Velocity = hrp.Velocity + Vector3.new(800, 800, 800)
                end)
                R.Notify("😈 Fling", 2)
            end
        end
    end
end))

UI.CreateSection(PageTrolling, "🎉 FUN")

-- Эмоции
local function DoDance()
    local _, hrp = GetChar()
    if not hrp then return end
    R.Notify("💃 Танец", 2)
    task.spawn(function()
        for i = 1, 6 do
            pcall(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(20))
            end)
            task.wait(0.15)
            pcall(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(-40))
            end)
            task.wait(0.15)
            pcall(function()
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(20))
            end)
            task.wait(0.15)
        end
    end)
end

local function DoSquat()
    local _, hrp = GetChar()
    if not hrp then return end
    R.Notify("🎭 Присед", 2)
    task.spawn(function()
        for i = 1, 10 do
            pcall(function() hrp.CFrame = hrp.CFrame * CFrame.new(0, -0.3, 0) end)
            task.wait(0.05)
        end
        task.wait(0.5)
        for i = 1, 10 do
            pcall(function() hrp.CFrame = hrp.CFrame * CFrame.new(0, 0.3, 0) end)
            task.wait(0.05)
        end
    end)
end

UI.CreateButton(PageTrolling, "💃 Танец", Color3.fromRGB(150, 100, 200), DoDance)
UI.CreateButton(PageTrolling, "🎭 Присед", Color3.fromRGB(150, 100, 200), DoSquat)
UI.CreateButton(PageTrolling, "🤸 Сальто", Color3.fromRGB(150, 100, 200), function()
    local _, hrp = GetChar()
    if not hrp then return end
    task.spawn(function()
        for i = 1, 20 do
            pcall(function() hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(18), 0, 0) end)
            task.wait(0.03)
        end
    end)
end)

-- Fake Korblox
UI.CreateToggle(PageTrolling, "Fake Korblox", Config.FakeKorblox, function(s)
    Config.FakeKorblox = s
    if not LP.Character then return end
    local leg = LP.Character:FindFirstChild("Right Leg") or LP.Character:FindFirstChild("RightUpperLeg")
    if leg then
        pcall(function()
            leg.Transparency = s and 1 or 0
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
            if mesh then mesh.Scale = s and Vector3.new(0.01, 0.01, 0.01) or Vector3.new(1.25, 1.25, 1.25) end
        end)
    end
end)

UI.CreateToggle(PageTrolling, "Fake Speed", Config.FakeSpeed, function(s) Config.FakeSpeed = s end)
UI.CreateToggle(PageTrolling, "Fake Jump", Config.FakeJump, function(s) Config.FakeJump = s end)
UI.CreateToggle(PageTrolling, "Wall Hop", Config.WallHop, function(s) Config.WallHop = s end)

-- Wall Hop
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
        local sky = Lighting:FindFirstChildOfClass("Sky")
        if sky then sky:Destroy() end
    end
end)

UI.CreateInput(PageVisuals, "Sky ID (rbxassetid://...)", Config.SkyID, function(text)
    Config.SkyID = text
    if Config.CustomSky and text ~= "" then
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

local function ApplySky(id)
    local old = Lighting:FindFirstChildOfClass("Sky")
    if old then old:Destroy() end
    local sky = Instance.new("Sky")
    sky.SkyboxBk = id; sky.SkyboxDn = id; sky.SkyboxFt = id
    sky.SkyboxLf = id; sky.SkyboxRt = id; sky.SkyboxUp = id
    sky.Parent = Lighting
    R.Notify("🌈 Sky установлен", 2)
end

UI.CreateButton(PageVisuals, "🌌 Космос", Color3.fromRGB(50, 50, 150), function()
    ApplySky("rbxassetid://159454299")
end)
UI.CreateButton(PageVisuals, "☀️ Закат", Color3.fromRGB(255, 150, 80), function()
    ApplySky("rbxassetid://271042910")
end)
UI.CreateButton(PageVisuals, "❄️ Снег", Color3.fromRGB(150, 200, 255), function()
    ApplySky("rbxassetid://6026252216")
end)
UI.CreateButton(PageVisuals, "❌ Убрать скай", Color3.fromRGB(200, 50, 50), function()
    local sky = Lighting:FindFirstChildOfClass("Sky")
    if sky then sky:Destroy() end
    R.Notify("❌ Sky убран", 2)
end)

UI.CreateSection(PageVisuals, "🔫 BULLET LASER")
UI.CreateToggle(PageVisuals, "Bullet Laser", Config.BulletLaser, function(s) Config.BulletLaser = s end)

local laserFolder = Instance.new("Folder")
laserFolder.Name = "DeepsikLasers"
laserFolder.Parent = Workspace

local function CreateLaser(fromPos, toPos)
    local dist = (toPos - fromPos).Magnitude
    if dist < 1 then return end
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

local function HookTools(char)
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(getgenv().DeepsikConns, tool.Activated:Connect(function()
                if not Config.BulletLaser then return end
                local handle = tool:FindFirstChild("Handle")
                if handle then
                    local mouse = UserInputService:GetMouseLocation()
                    local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
                    CreateLaser(handle.Position, ray.Origin + ray.Direction * 500)
                end
            end))
        end
    end
end

HookTools(LP.Character)
table.insert(getgenv().DeepsikConns, LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    HookTools(c)
end))

UI.CreateSection(PageVisuals, "🎥 CAMERA")
UI.CreateToggle(PageVisuals, "Camera Follow Knife", Config.CameraFollowKnife, function(s) Config.CameraFollowKnife = s end)

table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
    if not Config.CameraFollowKnife then return end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find("knife") and not obj.Anchored then
            pcall(function()
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, obj.Position)
            end)
            break
        end
    end
end))

print("✅ [Deepsik v3.1] Часть 4/5 — Teleport + Trolling + Visuals готовы")
R.Notify("⏳ Загрузка 4/5...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v3.1                    ║
    ║      ЧАСТЬ 5/5: ESP + Settings + Управление
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
local Camera = R.Camera
local TeleportService = R.TeleportService
local PageSettings = R.PageSettings
local MainFrame = R.MainFrame
local ScreenGui = R.ScreenGui
local CloseBtn = R.CloseBtn
local MinBtn = R.MinBtn
local ToggleBtn = R.ToggleBtn
local TitleBar = R.TitleBar
local ContentFrame = R.ContentFrame
local ESPObjects = getgenv().DeepsikESP
local GetRole = getgenv().DeepsikGetRole

-- ==================================================================
-- ESP
-- ==================================================================
local ROLE_COLORS = {
    Murder = Color3.fromRGB(255, 50, 50),
    Sheriff = Color3.fromRGB(50, 150, 255),
    Innocent = Color3.fromRGB(50, 255, 100),
}

local function CreateESPPlayer(player)
    if getgenv().DeepsikNoDrawing then return end
    if player == LP or ESPObjects[player] then return end
    pcall(function()
        local Box = Drawing.new("Square")
        Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1; Box.Visible = false

        local NameTag = Drawing.new("Text")
        NameTag.Size = 14; NameTag.Center = true; NameTag.Outline = true
        NameTag.Color = Color3.fromRGB(255, 255, 255); NameTag.Visible = false

        local DistanceTag = Drawing.new("Text")
        DistanceTag.Size = 12; DistanceTag.Center = true; DistanceTag.Outline = true
        DistanceTag.Color = Color3.fromRGB(0, 170, 255); DistanceTag.Visible = false

        local RoleTag = Drawing.new("Text")
        RoleTag.Size = 12; RoleTag.Center = true; RoleTag.Outline = true
        RoleTag.Color = Color3.fromRGB(255, 255, 255); RoleTag.Visible = false

        local Tracer = Drawing.new("Line")
        Tracer.Thickness = 1; Tracer.Visible = false

        ESPObjects[player] = {Box = Box, NameTag = NameTag, DistanceTag = DistanceTag, RoleTag = RoleTag, Tracer = Tracer}
    end)
end

local function RemoveESPPlayer(player)
    if ESPObjects[player] then
        for _, o in pairs(ESPObjects[player]) do
            pcall(function() o:Remove() end)
        end
        ESPObjects[player] = nil
    end
end

-- Gun ESP
local GunESPObjects = {}
local function UpdateGunESP()
    if not Config.GunESP then
        for _, o in pairs(GunESPObjects) do pcall(function() o:Remove() end) end
        GunESPObjects = {}
        return
    end
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("Tool") and not GunESPObjects[obj] then
            pcall(function()
                local tag = Drawing.new("Text")
                tag.Size = 12; tag.Center = true; tag.Outline = true
                tag.Color = Color3.fromRGB(255, 200, 0)
                tag.Text = obj.Name
                tag.Visible = false
                GunESPObjects[obj] = tag
            end)
        end
    end
end

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
            pcall(function()
                objs.Box.Visible = false; objs.NameTag.Visible = false
                objs.DistanceTag.Visible = false; objs.RoleTag.Visible = false; objs.Tracer.Visible = false
            end)
            continue
        end

        local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
        local hrpPos, hrpOn = Camera:WorldToViewportPoint(hrp.Position)

        if headOn and hrpOn then
            local h = math.abs(headPos.Y - hrpPos.Y) * 2
            local w = h * 0.6

            local role = GetRole(player)
            local col = Config.RoleESP and ROLE_COLORS[role] or Config.ESPColor

            pcall(function()
                objs.Box.Size = Vector2.new(w, h)
                objs.Box.Position = Vector2.new(headPos.X - w/2, headPos.Y)
                objs.Box.Color = col
                objs.Box.Visible = true

                local dist = (Camera.CFrame.Position - hrp.Position).Magnitude
                objs.NameTag.Text = player.Name
                objs.NameTag.Position = Vector2.new(headPos.X, headPos.Y - 20)
                objs.NameTag.Visible = true

                objs.DistanceTag.Text = string.format("[%d]", math.floor(dist))
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
            end)
        else
            pcall(function()
                objs.Box.Visible = false; objs.NameTag.Visible = false
                objs.DistanceTag.Visible = false; objs.RoleTag.Visible = false; objs.Tracer.Visible = false
            end)
        end
    end

    for gun, tag in pairs(GunESPObjects) do
        if not Config.GunESP or not gun.Parent then
            pcall(function() tag.Visible = false end)
        else
            local handle = gun:FindFirstChild("Handle")
            if handle then
                local sp, on = Camera:WorldToViewportPoint(handle.Position)
                if on then
                    pcall(function()
                        tag.Position = Vector2.new(sp.X, sp.Y)
                        tag.Text = gun.Name
                        tag.Visible = true
                    end)
                else
                    pcall(function() tag.Visible = false end)
                end
            end
        end
    end
end

if not getgenv().DeepsikNoDrawing then
    for _, plr in ipairs(Players:GetPlayers()) do CreateESPPlayer(plr) end
    table.insert(getgenv().DeepsikConns, Players.PlayerAdded:Connect(CreateESPPlayer))
    table.insert(getgenv().DeepsikConns, Players.PlayerRemoving:Connect(RemoveESPPlayer))
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        pcall(UpdateESP)
    end))
    table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
        if Config.GunESP and tick() % 1 < 0.02 then
            pcall(UpdateGunESP)
        end
    end))
end

-- ==================================================================
-- NOTIFIER
-- ==================================================================
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.KillNotifier and not Config.RoleNotifier then return end
    -- простое отслеживание
end))

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

local configName = "my_config"
UI.CreateInput(PageSettings, "Название конфига", configName, function(text)
    configName = text
end)

UI.CreateButton(PageSettings, "💾 Сохранить конфиг", Color3.fromRGB(0, 150, 0), function()
    pcall(function() R.SaveConfig(configName) end)
end)

UI.CreateButton(PageSettings, "📥 Загрузить конфиг", Color3.fromRGB(0, 120, 200), function()
    pcall(function()
        if R.LoadConfig(configName) then
            R.Notify("📥 Загружено (перезапусти скрипт)", 4)
        end
    end)
end)

UI.CreateButton(PageSettings, "📂 Список конфигов", Color3.fromRGB(100, 100, 120), function()
    pcall(function()
        local list = R.ListConfigs()
        if #list == 0 then
            R.Notify("📂 Нет конфигов", 3)
        else
            R.Notify("📂 " .. table.concat(list, ", "), 5)
        end
    end)
end)

UI.CreateSection(PageSettings, "🔧 ДЕЙСТВИЯ")

UI.CreateButton(PageSettings, "🔄 Rejoin сервер", Color3.fromRGB(0, 120, 200), function()
    R.Notify("🌍 Rejoin...", 2)
    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
end)

UI.CreateButton(PageSettings, "❌ Выгрузить Hub", Color3.fromRGB(200, 50, 50), function()
    if getgenv().DeepsikStopFly then pcall(getgenv().DeepsikStopFly) end
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
        pcall(function()
            InfoLabel.Text = string.format(
                "👥 Игроков: %d  |  📡 Ping: %d ms\n🔫 ESP: %s  |  ⚡ Speed: %s\n💙 Deepsik Hub v3.1",
                #Players:GetPlayers(),
                math.floor(LP:GetNetworkPing() * 1000),
                Config.ESP and "ON" or "OFF",
                Config.SpeedHack and "ON" or "OFF"
            )
        end)
        task.wait(1)
    end
end)

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
        if getgenv().DeepsikStopFly then pcall(getgenv().DeepsikStopFly) end
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

-- Инициализация
R.SwitchCategory(1)

print([[
╔══════════════════════════════════════════╗
║     🔫 DEEPSIK HUB v3.1 ЗАГРУЖЕН! 🔫     ║
║     ─────────────────────────────        ║
║     RightShift / F1 — открыть/закрыть    ║
║     Delete — выгрузить                   ║
║     G — Invis Bind                       ║
╚══════════════════════════════════════════╝
]])
R.Notify("✅ Deepsik Hub v3.1 запущен!", 3)
