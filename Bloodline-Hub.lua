--[[
    ╔══════════════════════════════════════════╗
    ║      BLOODLINE HUB v2.1                  ║
    ║      ЧАСТЬ 1/8: Ядро + GUI               ║
    ╚══════════════════════════════════════════╝
]]

-- Безопасное получение сервисов
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")

-- Ждём LocalPlayer безопасно
local LP
local _t = tick()
while not LP and tick() - _t < 15 do
    LP = Players.LocalPlayer
    if not LP then task.wait(0.1) end
end
if not LP then
    warn("[Bloodline] LocalPlayer не найден за 15 сек")
    return
end

-- Ждём PlayerGui
local PlayerGui
_t = tick()
repeat
    task.wait(0.1)
    PlayerGui = LP:FindFirstChild("PlayerGui")
until PlayerGui or tick() - _t > 10
if not PlayerGui then
    warn("[Bloodline] PlayerGui не найден")
    return
end

-- Чистим старое
if getgenv().BloodlineMenuGui then
    pcall(function() getgenv().BloodlineMenuGui:Destroy() end)
end
for _, c in pairs(getgenv().BloodlineConns or {}) do
    pcall(function() c:Disconnect() end)
end
getgenv().BloodlineConns = {}

-- ============ ПАЛИТРА ============
local COLORS = {
    bg = Color3.fromRGB(12, 8, 12),
    panel = Color3.fromRGB(20, 12, 16),
    card = Color3.fromRGB(28, 18, 22),
    text = Color3.fromRGB(240, 230, 230),
    textDim = Color3.fromRGB(150, 120, 120),
    accent = Color3.fromRGB(200, 20, 40),
    accentLight = Color3.fromRGB(255, 60, 80),
    border = Color3.fromRGB(60, 25, 35),
    toggleOff = Color3.fromRGB(70, 35, 40),
    toggleOn = Color3.fromRGB(220, 40, 60),
}
getgenv().BloodlineColors = COLORS

-- ============ КОНФИГ ============
getgenv().BloodlineConfig = getgenv().BloodlineConfig or {
    SpeedHack = false, SpeedValue = 60,
    JumpPower = false, JumpValue = 120,
    Noclip = false, InfiniteJump = false,
    Fly = false, FlySpeed = 50,
    Spin = false, SpinSpeed = 15,
    AntiAFK = true,
    SilentAim = false, SilentAimFOV = 100,
    KillAura = false, AuraRange = 30,
    KillOnlySheriff = false,
    KnifeAimbot = false,
    ESP = false, RoleESP = true, GunESP = false,
    Tracers = false, HitboxExpander = false, HitboxSize = 5,
    ESPColor = Color3.fromRGB(200, 130, 255),
    ChinaHat = false, ChinaHatColor = Color3.fromRGB(255, 80, 80),
    JumpCircle = false, GunBeam = false,
    GunBeamColor = Color3.fromRGB(200, 130, 255),
    BigHead = false, Fullbright = false,
    TouchFling = false, ClickFling = false,
    FlingAll = false, FlingMurder = false, FlingSheriff = false,
    FakeKorblox = false, FakeHeadless = false,
    AntiFling = true, AntiFlingForce = false,
    AntiCheatDetector = false, AntiRagdoll = false,
    TradeInfo = false, RoleNotifier = false, KillNotifier = false,
    Watermark = true,
}
local Config = getgenv().BloodlineConfig

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BloodlineHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset = true
ScreenGui.DisplayOrder = 999
pcall(function() ScreenGui.Parent = PlayerGui end)
getgenv().BloodlineMenuGui = ScreenGui

-- ===== ГЛАВНОЕ ОКНО =====
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 780, 0, 510)
MainFrame.Position = UDim2.new(0.5, -390, 0.5, -255)
MainFrame.BackgroundColor3 = COLORS.bg
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Visible = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 14)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = COLORS.accent
MainStroke.Thickness = 2
MainStroke.Transparency = 0.3
MainStroke.Parent = MainFrame

-- ===== ВЕРХНЯЯ ПАНЕЛЬ =====
local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
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

-- Кровавая полоса (БЕЗ анимации градиента — статика)
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

-- Простой градиент из 2 точек (безопасно)
local BS_Grad = Instance.new("UIGradient")
BS_Grad.Color = ColorSequence.new(
    Color3.fromRGB(100, 0, 10),
    Color3.fromRGB(255, 40, 60)
)
BS_Grad.Rotation = 0
pcall(function() BS_Grad.Parent = BloodStripe end)

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

-- Название
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

local SubBrand = Instance.new("TextLabel")
SubBrand.Size = UDim2.new(0, 300, 0, 18)
SubBrand.Position = UDim2.new(0, 70, 0, 34)
SubBrand.BackgroundTransparency = 1
SubBrand.Text = "v2.1 • MM2 Hub • 🩸"
SubBrand.TextColor3 = COLORS.textDim
SubBrand.TextSize = 11
SubBrand.Font = Enum.Font.Gotham
SubBrand.TextXAlignment = Enum.TextXAlignment.Left
SubBrand.ZIndex = 4
SubBrand.Parent = TopBar

-- Кнопка закрытия
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

-- ===== САЙДБАР =====
local SideBar = Instance.new("Frame")
SideBar.Name = "SideBar"
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
SideScroll.Name = "SideScroll"
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

-- ===== КОНТЕНТ =====
local ContentFrame = Instance.new("Frame")
ContentFrame.Name = "ContentFrame"
ContentFrame.Size = UDim2.new(1, -200, 1, -90)
ContentFrame.Position = UDim2.new(0, 185, 0, 74)
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

-- ============ БАЗОВЫЕ ССЫЛКИ ============
getgenv().BloodlineBase = {
    ScreenGui = ScreenGui, MainFrame = MainFrame,
    TopBar = TopBar, SideBar = SideBar, SideScroll = SideScroll,
    ContentFrame = ContentFrame, CloseBtn = CloseBtn, Logo = Logo,
    Colors = COLORS, Config = Config,
    LP = LP, Players = Players, RunService = RunService,
    UserInputService = UserInputService, TweenService = TweenService,
    Workspace = Workspace, StarterGui = StarterGui,
}

print("✅ [Bloodline v2.1] Часть 1/8 — Ядро + GUI")

