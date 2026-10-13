--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0 - MM2              ║
    ║      ЧАСТЬ 1/6: Ядро + GUI (KITI style)  ║
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
local SoundService = game:GetService("SoundService")

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

-- ============ КОНФИГ ============
local DefaultConfig = {
    -- ESP
    ESP = false, RoleESP = true, SkeletonESP = false,
    GunESP = false, Tracers = false, HitboxExpander = false,
    HitboxSize = 5,
    ESPColor = Color3.fromRGB(200, 130, 255),

    -- Notifier
    KillNotifier = false, RoleNotifier = false,

    -- Combat
    AutoPickupGun = false,
    SilentAim = false, SilentAimFOV = 100, WallCheck = false,
    KillAura = false, AuraRange = 30,
    KillOnlySheriff = false,
    KnifeAimbot = false,
    AimAssistAll = false, AimAssistAllFOV = 100,

    -- MM2 Special
    RevealRoles = false,
    AutoWin = false,
    SecondChance = false,
    AutoFarmCoins = false,

    -- Movement
    Noclip = false, InfiniteJump = false,
    AntiFling = false, AntiRagdoll = false,
    Fly = false, FlySpeed = 50,
    Spin = false, SpinSpeed = 15,
    Bhop = false,
    Invis = false, InvisBind = false,
    SpeedHack = false, SpeedValue = 60,
    JumpPower = false, JumpValue = 120,
    ClickTP = false,

    -- Visuals (KITI)
    GunModel = false, GunModelType = "BigUSP-S",
    GunBeam = false, GunBeamType = "Default",
    GunBeamColor = Color3.fromRGB(200, 130, 255),
    ChinaHat = false,
    JumpCircle = false,
    ChinaHatColor = Color3.fromRGB(255, 80, 80),
    BigHead = false,
    Fullbright = false,

    -- Auras
    Aura = "None",

    -- Skybox
    CustomSky = false, SkyID = "",
    BackgroundID = "",

    -- Trolling
    TouchFling = false, ClickFling = false,
    FlingAll = false, FlingMurder = false, FlingSheriff = false,
    FakeKorblox = false, FakeHeadless = false,

    -- Misc
    AntiAFK = true, Watermark = true,
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

-- ============ ПАЛИТРА (светлая, KITI) ============
local COLORS = {
    bg = Color3.fromRGB(245, 245, 250),
    panel = Color3.fromRGB(255, 255, 255),
    card = Color3.fromRGB(248, 248, 252),
    text = Color3.fromRGB(40, 40, 60),
    textDim = Color3.fromRGB(130, 130, 150),
    accent = Color3.fromRGB(200, 130, 255),
    accentDark = Color3.fromRGB(150, 80, 220),
    border = Color3.fromRGB(230, 230, 240),
    toggleOff = Color3.fromRGB(200, 200, 210),
    toggleOn = Color3.fromRGB(200, 130, 255),
}

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DeepsikHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui
getgenv().DeepsikGui = ScreenGui

-- ============ WATERMARK (перетаскиваемый) ============
local Watermark = Instance.new("TextButton")
Watermark.Size = UDim2.new(0, 260, 0, 36)
Watermark.Position = UDim2.new(0, 20, 1, -56)
Watermark.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Watermark.BackgroundTransparency = 0.05
Watermark.BorderSizePixel = 0
Watermark.Text = ""
Watermark.Active = true
Watermark.Draggable = true
Watermark.ZIndex = 20
Watermark.Parent = ScreenGui

local WMCorner = Instance.new("UICorner")
WMCorner.CornerRadius = UDim.new(1, 0)
WMCorner.Parent = Watermark

local WMStroke = Instance.new("UIStroke")
WMStroke.Color = Color3.fromRGB(220, 220, 235)
WMStroke.Thickness = 1
WMStroke.Parent = Watermark

local WMLabel = Instance.new("TextLabel")
WMLabel.Size = UDim2.new(1, -20, 1, 0)
WMLabel.Position = UDim2.new(0, 10, 0, 0)
WMLabel.BackgroundTransparency = 1
WMLabel.Text = "📶 -- fps  📡 -- ms  🔫 DEEPSIK"
WMLabel.TextColor3 = COLORS.text
WMLabel.TextSize = 11
WMLabel.Font = Enum.Font.GothamBold
WMLabel.TextXAlignment = Enum.TextXAlignment.Left
WMLabel.ZIndex = 21
WMLabel.Parent = Watermark

-- Обновление watermark
task.spawn(function()
    local lastTick = tick()
    local frames = 0
    local fps = 0
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTick >= 1 then
            fps = frames
            frames = 0
            lastTick = tick()
        end
    end))
    while Watermark.Parent do
        pcall(function()
            if Config.Watermark then
                Watermark.Visible = true
                local ping = math.floor(LP:GetNetworkPing() * 1000)
                WMLabel.Text = string.format("📶 %d fps  📡 %d ms  🔫 DEEPSIK", fps, ping)
            else
                Watermark.Visible = false
            end
        end)
        task.wait(0.5)
    end
end)

-- ============ ГЛАВНОЕ ОКНО ============
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 760, 0, 500)
MainFrame.Position = UDim2.new(0.5, -380, 0.5, -250)
MainFrame.BackgroundColor3 = COLORS.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui
getgenv().DeepsikMainFrame = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.border
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- ===== ВЕРХНЯЯ ПАНЕЛЬ =====
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 58)
TopBar.BackgroundColor3 = COLORS.panel
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local TopMask = Instance.new("Frame")
TopMask.Size = UDim2.new(1, 0, 0, 25)
TopMask.Position = UDim2.new(0, 0, 1, -25)
TopMask.BackgroundColor3 = COLORS.panel
TopMask.BorderSizePixel = 0
TopMask.ZIndex = 3
TopMask.Parent = TopBar

local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 52, 0, 52)
Logo.Position = UDim2.new(0, 15, 0, 3)
Logo.BackgroundTransparency = 1
Logo.Text = "💀"
Logo.TextSize = 34
Logo.Font = Enum.Font.GothamBold
Logo.ZIndex = 4
Logo.Parent = TopBar

local BrandName = Instance.new("TextLabel")
BrandName.Size = UDim2.new(0, 250, 0, 30)
BrandName.Position = UDim2.new(0, 70, 0, 8)
BrandName.BackgroundTransparency = 1
BrandName.Text = "DEEPSIK"
BrandName.TextColor3 = COLORS.text
BrandName.TextSize = 21
BrandName.Font = Enum.Font.GothamBold
BrandName.TextXAlignment = Enum.TextXAlignment.Left
BrandName.ZIndex = 4
BrandName.Parent = TopBar

local SubBrand = UNKNOWN -- placeholder

-- Исправляем (нельзя создавать до этого)
local SubBrand = Instance.new("TextLabel")
SubBrand.Size = UDim2.new(0, 250, 0, 18)
SubBrand.Position = UDim2.new(0, 70, 0, 32)
SubBrand.BackgroundTransparency = 1
SubBrand.Text = "v6.0 • KITI Edition"
SubBrand.TextColor3 = COLORS.textDim
SubBrand.TextSize = 11
SubBrand.Font = Enum.Font.Gotham
SubBrand.TextXAlignment = Enum.TextXAlignment.Left
SubBrand.ZIndex = 4
SubBrand.Parent = TopBar

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -30, 0, 1)
Divider.Position = UDim2.new(0, 15, 1, -1)
Divider.BackgroundColor3 = COLORS.border
Divider.BorderSizePixel = 0
Divider.ZIndex = 4
Divider.Parent = TopBar

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 13)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 245, 245)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(220, 80, 80)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 4
CloseBtn.Parent = TopBar

local CloseC = Instance.new("UICorner")
CloseC.CornerRadius = UDim.new(0, 8)
CloseC.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(255, 220, 220)
    }):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(255, 245, 245)
    }):Play()
end)

-- ===== АВАТАР ИГРОКА (в углу) =====
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 90, 0, 90)
AvatarFrame.Position = UDim2.new(1, -105, 0, 70)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(240, 235, 255)
AvatarFrame.BorderSizePixel = 0
AvatarFrame.ZIndex = 4
AvatarFrame.Parent = MainFrame

local AvatarCorner = Instance.new("UICorner")
AvatarCorner.CornerRadius = UDim.new(0, 12)
AvatarCorner.Parent = AvatarFrame

local AvatarStroke = Instance.new("UIStroke")
AvatarStroke.Color = COLORS.accent
AvatarStroke.Thickness = 2
AvatarStroke.Parent = AvatarFrame

local AvatarImage = Instance.new("ImageLabel")
AvatarImage.Size = UDim2.new(1, -8, 1, -8)
AvatarImage.Position = UDim2.new(0, 4, 0, 4)
AvatarImage.BackgroundTransparency = 1
AvatarImage.Image = ""
AvatarImage.ZIndex = 5
AvatarImage.Parent = AvatarFrame

local AvatarImageCorner = Instance.new("UICorner")
AvatarImageCorner.CornerRadius = UDim.new(0, 10)
AvatarImageCorner.Parent = AvatarImage

