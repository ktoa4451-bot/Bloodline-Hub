--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v4.0 - MM2              ║
    ║      ЧАСТЬ 1/7: Ядро + GUI               ║
    ╚══════════════════════════════════════════╝
]]

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
local VirtualUser = game:GetService("VirtualUser")

local _t = tick()
while not Players.LocalPlayer and tick() - _t < 30 do task.wait(0.1) end
if not Players.LocalPlayer then warn("[Deepsik] LocalPlayer не найден") return end
local LP = Players.LocalPlayer

local PlayerGui
_t = tick()
repeat
    task.wait(0.1)
    PlayerGui = LP:FindFirstChild("PlayerGui")
until PlayerGui or tick() - _t > 30
if not PlayerGui then warn("[Deepsik] PlayerGui не найден") return end

local Camera = Workspace.CurrentCamera
getgenv().DeepsikNoDrawing = (not Drawing)

-- ============ ДЕФОЛТНЫЙ КОНФИГ ============
local DefaultConfig = {
    -- Main / ESP
    ESP = false,
    RoleESP = true,          -- роль показывается только если игрок с ножом/пушкой
    GunESP = false,
    Tracers = false,
    ESPColor = Color3.fromRGB(0, 170, 255),

    -- Notifier
    KillNotifier = false,
    RoleNotifier = false,

    -- Combat: Sheriff
    AutoPickupGun = false,
    SilentAim = false, SilentAimFOV = 100,

    -- Combat: Murder
    KillAura = false, AuraRange = 30,
    KillOnlySheriff = false,
    KnifeAimbot = false,
    AimAssistAll = false, AimAssistAllFOV = 100,

    -- Movement
    Noclip = false,
    InfiniteJump = false,
    AntiFling = false,
    AntiRagdoll = false,
    Fly = false, FlySpeed = 50,
    Spin = false, SpinSpeed = 15,
    Bhop = false,
    Invis = false, InvisBind = false,
    SpeedHack = false, SpeedValue = 60,
    JumpPower = false, JumpValue = 120,

    -- Trolling
    TouchFling = false,
    ClickFling = false,
    FakeKorblox = false,
    FakeHeadless = false,

    -- Visuals
    CustomSky = false, SkyID = "",
    BulletLaser = false,
    CameraFollowKnife = false,

    -- Misc
    AntiAFK = true,
}

getgenv().DeepsikConfig = getgenv().DeepsikConfig or {}
for k, v in pairs(DefaultConfig) do
    if getgenv().DeepsikConfig[k] == nil then
        getgenv().DeepsikConfig[k] = v
    end
end
local Config = getgenv().DeepsikConfig

-- Очистка
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

-- ============ АНИМИРОВАННЫЙ ФОН ============
local AnimatedBg = Instance.new("Frame")
AnimatedBg.Size = UDim2.new(1, 0, 1, 0)
AnimatedBg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
AnimatedBg.BorderSizePixel = 0
AnimatedBg.ZIndex = 0
AnimatedBg.Parent = ScreenGui

local UIGradient = Instance.new("UIGradient")
UIGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(0, 170, 255)),
    ColorSequenceKeypoint.new(0.25, Color3.fromRGB(100, 0, 255)),
    ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 170, 255)),
    ColorSequenceKeypoint.new(0.75, Color3.fromRGB(255, 0, 150)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(0, 170, 255)),
})
UIGradient.Rotation = 45
UIGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.7),
    NumberSequenceKeypoint.new(0.5, 0.85),
    NumberSequenceKeypoint.new(1, 0.7),
})
UIGradient.Parent = AnimatedBg

-- Анимация фона
task.spawn(function()
    while AnimatedBg.Parent do
        UIGradient.Rotation = (UIGradient.Rotation + 1) % 360
        task.wait(0.03)
    end
end)

-- Заголовок окна
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 640, 0, 440)
MainFrame.Position = UDim2.new(0.5, -320, 0.5, -220)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 170, 255)
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Пульсирующая обводка
task.spawn(function()
    local tweenInfo = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    TweenService:Create(MainStroke, tweenInfo, {Transparency = 0.7}):Play()
end)

-- Градиент на главном окне
local MainGradient = Instance.new("UIGradient")
MainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 22)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(25, 20, 35)),
})
MainGradient.Rotation = 90
MainGradient.Parent = MainFrame

-- ===== ЗАГОЛОВОК =====
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 50)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleBar.BorderSizePixel = 0
TitleBar.ZIndex = 3
TitleBar.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 14)
TitleCorner.Parent = TitleBar

local TitleMask = Instance.new("Frame")
TitleMask.Size = UDim2.new(1, 0, 0, 25)
TitleMask.Position = UDim2.new(0, 0, 1, -25)
TitleMask.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
TitleMask.BorderSizePixel = 0
TitleMask.ZIndex = 3
TitleMask.Parent = TitleBar

local TitleGradient = Instance.new("UIGradient")
TitleGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 50, 255)),
})
TitleGradient.Rotation = 0
TitleGradient.Parent = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Size = UDim2.new(1, -100, 1, 0)
TitleLabel.Position = UDim2.new(0, 20, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.Text = "🔫 DEEPSIK HUB"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 24
TitleLabel.Font = Enum.Font.GothamBold
TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
TitleLabel.ZIndex = 4
TitleLabel.Parent = TitleBar

local VersionLabel = Instance.new("TextLabel")
VersionLabel.Size = UDim2.new(0, 80, 1, 0)
VersionLabel.Position = UDim2.new(1, -140, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.Text = "v4.0"
VersionLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
VersionLabel.TextSize = 14
VersionLabel.Font = Enum.Font.Gotham
VersionLabel.ZIndex = 4
VersionLabel.Parent = TitleBar

-- Кнопки управления
local function MakeTitleButton(text, pos, color)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 32, 0, 32)
    Btn.Position = pos
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    Btn.Text = text
    Btn.TextColor3 = color
    Btn.TextSize = 16
    Btn.Font = Enum.Font.GothamBold
    Btn.ZIndex = 5
    Btn.Parent = TitleBar
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Btn
    return Btn
end

local CloseBtn = MakeTitleButton("✕", UDim2.new(1, -42, 0, 9), Color3.fromRGB(255, 80, 80))
local MinBtn = MakeTitleButton("—", UDim2.new(1, -82, 0, 9), Color3.fromRGB(255, 200, 80))

-- Hover эффекты
for _, btn in ipairs({CloseBtn, MinBtn}) do
    local origColor = btn.BackgroundColor3
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(60, 60, 80)}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = origColor}):Play()
    end)
