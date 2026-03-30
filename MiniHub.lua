-- MAIN SCRIPT HUB v3.0
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

-- ============================================
-- ГЛАВНОЕ МЕНЮ (4 КНОПКИ)
-- ============================================
local MainGui = Instance.new("ScreenGui")
MainGui.Name = "ScriptHub"
MainGui.Parent = CoreGui
MainGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = MainGui
MainFrame.Size = UDim2.new(0, 320, 0, 80)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -40)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BackgroundTransparency = 0.1
MainFrame.BorderSizePixel = 0

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 12)
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(0, 255, 100)
MainStroke.Thickness = 1.5
MainStroke.Transparency = 0.5
MainStroke.Parent = MainFrame

local TitleBar = Instance.new("Frame")
TitleBar.Parent = MainFrame
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.Position = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
TitleBar.BackgroundTransparency = 0
TitleBar.BorderSizePixel = 0

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 12)
TitleCorner.Parent = TitleBar

local Title = Instance.new("TextLabel")
Title.Parent = TitleBar
Title.Size = UDim2.new(1, 0, 1, 0)
Title.BackgroundTransparency = 1
Title.Text = "⚡ SCRIPT HUB ⚡"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 12
Title.Font = Enum.Font.GothamBold

local Buttons = {
    {Name = "ESP", Color = Color3.fromRGB(0, 255, 100), Icon = "👁"},
    {Name = "FLY", Color = Color3.fromRGB(0, 200, 255), Icon = "✈"},
    {Name = "HITBOX", Color = Color3.fromRGB(255, 80, 80), Icon = "⬚"},
    {Name = "NO CLIP", Color = Color3.fromRGB(200, 150, 50), Icon = "⬚"}
}

local ButtonContainer = Instance.new("Frame")
ButtonContainer.Parent = MainFrame
ButtonContainer.Size = UDim2.new(1, -20, 1, -38)
ButtonContainer.Position = UDim2.new(0, 10, 0, 32)
ButtonContainer.BackgroundTransparency = 1

local btnWidth = 70
local btnHeight = 40
local spacing = 10

for i, btnData in ipairs(Buttons) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, btnWidth, 0, btnHeight)
    btn.Position = UDim2.new(0, (i-1) * (btnWidth + spacing), 0, 0)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.BackgroundTransparency = 0
    btn.Text = btnData.Icon .. " " .. btnData.Name
    btn.TextColor3 = btnData.Color
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.BorderSizePixel = 0
    btn.Parent = ButtonContainer
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = btn
    
    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    end)
    
    btnData.Button = btn
end

local dragActive = false
local dragStart, dragPos

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = true
        dragStart = input.Position
        dragPos = MainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragActive and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(dragPos.X.Scale, dragPos.X.Offset + delta.X, dragPos.Y.Scale, dragPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragActive = false
    end
end)

-- ============================================
-- ESP СКРИПТ
-- ============================================
local espConfig = {
    enabled = false,
    outlineColor = Color3.fromRGB(0, 255, 0),
    fillColor = Color3.fromRGB(0, 255, 0),
    fillTransparency = 0.85,
    showName = true,
    showDistance = true,
    maxDistance = 750,
    espToggleKey = Enum.KeyCode.E,
}

local espObjects = {}
local espTrackedPlayers = {}

local function updateESPColors()
    for _, data in pairs(espObjects) do
        if data.highlight then
            data.highlight.OutlineColor = espConfig.outlineColor
            data.highlight.FillColor = espConfig.fillColor
            data.highlight.FillTransparency = espConfig.fillTransparency
        end
        if data.nameLabel then
            data.nameLabel.TextColor3 = espConfig.outlineColor
        end
    end
end

local function createHighlight(character)
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_Highlight"
    highlight.Parent = character
    highlight.Adornee = character
    highlight.FillColor = espConfig.fillColor
    highlight.FillTransparency = espConfig.fillTransparency
    highlight.OutlineColor = espConfig.outlineColor
    highlight.OutlineTransparency = 0
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = true
    return highlight