-- Загрузка аватара
task.spawn(function()
    pcall(function()
        local thumb = Players:GetUserThumbnailAsync(
            LP.UserId,
            Enum.ThumbnailType.HeadShot,
            Enum.ThumbnailSize.Size150x150
        )
        AvatarImage.Image = thumb
    end)
end)

-- ===== САЙДБАР =====
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 155, 1, -88)
SideBar.Position = UDim2.new(0, 15, 0, 72)
SideBar.BackgroundColor3 = COLORS.panel
SideBar.BorderSizePixel = 0
SideBar.ZIndex = 3
SideBar.Parent = MainFrame

local SideC = Instance.new("UICorner")
SideC.CornerRadius = UDim.new(0, 10)
SideC.Parent = SideBar

local SideStroke = Instance.new("UIStroke")
SideStroke.Color = COLORS.border
SideStroke.Thickness = 1
SideStroke.Parent = SideBar

local SideScroll = Instance.new("ScrollingFrame")
SideScroll.Size = UDim2.new(1, -10, 1, -10)
SideScroll.Position = UDim2.new(0, 5, 0, 5)
SideScroll.BackgroundTransparency = 1
SideScroll.BorderSizePixel = 0
SideScroll.ScrollBarThickness = 2
SideScroll.ScrollBarImageColor3 = COLORS.accent
SideScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SideScroll.ZIndex = 4
SideScroll.Parent = SideBar

local SideLayout = Instance.new("UIListLayout")
SideLayout.Padding = UDim.new(0, 4)
SideLayout.SortOrder = Enum.SortOrder.LayoutOrder
SideLayout.Parent = SideScroll
SideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SideScroll.CanvasSize = UDim2.new(0, 0, 0, SideLayout.AbsoluteContentSize.Y + 10)
end)

-- ===== ПОДКАТЕГОРИИ =====
local SubTabBar = Instance.new("Frame")
SubTabBar.Size = UDim2.new(1, -195, 0, 40)
SubTabBar.Position = UDim2.new(0, 180, 0, 72)
SubTabBar.BackgroundColor3 = COLORS.panel
SubTabBar.BorderSizePixel = 0
SubTabBar.ZIndex = 3
SubTabBar.Parent = MainFrame

local SubTabC = Instance.new("UICorner")
SubTabC.CornerRadius = UDim.new(0, 10)
SubTabC.Parent = SubTabBar

local SubTabScroll = Instance.new("ScrollingFrame")
SubTabScroll.Size = UDim2.new(1, -10, 1, 0)
SubTabScroll.Position = UDim2.new(0, 5, 0, 0)
SubTabScroll.BackgroundTransparency = 1
SubTabScroll.BorderSizePixel = 0
SubTabScroll.ScrollBarThickness = 2
SubTabScroll.ScrollBarImageColor3 = COLORS.accent
SubTabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
SubTabScroll.ScrollingDirection = Enum.ScrollingDirection.X
SubTabScroll.ZIndex = 4
SubTabScroll.Parent = SubTabBar

local SubTabLayout = Instance.new("UIListLayout")
SubTabLayout.FillDirection = Enum.FillDirection.Horizontal
SubTabLayout.Padding = UDim.new(0, 6)
SubTabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
SubTabLayout.SortOrder = Enum.SortOrder.LayoutOrder
SubTabLayout.Parent = SubTabScroll
SubTabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    SubTabScroll.CanvasSize = UDim2.new(0, SubTabLayout.AbsoluteContentSize.X + 10, 0, 0)
end)

-- ===== КОНТЕНТ =====
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -195, 1, -145)
ContentFrame.Position = UDim2.new(0, 180, 0, 120)
ContentFrame.BackgroundColor3 = COLORS.panel
ContentFrame.BorderSizePixel = 0
ContentFrame.ClipsDescendants = true
ContentFrame.ZIndex = 3
ContentFrame.Parent = MainFrame

local ContentC = Instance.new("UICorner")
ContentC.CornerRadius = UDim.new(0, 10)
ContentC.Parent = ContentFrame

local ContentStroke = Instance.new("UIStroke")
ContentStroke.Color = COLORS.border
ContentStroke.Thickness = 1
ContentStroke.Parent = ContentFrame

-- ===== ФОНОВАЯ КАРТИНКА =====
local BgImage = Instance.new("ImageLabel")
BgImage.Size = UDim2.new(1, -20, 1, -20)
BgImage.Position = UDim2.new(0, 10, 0, 10)
BgImage.BackgroundTransparency = 1
BgImage.Image = "" -- сюда грузится ID
BgImage.ImageTransparency = 0.75
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ZIndex = 2
BgImage.Parent = MainFrame

local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 14)
BgCorner.Parent = BgImage

-- Обновление фона
getgenv().DeepsikSetBg = function(assetId)
    pcall(function()
        if assetId and assetId ~= "" then
            BgImage.Image = assetId
            BgImage.Visible = true
        else
            BgImage.Visible = false
        end
    end)
end

-- ===== ПЛАВАЮЩАЯ КНОПКА =====
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 130, 0, 44)
ToggleBtn.Position = UDim2.new(0.5, -65, 1, -72)
ToggleBtn.BackgroundColor3 = COLORS.accent
ToggleBtn.Text = "💀 DEEPSIK"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.TextSize = 14
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.Visible = false
ToggleBtn.Active = true
ToggleBtn.Draggable = true
ToggleBtn.ZIndex = 10
ToggleBtn.Parent = ScreenGui
local ToggleC = Instance.new("UICorner")
ToggleC.CornerRadius = UDim.new(0, 10)
ToggleC.Parent = ToggleBtn

-- ============ СОХРАНЕНИЕ ССЫЛОК ============
getgenv().DeepsikRefs = {
    ScreenGui = ScreenGui, MainFrame = MainFrame,
    TopBar = TopBar, SideBar = SideBar, SideScroll = SideScroll,
    SubTabBar = SubTabBar, SubTabScroll = SubTabScroll,
    ContentFrame = ContentFrame, BgImage = BgImage,
    AvatarFrame = AvatarFrame, AvatarImage = AvatarImage,
    CloseBtn = CloseBtn, ToggleBtn = ToggleBtn,
    Watermark = Watermark, WMLabel = WMLabel,
    Colors = COLORS,
    TweenService = TweenService, Players = Players, RunService = RunService,
    UserInputService = UserInputService, Lighting = Lighting, Workspace = Workspace,
    TeleportService = TeleportService, StarterGui = StarterGui,
    HttpService = HttpService, VirtualUser = VirtualUser, SoundService = SoundService,
    LocalPlayer = LP, Camera = Camera, Config = Config, Notify = Notify,
}

print("✅ [Deepsik v6.0] Часть 1/6 — Ядро + GUI (KITI style)")
Notify("⏳ Загрузка 1/6...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0                    ║
    ║      ЧАСТЬ 2A: Базовые компоненты        ║
    ║      (Category, SubTab, Page, Section,   ║
    ║       Card, Toggle, Slider)              ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
if not R then warn("❌ Запусти Часть 1!") return end

local TweenService = R.TweenService
local UserInputService = R.UserInputService
local SideScroll = R.SideScroll
local SubTabScroll = R.SubTabScroll
local COLORS = R.Colors

-- ============ КАТЕГОРИЯ (сайдбар) ============
local function CreateCategory(name, icon)
    local Cat = Instance.new("TextButton")
    Cat.Size = UDim2.new(1, -8, 0, 36)
    Cat.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Cat.Text = "  " .. icon .. "   " .. name
    Cat.TextColor3 = COLORS.text
    Cat.TextSize = 13
    Cat.Font = Enum.Font.GothamMedium
    Cat.TextXAlignment = Enum.TextXAlignment.Left
    Cat.AutoButtonColor = false
    Cat.ZIndex = 5
    Cat.Parent = SideScroll
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Cat

    Cat.MouseEnter:Connect(function()
        if Cat.BackgroundColor3 ~= COLORS.accent then
            TweenService:Create(Cat, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(245, 240, 255)
            }):Play()
        end
    end)
    Cat.MouseLeave:Connect(function()
        if Cat.BackgroundColor3 ~= COLORS.accent then
            TweenService:Create(Cat, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
        end
    end)
    return Cat
end

-- ============ ПОДКАТЕГОРИЯ ============
local function CreateSubTab(name, icon)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(0, 120, 0, 28)
    Tab.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    Tab.Text = (icon and (icon .. " ") or "") .. name
    Tab.TextColor3 = COLORS.text
    Tab.TextSize = 12
    Tab.Font = Enum.Font.GothamMedium
    Tab.AutoButtonColor = false
    Tab.ZIndex = 5
    Tab.Parent = SubTabScroll
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Tab
    return Tab
end

-- ============ СТРАНИЦА ============
local function CreatePage(parent)
    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = COLORS.accent
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = false
    Page.ZIndex = 4
    Page.Parent = parent
    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 8)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = Page
    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, L.AbsoluteContentSize.Y + 10)
    end)
    return Page
end

