--[[
    Bubble Gum Simulator Auto Farm Script for Delta Executor
    Created for Bubble Gum Simulator INFINITY
    
    HOW TO USE:
    1. Copy this entire script
    2. Open Delta executor in Roblox
    3. Paste this script into the executor
    4. Execute the script in Bubble Gum Simulator
    
    FEATURES:
    - Auto Farm bubbles
    - Auto Sell bubbles
    - Auto Hatch eggs
    - Auto Teleport to islands
    - Auto Teleport to floating islands when they spawn
    
    NOTE: This script will only work when executed inside Roblox with Delta executor!
]]--

-- Error handling
local success, errorMsg = pcall(function()
    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local TweenService = game:GetService("TweenService")
    local RunService = game:GetService("RunService")
    local UserInputService = game:GetService("UserInputService")
    
    -- Check if game is loaded correctly
    if not game:IsLoaded() then
        game.Loaded:Wait()
    end
    
    -- Verify we're in the right game
    if game.PlaceId ~= 2512643572 and game.PlaceId ~= 5324597737 then
        print("This script is only for Bubble Gum Simulator! Current game: " .. game.PlaceId)
        return
    end
    
    -- Variables
    local Player = Players.LocalPlayer
    local Character = Player.Character or Player.CharacterAdded:Wait()
    local Humanoid = Character:WaitForChild("Humanoid")
    local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Print startup message
    print("Script initializing - searching for remote events...")
    
    -- Remote Events with fallback options
    local RemoteEvents = ReplicatedStorage:FindFirstChild("NetworkRemoteEvents") or ReplicatedStorage:FindFirstChild("RemoteEvents")
    if not RemoteEvents then
        error("Could not find RemoteEvents. Game may have been updated.")
    end
    
    -- Try different possible names for remote events
    local BlowBubbleEvent = RemoteEvents:FindFirstChild("BlowBubble") or RemoteEvents:FindFirstChild("Bubble") or RemoteEvents:FindFirstChild("Blow")
    local SellBubbleEvent = RemoteEvents:FindFirstChild("SellBubble") or RemoteEvents:FindFirstChild("Sell")
    local OpenEggEvent = RemoteEvents:FindFirstChild("OpenEgg") or RemoteEvents:FindFirstChild("HatchEgg") or RemoteEvents:FindFirstChild("Hatch")
    
    -- Check if we found all remote events
    if not BlowBubbleEvent then
        print("BlowBubble event not found - auto farm disabled")
    end
    if not SellBubbleEvent then
        print("SellBubble event not found - auto sell disabled")
    end
    if not OpenEggEvent then
        print("OpenEgg event not found - auto hatch disabled")
    end
    
    -- Game Data
    local Islands = {
        ["Main Island"] = CFrame.new(237, 94, 351),
        ["Beach Island"] = CFrame.new(1183, 93, 318),
        ["Atlantis"] = CFrame.new(604, 90, -385),
        ["Candy Land"] = CFrame.new(41, 91, -546),
        ["Toy Land"] = CFrame.new(-593, 93, 10),
        ["Dinosaur Island"] = CFrame.new(-39, 224, -600),
        ["Mythic Island"] = CFrame.new(2330, 93, 1074),
        ["Space Island"] = CFrame.new(1418, 266, 1629),
        ["Underworld"] = CFrame.new(348, -144, 897)
    }
    
    local EggsList = {
        ["Common Egg"] = {name = "Common Egg", position = CFrame.new(254, 91, 377)},
        ["Spotted Egg"] = {name = "Spotted Egg", position = CFrame.new(289, 91, 377)},
        ["Candy Egg"] = {name = "Candy Egg", position = CFrame.new(77, 91, -524)},
        ["Beach Egg"] = {name = "Beach Egg", position = CFrame.new(1215, 93, 344)},
        ["Atlantis Egg"] = {name = "Atlantis Egg", position = CFrame.new(565, 90, -407)},
        ["Toy Egg"] = {name = "Toy Egg", position = CFrame.new(-560, 91, 32)},
        ["Dinosaur Egg"] = {name = "Dinosaur Egg", position = CFrame.new(-66, 224, -573)},
        ["Space Egg"] = {name = "Space Egg", position = CFrame.new(1390, 266, 1655)}
    }
    
    -- Settings
    local Settings = {
        AutoFarm = false,
        AutoSell = false,
        AutoHatch = false,
        AutoTeleport = false,
        AutoFloatingIsland = false,
        SelectedIsland = "Main Island",
        SelectedEgg = "Common Egg",
        HatchAmount = 1,
        TeleportDelay = 5
    }
    
    -- Let's try a different UI library that's more compatible with recent versions
    print("Loading UI library...")
    local Library = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
    
    -- Create UI Window
    local MainWindow = Library:MakeWindow({
        Name = "Bubble Gum Simulator", 
        HidePremium = true,
        SaveConfig = true, 
        ConfigFolder = "BubbleGumSimulator"
    })

-- Create Tabs
local FarmingTab = MainWindow:MakeTab({
    Name = "Farming",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local EggsTab = MainWindow:MakeTab({
    Name = "Eggs",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local TeleportTab = MainWindow:MakeTab({
    Name = "Teleport",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local SettingsTab = MainWindow:MakeTab({
    Name = "Settings",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- Farming Tab
FarmingTab:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(Value)
        Settings.AutoFarm = Value
    end    
})

FarmingTab:AddToggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(Value)
        Settings.AutoSell = Value
    end    
})

-- Eggs Tab
EggsTab:AddDropdown({
    Name = "Select Egg",
    Default = "Common Egg",
    Options = {"Common Egg", "Spotted Egg", "Candy Egg", "Beach Egg", "Atlantis Egg", "Toy Egg", "Dinosaur Egg", "Space Egg"},
    Callback = function(Value)
        Settings.SelectedEgg = Value
    end    
})

EggsTab:AddDropdown({
    Name = "Hatch Amount",
    Default = "1",
    Options = {"1", "3"},
    Callback = function(Value)
        Settings.HatchAmount = tonumber(Value)
    end    
})

EggsTab:AddToggle({
    Name = "Auto Hatch",
    Default = false,
    Callback = function(Value)
        Settings.AutoHatch = Value
    end    
})

-- Teleport Tab
TeleportTab:AddDropdown({
    Name = "Select Island",
    Default = "Main Island",
    Options = {"Main Island", "Beach Island", "Atlantis", "Candy Land", "Toy Land", "Dinosaur Island", "Mythic Island", "Space Island", "Underworld"},
    Callback = function(Value)
        Settings.SelectedIsland = Value
    end    
})

TeleportTab:AddButton({
    Name = "Teleport to Island",
    Callback = function()
        pcall(function() TeleportToIsland(Settings.SelectedIsland) end)
    end    
})

TeleportTab:AddToggle({
    Name = "Auto Teleport",
    Default = false,
    Callback = function(Value)
        Settings.AutoTeleport = Value
    end    
})

TeleportTab:AddToggle({
    Name = "Auto Floating Island",
    Default = false,
    Callback = function(Value)
        Settings.AutoFloatingIsland = Value
    end    
})

-- Settings Tab
SettingsTab:AddSlider({
    Name = "Teleport Delay (seconds)",
    Min = 1,
    Max = 30,
    Default = 5,
    Color = Color3.fromRGB(255, 255, 255),
    Increment = 1,
    Callback = function(Value)
        Settings.TeleportDelay = Value
    end    
})

-- Functions
function TeleportToIsland(IslandName)
    if Islands[IslandName] then
        local TargetCFrame = Islands[IslandName]
        HumanoidRootPart.CFrame = TargetCFrame
    else
        Library:MakeNotification({
            Name = "Teleport Failed",
            Content = "Island not found: " .. IslandName,
            Image = "rbxassetid://4483345998",
            Time = 5
        })
    end
end

function TeleportToPosition(Position)
    HumanoidRootPart.CFrame = Position
end

function SellBubbles()
    if Settings.AutoSell then
        -- Find closest sell area
        local sellPart = workspace:FindFirstChild("SellPart", true)
        if sellPart then
            -- Save current position
            local currentPos = HumanoidRootPart.CFrame
            
            -- Teleport to sell area
            TeleportToPosition(sellPart.CFrame)
            
            -- Fire sell event
            SellBubbleEvent:FireServer()
            
            -- Wait a short time
            wait(0.5)
            
            -- Return to previous position
            TeleportToPosition(currentPos)
        end
    end
end

function HatchEgg()
    if Settings.AutoHatch then
        local selectedEgg = EggsList[Settings.SelectedEgg]
        if selectedEgg then
            -- Teleport to egg
            TeleportToPosition(selectedEgg.position)
            
            -- Try to hatch egg
            OpenEggEvent:FireServer(selectedEgg.name, Settings.HatchAmount)
            
            -- Wait for animation
            wait(1.5)
        end
    end
end

function BlowBubble()
    if Settings.AutoFarm then
        BlowBubbleEvent:FireServer()
    end
end

function CheckForFloatingIslands()
    if Settings.AutoFloatingIsland then
        -- Search for floating islands in workspace
        local floatingIslands = workspace:FindFirstChild("FloatingIslands")
        if floatingIslands then
            for _, island in pairs(floatingIslands:GetChildren()) do
                if island:IsA("Model") and island:FindFirstChild("Platform") then
                    -- Teleport to floating island
                    TeleportToPosition(island.Platform.CFrame + Vector3.new(0, 5, 0))
                    Library:MakeNotification({
                        Name = "Auto Teleport",
                        Content = "Teleported to floating island",
                        Image = "rbxassetid://4483345998",
                        Time = 5
                    })
                    wait(Settings.TeleportDelay)
                    break
                end
            end
        end
    end
end

-- Main Loops
spawn(function()
    while true do
        wait(0.1)
        if Settings.AutoFarm and BlowBubbleEvent then
            pcall(function() BlowBubble() end)
        end
    end
end)

spawn(function()
    while true do
        wait(2)
        if Settings.AutoSell and SellBubbleEvent then
            pcall(function() SellBubbles() end)
        end
    end
end)

spawn(function()
    while true do
        wait(3)
        if Settings.AutoHatch and OpenEggEvent then
            pcall(function() HatchEgg() end)
        end
    end
end)

spawn(function()
    while true do
        wait(Settings.TeleportDelay)
        if Settings.AutoTeleport then
            pcall(function() TeleportToIsland(Settings.SelectedIsland) end)
        end
    end
end)

spawn(function()
    while true do
        wait(10)
        if Settings.AutoFloatingIsland then
            pcall(function() CheckForFloatingIslands() end)
        end
    end
end)

-- Handle character respawn
Player.CharacterAdded:Connect(function(NewCharacter)
    Character = NewCharacter
    Humanoid = Character:WaitForChild("Humanoid")
    HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
    
    -- Re-run teleport if needed
    if Settings.AutoTeleport then
        pcall(function() TeleportToIsland(Settings.SelectedIsland) end)
    end
end)

-- Notifications
Library:MakeNotification({
    Name = "Script Loaded",
    Content = "Bubble Gum Simulator Auto Farm has been loaded successfully!",
    Image = "rbxassetid://4483345998",
    Time = 5
})

-- Close pcall function from the beginning
end)

-- Check if script loaded successfully
if not success then
    -- In Roblox environment this would use warn(), but we're using print for compatibility
    print("Script initialization failed: " .. tostring(errorMsg))
    
    -- Attempt to create a basic notification even if the script failed
    pcall(function()
        local BasicLibrary = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Orion/main/source'))()
        BasicLibrary:MakeNotification({
            Name = "Script Error",
            Content = "Failed to load script. Error: " .. tostring(errorMsg),
            Image = "rbxassetid://4483345998",
            Time = 10
        })
    end)
end

-- Final message in console
print("BubbleGumSimulator script execution completed")