end

local function createBillboard(character, targetPlayer)
    if not character or not character:FindFirstChild("Head") then return end
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "ESP_Billboard"
    billboard.Parent = character.Head
    billboard.Size = UDim2.new(0, 140, 0, 28)
    billboard.StudsOffset = Vector3.new(0, 2.2, 0)
    billboard.AlwaysOnTop = true
    billboard.MaxDistance = espConfig.maxDistance

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
    nameLabel.Position = UDim2.new(0, 0, 0, 0)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = targetPlayer.Name
    nameLabel.TextColor3 = espConfig.outlineColor
    nameLabel.TextStrokeTransparency = 0.2
    nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 11
    nameLabel.TextScaled = true
    nameLabel.Visible = espConfig.showName
    nameLabel.Parent = billboard

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Size = UDim2.new(1, 0, 0.5, 0)
    distanceLabel.Position = UDim2.new(0, 0, 0.5, 0)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Text = ""
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.TextStrokeTransparency = 0.2
    distanceLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    distanceLabel.Font = Enum.Font.Gotham
    distanceLabel.TextSize = 9
    distanceLabel.TextScaled = true
    distanceLabel.Visible = espConfig.showDistance
    distanceLabel.Parent = billboard

    return {billboard = billboard, nameLabel = nameLabel, distanceLabel = distanceLabel}
end

local function addESP(targetPlayer)
    if targetPlayer == LocalPlayer or espObjects[targetPlayer] then return end
    local character = targetPlayer.Character
    if not character then return end
    
    local humanoid = character:FindFirstChild("Humanoid")
    if not humanoid or humanoid.Health <= 0 then return end

    local highlight = createHighlight(character)
    local billboardData = nil
    if espConfig.showName or espConfig.showDistance then
        billboardData = createBillboard(character, targetPlayer)
    end

    espObjects[targetPlayer] = {
        character = character,
        highlight = highlight,
        billboard = billboardData and billboardData.billboard,
        nameLabel = billboardData and billboardData.nameLabel,
        distanceLabel = billboardData and billboardData.distanceLabel,
        player = targetPlayer
    }
end

local function removeESP(targetPlayer)
    local data = espObjects[targetPlayer]
    if data then
        if data.highlight then data.highlight:Destroy() end
        if data.billboard then data.billboard:Destroy() end
        espObjects[targetPlayer] = nil
    end
end

local function refreshAllESP()
    for p, _ in pairs(espObjects) do removeESP(p) end
    if espConfig.enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = p.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    addESP(p)
                end
            end
        end
    end
end

local function toggleESP(state)
    espConfig.enabled = state
    if state then
        refreshAllESP()
    else
        for p, _ in pairs(espObjects) do removeESP(p) end
    end
end

local function trackPlayer(player)
    if player == LocalPlayer then return end
    if espTrackedPlayers[player] then return end
    espTrackedPlayers[player] = true
    
    local function onCharacterAdded(character)
        task.wait(0.8)
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid and humanoid.Health > 0 and espConfig.enabled then
            addESP(player)
        end
    end
    
    local function onCharacterRemoving()
        if espConfig.enabled then
            removeESP(player)
        end
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(onCharacterRemoving)
    
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 and espConfig.enabled then
            addESP(player)
        end
    end
end

-- ============================================
-- FLY СКРИПТ
-- ============================================
local flyConfig = {
    active = false,
    speed = 100,
    bind = Enum.KeyCode.F
}

local flyBodyVelocity = nil
local flyBodyGyro = nil
local flyOriginalGravity = nil

