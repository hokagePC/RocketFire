
-- ROCKET FIRE v4
-- Delta Executor | Flight prototype

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

pcall(function()
    CoreGui.RocketFireV4:Destroy()
end)

local gui = Instance.new("ScreenGui")
gui.Name = "RocketFireV4"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(270, 390)
main.Position = UDim2.new(0.5,-135,0.5,-195)
main.BackgroundColor3 = Color3.fromRGB(20,23,32)
main.Parent = gui
Instance.new("UICorner",main).CornerRadius = UDim.new(0,12)

local function button(text,y,parent)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(1,-20,0,38)
    b.Position = UDim2.fromOffset(10,y)
    b.BackgroundColor3 = Color3.fromRGB(45,57,77)
    b.TextColor3 = Color3.new(1,1,1)
    b.TextSize = 15
    b.Text = text
    b.Parent = parent
    Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
    return b
end

local title = button("ROCKET FIRE V4",0,main)
title.BackgroundColor3 = Color3.fromRGB(30,38,53)

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1,-20,0,25)
status.Position = UDim2.fromOffset(10,42)
status.BackgroundTransparency = 1
status.TextColor3 = Color3.fromRGB(255,150,70)
status.Text = "STATUS: READY"
status.Parent = main

local spawn = button("SPAWN ROCKET",75,main)
local grab = button("GRAB / RELEASE",120,main)
local fpv = button("FPV CAMERA",165,main)
local boost = button("BOOST: OFF",210,main)
local plus = button("DISTANCE +",255,main)
local minus = button("DISTANCE -",300,main)
local minimize = button("MINIMIZE",345,main)

local mini = button("🚀",0,gui)
mini.Size = UDim2.fromOffset(55,55)
mini.Position = UDim2.new(0,15,0.5,0)
mini.Visible = false

local rocket
local launched = false
local grabbed = false
local boosting = false
local fpvEnabled = false

local speed = 70
local distance = 8
local velocity = Vector3.zero
local oldCameraType
local oldSubject

local function createRocket()
    if rocket then rocket:Destroy() end

    local character = player.Character
    local root = character and character:FindFirstChild("HumanoidRootPart")
    if not root then return end

    rocket = Instance.new("Part")
    rocket.Name = "RocketFirePrototype"
    rocket.Size = Vector3.new(1,1,3)
    rocket.Color = Color3.fromRGB(220,35,25)
    rocket.Material = Enum.Material.Metal
    rocket.Anchored = true
    rocket.CanCollide = false
    rocket.CFrame = root.CFrame * CFrame.new(0,2,-distance)
    rocket.Parent = workspace

    local light = Instance.new("PointLight")
    light.Color = Color3.fromRGB(255,100,30)
    light.Brightness = 2
    light.Range = 10
    light.Parent = rocket

    local fire = Instance.new("Fire")
    fire.Size = 3
    fire.Heat = 5
    fire.Parent = rocket

    velocity = Vector3.zero
    launched = false
    grabbed = false
    status.Text = "STATUS: ROCKET READY"
end

spawn.MouseButton1Click:Connect(createRocket)

grab.MouseButton1Click:Connect(function()
    if not rocket then return end

    grabbed = not grabbed
    launched = not grabbed

    if launched then
        velocity = camera.CFrame.LookVector * speed
    end

    status.Text = grabbed and "STATUS: GRABBED" or "STATUS: RELEASED"
end)

boost.MouseButton1Click:Connect(function()
    boosting = not boosting
    boost.Text = boosting and "BOOST: ON" or "BOOST: OFF"
end)

plus.MouseButton1Click:Connect(function()
    distance = math.min(distance + 2,50)
    status.Text = "DISTANCE: "..distance
end)

minus.MouseButton1Click:Connect(function()
    distance = math.max(distance - 2,2)
    status.Text = "DISTANCE: "..distance
end)

fpv.MouseButton1Click:Connect(function()
    if not rocket then return end

    fpvEnabled = not fpvEnabled

    if fpvEnabled then
        oldCameraType = camera.CameraType
        oldSubject = camera.CameraSubject
        camera.CameraType = Enum.CameraType.Scriptable
    else
        camera.CameraType = oldCameraType or Enum.CameraType.Custom
        camera.CameraSubject = oldSubject
    end
end)

RunService.RenderStepped:Connect(function(dt)
    if not rocket or not rocket.Parent then return end

    if grabbed then
        local character = player.Character
        local root = character and character:FindFirstChild("HumanoidRootPart")
        if root then
            rocket.CFrame = root.CFrame * CFrame.new(0,2,-distance)
        end
    elseif launched then
        local direction = camera.CFrame.LookVector
        local acceleration = boosting and 180 or 35

        velocity = velocity + direction * acceleration * dt
        velocity = velocity + Vector3.new(0,-workspace.Gravity*0.15*dt,0)

        local position = rocket.Position + velocity * dt

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {rocket,player.Character}

        local result = workspace:Raycast(
            rocket.Position,
            position - rocket.Position,
            params
        )

        if result then
            local effect = Instance.new("Explosion")
            effect.Position = result.Position
            effect.BlastRadius = 0
            effect.BlastPressure = 0
            effect.Parent = workspace

            rocket:Destroy()
            rocket = nil
            launched = false
            status.Text = "STATUS: IMPACT"
            return
        end

        rocket.CFrame = CFrame.lookAt(position,position+velocity.Unit)
    end

    if fpvEnabled and rocket then
        camera.CFrame = rocket.CFrame * CFrame.new(0,1,4)
    end
end)

minimize.MouseButton1Click:Connect(function()
    main.Visible = false
    mini.Visible = true
end)

mini.MouseButton1Click:Connect(function()
    main.Visible = true
    mini.Visible = false
end)

-- Drag window
local dragging,dragStart,startPos

title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
    end
end)

UIS.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local delta = input.Position-dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,startPos.X.Offset+delta.X,
            startPos.Y.Scale,startPos.Y.Offset+delta.Y
        )
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

print("RocketFire V4 loaded")
