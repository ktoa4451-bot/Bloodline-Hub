--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 1/8: Ядро + GUI            ║
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

local function Notify(text, dur)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "Bloodline Hub", Text = tostring(text), Duration = dur or 3
        })
    end)
end
getgenv().BloodlineNotify = Notify

-- Ждём LocalPlayer
local _t = tick()
while not Players.LocalPlayer and tick() - _t < 30 do task.wait(0.1) end
if not Players.LocalPlayer then warn("[Bloodline] LocalPlayer не найден") return end
local LP = Players.LocalPlayer

local PlayerGui
_t = tick()
repeat
    task.wait(0.1)
    PlayerGui = LP:FindFirstChild("PlayerGui")
until PlayerGui or tick() - _t > 30
if not PlayerGui then warn("[Bloodline] PlayerGui не найден") return end

local Camera = Workspace.CurrentCamera

-- Проверка Drawing
local HAS_DRAWING = false
pcall(function()
    if Drawing and Drawing.new then
        local t = Drawing.new("Text")
        if t then t:Remove(); HAS_DRAWING = true end
    end
end)
getgenv().BloodlineNoDrawing = (not HAS_DRAWING)
if not HAS_DRAWING then warn("[Bloodline] Drawing недоступен — ESP отключён") end

-- Проверка File API
local HAS_FILE_API = false
pcall(function()
    HAS_FILE_API = (typeof(writefile) == "function" and typeof(readfile) == "function")
end)
getgenv().BloodlineFileAPI = HAS_FILE_API

-- ============ КОНФИГ ============
local DefaultConfig = {
    ESP = false, RoleESP = true, GunESP = false,
    Tracers = false, HitboxExpander = false, HitboxSize = 5,
    ESPColor = Color3.fromRGB(200, 130, 255),
    SkeletonESP = false,
    KillNotifier = false, RoleNotifier = false,
    AutoPickupGun = false,
    SilentAim = false, SilentAimFOV = 100,
    KillAura = false, AuraRange = 30,
    KillOnlySheriff = false,
    KnifeAimbot = false,
    AimAssistAll = false, AimAssistAllFOV = 100,
    RevealRoles = false, AutoWin = false, SecondChance = false, AutoFarmCoins = false,
    Noclip = false, InfiniteJump = false,
    AntiFling = false, AntiRagdoll = false,
    Fly = false, FlySpeed = 50,
    Spin = false, SpinSpeed = 15,
    Bhop = false,
    Invis = false, InvisBind = false,
    SpeedHack = false, SpeedValue = 60,
    ClickTP = false,
    GunModel = false, GunModelType = "BigUSP-S",
    GunBeam = false, GunBeamColor = Color3.fromRGB(200, 130, 255),
    ChinaHat = false, ChinaHatColor = Color3.fromRGB(255, 80, 80),
    JumpCircle = false, BigHead = false, Fullbright = false,
    TouchFling = false, ClickFling = false,
    FlingAll = false, FlingMurder = false, FlingSheriff = false,
    FakeKorblox = false, FakeHeadless = false,
    AntiAFK = true, Watermark = true,
    BackgroundID = "", BackgroundTransparency = 75,
    MusicVolume = 50, LastMusicID = "",
}

getgenv().BloodlineConfig = getgenv().BloodlineConfig or {}
for k, v in pairs(DefaultConfig) do
    if getgenv().BloodlineConfig[k] == nil then
        getgenv().BloodlineConfig[k] = v
    end
end
local Config = getgenv().BloodlineConfig

if getgenv().BloodlineGui then pcall(function() getgenv().BloodlineGui:Destroy() end) end
for _, c in pairs(getgenv().BloodlineConns or {}) do pcall(function() c:Disconnect() end) end
getgenv().BloodlineConns = {}
getgenv().BloodlineESP = getgenv().BloodlineESP or {}

-- ============ КРОВАВАЯ ПАЛИТРА ============
local COLORS = {
    bg = Color3.fromRGB(12, 8, 12),
    panel = Color3.fromRGB(20, 12, 16),
    card = Color3.fromRGB(28, 18, 22),
    text = Color3.fromRGB(240, 230, 230),
    textDim = Color3.fromRGB(150, 120, 120),
    accent = Color3.fromRGB(200, 20, 40),      -- кровавый
    accentDark = Color3.fromRGB(140, 10, 25),
    accentLight = Color3.fromRGB(255, 60, 80),
    border = Color3.fromRGB(60, 25, 35),
    toggleOff = Color3.fromRGB(70, 35, 40),
    toggleOn = Color3.fromRGB(220, 40, 60),
    blood = Color3.fromRGB(150, 0, 20),
}

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloodlineHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui
getgenv().BloodlineGui = ScreenGui

-- ============ WATERMARK ============
local Watermark = Instance.new("TextButton")
Watermark.Size = UDim2.new(0, 280, 0, 38)
Watermark.Position = UDim2.new(0, 20, 1, -60)
Watermark.BackgroundColor3 = Color3.fromRGB(15, 10, 15)
Watermark.BackgroundTransparency = 0.15
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
WMStroke.Color = COLORS.accent
WMStroke.Thickness = 1.5
WMStroke.Transparency = 0.2
WMStroke.Parent = Watermark

-- Пульсация обводки
task.spawn(function()
    local ti = TweenInfo.new(1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    pcall(function()
        TweenService:Create(WMStroke, ti, {Transparency = 0.7}):Play()
    end)
end)

local WMLabel = Instance.new("TextLabel")
WMLabel.Size = UDim2.new(1, -20, 1, 0)
WMLabel.Position = UDim2.new(0, 10, 0, 0)
WMLabel.BackgroundTransparency = 1
WMLabel.Text = "🩸 -- fps  📡 -- ms  💀 BLOODLINE"
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
    table.insert(getgenv().BloodlineConns, RunService.RenderStepped:Connect(function()
        frames = frames + 1
        if tick() - lastTick >= 1 then
            fps = frames; frames = 0; lastTick = tick()
        end
    end))
    while Watermark.Parent do
        pcall(function()
            if Config.Watermark then
                Watermark.Visible = true
                local ping = math.floor(LP:GetNetworkPing() * 1000)
                WMLabel.Text = string.format("🩸 %d fps  📡 %d ms  💀 BLOODLINE", fps, ping)
            else
                Watermark.Visible = false
            end
        end)
        task.wait(0.5)
    end
end)

-- ============ ГЛАВНОЕ ОКНО ============
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 780, 0, 510)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -255)
MainFrame.BackgroundColor3 = COLORS.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui
getgenv().BloodlineMainFrame = MainFrame

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.accent
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- Пульсация главной обводки
task.spawn(function()
    local ti = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)
    pcall(function()
        TweenService:Create(MainStroke, ti, {Transparency = 0.75}):Play()
    end)
end)

-- ============ ВЕРХНЯЯ ПАНЕЛЬ ============
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 60)
TopBar.BackgroundColor3 = Color3.fromRGB(18, 10, 14)
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = MainFrame

local TopCorner = Instance.new("UICorner")
TopCorner.CornerRadius = UDim.new(0, 14)
TopCorner.Parent = TopBar