local function enableFlight()
    if not LocalPlayer.Character then return end
    local char = LocalPlayer.Character
    local humanoid = char:FindFirstChild("Humanoid")
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not rootPart then return end
    
    if flyConfig.active then
        if flyBodyVelocity then flyBodyVelocity:Destroy() end
        if flyBodyGyro then flyBodyGyro:Destroy() end
        humanoid.PlatformStand = false
        humanoid.AutoRotate = true
        if flyOriginalGravity then workspace.Gravity = flyOriginalGravity end
        flyConfig.active = false
        print("[FLY] Выключен")
    else
        flyOriginalGravity = workspace.Gravity
        workspace.Gravity = 0
        
        flyBodyVelocity = Instance.new("BodyVelocity")
        flyBodyVelocity.MaxForce = Vector3.new(1e6, 1e6, 1e6)
        flyBodyVelocity.P = 1e5
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
        flyBodyVelocity.Parent = rootPart
        
        flyBodyGyro = Instance.new("BodyGyro")
        flyBodyGyro.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
        flyBodyGyro.P = 1e5
        flyBodyGyro.D = 500
        flyBodyGyro.CFrame = rootPart.CFrame
        flyBodyGyro.Parent = rootPart
        
        humanoid.AutoRotate = false
        humanoid.PlatformStand = true
        flyConfig.active = true
        print("[FLY] Включен, скорость: " .. flyConfig.speed)
    end
end

