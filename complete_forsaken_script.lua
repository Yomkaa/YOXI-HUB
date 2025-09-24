-- Полный обновленный Forsaken скрипт с улучшенной авто-блок логикой
local Services = {
    Players = game:GetService("Players"),
    RunService = game:GetService("RunService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    Workspace = game:GetService("Workspace"),
    VirtualUser = game:GetService("VirtualUser"),
    UserInputService = game:GetService("UserInputService"),
    HttpService = game:GetService("HttpService"),
    StarterGui = game:GetService("StarterGui"),
    TweenService = game:GetService("TweenService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    GuiService = game:GetService("GuiService"),
    CoreGui = game:GetService("CoreGui"),
    Debris = game:GetService("Debris"),
}

local player = Services.Players.LocalPlayer
local camera = Services.Workspace.CurrentCamera

-- Configuration
local CONFIG = {
    GENERATOR_WAIT_TIME_DEFAULT = 5,
    GENERATOR_WAIT_TIME_MAX = 30,
    NOTIFICATION_IMAGE_ID = 83784037333375,
}

-- State Table
local state = {
    autoGenerator = false,
    generatorWaitTime = CONFIG.GENERATOR_WAIT_TIME_DEFAULT,
    killerESP = false,
    playerESP = false,
    generatorESP = false,
    itemESP = false,
    pizzaEsp = false,
    speedBoost = false,
    sprintSpeed = 26,
    noStaminaLoss = false,
    fieldOfView = 80,
    autoRemovePopups = false,
    noClip = false,
    antiSlateskinDebuff = false,
    antiFallDebuff = false,
    antiMedkitDebuff = false,
    antiColaDebuff = false,
    antiSubspaceDebuff = false,
    antiGlitchedEffect = false,
    antiBlindness = false,
    antiBurgerDebuff = false,
    antiSlashDebuff = false,
    antiChickenDebuff = false,
    antiBlockDebuff = false,
    bypassChargeSpeed = false,
    antiSlowAfterChargeEnd = false,
    antiAutoFovCharge = false,
    bypassPunchSpeed = false,
    antiTaphTripwire = false,
    antiSubspaceTripmine = false,
    antiPlasmaBeam = false,
    antiSpawnProtection = false,
    antiTwoTimeStab = false,
    antiTwoTimeCrouching = false,
    antiCoolGui = false,
    antiBehead = false,
    antiEnraged = false,
    antiAFK = false,
    antiWalkSpeedOverride = false,
    antiCorruptNature = false,
    antiPizzaDelivery = false,
    pizzaDeliveryEsp = false,
    zombieEsp = false,
    fullBright = false,
    antiMassInfection = false,
    antiEntanglement = false,
    autoCoinFlip = false,
    -- CFrame speed
    cframeSpeedEnabled = false,
    cframeSpeedValue = 15,
    -- Новое состояние для отображения времени раунда
    showRoundTime = false,
    -- Новые состояния для GUI
    showTeleportGUI = false,
    -- Новые состояния для tracers
    killerTracers = false,
    survivorTracers = false,
    generatorTracers = false,
    itemTracers = false,
    pizzaTracers = false,
    pizzaDeliveryTracers = false,
    zombieTracers = false,
    -- Auto Block state
    facingCheckEnabled = false,
    detectionRange = 20,
    autoPunchOn = false,
    -- Noli antis
    antiNovaStarDebuff = false,
    antiVoidRushStun = false,
    fasterVoidRush = false,
    -- Noli aim
    aimBotVoidRush = false,
    -- New states from updated logic
    autoBlockAudioOn = false,
    looseFacing = false,
    aimPunch = false,
    aimPunchPrediction = 3,
    fakeBlock = false,
    taphTripwireEsp = false,
    tripMineEsp = false,
    footprintEsp = false,
    trialEsp = false,
    twoTimeRespawnEsp = false,
    -- Plasma Beam Aimbot
    plasmaBeamAimKiller = false,
    plasmaBeamAimSurvivor = false,
    -- New for 1x1x1x1
    massInfectionAimBot = false,
    entanglementAimBot = false,
    corruptAimAssist = false,
    corruptPrediction = 0,
    -- Chance AimBot
    chanceAimBot = false,
    chancePrediction = 4,
    chanceAimNormal = true,
}

-- ===== UPDATED AUTO-BLOCK SECTION WITH NEW LOGIC =====
-- Enhanced Auto Block logic with improved detection and performance

-- Auto Block IDs (updated from new script)
local autoBlockTriggerSounds = {
    ["102228729296384"] = true,
    ["140242176732868"] = true,
    ["112809109188560"] = true,
    ["136323728355613"] = true,
    ["115026634746636"] = true,
    ["84116622032112"] = true,
    ["108907358619313"] = true,
    ["127793641088496"] = true,
    ["86174610237192"] = true,
    ["95079963655241"] = true,
    ["101199185291628"] = true,
    ["119942598489800"] = true,
    ["84307400688050"] = true,
    ["113037804008732"] = true,
    ["105200830849301"] = true,
    ["75330693422988"] = true,
    ["82221759983649"] = true,
    ["81702359653578"] = true,
    ["108610718831698"] = true,
    ["112395455254818"] = true,
    ["109431876587852"] = true,
    ["109348678063422"] = true,
    ["85853080745515"] = true,
    ["12222216"] = true,
    ["105840448036441"] = true,
    ["114742322778642"] = true,
}

local autoBlockTriggerAnims = {
    "126830014841198", "126355327951215", "121086746534252", "18885909645",
    "98456918873918", "105458270463374", "83829782357897", "125403313786645",
    "118298475669935", "82113744478546", "70371667919898", "99135633258223",
    "97167027849946", "109230267448394", "139835501033932", "126896426760253",
    "109667959938617", "126681776859538", "129976080405072", "121293883585738",
    "81639435858902", "137314737492715",
    "92173139187970"
}

-- Anti-flick variables (updated)
local antiFlickOn = false
local antiFlickParts = 8
local antiFlickDelay = 0
local antiFlickBaseOffset = 1
local antiFlickOffsetStep = 0.3

-- Enhanced prediction constants
local PRED_SECONDS_FORWARD = 0.25
local PRED_SECONDS_LATERAL = 0.18
local PRED_MAX_FORWARD = 6.2
local PRED_MAX_LATERAL = 4
local ANG_TURN_MULTIPLIER = 0.6
local SMOOTHING_LERP = 0.22

-- Performance improvements
local killerState = {}
local predictionStrength = 1
local predictionTurnStrength = 1
local blockPartsSizeMultiplier = 1
local stagger = 0.02
local doubleblocktech = false
local autoAdjustDBTFBPS = false

-- Cached UI references for better performance
local cachedPlayerGui = player:FindFirstChild("PlayerGui") or player.PlayerGui
local cachedPunchBtn, cachedBlockBtn, cachedCharges, cachedCooldown, cachedChargeBtn, cachedCloneBtn = nil, nil, nil, nil, nil, nil

-- Killer delay mapping for auto-adjustment
local killerDelayMap = {
    ["c00lkidd"] = 0,
    ["jason"]    = 0.013,
    ["slasher"]  = 0.01,
    ["1x1x1x1"]  = 0.15,
    ["johndoe"]  = 0.33,
    ["noli"]     = 0.15,
}

-- Enhanced facing check with customizable dot product
local customFacingDot = -0.3

-- Sound detection and blocking
local soundHooks = {}
local soundBlockedUntil = {}
local LOCAL_BLOCK_COOLDOWN = 0.7
local lastLocalBlockTime = 0
local AUDIO_PREDICT_DT = 0.08
local AUDIO_LOCAL_COOLDOWN = 0.35
local AUDIO_SOUND_THROTTLE = 1.0

-- Auto block type selection
local autoblocktype = "Block" -- Options: "Block", "Charge", "7n7 Clone"

-- Enhanced UI refresh function
local function refreshUIRefs()
    cachedPlayerGui = player:FindFirstChild("PlayerGui") or cachedPlayerGui
    local main = cachedPlayerGui and cachedPlayerGui:FindFirstChild("MainUI")
    if main then
        local ability = main:FindFirstChild("AbilityContainer")
        cachedPunchBtn = ability and ability:FindFirstChild("Punch")
        cachedBlockBtn = ability and ability:FindFirstChild("Block")
        cachedChargeBtn = ability and ability:FindFirstChild("Charge")
        cachedCloneBtn = ability and ability:FindFirstChild("Clone")
        cachedCharges = cachedPunchBtn and cachedPunchBtn:FindFirstChild("Charges")
        cachedCooldown = cachedBlockBtn and cachedBlockBtn:FindFirstChild("CooldownTime")
    else
        cachedPunchBtn, cachedBlockBtn, cachedCharges, cachedCooldown, cachedChargeBtn, cachedCloneBtn = nil, nil, nil, nil, nil, nil
    end
end

-- Initialize UI references
refreshUIRefs()
if cachedPlayerGui then
    cachedPlayerGui.ChildAdded:Connect(function(child)
        if child.Name == "MainUI" then
            task.delay(0.02, refreshUIRefs)
        end
    end)
end

player.CharacterAdded:Connect(function()
    task.delay(0.5, refreshUIRefs)
end)

-- Enhanced sound ID extraction with better performance
local string_match = string.match
local tostring_local = tostring

local function extractNumericSoundId(sound)
    if not sound then return nil end
    local sid = sound.SoundId
    if not sid then return nil end
    sid = (type(sid) == "string") and sid or tostring_local(sid)
    local num =
        string_match(sid, "rbxassetid://(%d+)") or
        string_match(sid, "://(%d+)") or
        string_match(sid, "^(%d+)$")
    if num and #num > 0 then
        return num
    end
    local hash = string_match(sid, "[&%?]hash=([^&]+)")
    if hash then
        return "&hash=" .. hash
    end
    local path = string_match(sid, "rbxasset://sounds/.+")
    if path then
        return path
    end
    return nil
end

-- Enhanced facing check with better performance
local function isFacing(localRoot, targetRoot)
    if not state.facingCheckEnabled then
        return true
    end
    local dx = localRoot.Position.X - targetRoot.Position.X
    local dy = localRoot.Position.Y - targetRoot.Position.Y
    local dz = localRoot.Position.Z - targetRoot.Position.Z
    local mag = math.sqrt(dx*dx + dy*dy + dz*dz)
    if mag == 0 then return true end
    local invMag = 1 / mag
    local ux, uy, uz = dx * invMag, dy * invMag, dz * invMag
    local lv = targetRoot.CFrame.LookVector
    local lx, ly, lz = lv.X, lv.Y, lv.Z
    local dot = lx * ux + ly * uy + lz * uz
    return dot > (customFacingDot or -0.3)
end

-- Enhanced sound position detection
local function getSoundWorldPosition(sound)
    if not sound then return nil end
    local parent = sound.Parent
    if parent then
        if parent:IsA("BasePart") then
            return parent.Position, parent
        end
        if parent:IsA("Attachment") then
            local gp = parent.Parent
            if gp and gp:IsA("BasePart") then
                return gp.Position, gp
            end
        end
    end
    local KillersFolder = Services.Workspace:FindFirstChild("Players") and Services.Workspace.Players:FindFirstChild("Killers")
    if KillersFolder and sound:IsDescendantOf(KillersFolder) then
        local root = parent or sound
        local found = root:FindFirstChildWhichIsA("BasePart", true)
        if found then
            return found.Position, found
        end
    end
    return nil, nil
end

-- Enhanced character detection
local function getCharacterFromDescendant(inst)
    if not inst then return nil end
    local model = inst:FindFirstAncestorOfClass("Model")
    if model and model:FindFirstChildOfClass("Humanoid") then
        return model
    end
    return nil
end

-- Point-in-part detection for anti-flick
local function isPointInsidePart(part, point)
    if not (part and point) then return false end
    local rel = part.CFrame:PointToObjectSpace(point)
    local half = part.Size * 0.5
    return math.abs(rel.X) <= half.X + 0.001 and
           math.abs(rel.Y) <= half.Y + 0.001 and
           math.abs(rel.Z) <= half.Z + 0.001
end

-- Enhanced GUI activation with better fallback
local function tryActivateButton(btn)
    if not btn then return false end
    pcall(function() btn:Activate() end)
    local ok, conns = pcall(function()
        if type(getconnections) == "function" then
            return getconnections(btn.MouseButton1Click)
        end
        return nil
    end)
    if ok and conns then
        for _, conn in ipairs(conns) do
            pcall(function()
                if conn.Function then
                    conn.Function()
                elseif conn.func then
                    conn.func()
                elseif conn.Fire then
                    conn.Fire()
                end
            end)
        end
    end
    pcall(function()
        if btn.Activated then
            btn.Activated:Fire()
        end
    end)
    return true
end

-- Enhanced GUI firing functions
local function fireGuiBlock()
    if cachedBlockBtn and tryActivateButton(cachedBlockBtn) then return end
    -- Fallback to remote if GUI fails
    local args = {"UseActorAbility", "Block"}
    local ok, path = pcall(function()
        return Services.ReplicatedStorage:FindFirstChild("Modules") and Services.ReplicatedStorage.Modules:FindFirstChild("Network") and Services.ReplicatedStorage.Modules.Network:FindFirstChild("RemoteEvent")
    end)
    if ok and path and path.FireServer then
        pcall(function() path:FireServer(unpack(args)) end)
        return
    end
    local alt = Services.ReplicatedStorage:FindFirstChild("RemoteEvent") or Services.ReplicatedStorage:FindFirstChild("Remote") or Services.ReplicatedStorage:FindFirstChild("RemoteFunction")
    if alt and alt.FireServer then
        pcall(function() alt:FireServer(unpack(args)) end)
    end
end

local function fireGuiPunch()
    if cachedPunchBtn and tryActivateButton(cachedPunchBtn) then return end
    -- Fallback to remote if GUI fails
    local args = {"UseActorAbility", "Punch"}
    local ok, path = pcall(function()
        return Services.ReplicatedStorage:FindFirstChild("Modules") and Services.ReplicatedStorage.Modules:FindFirstChild("Network") and Services.ReplicatedStorage.Modules.Network:FindFirstChild("RemoteEvent")
    end)
    if ok and path and path.FireServer then
        pcall(function() path:FireServer(unpack(args)) end)
        return
    end
    local alt = Services.ReplicatedStorage:FindFirstChild("RemoteEvent") or Services.ReplicatedStorage:FindFirstChild("Remote") or Services.ReplicatedStorage:FindFirstChild("RemoteFunction")
    if alt and alt.FireServer then
        pcall(function() alt:FireServer(unpack(args)) end)
    end
end

local function fireGuiCharge()
    if cachedChargeBtn and tryActivateButton(cachedChargeBtn) then return end
end

local function fireGuiClone()
    if cachedCloneBtn and tryActivateButton(cachedCloneBtn) then return end
end

-- Enhanced killer state tracking for prediction
Services.RunService.RenderStepped:Connect(function(dt)
    if dt <= 0 then return end
    local killersFolder = Services.Workspace:FindFirstChild("Players") and Services.Workspace.Players:FindFirstChild("Killers")
    if not killersFolder then return end
    for _, killer in ipairs(killersFolder:GetChildren()) do
        if killer and killer.Parent then
            local hrp = killer:FindFirstChild("HumanoidRootPart")
            if hrp then
                local st = killerState[killer] or { prevPos = hrp.Position, prevLook = hrp.CFrame.LookVector, vel = Vector3.new(), angVel = 0 }
                local newVel = (hrp.Position - st.prevPos) / math.max(dt, 1e-6)
                st.vel = st.vel and st.vel:Lerp(newVel, SMOOTHING_LERP) or newVel
                local prevLook = st.prevLook or hrp.CFrame.LookVector
                local look = hrp.CFrame.LookVector
                local dot = math.clamp(prevLook:Dot(look), -1, 1)
                local angle = math.acos(dot)
                local crossY = prevLook:Cross(look).Y
                local angSign = (crossY >= 0) and 1 or -1
                local newAngVel = (angle / math.max(dt, 1e-6)) * angSign
                st.angVel = (st.angVel * (1 - SMOOTHING_LERP)) + (newAngVel * SMOOTHING_LERP)
                st.prevPos = hrp.Position
                st.prevLook = look
                killerState[killer] = st
            end
        end
    end
end)

-- Enhanced audio-based auto block with prediction
local function attemptBlockForSound(sound, idParam)
    if not state.autoBlockAudioOn then return end
    if not sound or not sound:IsA("Sound") then return end
    if not sound.IsPlaying then return end
    local now = tick()
    local hooks = soundHooks
    local hook = hooks[sound]
    local id = idParam or (hook and hook.id) or extractNumericSoundId(sound)
    if not id or not autoBlockTriggerSounds[id] then return end
    if soundBlockedUntil[sound] and now < soundBlockedUntil[sound] then return end
    if now - lastLocalBlockTime < AUDIO_LOCAL_COOLDOWN then return end
    
    if not cachedBlockBtn or not cachedCooldown or not cachedCharges then
        refreshUIRefs()
    end
    
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local char = hook and hook.char
    local hrp = hook and hook.hrp
    if not hrp then
        local soundPos, soundPart = getSoundWorldPosition(sound)
        if not soundPart then return end
        char = getCharacterFromDescendant(soundPart)
        hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hook then
            hook.char = char
            hook.hrp = hrp
        else
            soundHooks[sound] = { id = id, char = char, hrp = hrp }
            hook = soundHooks[sound]
        end
    end
    if not hrp then return end
    
    -- Enhanced prediction calculation
    local v = hrp.Velocity or Vector3.new()
    local predictedX = hrp.Position.X + v.X * AUDIO_PREDICT_DT
    local predictedY = hrp.Position.Y + v.Y * AUDIO_PREDICT_DT
    local predictedZ = hrp.Position.Z + v.Z * AUDIO_PREDICT_DT
    
    local dx = predictedX - myRoot.Position.X
    local dy = predictedY - myRoot.Position.Y
    local dz = predictedZ - myRoot.Position.Z
    local distSqPred = dx*dx + dy*dy + dz*dz
    
    local detectionRangeSq = state.detectionRange * state.detectionRange
    if detectionRangeSq and distSqPred > detectionRangeSq then
        local dx2 = hrp.Position.X - myRoot.Position.X
        local dy2 = hrp.Position.Y - myRoot.Position.Y
        local dz2 = hrp.Position.Z - myRoot.Position.Z
        local distSqNow = dx2*dx2 + dy2*dy2 + dz2*dz2
        local grace = (state.detectionRange + 3) * (state.detectionRange + 3)
        if distSqNow > grace then
            return
        end
    end
    
    local plr = Services.Players:GetPlayerFromCharacter(char)
    if not plr or plr == player then return end
    
    if state.facingCheckEnabled and not isFacing(myRoot, hrp) then
        return
    end
    
    -- Execute block based on type
    if autoblocktype == "Block" then
        fireGuiBlock()
    elseif autoblocktype == "Charge" then
        fireGuiCharge()
    elseif autoblocktype == "7n7 Clone" then
        fireGuiClone()
    end
    
    -- Optional double-tech/punch
    if doubleblocktech and cachedCharges and cachedCharges.Text == "1" then
        fireGuiPunch()
    end
    
    lastLocalBlockTime = now
    soundBlockedUntil[sound] = now + AUDIO_SOUND_THROTTLE
end

-- Enhanced Better Detection with anti-flick parts
local function attemptBDParts(sound, idParam)
    if not state.autoBlockAudioOn then return end
    if not sound or not sound:IsA("Sound") then return end
    if not sound.IsPlaying then return end
    local id = idParam or extractNumericSoundId(sound)
    if not id or not autoBlockTriggerSounds[id] then return end
    local t = tick()
    if soundBlockedUntil[sound] and t < soundBlockedUntil[sound] then return end
    
    local myChar = player.Character
    local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    
    local soundPos, soundPart = getSoundWorldPosition(sound)
    if not soundPos or not soundPart then return end
    
    local char = getCharacterFromDescendant(soundPart)
    local plr = char and Services.Players:GetPlayerFromCharacter(char)
    if not plr or plr == player then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    if antiFlickOn then
        local basePartSize = Vector3.new(8, 11.5, 8.5)
        local partSize = basePartSize * blockPartsSizeMultiplier
        local count = math.max(1, antiFlickParts)
        local base = antiFlickBaseOffset
        local step = antiFlickOffsetStep
        local lifeTime = 0.2
        
        task.spawn(function()
            local blocked = false
            task.wait(antiFlickDelay)
            
            for i = 1, count do
                if not hrp or not myRoot then break end
                
                local dist = base + (i - 1) * step
                local st = killerState[char] or { vel = hrp.Velocity or Vector3.new(), angVel = 0 }
                local vel = st.vel or hrp.Velocity or Vector3.new()
                
                local forwardSpeed = vel:Dot(hrp.CFrame.LookVector)
                local lateralSpeed = vel:Dot(hrp.CFrame.RightVector)
                
                local pStrength = predictionStrength or 1
                local pTurn = predictionTurnStrength or 1
                
                local forwardPredictRaw = forwardSpeed * PRED_SECONDS_FORWARD * pStrength
                local lateralPredictRaw = lateralSpeed * PRED_SECONDS_LATERAL * pStrength
                local turnLateralRaw = st.angVel * ANG_TURN_MULTIPLIER * pTurn
                
                local forwardClamp = PRED_MAX_FORWARD * pStrength
                local lateralClamp = PRED_MAX_LATERAL * pStrength
                local turnClamp = PRED_MAX_LATERAL * pTurn
                
                local forwardPredict = math.clamp(forwardPredictRaw, -forwardClamp, forwardClamp)
                local lateralPredict = math.clamp(lateralPredictRaw, -lateralClamp, lateralClamp)
                local turnLateral = math.clamp(turnLateralRaw, -turnClamp, turnClamp)
                
                local forwardDist = dist + forwardPredict
                local spawnPos = hrp.Position
                                + hrp.CFrame.LookVector * forwardDist
                                + hrp.CFrame.RightVector * (lateralPredict + turnLateral)
                
                local part = Instance.new("Part")
                part.Name = "AntiFlickZone"
                part.Size = partSize
                part.Transparency = 0.45
                part.Anchored = true
                part.CanCollide = false
                part.CFrame = CFrame.new(spawnPos, hrp.Position)
                part.BrickColor = BrickColor.new("Bright blue")
                part.Parent = Services.Workspace
                Services.Debris:AddItem(part, lifeTime)
                
                if isPointInsidePart(part, myRoot.Position) then
                    blocked = true
                else
                    local touching = {}
                    pcall(function() touching = myRoot:GetTouchingParts() end)
                    for _, p in ipairs(touching) do
                        if p == part then
                            blocked = true
                            break
                        end
                    end
                end
                
                if blocked then
                    if not (state.facingCheckEnabled and not isFacing(myRoot, hrp)) then
                        if autoblocktype == "Block" then
                            fireGuiBlock()
                        elseif autoblocktype == "Charge" then
                            fireGuiCharge()
                        elseif autoblocktype == "7n7 Clone" then
                            fireGuiClone()
                        end
                        
                        if doubleblocktech and cachedCharges and cachedCharges.Text == "1" then
                            fireGuiPunch()
                        end
                        soundBlockedUntil[sound] = t + 1.2
                    end
                    break
                end
                
                if stagger > 0 then
                    task.wait(stagger)
                else
                    task.wait(0)
                end
            end
        end)
        return
    end
end

-- Enhanced sound hooking system
local function hookSound(sound)
    if not sound or not sound:IsA("Sound") then return end
    if soundHooks[sound] then return end
    
    local preId = extractNumericSoundId(sound)
    soundHooks[sound] = { id = preId, hrp = nil, char = nil }
    
    local playedConn = sound.Played:Connect(function()
        if not state.autoBlockAudioOn then return end
        if not antiFlickOn then
            attemptBlockForSound(sound, preId)
        else
            attemptBDParts(sound, preId)
        end
    end)
    
    local propConn = sound:GetPropertyChangedSignal("IsPlaying"):Connect(function()
        if sound.IsPlaying and state.autoBlockAudioOn then
            if not antiFlickOn then
                attemptBlockForSound(sound, preId)
            else
                attemptBDParts(sound, preId)
            end
        end
    end)
    
    local destroyConn
    destroyConn = sound.Destroying:Connect(function()
        if playedConn and playedConn.Connected then playedConn:Disconnect() end
        if propConn and propConn.Connected then propConn:Disconnect() end
        if destroyConn and destroyConn.Connected then destroyConn:Disconnect() end
        soundHooks[sound] = nil
        soundBlockedUntil[sound] = nil
    end)
    
    soundHooks[sound].playedConn = playedConn
    soundHooks[sound].propConn = propConn
    soundHooks[sound].destroyConn = destroyConn
    
    if sound.IsPlaying then
        if not antiFlickOn then
            attemptBlockForSound(sound, preId)
        else
            attemptBDParts(sound, preId)
        end
    end
end

-- Hook sounds in KillersFolder for better performance
local KillersFolder = Services.Workspace:FindFirstChild("Players") and Services.Workspace.Players:FindFirstChild("Killers")
if KillersFolder then
    for _, desc in ipairs(KillersFolder:GetDescendants()) do
        if desc:IsA("Sound") then
            pcall(hookSound, desc)
        end
    end
    
    KillersFolder.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") then
            pcall(hookSound, desc)
        end
    end)
else
    for _, desc in ipairs(game:GetDescendants()) do
        if desc:IsA("Sound") then
            pcall(hookSound, desc)
        end
    end
    
    game.DescendantAdded:Connect(function(desc)
        if desc:IsA("Sound") then
            pcall(hookSound, desc)
        end
    end)
end

-- ===== END UPDATED AUTO-BLOCK SECTION =====

-- Medkit Config Variables
local medkitConfig = nil
local originalHealTime = nil
local originalHealSpeedMultiplier = nil
-- NoClip variables
local Clip = true
local NoclipConnection
local savedCollisions = {}
-- Anti-AFK variables
local AFKConnection
-- Keybind tracking
local lastKeyPressTime = {}
local KEY_DEBOUNCE_TIME = 0.05
-- List of pizza delivery names for ESP
local pizzaDeliveryNames = {
    "PizzaDeliveryRig", "Mafiaso1", "Mafiaso2", "Builderman", "Elliot",
    "ShedletskyCORRUPT", "ChancecORRUPT", "ChanceCORRUPT",
    "Mafia1", "Mafia2", "Mafia3", "Mafia4", "Mafia5", "Mafia6", "Mafia7", "Mafia8", "Mafia9", "GreenGuy", "RedGuy", "BlueGuy", "PurpleGuy", "PinkGuy",
    "YellowGuy", "OrangeGuy", "GreyGuy"
}
-- ESP Models Table (for players with multiple labels)
local espModels = {}
-- Non-player ESP models (pizza, items, dummies, zombies, generators)
local nonPlayerEspModels = {}
-- Tracers Table: key = instance (model or unique object), value = {line = Drawing, part = BasePart, connections = {}}
local tracers = {}
-- Round Time Window Logic
local roundTimeGui
local roundTimeFrame
local roundTimeLabel
local function createRoundTimeWindow()
    if roundTimeGui then return end
    roundTimeGui = Instance.new("ScreenGui")
    roundTimeGui.Name = "RoundTimeGui"
    roundTimeGui.Parent = Services.CoreGui
    roundTimeGui.ResetOnSpawn = false
    roundTimeFrame = Instance.new("Frame")
    roundTimeFrame.Size = UDim2.new(0, 150, 0, 50)
    local viewportSize = camera.ViewportSize
    local initialX = viewportSize.X * 0.5 - 75
    local initialY = viewportSize.Y * 0.1
    roundTimeFrame.Position = UDim2.new(0, initialX, 0, initialY)
    roundTimeFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    roundTimeFrame.BackgroundTransparency = 0.3
    roundTimeFrame.BorderSizePixel = 0
    roundTimeFrame.Active = true
    roundTimeFrame.Parent = roundTimeGui
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = roundTimeFrame
    roundTimeLabel = Instance.new("TextLabel")
    roundTimeLabel.Size = UDim2.new(1, 0, 1, 0)
    roundTimeLabel.BackgroundTransparency = 1
    roundTimeLabel.Text = "Round Time: 00:00"
    roundTimeLabel.Font = Enum.Font.GothamBlack
    roundTimeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    roundTimeLabel.TextSize = 18
    roundTimeLabel.Parent = roundTimeFrame
    -- Dragging logic
    local TweenService = Services.TweenService
    local UserInputService = Services.UserInputService
    local dragging = false
    local dragStartPos
    local dragStartMousePos
    local lastTween
    local tweenInfo = TweenInfo.new(
        0.15, -- Время анимации
        Enum.EasingStyle.Quad, -- Стиль
        Enum.EasingDirection.Out,
        0, false, 0
    )
    roundTimeFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStartPos = roundTimeFrame.Position
            dragStartMousePos = input.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStartMousePos
            local newPos = UDim2.new(
                0, dragStartPos.X.Offset + delta.X,
                0, dragStartPos.Y.Offset + delta.Y
            )
            if lastTween then
                lastTween:Cancel()
            end
            lastTween = TweenService:Create(roundTimeFrame, tweenInfo, {Position = newPos})
            lastTween:Play()
        end
    end)
    -- Update time loop
    task.spawn(function()
        while state.showRoundTime do
            local roundTimer = player.PlayerGui:FindFirstChild("RoundTimer")
            local main = roundTimer and roundTimer:FindFirstChild("Main")
            local timeLabel = main and main:FindFirstChild("Time")
            if timeLabel and timeLabel:IsA("TextLabel") then
                roundTimeLabel.Text = "Round Time: " .. timeLabel.Text
            else
                roundTimeLabel.Text = "Round Time: N/A"
            end
            task.wait(0.1)
        end
    end)
