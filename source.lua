--[[
    ONYX UI Library v2.0
    Black & white exploit hub — full library
    UIShadow (Roblox 2025), spring toggles, sliders, dropdowns,
    color picker, keybinds, notifications, draggable window
--]]

local ONYX = {}
ONYX.__index = ONYX

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer

-- ─── Theme ────────────────────────────────────────────────────────────────────

local T = {
    BG        = Color3.fromRGB(8,   8,   8),
    S1        = Color3.fromRGB(13,  13,  13),
    S2        = Color3.fromRGB(17,  17,  17),
    S3        = Color3.fromRGB(22,  22,  22),
    B1        = Color3.fromRGB(28,  28,  28),
    B2        = Color3.fromRGB(36,  36,  36),
    B3        = Color3.fromRGB(46,  46,  46),
    White     = Color3.new(1, 1, 1),
    Black     = Color3.new(0, 0, 0),
    Text      = Color3.fromRGB(232, 232, 232),
    TextSub   = Color3.fromRGB(130, 130, 130),
    TextMuted = Color3.fromRGB(60,  60,  60),
    Danger    = Color3.fromRGB(180, 70,  70),
    DangerBG  = Color3.fromRGB(20,  8,   8),
}

-- ─── Utility ──────────────────────────────────────────────────────────────────

local function Tw(obj, props, t, style, dir)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
        props
    ):Play()
end

local function Spring(obj, props, t)
    TweenService:Create(obj,
        TweenInfo.new(t or 0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        props
    ):Play()
end

local function N(class, props, parent)
    local o = Instance.new(class)
    for k, v in pairs(props) do
        o[k] = v
    end
    if parent then o.Parent = parent end
    return o
end

local function Corner(r, p)
    N("UICorner", { CornerRadius = UDim.new(0, r) }, p)
end

local function Pad(t, r, b, l, p)
    N("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
    }, p)
end

local function List(dir, gap, p, align)
    local l = N("UIListLayout", {
        FillDirection  = dir or Enum.FillDirection.Vertical,
        SortOrder      = Enum.SortOrder.LayoutOrder,
        Padding        = UDim.new(0, gap or 6),
    }, p)
    if align then l.HorizontalAlignment = align end
    return l
end

local function Stroke(thick, col, p, mode)
    local s = N("UIStroke", {
        Thickness = thick or 1,
        Color     = col or T.B1,
    }, p)
    s.ApplyStrokeMode = mode or Enum.ApplyStrokeMode.Border
    return s
end

local function Shadow(parent, blur, opacity, oy)
    -- UIShadow — Roblox 2025 native shadow
    local ok, s = pcall(function()
        return N("UIShadow", {
            BlurRadius    = blur    or 16,
            ShadowColor   = T.Black,
            ShadowOpacity = opacity or 0.6,
            OffsetX       = 0,
            OffsetY       = oy      or 4,
        }, parent)
    end)
    if not ok then
        -- fallback: invisible frame behind (pre-2025 executors)
        local fb = N("Frame", {
            BackgroundColor3    = T.Black,
            BackgroundTransparency = 0.6,
            Size                = UDim2.new(1, 12, 1, 12),
            Position            = UDim2.new(0, -6, 0, (oy or 4) - 2),
            ZIndex              = (parent.ZIndex or 1) - 1,
        }, parent)
        Corner(20, fb)
    end
end

local function MakeDraggable(window, handle)
    local dragging, dragInput, start, startPos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging  = true
            start     = i.Position
            startPos  = window.Position
        end
    end)
    handle.InputChanged:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = i
        end
    end)
    handle.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if i == dragInput and dragging then
            local d = i.Position - start
            window.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + d.X,
                startPos.Y.Scale, startPos.Y.Offset + d.Y
            )
        end
    end)
end

-- ─── ScreenGui ────────────────────────────────────────────────────────────────

local function GetGui()
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
    else
        g.Parent = LocalPlayer:FindFirstChildOfClass("PlayerGui") or LocalPlayer.PlayerGui
    end
    return g
end

-- ─── Notification System ─────────────────────────────────────────────────────

local NotifHolder

local function InitNotifs(gui)
    NotifHolder = N("Frame", {
        Name                 = "Notifs",
        BackgroundTransparency = 1,
        AnchorPoint          = Vector2.new(1, 1),
        Position             = UDim2.new(1, -18, 1, -18),
        Size                 = UDim2.new(0, 290, 1, -18),
        ZIndex               = 999,
    }, gui)
    local l = List(Enum.FillDirection.Vertical, 8, NotifHolder)
    l.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