local TopMask = Instance.new("Frame")
TopMask.Size = UDim2.new(1, 0, 0, 25)
TopMask.Position = UDim2.new(0, 0, 1, -25)
TopMask.BackgroundColor3 = Color3.fromRGB(18, 10, 14)
TopMask.BorderSizePixel = 0
TopMask.ZIndex = 3
TopMask.Parent = TopBar

-- КРОВАВАЯ ПОЛОСА СВЕРХУ (анимированная)
local BloodStripe = Instance.new("Frame")
BloodStripe.Size = UDim2.new(1, -30, 0, 3)
BloodStripe.Position = UDim2.new(0, 15, 1, -3)
BloodStripe.BackgroundColor3 = COLORS.accent
BloodStripe.BorderSizePixel = 0
BloodStripe.ZIndex = 5
BloodStripe.Parent = TopBar
local BS_Corner = Instance.new("UICorner")
BS_Corner.CornerRadius = UDim.new(1, 0)
BS_Corner.Parent = BloodStripe

local BS_Gradient = Instance.new("UIGradient")
BS_Gradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 0, 10)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 40, 60)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 0, 10)),
})
BS_Gradient.Parent = BloodStripe

-- Анимация "крови" по полосе
task.spawn(function()
    while BloodStripe.Parent do
        pcall(function()
            BS_Gradient.Offset = Vector2.new((tick() * 0.5) % 1, 0)
        end)
        task.wait(0.03)
    end
end)

-- Лого
local Logo = Instance.new("TextLabel")
Logo.Size = UDim2.new(0, 52, 0, 52)
Logo.Position = UDim2.new(0, 15, 0, 4)
Logo.BackgroundTransparency = 1
Logo.Text = "💀"
Logo.TextSize = 34
Logo.Font = Enum.Font.GothamBold
Logo.ZIndex = 4
Logo.Parent = TopBar

-- Пульс лого
task.spawn(function()
    while Logo.Parent do
        pcall(function()
            local ti = TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
            TweenService:Create(Logo, ti, {TextSize = 38}):Play()
            task.wait(1)
            TweenService:Create(Logo, ti, {TextSize = 32}):Play()
            task.wait(1)
        end)
    end
end)

local BrandName = Instance.new("TextLabel")
BrandName.Size = UDim2.new(0, 300, 0, 30)
BrandName.Position = UDim2.new(0, 70, 0, 8)
BrandName.BackgroundTransparency = 1
BrandName.Text = "BLOODLINE"
BrandName.TextColor3 = COLORS.accent
BrandName.TextSize = 22
BrandName.Font = Enum.Font.GothamBold
BrandName.TextXAlignment = Enum.TextXAlignment.Left
BrandName.ZIndex = 4
BrandName.Parent = TopBar

local BrandGradient = Instance.new("UIGradient")
BrandGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 40, 60)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(200, 20, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 40, 60)),
})
BrandGradient.Parent = BrandName

task.spawn(function()
    while BrandName.Parent do
        pcall(function()
            BrandGradient.Offset = Vector2.new((tick() * 0.3) % 1, 0)
        end)
        task.wait(0.03)
    end
end)

local SubBrand = Instance.new("TextLabel")
SubBrand.Size = UDim2.new(0, 300, 0, 18)
SubBrand.Position = UDim2.new(0, 70, 0, 34)
SubBrand.BackgroundTransparency = 1
SubBrand.Text = "v1.0 • MM2 Hub • 🩸"
SubBrand.TextColor3 = COLORS.textDim
SubBrand.TextSize = 11
SubBrand.Font = Enum.Font.Gotham
SubBrand.TextXAlignment = Enum.TextXAlignment.Left
SubBrand.ZIndex = 4
SubBrand.Parent = TopBar

-- Кнопки управления
local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 32, 0, 32)
CloseBtn.Position = UDim2.new(1, -42, 0, 14)
CloseBtn.BackgroundColor3 = Color3.fromRGB(40, 15, 20)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = COLORS.accentLight
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.ZIndex = 4
CloseBtn.Parent = TopBar
local CloseC = Instance.new("UICorner")
CloseC.CornerRadius = UDim.new(0, 8)
CloseC.Parent = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    pcall(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(80, 20, 30)
        }):Play()
    end)
end)
CloseBtn.MouseLeave:Connect(function()
    pcall(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = Color3.fromRGB(40, 15, 20)
        }):Play()
    end)
end)

-- ============ АВАТАР ============
local AvatarFrame = Instance.new("Frame")
AvatarFrame.Size = UDim2.new(0, 90, 0, 90)
AvatarFrame.Position = UDim2.new(1, -105, 0, 75)
AvatarFrame.BackgroundColor3 = Color3.fromRGB(30, 15, 20)
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

-- Попытка загрузить аватар (без крашей)
task.spawn(function()
    pcall(function()
        if Players.GetUserThumbnailAsync then
            local thumb = Players:GetUserThumbnailAsync(
                LP.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size150x150
            )
            if thumb then AvatarImage.Image = thumb end
        end
    end)
end)

-- ============ САЙДБАР ============
local SideBar = Instance.new("Frame")
SideBar.Size = UDim2.new(0, 160, 1, -88)
SideBar.Position = UDim2.new(0, 15, 0, 74)
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
SideScroll.ScrollBarThickness = 3
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

-- ============ ПОДКАТЕГОРИИ ============
local SubTabBar = Instance.new("Frame")
SubTabBar.Size = UDim2.new(1, -200, 0, 42)
SubTabBar.Position = UDim2.new(0, 185, 0, 74)
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

-- ============ КОНТЕНТ ============
local ContentFrame = Instance.new("Frame")
ContentFrame.Size = UDim2.new(1, -200, 1, -150)
ContentFrame.Position = UDim2.new(0, 185, 0, 124)
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

-- ============ ФОНОВАЯ КАРТИНКА ============
local BgImage = Instance.new("ImageLabel")
BgImage.Size = UDim2.new(1, -20, 1, -20)
BgImage.Position = UDim2.new(0, 10, 0, 10)
BgImage.BackgroundTransparency = 1
BgImage.Image = ""
BgImage.ImageTransparency = 0.75
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ZIndex = 2
BgImage.Visible = false
BgImage.Parent = MainFrame
local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 14)
BgCorner.Parent = BgImage

getgenv().BloodlineSetBg = function(assetId)
    pcall(function()
        if assetId and assetId ~= "" then
            BgImage.Image = assetId
            BgImage.Visible = true
        else
            BgImage.Visible = false
        end
    end)
end

-- ============ ПЛАВАЮЩАЯ КНОПКА ============
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 140, 0, 46)
ToggleBtn.Position = UDim2.new(0.5, -70, 1, -76)
ToggleBtn.BackgroundColor3 = COLORS.accent
ToggleBtn.Text = "💀 BLOODLINE"
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

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color = Color3.fromRGB(255, 80, 80)
ToggleStroke.Thickness = 2
ToggleStroke.Transparency = 0.3
ToggleStroke.Parent = ToggleBtn

-- ============ СОХРАНЕНИЕ ССЫЛОК ============
getgenv().BloodlineRefs = {
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
    HttpService = HttpService, VirtualUser = VirtualUser,
    LocalPlayer = LP, Camera = Camera, Config = Config, Notify = Notify,
    HasDrawing = HAS_DRAWING, HasFileAPI = HAS_FILE_API,
}

