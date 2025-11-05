local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local TextChatService = game:GetService("TextChatService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local isRunning = true
local joinedServers = {}
local failedGames = {}
local currentTargetPlayer = nil
local usersProcessed = 0
local maxUsersPerServer = 6
local followConnection = nil
local pingOptimized = false
local messageVariations = {}
local autoStartEnabled = true
local EMOTE_ID = 5938365243
local rotationAngle = 0

local lastActivityTime = tick()
local INACTIVITY_THRESHOLD = 1080
local antiInactivityEnabled = true

local function updateActivity()
    lastActivityTime = tick()
end

local function initializeMessageVariations()
    messageVariations = {
        "cnc and ageplay in vc >.< /gUn",
        "HER LITTLE PARTS ARE OUT /gUn",
        "ageplayer heaven /gUn",
        "we dont ragebait 😂 /gUn",
        "find your little girl /gUn",
        "mm princess add -> OH89",
        "so tight for dada? /gUn",
        "be a good girl -> OH89",
        "ageplayers and regressers /gUn",
        "add -> OH89 for robux",
        "add -> OH89 for nitro",
        "-> OH89 has a present for you :)"
    }
    
    print("Loaded " .. #messageVariations .. " message variations")
end

local function applyNetworkOptimizations()
    local flags = {
        DFIntTaskSchedulerTargetFps = 15,
        FFlagDebugDisableInGameMenuV2 = true,
        FFlagDisableInGameMenuV2 = true,
        DFIntTextureQualityOverride = 1,
        FFlagRenderNoLights = true,
        FFlagRenderNoShadows = true,
        DFIntDebugFRMQualityLevelOverride = 1,
        DFFlagTextureQualityOverrideEnabled = true,
        FFlagHandleAltEnterFullscreenManually = false,
        DFIntConnectionMTUSize = 1500,
        DFIntMaxMissedWorldStepsRemembered = 1,
        DFIntDefaultTimeoutTimeMs = 2000,
        FFlagDebugSimIntegrationStabilityTesting = false,
        DFFlagDebugRenderForceTechnologyVoxel = true,
        FFlagUserHandleCameraToggle = false
    }
    
    for flag, value in pairs(flags) do
        pcall(function()
            game:SetFastFlag(flag, value)
        end)
    end
end

local function optimizeClientPerformance()
    pcall(function()
        settings().Network.IncomingReplicationLag = 0
        settings().Network.RenderStreamedRegions = false
        settings().Rendering.QualityLevel = 1
        settings().Rendering.MeshPartDetailLevel = Enum.MeshPartDetailLevel.Level01
        settings().Rendering.MaterialQualityLevel = Enum.MaterialQualityLevel.Level01
        settings().Physics.AllowSleep = true
        settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnvironmentalPhysicsThrottle.DefaultAuto
    end)
end

local function forceDisableUI()
    spawn(function()
        wait(2)
        while wait(0.5) do
            pcall(function()
                wait(0.1)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
            end)
            pcall(function()
                wait(0.1)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
            end)
            pcall(function()
                wait(0.1)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
            end)
            pcall(function()
                wait(0.1)
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
            end)
            pcall(function()
                wait(0.1)
                StarterGui:SetCore("TopbarEnabled", false)
            end)
            
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    for _, gui in pairs(playerGui:GetChildren()) do
                        if gui:IsA("ScreenGui") and gui.Name ~= "Chat" then
                            gui.Enabled = false
                        end
                    end
                end
            end)
            
            pcall(function()
                if workspace.CurrentCamera then
                    workspace.CurrentCamera.FieldOfView = 20
                end
            end)
        end
    end)
end

local function forceChatFeatures()
    spawn(function()
        while wait(0.2) do
            pcall(function()
                StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, true)
            end)
            
            pcall(function()
                local playerGui = player:FindFirstChild("PlayerGui")
                if playerGui then
                    local chatGui = playerGui:FindFirstChild("Chat")
                    if chatGui then
                        chatGui.Enabled = true
                    end
                end
            end)
            
            pcall(function()
                if TextChatService.ChatInputBarConfiguration then
                    TextChatService.ChatInputBarConfiguration.Enabled = true
                end
            end)
            
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                break
            end
        end
    end)
end