-- ============ СЕКЦИЯ ============
local function CreateSection(parent, text)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 32)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 5
    Frame.Parent = parent

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 3, 0, 20)
    Bar.Position = UDim2.new(0, 6, 0.5, -10)
    Bar.BackgroundColor3 = COLORS.accent
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 6
    Bar.Parent = Frame
    local BarC = Instance.new("UICorner")
    BarC.CornerRadius = UDim.new(1, 0)
    BarC.Parent = Bar

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 1, 0)
    Label.Position = UDim2.new(0, 20, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.text
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    return Frame
end

-- ============ КАРТОЧКА (KITI-style) ============
local function CreateCard(parent, text, opts)
    opts = opts or {}
    local hasColor = opts.hasColor
    local hasSettings = opts.hasSettings
    local hasToggle = opts.hasToggle ~= false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 44)
    Frame.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = COLORS.border
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -160, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local rightOffset = -14

    -- Тумблер
    if hasToggle then
        local ToggleBg = Instance.new("Frame")
        ToggleBg.Size = UDim2.new(0, 38, 0, 20)
        ToggleBg.Position = UDim2.new(1, rightOffset - 38, 0.5, -10)
        ToggleBg.BackgroundColor3 = opts.default and COLORS.toggleOn or COLORS.toggleOff
        ToggleBg.BorderSizePixel = 0
        ToggleBg.ZIndex = 6
        ToggleBg.Parent = Frame
        local TC = Instance.new("UICorner")
        TC.CornerRadius = UDim.new(1, 0)
        TC.Parent = ToggleBg

        local ToggleInd = Instance.new("Frame")
        ToggleInd.Size = UDim2.new(0, 16, 0, 16)
        ToggleInd.Position = opts.default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        ToggleInd.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ToggleInd.BorderSizePixel = 0
        ToggleInd.ZIndex = 7
        ToggleInd.Parent = ToggleBg
        local IC = Instance.new("UICorner")
        IC.CornerRadius = UDim.new(1, 0)
        IC.Parent = ToggleInd

        local ClickBtn = Instance.new("TextButton")
        ClickBtn.Size = UDim2.new(0, 38, 0, 20)
        ClickBtn.Position = UDim2.new(1, rightOffset - 38, 0.5, -10)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 8
        ClickBtn.Parent = Frame

        local state = opts.default or false
        ClickBtn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(ToggleBg, TweenInfo.new(0.2), {
                BackgroundColor3 = state and COLORS.toggleOn or COLORS.toggleOff
            }):Play()
            TweenService:Create(ToggleInd, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
            if opts.callback then pcall(opts.callback, state) end
        end)
        rightOffset = rightOffset - 50
    end

    -- Шестерёнка
    if hasSettings then
        local SettingsBtn = Instance.new("TextButton")
        SettingsBtn.Size = UDim2.new(0, 26, 0, 26)
        SettingsBtn.Position = UDim2.new(1, rightOffset - 26, 0.5, -13)
        SettingsBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 248)
        SettingsBtn.Text = "⚙"
        SettingsBtn.TextColor3 = COLORS.textDim
        SettingsBtn.TextSize = 14
        SettingsBtn.Font = Enum.Font.Gotham
        SettingsBtn.ZIndex = 6
        SettingsBtn.Parent = Frame
        local SC = Instance.new("UICorner")
        SC.CornerRadius = UDim.new(0, 6)
        SC.Parent = SettingsBtn

        SettingsBtn.MouseButton1Click:Connect(function()
            if opts.onSettings then pcall(opts.onSettings) end
        end)
        rightOffset = rightOffset - 34
    end

    -- Цвет
    if hasColor then
        local ColorBox = Instance.new("TextButton")
        ColorBox.Size = UDim2.new(0, 34, 0, 22)
        ColorBox.Position = UDim2.new(1, rightOffset - 34, 0.5, -11)
        ColorBox.BackgroundColor3 = opts.color or COLORS.accent
        ColorBox.Text = ""
        ColorBox.ZIndex = 6
        ColorBox.Parent = Frame
        local CC = Instance.new("UICorner")
        CC.CornerRadius = UDim.new(0, 6)
        CC.Parent = ColorBox

        ColorBox.MouseButton1Click:Connect(function()
            if opts.onColor then pcall(opts.onColor, ColorBox) end
        end)
    end

    return Frame
end

-- ============ ТУМБЛЕР ============
local function CreateToggle(parent, text, default, callback)
    return CreateCard(parent, text, {
        hasToggle = true,
        default = default,
        callback = callback,
    })
end

-- ============ СЛАЙДЕР ============
local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 54)
    Frame.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = COLORS.border
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -60, 0, 20)
    Label.Position = UDim2.new(0, 14, 0, 6)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local ValueL = Instance.new("TextLabel")
    ValueL.Size = UDim2.new(0, 50, 0, 20)
    ValueL.Position = UDim2.new(1, -60, 0, 6)
    ValueL.BackgroundTransparency = 1
    ValueL.Text = tostring(default)
    ValueL.TextColor3 = COLORS.accentDark
    ValueL.TextSize = 13
    ValueL.Font = Enum.Font.GothamBold
    ValueL.TextXAlignment = Enum.TextXAlignment.Right
    ValueL.ZIndex = 6
    ValueL.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 8)
    Bar.Position = UDim2.new(0, 14, 0, 36)
    Bar.BackgroundColor3 = Color3.fromRGB(230, 230, 240)
    Bar.BorderSizePixel = 0
    Bar.ZIndex = 6
    Bar.Parent = Frame
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bar

    local Fill = Instance.new("Frame")
    Fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    Fill.BackgroundColor3 = COLORS.accent
    Fill.BorderSizePixel = 0
    Fill.ZIndex = 7
    Fill.Parent = Bar
    local FC = Instance.new("UICorner")
    FC.CornerRadius = UDim.new(1, 0)
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

-- ============ ЭКСПОРТ (часть 1) ============
getgenv().DeepsikUI = getgenv().DeepsikUI or {}
local UI = getgenv().DeepsikUI

UI.CreateCategory = CreateCategory
UI.CreateSubTab = CreateSubTab
UI.CreatePage = CreatePage
UI.CreateSection = CreateSection
UI.CreateCard = CreateCard
UI.CreateToggle = CreateToggle
UI.CreateSlider = CreateSlider

print("✅ [Deepsik v6.0] Часть 2A — Базовые компоненты")
R.Notify("⏳ Загрузка 2A...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0                    ║
    ║      ЧАСТЬ 2B: Доп. компоненты           ║
    ║      (Button, Input, Dropdown,           ║
    ║       ColorPicker)                       ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1 и 2A!") return end

local TweenService = R.TweenService
local UserInputService = R.UserInputService
local COLORS = R.Colors

-- ============ КНОПКА ============
local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 40)
    Btn.BackgroundColor3 = color or COLORS.accent
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.AutoButtonColor = false
    Btn.ZIndex = 5
    Btn.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Btn

    local origColor = color or COLORS.accent
    Btn.MouseEnter:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(
                math.min(255, origColor.R * 255 + 20),
                math.min(255, origColor.G * 255 + 20),
                math.min(255, origColor.B * 255 + 20)
            )
        }):Play()
    end)
    Btn.MouseLeave:Connect(function()
        TweenService:Create(Btn, TweenInfo.new(0.15), {
            BackgroundColor3 = origColor
        }):Play()
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
    return Btn
end

-- ============ ИНПУТ ============
local function CreateInput(parent, placeholder, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
    Frame.BorderSizePixel = 0
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = COLORS.border
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(1, -24, 1, -8)
    Box.Position = UDim2.new(0, 12, 0, 4)
    Box.BackgroundTransparency = 1
    Box.Text = default or ""
    Box.PlaceholderText = placeholder or "Введите..."
    Box.PlaceholderColor3 = COLORS.textDim
    Box.TextColor3 = COLORS.text
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

-- ============ ДРОПДАУН ============
local function CreateDropdown(parent, text, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 44)
    Frame.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = COLORS.border
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, -14, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local Selected = Instance.new("TextButton")
    Selected.Size = UDim2.new(0.5, -14, 0, 30)
    Selected.Position = UDim2.new(0.5, 0, 0, 7)
    Selected.BackgroundColor3 = Color3.fromRGB(240, 240, 248)
    Selected.Text = default or options[1] or "—"
    Selected.TextColor3 = COLORS.text
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
        Frame.Size = open and UDim2.new(1, -10, 0, 44 + #options * 30) or UDim2.new(1, -10, 0, 44)
    end)

    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, -14, 0, 26)
        OptBtn.Position = UDim2.new(0, 7, 0, 44 + (i - 1) * 30)
        OptBtn.BackgroundColor3 = Color3.fromRGB(240, 240, 248)
        OptBtn.Text = opt
        OptBtn.TextColor3 = COLORS.text
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
            Frame.Size = UDim2.new(1, -10, 0, 44)
            if callback then pcall(callback, opt) end
        end)
        table.insert(optionFrames, OptBtn)
    end
    return Frame
end