print("✅ [Bloodline] Часть 1/8 — Ядро + GUI (кровавый стиль)")
Notify("🩸 Загрузка 1/8...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 2A: Базовые UI             ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
if not R then warn("❌ Запусти Часть 1!") return end

local TweenService = R.TweenService
local UserInputService = R.UserInputService
local SideScroll = R.SideScroll
local SubTabScroll = R.SubTabScroll
local COLORS = R.Colors

local function CreateCategory(name, icon)
    local Cat = Instance.new("TextButton")
    Cat.Size = UDim2.new(1, -8, 0, 38)
    Cat.BackgroundColor3 = Color3.fromRGB(30, 18, 22)
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
            pcall(function()
                TweenService:Create(Cat, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(50, 22, 30)
                }):Play()
            end)
        end
    end)
    Cat.MouseLeave:Connect(function()
        if Cat.BackgroundColor3 ~= COLORS.accent then
            pcall(function()
                TweenService:Create(Cat, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(30, 18, 22)
                }):Play()
            end)
        end
    end)
    return Cat
end

local function CreateSubTab(name, icon)
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(0, 125, 0, 30)
    Tab.BackgroundColor3 = Color3.fromRGB(30, 18, 22)
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

local function CreateSection(parent, text)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 32)
    Frame.BackgroundTransparency = 1
    Frame.ZIndex = 5
    Frame.Parent = parent

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(0, 3, 0, 22)
    Bar.Position = UDim2.new(0, 6, 0.5, -11)
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
    Label.TextColor3 = COLORS.accent
    Label.TextSize = 14
    Label.Font = Enum.Font.GothamBold
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    return Frame
end

local function CreateCard(parent, text, opts)
    opts = opts or {}
    local hasColor = opts.hasColor
    local hasSettings = opts.hasSettings
    local hasToggle = opts.hasToggle ~= false

    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 46)
    Frame.BackgroundColor3 = COLORS.card
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

    if hasToggle then
        local ToggleBg = Instance.new("Frame")
        ToggleBg.Size = UDim2.new(0, 40, 0, 22)
        ToggleBg.Position = UDim2.new(1, rightOffset - 40, 0.5, -11)
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
        ClickBtn.Size = UDim2.new(0, 40, 0, 22)
        ClickBtn.Position = UDim2.new(1, rightOffset - 40, 0.5, -11)
        ClickBtn.BackgroundTransparency = 1
        ClickBtn.Text = ""
        ClickBtn.ZIndex = 8
        ClickBtn.Parent = Frame

        local state = opts.default or false
        ClickBtn.MouseButton1Click:Connect(function()
            state = not state
            pcall(function()
                TweenService:Create(ToggleBg, TweenInfo.new(0.2), {
                    BackgroundColor3 = state and COLORS.toggleOn or COLORS.toggleOff
                }):Play()
                TweenService:Create(ToggleInd, TweenInfo.new(0.2), {
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                }):Play()
            end)
            if opts.callback then pcall(opts.callback, state) end
        end)
        rightOffset = rightOffset - 52
    end

    if hasSettings then
        local SettingsBtn = Instance.new("TextButton")
        SettingsBtn.Size = UDim2.new(0, 26, 0, 26)
        SettingsBtn.Position = UDim2.new(1, rightOffset - 26, 0.5, -13)
        SettingsBtn.BackgroundColor3 = Color3.fromRGB(45, 22, 28)
        SettingsBtn.Text = "⚙"
        SettingsBtn.TextColor3 = COLORS.accentLight
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

local function CreateToggle(parent, text, default, callback)
    return CreateCard(parent, text, {
        hasToggle = true,
        default = default,
        callback = callback,
    })
end

local function CreateSlider(parent, text, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 56)
    Frame.BackgroundColor3 = COLORS.card
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
    ValueL.TextColor3 = COLORS.accentLight
    ValueL.TextSize = 13
    ValueL.Font = Enum.Font.GothamBold
    ValueL.TextXAlignment = Enum.TextXAlignment.Right
    ValueL.ZIndex = 6
    ValueL.Parent = Frame

    local Bar = Instance.new("Frame")
    Bar.Size = UDim2.new(1, -28, 0, 8)
    Bar.Position = UDim2.new(0, 14, 0, 38)
    Bar.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
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

getgenv().BloodlineUI = getgenv().BloodlineUI or {}
local UI = getgenv().BloodlineUI

UI.CreateCategory = CreateCategory
UI.CreateSubTab = CreateSubTab
UI.CreatePage = CreatePage
UI.CreateSection = CreateSection
UI.CreateCard = CreateCard
UI.CreateToggle = CreateToggle
UI.CreateSlider = CreateSlider

print("✅ [Bloodline] Часть 2A/8 — Базовые UI")
R.Notify("🩸 Загрузка 2A...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 2B: Доп. UI                ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1 и 2A!") return end

local TweenService = R.TweenService
local UserInputService = R.UserInputService
local COLORS = R.Colors

local function CreateButton(parent, text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 42)
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
        pcall(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.fromRGB(
                    math.min(255, origColor.R * 255 + 30),
                    math.min(255, origColor.G * 255 + 15),
                    math.min(255, origColor.B * 255 + 20)
                )
            }):Play()
        end)
    end)
    Btn.MouseLeave:Connect(function()
        pcall(function()
            TweenService:Create(Btn, TweenInfo.new(0.15), {
                BackgroundColor3 = origColor
            }):Play()
        end)
    end)

    Btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
    return Btn
end

local function CreateInput(parent, placeholder, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 42)
    Frame.BackgroundColor3 = COLORS.card
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

local function CreateDropdown(parent, text, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 46)
    Frame.BackgroundColor3 = COLORS.card
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
    Selected.Size = UDim2.new(0.5, -14, 0, 32)
    Selected.Position = UDim2.new(0.5, 0, 0, 7)
    Selected.BackgroundColor3 = Color3.fromRGB(45, 22, 30)
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
        Frame.Size = open and UDim2.new(1, -10, 0, 46 + #options * 30) or UDim2.new(1, -10, 0, 46)
    end)

    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, -14, 0, 26)
        OptBtn.Position = UDim2.new(0, 7, 0, 46 + (i - 1) * 30)
        OptBtn.BackgroundColor3 = Color3.fromRGB(45, 22, 30)
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
            Frame.Size = UDim2.new(1, -10, 0, 46)
            if callback then pcall(callback, opt) end
        end)
        table.insert(optionFrames, OptBtn)
    end
    return Frame
end

local function CreateColorPicker(parent, text, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, -10, 0, 46)
    Frame.BackgroundColor3 = COLORS.card
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
    Panel.Position = UDim2.new(0, 7, 0, 46)
    Panel.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
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
        Bar.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
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
        Frame.Size = open and UDim2.new(1, -10, 0, 46 + 130) or UDim2.new(1, -10, 0, 46)
    end)

    return Frame
end

UI.CreateButton = CreateButton
UI.CreateInput = CreateInput
UI.CreateDropdown = CreateDropdown
UI.CreateColorPicker = CreateColorPicker

