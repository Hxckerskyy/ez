--// Services \\--
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

--// LocalPlayer \\--
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:WaitForChild("Humanoid")
local LocalRootPart = LocalHumanoid.RootPart or LocalCharacter:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")



--// TargetPlayer \\--
local TargetPlayer, TargetCharacter, TargetHumanoid, TargetRootPart = nil, nil, nil, nil

--// Variables \\--
local Connections = {}

--// ScreenGui | Instance & Properties \\--
local ScreeenGui = Instance.new("ScreenGui")
local Fraame = Instance.new("Frame")
local TeextButton = Instance.new("ImageButton")
ScreeenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
ScreeenGui.ResetOnSpawn = false
ScreeenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Fraame.Parent = ScreeenGui
Fraame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Fraame.BackgroundTransparency = 1
Fraame.Position = UDim2.new(0.5, 0, 0.5, 0)
Fraame.Size = UDim2.new(0, 90, 0, 90)
Fraame.Draggable = false
Fraame.Active = true

TeextButton.Parent = Fraame
TeextButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TeextButton.BackgroundTransparency = 0.5
TeextButton.Size = UDim2.new(0, 75, 0, 75)
TeextButton.AnchorPoint = Vector2.new(0.5, 0.5)
TeextButton.Position = UDim2.new(0.5, 0, 0.5, 0)
TeextButton.Draggable = true
TeextButton.Active = true
TeextButton.Image = "rbxassetid://10747366027"

local uiiCorner = Instance.new("UICorner", TeextButton)
uiiCorner.CornerRadius = UDim.new(0, 8)

--// Functions \\--
LocalPlayer.CharacterAdded:Connect(function(Character)
    LocalCharacter = Character
    LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:WaitForChild("Humanoid")
    LocalRootPart = LocalHumanoid.RootPart or LocalCharacter:WaitForChild("HumanoidRootPart")
end)

Players.PlayerRemoving:Connect(function(Player)
    if Player == TargetPlayer then
        for _, connection in pairs({"Camera Lock", "TargetPlayer Respawning"}) do
            if Connections[connection] then
                Connections[connection]:Disconnect()
                Connections[connection] = nil
            end
        end
        TargetPlayer, TargetCharacter, TargetHumanoid, TargetRootPart = nil, nil, nil, nil
        TeextButton.Image = "rbxassetid://10747366027"
    end
end)

local function GetPlayerInMiddleOfScreen()
    local PlayerInMiddleOfScreen, DistanceRadius = nil, math.huge

    for _, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChild("Humanoid") and Player.Character:FindFirstChild("HumanoidRootPart") then
            local MagnitudeDistance = (LocalRootPart.Position - Player.Character.HumanoidRootPart.Position).Magnitude
            local ViewportPoint, OnScreen = Camera:WorldToViewportPoint(Player.Character.HumanoidRootPart.Position)
            local MagnitudeScreen = (Vector2.new(ViewportPoint.X, ViewportPoint.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude

            if OnScreen and MagnitudeScreen <= DistanceRadius then
                PlayerInMiddleOfScreen = Player
                DistanceRadius = MagnitudeDistance
            end
        end
    end

    return PlayerInMiddleOfScreen
end

local function ToggleCamlock()
    local CamlockSettings = getgenv().Settings.Camlock
    if CamlockSettings.Enabled then
        CamlockSettings.Toggle = not CamlockSettings.Toggle
        if CamlockSettings.Toggle then
            TargetPlayer = GetPlayerInMiddleOfScreen()
            if TargetPlayer and TargetPlayer.Character and TargetPlayer.Character:FindFirstChild("Humanoid") then
                TargetCharacter = TargetPlayer.Character
                TargetHumanoid = TargetCharacter:FindFirstChild("Humanoid")
                TargetRootPart = TargetCharacter:FindFirstChild(CamlockSettings.AimPart)

                if not CamlockSettings.Enabled then
                    TargetPlayer = nil
                end

                Connections["Camera Lock"] = RunService.Heartbeat:Connect(function()
                    if TargetRootPart then
                        local Prediction = TargetRootPart.Velocity * CamlockSettings.Prediction
                        Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, TargetRootPart.Position + Prediction)
                    end
                end)

                Connections["TargetPlayer Respawning"] = TargetPlayer.CharacterAdded:Connect(function(Character)
                    TargetCharacter = Character
                    TargetHumanoid = Character:FindFirstChild("Humanoid")
                    TargetRootPart = TargetHumanoid and TargetHumanoid.RootPart
                end)

                TeextButton.Image = "rbxassetid://10723434711"
            end
        else
            for _, connection in pairs({"Camera Lock", "TargetPlayer Respawning"}) do
                if Connections[connection] then
                    Connections[connection]:Disconnect()
                    Connections[connection] = nil
                end
            end
            TargetPlayer, TargetCharacter, TargetHumanoid, TargetRootPart = nil, nil, nil, nil
            TeextButton.Image = "rbxassetid://10747366027"
        end
    end
end

-- Button click event
TeextButton.MouseButton1Click:Connect(ToggleCamlock)

-- Keybind
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == getgenv().Settings.Camlock.Keybind then
        ToggleCamlock()
    end
end)