-- ============ COLOR PICKER ============
local function CreateColorPicker(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 44)
    Frame.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.ZIndex = 5
    Frame.Parent = parent
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Frame

    local Stroke = Instance.new("UIStroke")
    Stroke.Color = COLORS.border
    Stroke.Thickness = 1
    Stroke.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local Preview = Instance.new("TextButton")
    Preview.Size = UDim2.new(0, 48, 0, 26)
    Preview.Position = UDim2.new(1, -60, 0.5, -13)
    Preview.BackgroundColor3 = default
    Preview.Text = ""
    Preview.ZIndex = 6
    Preview.Parent = Frame
    local PC = Instance.new("UICorner")
    PC.CornerRadius = UDim.new(0, 6)
    PC.Parent = Preview

    local state = {R = default.R, G = default.G, B = default.B}
    local open = false

    local Panel = Instance.new("Frame")
    Panel.Size = UDim2.new(1, -14, 0, 130)
    Panel.Position = UDim2.new(0, 7, 0, 44)
    Panel.BackgroundColor3 = Color3.fromRGB(245, 245, 250)
    Panel.BorderSizePixel = 0
    Panel.Visible = false
    Panel.ZIndex = 6
    Panel.Parent = Frame
    local PanC = Instance.new("UICorner")
    PanC.CornerRadius = UDim.new(0, 6)
    PanC.Parent = Panel

    local function makeSlider(label, val, yPos, key)
        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(0, 20, 0, 26)
        Lbl.Position = UDim2.new(0, 8, 0, yPos)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = label
        Lbl.TextColor3 = COLORS.text
        Lbl.TextSize = 12
        Lbl.Font = Enum.Font.GothamBold
        Lbl.ZIndex = 7
        Lbl.Parent = Panel

        local Bar = Instance.new("Frame")
        Bar.Size = UDim2.new(1, -70, 0, 14)
        Bar.Position = UDim2.new(0, 30, 0, yPos + 6)
        Bar.BackgroundColor3 = Color3.fromRGB(220, 220, 230)
        Bar.BorderSizePixel = 0
        Bar.ZIndex = 7
        Bar.Parent = Panel
        local BC = Instance.new("UICorner")
        BC.CornerRadius = UDim.new(1, 0)
        BC.Parent = Bar

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(val, 0, 1, 0)
        Fill.BackgroundColor3 = key == "R" and Color3.fromRGB(255, 80, 80) or (key == "G" and Color3.fromRGB(80, 255, 80) or Color3.fromRGB(80, 80, 255))
        Fill.BorderSizePixel = 0
        Fill.ZIndex = 8
        Fill.Parent = Bar
        local FC = Instance.new("UICorner")
        FC.CornerRadius = UDim.new(1, 0)
        FC.Parent = Fill

        local Val = Instance.new("TextLabel")
        Val.Size = UDim2.new(0, 30, 1, 0)
        Val.Position = UDim2.new(1, -35, 0, 0)
        Val.BackgroundTransparency = 1
        Val.Text = tostring(math.floor(val * 255))
        Val.TextColor3 = COLORS.text
        Val.TextSize = 11
        Val.Font = Enum.Font.GothamBold
        Val.ZIndex = 7
        Val.Parent = Bar

        local drag = false
        Bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = true
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local m = UserInputService:GetMouseLocation()
                local bp = Bar.AbsolutePosition
                local bs = Bar.AbsoluteSize
                local rel = math.clamp((m.X - bp.X) / bs.X, 0, 1)
                Fill.Size = UDim2.new(rel, 0, 1, 0)
                Val.Text = tostring(math.floor(rel * 255))
                state[key] = rel
                local newCol = Color3.fromRGB(state.R * 255, state.G * 255, state.B * 255)
                Preview.BackgroundColor3 = newCol
                if callback then pcall(callback, newCol) end
            end
        end)
    end

    makeSlider("R", default.R, 8, "R")
    makeSlider("G", default.G, 46, "G")
    makeSlider("B", default.B, 84, "B")

    Preview.MouseButton1Click:Connect(function()
        open = not open
        Panel.Visible = open
        Frame.Size = open and UDim2.new(1, -10, 0, 44 + 130) or UDim2.new(1, -10, 0, 44)
    end)

    return Frame
end

-- ============ ЭКСПОРТ (часть 2) ============
UI.CreateButton = CreateButton
UI.CreateInput = CreateInput
UI.CreateDropdown = CreateDropdown
UI.CreateColorPicker = CreateColorPicker

print("✅ [Deepsik v6.0] Часть 2B — Доп. компоненты")
R.Notify("⏳ Загрузка 2B...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0                    ║
    ║      ЧАСТЬ 3/6: Home, General, MM2       ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-2!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local ContentFrame = R.ContentFrame
local SubTabScroll = R.SubTabScroll

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
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local n = tool.Name:lower()
            if n:find("knife") or n:find("dagger") then return "Murder"
            elseif n:find("gun") or n:find("revolver") then return "Sheriff"
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

-- ============ КАТЕГОРИИ (KITI-стиль) ============
local CatHome = UI.CreateCategory("Home", "🏠")
local CatGeneral = UI.CreateCategory("General", "⚙")
local CatMM2 = UI.CreateCategory("MM2", "🔫")
local CatVisuals = UI.CreateCategory("Visuals", "👁")
local CatTarget = UI.CreateCategory("Target", "🎯")
local CatFun = UI.CreateCategory("Fun", "🎉")
local CatEmotes = UI.CreateCategory("Emotes", "💃")
local CatSound = UI.CreateCategory("Sound", "🔊")
local CatConfigs = UI.CreateCategory("Configs", "💾")

local PageHome = UI.CreatePage(ContentFrame)
local PageGeneral = UI.CreatePage(ContentFrame)
local PageMM2 = UI.CreatePage(ContentFrame)
local PageVisuals = UI.CreatePage(ContentFrame)
local PageTarget = UI.CreatePage(ContentFrame)
local PageFun = UI.CreatePage(ContentFrame)
local PageEmotes = UI.CreatePage(ContentFrame)
local PageSound = UI.CreatePage(ContentFrame)
local PageConfigs = UI.CreatePage(ContentFrame)

local categories = {
    {Tab = CatHome, Page = PageHome},
    {Tab = CatGeneral, Page = PageGeneral},
    {Tab = CatMM2, Page = PageMM2},
    {Tab = CatVisuals, Page = PageVisuals},
    {Tab = CatTarget, Page = PageTarget},
    {Tab = CatFun, Page = PageFun},
    {Tab = CatEmotes, Page = PageEmotes},
    {Tab = CatSound, Page = PageSound},
    {Tab = CatConfigs, Page = PageConfigs},
}

local function SwitchCategory(idx)
    for i, c in ipairs(categories) do
        c.Page.Visible = (i == idx)
        c.Tab.BackgroundColor3 = (i == idx) and R.Colors.accent or Color3.fromRGB(255, 255, 255)
        c.Tab.TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or R.Colors.text
    end
end

for i, c in ipairs(categories) do
    c.Tab.MouseButton1Click:Connect(function() SwitchCategory(i) end)
end

R.PageHome = PageHome
R.PageGeneral = PageGeneral
R.PageMM2 = PageMM2
R.PageVisuals = PageVisuals
R.PageTarget = PageTarget
R.PageFun = PageFun
R.PageEmotes = PageEmotes
R.PageSound = PageSound
R.PageConfigs = PageConfigs
R.SwitchCategory = SwitchCategory

-- ==================================================================
-- HOME
-- ==================================================================
UI.CreateSection(PageHome, "👋 Добро пожаловать в Deepsik Hub v6.0")
UI.CreateSection(PageHome, "🎨 Стиль: KITI Edition")

local InfoCard = UI.CreateCard(PageHome, "💙 Made with love for MM2", {
    hasToggle = false,
})
InfoCard.Size = UDim2.new(1, -10, 0, 52)

UI.CreateSection(PageHome, "📊 СТАТИСТИКА")
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, -10, 0, 100)
StatsFrame.BackgroundColor3 = Color3.fromRGB(248, 248, 252)
StatsFrame.BorderSizePixel = 0
StatsFrame.ZIndex = 5
StatsFrame.Parent = PageHome
local StC = Instance.new("UICorner")
StC.CornerRadius = UDim.new(0, 8)
StC.Parent = StatsFrame
local StSt = Instance.new("UIStroke")
StSt.Color = R.Colors.border
StSt.Thickness = 1
StSt.Parent = StatsFrame
local StLabel = Instance.new("TextLabel")
StLabel.Size = UDim2.new(1, -20, 1, -16)
StLabel.Position = UDim2.new(0, 12, 0, 8)
StLabel.BackgroundTransparency = 1
StLabel.Text = "Загрузка..."
StLabel.TextColor3 = R.Colors.text
StLabel.TextSize = 12
StLabel.Font = Enum.Font.GothamMedium
StLabel.TextXAlignment = Enum.TextXAlignment.Left
StLabel.TextYAlignment = Enum.TextYAlignment.Top
StLabel.ZIndex = 6
StLabel.Parent = StatsFrame

task.spawn(function()
    while StLabel.Parent do
        pcall(function()
            StLabel.Text = string.format(
                "👥 Игроков: %d\n📡 Ping: %d ms\n🎭 Роль: %s\n💙 Deepsik Hub v6.0 (KITI)",
                #Players:GetPlayers(),
                math.floor(LP:GetNetworkPing() * 1000),
                GetRole(LP)
            )
        end)
        task.wait(1)
    end
end)

UI.CreateSection(PageHome, "⌨ ХОТКЕИ")
UI.CreateSection(PageHome, "RightShift / F1 — открыть меню")
UI.CreateSection(PageHome, "Delete — выгрузить")
UI.CreateSection(PageHome, "G — Invis Bind")