local function updateFlight()
    if not flyConfig.active then return end
    if not LocalPlayer.Character then 
        enableFlight()
        return 
    end
    
    local char = LocalPlayer.Character
    local rootPart = char:FindFirstChild("HumanoidRootPart")
    local humanoid = char:FindFirstChild("Humanoid")
    if not rootPart or not humanoid then return end
    
    local moveDirection = Vector3.new(0, 0, 0)
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDirection = moveDirection + Vector3.new(0, 0, -1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDirection = moveDirection + Vector3.new(0, 0, 1) end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDirection = moveDirection + Vector3.new(-1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDirection = moveDirection + Vector3.new(1, 0, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveDirection = moveDirection + Vector3.new(0, 1, 0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveDirection = moveDirection + Vector3.new(0, -1, 0) end
    
    local cameraCFrame = workspace.CurrentCamera.CFrame
    local forward = cameraCFrame.LookVector
    local right = cameraCFrame.RightVector
    local up = cameraCFrame.UpVector
    
    if moveDirection.Magnitude > 0 then
        moveDirection = moveDirection.Unit
        flyBodyVelocity.Velocity = (right * moveDirection.X + up * moveDirection.Y + forward * -moveDirection.Z) * flyConfig.speed
    else
        flyBodyVelocity.Velocity = Vector3.new(0, 0, 0)
    end
    
    local targetCFrame = CFrame.new(rootPart.Position, rootPart.Position + forward)
    flyBodyGyro.CFrame = targetCFrame
    humanoid.AutoRotate = false
end

-- ============================================
-- HITBOX СКРИПТ
-- ============================================
local hitboxConfig = {
    enabled = false,
    size = 6,
    transparency = 0.4,
    color = Color3.fromRGB(255, 50, 50),
    bind = Enum.KeyCode.H
}

local hitboxObjects = {}
local hitboxDebounce = {}
local hitboxTrackedPlayers = {}

local function isWeaponHit(hit)
    if not hit then return false end
    local name = hit.Name:lower()
    local words = {"bullet", "projectile", "ray", "shot", "pellet", "ammo", "shell", "tool", "weapon"}
    for _, w in ipairs(words) do
        if name:find(w) then return true end
    end
    local char = LocalPlayer.Character
    if char then
        local tool = char:FindFirstChildOfClass("Tool")
        if tool and hit:IsDescendantOf(tool) then return true end
    end
    return false
end

local function updateHitboxVisuals()
    for _, data in pairs(hitboxObjects) do
        if data.box then
            data.box.Color = hitboxConfig.color
            data.box.Transparency = hitboxConfig.transparency
            data.box.Size = Vector3.new(hitboxConfig.size, hitboxConfig.size, hitboxConfig.size)
        end
    end
end

local function createHitbox(player)
    if player == LocalPlayer or hitboxObjects[player] then return false end
    local char = player.Character
    if not char then return false end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum or hum.Health <= 0 then return false end
    
    local box = Instance.new("Part")
    box.Size = Vector3.new(hitboxConfig.size, hitboxConfig.size, hitboxConfig.size)
    box.Color = hitboxConfig.color
    box.Transparency = hitboxConfig.transparency
    box.Material = Enum.Material.Neon
    box.Anchored = false
    box.CanCollide = false
    box.CanTouch = true
    box.Massless = true
    box.Name = "ExpandedHitbox"
    box.Parent = char
    box.CFrame = root.CFrame + Vector3.new(0, 1.5, 0)
    
    local weld = Instance.new("Weld")
    weld.Part0 = root
    weld.Part1 = box
    weld.C0 = CFrame.new(0, 1.5, 0)
    weld.Parent = box
    
    box.Touched:Connect(function(hit)
        if not hitboxConfig.enabled then return end
        if not hit or not hit.Parent then return end
        local hitChar = hit:FindFirstAncestorOfClass("Model")
        if hitChar == char then return end
        if not isWeaponHit(hit) then return end
        
        local now = tick()
        if hitboxDebounce[player] and now - hitboxDebounce[player] < 0.15 then return end
        
        local targetHum = player.Character and player.Character:FindFirstChild("Humanoid")
        if targetHum and targetHum.Health > 0 then
            hitboxDebounce[player] = now
            targetHum:TakeDamage(20)
        end
    end)
    
    hitboxObjects[player] = { box = box, player = player }
    return true
end

local function removeHitbox(player)
    local data = hitboxObjects[player]
    if data then
        if data.box then data.box:Destroy() end
        hitboxObjects[player] = nil
    end
end

local function refreshAllHitboxes()
    for p, _ in pairs(hitboxObjects) do removeHitbox(p) end
    if hitboxConfig.enabled then
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local char = p.Character
                local hum = char and char:FindFirstChild("Humanoid")
                if hum and hum.Health > 0 then
                    createHitbox(p)
                end
            end
        end
    end
end

local function toggleHitboxSystem()
    hitboxConfig.enabled = not hitboxConfig.enabled
    if hitboxConfig.enabled then
        refreshAllHitboxes()
        print("[HITBOX] Включен")
    else
        for p, _ in pairs(hitboxObjects) do removeHitbox(p) end
        print("[HITBOX] Выключен")
    end
end

local function trackHitboxPlayer(player)
    if player == LocalPlayer then return end
    if hitboxTrackedPlayers[player] then return end
    hitboxTrackedPlayers[player] = true
    
    local function onCharacterAdded(character)
        task.wait(0.8)
        local hum = character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 and hitboxConfig.enabled then
            createHitbox(player)
        end
    end
    
    local function onCharacterRemoving()
        removeHitbox(player)
    end
    
    player.CharacterAdded:Connect(onCharacterAdded)
    player.CharacterRemoving:Connect(onCharacterRemoving)
    
    if player.Character then
        local hum = player.Character:FindFirstChild("Humanoid")
        if hum and hum.Health > 0 and hitboxConfig.enabled then
            createHitbox(player)
        end
    end
end

-- ============================================
-- NO CLIP СКРИПТ
-- ============================================
local noclipConfig = {
    enabled = false,
    bind = Enum.KeyCode.N,
    originalCollisions = {}
}

local function getCharacterParts(char)
    local parts = {}
    if not char then return parts end
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("BasePart") and obj.CanCollide then
            table.insert(parts, obj)
        end
    end
    return parts
end

local function enableNoclip()
    if noclipConfig.enabled then return end
    local char = LocalPlayer.Character
    if not char then return end
    
    noclipConfig.originalCollisions = {}
    local parts = getCharacterParts(char)
    for _, part in ipairs(parts) do
        noclipConfig.originalCollisions[part] = part.CanCollide
        part.CanCollide = false
    end
    noclipConfig.enabled = true
    print("[NO CLIP] Включен")
end

local function disableNoclip()
    if not noclipConfig.enabled then return end
    for part, original in pairs(noclipConfig.originalCollisions) do
        if part and part.Parent then
            part.CanCollide = original
        end
    end
    noclipConfig.originalCollisions = {}
    noclipConfig.enabled = false
    print("[NO CLIP] Выключен")
end

local function toggleNoclip()
    if noclipConfig.enabled then
        disableNoclip()
    else
        enableNoclip()
    end
end

LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if noclipConfig.enabled then
        noclipConfig.enabled = false
        enableNoclip()
    end
end)

RunService.Stepped:Connect(function()
    if noclipConfig.enabled and LocalPlayer.Character then
        local parts = getCharacterParts(LocalPlayer.Character)
        for _, part in ipairs(parts) do
            if part.CanCollide == true then
                part.CanCollide = false
            end
        end
    end
end)

-- ============================================
-- ГЛОБАЛЬНЫЕ БИНДЫ
-- ============================================
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == espConfig.espToggleKey then
        toggleESP(not espConfig.enabled)
    end
    
    if input.KeyCode == flyConfig.bind then
        enableFlight()
    end
    
    if input.KeyCode == hitboxConfig.bind then
        toggleHitboxSystem()
    end
    
    if input.KeyCode == noclipConfig.bind then
        toggleNoclip()
    end
end)

-- ============================================
-- ОБНОВЛЕНИЯ
-- ============================================
RunService.RenderStepped:Connect(updateFlight)

RunService.Heartbeat:Connect(function()
    if not espConfig.enabled then return end
    if not camera then return end
    
    for _, data in pairs(espObjects) do
        if data.billboard and data.character and data.character:FindFirstChild("HumanoidRootPart") then
            local distance = (camera.CFrame.Position - data.character.HumanoidRootPart.Position).Magnitude
            if data.distanceLabel and espConfig.showDistance then
                if distance <= espConfig.maxDistance then
                    data.distanceLabel.Text = string.format("%.0fm", distance)
                    if distance < 50 then
                        data.distanceLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
                    elseif distance < 100 then
                        data.distanceLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
                    else
                        data.distanceLabel.TextColor3 = Color3.fromRGB(255, 100, 0)
                    end
                    data.distanceLabel.Visible = true
                else
                    data.distanceLabel.Visible = false
                end
            end
        end
    end
end)

-- ============================================
-- ИНИЦИАЛИЗАЦИЯ
-- ============================================
for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        trackPlayer(p)
        trackHitboxPlayer(p)
    end
end

Players.PlayerAdded:Connect(function(p)
    if p == LocalPlayer then return end
    trackPlayer(p)
    trackHitboxPlayer(p)
end)

-- ============================================
-- ФУНКЦИЯ СОЗДАНИЯ МЕНЮ
-- ============================================
local function createMenu(title, color, width, height, elements)
    local gui = Instance.new("ScreenGui")
    gui.Name = title .. "_Menu"
    gui.Parent = CoreGui
    gui.ResetOnSpawn = false
    gui.Enabled = false
    
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, width, 0, height)
    main.Position = UDim2.new(0.5, 50, 0.5, -height/2)
    main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    main.BackgroundTransparency = 0.1
    main.BorderSizePixel = 0
    main.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = main
    
    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1.5
    stroke.Transparency = 0.5
    stroke.Parent = main
    
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 32)
    titleBar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = main
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = titleBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -50, 1, 0)
    titleLabel.Position = UDim2.new(0, 12, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = color
    titleLabel.TextSize = 12
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 28, 0, 28)
    closeBtn.Position = UDim2.new(1, -32, 0, 2)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
    closeBtn.BackgroundTransparency = 0
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 14
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        gui.Enabled = false
    end)
    
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Size = UDim2.new(1, -16, 1, -40)
    scrollFrame.Position = UDim2.new(0, 8, 0, 36)
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.ScrollBarThickness = 4
    scrollFrame.Parent = main
    
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.Parent = scrollFrame
    
    local yPos = 4
    
    for _, elem in ipairs(elements) do
        elem.Position = UDim2.new(0, 8, 0, yPos)
        yPos = yPos + elem.Size.Y.Offset + 4
        elem.Parent = container
    end
    
    container.Size = UDim2.new(1, 0, 0, yPos + 4)
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, yPos + 8)
    
    return gui