end

-- Плавающая кнопка
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 130, 0, 45)
ToggleBtn.Position = UDim2.new(0.5, -65, 1, -70)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
ToggleBtn.Text = "🔫 DEEPSIK"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 16
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Visible = false
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = ScreenGui
local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 10)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
ToggleStroke.Thickness = 2
ToggleStroke.Transparency = 0.5
ToggleStroke.Parent = ToggleBtn

-- ===== САЙДБАР =====
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 140, 1, -70)
SideBar.Position = UDim2.new(0, 12, 0, 62)
SideBar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
SideBar.BackgroundTransparency = 0.2
SideBar.BorderSizePixel = 0
SideBar.ZIndex = 3
SideBar.Parent = MainFrame

local SideCorner = Instance.new("UICorner")
SideCorner.CornerRadius = UDim.new(0, 10)
SideCorner.Parent = SideBar

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Size = UDim2.new(1, -8, 1, -10)
SideScroll.Position = UDim2.new(0, 4, 0, 5)
SideScroll.BackgroundTransparency = 1
SideScroll.BorderSizePixel = 0
SideScroll.ScrollBarThickness = 3
SideScroll.ScrollBarImageColor3 = Color3.fromRGB(0, 170, 255)
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SideScroll.ZIndex = 4
SideScroll.Parent = SideBar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 6)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideScroll
SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SideScroll.CanvasSize = UDim2.new(0, 0, 0, SideLayout.AbsoluteContentSize.Y + 10)
end)

-- ===== КОНТЕНТ =====
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -170, 1, -70)
ContentFrame.Position = UDim2.new(0, 158, 0, 62)
ContentFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
ContentFrame.BackgroundTransparency = 0.2
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.ZIndex = 3
ContentFrame.Parent = MainFrame

local ContentCorner = Instance.new("UICorner")
ContentCorner.CornerRadius = UDim.new(0, 10)
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
    Notify("❌ Не найдено: " .. name, 2)
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
    TeleportService = TeleportService, StarterGui = StarterGui,
    HttpService = HttpService, VirtualUser = VirtualUser,
    LocalPlayer = LP, Camera = Camera, Config = Config, Notify = Notify,
    SaveConfig = SaveConfig, LoadConfig = LoadConfig, ListConfigs = ListConfigs,
}

print("✅ [Deepsik v4.0] Часть 1/7 — Ядро + GUI")
Notify("⏳ Загрузка 1/7...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v4.0                    ║
    ║      ЧАСТЬ 2/7: UI-компоненты            ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
if not R then warn("❌ Запусти Часть 1!") return end

local TweenService = R.TweenService
local UserInputService = R.UserInputService
local SideScroll = R.SideScroll

-- Категория (анимированная)
local function CreateCategory(name, icon)
    local Cat = Instance.new("TextButton")
    Cat.Size = UDim2.new(1, -8, 0, 34)
    Cat.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Cat.Text = "  " .. icon .. "  " .. name
    Cat.TextColor3 = Color3.fromRGB(200, 200, 220)
    Cat.TextSize = 13
    Cat.Font = Enum.Font.GothamMedium
    Cat.TextXAlignment = Enum.TextXAlignment.Left
    Cat.AutoButtonColor = false
    Cat.ZIndex = 5
    Cat.Parent = SideScroll
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = Cat

    Cat.MouseEnter:Connect(function()
        if Cat.BackgroundColor3 ~= Color3.fromRGB(0, 170, 255) then
            TweenService:Create(Cat, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(45, 45, 65)
            }):Play()
        end
    end)
    Cat.MouseLeave:Connect(function()
        if Cat.BackgroundColor3 ~= Color3.fromRGB(0, 170, 255) then
            TweenService:Create(Cat, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(30, 30, 45)
            }):Play()
        end
    end)
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
    Page.ZIndex = 4
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
    Sec.Size = UDim2.new(1, -10, 0, 28)
    Sec.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
    Sec.Text = "  " .. text
    Sec.TextColor3 = Color3.fromRGB(0, 200, 255)
    Sec.TextSize = 13
    Sec.Font = Enum.Font.GothamBold
    Sec.TextXAlignment = Enum.TextXAlignment.Left
    Sec.ZIndex = 5
    Sec.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Sec

    local G = Instance.new("UIGradient")
    G.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(30, 30, 45)),
    })
    G.Parent = Sec
    return Sec
end

-- Тумблер
local function CreateToggle(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 34)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 40, 0, 20)
    Bg.Position = UDim2.new(1, -52, 0.5, -10)
    Bg.BackgroundColor3 = default and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 65)
    Bg.BorderSizePixel = 0
    Bg.ZIndex = 6
    Bg.Parent = Frame
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 10)
    BC.Parent = Bg

    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 16, 0, 16)
    Ind.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ind.BorderSizePixel = 0
    Ind.ZIndex = 7
    Ind.Parent = Bg
    local IC = Instance.new("UICorner")
    IC.CornerRadius = UDim.new(0, 10)
    IC.Parent = Ind

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 1, 0)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 8
    Btn.Parent = Frame

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(Bg, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            BackgroundColor3 = state and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(50, 50, 65)
        }):Play()
        TweenService:Create(Ind, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        }):Play()
        if callback then pcall(callback, state) end
    end)
    return Frame
end

-- Слайдер
local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 50)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 0, 20)
    Label.Position = UDim2.new(0, 14, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local ValueL = Instance.new("TextLabel")
    ValueL.Size = UDim2.new(0, 50, 0, 20)
    ValueL.Position = UDim2.new(1, -60, 0, 4)
    ValueL.BackgroundTransparency = 1
    ValueL.Text = tostring(default)
    ValueL.TextColor3 = Color3.fromRGB(0, 200, 255)
    ValueL.TextSize = 13
    ValueL.Font = Enum.Font.GothamBold
    ValueL.TextXAlignment = Enum.TextXAlignment.Right
    ValueL.ZIndex = 6
    ValueL.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 8)
    Bar.Position = UDim2.new(0, 14, 0, 32)
    Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 6
    Bar.Parent = Frame
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(0, 4)
    BC.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 7
    Fill.Parent = Bar
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(0, 4)
    FC.Parent = Fill

    local Fg = Instance.new("UIGradient")
    Fg.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 170, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(150, 100, 255)),
    })
    Fg.Parent = Fill

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
    Btn.Size = UDim2.new(1, -10, 0, 34)
    Btn.BackgroundColor3 = color or Color3.fromRGB(0, 120, 200)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.AutoButtonColor = false
    Btn.ZIndex = 5
    Btn.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = Btn

    local origColor = color or Color3.fromRGB(0, 120, 200)
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, origColor.R * 255 + 40),
                math.min(255, origColor.G * 255 + 40),
                math.min(255, origColor.B * 255 + 40)
            )
        }):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = origColor}):Play()
    end)

    Btn.MouseButton1Click:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(0.98, -10, 0, 32)}):Play()
        task.wait(0.1)
        TweenService:Create(Btn, TweenInfo.new(0.1), {Size = UDim2.new(1, -10, 0, 34)}):Play()
        if callback then pcall(callback) end
    end)
    return Btn