print("✅ [Bloodline] Часть 2B/8 — Доп. UI")
R.Notify("🩸 Загрузка 2B...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 3/8: Home, General, MM2    ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-2B!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local ContentFrame = R.ContentFrame

-- Хелперы
local function GetChar()
    local c = LP.Character
    if not c or not c.Parent then return nil, nil, nil end
    return c, c:FindFirstChild("HumanoidRootPart"), c:FindFirstChildOfClass("Humanoid")
end
getgenv().BloodlineGetChar = GetChar

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
getgenv().BloodlineGetRole = GetRole

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
getgenv().BloodlineGetTargets = GetTargets

local function GetEquippedTool()
    local char = LP.Character
    if not char then return nil end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return c end
    end
end
getgenv().BloodlineGetTool = GetEquippedTool

-- Категории
local CatHome = UI.CreateCategory("Home", "🩸")
local CatGeneral = UI.CreateCategory("General", "⚙")
local CatMM2 = UI.CreateCategory("MM2", "🔫")
local CatVisuals = UI.CreateCategory("Visuals", "👁")
local CatTarget = UI.CreateCategory("Target", "🎯")
local CatFun = UI.CreateCategory("Fun", "🎉")
local CatEmotes = UI.CreateCategory("Emotes", "💃")
local CatSound = UI.CreateCategory("Sound", "🎵")
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
        c.Tab.BackgroundColor3 = (i == idx) and R.Colors.accent or Color3.fromRGB(30, 18, 22)
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

-- ============ HOME ============
UI.CreateSection(PageHome, "🩸 Добро пожаловать в Bloodline Hub")
UI.CreateSection(PageHome, "💀 Версия: v1.0 • MM2 Edition")
UI.CreateSection(PageHome, "⌨ RightShift / F1 — меню")
UI.CreateSection(PageHome, "⌨ Delete — выгрузить")
UI.CreateSection(PageHome, "⌨ G — Invis Bind")

local InfoCard = UI.CreateCard(PageHome, "💙 Сделано для MM2 с любовью", {hasToggle = false})
InfoCard.Size = UDim2.new(1, -10, 0, 52)

UI.CreateSection(PageHome, "📊 СТАТИСТИКА")
local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, -10, 0, 110)
StatsFrame.BackgroundColor3 = R.Colors.card
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
                "👥 Игроков: %d\n📡 Ping: %d ms\n🎭 Роль: %s\n💀 Bloodline v1.0",
                #Players:GetPlayers(),
                math.floor(LP:GetNetworkPing() * 1000),
                GetRole(LP)
            )
        end)
        task.wait(1)
    end
end)

-- ============ GENERAL ============
UI.CreateSection(PageGeneral, "⚙ ОБЩИЕ")
UI.CreateToggle(PageGeneral, "Anti-AFK", Config.AntiAFK, function(s) Config.AntiAFK = s end)
UI.CreateToggle(PageGeneral, "Watermark (FPS/Ping)", Config.Watermark, function(s)
    Config.Watermark = s
end)

UI.CreateSection(PageGeneral, "🎨 ТЕМА")
UI.CreateDropdown(PageGeneral, "Стиль UI", {"Blood (красный)", "Dark", "Auto"}, "Blood (красный)", function(v)
    R.Notify("🎨 Стиль: " .. v, 2)
end)

-- ============ MM2 ============
UI.CreateSection(PageMM2, "🔫 AUTO")
UI.CreateToggle(PageMM2, "Auto Pickup Gun", Config.AutoPickupGun, function(s) Config.AutoPickupGun = s end)
UI.CreateToggle(PageMM2, "Silent Aim", Config.SilentAim, function(s) Config.SilentAim = s end)
UI.CreateSlider(PageMM2, "Silent Aim FOV", 10, 500, Config.SilentAimFOV, function(v) Config.SilentAimFOV = v end)

UI.CreateSection(PageMM2, "🎭 MM2 SPECIAL")
UI.CreateToggle(PageMM2, "Reveal Roles", Config.RevealRoles, function(s)
    Config.RevealRoles = s
    if s then
        local roles = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            table.insert(roles, plr.Name .. ": " .. GetRole(plr))
        end
        R.Notify("🎭 " .. table.concat(roles, " | "), 5)
    end
end)
UI.CreateToggle(PageMM2, "Auto Win", Config.AutoWin, function(s) Config.AutoWin = s end)
UI.CreateToggle(PageMM2, "Second Chance", Config.SecondChance, function(s) Config.SecondChance = s end)
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
    if s and getgenv().BloodlineStartFly then getgenv().BloodlineStartFly()
    elseif getgenv().BloodlineStopFly then getgenv().BloodlineStopFly() end
end)
UI.CreateSlider(PageMM2, "Скорость полёта", 10, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end)
UI.CreateToggle(PageMM2, "Spin", Config.Spin, function(s) Config.Spin = s end)
UI.CreateSlider(PageMM2, "Скорость Spin", 1, 60, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)
UI.CreateToggle(PageMM2, "Bhop", Config.Bhop, function(s) Config.Bhop = s end)
UI.CreateToggle(PageMM2, "Invis", Config.Invis, function(s) Config.Invis = s end)
UI.CreateToggle(PageMM2, "Invis Bind (G)", Config.InvisBind, function(s) Config.InvisBind = s end)
UI.CreateToggle(PageMM2, "Click TP", Config.ClickTP, function(s) Config.ClickTP = s end)

print("✅ [Bloodline] Часть 3/8 — Home, General, MM2")
R.Notify("🩸 Загрузка 3/8...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 4/8: Visuals + Target      ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-3!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera
local TweenService = R.TweenService
local PageVisuals = R.PageVisuals
local PageTarget = R.PageTarget

local GetChar = getgenv().BloodlineGetChar
local GetTargets = getgenv().BloodlineGetTargets
local GetRole = getgenv().BloodlineGetRole

-- ============ VISUALS ============
UI.CreateSection(PageVisuals, "🔫 GUN MODEL")
UI.CreateDropdown(PageVisuals, "Select Model", {
    "BigUSP-S", "BigKnife", "BigRevolver", "Sword", "Raygun", "Golden Gun", "Candy Cane", "Nerf Gun"
}, Config.GunModelType, function(v) Config.GunModelType = v end)
UI.CreateToggle(PageVisuals, "Gun Model", Config.GunModel, function(s) Config.GunModel = s end)

UI.CreateSection(PageVisuals, "✨ GUN BEAM")
UI.CreateColorPicker(PageVisuals, "Beam Color", Config.GunBeamColor, function(c) Config.GunBeamColor = c end)
UI.CreateToggle(PageVisuals, "Gun Beam (лазер)", Config.GunBeam, function(s) Config.GunBeam = s end)

UI.CreateSection(PageVisuals, "👤 AVATAR")
UI.CreateCard(PageVisuals, "Skeleton ESP", {
    hasColor = true, color = Color3.fromRGB(200, 130, 255),
    hasToggle = true, hasSettings = true,
    default = Config.SkeletonESP,
    callback = function(s) Config.SkeletonESP = s end,
    onSettings = function() R.Notify("⚙ Skeleton ESP", 2) end,
})
UI.CreateCard(PageVisuals, "China Hat", {
    hasColor = true, color = Config.ChinaHatColor,
    hasToggle = true, hasSettings = true,
    default = Config.ChinaHat,
    callback = function(s) Config.ChinaHat = s end,
    onSettings = function() R.Notify("⚙ China Hat", 2) end,
})
UI.CreateCard(PageVisuals, "Jump Circle", {
    hasColor = true, color = Color3.fromRGB(200, 40, 60),
    hasToggle = true, hasSettings = true,
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
    pcall(function()
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
end)

UI.CreateSection(PageVisuals, "👁️ ESP")
UI.CreateToggle(PageVisuals, "ESP игроков", Config.ESP, function(s) Config.ESP = s end)
UI.CreateToggle(PageVisuals, "Role ESP", Config.RoleESP, function(s) Config.RoleESP = s end)
UI.CreateToggle(PageVisuals, "Gun ESP", Config.GunESP, function(s) Config.GunESP = s end)
UI.CreateToggle(PageVisuals, "Tracers", Config.Tracers, function(s) Config.Tracers = s end)
UI.CreateToggle(PageVisuals, "Hitbox Expander", Config.HitboxExpander, function(s) Config.HitboxExpander = s end)
UI.CreateSlider(PageVisuals, "Hitbox Size", 2, 20, Config.HitboxSize, function(v) Config.HitboxSize = v end)

-- ============ ЛОГИКА CHINA HAT ============
local chinaHats = {}
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if tick() % 0.5 > 0.02 then return end
    pcall(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr.Character then
                local head = plr.Character:FindFirstChild("Head")
                if head then
                    if Config.ChinaHat then
                        if not chinaHats[plr] or not chinaHats[plr].Parent then
                            local hat = Instance.new("Part")
                            hat.Name = "BloodlineHat"
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
                            weld.Part0 = hat; weld.Part1 = head; weld.Parent = hat
                            chinaHats[plr] = hat
                        end
                        if chinaHats[plr] then chinaHats[plr].Color = Config.ChinaHatColor end
                    else
                        if chinaHats[plr] then pcall(function() chinaHats[plr]:Destroy() end); chinaHats[plr] = nil end
                    end
                end
            end
        end
    end)
end))

-- ============ ЛОГИКА JUMP CIRCLE ============
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.JumpCircle then return end
    pcall(function()
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
                    circle.Color = Color3.fromRGB(200, 40, 60)
                    circle.Transparency = 0.4
                    circle.Parent = Workspace
                    TweenService:Create(circle, TweenInfo.new(0.6), {
                        Transparency = 1, Size = Vector3.new(0.2, 15, 15)
                    }):Play()
                    task.delay(0.7, function() pcall(function() circle:Destroy() end) end)
                end
            end
        end
    end)
end))