local function Notify(opts)
    opts = opts or {}
    local title   = opts.Title    or "ONYX"
    local content = opts.Content  or ""
    local dur     = opts.Duration or 3.5
    local isWarn  = opts.Warning  or false

    local card = N("Frame", {
        Name             = "Notif_" .. tick(),
        BackgroundColor3 = T.S2,
        Size             = UDim2.new(1, 0, 0, 66),
        ClipsDescendants = true,
        ZIndex           = 999,
    }, NotifHolder)
    Corner(14, card)
    Stroke(1, T.B2, card)
    Shadow(card, 20, 0.7, 5)

    -- slide in from right
    card.Position = UDim2.new(1.1, 0, 0, 0)
    Spring(card, { Position = UDim2.new(0, 0, 0, 0) }, 0.4)

    -- icon
    local iconFrame = N("Frame", {
        BackgroundColor3 = isWarn and T.DangerBG or T.White,
        Size             = UDim2.new(0, 32, 0, 32),
        Position         = UDim2.new(0, 14, 0.5, -16),
        ZIndex           = 1000,
    }, card)
    Corner(9, iconFrame)
    N("TextLabel", {
        Text                 = isWarn and "!" or "✦",
        TextColor3           = isWarn and T.Danger or T.Black,
        TextSize             = isWarn and 16 or 13,
        Font                 = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size                 = UDim2.new(1, 0, 1, 0),
        ZIndex               = 1001,
    }, iconFrame)

    -- title
    N("TextLabel", {
        Text               = title,
        TextColor3         = T.White,
        TextSize           = 12,
        Font               = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position           = UDim2.new(0, 56, 0, 10),
        Size               = UDim2.new(1, -72, 0, 16),
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 1000,
    }, card)

    -- message
    N("TextLabel", {
        Text               = content,
        TextColor3         = T.TextSub,
        TextSize           = 11,
        Font               = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Position           = UDim2.new(0, 56, 0, 28),
        Size               = UDim2.new(1, -70, 0, 28),
        TextXAlignment     = Enum.TextXAlignment.Left,
        TextWrapped        = true,
        ZIndex             = 1000,
    }, card)

    -- progress bar
    local bar = N("Frame", {
        BackgroundColor3 = isWarn and T.Danger or T.White,
        Size             = UDim2.new(1, 0, 0, 2),
        Position         = UDim2.new(0, 0, 1, -2),
        ZIndex           = 1002,
    }, card)
    Tw(bar, { Size = UDim2.new(0, 0, 0, 2) }, dur, Enum.EasingStyle.Linear)

    task.delay(dur, function()
        Tw(card, { Size = UDim2.new(1, 0, 0, 0) }, 0.3)
        task.wait(0.32)
        card:Destroy()
    end)

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

    -- ── Main frame
    local win = N("Frame", {
        Name             = "ONYXWindow",
        BackgroundColor3 = T.BG,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = opts.Position or UDim2.new(0.5, 0, 0.5, 0),
        Size             = opts.Size     or UDim2.new(0, 600, 0, 420),
        ClipsDescendants = true,
        ZIndex           = 10,
    }, inst._gui)
    Corner(18, win)
    Stroke(1, T.B1, win)
    Shadow(win, 50, 0.9, 10)
    inst._win = win

    -- ── Topbar
    local topbar = N("Frame", {
        Name             = "Topbar",
        BackgroundColor3 = T.BG,
        Size             = UDim2.new(1, 0, 0, 48),
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, win)

    -- iOS pill
    local pill = N("Frame", {
        BackgroundColor3 = T.B3,
        AnchorPoint      = Vector2.new(0.5, 0.5),
        Position         = UDim2.new(0.5, 0, 0.5, 0),
        Size             = UDim2.new(0, 44, 0, 4),
        ZIndex           = 13,
    }, topbar)
    Corner(3, pill)

    -- Topbar divider
    N("Frame", {
        BackgroundColor3 = T.B1,
        Position         = UDim2.new(0, 0, 1, -1),
        Size             = UDim2.new(1, 0, 0, 1),
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, topbar)

    -- Window title
    N("TextLabel", {
        Text               = opts.Title or "ONYX",
        TextColor3         = T.White,
        TextSize           = 11,
        Font               = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position           = UDim2.new(0, 16, 0, 0),
        Size               = UDim2.new(0, 120, 1, 0),
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 13,
    }, topbar)

    -- Window subtitle
    if opts.Subtitle then
        N("TextLabel", {
            Text               = opts.Subtitle,
            TextColor3         = T.TextMuted,
            TextSize           = 10,
            Font               = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Position           = UDim2.new(0, 16, 0, 0),
            Size               = UDim2.new(1, -80, 1, 0),
            TextXAlignment     = Enum.TextXAlignment.Center,
            ZIndex             = 13,
        }, topbar)
    end

    MakeDraggable(win, topbar)

    -- Pill hover
    topbar.MouseEnter:Connect(function()
        Tw(pill, { Size = UDim2.new(0, 56, 0, 4), BackgroundColor3 = T.B2 }, 0.2)
    end)
    topbar.MouseLeave:Connect(function()
        Tw(pill, { Size = UDim2.new(0, 44, 0, 4), BackgroundColor3 = T.B3 }, 0.2)
    end)

    -- ── Sidebar
    local sidebar = N("Frame", {
        Name             = "Sidebar",
        BackgroundColor3 = Color3.fromRGB(6, 6, 6),
        Position         = UDim2.new(0, 0, 0, 48),
        Size             = UDim2.new(0, 162, 1, -48),
        ClipsDescendants = true,
        ZIndex           = 11,
    }, win)

    -- Sidebar right border
    N("Frame", {
        BackgroundColor3 = T.B1,
        Position         = UDim2.new(1, -1, 0, 0),
        Size             = UDim2.new(0, 1, 1, 0),
        BorderSizePixel  = 0,
        ZIndex           = 12,
    }, sidebar)

    local sideInner = N("Frame", {
        BackgroundTransparency = 1,
        Position               = UDim2.new(0, 7, 0, 10),
        Size                   = UDim2.new(1, -14, 1, -20),
        ZIndex                 = 12,
    }, sidebar)
    List(Enum.FillDirection.Vertical, 2, sideInner)
    inst._sideInner = sideInner

    -- ── Content area
    local contentArea = N("Frame", {
        Name                 = "ContentArea",
        BackgroundTransparency = 1,
        Position             = UDim2.new(0, 162, 0, 48),
        Size                 = UDim2.new(1, -162, 1, -48),
        ClipsDescendants     = true,
        ZIndex               = 11,
    }, win)
    inst._contentArea = contentArea

    -- ── Toggle keybind
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            inst._open = not inst._open
            win.Visible = inst._open
        end
    end)

    -- ── Bind Notify to instance scope
    function inst:Notify(o)
        return Notify(o)
    end

    return inst
end

-- ─── Section label helper (internal) ─────────────────────────────────────────

local function MakeSection(text, parent)
    local row = N("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 20),
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
        TextXAlignment     = Enum.TextXAlignment.Left,
        LayoutOrder        = 1,
        ZIndex             = parent.ZIndex + 2,
    }, row)

    N("Frame", {
        BackgroundColor3 = T.B1,
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 0.5, 0),
        BorderSizePixel  = 0,
        LayoutOrder      = 2,
        ZIndex           = parent.ZIndex + 1,
    }, row)