--[[
    BLOODLINE HUB v2.1
    ЧАСТЬ 2/8: Компоненты + Категории
]]

local B = getgenv().BloodlineBase
if not B then warn("❌ Сначала запусти Часть 1!") return end

local TweenService = B.TweenService
local UserInputService = B.UserInputService
local COLORS = B.Colors
local SideScroll = B.SideScroll
local ContentFrame = B.ContentFrame

-- ============ КОМПОНЕНТЫ ============
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

local function CreateToggle(parent, text, default, callback)
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
    Label.Size = UDim2.new(1, -70, 1, 0)
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = text
    Label.TextColor3 = COLORS.text
    Label.TextSize = 13
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 6
    Label.Parent = Frame

    local Bg = Instance.new("Frame")
    Bg.Size = UDim2.new(0, 40, 0, 22)
    Bg.Position = UDim2.new(1, -54, 0.5, -11)
    Bg.BackgroundColor3 = default and COLORS.toggleOn or COLORS.toggleOff
    Bg.BorderSizePixel = 0
    Bg.ZIndex = 6
    Bg.Parent = Frame
    local BC = Instance.new("UICorner")
    BC.CornerRadius = UDim.new(1, 0)
    BC.Parent = Bg

    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 16, 0, 16)
    Ind.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Ind.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Ind.BorderSizePixel = 0
    Ind.ZIndex = 7
    Ind.Parent = Bg
    local IC = Instance.new("UICorner")
    IC.CornerRadius = UDim.new(1, 0)
    IC.Parent = Ind

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 40, 0, 22)
    Btn.Position = UDim2.new(1, -54, 0.5, -11)
    Btn.BackgroundTransparency = 1
    Btn.Text = ""
    Btn.ZIndex = 8
    Btn.Parent = Frame

    local state = default or false
    Btn.MouseButton1Click:Connect(function()
        state = not state
        pcall(function()
            TweenService:Create(Bg, TweenInfo.new(0.2), {
                BackgroundColor3 = state and COLORS.toggleOn or COLORS.toggleOff
            }):Play()
            TweenService:Create(Ind, TweenInfo.new(0.2), {
                Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            }):Play()
        end)
        if callback then pcall(callback, state) end
    end)
    return Frame
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
    Btn.MouseButton1Click:Connect(function()
        if callback then pcall(callback) end
    end)
    return Btn
end

getgenv().BloodlineUI = {
    CreateSection = CreateSection,
    CreateToggle = CreateToggle,
    CreateSlider = CreateSlider,
    CreateButton = CreateButton,
}

-- ============ КАТЕГОРИИ ============
local categories = {
    {name = "Home", icon = "🩸"},
    {name = "General", icon = "⚙"},
    {name = "MM2", icon = "🔫"},
    {name = "Visuals", icon = "👁"},
    {name = "Target", icon = "🎯"},
    {name = "Fun", icon = "🎉"},
    {name = "Emotes", icon = "💃"},
    {name = "Sound", icon = "🎵"},
    {name = "Configs", icon = "💾"},
}

local categoryButtons = {}
local pages = {}

for i, cat in ipairs(categories) do
    local Tab = Instance.new("TextButton")
    Tab.Size = UDim2.new(1, -8, 0, 38)
    Tab.BackgroundColor3 = Color3.fromRGB(30, 18, 22)
    Tab.Text = "  " .. cat.icon .. "   " .. cat.name
    Tab.TextColor3 = COLORS.text
    Tab.TextSize = 13
    Tab.Font = Enum.Font.GothamMedium
    Tab.TextXAlignment = Enum.TextXAlignment.Left
    Tab.AutoButtonColor = false
    Tab.ZIndex = 5
    Tab.Parent = SideScroll
    local TC = Instance.new("UICorner")
    TC.CornerRadius = UDim.new(0, 8)
    TC.Parent = Tab
    table.insert(categoryButtons, Tab)

    local Page = Instance.new("ScrollingFrame")
    Page.Size = UDim2.new(1, -20, 1, -20)
    Page.Position = UDim2.new(0, 10, 0, 10)
    Page.BackgroundTransparency = 1
    Page.BorderSizePixel = 0
    Page.ScrollBarThickness = 3
    Page.ScrollBarImageColor3 = COLORS.accent
    Page.CanvasSize = UDim2.new(0, 0, 0, 0)
    Page.Visible = (i == 1)
    Page.ZIndex = 4
    Page.Parent = ContentFrame

    local L = Instance.new("UIListLayout")
    L.Padding = UDim.new(0, 8)
    L.SortOrder = Enum.SortOrder.LayoutOrder
    L.Parent = Page
    L:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        Page.CanvasSize = UDim2.new(0, 0, 0, L.AbsoluteContentSize.Y + 20)
    end)

    table.insert(pages, Page)
end

local function SwitchCategory(idx)
    for i, tab in ipairs(categoryButtons) do
        pages[i].Visible = (i == idx)
        tab.BackgroundColor3 = (i == idx) and COLORS.accent or Color3.fromRGB(30, 18, 22)
        tab.TextColor3 = (i == idx) and Color3.fromRGB(255, 255, 255) or COLORS.text
    end
end

for i, tab in ipairs(categoryButtons) do
    tab.MouseButton1Click:Connect(function() SwitchCategory(i) end)
    tab.MouseEnter:Connect(function()
        if tab.BackgroundColor3 ~= COLORS.accent then
            pcall(function()
                TweenService:Create(tab, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(50, 22, 30)
                }):Play()
            end)
        end
    end)
    tab.MouseLeave:Connect(function()
        if tab.BackgroundColor3 ~= COLORS.accent then
            pcall(function()
                TweenService:Create(tab, TweenInfo.new(0.15), {
                    BackgroundColor3 = Color3.fromRGB(30, 18, 22)
                }):Play()
            end)
        end
    end)
end

SwitchCategory(1)

-- Объединяем ссылки
getgenv().BloodlineRefs = {
    ScreenGui = B.ScreenGui, MainFrame = B.MainFrame,
    TopBar = B.TopBar, SideBar = B.SideBar, SideScroll = B.SideScroll,
    ContentFrame = B.ContentFrame, CloseBtn = B.CloseBtn,
    Pages = pages, CategoryButtons = categoryButtons,
    SwitchCategory = SwitchCategory,
    Colors = COLORS, Config = B.Config,
    LP = B.LP, Players = B.Players, RunService = B.RunService,
    UserInputService = B.UserInputService, TweenService = B.TweenService,
    Workspace = B.Workspace, StarterGui = B.StarterGui,
}