end

-- ============================================
-- ЭЛЕМЕНТЫ GUI
-- ============================================
local function createCheckbox(name, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 32)
    frame.BackgroundTransparency = 1
    
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 28)
    btn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    btn.BackgroundTransparency = 0
    btn.Text = getter() and "✓ " .. name or "○ " .. name
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.TextXAlignment = Enum.TextXAlignment.Left
    btn.BorderSizePixel = 0
    btn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = btn
    
    btn.MouseButton1Click:Connect(function()
        local newState = not getter()
        setter(newState)
        btn.Text = newState and "✓ " .. name or "○ " .. name
    end)
    
    return frame
end

local function createSlider(name, minVal, maxVal, getter, setter, format)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 55)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 20)
    label.BackgroundTransparency = 1
    label.Text = name .. ": " .. (format and format(getter()) or getter())
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local sliderBg = Instance.new("Frame")
    sliderBg.Size = UDim2.new(1, -50, 0, 4)
    sliderBg.Position = UDim2.new(0, 0, 0, 24)
    sliderBg.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    sliderBg.BorderSizePixel = 0
    sliderBg.Parent = frame
    
    local sliderCorner = Instance.new("UICorner")
    sliderCorner.CornerRadius = UDim.new(1, 0)
    sliderCorner.Parent = sliderBg
    
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((getter() - minVal) / (maxVal - minVal), 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    fill.BorderSizePixel = 0
    fill.Parent = sliderBg
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 14, 0, 14)
    button.Position = UDim2.new((getter() - minVal) / (maxVal - minVal), -7, 0, -5)
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = ""
    button.AutoButtonColor = false
    button.Parent = sliderBg
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(1, 0)
    btnCorner.Parent = button
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 45, 0, 20)
    valueLabel.Position = UDim2.new(1, -50, 0, 22)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = format and format(getter()) or tostring(getter())
    valueLabel.TextColor3 = Color3.fromRGB(0, 255, 100)
    valueLabel.TextSize = 10
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.Parent = frame
    
    local dragging = false
    
    button.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
    end)
    button.InputEnded:Connect(function() dragging = false end)
    
    local function update(val)
        val = math.clamp(val, minVal, maxVal)
        local t = (val - minVal) / (maxVal - minVal)
        fill.Size = UDim2.new(t, 0, 1, 0)
        button.Position = UDim2.new(t, -7, 0, -5)
        valueLabel.Text = format and format(val) or string.format("%.2f", val)
        label.Text = name .. ": " .. (format and format(val) or string.format("%.2f", val))
        setter(val)
        if name == "SIZE" then updateHitboxVisuals() end
        if name == "ALPHA" then updateHitboxVisuals() end
    end
    
    sliderBg.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local x = i.Position.X - sliderBg.AbsolutePosition.X
            local t = math.clamp(x / sliderBg.AbsoluteSize.X, 0, 1)
            update(minVal + t * (maxVal - minVal))
        end
    end)
    
    UserInputService.InputChanged:Connect(function(i)
        if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
            local x = i.Position.X - sliderBg.AbsolutePosition.X
            local t = math.clamp(x / sliderBg.AbsoluteSize.X, 0, 1)
            update(minVal + t * (maxVal - minVal))
        end
    end)
    
    return frame
