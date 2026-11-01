-- Mono UI Library / LocalScript source
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local Mono = {}
Mono.__index = Mono

local theme = {
    Black = Color3.fromRGB(12, 12, 12),
    White = Color3.fromRGB(245, 245, 245),
    Gray = Color3.fromRGB(125, 125, 125),
    Line = Color3.fromRGB(38, 38, 38)
}

local function create(className, properties)
    local instance = Instance.new(className)
    for property, value in pairs(properties) do
        instance[property] = value
    end
    return instance
end

function Mono:CreateWindow(config)
    local gui = create("ScreenGui", {
        Name = "MonoUI",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = game.Players.LocalPlayer.PlayerGui
    })

    local frame = create("Frame", {
        Name = "Window",
        Size = UDim2.fromOffset(620, 420),
        Position = UDim2.fromScale(.5, .5),
        AnchorPoint = Vector2.new(.5, .5),
        BackgroundColor3 = theme.White,
        BorderColor3 = theme.Black,
        BorderSizePixel = 1,
        Parent = gui
    })

    local topbar = create("Frame", {
        Name = "Topbar",
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = theme.Black,
        BorderSizePixel = 0,
        Parent = frame
    })

    local title = create("TextLabel", {
        Size = UDim2.new(1, -24, 1, 0),
        Position = UDim2.fromOffset(12, 0),
        BackgroundTransparency = 1,
        Text = config.Title or "MONO",
        TextColor3 = theme.White,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        Parent = topbar
    })

    local window = {Gui = gui, Frame = frame, Tabs = {}}

    function window:CreateTab(name)
        local tab = {Name = name, Sections = {}}
        table.insert(self.Tabs, tab)

        function tab:CreateSection(sectionName)
            local section = {Name = sectionName, Controls = {}}
            table.insert(self.Sections, section)

            function section:AddToggle(options)
                table.insert(self.Controls, {Type = "Toggle", Data = options})
                return self
            end

            function section:AddSlider(options)
                table.insert(self.Controls, {Type = "Slider", Data = options})
                return self
            end

            function section:AddDropdown(options)
                table.insert(self.Controls, {Type = "Dropdown", Data = options})
                return self
            end

            function section:AddButton(options)
                table.insert(self.Controls, {Type = "Button", Data = options})
                return self
            end

            return section
        end

        return tab
    end

    UIS.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == (config.Keybind or Enum.KeyCode.RightShift) then
            gui.Enabled = not gui.Enabled
        end
    end)

    return window
end

return Mono
