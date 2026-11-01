--[[
    Lumina UI Library v3.1 (Fixed & Production Ready)
    - Bottom iOS Grabber Pill Dragging with 0.2s Smooth Delay
    - Dynamic Lighting Blur Effect
    - Layered Soft Drop Shadows
    - Animated Toast Notifications with Countdown Bars
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()

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

-- Smooth Bottom iOS Bar Dragging Mechanism (0.2s lag/interpolation feel)
local function MakeSmoothBottomDraggable(dragHandle, targetFrame)
    local dragging = false
    local dragInput, dragStart, startPos
    local targetPos = targetFrame.Position

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.AbsolutePosition

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
            local screenGui = targetFrame.Parent
            if screenGui then
                local newX = startPos.X + delta.X
                local newY = startPos.Y + delta.Y
                targetPos = UDim2.new(0, newX + (targetFrame.AbsoluteSize.X / 2), 0, newY + (targetFrame.AbsoluteSize.Y / 2))
            end
        end
    end)

    RunService.RenderStepped:Connect(function(dt)
        if dragging or (targetFrame.Position - targetPos).Magnitude > 0.1 then
            local currentPos = targetFrame.Position
            local alpha = math.clamp(dt * 12, 0, 1)
            targetFrame.Position = UDim2.new(
                currentPos.X.Scale, currentPos.X.Offset + (targetPos.X.Offset - currentPos.X.Offset) * alpha,
                currentPos.Y.Scale, currentPos.Y.Offset + (targetPos.Y.Offset - currentPos.Y.Offset) * alpha
            )
        end
    end)
end

function Lumina:CreateWindow(config)
    config = config or {}
    local titleText = config.Title or "LUMINA UI"

    -- Robust parent container resolution for both Studio and Executors
    local success, parentGui = pcall(function()
        return (syn and CoreGui) or (gethui and gethui()) or LocalPlayer:WaitForChild("PlayerGui")
    end)
    if not success or not parentGui then
        parentGui = LocalPlayer:WaitForChild("PlayerGui")
    end

    if parentGui:FindFirstChild("LuminaUI") then
        parentGui.LuminaUI:Destroy()
    end

    -- Dynamic Blur Effect (Fluent Style)
    local Blur = Lighting:FindFirstChild("LuminaBlur")
    if not Blur then
        Blur = Instance.new("BlurEffect")
        Blur.Name = "LuminaBlur"
        Blur.Size = 12
        Blur.Parent = Lighting
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "LuminaUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = parentGui

    ScreenGui.Destroying:Connect(function()
        if Blur then Blur:Destroy() end
    end)

    -- Notification Holder Container (Top-Right)
    local NotifHolder = Instance.new("Frame")
    NotifHolder.Name = "NotificationHolder"
    NotifHolder.Size = UDim2.new(0, 300, 1, -40)
    NotifHolder.Position = UDim2.new(1, -315, 0, 20)
    NotifHolder.BackgroundTransparency = 1
    NotifHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout")
    NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 8)
    NotifLayout.Parent = NotifHolder

    -- Rayfield/WindUI Soft Drop Shadow Container
    local ShadowHolder = Instance.new("ImageLabel")
    ShadowHolder.Name = "ShadowHolder"
    ShadowHolder.Size = UDim2.new(0, 580, 0, 380)
    ShadowHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
    ShadowHolder.AnchorPoint = Vector2.new(0.5, 0.5)
    ShadowHolder.BackgroundTransparency = 1
    ShadowHolder.Image = "rbxassetid://6014261993"
    ShadowHolder.ImageColor3 = Color3.fromRGB(0, 0, 0)
    ShadowHolder.ImageTransparency = 0.3
    ShadowHolder.ScaleType = Enum.ScaleType.Slice
    ShadowHolder.SliceCenter = Rect.new(49, 49, 450, 450)
    ShadowHolder.Parent = ScreenGui

    -- Main Container Frame (Background Transparency: 0.34)
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(1, 0, 1, 0)
    MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 13)
    MainFrame.BackgroundTransparency = 0.34
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ShadowHolder

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.85
    MainStroke.Thickness = 1.2
    MainStroke.Parent = MainFrame

    -- Header Bar
    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundColor3 = Color3.fromRGB(16, 16, 20)
    Header.BackgroundTransparency = 0.2
    Header.BorderSizePixel = 0
    Header.Parent = MainFrame

    local HeaderCorner = Instance.new("UICorner")
    HeaderCorner.CornerRadius = UDim.new(0, 12)
    HeaderCorner.Parent = Header

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(1, -20, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = titleText
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 13
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header

    -- Bottom iOS Grabber Bar (Draggable Handle)
    local BottomBarHolder = Instance.new("Frame")
    BottomBarHolder.Name = "BottomBarHolder"
    BottomBarHolder.Size = UDim2.new(1, 0, 0, 22)
    BottomBarHolder.Position = UDim2.new(0, 0, 1, -22)
    BottomBarHolder.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
    BottomBarHolder.BackgroundTransparency = 0.5
    BottomBarHolder.BorderSizePixel = 0
    BottomBarHolder.Parent = MainFrame

    local BottomCorner = Instance.new("UICorner")
    BottomCorner.CornerRadius = UDim.new(0, 12)
    BottomCorner.Parent = BottomBarHolder

    local iOSGrabber = Instance.new("Frame")
    iOSGrabber.Name = "iOSGrabber"
    iOSGrabber.Size = UDim2.new(0, 44, 0, 4)
    iOSGrabber.Position = UDim2.new(0.5, -22, 0.5, -2)
    iOSGrabber.BackgroundColor3 = Color3.fromRGB(200, 200, 215)
    iOSGrabber.BackgroundTransparency = 0.3
    iOSGrabber.BorderSizePixel = 0
    iOSGrabber.Parent = BottomBarHolder

    local GrabberCorner = Instance.new("UICorner")
    GrabberCorner.CornerRadius = UDim.new(1, 0)
    GrabberCorner.Parent = iOSGrabber

    MakeSmoothBottomDraggable(BottomBarHolder, ShadowHolder)

    -- Sidebar & Content Layout
    local Sidebar = Instance.new("ScrollingFrame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 140, 1, -64)
    Sidebar.Position = UDim2.new(0, 0, 0, 42)
    Sidebar.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
    Sidebar.BackgroundTransparency = 0.6
    Sidebar.BorderSizePixel = 0
    Sidebar.ScrollBarThickness = 2
    Sidebar.Parent = MainFrame

    local SidebarList = Instance.new("UIListLayout")
    SidebarList.SortOrder = Enum.SortOrder.LayoutOrder
    SidebarList.Padding = UDim.new(0, 6)
    SidebarList.Parent = Sidebar

    local SidebarPadding = Instance.new("UIPadding")
    SidebarPadding.PaddingTop = UDim.new(0, 10)
    SidebarPadding.PaddingLeft = UDim.new(0, 8)
    SidebarPadding.PaddingRight = UDim.new(0, 8)
    SidebarPadding.Parent = Sidebar

    local ContainerFolder = Instance.new("Frame")
    ContainerFolder.Name = "Containers"
    ContainerFolder.Size = UDim2.new(1, -140, 1, -64)
    ContainerFolder.Position = UDim2.new(0, 140, 0, 42)
    ContainerFolder.BackgroundTransparency = 1
    ContainerFolder.Parent = MainFrame

    local WindowObj = { Tabs = {}, CurrentTab = nil }

    -- Toast Notification System with Animated Countdown Bar
    function WindowObj:Notify(config)
        config = config or {}
        local title = config.Title or "Notification"
        local content = config.Content or "Action executed successfully."
        local duration = config.Duration or 4

        local NotifCard = Instance.new("Frame")
        NotifCard.Size = UDim2.new(1, 0, 0, 68)
        NotifCard.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
        NotifCard.BackgroundTransparency = 0.2
        NotifCard.Position = UDim2.new(1, 40, 0, 0)
        NotifCard.Parent = NotifHolder

        Instance.new("UICorner", NotifCard).CornerRadius = UDim.new(0, 8)
        local nStroke = Instance.new("UIStroke", NotifCard)
        nStroke.Color = Color3.fromRGB(255, 255, 255)
        nStroke.Transparency = 0.85

        local nTitle = Instance.new("TextLabel", NotifCard)
        nTitle.Size = UDim2.new(1, -20, 0, 20)
        nTitle.Position = UDim2.new(0, 12, 0, 8)
        nTitle.BackgroundTransparency = 1
        nTitle.Text = title
        nTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
        nTitle.TextSize = 12
        nTitle.Font = Enum.Font.GothamBold
        nTitle.TextXAlignment = Enum.TextXAlignment.Left

        local nDesc = Instance.new("TextLabel", NotifCard)
        nDesc.Size = UDim2.new(1, -20, 0, 18)
        nDesc.Position = UDim2.new(0, 12, 0, 28)
        nDesc.BackgroundTransparency = 1
        nDesc.Text = content
        nDesc.TextColor3 = Color3.fromRGB(180, 180, 195)
        nDesc.TextSize = 11
        nDesc.Font = Enum.Font.Gotham
        nDesc.TextXAlignment = Enum.TextXAlignment.Left

        -- Countdown Progress Bar
        local BarTrack = Instance.new("Frame", NotifCard)
        BarTrack.Size = UDim2.new(1, -24, 0, 3)
        BarTrack.Position = UDim2.new(0, 12, 1, -8)
        BarTrack.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        Instance.new("UICorner", BarTrack).CornerRadius = UDim.new(1, 0)

        local BarFill = Instance.new("Frame", BarTrack)
        BarFill.Size = UDim2.new(1, 0, 1, 0)
        BarFill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Instance.new("UICorner", BarFill).CornerRadius = UDim.new(1, 0)

        Tween(NotifCard, {Position = UDim2.new(0, 0, 0, 0)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

        local tweenBar = TweenService:Create(BarFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {Size = UDim2.new(0, 0, 1, 0)})
        tweenBar:Play()

        task.spawn(function()
            task.wait(duration)
            Tween(NotifCard, {Position = UDim2.new(1, 40, 0, 0), BackgroundTransparency = 1}, 0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.In)
            task.wait(0.3)
            NotifCard:Destroy()
        end)
    end

    function WindowObj:CreateTab(tabName)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = tabName .. "_Tab"
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = tabName
        TabButton.TextColor3 = Color3.fromRGB(140, 140, 155)
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
                Tween(t.Button, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(140, 140, 155)}, 0.2)
                t.Container.Visible = false
            end
            Tween(TabButton, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
            Container.Visible = true
            WindowObj.CurrentTab = TabObj
        end

        TabButton.MouseButton1Click:Connect(ActivateTab)
        if #WindowObj.Tabs == 0 then ActivateTab() end
        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:CreateButton(name, callback)
            callback = callback or function() end
            local btn = Instance.new("TextButton")
            btn.Size = UDim2.new(1, 0, 0, 34)
            btn.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
            btn.BackgroundTransparency = 0.3
            btn.AutoButtonColor = false
            btn.Text = ""
            btn.Parent = Container

            Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
            local stroke = Instance.new("UIStroke", btn)
            stroke.Color = Color3.fromRGB(255, 255, 255)
            stroke.Transparency = 0.9

            local lbl = Instance.new("TextLabel", btn)
            lbl.Size = UDim2.new(1, 0, 1, 0)
            lbl.BackgroundTransparency = 1
            lbl.Text = name
            lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.GothamSemibold

            btn.MouseButton1Click:Connect(callback)
        end

        function TabObj:CreateToggle(name, default, callback)
            local toggled = default or false
            callback = callback or function() end

            local frame = Instance.new("Frame", Container)
            frame.Size = UDim2.new(1, 0, 0, 34)
            frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
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
            lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local track = Instance.new("Frame", frame)
            track.Size = UDim2.new(0, 34, 0, 18)
            track.Position = UDim2.new(1, -42, 0.5, -9)
            track.BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(38, 38, 48)
            Instance.new("UICorner", track).CornerRadius = UDim.new(1, 0)

            local knob = Instance.new("Frame", track)
            knob.Size = UDim2.new(0, 12, 0, 12)
            knob.Position = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)
            knob.BackgroundColor3 = toggled and Color3.fromRGB(10, 10, 13) or Color3.fromRGB(160, 160, 175)
            Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

            local btn = Instance.new("TextButton", frame)
            btn.Size = UDim2.new(1, 0, 1, 0)
            btn.BackgroundTransparency = 1
            btn.Text = ""

            btn.MouseButton1Click:Connect(function()
                toggled = not toggled
                Tween(track, {BackgroundColor3 = toggled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(38, 38, 48)})
                Tween(knob, {Position = toggled and UDim2.new(1, -15, 0.5, -6) or UDim2.new(0, 3, 0.5, -6)})
                Tween(knob, {BackgroundColor3 = toggled and Color3.fromRGB(10, 10, 13) or Color3.fromRGB(160, 160, 175)})
                callback(toggled)
            end)
        end

        function TabObj:CreateSlider(name, min, max, default, callback)
            min = min or 0; max = max or 100
            default = math.clamp(default or min, min, max)
            callback = callback or function() end

            local frame = Instance.new("Frame", Container)
            frame.Size = UDim2.new(1, 0, 0, 46)
            frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
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
            lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
            lbl.TextSize = 12
            lbl.Font = Enum.Font.Gotham
            lbl.TextXAlignment = Enum.TextXAlignment.Left

            local vlbl = Instance.new("TextLabel", frame)
            vlbl.Size = UDim2.new(0, 40, 0, 20)
            vlbl.Position = UDim2.new(1, -48, 0, 4)
            vlbl.BackgroundTransparency = 1
            vlbl.Text = tostring(default)
            vlbl.TextColor3 = Color3.fromRGB(180, 180, 195)
            vlbl.TextSize = 11
            vlbl.Font = Enum.Font.GothamMedium
            vlbl.TextXAlignment = Enum.TextXAlignment.Right

            local track = Instance.new("Frame", frame)
            track.Size = UDim2.new(1, -20, 0, 5)
            track.Position = UDim2.new(0, 10, 1, -12)
            track.BackgroundColor3 = Color3.fromRGB(38, 38, 48)
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
            frame.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
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
            lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
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
                optBtn.TextColor3 = Color3.fromRGB(170, 170, 185)
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

        return TabObj
    end

    function WindowObj:Demo()
        local t1 = self:CreateTab("Demo & Features")
        
        t1:CreateButton("Test Notification", function()
            self:Notify({
                Title = "Fluent & WindUI Alert",
                Content = "Countdown progress bar running smoothly!",
                Duration = 4
            })
        end)

        t1:CreateToggle("God Mode", true, function(state) 
            self:Notify({ Title = "Toggle Changed", Content = "GodMode state: " .. tostring(state), Duration = 3 })
        end)

        t1:CreateSlider("WalkSpeed", 16, 120, 16, function(val) end)

        t1:CreateDropdown("Theme Preset", {"Dark", "AMOLED", "Midnight"}, function(opt) 
            self:Notify({ Title = "Preset Loaded", Content = opt .. " mode active.", Duration = 3 })
        end)
    end

    return WindowObj
end

return Lumina