pcall(function()
    B.StarterGui:SetCore("SendNotification", {
        Title = "🩸 Bloodline v2.1",
        Text = "✅ Меню загружено! RightShift — открыть",
        Duration = 4
    })
end)

print("✅ [Bloodline v2.1] Часть 2/8 — Компоненты + Категории")

--[[
    BLOODLINE HUB v2.1
    ЧАСТЬ 3/8: Home + General + Защита
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-2!") return end

local LP = R.LP
local Players = R.Players
local RunService = R.RunService
local COLORS = R.Colors
local Config = R.Config

local PageHome = R.Pages[1]
local PageGeneral = R.Pages[2]

-- Хелпер: определение роли
local function GetRole(plr)
    if not plr or not plr.Character then return "Innocent" end
    
    local function CheckTool(tool)
        if not tool or not tool:IsA("Tool") then return nil end
        local n = tool.Name:lower()
        if n:find("knife") or n:find("dagger") then return "Murder" end
        if n:find("gun") or n:find("revolver") or n:find("pistol") then return "Sheriff" end
        return nil
    end
    
    for _, tool in ipairs(plr.Character:GetChildren()) do
        local r = CheckTool(tool)
        if r then return r end
    end
    
    local bp = plr:FindFirstChild("Backpack")
    if bp then
        for _, tool in ipairs(bp:GetChildren()) do
            local r = CheckTool(tool)
            if r then return r end
        end
    end
    
    return "Innocent"
end
getgenv().BloodlineGetRole = GetRole

-- HOME
UI.CreateSection(PageHome, "🩸 BLOODLINE HUB v2.1")
UI.CreateSection(PageHome, "💀 MM2 Hub • Made with 🩸")

local StatsFrame = Instance.new("Frame")
StatsFrame.Size = UDim2.new(1, -10, 0, 130)
StatsFrame.BackgroundColor3 = COLORS.card
StatsFrame.BorderSizePixel = 0
StatsFrame.ZIndex = 5
StatsFrame.Parent = PageHome
local StC = Instance.new("UICorner")
StC.CornerRadius = UDim.new(0, 8)
StC.Parent = StatsFrame
local StSt = Instance.new("UIStroke")
StSt.Color = COLORS.border
StSt.Thickness = 1
StSt.Parent = StatsFrame
local StLabel = Instance.new("TextLabel")
StLabel.Size = UDim2.new(1, -20, 1, -16)
StLabel.Position = UDim2.new(0, 12, 0, 8)
StLabel.BackgroundTransparency = 1
StLabel.Text = "Загрузка..."
StLabel.TextColor3 = COLORS.text
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
                "👥 Игроков: %d\n📡 Ping: %d ms\n🎭 Роль: %s\n🩸 Bloodline v2.1",
                #Players:GetPlayers(),
                math.floor(LP:GetNetworkPing() * 1000),
                GetRole(LP)
            )
        end)
        task.wait(1)
    end
end)

UI.CreateSection(PageHome, "⌨ RightShift / F1 — меню")

-- GENERAL
UI.CreateSection(PageGeneral, "⚙ ОБЩИЕ")
UI.CreateToggle(PageGeneral, "Anti-AFK", Config.AntiAFK, function(s) Config.AntiAFK = s end)
UI.CreateToggle(PageGeneral, "Watermark", Config.Watermark, function(s) Config.Watermark = s end)

UI.CreateSection(PageGeneral, "🛡️ ЗАЩИТА ОТ ЧИТЕРОВ")
UI.CreateToggle(PageGeneral, "Anti-Fling (защита от флинга)", Config.AntiFling, function(s) Config.AntiFling = s end)
UI.CreateToggle(PageGeneral, "Anti-Fling Force (откидывать агрессора)", Config.AntiFlingForce, function(s) Config.AntiFlingForce = s end)
UI.CreateToggle(PageGeneral, "Anti-Ragdoll (не падать)", Config.AntiRagdoll, function(s) Config.AntiRagdoll = s end)
UI.CreateToggle(PageGeneral, "Anti-Cheat Detector", Config.AntiCheatDetector, function(s) Config.AntiCheatDetector = s end)

-- Anti-Fling логика
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.AntiFling then return end
    pcall(function()
        local char = LP.Character
        if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        if hrp.Velocity.Magnitude > 150 then
            hrp.Velocity = Vector3.new(0, 0, 0)
        end
    end)
end))

-- Anti-Fling Force
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.AntiFlingForce then return end
    pcall(function()
        local char = LP.Character
        if not char then return end
        local myHrp = char:FindFirstChild("HumanoidRootPart")
        if not myHrp then return end
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LP and plr.Character then
                local theirHrp = plr.Character:FindFirstChild("HumanoidRootPart")
                if theirHrp and (myHrp.Position - theirHrp.Position).Magnitude < 5 then
                    if theirHrp.Velocity.Magnitude > 100 then
                        theirHrp.Velocity = (theirHrp.Position - myHrp.Position).Unit * 500 + Vector3.new(0, 200, 0)
                    end
                end
            end
        end
    end)
end))

-- Anti-Ragdoll
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.AntiRagdoll then return end
    pcall(function()
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
            hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        end
    end)
end))

-- Anti-Cheat Detector
task.spawn(function()
    while task.wait(1) do
        pcall(function()
            if not Config.AntiCheatDetector then return end
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hum and hrp then
                        if hum.WalkSpeed > 100 or hum.JumpPower > 200 or hrp.Velocity.Magnitude > 300 then
                            R.StarterGui:SetCore("SendNotification", {
                                Title = "🚨 ANTI-CHEAT",
                                Text = plr.Name .. " подозрительный!",
                                Duration = 3
                            })
                        end
                    end
                end
            end
        end)
    end
end)

-- Anti-AFK
table.insert(getgenv().BloodlineConns, LP.Idled:Connect(function()
    if not Config.AntiAFK then return end
    pcall(function()
        local vu = game:GetService("VirtualUser")
        vu:CaptureController()
        vu:ClickButton2(Vector2.new())
    end)
end))

