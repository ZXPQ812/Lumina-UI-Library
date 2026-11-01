--[[
    ██████╗ ███╗   ██╗██╗   ██╗██╗  ██╗
   ██╔═══██╗████╗  ██║╚██╗ ██╔╝╚██╗██╔╝
   ██║   ██║██╔██╗ ██║ ╚████╔╝  ╚███╔╝
   ██║   ██║██║╚██╗██║  ╚██╔╝   ██╔██╗
   ╚██████╔╝██║ ╚████║   ██║   ██╔╝ ██╗
    ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝
    UI Library v2.1 — Self-Contained
    Paste directly into executor. No loadstring needed.
    Lucide icon names → Roblox-compatible unicode map
--]]

local ONYX = {}
ONYX.__index = ONYX

-- ─── Services ────────────────────────────────────────────────────────────────
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ─── Lucide Icon Map (unicode approximations) ─────────────────────────────────
-- Use these names in Tab.Icon or element opts.Icon
ONYX.Icons = {
    -- Layout
    LayoutDashboard = "⊞",  Home = "⌂",  Layers = "≡",
    Grid = "⊟",             Menu = "☰",  Sidebar = "▐",
    -- User / Social
    User = "◉",  Users = "◎",  UserCheck = "◈",
    UserX = "⊗", Shield = "⬡", Lock = "⊕",
    -- Actions
    Zap = "⌁",       Play = "▶",   Pause = "⏸",
    RefreshCw = "↺",  Trash = "⊘",  Plus = "⊕",
    Minus = "⊖",      X = "✕",      Check = "✓",
    ChevronDown = "⌄", ChevronRight = "›", ChevronLeft = "‹",
    -- Tools / Features
    Target = "◎",   Eye = "◈",     EyeOff = "⊗",
    Settings = "⚙", Sliders = "⊟", ToggleLeft = "⊂",
    Crosshair = "⊕", Swords = "✦",  Flame = "◆",
    -- Misc
    Bell = "◆",  Star = "★",  Heart = "♥",  Sparkles = "✦",
    Info = "ℹ",  AlertTriangle = "⚠", CheckCircle = "✓",
    Gamepad2 = "⊞", Cpu = "◈",  Globe = "⊙",
    -- Fallback
    Default = "◆",
}

function ONYX:Icon(name)
    return self.Icons[name] or self.Icons.Default
end

-- ─── Theme ───────────────────────────────────────────────────────────────────
local T = {
    BG          = Color3.fromRGB(7,   7,   7),
    S1          = Color3.fromRGB(11,  11,  11),
    S2          = Color3.fromRGB(15,  15,  15),
    S3          = Color3.fromRGB(20,  20,  20),
    B1          = Color3.fromRGB(26,  26,  26),
    B2          = Color3.fromRGB(34,  34,  34),
    B3          = Color3.fromRGB(44,  44,  44),
    White       = Color3.new(1, 1, 1),
    Black       = Color3.new(0, 0, 0),
    Text        = Color3.fromRGB(225, 225, 225),
    TextSub     = Color3.fromRGB(110, 110, 110),
    TextMuted   = Color3.fromRGB(50,  50,  50),
    Danger      = Color3.fromRGB(185, 65,  65),
    DangerBG    = Color3.fromRGB(18,  6,   6),
    DangerBrd   = Color3.fromRGB(38,  14,  14),
    Success     = Color3.fromRGB(70,  185, 100),
    SuccessBG   = Color3.fromRGB(6,   18,  10),
}