end

local function createColorPicker(name, getter, setter)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 40)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 22)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local colorDisplay = Instance.new("Frame")
    colorDisplay.Size = UDim2.new(0, 50, 0, 24)
    colorDisplay.Position = UDim2.new(1, -55, 0, -1)
    colorDisplay.BackgroundColor3 = getter()
    colorDisplay.BorderSizePixel = 1
    colorDisplay.BorderColor3 = Color3.fromRGB(255, 255, 255)
    colorDisplay.Parent = frame
    
    local displayCorner = Instance.new("UICorner")
    displayCorner.CornerRadius = UDim.new(0, 4)
    displayCorner.Parent = colorDisplay
    
    local pickerFrame = Instance.new("Frame")
    pickerFrame.Size = UDim2.new(0, 160, 0, 130)
    pickerFrame.Position = UDim2.new(1, -165, 0, 28)
    pickerFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    pickerFrame.BackgroundTransparency = 0
    pickerFrame.BorderSizePixel = 0
    pickerFrame.Visible = false
    pickerFrame.ZIndex = 20
    pickerFrame.Parent = frame
    
    local pickerCorner = Instance.new("UICorner")
    pickerCorner.CornerRadius = UDim.new(0, 6)
    pickerCorner.Parent = pickerFrame
    
    local colors = {
        Color3.fromRGB(255, 0, 0), Color3.fromRGB(255, 100, 0), Color3.fromRGB(255, 200, 0), Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 100, 255), Color3.fromRGB(0, 0, 255), Color3.fromRGB(150, 0, 255),
        Color3.fromRGB(255, 0, 255), Color3.fromRGB(255, 255, 255), Color3.fromRGB(150, 150, 150), Color3.fromRGB(80, 80, 80)
    }
    
    local pickerContainer = Instance.new("Frame")
    pickerContainer.Size = UDim2.new(1, -8, 1, -8)
    pickerContainer.Position = UDim2.new(0, 4, 0, 4)
    pickerContainer.BackgroundTransparency = 1
    pickerContainer.Parent = pickerFrame
    
    local row, col = 0, 0
    for i, color in ipairs(colors) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 28, 0, 28)
        btn.Position = UDim2.new(0, col * 32, 0, row * 32)
        btn.BackgroundColor3 = color
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.Parent = pickerContainer
        
        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 4)
        btnCorner.Parent = btn
        
        btn.MouseButton1Click:Connect(function()
            setter(color)
            colorDisplay.BackgroundColor3 = color
            pickerFrame.Visible = false
            updateHitboxVisuals()
            updateESPColors()
        end)
        
        col = col + 1
        if col >= 4 then col = 0; row = row + 1 end
    end
    
    colorDisplay.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            pickerFrame.Visible = not pickerFrame.Visible
        end
    end)
    
    return frame