-- ==================================================================
-- GENERAL
-- ==================================================================
UI.CreateSection(PageGeneral, "⚙ ОБЩИЕ")

UI.CreateToggle(PageGeneral, "Anti-AFK", Config.AntiAFK, function(s) Config.AntiAFK = s end)
UI.CreateToggle(PageGeneral, "Watermark (FPS/Ping)", Config.Watermark, function(s)
    Config.Watermark = s
end)

UI.CreateSection(PageGeneral, "🎨 ТЕМА")
UI.CreateDropdown(PageGeneral, "Стиль UI", {"Light (KITI)", "Dark", "Auto"}, "Light (KITI)", function(v)
    R.Notify("🎨 Стиль: " .. v, 2)
end)

-- ==================================================================
-- MM2 (главные функции)
-- ==================================================================
UI.CreateSection(PageMM2, "🔫 AUTO")

UI.CreateToggle(PageMM2, "Auto Pickup Gun", Config.AutoPickupGun, function(s) Config.AutoPickupGun = s end)
UI.CreateToggle(PageMM2, "Silent Aim", Config.SilentAim, function(s) Config.SilentAim = s end)
UI.CreateSlider(PageMM2, "Silent Aim FOV", 10, 500, Config.SilentAimFOV, function(v) Config.SilentAimFOV = v end)
UI.CreateToggle(PageMM2, "Wall Check (только через стены)", Config.WallCheck, function(s) Config.WallCheck = s end)

UI.CreateSection(PageMM2, "🎭 MM2 SPECIAL")
UI.CreateToggle(PageMM2, "Reveal Roles (показать роли)", Config.RevealRoles, function(s)
    Config.RevealRoles = s
    if s then
        local roles = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            table.insert(roles, plr.Name .. ": " .. GetRole(plr))
        end
        R.Notify("🎭 Роли: " .. table.concat(roles, " | "), 5)
    end
end)
UI.CreateToggle(PageMM2, "Auto Win (авто-победа)", Config.AutoWin, function(s) Config.AutoWin = s end)
UI.CreateToggle(PageMM2, "Second Chance (вторая жизнь)", Config.SecondChance, function(s) Config.SecondChance = s end)
UI.CreateToggle(PageMM2, "Auto Farm Coins", Config.AutoFarmCoins, function(s) Config.AutoFarmCoins = s end)

UI.CreateSection(PageMM2, "⚡ SPEED")
UI.CreateToggle(PageMM2, "Speed Hack", Config.SpeedHack, function(s)
    Config.SpeedHack = s
    local _, _, hum = GetChar()
    if hum then hum.WalkSpeed = s and Config.SpeedValue or 16 end
end)
UI.CreateSlider(PageMM2, "Скорость", 16, 250, Config.SpeedValue, function(v)
    Config.SpeedValue = v
    local _, _, hum = GetChar()
    if hum and Config.SpeedHack then hum.WalkSpeed = v end
end)

UI.CreateSection(PageMM2, "🕊️ MOVEMENT")
UI.CreateToggle(PageMM2, "Noclip", Config.Noclip, function(s) Config.Noclip = s end)
UI.CreateToggle(PageMM2, "Infinite Jump", Config.InfiniteJump, function(s) Config.InfiniteJump = s end)
UI.CreateToggle(PageMM2, "Fly", Config.Fly, function(s)
    Config.Fly = s
    if s and getgenv().DeepsikStartFly then getgenv().DeepsikStartFly()
    elseif getgenv().DeepsikStopFly then getgenv().DeepsikStopFly() end
end)
UI.CreateSlider(PageMM2, "Скорость полёта", 10, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end)
UI.CreateToggle(PageMM2, "Spin", Config.Spin, function(s) Config.Spin = s end)
UI.CreateSlider(PageMM2, "Скорость Spin", 1, 60, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)
UI.CreateToggle(PageMM2, "Bhop", Config.Bhop, function(s) Config.Bhop = s end)
UI.CreateToggle(PageMM2, "Invis", Config.Invis, function(s) Config.Invis = s end)
UI.CreateToggle(PageMM2, "Invis Bind (G)", Config.InvisBind, function(s) Config.InvisBind = s end)
UI.CreateToggle(PageMM2, "Click TP", Config.ClickTP, function(s) Config.ClickTP = s end)

print("✅ [Deepsik v6.0] Часть 3/6 — Home, General, MM2")
R.Notify("⏳ Загрузка 3/6...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0                    ║
    ║      ЧАСТЬ 4/6: Visuals + Target         ║
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
local TweenService = R.TweenService
local ContentFrame = R.ContentFrame
local PageVisuals = R.PageVisuals
local PageTarget = R.PageTarget

local GetChar = getgenv().DeepsikGetChar
local GetTargets = getgenv().DeepsikGetTargets
local GetRole = getgenv().DeepsikGetRole
local GetEquippedTool = getgenv().DeepsikGetTool

-- ==================================================================
-- VISUALS (главная фишка скрина)
-- ==================================================================
UI.CreateSection(PageVisuals, "🔫 GUN MODEL")
UI.CreateDropdown(PageVisuals, "Select Model", {
    "BigUSP-S", "BigKnife", "BigRevolver", "Sword", "Raygun", "Golden Gun", "Candy Cane", "Nerf Gun"
}, Config.GunModelType, function(v)
    Config.GunModelType = v
end)
UI.CreateToggle(PageVisuals, "Gun Model", Config.GunModel, function(s)
    Config.GunModel = s
end)

UI.CreateSection(PageVisuals, "✨ GUN BEAM")
UI.CreateDropdown(PageVisuals, "Beam Type", {"Default", "Rainbow", "Neon", "Fire", "Ice"}, "Default", function(v)
    Config.GunBeamType = v
end)
UI.CreateColorPicker(PageVisuals, "Beam Color", Config.GunBeamColor, function(c)
    Config.GunBeamColor = c
end)
UI.CreateToggle(PageVisuals, "Gun Beam (лазер)", Config.GunBeam, function(s)
    Config.GunBeam = s
end)

UI.CreateSection(PageVisuals, "👤 AVATAR (KITI)")
UI.CreateCard(PageVisuals, "Skeleton ESP", {
    hasColor = true,
    color = Color3.fromRGB(200, 130, 255),
    hasToggle = true,
    hasSettings = true,
    default = Config.SkeletonESP,
    callback = function(s) Config.SkeletonESP = s end,
    onSettings = function() R.Notify("⚙ Skeleton ESP", 2) end,
})
UI.CreateCard(PageVisuals, "China Hat", {
    hasColor = true,
    color = Config.ChinaHatColor,
    hasToggle = true,
    hasSettings = true,
    default = Config.ChinaHat,
    callback = function(s) Config.ChinaHat = s end,
    onSettings = function() R.Notify("⚙ China Hat", 2) end,
})
UI.CreateCard(PageVisuals, "Jump Circle", {
    hasColor = true,
    color = Color3.fromRGB(100, 200, 255),
    hasToggle = true,
    hasSettings = true,
    default = Config.JumpCircle,
    callback = function(s) Config.JumpCircle = s end,
    onSettings = function() R.Notify("⚙ Jump Circle", 2) end,
})
UI.CreateToggle(PageVisuals, "Big Head", Config.BigHead, function(s)
    Config.BigHead = s
    if LP.Character then
        local head = LP.Character:FindFirstChild("Head")
        if head then
            local mesh = head:FindFirstChildOfClass("SpecialMesh")
            if mesh then mesh.Scale = s and Vector3.new(2, 2, 2) or Vector3.new(1.25, 1.25, 1.25) end
        end
    end
end)
UI.CreateToggle(PageVisuals, "Fullbright", Config.Fullbright, function(s)
    Config.Fullbright = s
    if s then
        R.Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        R.Lighting.Brightness = 3
        R.Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        R.Lighting.Ambient = Color3.fromRGB(70, 70, 70)
        R.Lighting.Brightness = 2
        R.Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end
end)

UI.CreateSection(PageVisuals, "👁️ ESP")
UI.CreateToggle(PageVisuals, "ESP игроков", Config.ESP, function(s) Config.ESP = s end)
UI.CreateToggle(PageVisuals, "Role ESP", Config.RoleESP, function(s) Config.RoleESP = s end)
UI.CreateToggle(PageVisuals, "Gun ESP", Config.GunESP, function(s) Config.GunESP = s end)
UI.CreateToggle(PageVisuals, "Tracers", Config.Tracers, function(s) Config.Tracers = s end)
UI.CreateToggle(PageVisuals, "Hitbox Expander", Config.HitboxExpander, function(s) Config.HitboxExpander = s end)
UI.CreateSlider(PageVisuals, "Hitbox Size", 2, 20, Config.HitboxSize, function(v) Config.HitboxSize = v end)

-- ============ ЛОГИКА: CHINA HAT ============
local chinaHats = {}
local function UpdateChinaHats()
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local head = plr.Character:FindFirstChild("Head")
            if head then
                if Config.ChinaHat then
                    if not chinaHats[plr] or not chinaHats[plr].Parent then
                        local hat = Instance.new("Part")
                        hat.Name = "DeepsikChinaHat"
                        hat.Size = Vector3.new(3, 0.3, 3)
                        hat.Shape = Enum.PartType.Cylinder
                        hat.CFrame = head.CFrame * CFrame.new(0, 1.5, 0) * CFrame.Angles(0, 0, math.rad(90))
                        hat.Anchored = false
                        hat.CanCollide = false
                        hat.Massless = true
                        hat.Color = Config.ChinaHatColor
                        hat.Material = Enum.Material.Neon
                        hat.Parent = head
                        local weld = Instance.new("WeldConstraint")
                        weld.Part0 = hat
                        weld.Part1 = head
                        weld.Parent = hat
                        chinaHats[plr] = hat
                    end
                    if chinaHats[plr] then chinaHats[plr].Color = Config.ChinaHatColor end
                else
                    if chinaHats[plr] then
                        pcall(function() chinaHats[plr]:Destroy() end)
                        chinaHats[plr] = nil
                    end
                end
            end
        end
    end
end

table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if tick() % 0.5 < 0.02 then pcall(UpdateChinaHats) end
end))

