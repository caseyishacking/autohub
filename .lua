-- 🌟 Blox Fruits Mega Hub Script (with Anti-Ban Layer)
-- 🚨 Educational Purposes Only — use responsibly
-- 💻 Synapse X / Fluxus Supported GUI Script

--\[💾\] Base Setup
local lp = game.Players.LocalPlayer
local rs = game:GetService("ReplicatedStorage")
local ws = game:GetService("Workspace")
local ts = game:GetService("TweenService")
local vim = game:GetService("VirtualInputManager")
local cam = workspace.CurrentCamera
local HttpService = game:GetService("HttpService")
local TPService = game:GetService("TeleportService")

--\[🧠\] Flags
_G.autoFarmFly = false
_G.fastAttack = false
_G.useMelee = true
_G.useSword = false
_G.autoMastery = false
_G.pvpAimbot = false
_G.autoRaidStart = false
_G.autoAwaken = false
_G.autoFruitFinder = false
_G.espEnabled = false
_G.killAura = false
_G.selectedBoss = "All"
_G.antiBanGuiHide = true
_G.serverHopMode = "Lowest"

--\[🛡️\] Anti-Ban: Admin Detection
local adminList = {
    "_Adm", "Admin", "Mod", "Developer", "Tester"
}

local function isAdmin(player)
    for _, word in ipairs(adminList) do
        if string.find(player.Name, word) or string.find(player.DisplayName, word) then
            return true
        end
    end
    return false
end

--\[🧱\] GUI Framework
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.Name = "BloxHubV2"

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 500)
frame.Position = UDim2.new(0, 20, 0.5, -250)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

local tabBar = Instance.new("Frame", frame)
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.BackgroundColor3 = Color3.fromRGB(30, 30, 30)

local content = Instance.new("Frame", frame)
content.Size = UDim2.new(1, 0, 1, -30)
content.Position = UDim2.new(0, 0, 0, 30)
content.BackgroundColor3 = Color3.fromRGB(35, 35, 35)

local tabs = {"Auto Farm", "Mastery", "PvP", "Raids", "Fruit", "Extras"}
local sections = {}

for i, tabName in ipairs(tabs) do
    local tab = Instance.new("TextButton", tabBar)
    tab.Size = UDim2.new(0, 60, 1, 0)
    tab.Position = UDim2.new(0, (i - 1) * 60, 0, 0)
    tab.Text = tabName
    tab.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    tab.TextColor3 = Color3.fromRGB(255, 255, 255)

    local section = Instance.new("Frame", content)
    section.Size = UDim2.new(1, 0, 1, 0)
    section.BackgroundTransparency = 1
    section.Visible = (i == 1)
    sections[tabName] = section

    tab.MouseButton1Click:Connect(function()
        for _, sec in pairs(sections) do sec.Visible = false end
        section.Visible = true
    end)
end

local function createToggle(parent, name, varName)
    local toggle = Instance.new("TextButton", parent)
    toggle.Size = UDim2.new(1, -10, 0, 25)
    toggle.Position = UDim2.new(0, 5, 0, #parent:GetChildren() * 30)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    _G[varName] = false
    toggle.Text = name .. ": OFF"
    toggle.MouseButton1Click:Connect(function()
        _G[varName] = not _G[varName]
        toggle.Text = name .. (_G[varName] and ": ON" or ": OFF")
    end)
end

-- Auto Farm Tab
createToggle(sections["Auto Farm"], "Auto Farm (Fly)", "autoFarmFly")
createToggle(sections["Auto Farm"], "Fast Attack", "fastAttack")
createToggle(sections["Auto Farm"], "Use Melee", "useMelee")
createToggle(sections["Auto Farm"], "Use Sword", "useSword")

-- Mastery
createToggle(sections["Mastery"], "Auto Mastery Finish (Fruit)", "autoMastery")

-- PvP
createToggle(sections["PvP"], "Skill Aimbot PvP (Prediction)", "pvpAimbot")

-- Raids
createToggle(sections["Raids"], "Auto Start Raid", "autoRaidStart")
createToggle(sections["Raids"], "Auto Awaken", "autoAwaken")

-- Fruit
createToggle(sections["Fruit"], "Find Dropped Fruit", "autoFruitFinder")

-- Extras
createToggle(sections["Extras"], "ESP Enabled", "espEnabled")
createToggle(sections["Extras"], "Kill Aura", "killAura")
createToggle(sections["Extras"], "Auto Hide GUI from Admin", "antiBanGuiHide")

-- Server Hop Dropdown
local hopLabel = Instance.new("TextLabel", sections["Extras"])
hopLabel.Size = UDim2.new(1, -10, 0, 20)
hopLabel.Position = UDim2.new(0, 5, 0, #sections["Extras"]:GetChildren() * 30)
hopLabel.Text = "Server Hop Mode: " .. _G.serverHopMode
hopLabel.BackgroundTransparency = 1
hopLabel.TextColor3 = Color3.new(1, 1, 1)

local function setHopMode(mode)
    _G.serverHopMode = mode
    hopLabel.Text = "Server Hop Mode: " .. mode
end

local function serverHop()
    local servers = {}
    local req = syn and syn.request or http_request
    local body = req({
        Url = "https://games.roblox.com/v1/games/2753915549/servers/Public?sortOrder=Asc&limit=100",
        Method = "GET"
    }).Body
    local data = HttpService:JSONDecode(body)
    for _, v in pairs(data.data) do
        if v.playing < v.maxPlayers then
            table.insert(servers, v)
        end
    end
    if #servers > 0 then
        table.sort(servers, function(a, b)
            return _G.serverHopMode == "Lowest" and a.playing < b.playing or a.playing > b.playing
        end)
        TPService:TeleportToPlaceInstance(game.PlaceId, servers[1].id, lp)
    end
end

local hopButton = Instance.new("TextButton", sections["Extras"])
hopButton.Size = UDim2.new(1, -10, 0, 25)
hopButton.Position = UDim2.new(0, 5, 0, #sections["Extras"]:GetChildren() * 30)
hopButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
hopButton.TextColor3 = Color3.fromRGB(255, 255, 255)
hopButton.Text = "Server Hop Now"
hopButton.MouseButton1Click:Connect(serverHop)

-- Dropdown for Boss Selection
local bossLabel = Instance.new("TextLabel", sections["Auto Farm"])
bossLabel.Size = UDim2.new(1, -10, 0, 20)
bossLabel.Position = UDim2.new(0, 5, 0, #sections["Auto Farm"]:GetChildren() * 30)
bossLabel.Text = "Selected Boss: " .. _G.selectedBoss
bossLabel.BackgroundTransparency = 1
bossLabel.TextColor3 = Color3.new(1, 1, 1)

local function setBoss(name)
    _G.selectedBoss = name
    bossLabel.Text = "Selected Boss: " .. name
end

-- 👮‍♂️ Admin Detection & GUI Hiding
spawn(function()
    while wait(2) do
        if _G.antiBanGuiHide then
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= lp and isAdmin(player) then
                    gui.Enabled = false
                    print("[AntiBan] Admin detected. GUI hidden.")
                    break
                else
                    gui.Enabled = true
                end
            end
        end
    end
end)