end

-- Инпут
local function CreateInput(parent, placeholder, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 34)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -24, 1, -8)
    Box.Position = UDim2.new(0, 12, 0, 4)
    Box.BackgroundTransparency = 1
    Box.Text = default or ""
    Box.PlaceholderText = placeholder or "Введите..."
    Box.PlaceholderColor3 = Color3.fromRGB(120, 120, 140)
    Box.TextColor3 = Color3.fromRGB(220, 220, 235)
    Box.TextSize = 13
    Box.Font = Enum.Font.GothamMedium
    Box.TextXAlignment = Enum.TextXAlignment.Left
    Box.ClearTextOnFocus = false
    Box.ZIndex = 6
    Box.Parent = Frame

    Box.FocusLost:Connect(function()
        if callback then pcall(callback, Box.Text) end
    end)
    return Frame, Box
end

-- Дропдаун
local function CreateDropdown(parent, text, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 34)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, -12, 0, 34)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local Selected = Instance.new("TextButton")
    Selected.Size = UDim2.new(0.5, -10, 0, 26)
    Selected.Position = UDim2.new(0.5, 0, 0, 4)
    Selected.BackgroundColor3 = Color3.fromRGB(0, 120, 200)
    Selected.Text = default or options[1] or "—"
    Selected.TextColor3 = Color3.fromRGB(255, 255, 255)
    Selected.TextSize = 12
    Selected.Font = Enum.Font.GothamBold
    Selected.ZIndex = 6
    Selected.Parent = Frame
    local SC = Instance.new("UICorner")
    SC.CornerRadius = UDim.new(0, 6)
    SC.Parent = Selected

    local open = false
    local optionFrames = {}

    Selected.MouseButton1Click:Connect(function()
        open = not open
        for _, of in ipairs(optionFrames) do of.Visible = open end
        Frame.Size = open and UDim2.new(1, -10, 0, 34 + #options * 28) or UDim2.new(1, -10, 0, 34)
    end)

    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, -10, 0, 26)
        OptBtn.Position = UDim2.new(0, 5, 0, 34 + (i - 1) * 28)
        OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 220)
        OptBtn.TextSize = 12
        OptBtn.Font = Enum.Font.GothamMedium
        OptBtn.Visible = false
        OptBtn.ZIndex = 6
        OptBtn.Parent = Frame
        local OC = Instance.new("UICorner")
        OC.CornerRadius = UDim.new(0, 6)
        OC.Parent = OptBtn

        OptBtn.MouseButton1Click:Connect(function()
            Selected.Text = opt
            open = false
            for _, of in ipairs(optionFrames) do of.Visible = false end
            Frame.Size = UDim2.new(1, -10, 0, 34)
            if callback then pcall(callback, opt) end
        end)
        table.insert(optionFrames, OptBtn)
    end
    return Frame
end

-- Color Picker
local function CreateColorPicker(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 7)
    C.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(220, 220, 235)
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local Preview = Instance.new("TextButton")
    Preview.Size = UDim2.new(0, 40, 0, 24)
    Preview.Position = UDim2.new(1, -52, 0.5, -12)
    Preview.BackgroundColor3 = default
    Preview.Text = ""
    Preview.ZIndex = 6
    Preview.Parent = Frame
    local PC = Instance.new("UICorner")
    PC.CornerRadius = UDim.new(0, 6)
    PC.Parent = Preview

    -- Простой picker через RGB слайдеры в отдельной панели
    local R_, G_, B_ = default.R, default.G, default.B

    local PickerPanel = Instance.new("Frame")
    PickerPanel.Size = UDim2.new(1, -10, 0, 130)
    PickerPanel.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
    PickerPanel.BorderSizePixel = 0
    PickerPanel.Visible = false
    PickerPanel.ZIndex = 5
    PickerPanel.Parent = parent
    local PPC = Instance.new("UICorner")
    PPC.CornerRadius = UDim.new(0, 7)
    PPC.Parent = PickerPanel

    local function MakeRGBSlider(label, defaultValue, yPos, key)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0, 20, 0, 24)
        lbl.Position = UDim2.new(0, 10, 0, yPos)
        lbl.BackgroundTransparency = 1
        lbl.Text = label
        lbl.TextColor3 = Color3.fromRGB(220, 220, 235)
        lbl.TextSize = 13
        lbl.Font = Enum.Font.GothamBold
        lbl.ZIndex = 6
        lbl.Parent = PickerPanel

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, -60, 0, 16)
        Bar.Position = UDim2.new(0, 35, 0, yPos + 4)
        Bar.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
        Bar.BorderSizePixel = 0
        Bar.ZIndex = 6
        Bar.Parent = PickerPanel
        local BC = Instance.new("UICorner")
        BC.CornerRadius = UDim.new(0, 8)
        BC.Parent = Bar

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(defaultValue / 255, 0, 1, 0)
        Fill.BackgroundColor3 = key == "R" and Color3.fromRGB(255, 80, 80) or (key == "G" and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(80, 80, 255))
        Fill.BorderSizePixel = 0
        Fill.ZIndex = 7
        Fill.Parent = Bar
        local FC = Instance.new("UICorner")
        FC.CornerRadius = UDim.new(0, 8)
        FC.Parent = Fill

        local val = Instance.new("TextLabel")
        val.Size = UDim2.new(0, 30, 1, 0)
        val.Position = UDim2.new(1, -35, 0, 0)
        val.BackgroundTransparency = 1
        val.Text = tostring(defaultValue)
        val.TextColor3 = Color3.fromRGB(220, 220, 235)
        val.TextSize = 12
        val.Font = Enum.Font.GothamBold
        val.ZIndex = 6
        val.Parent = Bar

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
                local v = math.floor(255 * rel)
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                val.Text = tostring(v)
                if key == "R" then R_ = v elseif key == "G" then G_ = v else B_ = v end
                local newColor = Color3.fromRGB(R_, G_, B_)
                Preview.BackgroundColor3 = newColor
                if callback then pcall(callback, newColor) end
            end
        end)
    end

    MakeRGBSlider("R", default.R * 255, 10, "R")
    MakeRGBSlider("G", default.G * 255, 45, "G")
    MakeRGBSlider("B", default.B * 255, 80, "B")

    Preview.MouseButton1Click:Connect(function()
        PickerPanel.Visible = not PickerPanel.Visible
        PickerPanel.Size = PickerPanel.Visible and UDim2.new(1, -10, 0, 130) or UDim2.new(1, -10, 0, 0)
    end)

    return Frame