-- ============ ЛОГИКА: JUMP CIRCLE ============
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.JumpCircle then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr.Character then
            local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hum and hrp and hum:GetState() == Enum.HumanoidStateType.Jumping then
                local circle = Instance.new("Part")
                circle.Shape = Enum.PartType.Cylinder
                circle.Size = Vector3.new(0.2, 5, 5)
                circle.CFrame = CFrame.new(hrp.Position - Vector3.new(0, 3, 0)) * CFrame.Angles(0, 0, math.rad(90))
                circle.Anchored = true
                circle.CanCollide = false
                circle.Material = Enum.Material.Neon
                circle.Color = Color3.fromRGB(100, 200, 255)
                circle.Transparency = 0.4
                circle.Parent = Workspace
                TweenService:Create(circle, TweenInfo.new(0.6), {
                    Transparency = 1, Size = Vector3.new(0.2, 15, 15)
                }):Play()
                task.delay(0.7, function() pcall(function() circle:Destroy() end) end)
            end
        end
    end
end))

-- ============ ЛОГИКА: GUN BEAM ============
local beamFolder = Workspace:FindFirstChild("DeepsikBeams")
if not beamFolder then
    beamFolder = Instance.new("Folder")
    beamFolder.Name = "DeepsikBeams"
    beamFolder.Parent = Workspace
end

local function CreateBeam(fromPos, toPos)
    local dist = (toPos - fromPos).Magnitude
    if dist < 1 then return end
    local part = Instance.new("Part")
    part.Size = Vector3.new(0.15, 0.15, dist)
    part.CFrame = CFrame.new(fromPos, toPos) * CFrame.new(0, 0, -dist / 2)
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Config.GunBeamColor
    part.Transparency = 0.15
    part.Parent = beamFolder
    TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1}):Play()
    task.delay(0.6, function() pcall(function() part:Destroy() end) end)
end

local function HookTools(char)
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(getgenv().DeepsikConns, tool.Activated:Connect(function()
                if not Config.GunBeam then return end
                local handle = tool:FindFirstChild("Handle")
                if not handle then return end
                local mouse = UserInputService:GetMouseLocation()
                local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
                CreateBeam(handle.Position, ray.Origin + ray.Direction * 500)
            end))
        end
    end
end

HookTools(LP.Character)
table.insert(getgenv().DeepsikConns, LP.CharacterAdded:Connect(function(c)
    task.wait(0.5)
    HookTools(c)
end))

-- ============ ЛОГИКА: HITBOX EXPANDER ============
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.HitboxExpander then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                    hrp.Massless = true
                end)
            end
        end
    end
end))

-- ==================================================================
-- TARGET
-- ==================================================================
UI.CreateSection(PageTarget, "🎯 ЦЕЛИ")

UI.CreateToggle(PageTarget, "Kill Aura (все)", Config.KillAura, function(s) Config.KillAura = s end)
UI.CreateSlider(PageTarget, "Kill Aura Radius", 5, 100, Config.AuraRange, function(v) Config.AuraRange = v end)
UI.CreateToggle(PageTarget, "Kill Only Sheriff", Config.KillOnlySheriff, function(s) Config.KillOnlySheriff = s end)
UI.CreateToggle(PageTarget, "Aim Assist All", Config.AimAssistAll, function(s) Config.AimAssistAll = s end)
UI.CreateSlider(PageTarget, "Aim Assist FOV", 10, 500, Config.AimAssistAllFOV, function(v) Config.AimAssistAllFOV = v end)

UI.CreateSection(PageTarget, "🔪 KNIFE")
UI.CreateToggle(PageTarget, "Knife Aimbot", Config.KnifeAimbot, function(s) Config.KnifeAimbot = s end)

UI.CreateSection(PageTarget, "📋 ТЕЛЕПОРТ")

local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(playerList, p.Name) end
end
if #playerList == 0 then playerList = {"—"} end

local selectedPlayer = playerList[1]
UI.CreateDropdown(PageTarget, "Выбрать игрока", playerList, selectedPlayer, function(v)
    selectedPlayer = v
end)

UI.CreateButton(PageTarget, "🎯 TP к цели", R.Colors.accent, function()
    local target = Players:FindFirstChild(selectedPlayer)
    local _, hrp = GetChar()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and hrp then
        hrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🎯 К " .. selectedPlayer, 2)
    else
        R.Notify("❌ Не найден", 2)
    end
end)

UI.CreateButton(PageTarget, "🔪 TP к Murder", Color3.fromRGB(220, 80, 80), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
    local _, hrp = GetChar()
    if hrp and #targets > 0 then
        hrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🔪 К Murder", 2)
    else
        R.Notify("❌ Murder не найден (нож в руках)", 2)
    end
end)

UI.CreateButton(PageTarget, "🚔 TP к Sheriff", Color3.fromRGB(80, 130, 220), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Sheriff" end)
    local _, hrp = GetChar()
    if hrp and #targets > 0 then
        hrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🚔 К Sheriff", 2)
    else
        R.Notify("❌ Sheriff не найден (пушка в руках)", 2)
    end
end)

UI.CreateButton(PageTarget, "🏠 TP в Lobby", Color3.fromRGB(100, 180, 100), function()
    local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbySpawn")
    local _, hrp = GetChar()
    if lobby and hrp then
        hrp.CFrame = CFrame.new((lobby.Position or Vector3.new(0, 100, 0)) + Vector3.new(0, 5, 0))
        R.Notify("🏠 В лобби", 2)
    else
        R.Notify("❌ Лобби не найдено", 2)
    end
end)

print("✅ [Deepsik v6.0] Часть 4/6 — Visuals + Target")
R.Notify("⏳ Загрузка 4/6...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0                    ║
    ║      ЧАСТЬ 5A: Fun (Fling + Fake Items)  ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1, 2A, 2B, 3, 4!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera
local PageFun = R.PageFun

local GetChar = getgenv().DeepsikGetChar
local GetTargets = getgenv().DeepsikGetTargets
local GetRole = getgenv().DeepsikGetRole

-- ==================================================================
-- FUN: FLING
-- ==================================================================
UI.CreateSection(PageFun, "😈 FLING")

UI.CreateToggle(PageFun, "Touch Fling", Config.TouchFling, function(s) Config.TouchFling = s end)
UI.CreateToggle(PageFun, "Click Fling", Config.ClickFling, function(s) Config.ClickFling = s end)
UI.CreateToggle(PageFun, "Fling All", Config.FlingAll, function(s) Config.FlingAll = s end)
UI.CreateToggle(PageFun, "Fling Murder", Config.FlingMurder, function(s) Config.FlingMurder = s end)
UI.CreateToggle(PageFun, "Fling Sheriff", Config.FlingSheriff, function(s) Config.FlingSheriff = s end)

-- Fling All
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.FlingAll then return end
    local _, myHrp = GetChar()
    if not myHrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                pcall(function()
                    hrp.Velocity = Vector3.new(500, 500, 500)
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(500, 500, 500)
                    bv.Parent = hrp
                    task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
                end)
            end
        end
    end
end))

-- Fling Murder
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.FlingMurder then return end
    local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
    for _, t in ipairs(targets) do
        pcall(function()
            t.hrp.Velocity = Vector3.new(500, 500, 500)
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(500, 500, 500)
            bv.Parent = t.hrp
            task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
        end)
    end
end))

-- Fling Sheriff
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.FlingSheriff then return end
    local targets = GetTargets(function(p) return GetRole(p) == "Sheriff" end)
    for _, t in ipairs(targets) do
        pcall(function()
            t.hrp.Velocity = Vector3.new(500, 500, 500)
            local bv = Instance.new("BodyVelocity")
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bv.Velocity = Vector3.new(500, 500, 500)
            bv.Parent = t.hrp
            task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
        end)
    end
end))