end
local function destroyRoundTimeWindow()
    if roundTimeGui then
        roundTimeGui:Destroy()
        roundTimeGui = nil
    end
end
-- Helper Functions
local function isGameInProgress()
    local map = Services.Workspace:FindFirstChild("Map")
    if not map or not map:FindFirstChild("Ingame") then
        return false
    end
    local ingameFolder = map:FindFirstChild("Ingame")
    if not ingameFolder or not ingameFolder:FindFirstChild("Map") then
        return false
    end
    local playersFolder = Services.Workspace:FindFirstChild("Players")
    if playersFolder then
        local survivorsFolder = playersFolder:FindFirstChild("Survivors")
        if survivorsFolder and #survivorsFolder:GetChildren() > 0 then
            return true
        end
    end
    return false
end
local function getUnfinishedGenerators()
    local map = Services.Workspace:FindFirstChild("Map")
    if not map or not map:FindFirstChild("Ingame") or not map.Ingame:FindFirstChild("Map") then
        return {}
    end
    local generators = {}
    for _, model in ipairs(map.Ingame.Map:GetChildren()) do
        if model:IsA("Model") and model.Name:lower():find("generator") and model.Name ~= "FakeGenerator" and model:FindFirstChild("Progress") and model.Progress.Value < 100 then
            table.insert(generators, model)
        end
    end
    return generators