-- ─── Helpers ─────────────────────────────────────────────────────────────────
local function Tw(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18,
            style or Enum.EasingStyle.Quart,
            dir   or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function Spring(obj, props, t)
    if not obj or not obj.Parent then return end
    TweenService:Create(obj,
        TweenInfo.new(t or 0.26, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function N(class, props, parent)
    local ok, obj = pcall(Instance.new, class)
    if not ok then return nil end
    for k, v in pairs(props) do
        pcall(function() obj[k] = v end)
    end
    if parent then obj.Parent = parent end
    return obj
end

local function Corner(r, p)
    if not p then return end
    N("UICorner", {CornerRadius = UDim.new(0, r)}, p)
end

local function Pad(t, r, b, l, p)
    if not p then return end
    N("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
    }, p)
end

local function List(dir, gap, p, valign, halign)
    if not p then return end
    local l = N("UIListLayout", {
        FillDirection = dir or Enum.FillDirection.Vertical,
        SortOrder     = Enum.SortOrder.LayoutOrder,
        Padding       = UDim.new(0, gap or 6),
    }, p)
    if valign then l.VerticalAlignment   = valign end
    if halign then l.HorizontalAlignment = halign end
    return l
end

local function Stroke(thick, col, p)
    if not p then return end
    local s = N("UIStroke", {Thickness = thick or 1, Color = col or T.B1}, p)
    if s then s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border end
    return s
end

local function Shadow(parent, blur, opacity, oy)
    if not parent then return end
    -- Try UIShadow (Roblox 2025+)
    local ok = pcall(function()
        local s = Instance.new("UIShadow")
        s.BlurRadius    = blur    or 20
        s.ShadowColor   = Color3.new(0,0,0)
        s.ShadowOpacity = opacity or 0.65
        s.OffsetX       = 0
        s.OffsetY       = oy or 5
        s.Parent        = parent
    end)
    -- Fallback: a blurred backing frame
    if not ok then
        local fb = N("Frame", {
            BackgroundColor3       = Color3.new(0,0,0),
            BackgroundTransparency = 1 - ((opacity or 0.65) * 0.4),
            Size                   = UDim2.new(1, 20, 1, 20),
            Position               = UDim2.new(0, -10, 0, (oy or 5) - 2),
            ZIndex                 = math.max(1, (parent.ZIndex or 1) - 1),
            BorderSizePixel        = 0,
        }, parent)
        if fb then Corner(22, fb) end
    end
end

local function MakeDraggable(win, handle)
    local drag, di, s0, p0 = false, nil, nil, nil
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            drag = true; s0 = i.Position; p0 = win.Position
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then di = i end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then drag = false end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == di and drag and s0 and p0 then
            local d = i.Position - s0
            win.Position = UDim2.new(p0.X.Scale, p0.X.Offset + d.X, p0.Y.Scale, p0.Y.Offset + d.Y)
        end
    end)
end

-- ─── ScreenGui ───────────────────────────────────────────────────────────────
local function GetGui()
    -- Clean up old instance
    local old = nil
    pcall(function()
        old = game:GetService("CoreGui"):FindFirstChild("ONYXHub")
            or (LocalPlayer.PlayerGui and LocalPlayer.PlayerGui:FindFirstChild("ONYXHub"))
    end)
    if old then old:Destroy() end

    local g = Instance.new("ScreenGui")
    g.Name           = "ONYXHub"
    g.ResetOnSpawn   = false
    g.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    g.DisplayOrder   = 999

    if syn and syn.protect_gui then
        syn.protect_gui(g)
        g.Parent = game:GetService("CoreGui")
    elseif gethui then
        g.Parent = gethui()
    elseif protect_gui then
        protect_gui(g)
        g.Parent = game:GetService("CoreGui")
    else
        pcall(function() g.Parent = game:GetService("CoreGui") end)
        if not g.Parent then
            g.Parent = LocalPlayer:WaitForChild("PlayerGui", 5)
        end
    end
    return g
end

-- ─── Notification ─────────────────────────────────────────────────────────────
local _notifHolder = nil

local function InitNotifs(gui)
    _notifHolder = N("Frame", {
        Name                   = "NotifHolder",
        BackgroundTransparency = 1,
        AnchorPoint            = Vector2.new(1, 1),
        Position               = UDim2.new(1, -16, 1, -16),
        Size                   = UDim2.new(0, 300, 0.85, 0),
        ZIndex                 = 999,
    }, gui)
    local l = List(Enum.FillDirection.Vertical, 8, _notifHolder)
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

local function Notify(opts)
    if not _notifHolder then return end
    opts = opts or {}

    local title   = opts.Title    or "ONYX"
    local content = opts.Content  or ""
    local dur     = opts.Duration or 3.5
    local ntype   = opts.Type     or "default" -- "default" | "success" | "error"
    local iconName = opts.Icon    or (ntype == "error" and "AlertTriangle" or ntype == "success" and "CheckCircle" or "Bell")

    local iconChar = ONYX.Icons[iconName] or ONYX.Icons.Default
    local iconBG   = ntype == "error"   and T.DangerBG
                  or ntype == "success" and T.SuccessBG
                  or T.S3
    local iconCol  = ntype == "error"   and T.Danger
                  or ntype == "success" and T.Success
                  or T.White
    local barCol   = ntype == "error"   and T.Danger
                  or ntype == "success" and T.Success
                  or T.White

    local card = N("Frame", {
        Name             = "Notif",
        BackgroundColor3 = T.S1,
        Size             = UDim2.new(1, 0, 0, 70),
        ClipsDescendants = true,
        ZIndex           = 1000,
    }, _notifHolder)
    if not card then return end
    Corner(14, card)
    Stroke(1, T.B2, card)
    Shadow(card, 24, 0.75, 6)

    -- Icon box
    local iconBox = N("Frame", {
        BackgroundColor3 = iconBG,
        Size             = UDim2.new(0, 34, 0, 34),
        Position         = UDim2.new(0, 14, 0.5, -17),
        ZIndex           = 1001,
    }, card)
    Corner(10, iconBox)
    N("TextLabel", {
        Text                   = iconChar,
        TextColor3             = iconCol,
        TextSize               = 15,
        Font                   = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        ZIndex                 = 1002,
    }, iconBox)

    -- Title
    N("TextLabel", {
        Text                   = title,
        TextColor3             = T.White,
        TextSize               = 12,
        Font                   = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 58, 0, 12),
        Size                   = UDim2.new(1, -72, 0, 16),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 1001,
    }, card)

    -- Content
    N("TextLabel", {
        Text                   = content,
        TextColor3             = T.TextSub,
        TextSize               = 11,
        Font                   = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 58, 0, 30),
        Size                   = UDim2.new(1, -72, 0, 28),
        TextXAlignment         = Enum.TextXAlignment.Left,
        TextWrapped            = true,
        ZIndex                 = 1001,
    }, card)

    -- Progress bar
    local bar = N("Frame", {
        BackgroundColor3 = barCol,
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        ZIndex           = 1003,
    }, card)

    -- Slide in
    card.Position = UDim2.new(1.1, 0, 0, 0)
    Spring(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.42)

    -- Animate bar
    Tw(bar, {Size = UDim2.new(0, 0, 0, 2)}, dur, Enum.EasingStyle.Linear)

    -- Close button
    local xBtn = N("TextButton", {
        Text                   = "✕",
        TextColor3             = T.TextMuted,
        TextSize               = 11,
        Font                   = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(0, 24, 0, 24),
        Position               = UDim2.new(1, -28, 0, 8),
        ZIndex                 = 1002,
        AutoButtonColor        = false,
    }, card)

    local function dismiss()
        Tw(card, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1}, 0.28)
        task.delay(0.3, function() pcall(function() card:Destroy() end) end)
    end

    xBtn.MouseButton1Click:Connect(dismiss)
    task.delay(dur, dismiss)
    return card
end