-- Touch Fling
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.TouchFling then return end
    local _, myHrp = GetChar()
    if not myHrp then return end
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr ~= LP and plr.Character then
            local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
            if hrp and (myHrp.Position - hrp.Position).Magnitude < 8 then
                pcall(function()
                    local bv = Instance.new("BodyVelocity")
                    bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                    bv.Velocity = Vector3.new(500, 800, 500)
                    bv.Parent = hrp
                    task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
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
            if hrp then
                pcall(function()
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

-- ==================================================================
-- FUN: FAKE ITEMS
-- ==================================================================
UI.CreateSection(PageFun, "🎭 FAKE ITEMS")

UI.CreateToggle(PageFun, "Fake Korblox", Config.FakeKorblox, function(s)
    Config.FakeKorblox = s
    if not LP.Character then return end
    for _, name in ipairs({"Right Leg", "RightUpperLeg", "RightLowerLeg", "RightFoot"}) do
        local leg = LP.Character:FindFirstChild(name)
        if leg then pcall(function() leg.Transparency = s and 1 or 0 end) end
    end
end)

UI.CreateToggle(PageFun, "Fake Headless", Config.FakeHeadless, function(s)
    Config.FakeHeadless = s
    if not LP.Character then return end
    local head = LP.Character:FindFirstChild("Head")
    if head then
        pcall(function()
            head.Transparency = s and 1 or 0
            local m = head:FindFirstChildOfClass("SpecialMesh")
            if m then m.Scale = s and Vector3.new(0.01, 0.01, 0.01) or Vector3.new(1.25, 1.25, 1.25) end
        end)
    end
end)

print("✅ [Deepsik v6.0] Часть 5A — Fun (Fling + Fake Items)")
R.Notify("⏳ Загрузка 5A...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0                    ║
    ║      ЧАСТЬ 5B: Emotes + Sound            ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-5A!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local Workspace = R.Workspace
local PageEmotes = R.PageEmotes
local PageSound = R.PageSound

-- ==================================================================
-- EMOTES (все эмоции)
-- ==================================================================
UI.CreateSection(PageEmotes, "💃 АНИМАЦИИ")

local ANIMATIONS = {
    Dance1 = "rbxassetid://507771019",
    Dance2 = "rbxassetid://507776043",
    Dance3 = "rbxassetid://507777268",
    Wave = "rbxassetid://507770239",
    Point = "rbxassetid://507770453",
    Salute = "rbxassetid://507768375",
    Sit = "rbxassetid://2506281703",
    Floss = "rbxassetid://5916837175",
    Dab = "rbxassetid://4831309985",
    Ninja = "rbxassetid://507769333",
    Headless = "rbxassetid://4831375742",
    Zen = "rbxassetid://507770239",
    Zombie = "rbxassetid://507772056",
}

local currentAnimTrack = nil
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
    if not loop then
        task.delay(5, function()
            if currentAnimTrack == track then
                pcall(function() track:Stop() end)
                currentAnimTrack = nil
            end
        end)
    end
end

-- Эмоции (все кнопки)
UI.CreateButton(PageEmotes, "💃 Танец 1", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Dance1, true) end)
UI.CreateButton(PageEmotes, "🕺 Танец 2", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Dance2, true) end)
UI.CreateButton(PageEmotes, "🌀 Танец 3", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Dance3, true) end)
UI.CreateButton(PageEmotes, "👋 Махнуть рукой", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Wave, false) end)
UI.CreateButton(PageEmotes, "👉 Указать", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Point, false) end)
UI.CreateButton(PageEmotes, "🫡 Честь", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Salute, false) end)
UI.CreateButton(PageEmotes, "🪑 Сидеть (Sit)", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Sit, true) end)
UI.CreateButton(PageEmotes, "🕺 Floss", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Floss, true) end)
UI.CreateButton(PageEmotes, "👆 Dab", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Dab, false) end)
UI.CreateButton(PageEmotes, "🥷 Ninja", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Ninja, false) end)
UI.CreateButton(PageEmotes, "💀 Headless", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Headless, true) end)
UI.CreateButton(PageEmotes, "🧘 Zen", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Zen, true) end)
UI.CreateButton(PageEmotes, "🧟 Zombie", R.Colors.accent, function() PlayAnimation(ANIMATIONS.Zombie, true) end)
UI.CreateButton(PageEmotes, "🛑 Остановить анимацию", Color3.fromRGB(220, 80, 80), function()
    if currentAnimTrack then
        pcall(function() currentAnimTrack:Stop() end)
        currentAnimTrack = nil
    end
end)

-- ==================================================================
-- SOUND
-- ==================================================================
UI.CreateSection(PageSound, "🔊 МУЗЫКА")

local musicInstance = nil
local function PlayMusic(id)
    if musicInstance then pcall(function() musicInstance:Destroy() end) end
    musicInstance = Instance.new("Sound")
    musicInstance.SoundId = id
    musicInstance.Volume = 0.5
    musicInstance.Looped = true
    musicInstance.Parent = Workspace
    musicInstance:Play()
    R.Notify("🎵 Играет музыка", 2)
end

UI.CreateButton(PageSound, "🎵 Lofi", R.Colors.accent, function() PlayMusic("rbxassetid://1837879082") end)
UI.CreateButton(PageSound, "🎵 Phonk", R.Colors.accent, function() PlayMusic("rbxassetid://1838457666") end)
UI.CreateButton(PageSound, "🎵 Anime OP", R.Colors.accent, function() PlayMusic("rbxassetid://1836248630") end)
UI.CreateButton(PageSound, "🎵 Piano", R.Colors.accent, function() PlayMusic("rbxassetid://1836197175") end)
UI.CreateButton(PageSound, "🎵 Guitar", R.Colors.accent, function() PlayMusic("rbxassetid://1837876001") end)
UI.CreateButton(PageSound, "🛑 Стоп", Color3.fromRGB(220, 80, 80), function()
    if musicInstance then pcall(function() musicInstance:Destroy() end); musicInstance = nil end
end)