end

getgenv().DeepsikUI = {
    CreateCategory = CreateCategory,
    CreatePage = CreatePage,
    CreateSection = CreateSection,
    CreateToggle = CreateToggle,
    CreateSlider = CreateSlider,
    CreateButton = CreateButton,
    CreateInput = CreateInput,
    CreateDropdown = CreateDropdown,
    CreateColorPicker = CreateColorPicker,
}

print("✅ [Deepsik v4.0] Часть 2/7 — UI-компоненты")
R.Notify("⏳ Загрузка 2/7...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v4.0                    ║
    ║      ЧАСТЬ 3/7: Категории + Main         ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-2!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
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
        c.Tab.BackgroundColor3 = (i == idx) and Color3.fromRGB(0, 170, 255) or Color3.fromRGB(30, 30, 45)
        c.Tab.TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 220)
    end
end

for i, c in ipairs(categories) do
    c.Tab.MouseButton1Click:Connect(function() SwitchCategory(i) end)
end

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

-- Роль ТОЛЬКО когда игрок держит нож/пистолет
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    local char = plr.Character
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local name = tool.Name:lower()
            if name:find("knife") or name:find("dagger") then
                return "Murder"
            elseif name:find("gun") or name:find("revolver") or name:find("pistol") then
                return "Sheriff"
            end
        end
    end
    return "Innocent"
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
                if not filter or filter(plr) then
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
    local char = LP.Character
    if not char then return nil end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return c end
    end
end
getgenv().DeepsikGetTool = GetEquippedTool

-- ============ MAIN ============
UI.CreateSection(PageMain, "🎯 ESP")
UI.CreateToggle(PageMain, "ESP игроков", Config.ESP, function(s) Config.ESP = s end)
UI.CreateToggle(PageMain, "Role ESP (цвет = роль)", Config.RoleESP, function(s) Config.RoleESP = s end)
UI.CreateToggle(PageMain, "Gun ESP (оружие)", Config.GunESP, function(s) Config.GunESP = s end)
UI.CreateToggle(PageMain, "Tracers (линии)", Config.Tracers, function(s) Config.Tracers = s end)

UI.CreateSection(PageMain, "🎨 ЦВЕТ ESP")
UI.CreateColorPicker(PageMain, "Цвет ESP", Config.ESPColor, function(c)
    Config.ESPColor = c
end)

UI.CreateSection(PageMain, "🔔 NOTIFIER")
UI.CreateToggle(PageMain, "Kill Notifier", Config.KillNotifier, function(s) Config.KillNotifier = s end)
UI.CreateToggle(PageMain, "Role Notifier", Config.RoleNotifier, function(s) Config.RoleNotifier = s end)

print("✅ [Deepsik v4.0] Часть 3/7 — Категории + Main")
R.Notify("⏳ Загрузка 3/7...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v4.0                    ║
    ║      ЧАСТЬ 4/7: Combat                   ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-3!") return end

local Config = R.Config
local LP = R.LocalPlayer
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera
local PageCombat = R.PageCombat

local GetChar = getgenv().DeepsikGetChar
local GetTargets = getgenv().DeepsikGetTargets
local GetRole = getgenv().DeepsikGetRole
local GetEquippedTool = getgenv().DeepsikGetTool

-- ============ UI ============
UI.CreateSection(PageCombat, "🚔 SHERIFF")
UI.CreateToggle(PageCombat, "Auto Pickup Gun", Config.AutoPickupGun, function(s) Config.AutoPickupGun = s end)
UI.CreateToggle(PageCombat, "Silent Aim", Config.SilentAim, function(s) Config.SilentAim = s end)
UI.CreateSlider(PageCombat, "Silent Aim FOV", 10, 500, Config.SilentAimFOV, function(v) Config.SilentAimFOV = v end)

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
    if not tool then R.Notify("❌ Возьми нож", 2) return end
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

-- ============ AUTO PICKUP GUN (полностью переписан) ============
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.AutoPickupGun then return end
    local char, myHrp, hum = GetChar()
    if not myHrp or not hum then return end
    -- Ищем Tools в Workspace
    for _, obj in ipairs(Workspace:GetChildren()) do
        if obj:IsA("Tool") then
            local h = obj:FindFirstChild("Handle")
            if h and (myHrp.Position - h.Position).Magnitude < 30 then
                pcall(function() hum:EquipTool(obj) end)
            end
        end
    end
    -- Также ищем внутри backpack
    local backpack = LP:FindFirstChild("Backpack")
    if backpack then
        for _, tool in ipairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                pcall(function() hum:EquipTool(tool) end)
            end
        end
    end
end))

-- ============ SILENT AIM (реально наводит) ============
local silentAimTarget = nil
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
        silentAimTarget = best
        -- Silent: жёстко наводим камеру на цель
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, best.hrp.Position)
    end
end))

-- ============ KILL AURA ============
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.KillAura then return end
    local tool = GetEquippedTool()
    if not tool then return end

    local targets = GetTargets(function(p)
        if Config.KillOnlySheriff then
            return GetRole(p) == "Sheriff"
        end
        return true
    end)

    for _, t in ipairs(targets) do
        if t.dist <= Config.AuraRange then
            pcall(function() tool:Activate() end)
            task.wait(0.05)
        end
    end
end))

-- ============ KNIFE AIMBOT ============
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

-- ============ AIM ASSIST ALL ============
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