end

-- ─── Element base (internal) ──────────────────────────────────────────────────

local function MakeElement(opts, parent, height)
    local el = N("Frame", {
        BackgroundColor3 = T.S1,
        Size             = UDim2.new(1, 0, 0, height or 48),
        ZIndex           = parent.ZIndex + 1,
    }, parent)
    Corner(12, el)
    Stroke(1, T.B1, el)

    if opts.Danger then
        el.BackgroundColor3 = T.DangerBG
    end

    -- hover glow
    local hov = N("TextButton", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        Text = "",
        ZIndex = el.ZIndex + 20,
        AutoButtonColor = false,
    }, el)

    hov.MouseEnter:Connect(function()
        Tw(el, { BackgroundColor3 = T.S2, ["BorderSizePixel"] = 0 }, 0.15)
        Tw(el:FindFirstChildOfClass("UIStroke"), { Color = T.B2 }, 0.15)
    end)
    hov.MouseLeave:Connect(function()
        Tw(el, { BackgroundColor3 = opts.Danger and T.DangerBG or T.S1 }, 0.15)
        Tw(el:FindFirstChildOfClass("UIStroke"), { Color = T.B1 }, 0.15)
    end)

    -- title
    N("TextLabel", {
        Text               = opts.Title or "",
        TextColor3         = opts.Danger and T.Danger or T.Text,
        TextSize           = 12,
        Font               = Enum.Font.GothamSemibold,
        BackgroundTransparency = 1,
        Position           = UDim2.new(0, 14, 0, opts.Description and 8 or 0),
        Size               = UDim2.new(0.55, 0, 0, 18),
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = el.ZIndex + 1,
    }, el)

    -- description
    if opts.Description then
        N("TextLabel", {
            Text               = opts.Description,
            TextColor3         = opts.Danger and Color3.fromRGB(100, 50, 50) or T.TextMuted,
            TextSize           = 10,
            Font               = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Position           = UDim2.new(0, 14, 0, 28),
            Size               = UDim2.new(0.6, 0, 0, 14),
            TextXAlignment     = Enum.TextXAlignment.Left,
            ZIndex             = el.ZIndex + 1,
        }, el)
    end

    return el, hov