print("✅ [Bloodline v2.1] Часть 3/8 — Home + General + Защита")

--[[
    BLOODLINE HUB v2.1
    ЧАСТЬ 4/8: MM2 (Движение + Combat)
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-3!") return end

local LP = R.LP
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = Workspace.CurrentCamera
local COLORS = R.Colors
local Config = R.Config

local PageMM2 = R.Pages[3]
local GetRole = getgenv().BloodlineGetRole

-- ============ ФУНКЦИИ ============
local function UpdateSpeed()
    pcall(function()
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = Config.SpeedHack and Config.SpeedValue or 16 end
    end)
end

local function UpdateJump()
    pcall(function()
        local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = Config.JumpPower and Config.JumpValue or 50
        end
    end)
end

-- Fly
local flyActive = false
local flyBV, flyBG = nil, nil

local function StopFly()
    flyActive = false
    if flyBV then pcall(function() flyBV:Destroy() end); flyBV = nil end
    if flyBG then pcall(function() flyBG:Destroy() end); flyBG = nil end
    local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if hum then pcall(function() hum.PlatformStand = false end) end
end

local function StartFly()
    StopFly()
    local char = LP.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChildOfClass("Humanoid")
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

    table.insert(getgenv().BloodlineConns, RunService.RenderStepped:Connect(function()
        if not flyActive or not Config.Fly then StopFly(); return end
        local c = LP.Character
        if not c then StopFly(); return end
        local h = c:FindFirstChild("HumanoidRootPart")
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
        flyBV.Velocity = dir
        flyBG.CFrame = cam.CFrame
    end))
end

getgenv().BloodlineStopFly = StopFly
getgenv().BloodlineStartFly = StartFly

-- Noclip / Infinite Jump / Spin / респавн
table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.Noclip then return end
    local char = LP.Character
    if not char then return end
    pcall(function()
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end)
end))

table.insert(getgenv().BloodlineConns, UserInputService.JumpRequest:Connect(function()
    if Config.InfiniteJump then
        pcall(function()
            local hum = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
    end
end))

local spinAngle = 0
table.insert(getgenv().BloodlineConns, RunService.RenderStepped:Connect(function(dt)
    if not Config.Spin then return end
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    spinAngle = spinAngle + Config.SpinSpeed * dt
    hrp.CFrame = CFrame.new(hrp.Position) * CFrame.Angles(0, spinAngle, 0)
end))

table.insert(getgenv().BloodlineConns, LP.CharacterAdded:Connect(function()
    task.wait(0.5)
    UpdateSpeed(); UpdateJump()
end))

-- Combat
local function GetEquippedTool()
    local char = LP.Character
    if not char then return nil end
    for _, c in ipairs(char:GetChildren()) do
        if c:IsA("Tool") then return c end
    end
end

local function GetTargets(filter)
    local targets = {}
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
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
getgenv().BloodlineGetTool = GetEquippedTool

table.insert(getgenv().BloodlineConns, RunService.RenderStepped:Connect(function()
    if not Config.SilentAim then return end
    pcall(function()
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
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, best.hrp.Position)
        end
    end)
end))

table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.KillAura then return end
    pcall(function()
        local tool = GetEquippedTool()
        if not tool then return end
        local targets = GetTargets(function(p)
            if Config.KillOnlySheriff then return GetRole(p) == "Sheriff" end
            return true
        end)
        for _, t in ipairs(targets) do
            if t.dist <= Config.AuraRange then
                tool:Activate()
                task.wait(0.05)
            end
        end
    end)
end))

table.insert(getgenv().BloodlineConns, RunService.Heartbeat:Connect(function()
    if not Config.KnifeAimbot then return end
    pcall(function()
        local tool = GetEquippedTool()
        if not tool or not tool.Name:lower():find("knife") then return end
        local targets = GetTargets()
        if #targets == 0 then return end
        local t = targets[1]
        local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
        if myHrp then
            myHrp.CFrame = CFrame.new(t.hrp.Position + (t.hrp.CFrame.LookVector * 3), t.hrp.Position)
            tool:Activate()
        end
    end)
end))

-- UI
UI.CreateSection(PageMM2, "⚡ СКОРОСТЬ")
UI.CreateToggle(PageMM2, "Speed Hack", Config.SpeedHack, function(s) Config.SpeedHack = s; UpdateSpeed() end)
UI.CreateSlider(PageMM2, "Скорость", 16, 250, Config.SpeedValue, function(v) Config.SpeedValue = v; UpdateSpeed() end)

UI.CreateSection(PageMM2, "🦘 ПРЫЖОК")
UI.CreateToggle(PageMM2, "Jump Power", Config.JumpPower, function(s) Config.JumpPower = s; UpdateJump() end)
UI.CreateSlider(PageMM2, "Сила прыжка", 50, 500, Config.JumpValue, function(v) Config.JumpValue = v; UpdateJump() end)
UI.CreateToggle(PageMM2, "Infinite Jump", Config.InfiniteJump, function(s) Config.InfiniteJump = s end)

UI.CreateSection(PageMM2, "🏃 ДВИЖЕНИЕ")
UI.CreateToggle(PageMM2, "Noclip", Config.Noclip, function(s) Config.Noclip = s end)
UI.CreateToggle(PageMM2, "Fly", Config.Fly, function(s)
    Config.Fly = s
    if s then StartFly() else StopFly() end
end)
UI.CreateSlider(PageMM2, "Скорость полёта", 10, 300, Config.FlySpeed, function(v) Config.FlySpeed = v end)
UI.CreateToggle(PageMM2, "Spin", Config.Spin, function(s) Config.Spin = s end)
UI.CreateSlider(PageMM2, "Скорость Spin", 1, 60, Config.SpinSpeed, function(v) Config.SpinSpeed = v end)

UI.CreateSection(PageMM2, "🎯 SILENT AIM")
UI.CreateToggle(PageMM2, "Silent Aim", Config.SilentAim, function(s) Config.SilentAim = s end)
UI.CreateSlider(PageMM2, "Silent Aim FOV", 10, 500, Config.SilentAimFOV, function(v) Config.SilentAimFOV = v end)