print("✅ [Deepsik v4.0] Часть 4/7 — Combat")
R.Notify("⏳ Загрузка 4/7...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v4.0                    ║
    ║      ЧАСТЬ 5/7: Movement                 ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-3!") return end

local Config = R.Config
local LP = R.LocalPlayer
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local PageMovement = R.PageMovement

local GetChar = getgenv().DeepsikGetChar

-- ============ UI ============
UI.CreateSection(PageMovement, "🏃 BASIC")
UI.CreateToggle(PageMovement, "Noclip", Config.Noclip, function(s) Config.Noclip = s end)
UI.CreateToggle(PageMovement, "Infinite Jump", Config.InfiniteJump, function(s) Config.InfiniteJump = s end)
UI.CreateToggle(PageMovement, "Anti-Fling", Config.AntiFling, function(s) Config.AntiFling = s end)
UI.CreateToggle(PageMovement, "Anti-Ragdoll", Config.AntiRagdoll, function(s) Config.AntiRagdoll = s end)

UI.CreateSection(PageMovement, "⚡ SPEED / JUMP")
UI.CreateToggle(PageMovement, "Speed Hack", Config.SpeedHack, function(s)
    Config.SpeedHack = s
    local _, _, hum = GetChar()
    if hum then hum.WalkSpeed = s and Config.SpeedValue or 16 end
end)
UI.CreateSlider(PageMovement, "Скорость", 16, 250, Config.SpeedValue, function(v)
    Config.SpeedValue = v
    local _, _, hum = GetChar()
    if hum and Config.SpeedHack then hum.WalkSpeed = v end
end)
UI.CreateToggle(PageMovement, "Jump Power", Config.JumpPower, function(s)
    Config.JumpPower = s
    local _, _, hum = GetChar()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = s and Config.JumpValue or 50
    end
end)
UI.CreateSlider(PageMovement, "Сила прыжка", 50, 500, Config.JumpValue, function(v)
    Config.JumpValue = v
    local _, _, hum = GetChar()
    if hum and Config.JumpPower then
        hum.UseJumpPower = true
        hum.JumpPower = v
    end
end)

-- ============ BHOP (правильный) ============
UI.CreateToggle(PageMovement, "Bhop", Config.Bhop, function(s) Config.Bhop = s end)

local bhopSpeed = 16
local bhopLastSpace = 0
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.Bhop then
        bhopSpeed = 16
        return
    end
    local char, hrp, hum = GetChar()
    if not hrp or not hum then return end

    if hum:GetState() == Enum.HumanoidStateType.Landed then
        -- Ускоряемся при каждом приземлении
        bhopSpeed = math.min(bhopSpeed + 1.5, 100)
        hum.WalkSpeed = bhopSpeed
        -- Автоматический прыжок
        if tick() - bhopLastSpace > 0.1 then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
            bhopLastSpace = tick()
        end
    elseif hum:GetState() == Enum.HumanoidStateType.Running then
        -- Медленно сбрасываем скорость если не прыгаем
        bhopSpeed = math.max(bhopSpeed - 0.5, 16)
        hum.WalkSpeed = bhopSpeed
    end

    -- Если игрок отпустил пробел — сброс
    if not UserInputService:IsKeyDown(Enum.KeyCode.Space) and hum:GetState() == Enum.HumanoidStateType.Running then
        bhopSpeed = 16
        hum.WalkSpeed = 16
    end
end))

UI.CreateSection(PageMovement, "🕊️ FLY / SPIN")
UI.CreateToggle(PageMovement, "Fly", Config.Fly, function(s)
    Config.Fly = s
    if s and getgenv().DeepsikStartFly then getgenv().DeepsikStartFly()
    elseif getgenv().DeepsikStopFly then getgenv().DeepsikStopFly() end
end)
UI.CreateSlider(PageMovement, "Скорость полёта", 10, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end)

UI.CreateToggle(PageMovement, "Spin", Config.Spin, function(s) Config.Spin = s end)
UI.CreateSlider(PageMovement, "Скорость Spin", 1, 60, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)

UI.CreateSection(PageMovement, "👻 INVIS")
UI.CreateToggle(PageMovement, "Invis", Config.Invis, function(s) Config.Invis = s end)
UI.CreateToggle(PageMovement, "Invis Bind (G)", Config.InvisBind, function(s) Config.InvisBind = s end)

-- ============ FLY (ИСПРАВЛЕНО) ============
local flyActive = false
local flyBV, flyBG = nil, nil

local function StopFly()
    flyActive = false
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    local _, _, hum = GetChar()
    if hum then hum.PlatformStand = false end
end

local function StartFly()
    StopFly()
    local _, hrp, hum = GetChar()
    if not hrp or not hum then return end

    hum.PlatformStand = true

    flyBV = Instance.new("BodyVelocity")
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.new(0, 0, 0)
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 10000
    flyBG.D = 500
    flyBG.Parent = hrp

    flyActive = true

    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        if not flyActive or not Config.Fly then StopFly(); return end
        local _, h, hum2 = GetChar()
        if not h or not hum2 then StopFly(); return end

        local dir = Vector3.new(0, 0, 0)
        local cam = Workspace.CurrentCamera
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0, 1, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0, 1, 0) end
        if dir.Magnitude > 0 then dir = dir.Unit * Config.FlySpeed end

        flyBV.Velocity = dir
        flyBG.CFrame = cam.CFrame
    end))
end

getgenv().DeepsikStartFly = StartFly
getgenv().DeepsikStopFly = StopFly

-- ============ SPIN (ИСПРАВЛЕНО) ============
local spinAngle = 0
table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function(dt)
    if not Config.Spin then return end
    local _, hrp = GetChar()
    if not hrp then return end
    spinAngle = spinAngle + Config.SpinSpeed * dt
    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
end))

-- ============ INVIS (ИСПРАВЛЕНО - убирается при касании камеры) ============
table.insert(getgenv().DeepsikConns, RunService.Stepped:Connect(function()
    if not Config.Invis or not LP.Character then return end
    for _, part in ipairs(LP.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function()
                part.Transparency = 1
                part.CanCollide = false
            end)
        end
    end
    local head = LP.Character:FindFirstChild("Head")
    if head then pcall(function() head.Transparency = 1 end) end
end))

-- Отключаем invis при движении камеры
table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
    if not Config.Invis then return end
    local char = LP.Character
    if not char then return end
    -- Если игрок двигает мышью и отдаляется камера — отключаем
    local currentCF = Camera.CFrame
    if not getgenv().DeepsikLastCF then getgenv().DeepsikLastCF = currentCF end
    local moved = (currentCF.Position - getgenv().DeepsikLastCF.Position).Magnitude
    getgenv().DeepsikLastCF = currentCF
    if moved > 5 then
        -- камера сильно отдалилась, отключаем
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                pcall(function() part.Transparency = 0 end)
            end
        end
    end
end))

-- ============ NOCLIP ============
table.insert(getgenv().DeepsikConns, RunService.Stepped:Connect(function()
    if not Config.Noclip or not LP.Character then return end
    for _, part in ipairs(LP.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.CanCollide = false
        end
    end
end))

-- ============ INFINITE JUMP ============
table.insert(getgenv().DeepsikConns, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local _, _, hum = GetChar()
        if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end))