print("✅ [Deepsik v6.0] Часть 5B — Emotes + Sound")
R.Notify("⏳ Загрузка 5B...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0                    ║
    ║      ЧАСТЬ 6A: Configs                   ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-5B!") return end

local Config = R.Config
local LP = R.LocalPlayer
local TeleportService = R.TeleportService
local PageConfigs = R.PageConfigs
local ScreenGui = R.ScreenGui

-- ==================================================================
-- ФОНЫ (выбор из 10)
-- ==================================================================
UI.CreateSection(PageConfigs, "🖼 ФОНЫ (выбор из 10)")

-- Замени ID на свои (rbxassetid://...)
local BACKGROUNDS = {
    {name = "1. Девушка с искрой", id = ""},
    {name = "2. Глаза фиолетовые", id = ""},
    {name = "3. Девушка на закате", id = ""},
    {name = "4. Облака", id = ""},
    {name = "5. Неко-девочка", id = ""},
    {name = "6. Тёмная девушка", id = ""},
    {name = "7. Девушка в разрыве", id = ""},
    {name = "8. Синие глаза", id = ""},
    {name = "9. Девушка в снегу", id = ""},
    {name = "10. Зайка", id = ""},
}

local bgNames = {}
for _, bg in ipairs(BACKGROUNDS) do table.insert(bgNames, bg.name) end

UI.CreateDropdown(PageConfigs, "Выбрать фон", bgNames, BACKGROUNDS[1].name, function(selected)
    for _, bg in ipairs(BACKGROUNDS) do
        if bg.name == selected and bg.id ~= "" then
            R.DeepsikSetBg(bg.id)
            R.Notify("🖼 Фон: " .. selected, 2)
            return
        end
    end
    R.Notify("⚠ Сначала загрузите AssetID (поле ниже)", 3)
end)

UI.CreateInput(PageConfigs, "Вставить AssetID фона (rbxassetid://...)", "", function(text)
    if text ~= "" then
        R.DeepsikSetBg(text)
        R.Notify("🖼 Фон установлен", 2)
    end
end)

UI.CreateButton(PageConfigs, "❌ Убрать фон", Color3.fromRGB(150, 150, 170), function()
    R.DeepsikSetBg("")
end)

UI.CreateSlider(PageConfigs, "Прозрачность фона (0-100)", 0, 100, 25, function(v)
    if R.BgImage then
        R.BgImage.ImageTransparency = v / 100
    end
end)

-- ==================================================================
-- СОХРАНЕНИЕ КОНФИГА
-- ==================================================================
UI.CreateSection(PageConfigs, "💾 СОХРАНЕНИЕ")

local configName = "my_config"
UI.CreateInput(PageConfigs, "Название конфига", configName, function(text)
    configName = text
end)

UI.CreateButton(PageConfigs, "💾 Сохранить конфиг", Color3.fromRGB(80, 180, 100), function()
    pcall(function()
        if isfolder and not isfolder("DeepsikHub") then makefolder("DeepsikHub") end
        if writefile then
            local path = "DeepsikHub/" .. configName .. ".json"
            local data = {}
            for k, v in pairs(Config) do
                if typeof(v) == "Color3" then
                    data[k] = {__color = true, r = v.R, g = v.G, b = v.B}
                else
                    data[k] = v
                end
            end
            writefile(path, R.HttpService:JSONEncode(data))
            R.Notify("💾 Сохранено: " .. configName, 2)
        else
            R.Notify("❌ writefile недоступен", 2)
        end
    end)
end)

UI.CreateButton(PageConfigs, "📥 Загрузить конфиг", R.Colors.accent, function()
    pcall(function()
        local path = "DeepsikHub/" .. configName .. ".json"
        if isfile and isfile(path) then
            local data = R.HttpService:JSONDecode(readfile(path))
            for k, v in pairs(data) do
                if type(v) == "table" and v.__color then
                    Config[k] = Color3.fromRGB(v.r * 255, v.g * 255, v.b * 255)
                else
                    Config[k] = v
                end
            end
            R.Notify("📥 Загружено (перезапусти скрипт)", 3)
        else
            R.Notify("❌ Конфиг не найден", 2)
        end
    end)
end)

UI.CreateToggle(PageConfigs, "Auto Load Config (при старте)", false, function(s)
    Config.AutoLoadConfig = s
end)

UI.CreateButton(PageConfigs, "📂 Список конфигов", Color3.fromRGB(150, 150, 170), function()
    pcall(function()
        if isfolder and isfolder("DeepsikHub") then
            local list = {}
            for _, f in ipairs(listfiles("DeepsikHub")) do
                local n = f:match("([^/\\]+)%.json$")
                if n then table.insert(list, n) end
            end
            if #list == 0 then R.Notify("📂 Пусто", 2)
            else R.Notify("📂 " .. table.concat(list, ", "), 5) end
        else
            R.Notify("📂 Нет конфигов", 2)
        end
    end)
end)

-- ==================================================================
-- ДЕЙСТВИЯ
-- ==================================================================
UI.CreateSection(PageConfigs, "🔧 ДЕЙСТВИЯ")

UI.CreateButton(PageConfigs, "🔄 Rejoin сервер", R.Colors.accent, function()
    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
end)

UI.CreateButton(PageConfigs, "❌ Выгрузить Hub", Color3.fromRGB(220, 80, 80), function()
    if getgenv().DeepsikStopFly then pcall(getgenv().DeepsikStopFly) end
    for _, objs in pairs(getgenv().DeepsikESP or {}) do
        for _, o in pairs(objs) do pcall(function() o:Remove() end) end
    end
    for _, c in pairs(getgenv().DeepsikConns or {}) do pcall(function() c:Disconnect() end) end
    ScreenGui:Destroy()
    getgenv().DeepsikGui = nil
    getgenv().DeepsikRefs = nil
end)

print("✅ [Deepsik v6.0] Часть 6A — Configs")
R.Notify("⏳ Загрузка 6A...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║      DEEPSIK HUB v6.0                    ║
    ║      ЧАСТЬ 6B: ESP + Управление          ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().DeepsikRefs
local UI = getgenv().DeepsikUI
if not R or not UI then warn("❌ Запусти Части 1-6A!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Camera = R.Camera
local TweenService = R.TweenService
local Workspace = R.Workspace
local MainFrame = R.MainFrame
local ScreenGui = R.ScreenGui
local CloseBtn = R.CloseBtn
local ToggleBtn = R.ToggleBtn
local ESPObjects = getgenv().DeepsikESP
local GetRole = getgenv().DeepsikGetRole
local GetChar = getgenv().DeepsikGetChar

-- ==================================================================
-- ESP (рендеринг)
-- ==================================================================
local ROLE_COLORS = {
    Murder = Color3.fromRGB(255, 80, 80),
    Sheriff = Color3.fromRGB(80, 130, 255),
    Innocent = Color3.fromRGB(80, 220, 130),
}

local function CreateESPPlayer(player)
    if getgenv().DeepsikNoDrawing then return end
    if player == LP or ESPObjects[player] then return end
    pcall(function()
        local Box = Drawing.new("Square")
        Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1; Box.Visible = false

        local NameTag = Drawing.new("Text")
        NameTag.Size = 14; NameTag.Center = true; NameTag.Outline = true
        NameTag.Color = Color3.fromRGB(40, 40, 60); NameTag.Visible = false

        local DistanceTag = Drawing.new("Text")
        DistanceTag.Size = 12; DistanceTag.Center = true; DistanceTag.Outline = true
        DistanceTag.Color = Color3.fromRGB(150, 80, 220); DistanceTag.Visible = false

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
        for _, o in pairs(ESPObjects[player]) do pcall(function() o:Remove() end) end
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
            local role = GetRole(player)
            local col = Config.ESPColor
            if Config.RoleESP and role ~= "Innocent" then col = ROLE_COLORS[role] end

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
end

if not getgenv().DeepsikNoDrawing then
    for _, plr in ipairs(Players:GetPlayers()) do CreateESPPlayer(plr) end
    table.insert(getgenv().DeepsikConns, Players.PlayerAdded:Connect(CreateESPPlayer))
    table.insert(getgenv().DeepsikConns, Players.PlayerRemoving:Connect(RemoveESPPlayer))
    table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function()
        pcall(UpdateESP)
    end))
end

-- ==================================================================
-- FLY
-- ==================================================================
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

-- ==================================================================
-- SPIN
-- ==================================================================
local spinAngle = 0
table.insert(getgenv().DeepsikConns, RunService.RenderStepped:Connect(function(dt)
    if not Config.Spin then return end
    local _, hrp = GetChar()
    if not hrp then return end
    spinAngle = spinAngle + Config.SpinSpeed * dt
    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
end))

-- ==================================================================
-- NOCLIP
-- ==================================================================
table.insert(getgenv().DeepsikConns, RunService.Stepped:Connect(function()
    if not Config.Noclip or not LP.Character then return end
    for _, part in ipairs(LP.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end))

-- ==================================================================
-- INFINITE JUMP
-- ==================================================================
table.insert(getgenv().DeepsikConns, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local _, _, hum = GetChar()
        if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end))

-- ==================================================================
-- BHOP
-- ==================================================================
local bhopSpeed = 16
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.Bhop then bhopSpeed = 16; return end
    local _, _, hum = GetChar()
    if not hum then return end
    if hum:GetState() == Enum.HumanoidStateType.Landed then
        bhopSpeed = math.min(bhopSpeed + 1.5, 100)
        hum.WalkSpeed = bhopSpeed
        pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end)
    elseif hum:GetState() == Enum.HumanoidStateType.Running then
        bhopSpeed = math.max(bhopSpeed - 0.5, 16)
        hum.WalkSpeed = bhopSpeed
    end
end))

-- ==================================================================
-- INVIS
-- ==================================================================
table.insert(getgenv().DeepsikConns, RunService.Stepped:Connect(function()
    if not Config.Invis or not LP.Character then return end
    for _, part in ipairs(LP.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function() part.Transparency = 1 end)
        end
    end
end))

-- ==================================================================
-- ANTI-AFK
-- ==================================================================
table.insert(getgenv().DeepsikConns, LP.Idled:Connect(function()
    if not Config.AntiAFK then return end
    pcall(function()
        R.VirtualUser:CaptureController()
        R.VirtualUser:ClickButton2(Vector2.new())
    end)
end))

-- ==================================================================
-- CLICK TP
-- ==================================================================
table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton2 then
        local mouse = UserInputService:GetMouseLocation()
        local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
        local _, hrp = GetChar()
        if hrp then
            pcall(function()
                hrp.CFrame = CFrame.new(ray.Origin + ray.Direction * 50)
            end)
        end
    end
end))

-- ==================================================================
-- INVIS BIND (G)
-- ==================================================================
table.insert(getgenv().DeepsikConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.InvisBind and input.KeyCode == Enum.KeyCode.G then
        Config.Invis = not Config.Invis
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

-- ==================================================================
-- AUTO FARM COINS
-- ==================================================================
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.AutoFarmCoins then return end
    local _, myHrp = GetChar()
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
end))

-- ==================================================================
-- AUTO WIN
-- ==================================================================
table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.AutoWin then return end
    local tool = getgenv().DeepsikGetTool()
    if not tool then return end
    local targets = getgenv().DeepsikGetTargets()
    if #targets == 0 then return end
    local t = targets[1]
    local _, myHrp = GetChar()
    if myHrp then
        pcall(function()
            myHrp.CFrame = t.hrp.CFrame * CFrame.new(0, 0, 2)
            tool:Activate()
        end)
    end
end))

-- ==================================================================
-- SECOND CHANCE
-- ==================================================================
local secondChanceUsed = false
table.insert(getgenv().DeepsikConns, LP.CharacterAdded:Connect(function()
    secondChanceUsed = false
end))

table.insert(getgenv().DeepsikConns, RunService.Heartbeat:Connect(function()
    if not Config.SecondChance then return end
    if not LP.Character then return end
    local hum = LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 and not secondChanceUsed then
        secondChanceUsed = true
        R.Notify("💚 Second Chance активирован!", 3)
        pcall(function()
            hum.Health = hum.MaxHealth
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(0, 100, 0) end
        end)
    end
end))

-- ==================================================================
-- УПРАВЛЕНИЕ ОКНОМ
-- ==================================================================
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleBtn.Visible = false
end)

-- ==================================================================
-- ХОТКЕИ
-- ==================================================================
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
║     🔫 DEEPSIK HUB v6.0 ЗАГРУЖЕН! 🔫     ║
║     ─────────────────────────────        ║
║     Стиль: KITI                           ║
║     RightShift / F1 — меню                ║
║     Delete — выгрузить                    ║
║     G — Invis Bind                        ║
║     RMB — Click TP (если включен)         ║
╚══════════════════════════════════════════╝
]])
R.Notify("✅ Deepsik Hub v6.0 запущен!", 3)