-- ─── CreateWindow ─────────────────────────────────────────────────────────────
function ONYX:CreateWindow(opts)
    opts = opts or {}
    local inst = setmetatable({}, ONYX)
    inst._tabs      = {}
    inst._open      = true
    inst._gui       = GetGui()

    InitNotifs(inst._gui)

    -- Main window frame
    local win = N("Frame", {
        Name             = "Window",
        BackgroundColor3 = T.BG,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = opts.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size             = opts.Size     or UDim2.new(0, 590, 0, 415),
        ClipsDescendants = true,
        ZIndex           = 10,
    }, inst._gui)
    Corner(18, win)
    Stroke(1, T.B1, win)
    Shadow(win, 60, 0.92, 12)
    inst._win = win

    -- Topbar
    local topbar = N("Frame", {
        BackgroundColor3 = T.BG,
        Size             = UDim2.new(1, 0, 0, 48),
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, win)

    -- iOS drag pill
    local pill = N("Frame", {
        BackgroundColor3 = T.B3,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 44, 0, 4),
        ZIndex           = 13,
    }, topbar)
    Corner(3, pill)

    -- Topbar separator
    N("Frame", {
        BackgroundColor3 = T.B1,
        Position         = UDim2.new(0, 0, 1, -1),
        Size             = UDim2.new(1, 0, 0, 1),
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, topbar)

    -- Title
    N("TextLabel", {
        Text                   = opts.Title or "ONYX",
        TextColor3             = T.White,
        TextSize               = 11,
        Font                   = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 16, 0, 0),
        Size                   = UDim2.new(0, 140, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Left,
        ZIndex                 = 13,
        RichText               = false,
    }, topbar)

    -- Subtitle / version tag
    local sub = opts.Subtitle or opts.Version or "v2.1"
    local subTag = N("TextLabel", {
        Text                   = sub,
        TextColor3             = T.TextMuted,
        TextSize               = 9,
        Font                   = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 16, 0, 0),
        Size                   = UDim2.new(1, -100, 1, 0),
        TextXAlignment         = Enum.TextXAlignment.Center,
        ZIndex                 = 13,
    }, topbar)

    MakeDraggable(win, topbar)

    -- Pill hover anim
    topbar.MouseEnter:Connect(function()
        Tw(pill, {Size = UDim2.new(0, 54, 0, 4), BackgroundColor3 = T.B2}, 0.2)
    end)
    topbar.MouseLeave:Connect(function()
        Tw(pill, {Size = UDim2.new(0, 44, 0, 4), BackgroundColor3 = T.B3}, 0.2)
    end)

    -- Sidebar
    local sidebar = N("Frame", {
        BackgroundColor3 = Color3.fromRGB(5, 5, 5),
        Position         = UDim2.new(0, 0, 0, 48),
        Size             = UDim2.new(0, 160, 1, -48),
        ClipsDescendants = true,
        ZIndex           = 11,
    }, win)
    N("Frame", {
        BackgroundColor3 = T.B1,
        Position         = UDim2.new(1, -1, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, sidebar)

    local sideScroll = N("ScrollingFrame", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 7, 0, 10),
        Size                   = UDim2.new(1, -14, 1, -16),
        ScrollBarThickness     = 0,
        CanvasSize             = UDim2.new(0,0,0,0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ZIndex                 = 12,
    }, sidebar)
    List(Enum.FillDirection.Vertical, 2, sideScroll)
    inst._sideScroll = sideScroll

    -- Content area
    local contentArea = N("Frame", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 160, 0, 48),
        Size                   = UDim2.new(1, -160, 1, -48),
        ClipsDescendants       = true,
        ZIndex                 = 11,
    }, win)
    inst._contentArea = contentArea

    -- Toggle keybind
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            inst._open = not inst._open
            win.Visible = inst._open
        end
    end)

    function inst:Notify(o) return Notify(o) end

    -- Boot notification
    task.delay(0.5, function()
        Notify({
            Title   = opts.Title or "ONYX",
            Content = "Hub loaded. " .. toggleKey.Name .. " to toggle.",
            Type    = "success",
            Icon    = "CheckCircle",
            Duration = 4,
        })
    end)

    return inst
end

-- ─── Sidebar section header ───────────────────────────────────────────────────
local function SideLabel(text, parent)
    local row = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0, 22),
        ZIndex = parent.ZIndex + 1,
    }, parent)
    List(Enum.FillDirection.Horizontal, 5, row)
    N("TextLabel", {
        Text               = string.upper(text),
        TextColor3         = T.TextMuted,
        TextSize           = 8,
        Font               = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size               = UDim2.new(0, 0, 1, 0),
        AutomaticSize      = Enum.AutomaticSize.X,
        TextXAlignment     = Enum.TextXAlignment.Left,
        LayoutOrder        = 1,
        ZIndex             = parent.ZIndex + 2,
    }, row)
    local ln = N("Frame", {
        BackgroundColor3 = T.B1,
        Size             = UDim2.new(1, 0, 0, 1),
        BorderSizePixel  = 0,
        LayoutOrder      = 2,
        ZIndex           = parent.ZIndex + 1,
    }, row)
end

-- ─── Content section header ───────────────────────────────────────────────────
local function ContentSection(text, parent)
    local row = N("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, 0, 0, 20),
        ZIndex = parent.ZIndex + 1,
    }, parent)
    List(Enum.FillDirection.Horizontal, 6, row)
    N("TextLabel", {
        Text               = string.upper(text),
        TextColor3         = T.TextMuted,
        TextSize           = 9,
        Font               = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size               = UDim2.new(0, 0, 1, 0),
        AutomaticSize      = Enum.AutomaticSize.X,
        LayoutOrder        = 1,
        ZIndex             = parent.ZIndex + 2,
    }, row)
    N("Frame", {
        BackgroundColor3 = T.B1,
        Size             = UDim2.new(1, 0, 0, 1),
        BorderSizePixel  = 0,
        LayoutOrder      = 2,
        ZIndex           = parent.ZIndex + 1,
    }, row)