-- ============ ЛОГИКА GUN BEAM ============
local beamFolder = Workspace:FindFirstChild("BloodlineBeams")
if not beamFolder then
    beamFolder = Instance.new("Folder")
    beamFolder.Name = "BloodlineBeams"
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
            table.insert(getgenv().BloodlineConns, tool.Activated:Connect(function()
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
table.insert(getgenv().BloodlineConns, LP.CharacterAdded:Connect(function(c)
    task.wait(0.5); HookTools(c)
end))

-- ============ HITBOX EXPANDER ============
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.HitboxExpander then return end
    pcall(function()
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    hrp.Size = Vector3.new(Config.HitboxSize, Config.HitboxSize, Config.HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.CanCollide = false
                end
            end
        end
    end)
end))

-- ============ TARGET ============
UI.CreateSection(PageTarget, "🎯 ЦЕЛИ")
UI.CreateToggle(PageTarget, "Kill Aura", Config.KillAura, function(s) Config.KillAura = s end)
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

UI.CreateButton(PageTarget, "🔪 TP к Murder", Color3.fromRGB(220, 60, 60), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
    local _, hrp = GetChar()
    if hrp and #targets > 0 then
        hrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🔪 К Murder", 2)
    else
        R.Notify("❌ Murder не найден", 2)
    end
end)

UI.CreateButton(PageTarget, "🚔 TP к Sheriff", Color3.fromRGB(80, 130, 220), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Sheriff" end)
    local _, hrp = GetChar()
    if hrp and #targets > 0 then
        hrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
        R.Notify("🚔 К Sheriff", 2)
    else
        R.Notify("❌ Sheriff не найден", 2)
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

print("✅ [Bloodline] Часть 4/8 — Visuals + Target")
R.Notify("🩸 Загрузка 4/8...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 5A: Fun                    ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-4!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = R.Camera
local PageFun = R.PageFun

local GetChar = getgenv().BloodlineGetChar
local GetTargets = getgenv().BloodlineGetTargets
local GetRole = getgenv().BloodlineGetRole

UI.CreateSection(PageFun, "😈 FLING")
UI.CreateToggle(PageFun, "Touch Fling", Config.TouchFling, function(s) Config.TouchFling = s end)
UI.CreateToggle(PageFun, "Click Fling", Config.ClickFling, function(s) Config.ClickFling = s end)
UI.CreateToggle(PageFun, "Fling All", Config.FlingAll, function(s) Config.FlingAll = s end)
UI.CreateToggle(PageFun, "Fling Murder", Config.FlingMurder, function(s) Config.FlingMurder = s end)
UI.CreateToggle(PageFun, "Fling Sheriff", Config.FlingSheriff, function(s) Config.FlingSheriff = s end)

local function ApplyFling(hrp, power)
    pcall(function()
        local bv = Instance.new("BodyVelocity")
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(power, power, power)
        bv.Parent = hrp
        task.delay(0.3, function() pcall(function() bv:Destroy() end) end)
    end)
end

table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.FlingAll then return end
    pcall(function()
        local _, myHrp = GetChar()
        if not myHrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp then ApplyFling(hrp, 500) end
            end
        end
    end)
end))

table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.FlingMurder then return end
    pcall(function()
        local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
        for _, t in ipairs(targets) do ApplyFling(t.hrp, 500) end
    end)
end))

table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.FlingSheriff then return end
    pcall(function()
        local targets = GetTargets(function(p) return GetRole(p) == "Sheriff" end)
        for _, t in ipairs(targets) do ApplyFling(t.hrp, 500) end
    end)
end))

table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.TouchFling then return end
    pcall(function()
        local _, myHrp = GetChar()
        if not myHrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if hrp and (myHrp.Position - hrp.Position).Magnitude < 8 then
                    ApplyFling(hrp, 800)
                end
            end
        end
    end)
end))

table.insert(getgenv().BloodlineConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if not Config.ClickFling then return end
    if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
    pcall(function()
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
                if hrp then ApplyFling(hrp, 1000) end
                local targetPlr = Players:GetPlayerFromCharacter(char)
                if targetPlr then R.Notify("😈 Fling: " .. targetPlr.Name, 2) end
            end
        end
    end)
end))

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

print("✅ [Bloodline] Часть 5A/8 — Fun")
R.Notify("🩸 Загрузка 5A...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 5B: Emotes + Sound         ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-5A!") return end

local Config = R.Config
local LP = R.LocalPlayer
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local PageEmotes = R.PageEmotes
local PageSound = R.PageSound

-- ============ EMOTES ============
UI.CreateSection(PageEmotes, "💃 АНИМАЦИИ")

-- Безопасный проигрыватель через Humanoid (без LoadAnimation)
local function DoEmote(name)
    pcall(function()
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if name == "dance" then
            for i = 1, 8 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(15))
                task.wait(0.1)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(-30))
                task.wait(0.1)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(15))
                task.wait(0.1)
            end
        elseif name == "spin" then
            for i = 1, 20 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(30), 0)
                task.wait(0.05)
            end
        elseif name == "sit" then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Sit) end)
        elseif name == "flip" then
            for i = 1, 20 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(18), 0, 0)
                task.wait(0.03)
            end
        elseif name == "wave" then
            for i = 1, 3 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(10))
                task.wait(0.15)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(-20))
                task.wait(0.15)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(10))
                task.wait(0.15)
            end
        end
    end)
