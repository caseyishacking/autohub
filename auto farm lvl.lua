-- Services
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 250)
frame.Position = UDim2.new(0, 10, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Parent = ScreenGui

local autoFarmButton = Instance.new("TextButton")
autoFarmButton.Size = UDim2.new(0, 180, 0, 50)
autoFarmButton.Position = UDim2.new(0, 10, 0, 10)
autoFarmButton.Text = "Toggle Auto Farm"
autoFarmButton.Parent = frame

-- Variables
local autoFarmActive = false
local compass = workspace:WaitForChild("Compass") -- Assuming compass object exists
local playerLevel = player:WaitForChild("leaderstats"):WaitForChild("Level") -- Assuming level is in leaderstats

-- Helper Functions
local function checkForQuest()
    -- Assuming the compass has a property that marks quest NPC positions
    if compass:FindFirstChild("QuestPosition") then
        return compass.QuestPosition.Position
    else
        return nil
    end
end

local function findClosestEnemy()
    local closestEnemy = nil
    local shortestDistance = math.huge
    for _, enemy in pairs(workspace:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy ~= character then
            local distance = (humanoidRootPart.Position - enemy.HumanoidRootPart.Position).Magnitude
            if distance < shortestDistance then
                closestEnemy = enemy
                shortestDistance = distance
            end
        end
    end
    return closestEnemy
end

local function magnetizeEnemies()
    local enemies = {}
    for _, enemy in pairs(workspace:GetChildren()) do
        if enemy:FindFirstChild("HumanoidRootPart") and enemy ~= character then
            table.insert(enemies, enemy)
        end
    end
    for _, enemy in pairs(enemies) do
        -- Move enemies to a group (e.g., close to the player)
        enemy.HumanoidRootPart.CFrame = humanoidRootPart.CFrame * CFrame.new(0, 0, 5) -- Adjust for grouping
    end
end

local function fastAttackEnemy(enemy)
    local humanoid = enemy:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        -- Quick attack logic (e.g., fast damage)
        humanoid:TakeDamage(10)  -- Adjust damage value for fast attack
    end
end

local function tweenToPosition(position)
    local tweenInfo = TweenInfo.new((humanoidRootPart.Position - position).Magnitude / 50, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    local goal = {Position = position}
    local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
    tween:Play()
end

local function detectAndMoveToNewQuest()
    local newQuestLocation = checkForQuest()
    if newQuestLocation then
        print("Detected New Quest at: " .. tostring(newQuestLocation))
        tweenToPosition(newQuestLocation)
        -- Wait until the player arrives at the quest NPC
        repeat
            wait(0.5)
        until (humanoidRootPart.Position - newQuestLocation).Magnitude < 5
        -- Once at the NPC, auto-interact to start the quest
        local questNPC = workspace:FindFirstChild("QuestNPC_1")  -- Adjust with dynamic NPC naming or indexing
        if questNPC then
            -- Simulate interaction (e.g., clicking the NPC or using a proximity prompt)
            local proximityPrompt = questNPC:FindFirstChild("ProximityPrompt")
            if proximityPrompt then
                proximityPrompt:InputHoldBegin(userInputService)
                wait(1)
                proximityPrompt:InputHoldEnd(userInputService)
            end
        end
    end
end

-- Toggle function for Auto Farm button
autoFarmButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    print("Auto Farm: " .. tostring(autoFarmActive))
end)

-- Main Loop: Handles auto quest, auto farm, magnetizing enemies, and auto attack
runService.Heartbeat:Connect(function()
    if autoFarmActive then
        -- Detect new quest and move to it
        detectAndMoveToNewQuest()

        -- Magnetize enemies and group them
        magnetizeEnemies()

        -- Auto Farming logic: Find and attack the closest enemy
        local targetEnemy = findClosestEnemy()
        if targetEnemy then
            fastAttackEnemy(targetEnemy)
            print("Attacking: " .. targetEnemy.Name)
        end
    end
end)