end

-- ─── Element base ────────────────────────────────────────────────────────────
local function MakeEl(opts, parent, h)
    h = h or 48
    local isDanger  = opts.Danger  or false
    local isSuccess = opts.Success or false

    local el = N("Frame", {
        BackgroundColor3 = isDanger and T.DangerBG or T.S1,
        Size             = UDim2.new(1, 0, 0, h),
        ZIndex           = parent.ZIndex + 1,
    }, parent)
    Corner(12, el)
    local strk = Stroke(1, isDanger and T.DangerBrd or T.B1, el)

    -- Hover
    local hov = N("TextButton", {
        BackgroundTransparency = 1,
        Size    = UDim2.new(1, 0, 1, 0),
        Text    = "",
        ZIndex  = el.ZIndex + 20,
        AutoButtonColor = false,
    }, el)
    hov.MouseEnter:Connect(function()
        Tw(el,   {BackgroundColor3 = isDanger and Color3.fromRGB(22,7,7) or T.S2}, 0.12)
        Tw(strk, {Color = isDanger and Color3.fromRGB(50,16,16) or T.B2}, 0.12)
    end)
    hov.MouseLeave:Connect(function()
        Tw(el,   {BackgroundColor3 = isDanger and T.DangerBG or T.S1}, 0.12)
        Tw(strk, {Color = isDanger and T.DangerBrd or T.B1}, 0.12)
    end)

    -- Icon (if provided)
    local titleX = 14
    if opts.Icon then
        local iconChar = ONYX.Icons[opts.Icon] or opts.Icon
        N("TextLabel", {
            Text                   = iconChar,
            TextColor3             = isDanger and T.Danger or T.TextSub,
            TextSize               = 14,
            Font                   = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            Position               = UDim2.new(0, 12, 0.5, -10),
            Size                   = UDim2.new(0, 20, 0, 20),
            ZIndex                 = el.ZIndex + 1,
        }, el)
        titleX = 36
    end

    -- Title
    N("TextLabel", {
        Text               = opts.Title or "",
        TextColor3         = isDanger and T.Danger or T.Text,
        TextSize           = 12,
        Font               = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Position           = UDim2.new(0, titleX, 0, opts.Description and 9 or 0),
        Size               = UDim2.new(0.58, -titleX, 0, 18),
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = el.ZIndex + 1,
    }, el)

    if opts.Description then
        N("TextLabel", {
            Text               = opts.Description,
            TextColor3         = isDanger and Color3.fromRGB(90, 45, 45) or T.TextMuted,
            TextSize           = 10,
            Font               = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Position           = UDim2.new(0, titleX, 0, 28),
            Size               = UDim2.new(0.6, 0, 0, 14),
            TextXAlignment     = Enum.TextXAlignment.Left,
            ZIndex             = el.ZIndex + 1,
        }, el)
    end

    return el, hov
end

