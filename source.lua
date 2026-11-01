--[[
    Lumina UI Library v1.3 (WindUI, Rayfield & Luna Inspired)
    - Background Transparency: 0.34
    - Soft Rayfield Drop Shadows & iOS Pill Bar
    - Animated Notification System with Countdown Progress Bar
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local Lumina = {}
Lumina.__index = Lumina

local function Tween(instance, properties, duration, style, direction)
    duration = duration or 0.25
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local tween = TweenService:Create(instance, TweenInfo.new(duration, style, direction), properties)
    tween:Play()
    return tween
end

-- iOS Style Pill Bar Draggable Mechanism
local function MakeDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(targetFrame, {
                Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            }, 0.1, Enum.EasingStyle.Sine)
        end
    end)
end

function Lumina:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "LUMINA UI"

    local parentGui = (syn and CoreGui) or LocalPlayer:FindFirstChildOfClass("PlayerGui") or CoreGui
    if parentGui:FindFirstChild("LuminaUI") then
        parentGui.LuminaUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LuminaUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = parentGui

    -- Notification Holder Container (Top-Right)
    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "NotificationHolder"
    NotifHolder.Size = UDim2.new(0, 300, 1, -20)
    NotifHolder.Position = UDim2.new(1, -315, 0, 10)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.Parent = NotifHolder

    -- Rayfield-Style Soft Drop Shadow Container
    local ShadowHolder = Instance.new("ImageLabel")
    ShadowHolder.Name = "ShadowHolder"
    ShadowHolder.Size = UDim2.new(0, 560, 0, 360)
    ShadowHolder.Position = UDim2.new(0.5, -280, 0.5, -180)
    ShadowHolder.BackgroundTransparency = 1
    ShadowHolder.Image = "rbxassetid://6014261993"
    ShadowHolder.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ShadowHolder.ImageTransparency = 0.4
    ShadowHolder.ScaleType = Enum.ScaleType.Slice
    ShadowHolder.SliceCenter = Rect.new(49, 49, 450, 450)
    ShadowHolder.Parent = ScreenGui

    -- Main Frame (Background Transparency: 0.34)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 15)
    MainFrame.BackgroundTransparency = 0.34
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ShadowHolder

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.85
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame

    -- Header with iOS Pill Bar Draggable Handle
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 10)
    HeaderCorner.Parent = Header

    local iOSBar = Instance.new("Frame")
    iOSBar.Name = "iOSBar"
    iOSBar.Size = UDim2.new(0, 36, 0, 4)
    iOSBar.Position = UDim2.new(0.5, -18, 0, 6)
    iOSBar.BackgroundColor3 = Color3.fromRGB(200, 200, 210)
    iOSBar.BackgroundTransparency = 0.4
    iOSBar.BorderSizePixel = 0
    iOSBar.Parent = Header

    local iOSBarCorner = Instance.new("UICorner")
    iOSBarCorner.CornerRadius = UDim.new(1, 0)
    iOSBarCorner.Parent = iOSBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -20, 1, -10)
    TitleLabel.Position = UDim2.new(0, 14, 0, 8)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    MakeDraggable(Header, ShadowHolder)

    -- Sidebar & Content Layout
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 135, 1, -42)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    Sidebar.BackgroundTransparency = 0.5
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Parent = MainFrame

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 5)
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 10)
    SidebarPadding.PaddingLeft = UDim.new(0, 8)
    SidebarPadding.PaddingRight = UDim.new(0, 8)
    SidebarPadding.Parent = Sidebar

    local ContainerFolder = Instance.new("Frame")
    ContainerFolder.Name = "Containers"
    ContainerFolder.Size = UDim2.new(1, -135, 1, -42)
    ContainerFolder.Position = UDim2.new(0, 135, 0, 42)
    ContainerFolder.BackgroundTransparency = 1
    ContainerFolder.Parent = MainFrame

    local WindowObj = { Tabs = {}, CurrentTab = nil }

    -- ================================================================================
    -- NOTIFICATION SYSTEM (WindUI / Luna Style with Shrinking Progress Bar)
    -- ================================================================================
    function WindowObj:Notify(notifConfig)
        local nTitle = notifConfig.Title or "Notification"
        local nContent = notifConfig.Content or ""
        local nDuration = notifConfig.Duration or 4

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Size = UDim2.new(1, 0, 0, 65)
        NotifFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
        NotifFrame.BackgroundTransparency = 0.2
        NotifFrame.BorderSizePixel = 0
        NotifFrame.ClipsDescendants = true
        NotifFrame.Parent = NotifHolder

        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 6)
        NotifCorner.Parent = NotifFrame

        local NotifStroke = Instance.new("UIStroke")
        NotifStroke.Color = Color3.fromRGB(255, 255, 255)
        NotifStroke.Transparency = 0.85
        NotifStroke.Thickness = 1
        NotifStroke.Parent = NotifFrame

        local TitleLbl = Instance.new("TextLabel")
        TitleLbl.Size = UDim2.new(1, -20, 0, 20)
        TitleLbl.Position = UDim2.new(0, 10, 0, 8)
        TitleLbl.BackgroundTransparency = 1
        TitleLbl.Text = nTitle
        TitleLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        TitleLbl.TextSize = 13
        TitleLbl.Font = Enum.Font.GothamBold
        TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
        TitleLbl.Parent = NotifFrame

        local DescLbl = Instance.new("TextLabel")
        DescLbl.Size = UDim2.new(1, -20, 0, 20)
        DescLbl.Position = UDim2.new(0, 10, 0, 28)
        DescLbl.BackgroundTransparency = 1
        DescLbl.Text = nContent
        DescLbl.TextColor3 = Color3.fromRGB(170, 170, 180)
        DescLbl.TextSize = 11
        DescLbl.Font = Enum.Font.Gotham
        DescLbl.TextXAlignment = Enum.TextXAlignment.Left
        DescLbl.Parent = NotifFrame

        -- Countdown Progress Bar Line at bottom
        local ProgressBar = Instance.new("Frame")
        ProgressBar.Size = UDim2.new(1, 0, 0, 3)
        ProgressBar.Position = UDim2.new(0, 0, 1, -3)
        ProgressBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ProgressBar.BorderSizePixel = 0
        ProgressBar.Parent = NotifFrame

        -- Slide-in entry animation
        NotifFrame.Position = UDim2.new(1, 50, 0, 0)
        Tween(NotifFrame, {Position = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        -- Shrink progress bar smoothly over the specified duration
        Tween(ProgressBar, {Size = UDim2.new(0, 0, 0, 3)}, nDuration, Enum.EasingStyle.Linear)

        task.delay(nDuration, function()
            Tween(NotifFrame, {Position = UDim2.new(1, 50, 0, 0)}, 0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.wait(0.3)
            NotifFrame:Destroy()
        end)
    end

    function WindowObj:CreateTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(140, 140, 150)
        TabButton.TextSize = 12
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.Parent = Sidebar

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton

        local Container = Instance.new("ScrollingFrame")
        Container.Name = tabName .. "_Container"
        Container.Size = UDim2.new(1, 0, 1, 0)
        Container.BackgroundTransparency = 1
        Container.BorderSizePixel = 0
        Container.Visible = false
        Container.ScrollBarThickness = 3
        Container.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
        Container.ScrollBarImageTransparency = 0.7
        Container.Parent = ContainerFolder

        local ContainerList = Instance.new("UIListLayout")
        ContainerList.SortOrder = Enum.SortOrder.LayoutOrder
        ContainerList.Padding = UDim.new(0, 8)
        ContainerList.Parent = Container

        local ContainerPadding = Instance.new("UIPadding")
        ContainerPadding.PaddingTop = UDim.new(0, 10)
        ContainerPadding.PaddingLeft = UDim.new(0, 10)
        ContainerPadding.PaddingRight = UDim.new(0, 10)
        ContainerPadding.PaddingBottom = UDim.new(0, 10)
        ContainerPadding.Parent = Container

        ContainerList:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Container.CanvasSize = UDim2.new(0, 0, 0, ContainerList.AbsoluteContentSize.Y + 20)
        end)

        local TabObj = { Button = TabButton, Container = Container }

        local function ActivateTab()
            for _, t in pairs(WindowObj.Tabs) do
                Tween(t.Button, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 150)}, 0.2)
                t.Container.Visible = false
            end
            Tween(TabButton, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            Container.Visible = true
            WindowObj.CurrentTab = TabObj
        end

        TabButton.MouseButton1Click:Connect(ActivateTab)
        if #WindowObj.Tabs == 0 then ActivateTab() end
        table.insert(WindowObj.Tabs, TabObj)

        -- Component Generators
        function TabObj:CreateButton(name, callback)
            callback = callback or function() end
            local btn = Instance.new("TextButton", Container)
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            btn.BackgroundTransparency = 0.3
            btn.AutoButtonColor = false
            btn.Text = ""

            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.9

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.GothamSemibold

            btn.MouseButton1Click:Connect(callback)
        end

        function TabObj:CreateToggle(name, default, callback)
            local toggled = default or false
            callback = callback or function() end

            local frame = Instance.new("Frame", Container)
            frame.Size = UDim2.new(1, 0, 0, 34)
            frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            frame.BackgroundTransparency = 0.3

            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.9

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, -50, 1, 0)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local track = Instance.new("Frame", frame)
            track.Size = UDim2.new(0, 34, 0, 18)
            track.Position = UDim2.new(1, -42, 0.5, -9)
            track.BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 48)
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", track)
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            knob.BackgroundColor3 = toggled and Color3.fromRGB(15, 15, 18) or Color3.fromRGB(160, 160, 170)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""

            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                Tween(track, {BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 48)})
                Tween(knob, {Position = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)})
                callback(toggled)
            end)
        end

        function TabObj:CreateSlider(name, min, max, default, callback)
            min = min or 0; max = max or 100
            default = math.clamp(default or min, min, max)
            callback = callback or function() end

            local frame = Instance.new("Frame", Container)
            frame.Size = UDim2.new(1, 0, 0, 46)
            frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            frame.BackgroundTransparency = 0.3

            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.9

            local lbl = Instance.new("TextLabel", frame)
            lbl.Size = UDim2.new(1, -50, 0, 20)
            lbl.Position = UDim2.new(0, 10, 0, 4)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local vlbl = Instance.new("TextLabel", frame)
            vlbl.Size = UDim2.new(0, 40, 0, 20)
            vlbl.Position = UDim2.new(1, -48, 0, 4)
            vlbl.BackgroundTransparency = 1
            vlbl.Text = tostring(default)
            vlbl.TextColor3 = Color3.fromRGB(180, 180, 190)
            vlbl.TextSize = 11
            vlbl.Font = Enum.Font.GothamMedium
            vlbl.TextXAlignment = Enum.TextXAlignment.Right

            local track = Instance.new("Frame", frame)
            track.Size = UDim2.new(1, -20, 0, 5)
            track.Position = UDim2.new(0, 10, 1, -12)
            track.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local fill = Instance.new("Frame", track)
            fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

            local sliding = false
            local function update(input)
                local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                local val = math.floor(min + (max - min) * pos)
                vlbl.Text = tostring(val)
                fill.Size = UDim2.new(pos, 0, 1, 0)
                callback(val)
            end

            track.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = true; update(input)
                end
            end)
            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    sliding = false
                end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if sliding and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
        end

        function TabObj:CreateDropdown(name, options, callback)
            options = options or {}
            callback = callback or function() end
            local expanded = false

            local frame = Instance.new("Frame", Container)
            frame.Size = UDim2.new(1, 0, 0, 34)
            frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            frame.BackgroundTransparency = 0.3
            frame.ClipsDescendants = true

            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.9

            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundTransparency = 1
            btn.Text = ""

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, -30, 0, 34)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local optList = Instance.new("Frame", frame)
            optList.Size = UDim2.new(1, 0, 0, #options * 26)
            optList.Position = UDim2.new(0, 0, 0, 34)
            optList.BackgroundTransparency = 1
            local listLayout = Instance.new("UIListLayout", optList)
            listLayout.SortOrder = Enum.SortOrder.LayoutOrder

            for _, opt in ipairs(options) do
                local optBtn = Instance.new("TextButton", optList)
                optBtn.Size = UDim2.new(1, 0, 0, 26)
                optBtn.BackgroundTransparency = 1
                optBtn.Text = opt
                optBtn.TextColor3 = Color3.fromRGB(170, 170, 180)
                optBtn.TextSize = 11
                optBtn.Font = Enum.Font.Gotham

                optBtn.MouseButton1Click:Connect(function()
                    lbl.Text = name .. ": " .. opt
                    expanded = false
                    Tween(frame, {Size = UDim2.new(1, 0, 0, 34)})
                    callback(opt)
                end)
            end

            btn.MouseButton1Click:Connect(function()
                expanded = not expanded
                Tween(frame, {Size = UDim2.new(1, 0, 0, expanded and (34 + (#options * 26)) or 34)})
            end)
        end

        function TabObj:CreateColorPicker(name, default, callback)
            default = default or Color3.fromRGB(255, 255, 255)
            callback = callback or function() end
            local expanded = false

            local frame = Instance.new("Frame", Container)
            frame.Size = UDim2.new(1, 0, 0, 34)
            frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            frame.BackgroundTransparency = 0.3
            frame.ClipsDescendants = true

            Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", frame)
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.9

            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundTransparency = 1
            btn.Text = ""

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, -50, 0, 34)
            lbl.Position = UDim2.new(0, 10, 0, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(230, 230, 230)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local preview = Instance.new("Frame", btn)
            preview.Size = UDim2.new(0, 20, 0, 20)
            preview.Position = UDim2.new(1, -28, 0.5, -10)
            preview.BackgroundColor3 = default
            Instance.new("UICorner", preview).CornerRadius = UDim.new(0, 4)

            local hueSlider = Instance.new("Frame", frame)
            hueSlider.Size = UDim2.new(1, -20, 0, 14)
            hueSlider.