UI.CreateSection(PageMM2, "🔪 KILL AURA")
UI.CreateToggle(PageMM2, "Kill Aura", Config.KillAura, function(s) Config.KillAura = s end)
UI.CreateSlider(PageMM2, "Kill Aura Radius", 5, 100, Config.AuraRange, function(v) Config.AuraRange = v end)
UI.CreateToggle(PageMM2, "Kill Only Sheriff", Config.KillOnlySheriff, function(s) Config.KillOnlySheriff = s end)

UI.CreateSection(PageMM2, "🗡 KNIFE AIMBOT")
UI.CreateToggle(PageMM2, "Knife Aimbot", Config.KnifeAimbot, function(s) Config.KnifeAimbot = s end)

print("✅ [Bloodline v2.1] Часть 4/8 — MM2")

--[[
    BLOODLINE HUB v2.1
    ЧАСТЬ 5/8: Visuals
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-4!") return end

local LP = R.LP
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = Workspace.CurrentCamera
local TweenService = R.TweenService
local Lighting = game:GetService("Lighting")
local COLORS = R.Colors
local Config = R.Config

local PageVisuals = R.Pages[4]
local GetRole = getgenv().BloodlineGetRole

-- Проверка Drawing
local HAS_DRAWING = false
pcall(function()
    if Drawing and Drawing.new then
        local t = Drawing.new("Text")
        if t then t:Remove(); HAS_DRAWING = true end
    end
end)
getgenv().BloodlineNoDrawing = (not HAS_DRAWING)

-- ESP
local ESPObjects = getgenv().BloodlineESP or {}
getgenv().BloodlineESP = ESPObjects

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
        DistanceTag.Color = COLORS.accent; DistanceTag.Visible = false
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

-- China Hat
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
                    else
                        if chinaHats[plr] then pcall(function() chinaHats[plr]:Destroy() end); chinaHats[plr] = nil end
                    end
                end
            end
        end
    end)
end))

-- Jump Circle
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
                    circle.Color = COLORS.accent
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

-- Gun Beam
local beamFolder = Workspace:FindFirstChild("BloodlineBeams")
if not beamFolder then
    beamFolder = Instance.new("Folder")
    beamFolder.Name = "BloodlineBeams"
    beamFolder.Parent = Workspace
end

local function HookTools(char)
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            table.insert(getgenv().BloodlineConns, tool.Activated:Connect(function()
                if not Config.GunBeam then return end
                pcall(function()
                    local handle = tool:FindFirstChild("Handle")
                    if not handle then return end
                    local mouse = UserInputService:GetMouseLocation()
                    local ray = Camera:ViewportPointToRay(mouse.X, mouse.Y)
                    local dist = 500
                    local part = Instance.new("Part")
                    part.Size = Vector3.new(0.15, 0.15, dist)
                    part.CFrame = CFrame.new(handle.Position, ray.Origin + ray.Direction * dist) * CFrame.new(0, 0, -dist / 2)
                    part.Anchored = true
                    part.CanCollide = false
                    part.Material = Enum.Material.Neon
                    part.Color = Config.GunBeamColor
                    part.Transparency = 0.15
                    part.Parent = beamFolder
                    TweenService:Create(part, TweenInfo.new(0.5), {Transparency = 1}):Play()
                    task.delay(0.6, function() pcall(function() part:Destroy() end) end)
                end)
            end))
        end
    end
end
HookTools(LP.Character)
table.insert(getgenv().BloodlineConns, LP.CharacterAdded:Connect(function(c)
    task.wait(0.5); HookTools(c)
end))

-- Hitbox Expander
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

-- UI
UI.CreateSection(PageVisuals, "👁️ ESP")
UI.CreateToggle(PageVisuals, "ESP игроков", Config.ESP, function(s) Config.ESP = s end)
UI.CreateToggle(PageVisuals, "Role ESP", Config.RoleESP, function(s) Config.RoleESP = s end)
UI.CreateToggle(PageVisuals, "Gun ESP", Config.GunESP, function(s) Config.GunESP = s end)
UI.CreateToggle(PageVisuals, "Tracers", Config.Tracers, function(s) Config.Tracers = s end)
UI.CreateToggle(PageVisuals, "Hitbox Expander", Config.HitboxExpander, function(s) Config.HitboxExpander = s end)
UI.CreateSlider(PageVisuals, "Hitbox Size", 2, 20, Config.HitboxSize, function(v) Config.HitboxSize = v end)

UI.CreateSection(PageVisuals, "🎩 КОСМЕТИКА")
UI.CreateToggle(PageVisuals, "China Hat", Config.ChinaHat, function(s) Config.ChinaHat = s end)
UI.CreateToggle(PageVisuals, "Jump Circle", Config.JumpCircle, function(s) Config.JumpCircle = s end)
UI.CreateToggle(PageVisuals, "Gun Beam", Config.GunBeam, function(s) Config.GunBeam = s end)
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