-- ============ SPEED / JUMP UPDATE ============
local function UpdateSpeed()
    local _, _, hum = GetChar()
    if hum then hum.WalkSpeed = Config.SpeedHack and Config.SpeedValue or 16 end
end
local function UpdateJump()
    local _, _, hum = GetChar()
    if hum then
        hum.UseJumpPower = true
        hum.JumpPower = Config.JumpPower and Config.JumpValue or 50
    end
end

table.insert(getgenv().DeepsikConns, LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateSpeed(); UpdateJump()
end))

-- ============ ANTI-FLING ============
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.AntiFling then return end
    local _, hrp = GetChar()
    if hrp and hrp.Velocity.Magnitude > 100 then
        hrp.Velocity = hrp.Velocity.Unit * 100
    end
end))

-- ============ ANTI-RAGDOLL ============
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.AntiRagdoll then return end
    local char = LP.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        pcall(function()
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        end)
    end
end))

-- ============ ANTI-AFK ============
table.insert(getgenv().DeepsikConns, LP.Idled:Connect(function()
    if not Config.AntiAFK then return end
    pcall(function()
        R.VirtualUser:CaptureController()
        R.VirtualUser:ClickButton2(Vector2.new())
    end)
end))

-- ============ INVIS BIND (G) ============
table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.InvisBind and input.KeyCode == Enum.KeyCode.G then
        Config.Invis = not Config.Invis
        -- Восстанавливаем если выключили
        if not Config.Invis and LP.Character then
            for _, part in ipairs(LP.Character:GetDescendants()) do
                if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
                    pcall(function() part.Transparency = 0 end)
                end
            end
        end
        R.Notify("👻 Invis: " .. (Config.Invis and "ВКЛ" or "ВЫКЛ"), 2)
    end
end))

print("✅ [Deepsik v4.0] Часть 5/7 — Movement")
R.Notify("⏳ Загрузка 5/7...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v4.0                    ║
    ║      ЧАСТЬ 6/7: Teleport + Trolling      ║
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
local PageTeleport = R.PageTeleport
local PageTrolling = R.PageTrolling

local GetChar = getgenv().DeepsikGetChar
local GetTargets = getgenv().DeepsikGetTargets
local GetRole = getgenv().DeepsikGetRole

-- ==================================================================
-- TELEPORT
-- ==================================================================
UI.CreateSection(PageTeleport, "🌐 TELEPORT")

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
        R.Notify("❌ Murder не найден (нож в руках)", 2)
    end
end)

UI.CreateButton(PageTeleport, "🚔 TP to Sheriff", Color3.fromRGB(50, 120, 255), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Sheriff" end)
    local _, hrp = GetChar()
    if hrp and #targets > 0 then
        hrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🚔 К Sheriff", 2)
    else
        R.Notify("❌ Sheriff не найден (пушка в руках)", 2)
    end
end)

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
        R.Notify("❌ Не найден", 2)
    end
end)

-- ==================================================================
-- TROLLING
-- ==================================================================
UI.CreateSection(PageTrolling, "😈 TROLL")

UI.CreateToggle(PageTrolling, "Touch Fling", Config.TouchFling, function(s) Config.TouchFling = s end)
UI.CreateToggle(PageTrolling, "Click Fling", Config.ClickFling, function(s) Config.ClickFling = s end)

-- ============ TOUCH FLING (ИСПРАВЛЕНО) ============
local touchFlingConns = {}
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.TouchFling then return end
    local char, myHrp, hum = GetChar()
    if not myHrp or not hum then return end
    -- Ищем игроков вблизи
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character and plr.Character.Parent then
            local theirHrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if theirHrp and (myHrp.Position - theirHrp.Position).Magnitude < 8 then
                pcall(function()
                    -- Откидываем их через BodyVelocity
                    local bv = theirHrp:FindFirstChild("DeepsikFling")
                    if not bv then
                        bv = Instance.new("BodyVelocity")
                        bv.Name = "DeepsikFling"
                        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                        bv.Velocity = Vector3.new(500, 800, 500)
                        bv.Parent = theirHrp
                        task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
                    end
                end)
            end
        end
    end
end))

-- ============ CLICK FLING (ИСПРАВЛЕНО) ============
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
            if hrp then
                pcall(function()
                    hrp.Velocity = Vector3.new(1000, 1000, 1000)
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(1000, 1000, 1000)
                    bv.Parent = hrp
                    task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
                end)
                local targetPlr = Players:GetPlayerFromCharacter(char)
                if targetPlr then R.Notify("😈 Fling: " .. targetPlr.Name, 2) end
            end
        end
    end
end))

-- ============ FUN / АНИМАЦИИ ============
UI.CreateSection(PageTrolling, "🎉 АНИМАЦИИ (реальные)")

-- Используем стандартные анимации Roblox (работают всегда)
local ANIMATIONS = {
    Dance1 = "rbxassetid://507771019",
    Dance2 = "rbxassetid://507776043",
    Dance3 = "rbxassetid://507777268",
    Wave = "rbxassetid://507770239",
    Point = "rbxassetid://507770453",
    Salute = "rbxassetid://507768375",
}

local currentAnimTrack = nil
local animator = nil

-- Получаем Animator
local function GetAnimator()
    local char = LP.Character
    if not char then return nil end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return nil end
    local anim = hum:FindFirstChildOfClass("Animator")
    if not anim then
        anim = Instance.new("Animator")
        anim.Parent = hum
    end
    return anim
end

local function PlayAnimation(animId, loop)
    local anim = GetAnimator()
    if not anim then return end

    -- Останавливаем предыдущую
    if currentAnimTrack then
        pcall(function() currentAnimTrack:Stop() end)
        currentAnimTrack = nil
    end

    local animation = Instance.new("Animation")
    animation.AnimationId = animId

    local track = anim:LoadAnimation(animation)
    track.Looped = loop or false
    track:Play()
    currentAnimTrack = track

    -- Авто-стоп через 5 сек если не loop
    if not loop then
        task.delay(5, function()
            if currentAnimTrack == track then
                pcall(function() track:Stop() end)
                currentAnimTrack = nil
            end
        end)
    end
end

UI.CreateButton(PageTrolling, "💃 Танец 1", Color3.fromRGB(150, 100, 200), function()
    PlayAnimation(ANIMATIONS.Dance1, true)
    R.Notify("💃 Танец 1 (повторно нажми для стоп)", 2)
end)