end

UI.CreateButton(PageEmotes, "💃 Танец", R.Colors.accent, function() DoEmote("dance") end)
UI.CreateButton(PageEmotes, "🌀 Spin", R.Colors.accent, function() DoEmote("spin") end)
UI.CreateButton(PageEmotes, "🪑 Сидеть", R.Colors.accent, function() DoEmote("sit") end)
UI.CreateButton(PageEmotes, "🤸 Сальто", R.Colors.accent, function() DoEmote("flip") end)
UI.CreateButton(PageEmotes, "👋 Махнуть", R.Colors.accent, function() DoEmote("wave") end)

-- ============ SOUND PLAYER ============
UI.CreateSection(PageSound, "🎵 МУЗЫКАЛЬНЫЙ ПЛЕЕР")

local PlayerFrame = Instance.new("Frame")
PlayerFrame.Size = UDim2.new(1, -10, 0, 200)
PlayerFrame.BackgroundColor3 = R.Colors.card
PlayerFrame.BorderSizePixel = 0
PlayerFrame.ZIndex = 5
PlayerFrame.Parent = PageSound
local PFC = Instance.new("UICorner")
PFC.CornerRadius = UDim.new(0, 8)
PFC.Parent = PlayerFrame
local PFStroke = Instance.new("UIStroke")
PFStroke.Color = R.Colors.border
PFStroke.Thickness = 1
PFStroke.Parent = PlayerFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -20, 0, 24)
Title.Position = UDim2.new(0, 12, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "🩸 Вставь ID музыки (Roblox)"
Title.TextColor3 = R.Colors.text
Title.TextSize = 12
Title.Font = Enum.Font.GothamMedium
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 6
Title.Parent = PlayerFrame

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -24, 0, 36)
InputFrame.Position = UDim2.new(0, 12, 0, 36)
InputFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
InputFrame.BorderSizePixel = 0
InputFrame.ZIndex = 6
InputFrame.Parent = PlayerFrame
local IFC = Instance.new("UICorner")
IFC.CornerRadius = UDim.new(0, 8)
IFC.Parent = InputFrame
local IFStroke = Instance.new("UIStroke")
IFStroke.Color = R.Colors.border
IFStroke.Thickness = 1
IFStroke.Parent = InputFrame

local MusicInput = Instance.new("TextBox")
MusicInput.Size = UDim2.new(1, -24, 1, -8)
MusicInput.Position = UDim2.new(0, 12, 0, 4)
MusicInput.BackgroundTransparency = 1
MusicInput.Text = ""
MusicInput.PlaceholderText = "Например: 1837879082"
MusicInput.PlaceholderColor3 = R.Colors.textDim
MusicInput.TextColor3 = R.Colors.text
MusicInput.TextSize = 13
MusicInput.Font = Enum.Font.GothamMedium
MusicInput.TextXAlignment = Enum.TextXAlignment.Left
MusicInput.ClearTextOnFocus = false
MusicInput.ZIndex = 7
MusicInput.Parent = InputFrame

local musicInstance = nil
local musicFolder = Workspace:FindFirstChild("BloodlineMusic")
if not musicFolder then
    musicFolder = Instance.new("Folder")
    musicFolder.Name = "BloodlineMusic"
    musicFolder.Parent = Workspace
end

local function NormalizeId(input)
    input = tostring(input):gsub("%s", "")
    if input == "" then return nil end
    if input:match("^%d+$") then return "rbxassetid://" .. input end
    if input:match("rbxassetid://") then return input end
    if input:match("^https?://") then
        local id = input:match("(%d+)")
        if id then return "rbxassetid://" .. id end
    end
    return "rbxassetid://" .. input
end

local function PlayMusicFromInput()
    local id = NormalizeId(MusicInput.Text)
    if not id then R.Notify("❌ Введи ID музыки", 2) return end
    pcall(function()
        if musicInstance then musicInstance:Destroy() end
        musicInstance = Instance.new("Sound")
        musicInstance.SoundId = id
        musicInstance.Volume = (Config.MusicVolume or 50) / 100
        musicInstance.Looped = true
        musicInstance.Parent = musicFolder
        musicInstance:Play()
        Config.LastMusicID = id
        R.Notify("🩸 Играет: " .. id, 2)
    end)
end

local BtnRow = Instance.new("Frame")
BtnRow.Size = UDim2.new(1, -24, 0, 36)
BtnRow.Position = UDim2.new(0, 12, 0, 80)
BtnRow.BackgroundTransparency = 1
BtnRow.ZIndex = 6
BtnRow.Parent = PlayerFrame

local BtnLayout = Instance.new("UIListLayout")
BtnLayout.FillDirection = Enum.FillDirection.Horizontal
BtnLayout.Padding = UDim.new(0, 6)
BtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
BtnLayout.Parent = BtnRow

local function MakeSmallBtn(text, color, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 100, 0, 32)
    Btn.BackgroundColor3 = color
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.GothamBold
    Btn.ZIndex = 7
    Btn.Parent = BtnRow
    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 8)
    C.Parent = Btn
    Btn.MouseButton1Click:Connect(callback)
    return Btn
end

MakeSmallBtn("▶ Play", Color3.fromRGB(80, 180, 100), PlayMusicFromInput)
MakeSmallBtn("⏸ Pause", Color3.fromRGB(200, 160, 60), function()
    if musicInstance then
        pcall(function() musicInstance:Pause() end)
        R.Notify("⏸ Пауза", 2)
    end
end)
MakeSmallBtn("⏹ Stop", Color3.fromRGB(220, 60, 60), function()
    if musicInstance then
        pcall(function() musicInstance:Stop(); musicInstance:Destroy() end)
        musicInstance = nil
        R.Notify("⏹ Остановлено", 2)
    end
end)

-- Volume
local VolLabel = Instance.new("TextLabel")
VolLabel.Size = UDim2.new(0, 90, 0, 20)
VolLabel.Position = UDim2.new(0, 12, 0, 132)
VolLabel.BackgroundTransparency = 1
VolLabel.Text = "🔊 Громкость"
VolLabel.TextColor3 = R.Colors.text
VolLabel.TextSize = 12
VolLabel.Font = Enum.Font.GothamMedium
VolLabel.TextXAlignment = Enum.TextXAlignment.Left
VolLabel.ZIndex = 6
VolLabel.Parent = PlayerFrame

local VolValue = Instance.new("TextLabel")
VolValue.Size = UDim2.new(0, 40, 0, 20)
VolValue.Position = UDim2.new(1, -52, 0, 132)
VolValue.BackgroundTransparency = 1
VolValue.Text = tostring(Config.MusicVolume or 50)
VolValue.TextColor3 = R.Colors.accentLight
VolValue.TextSize = 12
VolValue.Font = Enum.Font.GothamBold
VolValue.TextXAlignment = Enum.TextXAlignment.Right
VolValue.ZIndex = 6
VolValue.Parent = PlayerFrame

