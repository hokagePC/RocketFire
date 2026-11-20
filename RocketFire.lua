
-- ROCKET FIRE | Fling Things and People
-- Delta Executor | Client-side prototype

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local rockets = {}
local enabled = false
local flying = false
local speed = 100
local rocketCount = 3

local gui = Instance.new("ScreenGui")
gui.Name = "RocketFire"
gui.ResetOnSpawn = false
gui.Parent = game:GetService("CoreGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(220, 240)
frame.Position = UDim2.new(0, 20, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 23, 30)
frame.Parent = gui

local function button(name, position, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(190, 38)
    b.Position = position
    b.BackgroundColor3 = Color3.fromRGB(45, 55, 75)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Text = name
    b.TextSize = 15
    b.Parent = frame
    b.MouseButton1Click:Connect(callback)
    return b
end

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.BackgroundTransparency = 1
title.Text = "ROCKET FIRE"
title.TextColor3 = Color3.fromRGB(255, 120, 50)
title.TextSize = 20
title.Parent = frame

local status = button("ROCKET: OFF", UDim2.fromOffset(15, 45), function()
    enabled = not enabled
    status.Text = enabled and "ROCKET: ON" or "ROCKET: OFF"
end)

local spawnButton = button("SPAWN ROCKETS", UDim2.fromOffset(15, 90), function()
    if not enabled then return end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for i = 1, rocketCount do
        local rocket = Instance.new("Part")
        rocket.Name = "VisualRocket"
        rocket.Size = Vector3.new(1, 1, 3)
        rocket.Material = Enum.Material.Neon
        rocket.Color = Color3.fromRGB(255, 100, 20)
        rocket.Anchored = true
        rocket.CanCollide = false
        rocket.CFrame = root.CFrame * CFrame.new((i-2)*3, 5, -4)
        rocket.Parent = workspace

        table.insert(rockets, rocket)
    end
end)

local fireButton = button("FIRE / FPV", UDim2.fromOffset(15, 135), function()
    flying = not flying
    fireButton.Text = flying and "STOP FPV" or "FIRE / FPV"
end)

local speedButton = button("SPEED: 100", UDim2.fromOffset(15, 180), function()
    speed = speed + 25
    if speed > 250 then speed = 50 end
    speedButton.Text = "SPEED: " .. speed
end)

local activeRocket

RunService.RenderStepped:Connect(function(dt)
    if not flying then return end

    if not activeRocket or not activeRocket.Parent then
        activeRocket = rockets[1]
    end

    if not activeRocket then return end

    local direction = camera.CFrame.LookVector
    local nextPosition = activeRocket.Position + direction * speed * dt

    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {activeRocket, player.Character}

    local result = workspace:Raycast(
        activeRocket.Position,
        nextPosition - activeRocket.Position,
        params
    )

    if result then
        local explosion = Instance.new("Explosion")
        explosion.Position = result.Position
        explosion.BlastRadius = 0
        explosion.BlastPressure = 0
        explosion.Parent = workspace

        activeRocket:Destroy()
        activeRocket = nil
        flying = false
    else
        activeRocket.CFrame = CFrame.lookAt(nextPosition, nextPosition + direction)
    end
end)

button("CLEAR ROCKETS", UDim2.fromOffset(15, 215), function()
    for _, rocket in ipairs(rockets) do
        if rocket and rocket.Parent then
            rocket:Destroy()
        end
    end
    table.clear(rockets)
    activeRocket = nil
    flying = false
end)