end

local function createKeybind(name, getter, setter, color)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -16, 0, 36)
    frame.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 0, 22)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = Color3.fromRGB(200, 200, 200)
    label.TextSize = 10
    label.Font = Enum.Font.Gotham
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 70, 0, 26)
    keyBtn.Position = UDim2.new(1, -75, 0, -2)
    keyBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    keyBtn.BackgroundTransparency = 0
    keyBtn.Text = getter().Name
    keyBtn.TextColor3 = color or Color3.fromRGB(255, 100, 100)
    keyBtn.TextSize = 10
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.BorderSizePixel = 0
    keyBtn.Parent = frame
    
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 6)
    btnCorner.Parent = keyBtn
    
    local binding = false
    keyBtn.MouseButton1Click:Connect(function()
        binding = true
        keyBtn.Text = "..."
        local conn
        conn = UserInputService.InputBegan:Connect(function(input, proc)
            if proc or not binding then return end
            if input.KeyCode ~= Enum.KeyCode.Unknown then
                setter(input.KeyCode)
                keyBtn.Text = input.KeyCode.Name
                binding = false
                conn:Disconnect()
            end
        end)
        task.wait(3)
        if binding then
            binding = false
            keyBtn.Text = getter().Name
        end
    end)
    
    return frame
end

-- ============================================
-- СОЗДАНИЕ МЕНЮ
-- ============================================
local EspMenu = createMenu("👁 ESP SETTINGS", Color3.fromRGB(0, 255, 100), 280, 380, {
    createCheckbox("ESP ENABLED", function() return espConfig.enabled end, function(v) toggleESP(v) end),
    createSlider("ALPHA", 0, 1, function() return espConfig.fillTransparency end, function(v) espConfig.fillTransparency = v; updateESPColors() end, function(v) return string.format("%.0f%%", v*100) end),
    createColorPicker("OUTLINE COLOR", function() return espConfig.outlineColor end, function(v) espConfig.outlineColor = v; updateESPColors() end),
    createColorPicker("FILL COLOR", function() return espConfig.fillColor end, function(v) espConfig.fillColor = v; updateESPColors() end),
    createCheckbox("SHOW NAMES", function() return espConfig.showName end, function(v) espConfig.showName = v; for _, d in pairs(espObjects) do if d.nameLabel then d.nameLabel.Visible = v end end end),
    createCheckbox("SHOW DISTANCE", function() return espConfig.showDistance end, function(v) espConfig.showDistance = v; for _, d in pairs(espObjects) do if d.distanceLabel then d.distanceLabel.Visible = v end end end),
    createKeybind("ESP KEY", function() return espConfig.espToggleKey end, function(v) espConfig.espToggleKey = v end, Color3.fromRGB(0, 255, 100))
})