local VolBar = Instance.new("Frame")
VolBar.Size = UDim2.new(1, -24, 0, 8)
VolBar.Position = UDim2.new(0, 12, 0, 162)
VolBar.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
VolBar.BorderSizePixel = 0
VolBar.ZIndex = 6
VolBar.Parent = PlayerFrame
local VBC = Instance.new("UICorner")
VBC.CornerRadius = UDim.new(1, 0)
VBC.Parent = VolBar

local VolFill = Instance.new("Frame")
VolFill.Size = UDim2.new((Config.MusicVolume or 50) / 100, 0, 1, 0)
VolFill.BackgroundColor3 = R.Colors.accent
VolFill.BorderSizePixel = 0
VolFill.ZIndex = 7
VolFill.Parent = VolBar
local VFC = Instance.new("UICorner")
VFC.CornerRadius = UDim.new(1, 0)
VFC.Parent = VolFill

local volDragging = false
VolBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        volDragging = true
    end
end)
UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        volDragging = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if volDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local m = UserInputService:GetMouseLocation()
        local bp = VolBar.AbsolutePosition
        local bs = VolBar.AbsoluteSize
        local rel = math.clamp((m.X - bp.X) / bs.X, 0, 1)
        VolFill.Size = UDim2.new(rel, 0, 1, 0)
        VolValue.Text = tostring(math.floor(rel * 100))
        Config.MusicVolume = math.floor(rel * 100)
        if musicInstance then
            pcall(function() musicInstance.Volume = rel end)
        end
    end
end)

-- Быстрые пресеты
UI.CreateSection(PageSound, "🎼 БЫСТРЫЕ ТРЕКИ")

local function QuickPlay(id)
    MusicInput.Text = id
    PlayMusicFromInput()
end

UI.CreateButton(PageSound, "🩸 Lofi", R.Colors.accent, function() QuickPlay("1837879082") end)
UI.CreateButton(PageSound, "🩸 Phonk", R.Colors.accent, function() QuickPlay("1838457666") end)
UI.CreateButton(PageSound, "🩸 Anime OP", R.Colors.accent, function() QuickPlay("1836248630") end)
UI.CreateButton(PageSound, "🩸 Piano", R.Colors.accent, function() QuickPlay("1836197175") end)
UI.CreateButton(PageSound, "🩸 Guitar", R.Colors.accent, function() QuickPlay("1837876001") end)
UI.CreateButton(PageSound, "🛑 Стоп всё", Color3.fromRGB(220, 60, 60), function()
    if musicInstance then
        pcall(function() musicInstance:Destroy() end)
        musicInstance = nil
    end
end)

print("✅ [Bloodline] Часть 5B/8 — Emotes + Sound Player")
R.Notify("🩸 Загрузка 5B...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 6/8: Configs               ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-5B!") return end

local Config = R.Config
local LP = R.LocalPlayer
local TeleportService = R.TeleportService
local PageConfigs = R.PageConfigs

UI.CreateSection(PageConfigs, "🖼 ФОНЫ (выбор из 10)")

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
            R.BloodlineSetBg(bg.id)
            R.Notify("🖼 Фон: " .. selected, 2)
            return
        end
    end
    R.Notify("⚠ Сначала загрузите AssetID", 3)
end)

UI.CreateInput(PageConfigs, "AssetID фона (rbxassetid://...)", "", function(text)
    if text ~= "" then
        R.BloodlineSetBg(text)
        R.Notify("🖼 Фон установлен", 2)
    end
end)

UI.CreateButton(PageConfigs, "❌ Убрать фон", Color3.fromRGB(80, 30, 40), function()
    R.BloodlineSetBg("")
end)

UI.CreateSlider(PageConfigs, "Прозрачность фона (0-100)", 0, 100, 75, function(v)
    if R.BgImage then
        R.BgImage.ImageTransparency = v / 100
    end
end)

UI.CreateSection(PageConfigs, "💾 СОХРАНЕНИЕ КОНФИГА")

local configName = "bloodline_config"
UI.CreateInput(PageConfigs, "Название конфига", configName, function(text)
    configName = text
end)

UI.CreateButton(PageConfigs, "💾 Сохранить", Color3.fromRGB(80, 180, 100), function()
    pcall(function()
        if not R.HasFileAPI then R.Notify("❌ writefile недоступен", 2) return end
        if isfolder and not isfolder("BloodlineHub") then makefolder("BloodlineHub") end
        local path = "BloodlineHub/" .. configName .. ".json"
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
    end)
end)

UI.CreateButton(PageConfigs, "📥 Загрузить", R.Colors.accent, function()
    pcall(function()
        if not R.HasFileAPI then R.Notify("❌ readfile недоступен", 2) return end
        local path = "BloodlineHub/" .. configName .. ".json"
        if isfile and isfile(path) then
            local data = R.HttpService:JSONDecode(readfile(path))
            for k, v in pairs(data) do
                if type(v) == "table" and v.__color then
                    Config[k] = Color3.fromRGB(v.r * 255, v.g * 255, v.b * 255)
                else
                    Config[k] = v
                end
            end
            R.Notify("📥 Загружено (перезапусти)", 3)
        else
            R.Notify("❌ Конфиг не найден", 2)
        end
    end)
end)

