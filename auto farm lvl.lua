-- Services
local TweenService = game:GetService("TweenService")
local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")
local workspace = game:GetService("Workspace")
local runService = game:GetService("RunService")
local userInputService = game:GetService("UserInputService")

-- UI Setup for Mod Menu
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

-- Variables for toggles
local autoFarmActive = false
local compass = game.Workspace:WaitForChild("Compass") -- Reference to the game's compass object (adjust if needed)
local playerLevel = player:WaitForChild("leaderstats"):WaitForChild("Level") -- Assuming you have a level in leaderstats

-- Island locations (Adjust with actual quest NPCs)
local islands = {
    {questNPCName = "QuestNPC_1", questLocation = Vector3.new(100, 0, 200), levelThreshold = 20},
    {questNPCName = "QuestNPC_2", questLocation = Vector3.new(500, 0, 500), levelThreshold = 25},
    -- Add more quests and islands as needed
}

-- Helper function to check for quest from the compass
local function checkForQuest()
    -- Assuming the compass has a property that marks quest NPC positions
    if compass:FindFirstChild("QuestPosition") then
        return compass.QuestPosition.Position
    else
        return nil
    end
end

-- Toggle function for Auto Farm button
autoFarmButton.MouseButton1Click:Connect(function()
    autoFarmActive = not autoFarmActive
    print("Auto Farm: " .. tostring(autoFarmActive))
end)

-- Function to detect if the player needs to move to a new island based on their level and compass
local function detectAndMoveToNewQuest()
    local newQuestLocation = checkForQuest()
    if newQuestLocation then
        print("Detected New Quest at: " .. tostring(newQuestLocation))
        -- Tween to the new quest location
        local tweenInfo = TweenInfo.new(3, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false)
        local goal = {Position = newQuestLocation}
        local tween = TweenService:Create(humanoidRootPart, tweenInfo, goal)
        tween:Play()

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

-- Function to find closest enemy
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

-- Function to magnetize and group enemies
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

-- Function to attack the enemy (fast attack)
local function fastAttackEnemy(enemy)
    local humanoid = enemy:FindFirstChild("Humanoid")
    if humanoid and humanoid.Health > 0 then
        -- Quick attack logic (e.g., fast damage)
        humanoid:TakeDamage(10)  -- Adjust damage value for fast attack
    end
end

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