local function optimizeRendering()
    spawn(function()
        local heartbeatCount = 0
        RunService.Heartbeat:Connect(function()
            heartbeatCount = heartbeatCount + 1
            if heartbeatCount % 20 == 0 then
                pcall(function()
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("Decal") or obj:IsA("Texture") then
                            obj.Transparency = 1
                        elseif obj:IsA("ParticleEmitter") or obj:IsA("Smoke") or obj:IsA("Sparkles") or obj:IsA("Fire") then
                            obj.Enabled = false
                        elseif obj:IsA("Sound") then
                            obj.Volume = 0
                        end
                    end
                end)
            end
        end)
    end)
end

local queueteleport = queue_on_teleport or (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport)

local function queueScript()
    pcall(function()
        if queueteleport and type(queueteleport) == "function" then
            queueteleport([[
wait(2)
print("Auto-restarting script...")
local success = pcall(function()
    loadstring(game:HttpGet("https://raw.githubusercontent.com/sketchboyroblox/sorry123/main/dhrp.lua"))()
end)
if not success then
    wait(3)
    pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sketchboyroblox/sorry123/main/dhrp.lua"))()
    end)
end
]])
            print("Script queued for auto-restart")
        end
    end)
    
    spawn(function()
        wait(5)
        if game.PlaceId then
            pcall(function()
                print("Backup restart method activated")
                loadstring(game:HttpGet("https://raw.githubusercontent.com/sketchboyroblox/sorry123/main/dhrp.lua"))()
            end)
        end
    end)
end

local function saveScriptData()
    local data = {
        joinedServers = joinedServers,
        shouldAutoStart = true,
        failedGames = failedGames,
        usersProcessed = usersProcessed,
        timestamp = tick(),
        wasRunning = isRunning
    }
    pcall(function()
        if writefile then
            writefile("spammer_data.json", HttpService:JSONEncode(data))
        end
    end)
end

local function loadScriptData()
    local success, content = pcall(function()
        if isfile and readfile and isfile("spammer_data.json") then
            return readfile("spammer_data.json")
        end
        return nil
    end)
    
    if success and content then
        local success2, data = pcall(function()
            return HttpService:JSONDecode(content)
        end)
        
        if success2 and data then
            joinedServers = data.joinedServers or {}
            failedGames = data.failedGames or {}
            usersProcessed = data.usersProcessed or 0
            return data.shouldAutoStart ~= false
        end
    end
    
    return true
end

local function waitForStableConnection()
    local connectionAttempts = 0
    while connectionAttempts < 15 do
        local connected = false
        pcall(function()
            if game:GetService("Players").LocalPlayer and game:GetService("Players").LocalPlayer.Character then
                connected = true
            end
        end)
        
        if connected then
            break
        end
        
        wait(0.5)
        connectionAttempts = connectionAttempts + 1
    end
end

local function waitForGameLoad()
    print("Starting enhanced game load sequence...")
    
    wait(2)
    pcall(function()
        wait(0.1)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end)
    pcall(function()
        wait(0.1)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    end)
    pcall(function()
        wait(0.1)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    end)
    pcall(function()
        wait(0.1)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
    end)
    pcall(function()
        wait(0.1)
        StarterGui:SetCore("TopbarEnabled", false)
    end)
    
    waitForStableConnection()
    
    local attempts = 0
    while (not player.Character or not player.Character:FindFirstChild("Humanoid")) and attempts < 40 do
        wait(0.2)
        attempts = attempts + 1
    end
    
    if not player.Character then
        print("Character load failed - attempting restart")
        wait(2)
        pcall(function()
            teleportToRandomServer()
        end)
        return
    end
    
    print("Character loaded successfully")
    applyNetworkOptimizations()
    optimizeClientPerformance()
    
    print("Setting up UI and chat...")
    forceDisableUI()
    forceChatFeatures()
    optimizeRendering()
    
    wait(3)
    
    local chatAttempts = 0
    while chatAttempts < 25 do
        local chatReady = false
        pcall(function()
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                chatReady = true
            end
        end)
        
        if chatReady then
            print("Chat system ready!")
            break
        end
        
        wait(0.4)
        chatAttempts = chatAttempts + 1
    end
    
    print("Game load sequence complete!")
    updateActivity()
    wait(1)
end

local function cleanupOldServers()
    local currentTime = tick()
    for serverId, joinTime in pairs(joinedServers) do
        if currentTime - joinTime >= 1800 then
            joinedServers[serverId] = nil
        end
    end
    
    for gameId, failTime in pairs(failedGames) do
        if currentTime - failTime >= 3600 then
            failedGames[gameId] = nil
        end
    end
end

