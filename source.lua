-- ONYX UI Library v1.0
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/yourrepo/onyx/main/onyx.lua"))()

local ONYX = {}
ONYX.__index = ONYX

local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService       = game:GetService("RunService")
local Players          = game:GetService("Players")
local LocalPlayer      = Players.LocalPlayer
local Mouse            = LocalPlayer:GetMouse()

-- ─── Theme ───────────────────────────────────────────────────────────────────

local Theme = {
    Background    = Color3.fromRGB(13, 13, 13),
    Surface       = Color3.fromRGB(17, 17, 17),
    Sidebar       = Color3.fromRGB(8, 8, 8),
    Border        = Color3.fromRGB(26, 26, 26),
    Topbar        = Color3.fromRGB(13, 13, 13),
    Text          = Color3.fromRGB(221, 221, 221),
    TextMuted     = Color3.fromRGB(58, 58, 58),
    TextSecondary = Color3.fromRGB(100, 100, 100),
    AccentOn      = Color3.fromRGB(255, 255, 255),
    AccentOff     = Color3.fromRGB(31, 31, 31),
    ThumbOn       = Color3.fromRGB(0, 0, 0),
    ThumbOff      = Color3.fromRGB(58, 58, 58),
    ButtonPrimary = Color3.fromRGB(255, 255, 255),
    ButtonText    = Color3.fromRGB(0, 0, 0),
    ButtonGhost   = Color3.fromRGB(20, 20, 20),
    SectionText   = Color3.fromRGB(42, 42, 42),
    NotifBg       = Color3.fromRGB(17, 17, 17),
    Pill          = Color3.fromRGB(42, 42, 42),
    DangerAccent  = Color3.fromRGB(192, 82, 74),
}

-- ─── Utility ─────────────────────────────────────────────────────────────────

local function Tween(obj, props, dur, style, dir)
    local info = TweenInfo.new(dur or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out)
    TweenService:Create(obj, info, props):Play()
end