UI.CreateSection(PageVisuals, "🌞 ОСВЕЩЕНИЕ")
UI.CreateToggle(PageVisuals, "Fullbright", Config.Fullbright, function(s)
    Config.Fullbright = s
    pcall(function()
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
end)

print("✅ [Bloodline v2.1] Часть 5/8 — Visuals")

--[[
    BLOODLINE HUB v2.1
    ЧАСТЬ 6/8: Target + Fun
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-5!") return end

local LP = R.LP
local Players = R.Players
local RunService = R.RunService
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local Camera = Workspace.CurrentCamera
local COLORS = R.Colors
local Config = R.Config

local PageTarget = R.Pages[5]
local PageFun = R.Pages[6]
local GetRole = getgenv().BloodlineGetRole
local GetTargets = getgenv().BloodlineGetTargets

-- TARGET
UI.CreateSection(PageTarget, "🎯 ТЕЛЕПОРТ")

local playerList = {}
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LP then table.insert(playerList, p.Name) end
end
if #playerList == 0 then playerList = {"—"} end
local selectedPlayer = playerList[1]

local PSFrame = Instance.new("Frame")
PSFrame.Size = UDim2.new(1, -10, 0, 42)
PSFrame.BackgroundColor3 = COLORS.card
PSFrame.BorderSizePixel = 0
PSFrame.ZIndex = 5
PSFrame.Parent = PageTarget
local PSC = Instance.new("UICorner")
PSC.CornerRadius = UDim.new(0, 8)
PSC.Parent = PSFrame
local PSStroke = Instance.new("UIStroke")
PSStroke.Color = COLORS.border
PSStroke.Thickness = 1
PSStroke.Parent = PSFrame

local PSBtn = Instance.new("TextButton")
PSBtn.Size = UDim2.new(1, -20, 1, -8)
PSBtn.Position = UDim2.new(0, 10, 0, 4)
PSBtn.BackgroundTransparency = 1
PSBtn.Text = "🎯 Цель: " .. selectedPlayer
PSBtn.TextColor3 = COLORS.text
PSBtn.TextSize = 13
PSBtn.Font = Enum.Font.GothamBold
PSBtn.ZIndex = 6
PSBtn.Parent = PSFrame

PSBtn.MouseButton1Click:Connect(function()
    local all = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(all, p.Name) end
    end
    if #all == 0 then return end
    for i, n in ipairs(all) do
        if n == selectedPlayer then
            selectedPlayer = all[i % #all + 1]
            break
        end
    end
    PSBtn.Text = "🎯 Цель: " .. selectedPlayer
end)

UI.CreateButton(PageTarget, "🎯 TP к цели", COLORS.accent, function()
    local target = Players:FindFirstChild(selectedPlayer)
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and myHrp then
        myHrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 3)
    end
end)

UI.CreateButton(PageTarget, "🔪 TP к Murder", Color3.fromRGB(220, 60, 60), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Murder" end)
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myHrp and #targets > 0 then
        myHrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
    end
end)

UI.CreateButton(PageTarget, "🚔 TP к Sheriff", Color3.fromRGB(80, 130, 220), function()
    local targets = GetTargets(function(p) return GetRole(p) == "Sheriff" end)
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if myHrp and #targets > 0 then
        myHrp.CFrame = targets[1].hrp.CFrame * CFrame.new(0, 0, 3)
    end
end)

UI.CreateButton(PageTarget, "🏠 TP в Lobby", Color3.fromRGB(100, 180, 100), function()
    local lobby = Workspace:FindFirstChild("Lobby") or Workspace:FindFirstChild("LobbySpawn")
    local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if lobby and myHrp then
        myHrp.CFrame = CFrame.new((lobby.Position or Vector3.new(0, 100, 0)) + Vector3.new(0, 5, 0))
    end
end)

-- FUN
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
    if Config.FlingAll then
        pcall(function()
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LP and plr.Character then
                    local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then ApplyFling(hrp, 500) end
                end
            end
        end)
    end
    if Config.FlingMurder then
        pcall(function()
            for _, t in ipairs(GetTargets(function(p) return GetRole(p) == "Murder" end)) do
                ApplyFling(t.hrp, 500)
            end
        end)
    end
    if Config.FlingSheriff then
        pcall(function()
            for _, t in ipairs(GetTargets(function(p) return GetRole(p) == "Sheriff" end)) do
                ApplyFling(t.hrp, 500)
            end
        end)
    end
    if Config.TouchFling then
        pcall(function()
            local myHrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
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
    end
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

print("✅ [Bloodline v2.1] Часть 6/8 — Target + Fun")

--[[
    BLOODLINE HUB v2.1
    ЧАСТЬ 7/8: Emotes + Sound
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-6!") return end

local LP = R.LP
local UserInputService = R.UserInputService
local Workspace = R.Workspace
local COLORS = R.Colors

local PageEmotes = R.Pages[7]
local PageSound = R.Pages[8]

-- EMOTES
UI.CreateSection(PageEmotes, "💃 АНИМАЦИИ")

local function DoEmote(name)
    pcall(function()
        local char = LP.Character
        if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if not hum or not hrp then return end

        if name == "dance" then
            for i = 1, 8 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(15)); task.wait(0.1)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(-30)); task.wait(0.1)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(15)); task.wait(0.1)
            end
        elseif name == "spin" then
            for i = 1, 20 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(30), 0); task.wait(0.05)
            end
        elseif name == "sit" then
            pcall(function() hum:ChangeState(Enum.HumanoidStateType.Sit) end)
        elseif name == "flip" then
            for i = 1, 20 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(math.rad(18), 0, 0); task.wait(0.03)
            end
        elseif name == "wave" then
            for i = 1, 3 do
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(10)); task.wait(0.15)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(-20)); task.wait(0.15)
                hrp.CFrame = hrp.CFrame * CFrame.Angles(0, 0, math.rad(10)); task.wait(0.15)
            end
        end
    end)
end

UI.CreateButton(PageEmotes, "💃 Танец", COLORS.accent, function() DoEmote("dance") end)
UI.CreateButton(PageEmotes, "🌀 Spin", COLORS.accent, function() DoEmote("spin") end)
UI.CreateButton(PageEmotes, "🪑 Сидеть", COLORS.accent, function() DoEmote("sit") end)
UI.CreateButton(PageEmotes, "🤸 Сальто", COLORS.accent, function() DoEmote("flip") end)
UI.CreateButton(PageEmotes, "👋 Махнуть", COLORS.accent, function() DoEmote("wave") end)

-- SOUND PLAYER
UI.CreateSection(PageSound, "🎵 МУЗЫКА")

local PlayerFrame = Instance.new("Frame")
PlayerFrame.Size = UDim2.new(1, -10, 0, 130)
PlayerFrame.BackgroundColor3 = COLORS.card
PlayerFrame.BorderSizePixel = 0
PlayerFrame.ZIndex = 5
PlayerFrame.Parent = PageSound
local PFC = Instance.new("UICorner")
PFC.CornerRadius = UDim.new(0, 8)
PFC.Parent = PlayerFrame
local PFStroke = Instance.new("UIStroke")
PFStroke.Color = COLORS.border
PFStroke.Thickness = 1
PFStroke.Parent = PlayerFrame

local InputFrame = Instance.new("Frame")
InputFrame.Size = UDim2.new(1, -24, 0, 36)
InputFrame.Position = UDim2.new(0, 12, 0, 12)
InputFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 16)
InputFrame.BorderSizePixel = 0
InputFrame.ZIndex = 6
InputFrame.Parent = PlayerFrame
local IFC = Instance.new("UICorner")
IFC.CornerRadius = UDim.new(0, 8)
IFC.Parent = InputFrame
local IFStroke = Instance.new("UIStroke")
IFStroke.Color = COLORS.border
IFStroke.Thickness = 1
IFStroke.Parent = InputFrame