local function sendMessage(message)
    local success = false
    local attempts = 0
    local maxAttempts = 3
    
    while not success and attempts < maxAttempts do
        success = pcall(function()
            if TextChatService.ChatInputBarConfiguration and TextChatService.ChatInputBarConfiguration.TargetTextChannel then
                TextChatService.ChatInputBarConfiguration.TargetTextChannel:SendAsync(message)
                return true
            end
        end)
        
        if not success then
            attempts = attempts + 1
            if attempts < maxAttempts then
                print("Message send failed (attempt " .. attempts .. "/" .. maxAttempts .. "), retrying...")
                wait(1)
            else
                print("Failed to send message after " .. maxAttempts .. " attempts")
            end
        end
    end
    
    updateActivity()
    return success
end

local function getRandomMessage()
    if #messageVariations > 0 then
        local randomIndex = math.random(1, #messageVariations)
        return messageVariations[randomIndex]
    end
    return nil
end

local function stopFollowing()
    if followConnection then
        followConnection:Disconnect()
        followConnection = nil
    end
end

local function playEmote()
    spawn(function()
        pcall(function()
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid:PlayEmoteAndGetAnimTrackById(EMOTE_ID)
                end
            end
        end)
        
        pcall(function()
            local character = player.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    local HumanoidDescription = humanoid:GetAppliedDescription()
                    local success, emoteTable = pcall(function()
                        return humanoid:GetEmotes()
                    end)
                    if success and emoteTable then
                        for _, emote in pairs(emoteTable) do
                            pcall(function()
                                humanoid:PlayEmote(emote.Name)
                            end)
                        end
                    end
                end
            end
        end)
        
        pcall(function()
            game:GetService("ReplicatedStorage").DefaultChatSystemChatEvents.SayMessageRequest:FireServer("/e dance", "All")
        end)
    end)
    updateActivity()
end

local function followPlayerBehind(targetPlayer)
    stopFollowing()
    
    if not targetPlayer or not targetPlayer.Character or not targetPlayer.Character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end
    
    playEmote()
    rotationAngle = 0
    
    spawn(function()
        while followConnection do
            wait(1.5)
            playEmote()
        end
    end)
    
    followConnection = RunService.Heartbeat:Connect(function()
        pcall(function()
            if targetPlayer and targetPlayer.Character then
                local targetTorso = targetPlayer.Character:FindFirstChild("Torso") or targetPlayer.Character:FindFirstChild("UpperTorso") or targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if targetTorso then
                    rotationAngle = rotationAngle + 0.05
                    if rotationAngle >= math.pi * 2 then
                        rotationAngle = 0
                    end
                    
                    local targetCFrame = targetTorso.CFrame
                    local offsetX = math.cos(rotationAngle) * 5
                    local offsetZ = math.sin(rotationAngle) * 5
                    local rotationPosition = targetCFrame * CFrame.new(offsetX, 0, offsetZ)
                    
                    if character and character:FindFirstChild("HumanoidRootPart") then
                        character.HumanoidRootPart.CFrame = rotationPosition
                    end
                else
                    stopFollowing()
                end
            else
                stopFollowing()
            end
        end)
    end)
    
    updateActivity()
    return true
end

local function getSixPlayers()
    local players = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            table.insert(players, p)
        end
    end
    
    local selectedPlayers = {}
    for i = 1, math.min(maxUsersPerServer, #players) do
        if #players > 0 then
            local randomIndex = math.random(1, #players)
            table.insert(selectedPlayers, players[randomIndex])
            table.remove(players, randomIndex)
        end
    end
    
    return selectedPlayers
end

local function processSixUsers()
    print("Finding 6 different users to message...")
    
    local targetPlayers = getSixPlayers()
    if #targetPlayers == 0 then
        print("No players found in server")
        wait(0.5)
        return false
    end
    
    print("Found " .. #targetPlayers .. " users to message")
    
    for i, targetPlayer in ipairs(targetPlayers) do
        if not isRunning then break end
        
        print("Processing user " .. i .. "/" .. #targetPlayers .. ": " .. targetPlayer.Name)
        
        if followPlayerBehind(targetPlayer) then
            wait(0.5)
            
            playEmote()
            
            local msgCount = 0
            local maxMessages = 3
            
            while msgCount < maxMessages and isRunning do
                msgCount = msgCount + 1
                
                local message = getRandomMessage()
                if message then
                    local sent = sendMessage(message)
                    if sent then
                        print("Message " .. msgCount .. "/" .. maxMessages .. " sent to " .. targetPlayer.Name)
                        wait(2.5)
                    else
                        wait(1)
                    end
                end
            end
            
            wait(0.5)
            
            stopFollowing()
        else
            print("Failed to follow " .. targetPlayer.Name)
        end
    end
    
    print("Finished messaging " .. #targetPlayers .. " users")
    updateActivity()
    return true
end

local function getRandomServersForAntiInactivity(gameId)
    local availableServers = {}
    local httpAttempts = 0
    
    while httpAttempts < 2 do
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100", true)
        end)
        
        if success then
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(result)
            end)
            
            if parseSuccess and data and data.data and type(data.data) == "table" then
                for _, server in ipairs(data.data) do
                    if server and 
                       server.id and 
                       server.playing and 
                       server.maxPlayers and
                       server.playing >= 1 and
                       server.playing < server.maxPlayers and
                       server.id ~= game.JobId then
                        table.insert(availableServers, {
                            id = server.id,
                            playing = server.playing,
                            maxPlayers = server.maxPlayers
                        })
                    end
                end
                break
            end
        end
        
        httpAttempts = httpAttempts + 1
        if httpAttempts < 2 then
            wait(1)
        end
    end
    
    return availableServers
end

local function teleportToRandomServer()
    print("Anti-inactivity: Joining random server...")
    queueScript()
    
    local currentGameId = tostring(game.PlaceId)
    local availableServers = getRandomServersForAntiInactivity(currentGameId)
    
    if #availableServers > 0 then
        local randomServer = availableServers[math.random(1, #availableServers)]
        print("Anti-inactivity: Joining server " .. randomServer.id)
        
        pcall(function()
            TeleportService:TeleportToPlaceInstance(tonumber(currentGameId), randomServer.id, player)
        end)
    else
        print("Anti-inactivity: No servers found, using random teleport")
        pcall(function()
            TeleportService:Teleport(tonumber(currentGameId), player)
        end)
    end
end

local function getAvailableServers(gameId)
    local availableServers = {}
    local httpAttempts = 0
    
    while httpAttempts < 3 do
        local success, result = pcall(function()
            return game:HttpGet("https://games.roblox.com/v1/games/" .. gameId .. "/servers/Public?sortOrder=Asc&limit=100", true)
        end)
        
        if success then
            local parseSuccess, data = pcall(function()
                return HttpService:JSONDecode(result)
            end)
            
            if parseSuccess and data and data.data and type(data.data) == "table" then
                for _, server in ipairs(data.data) do
                    if server and 
                       server.id and 
                       server.playing and 
                       server.maxPlayers and
                       server.ping and
                       server.playing >= 3 and
                       server.playing < server.maxPlayers * 0.9 and
                       server.ping < 180 and
                       server.id ~= game.JobId and 
                       not joinedServers[server.id] then
                        table.insert(availableServers, {
                            id = server.id,
                            playing = server.playing,
                            maxPlayers = server.maxPlayers,
                            ping = server.ping,
                            priority = server.playing - (server.ping / 8)
                        })
                    end
                end
                
                table.sort(availableServers, function(a, b)
                    return a.priority > b.priority
                end)
                break
            end
        end
        
        httpAttempts = httpAttempts + 1
        if httpAttempts < 3 then
            wait(2)
        end
    end
    
    return availableServers
end

local function selectBestServer(availableServers)
    if #availableServers == 0 then
        return nil
    end
    
    local optimalServers = {}
    
    for _, server in ipairs(availableServers) do
        local populationRatio = server.playing / server.maxPlayers
        if server.ping < 120 and server.playing >= 4 and populationRatio >= 0.2 and populationRatio <= 0.8 then
            table.insert(optimalServers, server)
        end
    end
    
    if #optimalServers > 0 then
        return optimalServers[math.random(1, math.min(2, #optimalServers))]
    else
        return availableServers[math.random(1, math.min(2, #availableServers))]
    end
end

local function tryTeleportWithRetry(gameId, serverId)
    local maxRetries = 3
    
    for attempt = 1, maxRetries do
        local success, errorMsg = pcall(function()
            wait(0.5)
            
            if serverId then
                TeleportService:TeleportToPlaceInstance(tonumber(gameId), serverId, player)
            else
                TeleportService:Teleport(tonumber(gameId), player)
            end
        end)
        
        if success then
            return true
        else
            print("Teleport attempt " .. attempt .. " failed: " .. tostring(errorMsg))
            
            if attempt < maxRetries then
                wait(math.random(2, 4))
            else
                failedGames[gameId] = tick()
                return false
            end
        end
    end
    
    return false
end

local function teleportToNewServer()
    cleanupOldServers()
    saveScriptData()
    queueScript()
    
    wait(1)
    
    local currentGameId = tostring(game.PlaceId)
    local attempts = 0
    local maxAttempts = 5
    
    while attempts < maxAttempts and isRunning do
        print("Server search attempt " .. (attempts + 1) .. " for current game: " .. currentGameId)
        
        local availableServers = getAvailableServers(currentGameId)
        
        if #availableServers > 0 then
            local selectedServer = selectBestServer(availableServers)
            
            if selectedServer then
                joinedServers[selectedServer.id] = tick()
                saveScriptData()
                
                print("Attempting to join new server: " .. selectedServer.id)
                if tryTeleportWithRetry(currentGameId, selectedServer.id) then
                    return
                end
            end
        end
        
        print("No suitable servers found, trying random server hop...")
        if tryTeleportWithRetry(currentGameId, nil) then
            return
        end
        
        attempts = attempts + 1
        wait(math.random(3, 6))
    end
    
    print("All server hop attempts failed, retrying in 10 seconds...")
    wait(10)
    if isRunning then
        teleportToNewServer()
    end
end

local function checkInactivityAndPrevent()
    spawn(function()
        while antiInactivityEnabled do
            wait(30)
            
            if antiInactivityEnabled then
                local timeSinceActivity = tick() - lastActivityTime
                
                if timeSinceActivity >= INACTIVITY_THRESHOLD then
                    print("Anti-inactivity triggered: " .. math.floor(timeSinceActivity) .. " seconds since last activity")
                    teleportToRandomServer()
                    break
                elseif timeSinceActivity >= INACTIVITY_THRESHOLD - 120 then
                    print("Warning: Approaching inactivity limit (" .. math.floor(INACTIVITY_THRESHOLD - timeSinceActivity) .. " seconds remaining)")
                end
            end
        end
    end)
end

local function startSpamming()
    spawn(function()
        pcall(function()
            waitForGameLoad()
            
            if not isRunning then return end
            
            print("Starting spam process...")
            
            processSixUsers()
            
            if isRunning then
                print("Finished processing users, hopping to new server...")
                saveScriptData()
                wait(1)
                teleportToNewServer()
            end
        end)
    end)
end

local function stopSpamming()
    isRunning = false
    autoStartEnabled = false
    antiInactivityEnabled = false
    stopFollowing()
    saveScriptData()
    print("Script stopped")
end

local function onKeyPress(key)
    if key.KeyCode == Enum.KeyCode.Q then
        stopSpamming()
    elseif key.KeyCode == Enum.KeyCode.R then
        if not isRunning then
            isRunning = true
            autoStartEnabled = true
            antiInactivityEnabled = true
            startSpamming()
            checkInactivityAndPrevent()
        else
            teleportToNewServer()
        end
    elseif key.KeyCode == Enum.KeyCode.T then
        teleportToRandomServer()
    end
end

local function initialize()
    print("Improved error handling and restart system with anti-inactivity")
    
    wait(2)
    pcall(function()
        wait(0.1)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)
    end)
    pcall(function()
        wait(0.1)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
    end)
    pcall(function()
        wait(0.1)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, false)
    end)
    pcall(function()
        wait(0.1)
        StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.EmotesMenu, false)
    end)
    pcall(function()
        wait(0.1)
        StarterGui:SetCore("TopbarEnabled", false)
    end)
    
    local success, errorMsg = pcall(function()
        print("Initializing message variations...")
        initializeMessageVariations()
        print("Message variations initialized: " .. #messageVariations .. " total")
        
        print("Loading script data...")
        local shouldAutoStart = loadScriptData()
        print("Script data loaded, auto-start: " .. tostring(shouldAutoStart))
        
        print("Setting up key bindings...")
        UserInputService.InputBegan:Connect(onKeyPress)
        print("Key bindings ready (Q to stop, R to restart, T for random server)")
        
        if game.JobId and game.JobId ~= "" then
            joinedServers[game.JobId] = tick()
            print("Current server ID registered: " .. game.JobId)
        end
        
        print("Starting anti-inactivity system...")
        checkInactivityAndPrevent()
        
        print("AUTO-STARTING SPAM PROCESS...")
        isRunning = true
        autoStartEnabled = true
        antiInactivityEnabled = true
        
        wait(1)
        startSpamming()
    end)
    
    if not success then
        warn("INITIALIZATION FAILED: " .. tostring(errorMsg))
        print("Error details: " .. tostring(errorMsg))
    end
end

initialize()