UI.CreateButton(PageTrolling, "🕺 Танец 2", Color3.fromRGB(150, 100, 200), function()
    PlayAnimation(ANIMATIONS.Dance2, true)
    R.Notify("🕺 Танец 2", 2)
end)

UI.CreateButton(PageTrolling, "🌀 Танец 3", Color3.fromRGB(150, 100, 200), function()
    PlayAnimation(ANIMATIONS.Dance3, true)
    R.Notify("🌀 Танец 3", 2)
end)

UI.CreateButton(PageTrolling, "👋 Махнуть рукой", Color3.fromRGB(100, 150, 200), function()
    PlayAnimation(ANIMATIONS.Wave, false)
end)

UI.CreateButton(PageTrolling, "👉 Указать", Color3.fromRGB(100, 150, 200), function()
    PlayAnimation(ANIMATIONS.Point, false)
end)

UI.CreateButton(PageTrolling, "🫡 Честь", Color3.fromRGB(100, 150, 200), function()
    PlayAnimation(ANIMATIONS.Salute, false)
end)

UI.CreateButton(PageTrolling, "🛑 Остановить анимацию", Color3.fromRGB(200, 50, 50), function()
    if currentAnimTrack then
        pcall(function() currentAnimTrack:Stop() end)
        currentAnimTrack = nil
        R.Notify("🛑 Остановлено", 2)
    end
end)

-- ============ FAKE KORBLOX (ИСПРАВЛЕНО — вся правая нога) ============
UI.CreateSection(PageTrolling, "🎭 FAKE ITEMS")

UI.CreateToggle(PageTrolling, "Fake Korblox", Config.FakeKorblox, function(s)
    Config.FakeKorblox = s
    if not LP.Character then return end
    local legsToHide = {"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}
    for _, legName in ipairs(legsToHide) do
        local leg = LP.Character:FindFirstChild(legName)
        if leg then
            pcall(function()
                leg.Transparency = s and 1 or 0
                leg.CanCollide = not s
            end)
        end
    end
end)

UI.CreateToggle(PageTrolling, "Fake Headless", Config.FakeHeadless, function(s)
    Config.FakeHeadless = s
    if not LP.Character then return end
    local head = LP.Character:FindFirstChild("Head")
    if head then
        pcall(function()
            head.Transparency = s and 1 or 0
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if mesh then
                mesh.Scale = s and Vector3.new(0.01, 0.01, 0.01) or Vector3.new(1.25, 1.25, 1.25)
            end
            local decal = head:FindFirstChildOfClass("Decal")
            if decal then decal.Transparency = s and 1 or 0 end
        end)
    end
end)

print("✅ [Deepsik v4.0] Часть 6/7 — Teleport + Trolling")
R.Notify("⏳ Загрузка 6/7...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v4.0                    ║
    ║      ЧАСТЬ 7/7: Visuals + ESP + Settings ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-6!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Camera = R.Camera
local Workspace = R.Workspace
local Lighting = R.Lighting
local TweenService = R.TweenService
local TeleportService = R.TeleportService
local PageVisuals = R.PageVisuals
local PageSettings = R.PageSettings
local MainFrame = R.MainFrame
local ScreenGui = R.ScreenGui
local CloseBtn = R.CloseBtn
local MinBtn = R.MinBtn
local ToggleBtn = R.ToggleBtn
local ESPObjects = getgenv().DeepsikESP
local GetRole = getgenv().DeepsikGetRole

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
        sky.SkyboxBk = text; sky.SkyboxDn = text; sky.SkyboxFt = text
        sky.SkyboxLf = text; sky.SkyboxRt = text; sky.SkyboxUp = text
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

-- ============ BULLET LASER (ИСПРАВЛЕНО) ============
UI.CreateSection(PageVisuals, "🔫 BULLET LASER")
UI.CreateToggle(PageVisuals, "Bullet Laser", Config.BulletLaser, function(s) Config.BulletLaser = s end)

local laserFolder = Workspace:FindFirstChild("DeepsikLasers")
if not laserFolder then
    laserFolder = Instance.new("Folder")
    laserFolder.Name = "DeepsikLasers"
    laserFolder.Parent = Workspace
end

local function CreateLaser(fromPos, toPos)
    local dist = (toPos - fromPos).Magnitude
    if dist < 1 then return end
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.15, 0.15, dist)
    part.CFrame = CFrame.new(fromPos, toPos) * CFrame.new(0, 0, -dist / 2)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(255, 50, 50)
    part.Transparency = 0.15
    part.Parent = laserFolder
    TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1}):Play()
    task.delay(0.6, function() pcall(function() part:Destroy() end) end)
end

-- Хук на выстрел
local function HookTools(char)
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(getgenv().DeepsikConns, tool.Activated:Connect(function()
                if not Config.BulletLaser then return end
                local handle = tool:FindFirstChild("Handle")
                if not handle then return end

                local mouse = UserInputService:GetMouseLocation()
                local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)

                -- Проверяем, попал ли луч в игрока
                local params = RaycastParams.new()
                params.FilterDescendantsInstances = {LP.Character}
                params.FilterType = Enum.RaycastFilterType.Exclude
                local hit = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)

                local endPos
                if hit then
                    endPos = hit.Position
                else
                    endPos = ray.Origin + ray.Direction * 1000
                end

                CreateLaser(handle.Position, endPos)
            end))
        end
    end
end

HookTools(LP.Character)
table.insert(getgenv().DeepsikConns, LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    HookTools(c)
end))

-- ============ CAMERA FOLLOW KNIFE (ИСПРАВЛЕНО — только когда Murder кидает) ============
UI.CreateSection(PageVisuals, "🎥 CAMERA")
UI.CreateToggle(PageVisuals, "Camera Follow Knife (когда кидают)", Config.CameraFollowKnife, function(s) Config.CameraFollowKnife = s end)

local originalCameraCF = nil
table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
    if not Config.CameraFollowKnife then
        if originalCameraCF then originalCameraCF = nil end
        return
    end

    -- Ищем летящий нож в Workspace (не в руках)
    local flyingKnife = nil
    for _, obj in ipairs(Workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj.Anchored then
            local name = obj.Name:lower()
            if name:find("knife") or name:find("dagger") then
                -- Проверяем, что это не в руках игрока
                local parent = obj.Parent
                if not parent or not parent:FindFirstChild("Handle") then
                    flyingKnife = obj
                    break
                end
            end
        end
    end

    if flyingKnife then
        pcall(function()
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, flyingKnife.Position)
        end)
    end
end))

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
        RoleTag.Size = 14; RoleTag.Center = true; RoleTag.Outline = true
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