local function Spring(obj, props, dur)
    Tween(obj, props, dur or 0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    handle.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

local function NewInstance(class, props, parent)
    local inst = Instance.new(class)
    for k, v in pairs(props) do inst[k] = v end
    if parent then inst.Parent = parent end
    return inst
end

local function Corner(radius, parent)
    return NewInstance("UICorner", {CornerRadius = UDim.new(0, radius)}, parent)
end

local function Stroke(thickness, color, parent)
    local s = NewInstance("UIStroke", {Thickness = thickness, Color = color or Theme.Border}, parent)
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    return s
end

local function Padding(t, r, b, l, parent)
    return NewInstance("UIPadding", {
        PaddingTop    = UDim.new(0, t or 0),
        PaddingRight  = UDim.new(0, r or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft   = UDim.new(0, l or 0),
    }, parent)
end

local function ListLayout(dir, gap, parent)
    return NewInstance("UIListLayout", {
        FillDirection       = dir or Enum.FillDirection.Vertical,
        SortOrder           = Enum.SortOrder.LayoutOrder,
        Padding             = UDim.new(0, gap or 6),
    }, parent)
end

-- ─── Root ScreenGui ──────────────────────────────────────────────────────────

local function GetGui()
    local gui
    if syn and syn.protect_gui then
        gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
    elseif gethui then
        gui = Instance.new("ScreenGui")
        gui.Parent = gethui()
    else
        gui = Instance.new("ScreenGui")
        gui.Parent = LocalPlayer.PlayerGui
    end
    gui.Name = "ONYXHub"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    return gui
end

-- ─── Notification System ─────────────────────────────────────────────────────

local NotifHolder

local function InitNotifications(gui)
    NotifHolder = NewInstance("Frame", {
        Name              = "Notifications",
        BackgroundTransparency = 1,
        Position          = UDim2.new(1, -20, 1, -20),
        AnchorPoint       = Vector2.new(1, 1),
        Size              = UDim2.new(0, 280, 1, -20),
        ZIndex            = 100,
    }, gui)
    local layout = ListLayout(Enum.FillDirection.Vertical, 8, NotifHolder)
    layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end

function ONYX:Notify(opts)
    opts = opts or {}
    local title   = opts.Title   or "ONYX"
    local content = opts.Content or "Notification."
    local duration = opts.Duration or 3

    local card = NewInstance("Frame", {
        Name = "Notif",
        BackgroundColor3 = Theme.NotifBg,
        Size = UDim2.new(1, 0, 0, 62),
        ClipsDescendants = true,
        ZIndex = 100,
    }, NotifHolder)
    Corner(12, card)
    Stroke(1, Theme.Border, card)

    -- Icon
    local icon = NewInstance("Frame", {
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size = UDim2.new(0, 30, 0, 30),
        Position = UDim2.new(0, 13, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        ZIndex = 101,
    }, card)
    Corner(8, icon)
    NewInstance("TextLabel", {
        Text = "✦",
        TextColor3 = Color3.fromRGB(0,0,0),
        TextSize = 14,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        ZIndex = 102,
    }, icon)

    -- Title
    NewInstance("TextLabel", {
        Text = title,
        TextColor3 = Color3.fromRGB(255,255,255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0, 10),
        Size = UDim2.new(1, -62, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 101,
    }, card)

    -- Message
    NewInstance("TextLabel", {
        Text = content,
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 52, 0, 28),
        Size = UDim2.new(1, -62, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true,
        ZIndex = 101,
    }, card)

    -- Progress bar
    local bar = NewInstance("Frame", {
        BackgroundColor3 = Color3.fromRGB(255,255,255),
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -2),
        ZIndex = 103,
    }, card)
    Tween(bar, {Size = UDim2.new(0, 0, 0, 2)}, duration, Enum.EasingStyle.Linear)

    -- Slide in
    card.Position = UDim2.new(1.2, 0, 0, 0)
    Spring(card, {Position = UDim2.new(0, 0, 0, 0)}, 0.35)

    -- Auto dismiss
    task.delay(duration, function()
        Tween(card, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
        task.wait(0.32)
        card:Destroy()
    end)

    return card
end

-- ─── Window ──────────────────────────────────────────────────────────────────

function ONYX:CreateWindow(opts)
    opts = opts or {}
    local self = setmetatable({}, ONYX)
    self._tabs       = {}
    self._activeTab  = nil
    self._gui        = GetGui()
    self._open       = true

    InitNotifications(self._gui)

    -- Main frame
    local win = NewInstance("Frame", {
        Name             = "OnyxWindow",
        BackgroundColor3 = Theme.Background,
        Size             = opts.Size or UDim2.new(0, 580, 0, 400),
        Position         = opts.Position or UDim2.new(0.5, -290, 0.5, -200),
        ClipsDescendants = true,
    }, self._gui)
    Corner(16, win)
    Stroke(1, Theme.Border, win)
    self._win = win

    -- Topbar
    local topbar = NewInstance("Frame", {
        Name             = "Topbar",
        BackgroundColor3 = Theme.Topbar,
        Size             = UDim2.new(1, 0, 0, 44),
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, win)

    -- iOS pill
    NewInstance("Frame", {
        BackgroundColor3 = Theme.Pill,
        Size             = UDim2.new(0, 38, 0, 4),
        Position         = UDim2.new(0.5, -19, 0.5, -2),
        ZIndex           = 3,
    }, topbar).Parent = topbar
    Corner(2, topbar:FindFirstChildWhichIsA("Frame"))

    -- Separator under topbar
    NewInstance("Frame", {
        BackgroundColor3 = Theme.Border,
        Size             = UDim2.new(1, 0, 0, 1),
        Position         = UDim2.new(0, 0, 1, -1),
        BorderSizePixel  = 0,
        ZIndex           = 2,
    }, topbar)

    -- Title left
    NewInstance("TextLabel", {
        Text             = opts.Title or "ONYX",
        TextColor3       = Color3.fromRGB(255,255,255),
        TextSize         = 12,
        Font             = Enum.Font.GothamBold,
        BackgroundTransparency = 1,
        Size             = UDim2.new(0, 120, 1, 0),
        Position         = UDim2.new(0, 14, 0, 0),
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 3,
    }, topbar)

    MakeDraggable(win, topbar)

    -- Sidebar
    local sidebar = NewInstance("Frame", {
        Name             = "Sidebar",
        BackgroundColor3 = Theme.Sidebar,
        Size             = UDim2.new(0, 155, 1, -44),
        Position         = UDim2.new(0, 0, 0, 44),
        ClipsDescendants = true,
    }, win)

    -- Sidebar right border
    NewInstance("Frame", {
        BackgroundColor3 = Theme.Border,
        Size             = UDim2.new(0, 1, 1, 0),
        Position         = UDim2.new(1, -1, 0, 0),
        BorderSizePixel  = 0,
    }, sidebar)

    local sideList = NewInstance("Frame", {
        BackgroundTransparency = 1,
        Size   = UDim2.new(1, -12, 1, -16),
        Position = UDim2.new(0, 6, 0, 8),
    }, sidebar)
    ListLayout(Enum.FillDirection.Vertical, 2, sideList)
    self._sideList = sideList

    -- Content area
    local contentArea = NewInstance("Frame", {
        Name             = "ContentArea",
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, -155, 1, -44),
        Position         = UDim2.new(0, 155, 0, 44),
        ClipsDescendants = true,
    }, win)
    self._contentArea = contentArea

    -- Toggle keybind
    local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == toggleKey then
            self._open = not self._open
            win.Visible = self._open
        end
    end)

    -- Bind Notify to window scope
    function self:Notify(o) return ONYX.Notify(self, o) end

    return self
end

-- ─── Tab ─────────────────────────────────────────────────────────────────────

function ONYX:CreateTab(name, icon)
    local tab    = {}
    local isActive = false

    -- Sidebar button
    local btn = NewInstance("TextButton", {
        Name             = name,
        BackgroundColor3 = Color3.fromRGB(17,17,17),
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 0, 34),
        Text             = "",
        AutoButtonColor  = false,
        ZIndex           = 2,
    }, self._sideList)
    Corner(9, btn)

    -- Icon label (emoji or text)
    NewInstance("TextLabel", {
        Text             = (icon or "◆") .. "  " .. name,
        TextColor3       = Theme.TextSecondary,
        TextSize         = 12,
        Font             = Enum.Font.Gotham,
        BackgroundTransparency = 1,
        Size             = UDim2.new(1, 0, 1, 0),
        TextXAlignment   = Enum.TextXAlignment.Left,
        ZIndex           = 3,
        Name             = "Label",
    }, btn)
    Padding(0, 0, 0, 10, btn)

    -- Tab content frame
    local frame = NewInstance("ScrollingFrame", {
        Name                      = name .. "Frame",
        BackgroundTransparency    = 1,
        Size                      = UDim2.new(1, 0, 1, 0),
        Visible                   = false,
        ScrollBarThickness        = 2,
        ScrollBarImageColor3      = Color3.fromRGB(31,31,31),
        CanvasSize                = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize       = Enum.AutomaticSize.Y,
        ClipsDescendants          = true,
    }, self._contentArea)
    Padding(14, 14, 14, 14, frame)
    ListLayout(Enum.FillDirection.Vertical, 7, frame)

    tab._frame  = frame
    tab._btn    = btn
    tab._window = self

    -- Activate logic
    local function Activate()
        for _, t in ipairs(self._tabs) do
            t._frame.Visible = false
            local lbl = t._btn:FindFirstChild("Label")
            if lbl then
                Tween(lbl, {TextColor3 = Theme.TextSecondary}, 0.12)
            end
            Tween(t._btn, {BackgroundTransparency = 1}, 0.12)
        end
        frame.Visible = true
        local lbl = btn:FindFirstChild("Label")
        if lbl then
            Tween(lbl, {TextColor3 = Color3.fromRGB(0,0,0)}, 0.12)
        end
        Tween(btn, {BackgroundColor3 = Color3.fromRGB(255,255,255), BackgroundTransparency = 0}, 0.12)
        self._activeTab = tab
    end

    btn.MouseButton1Click:Connect(Activate)
    table.insert(self._tabs, tab)

    if #self._tabs == 1 then
        task.defer(Activate)
    end

    -- ── Element builders ──────────────────────────────────────────────────────

    local function SectionHeader(text)
        local row = NewInstance("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
        }, frame)
        ListLayout(Enum.FillDirection.Horizontal, 7, row)

        NewInstance("TextLabel", {
            Text = string.upper(text),
            TextColor3 = Theme.SectionText,
            TextSize = 9,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            LayoutOrder = 1,
        }, row)

        NewInstance("Frame", {
            BackgroundColor3 = Theme.Border,
            Size = UDim2.new(1, 0, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BorderSizePixel = 0,
            LayoutOrder = 2,
        }, row)
    end

    local function Element(opts2)
        local el = NewInstance("Frame", {
            BackgroundColor3 = Theme.Surface,
            Size = UDim2.new(1, 0, 0, 46),
        }, frame)
        Corner(10, el)
        Stroke(1, Theme.Border, el)

        local info = NewInstance("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.55, 0, 1, 0),
            Position = UDim2.new(0, 13, 0, 0),
        }, el)

        NewInstance("TextLabel", {
            Text = opts2.Title or "",
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 20),
            Position = UDim2.new(0, 0, 0.5, -10),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, info)

        if opts2.Description then
            NewInstance("TextLabel", {
                Text = opts2.Description,
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                Font = Enum.Font.Gotham,
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 14),
                Position = UDim2.new(0, 0, 0.5, 10),
                TextXAlignment = Enum.TextXAlignment.Left,
            }, info)
        end

        return el, info
    end

    -- Toggle
    function tab:CreateToggle(opts2)
        opts2 = opts2 or {}
        local state = opts2.Default or false
        local el, _ = Element(opts2)

        local track = NewInstance("Frame", {
            BackgroundColor3 = state and Theme.AccentOn or Theme.AccentOff,
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, -50, 0.5, -10),
        }, el)
        Corner(10, track)

        local thumb = NewInstance("Frame", {
            BackgroundColor3 = state and Theme.ThumbOn or Theme.ThumbOff,
            Size = UDim2.new(0, 14, 0, 14),
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7),
        }, track)
        Corner(7, thumb)

        local btn = NewInstance("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Text = "",
            ZIndex = 3,
        }, track)

        btn.MouseButton1Click:Connect(function()
            state = not state
            Tween(track, {BackgroundColor3 = state and Theme.AccentOn or Theme.AccentOff}, 0.18)
            Spring(thumb, {
                BackgroundColor3 = state and Theme.ThumbOn or Theme.ThumbOff,
                Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
            }, 0.22)
            if opts2.Callback then opts2.Callback(state) end
        end)

        local ctrl = {}
        function ctrl:Set(v)
            state = v
            Tween(track, {BackgroundColor3 = state and Theme.AccentOn or Theme.AccentOff}, 0.18)
            Spring(thumb, {
                BackgroundColor3 = state and Theme.ThumbOn or Theme.ThumbOff,
                Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
            }, 0.22)
        end
        function ctrl:Get() return state end
        return ctrl
    end

    -- Button
    function tab:CreateButton(opts2)
        opts2 = opts2 or {}
        local el, _ = Element(opts2)

        local btn = NewInstance("TextButton", {
            Text             = opts2.ButtonText or "Execute",
            TextColor3       = Theme.ButtonText,
            TextSize         = 11,
            Font             = Enum.Font.GothamBold,
            BackgroundColor3 = Theme.ButtonPrimary,
            Size             = UDim2.new(0, 0, 0, 28),
            AutomaticSize    = Enum.AutomaticSize.X,
            Position         = UDim2.new(1, -14, 0.5, -14),
            AnchorPoint      = Vector2.new(1, 0),
            ZIndex           = 3,
        }, el)
        Padding(0, 14, 0, 14, btn)
        Corner(8, btn)

        btn.MouseButton1Click:Connect(function()
            Tween(btn, {BackgroundColor3 = Color3.fromRGB(200,200,200)}, 0.08)
            task.delay(0.15, function()
                Tween(btn, {BackgroundColor3 = Theme.ButtonPrimary}, 0.15)
            end)
            if opts2.Callback then opts2.Callback() end
        end)
    end

    -- Slider
    function tab:CreateSlider(opts2)
        opts2 = opts2 or {}
        local min   = opts2.Min     or 0
        local max   = opts2.Max     or 100
        local value = opts2.Default or min

        local el = NewInstance("Frame", {
            BackgroundColor3 = Theme.Surface,
            Size = UDim2.new(1, 0, 0, 56),
        }, frame)
        Corner(10, el)
        Stroke(1, Theme.Border, el)
        Padding(12, 13, 12, 13, el)

        local head = NewInstance("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 16),
        }, el)
        ListLayout(Enum.FillDirection.Horizontal, 0, head)

        NewInstance("TextLabel", {
            Text = opts2.Title or "Slider",
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -60, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            LayoutOrder = 1,
        }, head)

        local valLabel = NewInstance("TextLabel", {
            Text = tostring(value),
            TextColor3 = Color3.fromRGB(255,255,255),
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            BackgroundColor3 = Color3.fromRGB(26,26,26),
            Size = UDim2.new(0, 50, 1, 0),
            TextXAlignment = Enum.TextXAlignment.Center,
            LayoutOrder = 2,
        }, head)
        Corner(5, valLabel)
        Stroke(1, Theme.Border, valLabel)

        -- Track
        local track = NewInstance("Frame", {
            BackgroundColor3 = Color3.fromRGB(31,31,31),
            Size = UDim2.new(1, 0, 0, 3),
            Position = UDim2.new(0, 0, 1, -3),
        }, el)
        Corner(2, track)

        local fill = NewInstance("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new((value-min)/(max-min), 0, 1, 0),
        }, track)
        Corner(2, fill)

        local thumb = NewInstance("Frame", {
            BackgroundColor3 = Color3.fromRGB(255,255,255),
            Size = UDim2.new(0, 13, 0, 13),
            Position = UDim2.new((value-min)/(max-min), -7, 0.5, -7),
        }, track)
        Corner(7, thumb)
        Stroke(2, Color3.fromRGB(13,13,13), thumb)

        -- Interaction
        local dragging = false
        local function Update(input)
            local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * pct)
            valLabel.Text = tostring(value)
            Tween(fill,  {Size = UDim2.new(pct, 0, 1, 0)}, 0.05)
            Tween(thumb, {Position = UDim2.new(pct, -7, 0.5, -7)}, 0.05)
            if opts2.Callback then opts2.Callback(value) end
        end

        local hitbox = NewInstance("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 30),
            Position = UDim2.new(0, 0, 0, -14),
            Text = "", ZIndex = 4,
        }, track)
        hitbox.MouseButton1Down:Connect(function() dragging = true end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then Update(i) end
        end)

        local ctrl = {}
        function ctrl:Set(v)
            value = math.clamp(v, min, max)
            local pct = (value - min) / (max - min)
            valLabel.Text = tostring(value)
            Tween(fill,  {Size = UDim2.new(pct, 0, 1, 0)}, 0.12)
            Tween(thumb, {Position = UDim2.new(pct, -7, 0.5, -7)}, 0.12)
        end
        function ctrl:Get() return value end
        return ctrl
    end

    -- Dropdown
    function tab:CreateDropdown(opts2)
        opts2 = opts2 or {}
        local options  = opts2.Options  or {}
        local selected = opts2.Default  or options[1] or "Select"
        local open     = false

        local el = NewInstance("Frame", {
            BackgroundColor3 = Theme.Surface,
            Size = UDim2.new(1, 0, 0, 46),
            ClipsDescendants = false,
            ZIndex = 2,
        }, frame)
        Corner(10, el)
        Stroke(1, Theme.Border, el)

        NewInstance("TextLabel", {
            Text = opts2.Title or "Dropdown",
            TextColor3 = Theme.Text,
            TextSize = 12,
            Font = Enum.Font.GothamSemibold,
            BackgroundTransparency = 1,
            Size = UDim2.new(0.5, 0, 1, 0),
            Position = UDim2.new(0, 13, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
        }, el)

        local ddBtn = NewInstance("Frame", {
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            Size = UDim2.new(0, 140, 0, 28),
            Position = UDim2.new(1, -154, 0.5, -14),
            ZIndex = 5,
        }, el)
        Corner(8, ddBtn)
        Stroke(1, Theme.Border, ddBtn)

        local ddLabel = NewInstance("TextLabel", {
            Text = selected,
            TextColor3 = Theme.TextSecondary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -24, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 6,
        }, ddBtn)

        NewInstance("TextLabel", {
            Text = "⌄",
            TextColor3 = Theme.TextMuted,
            TextSize = 14,
            Font = Enum.Font.GothamBold,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 20, 1, 0),
            Position = UDim2.new(1, -24, 0, 0),
            ZIndex = 6,
        }, ddBtn)

        -- Dropdown panel
        local panel = NewInstance("Frame", {
            BackgroundColor3 = Color3.fromRGB(17,17,17),
            Size = UDim2.new(0, 140, 0, #options * 30 + 12),
            Position = UDim2.new(0, 0, 1, 6),
            Visible = false,
            ZIndex = 20,
        }, ddBtn)
        Corner(10, panel)
        Stroke(1, Theme.Border, panel)
        Padding(6, 6, 6, 6, panel)
        ListLayout(Enum.FillDirection.Vertical, 2, panel)

        for _, opt in ipairs(options) do
            local optBtn = NewInstance("TextButton", {
                Text = opt,
                TextColor3 = opt == selected and Color3.fromRGB(255,255,255) or Theme.TextSecondary,
                TextSize = 11,
                Font = Enum.Font.Gotham,
                BackgroundColor3 = opt == selected and Color3.fromRGB(22,22,22) or Color3.fromRGB(17,17,17),
                Size = UDim2.new(1, 0, 0, 26),
                AutoButtonColor = false,
                ZIndex = 21,
            }, panel)
            Corner(7, optBtn)

            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                ddLabel.Text = opt
                panel.Visible = false
                open = false
                -- Reset others
                for _, c in ipairs(panel:GetChildren()) do
                    if c:IsA("TextButton") then
                        Tween(c, {BackgroundColor3 = Color3.fromRGB(17,17,17), TextColor3 = Theme.TextSecondary}, 0.1)
                    end
                end
                Tween(optBtn, {BackgroundColor3 = Color3.fromRGB(22,22,22), TextColor3 = Color3.fromRGB(255,255,255)}, 0.1)
                if opts2.Callback then opts2.Callback(selected) end
            end)
        end

        local hitbox = NewInstance("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Text = "", ZIndex = 7,
        }, ddBtn)
        hitbox.MouseButton1Click:Connect(function()
            open = not open
            panel.Visible = open
        end)

        local ctrl = {}
        function ctrl:Set(v) ddLabel.Text = v selected = v end
        function ctrl:Get() return selected end
        return ctrl
    end

    -- Color Picker
    function tab:CreateColorPicker(opts2)
        opts2 = opts2 or {}
        local color = opts2.Default or Color3.new(1,1,1)

        local el, _ = Element(opts2)

        local swatch = NewInstance("Frame", {
            BackgroundColor3 = color,
            Size = UDim2.new(0, 32, 0, 32),
            Position = UDim2.new(1, -46, 0.5, -16),
            ZIndex = 3,
        }, el)
        Corner(8, swatch)
        Stroke(2, Theme.Border, swatch)

        -- Hue slider (simple RGB channels via a Frame picker)
        local pickerOpen = false
        local picker = NewInstance("Frame", {
            BackgroundColor3 = Color3.fromRGB(17,17,17),
            Size = UDim2.new(0, 200, 0, 120),
            Position = UDim2.new(1, -214, 1, 8),
            Visible = false,
            ZIndex = 15,
        }, el)
        Corner(12, picker)
        Stroke(1, Theme.Border, picker)
        Padding(12,12,12,12, picker)

        local function MakeChannel(label, r, g, b, yOff)
            NewInstance("TextLabel", {
                Text = label,
                TextColor3 = Theme.TextMuted,
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 14, 0, 16),
                Position = UDim2.new(0, 0, 0, yOff),
                ZIndex = 16,
            }, picker)

            local cTrack = NewInstance("Frame", {
                BackgroundColor3 = Color3.fromRGB(31,31,31),
                Size = UDim2.new(1, -28, 0, 3),
                Position = UDim2.new(0, 18, 0, yOff + 7),
                ZIndex = 16,
            }, picker)
            Corner(2, cTrack)

            local initV = label == "R" and r or label == "G" and g or b
            local cFill = NewInstance("Frame", {
                BackgroundColor3 = Color3.fromRGB(
                    label == "R" and 255 or 80,
                    label == "G" and 255 or 80,
                    label == "B" and 255 or 80
                ),
                Size = UDim2.new(initV, 0, 1, 0),
                ZIndex = 17,
            }, cTrack)
            Corner(2, cFill)

            local cThumb = NewInstance("Frame", {
                BackgroundColor3 = Color3.fromRGB(255,255,255),
                Size = UDim2.new(0, 10, 0, 10),
                Position = UDim2.new(initV, -5, 0.5, -5),
                ZIndex = 18,
            }, cTrack)
            Corner(5, cThumb)

            local draggingC = false
            local hitC = NewInstance("TextButton", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 22),
                Position = UDim2.new(0, 0, 0, -10),
                Text = "", ZIndex = 19,
            }, cTrack)
            hitC.MouseButton1Down:Connect(function() draggingC = true end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 then draggingC = false end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if draggingC and i.UserInputType == Enum.UserInputType.MouseMovement then
                    local pct = math.clamp((i.Position.X - cTrack.AbsolutePosition.X) / cTrack.AbsoluteSize.X, 0, 1)
                    Tween(cFill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.04)
                    Tween(cThumb, {Position = UDim2.new(pct, -5, 0.5, -5)}, 0.04)
                    -- Rebuild color from channels (simplified, just white tint by pct)
                    local rv = label == "R" and pct or color.R
                    local gv = label == "G" and pct or color.G
                    local bv = label == "B" and pct or color.B
                    color = Color3.new(rv, gv, bv)
                    swatch.BackgroundColor3 = color
                    if opts2.Callback then opts2.Callback(color) end
                end
            end)
        end

        local rv, gv, bv = color.R, color.G, color.B
        MakeChannel("R", rv, gv, bv, 0)
        MakeChannel("G", rv, gv, bv, 30)
        MakeChannel("B", rv, gv, bv, 60)

        local swBtn = NewInstance("TextButton", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1,0,1,0),
            Text = "", ZIndex = 4,
        }, swatch)
        swBtn.MouseButton1Click:Connect(function()
            pickerOpen = not pickerOpen
            picker.Visible = pickerOpen
        end)

        local ctrl = {}
        function ctrl:Set(c) color = c swatch.BackgroundColor3 = c end
        function ctrl:Get() return color end
        return ctrl
    end

    -- TextInput
    function tab:CreateInput(opts2)
        opts2 = opts2 or {}
        local el, _ = Element(opts2)

        local box = NewInstance("TextBox", {
            Text             = "",
            PlaceholderText  = opts2.Placeholder or "Type here...",
            PlaceholderColor3 = Color3.fromRGB(46,46,46),
            TextColor3       = Theme.TextSecondary,
            TextSize         = 11,
            Font             = Enum.Font.Gotham,
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            Size             = UDim2.new(0, 140, 0, 26),
            Position         = UDim2.new(1, -154, 0.5, -13),
            ClearTextOnFocus = opts2.ClearOnFocus ~= nil and opts2.ClearOnFocus or true,
            ZIndex           = 3,
        }, el)
        Corner(8, box)
        Stroke(1, Theme.Border, box)
        Padding(0, 10, 0, 10, box)

        box.FocusLost:Connect(function(enter)
            if enter and opts2.Callback then opts2.Callback(box.Text) end
        end)

        local ctrl = {}
        function ctrl:Set(v) box.Text = v end
        function ctrl:Get() return box.Text end
        return ctrl
    end

    -- Keybind
    function tab:CreateKeybind(opts2)
        opts2 = opts2 or {}
        local key = opts2.Default or Enum.KeyCode.F
        local listening = false

        local el, _ = Element(opts2)

        local kBtn = NewInstance("TextButton", {
            Text             = key.Name,
            TextColor3       = Theme.TextSecondary,
            TextSize         = 10,
            Font             = Enum.Font.GothamBold,
            BackgroundColor3 = Color3.fromRGB(20,20,20),
            Size             = UDim2.new(0, 80, 0, 26),
            Position         = UDim2.new(1, -94, 0.5, -13),
            AutoButtonColor  = false,
            ZIndex           = 3,
        }, el)
        Corner(7, kBtn)
        Stroke(1, Theme.Border, kBtn)

        kBtn.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            kBtn.Text = "..."
            Tween(kBtn, {TextColor3 = Color3.fromRGB(255,255,255)}, 0.1)
        end)

        UserInputService.InputBegan:Connect(function(input, gp)
            if gp or not listening then return end
            if input.UserInputType == Enum.UserInputType.Keyboard then
                key = input.KeyCode
                listening = false
                kBtn.Text = key.Name
                Tween(kBtn, {TextColor3 = Theme.TextSecondary}, 0.1)
                if opts2.Callback then opts2.Callback(key) end
            end
        end)

        local ctrl = {}
        function ctrl:Get() return key end
        return ctrl
    end

    -- Section header exposed
    function tab:CreateSection(text)
        SectionHeader(text)
    end

    -- Label
    function tab:CreateLabel(opts2)
        opts2 = opts2 or {}
        local lbl = NewInstance("TextLabel", {
            Text = opts2.Text or "",
            TextColor3 = opts2.Color or Theme.TextSecondary,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 22),
            TextXAlignment = Enum.TextXAlignment.Left,
            TextWrapped = true,
        }, frame)
        Padding(0, 0, 0, 6, lbl)

        local ctrl = {}
        function ctrl:Set(v) lbl.Text = v end
        return ctrl
    end

    return tab
end

return ONYX