end

-- ─── CreateTab ────────────────────────────────────────────────────────────────

function ONYX:CreateTab(name, icon)
    local tab = {}

    -- sidebar button
    local btn = N("TextButton", {
        Name                 = name,
        BackgroundColor3     = T.S1,
        BackgroundTransparency = 1,
        Size                 = UDim2.new(1, 0, 0, 36),
        Text                 = "",
        AutoButtonColor      = false,
        ZIndex               = 13,
    }, self._sideInner)
    Corner(10, btn)

    local btnLabel = N("TextLabel", {
        Text               = (icon or "◆") .. "   " .. name,
        TextColor3         = T.TextMuted,
        TextSize           = 12,
        Font               = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size               = UDim2.new(1, 0, 1, 0),
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 14,
        Name               = "Label",
    }, btn)
    Pad(0, 0, 0, 11, btnLabel)

    -- content scroll frame
    local frame = N("ScrollingFrame", {
        Name                   = name .. "_Content",
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
            t._frame.Visible = false
            Tw(t._label, { TextColor3 = T.TextMuted, Font = Enum.Font.Gotham }, 0.12)
            Tw(t._btn,   { BackgroundTransparency = 1 }, 0.12)
        end
        frame.Visible = true
        Tw(btnLabel, { TextColor3 = T.Black, Font = Enum.Font.GothamBold }, 0.12)
        Tw(btn, {
            BackgroundColor3     = T.White,
            BackgroundTransparency = 0,
        }, 0.15)
    end

    btn.MouseButton1Click:Connect(Activate)
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then task.defer(Activate) end

    -- ── Section ──────────────────────────────────────────────────────────────

    function tab:CreateSection(text)
        MakeSection(text, frame)
    end

    -- ── Label ────────────────────────────────────────────────────────────────

    function tab:CreateLabel(opts)
        opts = opts or {}
        local lbl = N("TextLabel", {
            Text               = opts.Text or "",
            TextColor3         = opts.Color or T.TextSub,
            TextSize           = 11,
            Font               = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size               = UDim2.new(1, 0, 0, 20),
            TextXAlignment     = Enum.TextXAlignment.Left,
            TextWrapped        = true,
            ZIndex             = frame.ZIndex + 1,
        }, frame)
        Pad(0, 0, 0, 6, lbl)
        local ctrl = {}
        function ctrl:Set(v) lbl.Text = v end
        function ctrl:Get() return lbl.Text end
        return ctrl
    end

    -- ── Toggle ───────────────────────────────────────────────────────────────

    function tab:CreateToggle(opts)
        opts = opts or {}
        local state = opts.Default or false
        local el, hov = MakeElement(opts, frame)

        local track = N("Frame", {
            BackgroundColor3 = state and T.White or T.B2,
            Size             = UDim2.new(0, 40, 0, 22),
            Position         = UDim2.new(1, -54, 0.5, -11),
            ZIndex           = el.ZIndex + 2,
        }, el)
        Corner(11, track)
        Stroke(1, state and T.White or T.B3, track)

        local thumb = N("Frame", {
            BackgroundColor3 = state and T.Black or Color3.fromRGB(70, 70, 70),
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = state and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
            ZIndex           = el.ZIndex + 3,
        }, track)
        Corner(7, thumb)

        local function SetState(v)
            state = v
            Spring(thumb, {
                Position         = v and UDim2.new(1, -18, 0.5, -7) or UDim2.new(0, 4, 0.5, -7),
                BackgroundColor3 = v and T.Black or Color3.fromRGB(70, 70, 70),
            }, 0.28)
            Tw(track, {
                BackgroundColor3 = v and T.White or T.B2,
            }, 0.18)
            Tw(track:FindFirstChildOfClass("UIStroke"), {
                Color = v and T.White or T.B3,
            }, 0.18)
            if opts.Callback then opts.Callback(state) end
        end

        hov.MouseButton1Click:Connect(function() SetState(not state) end)

        local ctrl = {}
        function ctrl:Set(v) SetState(v) end
        function ctrl:Get() return state end
        return ctrl
    end

    -- ── Button ───────────────────────────────────────────────────────────────

    function tab:CreateButton(opts)
        opts = opts or {}
        local el, hov = MakeElement(opts, frame)

        local btn2 = N("TextButton", {
            Text             = opts.ButtonText or "Execute",
            TextColor3       = T.Black,
            TextSize         = 11,
            Font             = Enum.Font.GothamBold,
            BackgroundColor3 = T.White,
            Size             = UDim2.new(0, 0, 0, 28),
            AutomaticSize    = Enum.AutomaticSize.X,
            Position         = UDim2.new(1, -14, 0.5, -14),
            AnchorPoint      = Vector2.new(1, 0),
            AutoButtonColor  = false,
            ZIndex           = el.ZIndex + 2,
        }, el)
        Pad(0, 14, 0, 14, btn2)
        Corner(8, btn2)

        btn2.MouseButton1Click:Connect(function()
            Tw(btn2, { BackgroundColor3 = Color3.fromRGB(200, 200, 200) }, 0.07)
            task.delay(0.12, function()
                Tw(btn2, { BackgroundColor3 = T.White }, 0.12)
            end)
            if opts.Callback then opts.Callback() end
        end)

        btn2.MouseEnter:Connect(function()
            Tw(btn2, { BackgroundColor3 = Color3.fromRGB(220, 220, 220) }, 0.12)
        end)
        btn2.MouseLeave:Connect(function()
            Tw(btn2, { BackgroundColor3 = T.White }, 0.12)
        end)

        if opts.Ghost then
            btn2.BackgroundColor3 = T.S3
            btn2.TextColor3       = T.TextSub
            Stroke(1, T.B2, btn2)
        end
    end

    -- ── Slider ───────────────────────────────────────────────────────────────

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

        -- header row
        local head = N("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 18),
            ZIndex = el.ZIndex + 1,
        }, el)
        List(Enum.FillDirection.Horizontal, 0, head)

        N("TextLabel", {
            Text               = opts.Title or "Slider",
            TextColor3         = T.Text,
            TextSize           = 12,
            Font               = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            Size               = UDim2.new(1, -52, 1, 0),
            TextXAlignment     = Enum.TextXAlignment.Left,
            LayoutOrder        = 1,
            ZIndex             = el.ZIndex + 2,
        }, head)

        local valLbl = N("TextLabel", {
            Text               = tostring(val),
            TextColor3         = T.White,
            TextSize           = 10,
            Font               = Enum.Font.GothamBold,
            BackgroundColor3   = T.S3,
            Size               = UDim2.new(0, 48, 1, 0),
            TextXAlignment     = Enum.TextXAlignment.Center,
            LayoutOrder        = 2,
            ZIndex             = el.ZIndex + 2,
        }, head)
        Corner(5, valLbl)
        Stroke(1, T.B2, valLbl)

        -- track
        local track = N("Frame", {
            BackgroundColor3 = T.B2,
            Size             = UDim2.new(1, 0, 0, 3),
            Position         = UDim2.new(0, 0, 1, -3),
            ZIndex           = el.ZIndex + 1,
        }, el)
        Corner(2, track)

        local pctInit = (val - min) / (max - min)
        local fill = N("Frame", {
            BackgroundColor3 = T.White,
            Size             = UDim2.new(pctInit, 0, 1, 0),
            ZIndex           = el.ZIndex + 2,
        }, track)
        Corner(2, fill)

        local thumb = N("Frame", {
            BackgroundColor3 = T.White,
            Size             = UDim2.new(0, 14, 0, 14),
            Position         = UDim2.new(pctInit, -7, 0.5, -7),
            ZIndex           = el.ZIndex + 3,
        }, track)
        Corner(7, thumb)
        Stroke(2, T.Black, thumb)
        Shadow(thumb, 4, 0.5, 1)

        -- interaction
        local drag = false
        local function Update(x)
            local p = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            val = math.round(min + (max - min) * p)
            valLbl.Text = tostring(val)
            fill.Size   = UDim2.new(p, 0, 1, 0)
            thumb.Position = UDim2.new(p, -7, 0.5, -7)
            if opts.Callback then opts.Callback(val) end
        end

        local hitbox = N("TextButton", {
            BackgroundTransparency = 1,
            Size     = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, -13),
            Text     = "",
            ZIndex   = el.ZIndex + 5,
        }, track)

        hitbox.MouseButton1Down:Connect(function()
            drag = true
            Spring(thumb, { Size = UDim2.new(0, 18, 0, 18), Position = UDim2.new(thumb.Position.X.Scale, -9, 0.5, -9) }, 0.2)
        end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 and drag then
                drag = false
                Spring(thumb, { Size = UDim2.new(0, 14, 0, 14) }, 0.2)
            end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if drag and i.UserInputType == Enum.UserInputType.MouseMovement then
                Update(i.Position.X)
                thumb.Position = UDim2.new(
                    math.clamp((i.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1),
                    -9, 0.5, -9
                )
            end
        end)

        local ctrl = {}
        function ctrl:Set(v)
            val = math.clamp(v, min, max)
            local p = (val - min) / (max - min)
            valLbl.Text    = tostring(val)
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
        local selected = opts.Default  or options[1] or "Select"
        local open     = false

        local el, hov = MakeElement(opts, frame)

        local ddBtn = N("Frame", {
            BackgroundColor3 = T.S3,
            Size             = UDim2.new(0, 140, 0, 28),
            Position         = UDim2.new(1, -154, 0.5, -14),
            ZIndex           = el.ZIndex + 2,
            ClipsDescendants = false,
        }, el)
        Corner(8, ddBtn)
        Stroke(1, T.B2, ddBtn)
        Shadow(ddBtn, 8, 0.3, 3)

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
            Position           = UDim2.new(1, -22, 0, 0),
            Size               = UDim2.new(0, 18, 1, 0),
            ZIndex             = el.ZIndex + 3,
        }, ddBtn)

        local panel = N("Frame", {
            BackgroundColor3 = T.S2,
            Size             = UDim2.new(0, 140, 0, (#options * 30) + 10),
            Position         = UDim2.new(0, 0, 1, 6),
            Visible          = false,
            ZIndex           = 99,
            ClipsDescendants = true,
        }, ddBtn)
        Corner(10, panel)
        Stroke(1, T.B2, panel)
        Shadow(panel, 16, 0.6, 6)
        Pad(5, 5, 5, 5, panel)
        List(Enum.FillDirection.Vertical, 2, panel)

        for _, opt in ipairs(options) do
            local o = N("TextButton", {
                Text             = opt,
                TextColor3       = opt == selected and T.White or T.TextSub,
                TextSize         = 11,
                Font             = opt == selected and Enum.Font.GothamSemibold or Enum.Font.Gotham,
                BackgroundColor3 = opt == selected and T.S3 or T.S2,
                BackgroundTransparency = opt == selected and 0 or 1,
                Size             = UDim2.new(1, 0, 0, 26),
                AutoButtonColor  = false,
                ZIndex           = 100,
            }, panel)
            Corner(7, o)

            o.MouseButton1Click:Connect(function()
                selected = opt
                ddLabel.Text = opt
                panel.Visible = false
                open = false
                Tw(arrow, { Rotation = 0 }, 0.18)
                for _, c in ipairs(panel:GetChildren()) do
                    if c:IsA("TextButton") then
                        Tw(c, {
                            BackgroundTransparency = 1,
                            TextColor3 = T.TextSub,
                        }, 0.1)
                    end
                end
                Tw(o, { BackgroundTransparency = 0, BackgroundColor3 = T.S3, TextColor3 = T.White }, 0.1)
                if opts.Callback then opts.Callback(selected) end
            end)

            o.MouseEnter:Connect(function()
                if opt ~= selected then
                    Tw(o, { BackgroundTransparency = 0, BackgroundColor3 = T.B1 }, 0.1)
                end
            end)
            o.MouseLeave:Connect(function()
                if opt ~= selected then
                    Tw(o, { BackgroundTransparency = 1 }, 0.1)
                end
            end)
        end

        local hitbox = N("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = el.ZIndex + 4,
        }, ddBtn)

        hitbox.MouseButton1Click:Connect(function()
            open = not open
            panel.Visible = open
            Tw(arrow, { Rotation = open and 180 or 0 }, 0.2)
        end)

        local ctrl = {}
        function ctrl:Set(v) selected = v ddLabel.Text = v end
        function ctrl:Get() return selected end
        function ctrl:Refresh(newOpts)
            for _, c in ipairs(panel:GetChildren()) do
                if c:IsA("TextButton") then c:Destroy() end
            end
            options = newOpts
        end
        return ctrl
    end

    -- ── Color Picker ─────────────────────────────────────────────────────────

    function tab:CreateColorPicker(opts)
        opts = opts or {}
        local color = opts.Default or Color3.new(1, 1, 1)
        local r, g, b = 255, 255, 255

        local el, hov = MakeElement(opts, frame)

        local swatch = N("Frame", {
            BackgroundColor3 = color,
            Size             = UDim2.new(0, 32, 0, 32),
            Position         = UDim2.new(1, -46, 0.5, -16),
            ZIndex           = el.ZIndex + 2,
        }, el)
        Corner(9, swatch)
        Stroke(2, T.B2, swatch)
        Shadow(swatch, 8, 0.4, 2)

        local pickerOpen = false
        local picker = N("Frame", {
            BackgroundColor3 = T.S2,
            Size             = UDim2.new(0, 210, 0, 130),
            Position         = UDim2.new(0, -168, 1, 8),
            Visible          = false,
            ZIndex           = 98,
            ClipsDescendants = true,
        }, swatch)
        Corner(12, picker)
        Stroke(1, T.B2, picker)
        Shadow(picker, 20, 0.7, 6)
        Pad(12, 12, 12, 12, picker)

        -- swatches row
        local swatchRow = N("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            ZIndex = picker.ZIndex + 1,
        }, picker)
        List(Enum.FillDirection.Horizontal, 4, swatchRow)

        local presets = {
            Color3.new(1,1,1), Color3.new(0,0,0),
            Color3.fromRGB(255,70,70), Color3.fromRGB(255,160,0),
            Color3.fromRGB(255,230,0), Color3.fromRGB(70,220,70),
            Color3.fromRGB(70,140,255), Color3.fromRGB(180,80,255),
            Color3.fromRGB(255,80,180), Color3.fromRGB(0,230,200),
        }

        for _, preset in ipairs(presets) do
            local ps = N("TextButton", {
                BackgroundColor3 = preset,
                Size = UDim2.new(0, 20, 0, 20),
                Text = "",
                AutoButtonColor = false,
                ZIndex = picker.ZIndex + 2,
            }, swatchRow)
            Corner(5, ps)
            ps.MouseButton1Click:Connect(function()
                r, g, b = math.round(preset.R * 255), math.round(preset.G * 255), math.round(preset.B * 255)
                color = Color3.fromRGB(r, g, b)
                swatch.BackgroundColor3 = color
                if opts.Callback then opts.Callback(color) end
            end)
        end

        -- channel sliders
        local channels = {
            { label = "R", initVal = 255, color = Color3.fromRGB(180, 40, 40), key = "r" },
            { label = "G", initVal = 255, color = Color3.fromRGB(40, 160, 40), key = "g" },
            { label = "B", initVal = 255, color = Color3.fromRGB(40, 80, 200), key = "b" },
        }

        local chHolder = N("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -30),
            Position = UDim2.new(0, 0, 0, 30),
            ZIndex = picker.ZIndex + 1,
        }, picker)
        List(Enum.FillDirection.Vertical, 6, chHolder)

        for _, ch in ipairs(channels) do
            local row = N("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                ZIndex = chHolder.ZIndex + 1,
            }, chHolder)
            List(Enum.FillDirection.Horizontal, 6, row)

            N("TextLabel", {
                Text               = ch.label,
                TextColor3         = T.TextMuted,
                TextSize           = 9,
                Font               = Enum.Font.GothamBold,
                BackgroundTransparency = 1,
                Size               = UDim2.new(0, 10, 1, 0),
                TextXAlignment     = Enum.TextXAlignment.Left,
                LayoutOrder        = 1,
                ZIndex             = row.ZIndex + 1,
            }, row)

            local cTrack = N("Frame", {
                BackgroundColor3 = T.B1,
                Size             = UDim2.new(1, -40, 0, 3),
                LayoutOrder      = 2,
                ZIndex           = row.ZIndex + 1,
                AnchorPoint      = Vector2.new(0, 0.5),
            }, row)
            Corner(2, cTrack)

            local cFill = N("Frame", {
                BackgroundColor3 = ch.color,
                Size             = UDim2.new(1, 0, 1, 0),
                ZIndex           = row.ZIndex + 2,
            }, cTrack)
            Corner(2, cFill)

            local cThumb = N("Frame", {
                BackgroundColor3 = T.White,
                Size             = UDim2.new(0, 10, 0, 10),
                Position         = UDim2.new(1, -5, 0.5, -5),
                ZIndex           = row.ZIndex + 3,
            }, cTrack)
            Corner(5, cThumb)

            local cValLbl = N("TextLabel", {
                Text               = "255",
                TextColor3         = T.TextMuted,
                TextSize           = 9,
                Font               = Enum.Font.GothamBold,
                BackgroundTransparency = 1,
                Size               = UDim2.new(0, 24, 1, 0),
                TextXAlignment     = Enum.TextXAlignment.Right,
                LayoutOrder        = 3,
                ZIndex             = row.ZIndex + 1,
            }, row)

            local cDrag = false
            local cHit = N("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 20),
                Position = UDim2.new(0, 0, 0.5, -10),
                Text = "", ZIndex = row.ZIndex + 4,
            }, cTrack)

            cHit.MouseButton1Down:Connect(function() cDrag = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then cDrag = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if cDrag and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local p = math.clamp((i.Position.X - cTrack.AbsolutePosition.X) / cTrack.AbsoluteSize.X, 0, 1)
                    local v = math.round(p * 255)
                    cFill.Size = UDim2.new(p, 0, 1, 0)
                    cThumb.Position = UDim2.new(p, -5, 0.5, -5)
                    cValLbl.Text = tostring(v)
                    if ch.key == "r" then r = v
                    elseif ch.key == "g" then g = v
                    else b = v end
                    color = Color3.fromRGB(r, g, b)
                    swatch.BackgroundColor3 = color
                    if opts.Callback then opts.Callback(color) end
                end
            end)
        end

        local swHit = N("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "", ZIndex = el.ZIndex + 4,
        }, swatch)
        swHit.MouseButton1Click:Connect(function()
            pickerOpen = not pickerOpen
            picker.Visible = pickerOpen
        end)

        local ctrl = {}
        function ctrl:Set(c)
            color = c
            swatch.BackgroundColor3 = c
            r, g, b = math.round(c.R * 255), math.round(c.G * 255), math.round(c.B * 255)
        end
        function ctrl:Get() return color end
        return ctrl
    end

    -- ── TextInput ────────────────────────────────────────────────────────────

    function tab:CreateInput(opts)
        opts = opts or {}
        local el, hov = MakeElement(opts, frame)

        local box = N("TextBox", {
            Text                 = opts.Default or "",
            PlaceholderText      = opts.Placeholder or "Type here...",
            PlaceholderColor3    = T.B3,
            TextColor3           = T.TextSub,
            TextSize             = 11,
            Font                 = Enum.Font.Gotham,
            BackgroundColor3     = T.S3,
            Size                 = UDim2.new(0, 140, 0, 26),
            Position             = UDim2.new(1, -154, 0.5, -13),
            ClearTextOnFocus     = opts.ClearOnFocus ~= nil and opts.ClearOnFocus or true,
            ZIndex               = el.ZIndex + 2,
        }, el)
        Corner(8, box)
        Stroke(1, T.B2, box)
        Pad(0, 10, 0, 10, box)

        box.Focused:Connect(function()
            Tw(box:FindFirstChildOfClass("UIStroke"), { Color = T.B3 }, 0.15)
            Tw(box, { TextColor3 = T.Text }, 0.15)
        end)
        box.FocusLost:Connect(function(enter)
            Tw(box:FindFirstChildOfClass("UIStroke"), { Color = T.B2 }, 0.15)
            Tw(box, { TextColor3 = T.TextSub }, 0.15)
            if enter and opts.Callback then opts.Callback(box.Text) end
        end)

        local ctrl = {}
        function ctrl:Set(v) box.Text = v end
        function ctrl:Get() return box.Text end
        return ctrl
    end

    -- ── Keybind ──────────────────────────────────────────────────────────────

    function tab:CreateKeybind(opts)
        opts = opts or {}
        local key       = opts.Default or Enum.KeyCode.F
        local listening = false

        local el, hov = MakeElement(opts, frame)

        local kBtn = N("TextButton", {
            Text             = key.Name,
            TextColor3       = T.TextSub,
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            BackgroundColor3 = T.S3,
            Size             = UDim2.new(0, 80, 0, 26),
            Position         = UDim2.new(1, -94, 0.5, -13),
            AutoButtonColor  = false,
            ZIndex           = el.ZIndex + 2,
        }, el)
        Corner(7, kBtn)
        Stroke(1, T.B2, kBtn)

        kBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            kBtn.Text = "..."
            Tw(kBtn, { TextColor3 = T.White }, 0.1)
            Tw(kBtn:FindFirstChildOfClass("UIStroke"), { Color = T.White }, 0.1)
        end)

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp or not listening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                listening = false
                kBtn.Text = key.Name
                Tw(kBtn, { TextColor3 = T.TextSub }, 0.15)
                Tw(kBtn:FindFirstChildOfClass("UIStroke"), { Color = T.B2 }, 0.15)
                if opts.Callback then opts.Callback(key) end
            end
        end)

        local ctrl = {}
        function ctrl:Get() return key end
        return ctrl
    end

    -- ── Separator ────────────────────────────────────────────────────────────

    function tab:CreateSeparator()
        N("Frame", {
            BackgroundColor3 = T.B1,
            Size             = UDim2.new(1, 0, 0, 1),
            BorderSizePixel  = 0,
            ZIndex           = frame.ZIndex + 1,
        }, frame)
    end

    return tab
end

-- ─── Sidebar section label ────────────────────────────────────────────────────

function ONYX:AddSidebarLabel(text)
    N("TextLabel", {
        Text               = string.upper(text),
        TextColor3         = T.TextMuted,
        TextSize           = 9,
        Font               = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size               = UDim2.new(1, 0, 0, 22),
        TextXAlignment     = Enum.TextXAlignment.Left,
        ZIndex             = 14,
    }, self._sideInner)
end

-- ─── Return ───────────────────────────────────────────────────────────────────

return ONYX