UI.CreateButton(PageConfigs, "📂 Список конфигов", Color3.fromRGB(80, 40, 50), function()
    pcall(function()
        if not R.HasFileAPI then R.Notify("❌ listfiles недоступен", 2) return end
        if isfolder and isfolder("BloodlineHub") then
            local list = {}
            for _, f in ipairs(listfiles("BloodlineHub")) do
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

UI.CreateSection(PageConfigs, "🔧 ДЕЙСТВИЯ")

UI.CreateButton(PageConfigs, "🔄 Rejoin сервер", R.Colors.accent, function()
    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
end)

UI.CreateButton(PageConfigs, "❌ Выгрузить Hub", Color3.fromRGB(220, 60, 60), function()
    if getgenv().BloodlineStopFly then pcall(getgenv().BloodlineStopFly) end
    for _, objs in pairs(getgenv().BloodlineESP or {}) do
        for _, o in pairs(objs) do pcall(function() o:Remove() end) end
    end
    for _, c in pairs(getgenv().BloodlineConns or {}) do pcall(function() c:Disconnect() end) end
    R.ScreenGui:Destroy()
    getgenv().BloodlineGui = nil
    getgenv().BloodlineRefs = nil
end)

print("✅ [Bloodline] Часть 6/8 — Configs")
R.Notify("🩸 Загрузка 6/8...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 7/8: ESP + Движение        ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-6!") return end

local Config = R.Config
local LP = R.LocalPlayer
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Camera = R.Camera
local Workspace = R.Workspace
local ESPObjects = getgenv().BloodlineESP
local GetRole = getgenv().BloodlineGetRole
local GetChar = getgenv().BloodlineGetChar

-- ============ ESP ============
local ROLE_COLORS = {
    Murder = Color3.fromRGB(255, 40, 60),
    Sheriff = Color3.fromRGB(80, 130, 255),
    Innocent = Color3.fromRGB(80, 220, 130),
}

local function CreateESPPlayer(player)
    if getgenv().BloodlineNoDrawing then return end
    if player == LP or ESPObjects[player] then return end
    pcall(function()
        local Box = Drawing.new("Square")
        Box.Thickness = 2; Box.Filled = false; Box.Transparency = 1; Box.Visible = false
        local NameTag = Drawing.new("Text")
        NameTag.Size = 14; NameTag.Center = true; NameTag.Outline = true
        NameTag.Color = Color3.fromRGB(240, 230, 230); NameTag.Visible = false
        local DistanceTag = Drawing.new("Text")
        DistanceTag.Size = 12; DistanceTag.Center = true; DistanceTag.Outline = true
        DistanceTag.Color = Color3.fromRGB(220, 40, 60); DistanceTag.Visible = false
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

if not getgenv().BloodlineNoDrawing then
    for _, plr in ipairs(Players:GetPlayers()) do CreateESPPlayer(plr) end
    table.insert(getgenv().BloodlineConns, Players.PlayerAdded:Connect(CreateESPPlayer))
    table.insert(getgenv().BloodlineConns, Players.PlayerRemoving:Connect(RemoveESPPlayer))
    table.insert(getgenv().BloodlineConns, RunService.RenderStepped:Connect(function()
        pcall(UpdateESP)
    end))
end

-- ============ FLY ============
local flyActive = false
local flyBV, flyBG = nil, nil

local function StopFly()
    flyActive = false
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    local _, _, hum = GetChar()
    if hum then pcall(function() hum.PlatformStand = false end) end
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
    flyBG.P = 10000; flyBG.D = 500
    flyBG.Parent = hrp
    flyActive = true

    table.insert(getgenv().BloodlineConns, RunService.RenderStepped:Connect(function()
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

getgenv().BloodlineStartFly = StartFly
getgenv().BloodlineStopFly = StopFly

-- ============ SPIN ============
local spinAngle = 0
table.insert(getgenv().BloodlineConns, RunService.RenderStepped:Connect(function(dt)
    if not Config.Spin then return end
    local _, hrp = GetChar()
    if not hrp then return end
    spinAngle = spinAngle + Config.SpinSpeed * dt
    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
end))

-- ============ NOCLIP ============
table.insert(getgenv().BloodlineConns, RunService.Stepped:Connect(function()
    if not Config.Noclip or not LP.Character then return end
    for _, part in ipairs(LP.Character:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end))

-- ============ INFINITE JUMP ============
table.insert(getgenv().BloodlineConns, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        local _, _, hum = GetChar()
        if hum then pcall(function() hum:ChangeState(Enum.HumanoidStateType.Jumping) end) end
    end
end))

-- ============ BHOP ============
local bhopSpeed = 16
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
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

-- ============ INVIS ============
table.insert(getgenv().BloodlineConns, RunService.Stepped:Connect(function()
    if not Config.Invis or not LP.Character then return end
    for _, part in ipairs(LP.Character:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
            pcall(function() part.Transparency = 1 end)
        end
    end
end))

-- ============ ANTI-AFK ============
table.insert(getgenv().BloodlineConns, LP.Idled:Connect(function()
    if not Config.AntiAFK then return end
    pcall(function()
        R.VirtualUser:CaptureController()
        R.VirtualUser:ClickButton2(Vector2.new())
    end)
end))

-- ============ CLICK TP ============
table.insert(getgenv().BloodlineConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if Config.ClickTP and input.UserInputType == Enum.UserInputType.MouseButton2 then
        pcall(function()
            local mouse = UserInputService:GetMouseLocation()
            local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
            local _, hrp = GetChar()
            if hrp then hrp.CFrame = CFrame.new(ray.Origin + ray.Direction * 50) end
        end)
    end
end))

-- ============ AUTO FARM COINS ============
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
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

-- ============ AUTO WIN ============
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.AutoWin then return end
    local tool = getgenv().BloodlineGetTool()
    if not tool then return end
    local targets = getgenv().BloodlineGetTargets()
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

-- ============ SECOND CHANCE ============
local secondChanceUsed = false
table.insert(getgenv().BloodlineConns, LP.CharacterAdded:Connect(function()
    secondChanceUsed = false
end))
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.SecondChance then return end
    if not LP.Character then return end
    local hum = LP.Character:FindFirstChildOfClass("Humanoid")
    if hum and hum.Health <= 0 and not secondChanceUsed then
        secondChanceUsed = true
        R.Notify("🩸 Second Chance активирован!", 3)
        pcall(function()
            hum.Health = hum.MaxHealth
            local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(0, 100, 0) end
        end)
    end
end))

-- ============ INVIS BIND (G) ============
table.insert(getgenv().BloodlineConns, UserInputService.InputBegan:Connect(function(input, gp)
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

print("✅ [Bloodline] Часть 7/8 — ESP + Движение")
R.Notify("🩸 Загрузка 7/8...", 1)

--[[
    ╔══════════════════════════════════════════╗
    ║         BLOODLINE HUB v1.0               ║
    ║         ЧАСТЬ 8/8: Управление            ║
    ╚══════════════════════════════════════════╝
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-7!") return end

local LP = R.LocalPlayer
local UserInputService = R.UserInputService
local RunService = R.RunService
local TweenService = R.TweenService
local MainFrame = R.MainFrame
local ScreenGui = R.ScreenGui
local CloseBtn = R.CloseBtn
local ToggleBtn = R.ToggleBtn
local ESPObjects = getgenv().BloodlineESP

-- Гарантируем что GUI видим
if MainFrame then
    MainFrame.Visible = true
    MainFrame.Size = UDim2.new(0, 780, 0, 510)
    MainFrame.Position = UDim2.new(0.5, -390, 0.5, -255)
end
if ToggleBtn then ToggleBtn.Visible = false end

-- ============ КНОПКИ УПРАВЛЕНИЯ ============
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    ToggleBtn.Visible = true
end)

ToggleBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    ToggleBtn.Visible = false
end)

-- ============ ХОТКЕИ ============
table.insert(getgenv().BloodlineConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
        ToggleBtn.Visible = not MainFrame.Visible
    end

    if input.KeyCode == Enum.KeyCode.Delete then
        if getgenv().BloodlineStopFly then pcall(getgenv().BloodlineStopFly) end
        for _, objs in pairs(ESPObjects) do
            for _, o in pairs(objs) do pcall(function() o:Remove() end) end
        end
        for _, c in pairs(getgenv().BloodlineConns or {}) do pcall(function() c:Disconnect() end) end
        ScreenGui:Destroy()
        getgenv().BloodlineGui = nil
        getgenv().BloodlineRefs = nil
    end
end))

-- ============ ИНИЦИАЛИЗАЦИЯ ============
if R.SwitchCategory then
    pcall(R.SwitchCategory, 1)
else
    warn("[Bloodline] SwitchCategory не найден")
end

-- Стартовое уведомление
task.spawn(function()
    task.wait(0.5)
    pcall(function()
        R.StarterGui:SetCore("SendNotification", {
            Title = "🩸 BLOODLINE HUB v1.0",
            Text = "✅ Загружен! RightShift — открыть меню",
            Duration = 5
        })
    end)
end)

print([[
╔══════════════════════════════════════════╗
║     🩸 BLOODLINE HUB v1.0 ЗАГРУЖЕН! 🩸   ║
║     ─────────────────────────────        ║
║     RightShift / F1 — меню                ║
║     Delete — выгрузить                    ║
║     G — Invis Bind                        ║
║     RMB — Click TP (если включен)         ║
╚══════════════════════════════════════════╝
]])
R.Notify("🩸 Bloodline Hub v1.0 запущен!", 3)