local MusicInput = Instance.new("TextBox")
MusicInput.Size = UDim2.new(1, -24, 1, -8)
MusicInput.Position = UDim2.new(0, 12, 0, 4)
MusicInput.BackgroundTransparency = 1
MusicInput.Text = ""
MusicInput.PlaceholderText = "ID музыки (например: 1837879082)"
MusicInput.PlaceholderColor3 = COLORS.textDim
MusicInput.TextColor3 = COLORS.text
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
    return "rbxassetid://" .. input
end

local function PlayMusic()
    local id = NormalizeId(MusicInput.Text)
    if not id then return end
    pcall(function()
        if musicInstance then musicInstance:Destroy() end
        musicInstance = Instance.new("Sound")
        musicInstance.SoundId = id
        musicInstance.Volume = 0.5
        musicInstance.Looped = true
        musicInstance.Parent = musicFolder
        musicInstance:Play()
    end)
end

local BtnRow = Instance.new("Frame")
BtnRow.Size = UDim2.new(1, -24, 0, 36)
BtnRow.Position = UDim2.new(0, 12, 0, 58)
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

MakeSmallBtn("▶ Play", Color3.fromRGB(80, 180, 100), PlayMusic)
MakeSmallBtn("⏸ Pause", Color3.fromRGB(200, 160, 60), function()
    if musicInstance then pcall(function() musicInstance:Pause() end) end
end)
MakeSmallBtn("⏹ Stop", Color3.fromRGB(220, 60, 60), function()
    if musicInstance then pcall(function() musicInstance:Stop(); musicInstance:Destroy() end); musicInstance = nil end
end)

-- Volume слайдер
local VolLabel = Instance.new("TextLabel")
VolLabel.Size = UDim2.new(0, 90, 0, 20)
VolLabel.Position = UDim2.new(0, 12, 0, 100)
VolLabel.BackgroundTransparency = 1
VolLabel.Text = "🔊 Громкость"
VolLabel.TextColor3 = COLORS.text
VolLabel.TextSize = 12
VolLabel.Font = Enum.Font.GothamMedium
VolLabel.TextXAlignment = Enum.TextXAlignment.Left
VolLabel.ZIndex = 6
VolLabel.Parent = PlayerFrame

local VolBar = Instance.new("Frame")
VolBar.Size = UDim2.new(0, 200, 0, 8)
VolBar.Position = UDim2.new(0, 100, 0, 106)
VolBar.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
VolBar.BorderSizePixel = 0
VolBar.ZIndex = 6
VolBar.Parent = PlayerFrame
local VBC = Instance.new("UICorner")
VBC.CornerRadius = UDim.new(1, 0)
VBC.Parent = VolBar

local VolFill = Instance.new("Frame")
VolFill.Size = UDim2.new(0.5, 0, 1, 0)
VolFill.BackgroundColor3 = COLORS.accent
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
        if musicInstance then pcall(function() musicInstance.Volume = rel end) end
    end
end)

-- Пресеты
UI.CreateSection(PageSound, "🎼 БЫСТРЫЕ ТРЕКИ")
UI.CreateButton(PageSound, "🩸 Lofi", COLORS.accent, function()
    MusicInput.Text = "1837879082"; PlayMusic()
end)
UI.CreateButton(PageSound, "🩸 Phonk", COLORS.accent, function()
    MusicInput.Text = "1838457666"; PlayMusic()
end)
UI.CreateButton(PageSound, "🩸 Anime OP", COLORS.accent, function()
    MusicInput.Text = "1836248630"; PlayMusic()
end)

print("✅ [Bloodline v2.1] Часть 7/8 — Emotes + Sound")

--[[
    BLOODLINE HUB v2.1
    ЧАСТЬ 8/8: Configs + Управление
]]

local R = getgenv().BloodlineRefs
local UI = getgenv().BloodlineUI
if not R or not UI then warn("❌ Запусти Части 1-7!") return end

local LP = R.LP
local UserInputService = R.UserInputService
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local COLORS = R.Colors
local Config = R.Config
local MainFrame = R.MainFrame
local ScreenGui = R.ScreenGui
local CloseBtn = R.CloseBtn
local PageConfigs = R.Pages[9]
local ESPObjects = getgenv().BloodlineESP or {}

local HAS_FILE_API = false
pcall(function()
    HAS_FILE_API = (typeof(writefile) == "function" and typeof(readfile) == "function")
end)

-- ФОНЫ
UI.CreateSection(PageConfigs, "🖼 ФОНЫ")

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

local BgImage = Instance.new("ImageLabel")
BgImage.Size = UDim2.new(1, -20, 1, -20)
BgImage.Position = UDim2.new(0, 10, 0, 10)
BgImage.BackgroundTransparency = 1
BgImage.Image = ""
BgImage.ImageTransparency = 0.8
BgImage.ScaleType = Enum.ScaleType.Crop
BgImage.ZIndex = 2
BgImage.Visible = false
BgImage.Parent = MainFrame
local BgCorner = Instance.new("UICorner")
BgCorner.CornerRadius = UDim.new(0, 14)
BgCorner.Parent = BgImage

local function SetBg(assetId)
    pcall(function()
        if assetId and assetId ~= "" then
            BgImage.Image = assetId
            BgImage.Visible = true
        else
            BgImage.Visible = false
        end
    end)
end

for _, bg in ipairs(BACKGROUNDS) do
    UI.CreateButton(PageConfigs, "🖼 " .. bg.name, Color3.fromRGB(60, 25, 40), function()
        if bg.id ~= "" then SetBg(bg.id) end
    end)
end

local BgInputFrame = Instance.new("Frame")
BgInputFrame.Size = UDim2.new(1, -10, 0, 42)
BgInputFrame.BackgroundColor3 = COLORS.card
BgInputFrame.BorderSizePixel = 0
BgInputFrame.ZIndex = 5
BgInputFrame.Parent = PageConfigs
local BgIC = Instance.new("UICorner")
BgIC.CornerRadius = UDim.new(0, 8)
BgIC.Parent = BgInputFrame
local BgIStroke = Instance.new("UIStroke")
BgIStroke.Color = COLORS.border
BgIStroke.Thickness = 1
BgIStroke.Parent = BgInputFrame

