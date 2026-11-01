--[[
    EXAMPLE USAGE — paste after library or use loadstring
]]

local Library = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/yourrepo/onyx/main/onyx.lua"
))()

local Win = Library:CreateWindow({
    Title     = "ONYX",
    Subtitle  = "v2.0",
    Size      = UDim2.new(0, 600, 0, 420),
    ToggleKey = Enum.KeyCode.RightShift,
})

-- ── Main tab
local Main = Win:CreateTab("Main", "◈")

Main:CreateSection("Movement")

local SpeedToggle = Main:CreateToggle({
    Title       = "Speed boost",
    Description = "Multiplies walk speed",
    Default     = false,
    Callback    = function(v)
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v and 100 or 16 end
    end,
})

local SpeedSlider = Main:CreateSlider({
    Title    = "Walk speed",
    Min      = 16,
    Max      = 250,
    Default  = 100,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.WalkSpeed = v end
    end,
})

local JumpSlider = Main:CreateSlider({
    Title    = "Jump power",
    Min      = 50,
    Max      = 500,
    Default  = 200,
    Callback = function(v)
        local hum = game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = v end
    end,
})

Main:CreateSection("Actions")

Main:CreateButton({
    Title      = "Rejoin server",
    Description = "Teleport to fresh instance",
    ButtonText = "Execute",
    Callback   = function()
        Win:Notify({ Title = "Rejoining...", Content = "Finding optimal server.", Duration = 3 })
        task.delay(1.5, function()
            game:GetService("TeleportService"):Teleport(game.PlaceId)
        end)
    end,
})

Main:CreateToggle({
    Title       = "Noclip",
    Description = "Phase through geometry",
    Default     = false,
    Callback    = function(v)
        local char = game.Players.LocalPlayer.Character
        if not char then return end
        game:GetService("RunService").Stepped:Connect(function()
            if v then
                for _, p in ipairs(char:GetDescendants()) do
                    if p:IsA("BasePart") then p.CanCollide = false end
                end
            end
        end)
    end,
})

-- ── Player tab
local Player = Win:CreateTab("Player", "◉")

Player:CreateSection("Targeting")

local TargetDrop = Player:CreateDropdown({
    Title    = "Target mode",
    Description = "Who to lock onto",
    Options  = { "Nearest", "Random", "Lowest HP", "Highest HP", "Anyone" },
    Default  = "Nearest",
    Callback = function(v)
        print("Target mode set to:", v)
    end,
})

Player:CreateSection("Identity")

local TagInput = Player:CreateInput({
    Title       = "Custom tag",
    Description = "Name shown above head",
    Placeholder = "Enter tag...",
    Callback    = function(v)
        print("Tag set to:", v)
    end,
})

local ToggleKey = Player:CreateKeybind({
    Title       = "Toggle keybind",
    Description = "Show / hide the hub",
    Default     = Enum.KeyCode.RightShift,
    Callback    = function(k)
        Win:Notify({ Title = "Keybind updated", Content = "Now using: " .. k.Name, Duration = 2.5 })
    end,
})

Player:CreateToggle({
    Title       = "Anti-AFK",
    Description = "Prevents auto-kick",
    Default     = true,
    Callback    = function(v)
        print("Anti-AFK:", v)
    end,
})

-- ── Visuals tab
local Visuals = Win:CreateTab("Visuals", "◇")

Visuals:CreateSection("ESP")

Visuals:CreateToggle({
    Title       = "Player ESP",
    Description = "Draw boxes around players",
    Default     = false,
    Callback    = function(v)
        print("ESP:", v)
    end,
})

local ESPColor = Visuals:CreateColorPicker({
    Title       = "ESP color",
    Description = "Highlight tint for boxes",
    Default     = Color3.new(1, 1, 1),
    Callback    = function(c)
        print("ESP color changed:", c)
    end,
})

Visuals:CreateToggle({
    Title       = "Chams",
    Description = "See players through walls",
    Default     = false,
    Callback    = function(v)
        print("Chams:", v)
    end,
})

Visuals:CreateSection("World")

Visuals:CreateToggle({
    Title       = "Fullbright",
    Description = "Removes ambient darkness",
    Default     = false,
    Callback    = function(v)
        game:GetService("Lighting").Brightness = v and 10 or 1
        game:GetService("Lighting").FogEnd     = v and 1e6 or 1000
    end,
})

local FOVSlider = Visuals:CreateSlider({
    Title    = "FOV circle",
    Min      = 10,
    Max      = 300,
    Default  = 80,
    Callback = function(v)
        print("FOV:", v)
    end,
})

-- ── Combat tab
local Combat = Win:CreateTab("Combat", "◎")

Combat:CreateSection("Aimbot")

Combat:CreateToggle({
    Title       = "Aimbot",
    Description = "Lock aim to nearest target",
    Default     = false,
    Callback    = function(v)
        print("Aimbot:", v)
    end,
})

Combat:CreateSlider({
    Title    = "Smoothness",
    Min      = 0,
    Max      = 100,
    Default  = 60,
    Callback = function(v)
        print("Smooth:", v)
    end,
})

Combat:CreateDropdown({
    Title    = "Target part",
    Options  = { "Head", "Torso", "HumanoidRootPart", "LeftArm", "RightArm" },
    Default  = "Head",
    Callback = function(v)
        print("Part:", v)
    end,
})

Combat:CreateSection("Modifiers")

Combat:CreateToggle({
    Title       = "No-recoil",
    Description = "Locks camera drift",
    Default     = true,
    Callback    = function(v) print("No-recoil:", v) end,
})

Combat:CreateToggle({
    Title       = "Silent aim",
    Description = "Hit detection override",
    Danger      = true,
    Default     = false,
    Callback    = function(v) print("Silent aim:", v) end,
})

-- ── Welcome
Win:Notify({
    Title    = "ONYX loaded",
    Content  = "Hub active. RShift to toggle.",
    Duration = 4,
})