end
local function teleportToUnfinishedGenerator()
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end
    local unfinishedGenerators = getUnfinishedGenerators()
    if #unfinishedGenerators == 0 then
        return
    end
    local closestGenerator = nil
    local minDistance = math.huge
    for _, generator in ipairs(unfinishedGenerators) do
        local positions = generator:FindFirstChild("Positions")
        local center = positions and positions:FindFirstChild("Center")
        if center and center:IsA("BasePart") then
            local distance = (character.HumanoidRootPart.Position - center.Position).Magnitude
            if distance < minDistance then
                minDistance = distance
                closestGenerator = center
            end
        end
    end
    if closestGenerator then
        local offset = Vector3.new(0, 5, 0)
        character.HumanoidRootPart.CFrame = CFrame.new(closestGenerator.Position + offset)
    end
end
local isRunning = false
local mapWatcherConnection
-- Improved auto-generator loop:
local function runAutoGenerator()
    if isRunning then return end
    isRunning = true
    task.spawn(function()
        local ok, err = pcall(function()
            while state.autoGenerator do
                if isGameInProgress() then
                    pcall(function()
                        local map = Services.Workspace:FindFirstChild("Map")
                        if not map then return end
                        local ingame = map:FindFirstChild("Ingame")
                        if not ingame then return end
                        local mapFolder = ingame:FindFirstChild("Map")
                        if not mapFolder then return end
                        for _, generator in ipairs(mapFolder:GetChildren()) do
                            if generator:IsA("Model") and generator.Name:lower():find("generator") and generator.Name ~= "FakeGenerator" then
                                local progress = generator:FindFirstChild("Progress")
                                if progress and progress.Value < 100 then
                                    local remittances = generator:FindFirstChild("Remotes")
                                    if remittances then
                                        local re = remittances:FindFirstChild("RE")
                                        local rf = remittances:FindFirstChild("RF")
                                        if re and rf then
                                            pcall(function() re:FireServer() end)
                                            pcall(function() rf:InvokeServer() end)
                                        end
                                    end
                                    task.wait(0.1)
                                end
                            end
                        end
                    end)
                    task.wait(state.generatorWaitTime)
                else
                    task.wait(0.5)
                end
            end
        end)
        if not ok then
            warn("runAutoGenerator error: "..tostring(err))
        end
        isRunning = false
    end)
end

-- [ОСТАЛЬНАЯ ЧАСТЬ СКРИПТА БУДЕТ ПРОДОЛЖЕНА В СЛЕДУЮЩЕЙ ЧАСТИ...]
-- UI Library и остальной код остается без изменений...