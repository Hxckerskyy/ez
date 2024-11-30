

--// Services \\--
local Workspace = Game:GetService("Workspace")
local RunService = Game:GetService("RunService")
local Players = Game:GetService("Players")
local CoreGui = Game:GetService("CoreGui")

local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

--// LocalPlayer \\--
local LocalPlayer = Players.LocalPlayer
local LocalCharacter = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local LocalHumanoid = LocalCharacter:FindFirstChildOfClass("Humanoid") or LocalCharacter:WaitForChild("Humanoid")
local LocalRootPart = LocalHumanoid.RootPart or LocalCharacter:WaitForChild("HumanoidRootPart")
local Camera = Workspace.CurrentCamera or Workspace:FindFirstChildOfClass("Camera")


--// TargetPlayer \\--
local TargetPlayer = nil
local TargetCharacter = nil
local TargetHumanoid = nil
local TargetRootPart = nil

--// Variables \\--
local Connections = {}

--// Script Settings \\--


--// ScreenGui | Instance & Properties \\--
local ScreeenGui = Instance.new("ScreenGui")
local Fraame = Instance.new("Frame")
local TeextButton = Instance.new("ImageButton")
ScreeenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
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
        if Connections["Camera Lock"] then
            Connections["Camera Lock"]:Disconnect()
            Connections["Camera Lock"] = nil
        end
        
        if Connections["TargetPlayer Respawning"] then
            Connections["TargetPlayer Respawning"]:Disconnect()
            Connections["TargetPlayer Respawning"] = nil
        end
        
        TargetPlayer = nil
        TargetCharacter = nil
        TargetHumanoid = nil
        TargetRootPart = nil
        TeextButton.Image = "rbxassetid://10747366027"
    end
end)

local function GetPlayerInMiddleOfScreen()
    local PlayerInMiddleOfScreen = nil
    local DistanceRadius = math.huge
    
    for Index, Player in ipairs(Players:GetPlayers()) do
        if Player ~= LocalPlayer and Player.Character and Player.Character:FindFirstChildOfClass("Humanoid") and Player.Character:FindFirstChildOfClass("Humanoid").RootPart and LocalCharacter and LocalHumanoid and LocalRootPart then
            local MagnitudeDistance = (LocalRootPart.Position - Player.Character:FindFirstChildOfClass("Humanoid").RootPart.Position).Magnitude
            local ViewportPointPosition, OnScreen = Camera:WorldToViewportPoint(Player.Character:FindFirstChildOfClass("Humanoid").RootPart.Position)
            local MagnitudeScreen = (Vector2.new(ViewportPointPosition.X, ViewportPointPosition.Y) - Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)).Magnitude
            
            if not OnScreen then continue end
            
            if DistanceRadius >= MagnitudeScreen then
                if DistanceRadius >= MagnitudeDistance then
                    PlayerInMiddleOfScreen = Player
                    DistanceRadius = MagnitudeDistance
                end
            end
        end
    end
    
    return PlayerInMiddleOfScreen
end

local function ToggleCamlock()
    if Script.Settings.Camlock.Enabled then
        Script.Settings.Camlock.Toggle = not Script.Settings.Camlock.Toggle
        
        if Script.Settings.Camlock.Toggle then
            -- Get the target player in the middle of the screen
            TargetPlayer = GetPlayerInMiddleOfScreen()
            
            if TargetPlayer then
                if TargetPlayer.Character and TargetPlayer.Character:FindFirstChildOfClass("Humanoid") and TargetPlayer.Character:FindFirstChildOfClass("Humanoid").RootPart then
                    TargetCharacter = TargetPlayer.Character
                    TargetHumanoid = TargetCharacter:FindFirstChildOfClass("Humanoid")
                    TargetRootPart = TargetHumanoid.RootPart
                    
                    -- Camera lock logic
                    Connections["Camera Lock"] = RunService.Heartbeat:Connect(function(DeltaTime)
                        if TargetCharacter:FindFirstChild(Script.Settings.Camlock.AimPart) and TargetCharacter:FindFirstChild(Script.Settings.Camlock.AimPart):IsA("BasePart") then
                            local AimPart = TargetCharacter:FindFirstChild(Script.Settings.Camlock.AimPart)
                            local Velocity = AimPart.Velocity
                            local Prediction = Velocity * Script.Settings.Camlock.Prediction
                            local AimingPosition = AimPart.Position + Prediction
                            
                            Camera.CFrame = CFrame.lookAt(Camera.CFrame.Position, AimingPosition)
                        end
                    end)
                end
                
                -- Listen for character respawn and update target info
                Connections["TargetPlayer Respawning"] = TargetPlayer.CharacterAdded:Connect(function(Character)
                    TargetCharacter = Character
                    TargetHumanoid = TargetCharacter:FindFirstChildOfClass("Humanoid") or TargetCharacter:WaitForChild("Humanoid")
                    TargetRootPart = TargetHumanoid.RootPart or TargetCharacter:WaitForChild("HumanoidRootPart")
                end)
                
                -- Change button image when Camlock is active
                TeextButton.Image = "rbxassetid://10723434711"
            end
            
        else
            -- Disconnect connections when Camlock is disabled
            if Connections["Camera Lock"] then
                Connections["Camera Lock"]:Disconnect()
                Connections["Camera Lock"] = nil
            end
            
            if Connections["TargetPlayer Respawning"] then
                Connections["TargetPlayer Respawning"]:Disconnect()
                Connections["TargetPlayer Respawning"] = nil
            end
            
            TargetPlayer = nil
            TargetCharacter = nil
            TargetHumanoid = nil
            TargetRootPart = nil
            
            -- Reset button image when Camlock is off
            TeextButton.Image = "rbxassetid://10747366027"
        end
    end
end

-- Button click event to toggle Camlock
TeextButton.MouseButton1Click:Connect(function()
    ToggleCamlock()
end)

-- Keybind listening function
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end  -- Ignore if the input is processed by the game
    
    -- Check if the pressed key matches the Camlock toggle keybind
    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Script.Settings.Camlock.Keybind then
        ToggleCamlock()
    end
end)


function SetKeybind(key, action)
    if action == "ToggleCamlock" then
        keybinds.ToggleCamlock = key
    end
end