local FlyMenu = createMenu("✈ FLY SETTINGS", Color3.fromRGB(0, 200, 255), 260, 180, {
    createSlider("SPEED", 10, 500, function() return flyConfig.speed end, function(v) flyConfig.speed = v; if flyConfig.active then print("[FLY] Скорость: " .. v) end end, function(v) return tostring(v) end),
    createKeybind("FLY KEY", function() return flyConfig.bind end, function(v) flyConfig.bind = v end, Color3.fromRGB(0, 200, 255))
})

local HitboxMenu = createMenu("⬚ HITBOX SETTINGS", Color3.fromRGB(255, 80, 80), 280, 400, {
    createCheckbox("HITBOX ENABLED", function() return hitboxConfig.enabled end, function(v) 
        hitboxConfig.enabled = v
        if v then refreshAllHitboxes() else for p, _ in pairs(hitboxObjects) do removeHitbox(p) end end
    end),
    createSlider("SIZE", 2, 30, function() return hitboxConfig.size end, function(v) hitboxConfig.size = v; updateHitboxVisuals() end, function(v) return tostring(v) end),
    createSlider("ALPHA", 0, 1, function() return hitboxConfig.transparency end, function(v) hitboxConfig.transparency = v; updateHitboxVisuals() end, function(v) return string.format("%.0f%%", v*100) end),
    createColorPicker("COLOR", function() return hitboxConfig.color end, function(v) hitboxConfig.color = v; updateHitboxVisuals() end),
    createKeybind("HITBOX KEY", function() return hitboxConfig.bind end, function(v) hitboxConfig.bind = v end, Color3.fromRGB(255, 80, 80))
})

local NoclipMenu = createMenu("⬚ NO CLIP", Color3.fromRGB(200, 150, 50), 240, 140, {
    createCheckbox("NO CLIP", function() return noclipConfig.enabled end, function(v) if v then enableNoclip() else disableNoclip() end end),
    createKeybind("NO CLIP KEY", function() return noclipConfig.bind end, function(v) noclipConfig.bind = v end, Color3.fromRGB(200, 150, 50))
})

-- ============================================
-- ОБРАБОТЧИК КНОПОК
-- ============================================
local menus = {EspMenu, FlyMenu, HitboxMenu, NoclipMenu}
local menuVisible = {false, false, false, false}

for i, btn in ipairs(Buttons) do
    btn.Button.MouseButton1Click:Connect(function()
        for j, menu in ipairs(menus) do
            if j == i then
                menuVisible[j] = not menuVisible[j]
                menu.Enabled = menuVisible[j]
            else
                menu.Enabled = false
                menuVisible[j] = false
            end
        end
    end)
end

print("════════════════════════════════════════")
print("  SCRIPT HUB v3.0 LOADED")
print("════════════════════════════════════════")
print("  БИНДЫ:")
print("    ESP: E")
print("    FLY: F")
print("    HITBOX: H")
print("    NO CLIP: N")
print("════════════════════════════════════════")