local BgInput = Instance.new("TextBox")
BgInput.Size = UDim2.new(1, -20, 1, -8)
BgInput.Position = UDim2.new(0, 10, 0, 4)
BgInput.BackgroundTransparency = 1
BgInput.Text = ""
BgInput.PlaceholderText = "ID фона (rbxassetid://...)"
BgInput.PlaceholderColor3 = COLORS.textDim
BgInput.TextColor3 = COLORS.text
BgInput.TextSize = 13
BgInput.Font = Enum.Font.GothamMedium
BgInput.TextXAlignment = Enum.TextXAlignment.Left
BgInput.ClearTextOnFocus = false
BgInput.ZIndex = 6
BgInput.Parent = BgInputFrame

BgInput.FocusLost:Connect(function()
    if BgInput.Text ~= "" then SetBg(BgInput.Text) end
end)

UI.CreateButton(PageConfigs, "❌ Убрать фон", Color3.fromRGB(80, 30, 40), function()
    SetBg("")
end)

-- СОХРАНЕНИЕ
UI.CreateSection(PageConfigs, "💾 КОНФИГИ")

local configName = "bloodline_config"
local ConfigInputFrame = Instance.new("Frame")
ConfigInputFrame.Size = UDim2.new(1, -10, 0, 42)
ConfigInputFrame.BackgroundColor3 = COLORS.card
ConfigInputFrame.BorderSizePixel = 0
ConfigInputFrame.ZIndex = 5
ConfigInputFrame.Parent = PageConfigs
local CIC = Instance.new("UICorner")
CIC.CornerRadius = UDim.new(0, 8)
CIC.Parent = ConfigInputFrame
local CIStroke = Instance.new("UIStroke")
CIStroke.Color = COLORS.border
CIStroke.Thickness = 1
CIStroke.Parent = ConfigInputFrame

local ConfigInput = Instance.new("TextBox")
ConfigInput.Size = UDim2.new(1, -20, 1, -8)
ConfigInput.Position = UDim2.new(0, 10, 0, 4)
ConfigInput.BackgroundTransparency = 1
ConfigInput.Text = configName
ConfigInput.PlaceholderColor3 = COLORS.textDim
ConfigInput.TextColor3 = COLORS.text
ConfigInput.TextSize = 13
ConfigInput.Font = Enum.Font.GothamMedium
ConfigInput.TextXAlignment = Enum.TextXAlignment.Left
ConfigInput.ClearTextOnFocus = false
ConfigInput.ZIndex = 6
ConfigInput.Parent = ConfigInputFrame

ConfigInput.FocusLost:Connect(function()
    configName = ConfigInput.Text
end)

UI.CreateButton(PageConfigs, "💾 Сохранить", Color3.fromRGB(80, 180, 100), function()
    pcall(function()
        if not HAS_FILE_API then return end
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
        writefile(path, HttpService:JSONEncode(data))
    end)
end)

UI.CreateButton(PageConfigs, "📥 Загрузить", COLORS.accent, function()
    pcall(function()
        if not HAS_FILE_API then return end
        local path = "BloodlineHub/" .. configName .. ".json"
        if isfile and isfile(path) then
            local data = HttpService:JSONDecode(readfile(path))
            for k, v in pairs(data) do
                if type(v) == "table" and v.__color then
                    Config[k] = Color3.fromRGB(v.r * 255, v.g * 255, v.b * 255)
                else
                    Config[k] = v
                end
            end
        end
    end)
end)

-- ДЕЙСТВИЯ
UI.CreateSection(PageConfigs, "🔧 ДЕЙСТВИЯ")
UI.CreateButton(PageConfigs, "🔄 Rejoin сервер", COLORS.accent, function()
    pcall(function() TeleportService:Teleport(game.PlaceId, LP) end)
end)

UI.CreateButton(PageConfigs, "🛑 Выгрузить Hub", Color3.fromRGB(220, 60, 60), function()
    pcall(function()
        if getgenv().BloodlineStopFly then pcall(getgenv().BloodlineStopFly) end
        for _, objs in pairs(ESPObjects) do
            for _, o in pairs(objs) do pcall(function() o:Remove() end) end
        end
        for _, c in pairs(getgenv().BloodlineConns or {}) do pcall(function() c:Disconnect() end) end
        ScreenGui:Destroy()
        getgenv().BloodlineMenuGui = nil
        getgenv().BloodlineRefs = nil
        getgenv().BloodlineBase = nil
    end)
end)

-- УПРАВЛЕНИЕ
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

table.insert(getgenv().BloodlineConns, UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.RightShift or input.KeyCode == Enum.KeyCode.F1 then
        MainFrame.Visible = not MainFrame.Visible
    end
    if input.KeyCode == Enum.KeyCode.Delete then
        pcall(function()
            if getgenv().BloodlineStopFly then pcall(getgenv().BloodlineStopFly) end
            for _, objs in pairs(ESPObjects) do
                for _, o in pairs(objs) do pcall(function() o:Remove() end) end
            end
            for _, c in pairs(getgenv().BloodlineConns or {}) do pcall(function() c:Disconnect() end) end
            ScreenGui:Destroy()
            getgenv().BloodlineMenuGui = nil
            getgenv().BloodlineRefs = nil
        end)
    end
end))

-- ИНИЦИАЛИЗАЦИЯ
if R.SwitchCategory then pcall(R.SwitchCategory, 1) end

task.spawn(function()
    task.wait(0.5)
    pcall(function()
        R.StarterGui:SetCore("SendNotification", {
            Title = "🩸 BLOODLINE HUB v2.1",
            Text = "✅ Загружен! RightShift — меню",
            Duration = 5
        })
    end)
end)

print([[
╔══════════════════════════════════════════╗
║   🩸 BLOODLINE HUB v2.1 ЗАГРУЖЕН! 🩸    ║
║   RightShift / F1 — открыть/закрыть      ║
║   Delete — выгрузить                     ║
╚══════════════════════════════════════════╝
]])