-- Обновление ESP
local function UpdateESP()
    for player, objs in pairs(ESPObjects) do
        local char = player.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local head = char and char:FindFirstChild("Head")
        local hum = char and char:FindFirstChildOfClass("Humanoid")

        local show = Config.ESP and hum and hum.Health > 0 and hrp and head

        if not show then
            pcall(function()
                objs.Box.Visible = false; objs.NameTag.Visible = false
                objs.DistanceTag.Visible = false; objs.RoleTag.Visible = false
                objs.Tracer.Visible = false
            end)
            continue
        end

        local headPos, headOn = Camera:WorldToViewportPoint(head.Position)
        local hrpPos, hrpOn = Camera:WorldToViewportPoint(hrp.Position)

        if headOn and hrpOn then
            local h = math.abs(headPos.Y - hrpPos.Y) * 2
            local w = h * 0.6

            -- Роль берём ТОЛЬКО если держит нож/пушку
            local role = GetRole(player)
            local col = Config.ESPColor
            if Config.RoleESP and role ~= "Innocent" then
                col = ROLE_COLORS[role]
            end

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

                -- RoleTag показываем ТОЛЬКО если держит оружие
                if Config.RoleESP and role ~= "Innocent" then
                    objs.RoleTag.Text = role
                    objs.RoleTag.Color = ROLE_COLORS[role]
                    objs.RoleTag.Position = Vector2.new(headPos.X, headPos.Y + h + 18)
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
                objs.DistanceTag.Visible = false; objs.RoleTag.Visible = false
                objs.Tracer.Visible = false
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
-- NOTIFIER (ИСПРАВЛЕНО)
-- ==================================================================
local lastRoles = {}
local lastHealth = {}

-- Role Notifier — показывает когда игрок достаёт нож/пистолет
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.RoleNotifier then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP then
            local role = GetRole(plr)
            if role ~= "Innocent" then
                if lastRoles[plr] ~= role then
                    lastRoles[plr] = role
                    R.Notify(string.format("🔍 %s — %s", plr.Name, role), 4)
                end
            else
                lastRoles[plr] = nil
            end
        end
    end
end))

-- Kill Notifier — отслеживание смертей
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.KillNotifier then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if hum then
                local prev = lastHealth[plr] or hum.Health
                if prev > 0 and hum.Health <= 0 then
                    -- Ищем убийцу рядом
                    local killer = nil
                    local char = plr.Character
                    local hrp = char:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        for _, other in ipairs(Players:GetPlayers()) do
                            if other ~= plr and other.Character then
                                local oHrp = other.Character:FindFirstChild("HumanoidRootPart")
                                if oHrp and (hrp.Position - oHrp.Position).Magnitude < 10 then
                                    killer = other
                                    break
                                end
                            end
                        end
                    end
                    if killer then
                        R.Notify(string.format("💀 %s убил %s", killer.Name, plr.Name), 4)
                    else
                        R.Notify(string.format("💀 %s умер", plr.Name), 3)
                    end
                end
                lastHealth[plr] = hum.Health
            end
        end
    end
end))

-- ==================================================================
-- SETTINGS
-- ==================================================================
UI.CreateSection(PageSettings, "🎨 UI")
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
            R.Notify("📂 Нет сохранённых конфигов", 3)
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
InfoLabel.Size = UDim2.new(1, -10, 0, 90)
InfoLabel.BackgroundColor3 = Color3.fromRGB(28, 28, 40)
InfoLabel.Text = "Загрузка..."
InfoLabel.TextColor3 = Color3.fromRGB(220, 220, 235)
InfoLabel.TextSize = 12
InfoLabel.Font = Enum.Font.GothamMedium
InfoLabel.TextXAlignment = Enum.TextXAlignment.Left
InfoLabel.TextYAlignment = Enum.TextYAlignment.Top
InfoLabel.ZIndex = 5
InfoLabel.Parent = PageSettings
local ILC = Instance.new("UICorner")
ILC.CornerRadius = UDim.new(0, 7)
ILC.Parent = InfoLabel
local ILP = Instance.new("UIPadding")
ILP.PaddingTop = UDim.new(0, 8)
ILP.PaddingLeft = UDim.new(0, 12)
ILP.Parent = InfoLabel

task.spawn(function()
    while InfoLabel.Parent do
        pcall(function()
            InfoLabel.Text = string.format(
                "👥 Игроков: %d  |  📡 Ping: %d ms\n🔫 ESP: %s  |  ⚡ Speed: %s\n🕊️ Fly: %s  |  👻 Invis: %s\n💙 Deepsik Hub v4.0",
                #Players:GetPlayers(),
                math.floor(LP:GetNetworkPing() * 1000),
                Config.ESP and "ON" or "OFF",
                Config.SpeedHack and "ON" or "OFF",
                Config.Fly and "ON" or "OFF",
                Config.Invis and "ON" or "OFF"
            )
        end)
        task.wait(1)
    end
end)

-- ==================================================================
-- УПРАВЛЕНИЕ ОКНОМ
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

-- Плавное открытие/закрытие
local function ToggleMenu()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.2)
        MainFrame.Visible = false
        ToggleBtn.Visible = true
    else
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 640, 0, 440)
        }):Play()
        ToggleBtn.Visible = false
    end
end

-- ==================================================================
-- ГОРЯЧИЕ КЛАВИШИ
-- ==================================================================
table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- RightShift / F1 — меню
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.F1 then
        ToggleMenu()
    end

    -- Delete — выгрузить
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
        pcall(function()
            StarterGui:SetCore("SendNotification", {
                Title = "Deepsik Hub", Text = "❌ Hub выгружен", Duration = 2
            })
        end)
    end
end))

-- ==================================================================
-- ИНИЦИАЛИЗАЦИЯ
-- ==================================================================
R.SwitchCategory(1)

-- Стартовое уведомление
task.spawn(function()
    task.wait(0.5)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "🔫 Deepsik Hub v4.0",
            Text = "✅ Загружен! RightShift — открыть меню",
            Duration = 5
        })
    end)
end)

print([[
╔══════════════════════════════════════════╗
║     🔫 DEEPSIK HUB v4.0 ЗАГРУЖЕН! 🔫     ║
║     ─────────────────────────────        ║
║     RightShift / F1 — меню               ║
║     Delete — выгрузить                   ║
║     G — Invis Bind                       ║
║     ─────────────────────────────        ║
║     Всего функций: 40+                   ║
║     Категорий: 7                         ║
╚══════════════════════════════════════════╝
]])
R.Notify("✅ Deepsik Hub v4.0 запущен!", 3)