-- ─── CreateTab ───────────────────────────────────────────────────────────────
function ONYX:CreateTab(name, icon)
    local tab = {}
    local iconChar = (type(icon) == "string" and (ONYX.Icons[icon] or icon)) or "◆"

    -- Sidebar tab button
    local btn = N("TextButton", {
        BackgroundColor3       = T.S1,
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 0, 36),
        Text                   = "",
        AutoButtonColor        = false,
        ZIndex                 = 13,
    }, self._sideScroll)
    Corner(10, btn)

    local btnLabel = N("TextLabel", {
        Text               = iconChar .. "   " .. name,
        TextColor3         = T.TextMuted,
        TextSize           = 11.5,
        Font               = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size               = UDim2.new(1, 0, 1, 0),
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 14,
    }, btn)
    Pad(0, 0, 0, 11, btnLabel)

    -- Content frame
    local frame = N("ScrollingFrame", {
        BackgroundTransparency = 1,
        Size                   = UDim2.new(1, 0, 1, 0),
        Visible                = false,
        ScrollBarThickness     = 2,
        ScrollBarImageColor3   = T.B2,
        CanvasSize             = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize    = Enum.AutomaticSize.Y,
        ClipsDescendants       = true,
        ZIndex                 = 12,
    }, self._contentArea)
    Pad(14, 14, 20, 14, frame)
    List(Enum.FillDirection.Vertical, 7, frame)

    tab._frame  = frame
    tab._btn    = btn
    tab._label  = btnLabel
    tab._window = self

    local function Activate()
        for _, t in ipairs(self._tabs) do
            if t._frame then t._frame.Visible = false end
            Tw(t._label, {TextColor3 = T.TextMuted, Font = Enum.Font.Gotham}, 0.12)
            Tw(t._btn,   {BackgroundTransparency = 1}, 0.15)
        end
        frame.Visible = true
        Tw(btnLabel, {TextColor3 = T.Black, Font = Enum.Font.GothamBold}, 0.12)
        Tw(btn, {BackgroundColor3 = T.White, BackgroundTransparency = 0}, 0.15)
    end

    btn.MouseButton1Click:Connect(Activate)
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then task.defer(Activate) end

    -- ── Tab methods ───────────────────────────────────────────────────────────

    function tab:CreateSection(text)
        ContentSection(text, frame)
    end

    function tab:CreateSeparator()
        N("Frame", {
            BackgroundColor3 = T.B1,
            Size             = UDim2.new(1, 0, 0, 1),
            BorderSizePixel  = 0,
            ZIndex           = frame.ZIndex + 1,
        }, frame)
    end

    function tab:CreateLabel(opts)
        opts = type(opts) == "string" and {Text = opts} or opts or {}
        local lbl = N("TextLabel", {
            Text               = opts.Text or "",
            TextColor3         = opts.Color or T.TextSub,
            TextSize           = 11,
            Font               = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size               = UDim2.new(1, 0, 0, 18),
            TextXAlignment     = Enum.TextXAlignment.Left,
            TextWrapped        = true,
            ZIndex             = frame.ZIndex + 1,
        }, frame)
        Pad(0, 0, 0, 6, lbl)
        local ctrl = {}
        function ctrl:Set(v) if lbl then lbl.Text = v end end
        function ctrl:Get() return lbl and lbl.Text or "" end
        return ctrl
    end

    -- ── Toggle ────────────────────────────────────────────────────────────────
    function tab:CreateToggle(opts)
        opts = opts or {}
        local state = opts.Default == true
        local el, hov = MakeEl(opts, frame)

        local track = N("Frame", {
            BackgroundColor3 = state and T.White or T.B2,
            Size             = UDim2.new(0, 40, 0, 22),
            Position         = UDim2.new(1, -52, 0.5, -11),
            ZIndex           = el.ZIndex + 2,
        }, el)
        Corner(11, track)
        local trkStrk = Stroke(1, state and T.White or T.B3, track)

        local thumb = N("Frame", {
            BackgroundColor3 = state and T.Black or Color3.fromRGB(65, 65, 65),
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
            ZIndex           = el.ZIndex + 3,
        }, track)
        Corner(7, thumb)
        Shadow(thumb, 4, 0.4, 1)

        local badge = N("TextLabel", {
            Text               = state and "ON" or "OFF",
            TextColor3         = state and Color3.fromRGB(80,80,80) or T.TextMuted,
            TextSize           = 8,
            Font               = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            Position           = UDim2.new(1, -96, 0.5, -8),
            Size               = UDim2.new(0, 36, 0, 16),
            TextXAlignment     = Enum.TextXAlignment.Right,
            ZIndex             = el.ZIndex + 2,
        }, el)

        local function SetState(v)
            state = v
            Spring(thumb, {
                Position         = v and UDim2.new(1,-18,0.5,-7) or UDim2.new(0,4,0.5,-7),
                BackgroundColor3 = v and T.Black or Color3.fromRGB(65,65,65),
            }, 0.28)
            Tw(track,    {BackgroundColor3 = v and T.White or T.B2},  0.18)
            Tw(trkStrk,  {Color            = v and T.White or T.B3},  0.18)
            Tw(badge,    {TextColor3       = v and Color3.fromRGB(80,80,80) or T.TextMuted}, 0.15)
            badge.Text = v and "ON" or "OFF"
            if opts.Callback then
                task.spawn(opts.Callback, state)
            end
        end

        hov.MouseButton1Click:Connect(function() SetState(not state) end)

        local ctrl = {}
        function ctrl:Set(v)  SetState(v) end
        function ctrl:Get()   return state end
        return ctrl
    end

    -- ── Button ────────────────────────────────────────────────────────────────
    function tab:CreateButton(opts)
        opts = opts or {}
        local el, hov = MakeEl(opts, frame)
        local isGhost = opts.Ghost == true

        local btnFrame = N("TextButton", {
            Text             = opts.ButtonText or "Execute",
            TextColor3       = isGhost and T.TextSub or T.Black,
            TextSize         = 11,
            Font             = Enum.Font.GothamBold,
            BackgroundColor3 = isGhost and T.S3 or T.White,
            Size             = UDim2.new(0, 0, 0, 28),
            AutomaticSize    = Enum.AutomaticSize.X,
            Position         = UDim2.new(1, -14, 0.5, -14),
            AnchorPoint      = Vector2.new(1, 0),
            AutoButtonColor  = false,
            ZIndex           = el.ZIndex + 2,
        }, el)
        Pad(0, 14, 0, 14, btnFrame)
        Corner(8, btnFrame)
        if isGhost then Stroke(1, T.B2, btnFrame) end
        Shadow(btnFrame, 6, 0.25, 2)

        btnFrame.MouseEnter:Connect(function()
            Tw(btnFrame, {BackgroundColor3 = isGhost and T.B1 or Color3.fromRGB(220,220,220)}, 0.12)
        end)
        btnFrame.MouseLeave:Connect(function()
            Tw(btnFrame, {BackgroundColor3 = isGhost and T.S3 or T.White}, 0.12)
        end)
        btnFrame.MouseButton1Down:Connect(function()
            Tw(btnFrame, {BackgroundColor3 = isGhost and T.B2 or Color3.fromRGB(180,180,180)}, 0.06)
        end)
        btnFrame.MouseButton1Click:Connect(function()
            task.delay(0.1, function()
                Tw(btnFrame, {BackgroundColor3 = isGhost and T.S3 or T.White}, 0.12)
            end)
            if opts.Callback then task.spawn(opts.Callback) end
        end)
    end

    -- ── Slider ────────────────────────────────────────────────────────────────
    function tab:CreateSlider(opts)
        opts = opts or {}
        local min  = opts.Min     or 0
        local max  = opts.Max     or 100
        local val  = math.clamp(opts.Default or min, min, max)

        local el = N("Frame", {
            BackgroundColor3 = T.S1,
            Size             = UDim2.new(1, 0, 0, 58),
            ZIndex           = frame.ZIndex + 1,
        }, frame)
        Corner(12, el)
        Stroke(1, T.B1, el)
        Pad(12, 14, 12, 14, el)

        local head = N("Frame", {
            BackgroundTransparency = 1,
            Size  = UDim2.new(1, 0, 0, 18),
            ZIndex = el.ZIndex + 1,
        }, el)
        List(Enum.FillDirection.Horizontal, 0, head)

        N("TextLabel", {
            Text               = opts.Title or "Value",
            TextColor3         = T.Text,
            TextSize           = 12,
            Font               = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            Size               = UDim2.new(1, -54, 1, 0),
            TextXAlignment     = Enum.TextXAlignment.Left,
            LayoutOrder        = 1,
            ZIndex             = el.ZIndex + 2,
        }, head)

        local valBox = N("TextLabel", {
            Text               = tostring(val),
            TextColor3         = T.White,
            TextSize           = 10,
            Font               = Enum.Font.GothamBold,
            BackgroundColor3   = T.S3,
            Size               = UDim2.new(0, 50, 1, 0),
            TextXAlignment     = Enum.TextXAlignment.Center,
            LayoutOrder        = 2,
            ZIndex             = el.ZIndex + 2,
        }, head)
        Corner(5, valBox)
        Stroke(1, T.B2, valBox)

        local track = N("Frame", {
            BackgroundColor3 = T.B2,
            Size             = UDim2.new(1, 0, 0, 3),
            Position         = UDim2.new(0, 0, 1, -3),
            ZIndex           = el.ZIndex + 1,
        }, el)
        Corner(2, track)

        local initPct = (val - min) / (max - min)
        local fill = N("Frame", {
            BackgroundColor3 = T.White,
            Size             = UDim2.new(initPct, 0, 1, 0),
            ZIndex           = el.ZIndex + 2,
        }, track)
        Corner(2, fill)

        local thumb = N("Frame", {
            BackgroundColor3 = T.White,
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = UDim2.new(initPct, -7, 0.5, -7),
            ZIndex           = el.ZIndex + 3,
        }, track)
        Corner(7, thumb)
        Stroke(2, T.Black, thumb)
        Shadow(thumb, 4, 0.5, 1)

        local dragging = false

        local function Update(mouseX)
            local p   = math.clamp((mouseX - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            val       = math.round(min + (max - min) * p)
            valBox.Text      = tostring(val)
            fill.Size        = UDim2.new(p, 0, 1, 0)
            thumb.Position   = UDim2.new(p, -7, 0.5, -7)
            if opts.Callback then task.spawn(opts.Callback, val) end
        end

        local hitbox = N("TextButton", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0.5, -14),
            Text     = "",
            ZIndex   = el.ZIndex + 5,
        }, track)

        hitbox.MouseButton1Down:Connect(function()
            dragging = true
            Spring(thumb, {Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(thumb.Position.X.Scale, -9, 0.5, -9)}, 0.18)
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 and dragging then
                dragging = false
                Spring(thumb, {Size = UDim2.new(0, 14, 0, 14)}, 0.18)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                Update(i.Position.X)
            end
        end)

        local ctrl = {}
        function ctrl:Set(v)
            val = math.clamp(v, min, max)
            local p = (val - min) / (max - min)
            valBox.Text    = tostring(val)
            fill.Size      = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, -7, 0.5, -7)
        end
        function ctrl:Get() return val end
        return ctrl
    end

    -- ── Dropdown ─────────────────────────────────────────────────────────────
    function tab:CreateDropdown(opts)
        opts = opts or {}
        local options  = opts.Options or {}
        local selected = opts.Default  or (options[1] or "Select")
        local isOpen   = false

        local el, hov = MakeEl(opts, frame)

        local ddBtn = N("Frame", {
            BackgroundColor3 = T.S3,
            Size             = UDim2.new(0, 138, 0, 28),
            Position         = UDim2.new(1, -150, 0.5, -14),
            ClipsDescendants = false,
            ZIndex           = el.ZIndex + 2,
        }, el)
        Corner(8, ddBtn)
        Stroke(1, T.B2, ddBtn)
        Shadow(ddBtn, 6, 0.25, 3)

        local ddLabel = N("TextLabel", {
            Text               = selected,
            TextColor3         = T.TextSub,
            TextSize           = 11,
            Font               = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Position           = UDim2.new(0, 10, 0, 0),
            Size               = UDim2.new(1, -26, 1, 0),
            TextXAlignment     = Enum.TextXAlignment.Left,
            ZIndex             = el.ZIndex + 3,
        }, ddBtn)

        local arrow = N("TextLabel", {
            Text               = "⌄",
            TextColor3         = T.TextMuted,
            TextSize           = 14,
            Font               = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            Position           = UDim2.new(1, -22, 0, 1),
            Size               = UDim2.new(0, 18, 1, 0),
            ZIndex             = el.ZIndex + 3,
        }, ddBtn)

        local panel = N("Frame", {
            BackgroundColor3 = T.S2,
            Size             = UDim2.new(0, 138, 0, (#options * 30) + 10),
            Position         = UDim2.new(0, 0, 1, 6),
            Visible          = false,
            ZIndex           = 50,
        }, ddBtn)
        Corner(10, panel)
        Stroke(1, T.B2, panel)
        Shadow(panel, 18, 0.65, 6)
        Pad(5, 5, 5, 5, panel)
        List(Enum.FillDirection.Vertical, 2, panel)

        local function Close()
            isOpen = false
            panel.Visible = false
            Tw(arrow, {Rotation = 0}, 0.18)
        end

        for _, opt in ipairs(options) do
            local isSel = opt == selected
            local o = N("TextButton", {
                Text             = opt,
                TextColor3       = isSel and T.White or T.TextSub,
                TextSize         = 11,
                Font             = isSel and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                BackgroundColor3 = T.S3,
                BackgroundTransparency = isSel and 0 or 1,
                Size             = UDim2.new(1, 0, 0, 26),
                AutoButtonColor  = false,
                ZIndex           = 51,
            }, panel)
            Corner(7, o)

            o.MouseEnter:Connect(function()
                if opt ~= selected then Tw(o, {BackgroundTransparency = 0, BackgroundColor3 = T.B1}, 0.1) end
            end)
            o.MouseLeave:Connect(function()
                if opt ~= selected then Tw(o, {BackgroundTransparency = 1}, 0.1) end
            end)
            o.MouseButton1Click:Connect(function()
                selected     = opt
                ddLabel.Text = opt
                -- deselect all
                for _, c in ipairs(panel:GetChildren()) do
                    if c:IsA("TextButton") then
                        Tw(c, {BackgroundTransparency = 1, TextColor3 = T.TextSub}, 0.1)
                        c.Font = Enum.Font.Gotham
                    end
                end
                Tw(o, {BackgroundTransparency = 0, BackgroundColor3 = T.S3, TextColor3 = T.White}, 0.1)
                o.Font = Enum.Font.GothamSemibold
                Close()
                if opts.Callback then task.spawn(opts.Callback, selected) end
            end)
        end

        local hitbox = N("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "", ZIndex = el.ZIndex + 4,
        }, ddBtn)
        hitbox.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            panel.Visible = isOpen
            Tw(arrow, {Rotation = isOpen and 180 or 0}, 0.2)
        end)

        local ctrl = {}
        function ctrl:Set(v)   selected = v ddLabel.Text = v end
        function ctrl:Get()    return selected end
        function ctrl:Close()  Close() end
        return ctrl
    end

    -- ── Color Picker ──────────────────────────────────────────────────────────
    function tab:CreateColorPicker(opts)
        opts = opts or {}
        local color = opts.Default or Color3.new(1,1,1)
        local rv, gv, bv = 255, 255, 255

        local el, hov = MakeEl(opts, frame)

        local swatch = N("Frame", {
            BackgroundColor3 = color,
            Size             = UDim2.new(0, 32, 0, 32),
            Position         = UDim2.new(1, -46, 0.5, -16),
            ZIndex           = el.ZIndex + 2,
        }, el)
        Corner(9, swatch)
        Stroke(2, T.B2, swatch)
        Shadow(swatch, 8, 0.35, 2)

        local pickerOpen = false
        local picker = N("Frame", {
            BackgroundColor3 = T.S2,
            Size             = UDim2.new(0, 218, 0, 136),
            Position         = UDim2.new(0, -185, 1, 8),
            Visible          = false,
            ZIndex           = 60,
        }, swatch)
        Corner(12, picker)
        Stroke(1, T.B2, picker)
        Shadow(picker, 22, 0.72, 7)
        Pad(12, 12, 12, 12, picker)

        -- Preset swatches
        local row = N("Frame", {
            BackgroundTransparency = 1,
            Size   = UDim2.new(1, 0, 0, 22),
            ZIndex = picker.ZIndex + 1,
        }, picker)
        List(Enum.FillDirection.Horizontal, 4, row)

        local presets = {
            {1,1,1},{0,0,0},{1,.27,.27},{1,.63,0},
            {1,.9,0},{.27,.86,.27},{.27,.55,1},{.7,.31,1},
            {1,.31,.71},{0,.9,.79},{.5,.5,.5},{.18,.18,.18},
        }
        for _, p in ipairs(presets) do
            local c = Color3.new(p[1], p[2], p[3])
            local ps = N("TextButton", {
                BackgroundColor3 = c,
                Size = UDim2.new(0, 20, 0, 20),
                Text = "", AutoButtonColor = false,
                ZIndex = picker.ZIndex + 2,
            }, row)
            Corner(5, ps)
            Stroke(1, T.B3, ps)
            ps.MouseButton1Click:Connect(function()
                rv = math.round(p[1]*255)
                gv = math.round(p[2]*255)
                bv = math.round(p[3]*255)
                color = c
                swatch.BackgroundColor3 = c
                if opts.Callback then task.spawn(opts.Callback, color) end
            end)
        end

        -- RGB channel sliders
        local chHolder = N("Frame", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30),
            ZIndex   = picker.ZIndex + 1,
        }, picker)
        List(Enum.FillDirection.Vertical, 7, chHolder)

        local channels = {
            {lbl="R", key="r", col=Color3.fromRGB(160,40,40)},
            {lbl="G", key="g", col=Color3.fromRGB(40,150,40)},
            {lbl="B", key="b", col=Color3.fromRGB(40,80,190)},
        }

        for _, ch in ipairs(channels) do
            local cRow = N("Frame", {
                BackgroundTransparency = 1,
                Size   = UDim2.new(1, 0, 0, 14),
                ZIndex = chHolder.ZIndex + 1,
            }, chHolder)
            List(Enum.FillDirection.Horizontal, 5, cRow)

            N("TextLabel", {
                Text               = ch.lbl,
                TextColor3         = T.TextMuted,
                TextSize           = 9,
                Font               = Enum.Font.GothamBold,
                BackgroundTransparency = 1,
                Size               = UDim2.new(0, 10, 1, 0),
                LayoutOrder        = 1,
                ZIndex             = cRow.ZIndex + 1,
            }, cRow)

            local cTrack = N("Frame", {
                BackgroundColor3 = T.B1,
                Size             = UDim2.new(1, -44, 0, 3),
                LayoutOrder      = 2,
                ZIndex           = cRow.ZIndex + 1,
            }, cRow)
            Corner(2, cTrack)

            local cFill = N("Frame", {
                BackgroundColor3 = ch.col,
                Size             = UDim2.new(1, 0, 1, 0),
                ZIndex           = cRow.ZIndex + 2,
            }, cTrack)
            Corner(2, cFill)

            local cThumb = N("Frame", {
                BackgroundColor3 = T.White,
                Size             = UDim2.new(0, 10, 0, 10),
                Position         = UDim2.new(1, -5, 0.5, -5),
                ZIndex           = cRow.ZIndex + 3,
            }, cTrack)
            Corner(5, cThumb)

            local cValLbl = N("TextLabel", {
                Text               = "255",
                TextColor3         = T.TextMuted,
                TextSize           = 9,
                Font               = Enum.Font.GothamBold,
                BackgroundTransparency = 1,
                Size               = UDim2.new(0, 28, 1, 0),
                TextXAlignment     = Enum.TextXAlignment.Right,
                LayoutOrder        = 3,
                ZIndex             = cRow.ZIndex + 1,
            }, cRow)

            local cDrag = false
            local cHit = N("TextButton", {
                BackgroundTransparency = 1,
                Size     = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0.5, -10),
                Text     = "", ZIndex = cRow.ZIndex + 4,
            }, cTrack)

            cHit.MouseButton1Down:Connect(function() cDrag = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then cDrag = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if not cDrag or i.UserInputType ~= Enum.UserInputType.MouseMovement then return end
                local p = math.clamp((i.Position.X - cTrack.AbsolutePosition.X) / cTrack.AbsoluteSize.X, 0, 1)
                local v = math.round(p * 255)
                cFill.Size     = UDim2.new(p, 0, 1, 0)
                cThumb.Position = UDim2.new(p, -5, 0.5, -5)
                cValLbl.Text   = tostring(v)
                if ch.key == "r" then rv = v
                elseif ch.key == "g" then gv = v
                else bv = v end
                color = Color3.fromRGB(rv, gv, bv)
                swatch.BackgroundColor3 = color
                if opts.Callback then task.spawn(opts.Callback, color) end
            end)
        end

        local swHit = N("TextButton", {
            BackgroundTransparency = 1,
            Size   = UDim2.new(1, 0, 1, 0),
            Text   = "", ZIndex = el.ZIndex + 4,
        }, swatch)
        swHit.MouseButton1Click:Connect(function()
            pickerOpen = not pickerOpen
            picker.Visible = pickerOpen
        end)

        local ctrl = {}
        function ctrl:Set(c)
            color = c
            swatch.BackgroundColor3 = c
            rv = math.round(c.R*255); gv = math.round(c.G*255); bv = math.round(c.B*255)
        end
        function ctrl:Get() return color end
        return ctrl
    end

    -- ── Input ─────────────────────────────────────────────────────────────────
    function tab:CreateInput(opts)
        opts = opts or {}
        local el, hov = MakeEl(opts, frame)

        local box = N("TextBox", {
            Text             = opts.Default or "",
            PlaceholderText  = opts.Placeholder or "Type here...",
            PlaceholderColor3 = T.B3,
            TextColor3       = T.TextSub,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            BackgroundColor3 = T.S3,
            Size             = UDim2.new(0, 138, 0, 26),
            Position         = UDim2.new(1, -150, 0.5, -13),
            ClearTextOnFocus = opts.ClearOnFocus ~= nil and opts.ClearOnFocus or false,
            ZIndex           = el.ZIndex + 2,
        }, el)
        Corner(8, box)
        local bStrk = Stroke(1, T.B2, box)
        Pad(0, 10, 0, 10, box)

        box.Focused:Connect(function()
            Tw(bStrk, {Color = T.White}, 0.15)
            Tw(box,   {TextColor3 = T.Text}, 0.15)
        end)
        box.FocusLost:Connect(function(enter)
            Tw(bStrk, {Color = T.B2}, 0.15)
            Tw(box,   {TextColor3 = T.TextSub}, 0.15)
            if enter and opts.Callback then task.spawn(opts.Callback, box.Text) end
        end)

        local ctrl = {}
        function ctrl:Set(v) if box then box.Text = v end end
        function ctrl:Get() return box and box.Text or "" end
        return ctrl
    end

    -- ── Keybind ───────────────────────────────────────────────────────────────
    function tab:CreateKeybind(opts)
        opts = opts or {}
        local key       = opts.Default or Enum.KeyCode.F
        local listening = false

        local el, hov = MakeEl(opts, frame)

        local kBtn = N("TextButton", {
            Text             = key.Name,
            TextColor3       = T.TextSub,
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            BackgroundColor3 = T.S3,
            Size             = UDim2.new(0, 80, 0, 26),
            Position         = UDim2.new(1, -92, 0.5, -13),
            AutoButtonColor  = false,
            ZIndex           = el.ZIndex + 2,
        }, el)
        Corner(7, kBtn)
        local kStrk = Stroke(1, T.B2, kBtn)

        kBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            kBtn.Text = "..."
            Tw(kBtn,  {TextColor3 = T.White}, 0.1)
            Tw(kStrk, {Color = T.White}, 0.1)
        end)

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp or not listening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                listening = false
                kBtn.Text = key.Name
                Tw(kBtn,  {TextColor3 = T.TextSub}, 0.15)
                Tw(kStrk, {Color = T.B2}, 0.15)
                if opts.Callback then task.spawn(opts.Callback, key) end
            end
        end)

        local ctrl = {}
        function ctrl:Get() return key end
        return ctrl
    end

    -- ── Sidebar section ───────────────────────────────────────────────────────
    function tab:AddSideSection(text)
        SideLabel(text, self._window._sideScroll)
    end

    return tab
end

-- ─── Sidebar section (window-level) ──────────────────────────────────────────
function ONYX:AddSideSection(text)
    SideLabel(text, self._sideScroll)
end

return ONYX
