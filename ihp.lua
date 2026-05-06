--[[
    ██╗██████╗  ██████╗ ███╗   ██╗██╗  ██╗███████╗ █████╗ ██████╗ 
    ██║██╔══██╗██╔═══██╗████╗  ██║██║  ██║██╔════╝██╔══██╗██╔══██╗
    ██║██████╔╝██║   ██║██╔██╗ ██║███████║█████╗  ███████║██║  ██║
    ██║██╔══██╗██║   ██║██║╚██╗██║██╔══██║██╔══╝  ██╔══██║██║  ██║
    ██║██║  ██║╚██████╔╝██║ ╚████║██║  ██║███████╗██║  ██║██████╔╝
    ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚═════╝ 
    ██████╗  █████╗ ███╗   ██╗███████╗██╗     
    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║     
    ██████╔╝███████║██╔██╗ ██║█████╗  ██║     
    ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║     
    ██║     ██║  ██║██║ ╚████║███████╗███████╗
    ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝
    
    IronHeadPanel v2.0 - Advanced Admin Script
    Öffnen: RECHTE SHIFT-Taste
    Entwickelt für Roblox LocalScript (StarterPlayerScripts)
--]]

-- ╔══════════════════════════════════════╗
-- ║         SERVICES & VARIABLEN         ║
-- ╚══════════════════════════════════════╝

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local Camera = Workspace.CurrentCamera

-- ╔══════════════════════════════════════╗
-- ║            EINSTELLUNGEN             ║
-- ╚══════════════════════════════════════╝

local CONFIG = {
    PanelName    = "IronHeadPanel",
    Version      = "2.0",
    OpenKey      = Enum.KeyCode.RightShift,
    Prefix       = "/",           -- Command-Präfix (z.B. /kill)
    AdminColor   = Color3.fromRGB(220, 50, 50),
    AccentColor  = Color3.fromRGB(255, 80, 80),
    BgDark       = Color3.fromRGB(12, 12, 18),
    BgMid        = Color3.fromRGB(18, 18, 28),
    BgLight      = Color3.fromRGB(25, 25, 40),
    TextColor    = Color3.fromRGB(240, 240, 255),
    SubText      = Color3.fromRGB(140, 140, 170),
    GreenColor   = Color3.fromRGB(50, 220, 100),
    YellowColor  = Color3.fromRGB(255, 200, 50),
    ESPColor     = Color3.fromRGB(255, 60, 60),
    WalkSpeed    = 16,
    JumpPower    = 50,
}

-- ╔══════════════════════════════════════╗
-- ║           STATE VARIABLEN            ║
-- ╚══════════════════════════════════════╝

local State = {
    PanelOpen      = false,
    ESPEnabled     = false,
    NoclipEnabled  = false,
    SpeedHack      = false,
    GodMode        = false,
    FullBright     = false,
    InfJump        = false,
    FlyEnabled     = false,
    AntiAFK        = false,
    SpamEnabled    = false,
    AutoRespawn    = false,
    Frozen         = false,
    Invisible      = false,
    WalkSpeedVal   = 16,
    JumpPowerVal   = 50,
    FovVal         = 70,
    SpamMessage    = "",
    SpamDelay      = 1,
    CommandHistory = {},
    HistoryIndex   = 0,
    ESPHighlights  = {},
    Connections    = {},
    FlyBodyVel    = nil,
    FlyBodyGyro   = nil,
}

-- ╔══════════════════════════════════════╗
-- ║           HILFSFUNKTIONEN            ║
-- ╚══════════════════════════════════════╝

local function GetCharacter()
    return LocalPlayer.Character
end

local function GetHumanoid()
    local char = GetCharacter()
    return char and char:FindFirstChildOfClass("Humanoid")
end

local function GetRootPart()
    local char = GetCharacter()
    return char and char:FindFirstChild("HumanoidRootPart")
end

local function FindPlayer(name)
    name = name:lower()
    if name == "me" then return LocalPlayer end
    if name == "all" then return Players:GetPlayers() end
    for _, p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():sub(1, #name) == name then
            return p
        end
    end
    return nil
end

local function Notify(msg, color)
    color = color or CONFIG.GreenColor
    -- Notification Toast
    local notifGui = Instance.new("ScreenGui")
    notifGui.Name = "IHP_Notif"
    notifGui.ResetOnSpawn = false
    notifGui.Parent = PlayerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 300, 0, 50)
    frame.Position = UDim2.new(0.5, -150, 0, -60)
    frame.BackgroundColor3 = CONFIG.BgMid
    frame.BorderSizePixel = 0
    frame.Parent = notifGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Color = color
    stroke.Thickness = 1.5
    stroke.Parent = frame

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "⚡ " .. msg
    label.TextColor3 = CONFIG.TextColor
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
        Position = UDim2.new(0.5, -150, 0, 20)
    }):Play()

    task.delay(2.5, function()
        TweenService:Create(frame, TweenInfo.new(0.3), {
            Position = UDim2.new(0.5, -150, 0, -60)
        }):Play()
        task.wait(0.35)
        notifGui:Destroy()
    end)
end

-- ╔══════════════════════════════════════╗
-- ║            ESP SYSTEM                ║
-- ╚══════════════════════════════════════╝

local function RemoveESP(player)
    if State.ESPHighlights[player] then
        State.ESPHighlights[player]:Destroy()
        State.ESPHighlights[player] = nil
    end
end

local function AddESP(player)
    if player == LocalPlayer then return end
    RemoveESP(player)

    local function setupHighlight()
        local char = player.Character
        if not char then return end

        local highlight = Instance.new("Highlight")
        highlight.Name = "IHP_ESP"
        highlight.FillColor = Color3.fromRGB(255, 30, 30)
        highlight.FillTransparency = 0.5
        highlight.OutlineColor = CONFIG.ESPColor
        highlight.OutlineTransparency = 0
        highlight.Adornee = char
        highlight.Parent = char

        -- Name-Billboard
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "IHP_ESPLabel"
        billboard.Size = UDim2.new(0, 120, 0, 40)
        billboard.StudsOffset = Vector3.new(0, 3.5, 0)
        billboard.AlwaysOnTop = true
        billboard.Parent = char:FindFirstChild("Head") or char

        local bg = Instance.new("Frame")
        bg.Size = UDim2.new(1, 0, 1, 0)
        bg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        bg.BackgroundTransparency = 0.4
        bg.BorderSizePixel = 0
        bg.Parent = billboard
        Instance.new("UICorner", bg).CornerRadius = UDim.new(0, 4)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name
        nameLabel.TextColor3 = CONFIG.ESPColor
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextSize = 12
        nameLabel.Parent = bg

        local hpLabel = Instance.new("TextLabel")
        hpLabel.Size = UDim2.new(1, 0, 0.4, 0)
        hpLabel.Position = UDim2.new(0, 0, 0.6, 0)
        hpLabel.BackgroundTransparency = 1
        hpLabel.TextColor3 = CONFIG.GreenColor
        hpLabel.Font = Enum.Font.Gotham
        hpLabel.TextSize = 10
        hpLabel.Parent = bg

        -- HP Update
        local hpConn = RunService.Heartbeat:Connect(function()
            local h = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if h then
                hpLabel.Text = "❤ " .. math.floor(h.Health) .. "/" .. math.floor(h.MaxHealth)
                local ratio = h.Health / h.MaxHealth
                hpLabel.TextColor3 = Color3.new(1 - ratio, ratio, 0)
            end
        end)

        State.ESPHighlights[player] = highlight
        table.insert(State.Connections, hpConn)

        player.CharacterRemoving:Connect(function()
            highlight:Destroy()
            billboard:Destroy()
        end)
    end

    setupHighlight()
    player.CharacterAdded:Connect(setupHighlight)
end

local function ToggleESP()
    State.ESPEnabled = not State.ESPEnabled
    if State.ESPEnabled then
        for _, p in ipairs(Players:GetPlayers()) do
            AddESP(p)
        end
        Players.PlayerAdded:Connect(function(p)
            if State.ESPEnabled then AddESP(p) end
        end)
        Notify("ESP aktiviert", CONFIG.ESPColor)
    else
        for _, p in ipairs(Players:GetPlayers()) do
            RemoveESP(p)
        end
        Notify("ESP deaktiviert", CONFIG.SubText)
    end
end

-- ╔══════════════════════════════════════╗
-- ║            FLY SYSTEM                ║
-- ╚══════════════════════════════════════╝

local function ToggleFly()
    State.FlyEnabled = not State.FlyEnabled
    local char = GetCharacter()
    local root = GetRootPart()
    local hum = GetHumanoid()
    if not char or not root or not hum then return end

    if State.FlyEnabled then
        hum.PlatformStand = true

        local bg = Instance.new("BodyGyro")
        bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.D = 50
        bg.Parent = root
        State.FlyBodyGyro = bg

        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.zero
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = root
        State.FlyBodyVel = bv

        local flyConn
        flyConn = RunService.Heartbeat:Connect(function()
            if not State.FlyEnabled then
                flyConn:Disconnect()
                return
            end
            local cam = Camera
            local vel = Vector3.zero
            local speed = UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and 80 or 40

            if UserInputService:IsKeyDown(Enum.KeyCode.W) then vel = vel + cam.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then vel = vel - cam.CFrame.LookVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then vel = vel - cam.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then vel = vel + cam.CFrame.RightVector * speed end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0, speed, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then vel = vel - Vector3.new(0, speed, 0) end

            bv.Velocity = vel
            bg.CFrame = cam.CFrame
        end)
        Notify("Fly aktiviert (W/A/S/D + Space/Ctrl)", CONFIG.YellowColor)
    else
        if State.FlyBodyVel then State.FlyBodyVel:Destroy() end
        if State.FlyBodyGyro then State.FlyBodyGyro:Destroy() end
        hum.PlatformStand = false
        Notify("Fly deaktiviert", CONFIG.SubText)
    end
end

-- ╔══════════════════════════════════════╗
-- ║           NOCLIP SYSTEM              ║
-- ╚══════════════════════════════════════╝

local function ToggleNoclip()
    State.NoclipEnabled = not State.NoclipEnabled
    if State.NoclipEnabled then
        local noclipConn
        noclipConn = RunService.Stepped:Connect(function()
            if not State.NoclipEnabled then noclipConn:Disconnect() return end
            local char = GetCharacter()
            if char then
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") and part.CanCollide then
                        part.CanCollide = false
                    end
                end
            end
        end)
        Notify("Noclip aktiviert", CONFIG.YellowColor)
    else
        local char = GetCharacter()
        if char then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
        Notify("Noclip deaktiviert", CONFIG.SubText)
    end
end

-- ╔══════════════════════════════════════╗
-- ║         GOD MODE SYSTEM              ║
-- ╚══════════════════════════════════════╝

local function ToggleGodMode()
    State.GodMode = not State.GodMode
    local hum = GetHumanoid()
    if not hum then return end

    if State.GodMode then
        local godConn
        godConn = RunService.Heartbeat:Connect(function()
            if not State.GodMode then godConn:Disconnect() return end
            local h = GetHumanoid()
            if h then h.Health = h.MaxHealth end
        end)
        Notify("God Mode aktiviert", CONFIG.GreenColor)
    else
        Notify("God Mode deaktiviert", CONFIG.SubText)
    end
end

-- ╔══════════════════════════════════════╗
-- ║          FULLBRIGHT SYSTEM           ║
-- ╚══════════════════════════════════════╝

local originalAmbient = Lighting.Ambient
local originalBrightness = Lighting.Brightness

local function ToggleFullBright()
    State.FullBright = not State.FullBright
    if State.FullBright then
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 1e6
        Notify("FullBright aktiviert", CONFIG.YellowColor)
    else
        Lighting.Ambient = originalAmbient
        Lighting.Brightness = originalBrightness
        Lighting.GlobalShadows = true
        Notify("FullBright deaktiviert", CONFIG.SubText)
    end
end

-- ╔══════════════════════════════════════╗
-- ║         INFINITE JUMP SYSTEM         ║
-- ╚══════════════════════════════════════╝

local function ToggleInfJump()
    State.InfJump = not State.InfJump
    if State.InfJump then
        local jumpConn
        jumpConn = UserInputService.JumpRequest:Connect(function()
            if not State.InfJump then jumpConn:Disconnect() return end
            local hum = GetHumanoid()
            if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
        end)
        Notify("Infinite Jump aktiviert", CONFIG.GreenColor)
    else
        Notify("Infinite Jump deaktiviert", CONFIG.SubText)
    end
end

-- ╔══════════════════════════════════════╗
-- ║           ANTI-AFK SYSTEM            ║
-- ╚══════════════════════════════════════╝

local function ToggleAntiAFK()
    State.AntiAFK = not State.AntiAFK
    if State.AntiAFK then
        local vConnection
        vConnection = LocalPlayer.Idled:Connect(function()
            if not State.AntiAFK then vConnection:Disconnect() return end
            -- Simulate virtual input to prevent kick
            local vInput = game:GetService("VirtualUser")
            if vInput then
                vInput:CaptureController()
                vInput:ClickButton2(Vector2.new())
            end
        end)
        Notify("Anti-AFK aktiviert", CONFIG.GreenColor)
    else
        Notify("Anti-AFK deaktiviert", CONFIG.SubText)
    end
end

-- ╔══════════════════════════════════════╗
-- ║           COMMAND SYSTEM             ║
-- ╚══════════════════════════════════════╝

local COMMANDS = {
    -- MOVEMENT
    {name = "speed", args = "<value> [player/me/all]", desc = "Setzt WalkSpeed eines Spielers", cat = "Movement"},
    {name = "jump",  args = "<value> [player/me/all]", desc = "Setzt JumpPower eines Spielers",  cat = "Movement"},
    {name = "fly",   args = "",             desc = "Fliegen an/aus",                 cat = "Movement"},
    {name = "noclip",args = "",             desc = "Noclip an/aus",                  cat = "Movement"},
    {name = "tp",    args = "<player>",     desc = "Teleportiere zu Spieler",        cat = "Movement"},
    {name = "tpme",  args = "<player>",     desc = "Teleportiere Spieler zu dir",    cat = "Movement"},
    {name = "bring", args = "<player>",     desc = "Bringe Spieler zu dir",          cat = "Movement"},
    {name = "goto",  args = "<x> <y> <z>", desc = "Teleportiere zu Koordinaten",    cat = "Movement"},
    {name = "respawn",args="",             desc = "Respawne dich",                  cat = "Movement"},
    -- PLAYER
    {name = "explode",args = "<player/me/all>",desc = "Spieler explodieren lassen 💥", cat = "Player"},
    {name = "kill",       args = "<player/me/all>",            desc = "Töte einen/alle Spieler",        cat = "Player"},
    {name = "repeatkill", args = "<player/me/all> <true/false>",desc = "Loop-Kill an/aus",               cat = "Player"},
    {name = "god",   args = "",             desc = "God Mode an/aus",                cat = "Player"},
    {name = "heal",  args = "<player/me/all>",desc = "Heile einen/alle Spieler",     cat = "Player"},
    {name = "freeze",args = "<player/me/all>",desc = "Einfrieren an/aus",            cat = "Player"},
    {name = "sit",   args = "",             desc = "Lass dich hinsetzen",            cat = "Player"},
    {name = "invisible",args = "<player/me/all>",desc = "Unsichtbarkeit an/aus",     cat = "Player"},
    {name = "char",  args = "<player>",     desc = "Kopiere Charakter",              cat = "Player"},
    {name = "size",  args = "<value> <player/me/all>",desc = "Charaktergröße ändern",cat = "Player"},
    {name = "team",  args = "<team>",       desc = "Wechsle Team",                   cat = "Player"},
    -- VISUALS
    {name = "esp",      args = "",          desc = "ESP (Spieler durch Wände)",      cat = "Visuals"},
    {name = "fullbright",args = "",         desc = "Fullbright an/aus",              cat = "Visuals"},
    {name = "fov",      args = "<value>",   desc = "Field of View ändern",          cat = "Visuals"},
    {name = "blur",     args = "<value>",   desc = "Blur-Effekt (0-56)",             cat = "Visuals"},
    {name = "rainbow",  args = "",          desc = "Regenbogen-Farben für Charakter",cat = "Visuals"},
    {name = "trails",   args = "",          desc = "Trail-Effekt an/aus",            cat = "Visuals"},
    -- TOOLS
    {name = "infjump",  args = "",          desc = "Infinite Jump an/aus",           cat = "Tools"},
    {name = "antiafk",  args = "",          desc = "Anti-AFK an/aus",                cat = "Tools"},
    {name = "spam",     args = "<msg>",     desc = "Chat-Spam an/aus",               cat = "Tools"},
    {name = "clear",    args = "",          desc = "Chat leeren",                    cat = "Tools"},
    {name = "time",     args = "<0-24>",    desc = "Tageszeit setzen",               cat = "Tools"},
    {name = "gravity",  args = "<value>",   desc = "Schwerkraft setzen",             cat = "Tools"},
    {name = "fog",      args = "<value>",   desc = "Nebel-Distanz setzen",          cat = "Tools"},
    {name = "ambient",  args = "<r> <g> <b>",desc="Umgebungslicht setzen",          cat = "Tools"},
    -- INFO
    {name = "players",  args = "",          desc = "Alle Spieler auflisten",         cat = "Info"},
    {name = "pos",      args = "",          desc = "Aktuelle Position anzeigen",     cat = "Info"},
    {name = "ping",     args = "",          desc = "Ping anzeigen",                  cat = "Info"},
    {name = "fps",      args = "",          desc = "FPS anzeigen",                   cat = "Info"},
    {name = "gameid",   args = "",          desc = "Game ID anzeigen",               cat = "Info"},
    {name = "serverinfo",args="",          desc = "Server-Info anzeigen",           cat = "Info"},
    -- MISC
    {name = "help",     args = "[cmd]",     desc = "Hilfe anzeigen",                 cat = "Misc"},
    {name = "close",    args = "",          desc = "Panel schließen",               cat = "Misc"},
    {name = "version",  args = "",          desc = "Version anzeigen",              cat = "Misc"},
    {name = "credits",  args = "",          desc = "Credits anzeigen",              cat = "Misc"},
}

local function ExecuteCommand(input)
    input = input:gsub("^%s+", ""):gsub("%s+$", "")
    if input == "" then return end

    -- Strip prefix
    if input:sub(1,1) == CONFIG.Prefix then
        input = input:sub(2)
    end

    local parts = {}
    for word in input:gmatch("%S+") do table.insert(parts, word) end
    local cmd = parts[1] and parts[1]:lower() or ""
    local args = {table.unpack(parts, 2)}

    -- Command History
    table.insert(State.CommandHistory, 1, input)
    if #State.CommandHistory > 50 then table.remove(State.CommandHistory) end
    State.HistoryIndex = 0

    -- ══ COMMANDS ══

    if cmd == "speed" then
        -- /speed <value> [player/me/all]
        local val = tonumber(args[1]) or 16
        val = math.clamp(val, 0, 500)
        local targetArg = args[2] or "me"
        local targets = targetArg == "all" and Players:GetPlayers() or {FindPlayer(targetArg)}
        for _, target in ipairs(targets) do
            if target and target.Character then
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.WalkSpeed = val end
            end
        end
        if targetArg == "me" then State.WalkSpeedVal = val end
        Notify("WalkSpeed " .. val .. " → " .. (targetArg == "all" and "Alle" or (targets[1] and targets[1].Name or "?")))

    elseif cmd == "jump" then
        -- /jump <value> [player/me/all]
        local val = tonumber(args[1]) or 50
        val = math.clamp(val, 0, 500)
        local targetArg = args[2] or "me"
        local targets = targetArg == "all" and Players:GetPlayers() or {FindPlayer(targetArg)}
        for _, target in ipairs(targets) do
            if target and target.Character then
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.JumpPower = val end
            end
        end
        if targetArg == "me" then State.JumpPowerVal = val end
        Notify("JumpPower " .. val .. " → " .. (targetArg == "all" and "Alle" or (targets[1] and targets[1].Name or "?")))

    elseif cmd == "fly" then
        ToggleFly()

    elseif cmd == "noclip" then
        ToggleNoclip()

    elseif cmd == "tp" then
        local target = FindPlayer(args[1] or "")
        if target and not target.Character then Notify("Spieler hat keinen Charakter", CONFIG.AdminColor) return end
        if target and target.Character then
            local root = GetRootPart()
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if root and tRoot then
                root.CFrame = tRoot.CFrame + Vector3.new(2, 0, 0)
                Notify("Teleportiert zu " .. target.Name)
            end
        else
            Notify("Spieler nicht gefunden: " .. (args[1] or ""), CONFIG.AdminColor)
        end

    elseif cmd == "tpme" or cmd == "bring" then
        local target = FindPlayer(args[1] or "")
        if target and target.Character then
            local root = GetRootPart()
            local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
            if root and tRoot then
                tRoot.CFrame = root.CFrame + Vector3.new(2, 0, 0)
                Notify(target.Name .. " zu dir teleportiert")
            end
        else
            Notify("Spieler nicht gefunden", CONFIG.AdminColor)
        end

    elseif cmd == "goto" then
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if x and y and z then
            local root = GetRootPart()
            if root then root.CFrame = CFrame.new(x, y, z) end
            Notify(("Teleportiert zu (%.1f, %.1f, %.1f)"):format(x, y, z))
        else
            Notify("Benutze: goto <x> <y> <z>", CONFIG.AdminColor)
        end

    elseif cmd == "respawn" then
        LocalPlayer:LoadCharacter()
        Notify("Respawned")

    elseif cmd == "explode" then
        local targets = {}
        local targetArg = args[1] or "me"
        if targetArg == "all" then
            for _, p in ipairs(Players:GetPlayers()) do table.insert(targets, p) end
        else
            local t = FindPlayer(targetArg)
            if t then table.insert(targets, t) end
        end

        if #targets == 0 then
            Notify("Spieler nicht gefunden: " .. targetArg, CONFIG.AdminColor)
        end

        for _, target in ipairs(targets) do
            local tChar = target.Character
            local tRoot = tChar and tChar:FindFirstChild("HumanoidRootPart")
            if tRoot then
                local pos = tRoot.Position

                -- Roblox Explosion Instance
                local explosion = Instance.new("Explosion")
                explosion.Position = pos
                explosion.BlastRadius = 12
                explosion.BlastPressure = 400000
                explosion.ExplosionType = Enum.ExplosionType.NoCraters
                explosion.DestroyJointRadiusPercent = 0
                explosion.Parent = Workspace

                -- Feuer + Rauch am Spieler
                local part = Instance.new("Part")
                part.Size = Vector3.new(1,1,1)
                part.Position = pos
                part.Anchored = true
                part.CanCollide = false
                part.Transparency = 1
                part.Parent = Workspace

                local fire = Instance.new("Fire")
                fire.Size = 18
                fire.Heat = 30
                fire.Color = Color3.fromRGB(255, 100, 0)
                fire.SecondaryColor = Color3.fromRGB(255, 50, 0)
                fire.Parent = part

                local smoke = Instance.new("Smoke")
                smoke.RiseVelocity = 10
                smoke.Size = 6
                smoke.Opacity = 0.9
                smoke.Parent = part

                -- Kamera Shake nur wenn eigener Char
                if target == LocalPlayer then
                    local shakeTime = 0
                    local shakeConn
                    shakeConn = RunService.RenderStepped:Connect(function(dt)
                        shakeTime = shakeTime + dt
                        if shakeTime > 0.7 then shakeConn:Disconnect() return end
                        local intensity = (0.7 - shakeTime) * 4
                        Camera.CFrame = Camera.CFrame * CFrame.Angles(
                            math.rad((math.random()-0.5) * intensity * 2),
                            math.rad((math.random()-0.5) * intensity * 2),
                            0
                        )
                    end)
                end

                task.delay(4, function()
                    if part and part.Parent then part:Destroy() end
                end)

                Notify("💥 " .. target.Name .. " KABOOM!", Color3.fromRGB(255, 120, 0))
            else
                Notify(target.Name .. " hat keinen Charakter", CONFIG.AdminColor)
            end
        end

    elseif cmd == "kill" then
        local targetArg = args[1] or "me"
        local targets = targetArg == "all" and Players:GetPlayers() or {FindPlayer(targetArg)}
        for _, target in ipairs(targets) do
            if target then
                local hum = target.Character and target.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = 0 end
            end
        end
        Notify("Getötet: " .. (targetArg == "all" and "Alle" or (targets[1] and targets[1].Name or "?")), CONFIG.AdminColor)

    elseif cmd == "repeatkill" or cmd == "loopkill" then
        -- /repeatkill <player/me/all> <true/false>
        local targetArg = args[1] or "me"
        local toggle = (args[2] or "true"):lower()
        local enable = toggle ~= "false" and toggle ~= "off" and toggle ~= "0"

        if not State.RepeatKillConnections then
            State.RepeatKillConnections = {}
        end

        -- Stoppe bestehende Loops für diesen Spieler
        if State.RepeatKillConnections[targetArg] then
            State.RepeatKillConnections[targetArg] = false
            if not enable then
                Notify("RepeatKill gestoppt: " .. targetArg, CONFIG.SubText)
                return
            end
        end

        if enable then
            State.RepeatKillConnections[targetArg] = true
            Notify("🔁 RepeatKill AN: " .. targetArg, CONFIG.AdminColor)

            task.spawn(function()
                while State.RepeatKillConnections and State.RepeatKillConnections[targetArg] do
                    local targets = targetArg == "all" and Players:GetPlayers() or {FindPlayer(targetArg)}
                    for _, target in ipairs(targets) do
                        if target and target.Character then
                            local hum = target.Character:FindFirstChildOfClass("Humanoid")
                            if hum and hum.Health > 0 then
                                hum.Health = 0
                            end
                        end
                    end
                    task.wait(0.1)
                end
            end)
        else
            Notify("RepeatKill gestoppt: " .. targetArg, CONFIG.SubText)
        end

    elseif cmd == "god" then
        ToggleGodMode()

    elseif cmd == "heal" then
        local targetArg = args[1] or "me"
        local targets = targetArg == "all" and Players:GetPlayers() or {FindPlayer(targetArg)}
        for _, target in ipairs(targets) do
            if target and target.Character then
                local hum = target.Character:FindFirstChildOfClass("Humanoid")
                if hum then hum.Health = hum.MaxHealth end
            end
        end
        Notify("Geheilt: " .. (targetArg == "all" and "Alle" or (targets[1] and targets[1].Name or "?")))

    elseif cmd == "freeze" then
        local targetArg = args[1] or "me"
        local targets = targetArg == "all" and Players:GetPlayers() or {FindPlayer(targetArg)}
        State.Frozen = not State.Frozen
        for _, target in ipairs(targets) do
            if target and target.Character then
                local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                if tRoot then tRoot.Anchored = State.Frozen end
            end
        end
        Notify(State.Frozen and "Eingefroren: " .. (targetArg == "all" and "Alle" or (targets[1] and targets[1].Name or "?"))
                             or "Entfroren: "   .. (targetArg == "all" and "Alle" or (targets[1] and targets[1].Name or "?")))

    elseif cmd == "sit" then
        local hum = GetHumanoid()
        if hum then hum.Sit = true end
        Notify("Hingesetzt")

    elseif cmd == "invisible" then
        local targetArg = args[1] or "me"
        local targets = targetArg == "all" and Players:GetPlayers() or {FindPlayer(targetArg)}
        State.Invisible = not State.Invisible
        for _, target in ipairs(targets) do
            if target and target.Character then
                for _, part in ipairs(target.Character:GetDescendants()) do
                    if part:IsA("BasePart") or part:IsA("Decal") then
                        part.Transparency = State.Invisible and 1 or 0
                    end
                end
            end
        end
        Notify((State.Invisible and "Unsichtbar" or "Sichtbar") .. ": " .. (targetArg == "all" and "Alle" or (targets[1] and targets[1].Name or "?")))

    elseif cmd == "size" then
        local val = tonumber(args[1]) or 1
        local targetArg = args[2] or "me"
        val = math.clamp(val, 0.1, 10)
        local targets = targetArg == "all" and Players:GetPlayers() or {FindPlayer(targetArg)}
        for _, target in ipairs(targets) do
            if target and target.Character then
                for _, part in ipairs(target.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Size = part.Size * val
                    end
                end
            end
        end
        Notify("Größe: " .. val .. "x")

    elseif cmd == "esp" then
        ToggleESP()

    elseif cmd == "fullbright" then
        ToggleFullBright()

    elseif cmd == "fov" then
        local val = tonumber(args[1]) or 70
        val = math.clamp(val, 1, 120)
        Camera.FieldOfView = val
        State.FovVal = val
        Notify("FOV: " .. val)

    elseif cmd == "blur" then
        local val = tonumber(args[1]) or 0
        local blur = Lighting:FindFirstChild("IHP_Blur") or Instance.new("BlurEffect", Lighting)
        blur.Name = "IHP_Blur"
        blur.Size = math.clamp(val, 0, 56)
        Notify("Blur: " .. val)

    elseif cmd == "rainbow" then
        local char = GetCharacter()
        if char then
            local conn
            conn = RunService.Heartbeat:Connect(function()
                local t = tick()
                local color = Color3.fromHSV((t % 5) / 5, 1, 1)
                for _, part in ipairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.Color = color end
                end
            end)
            table.insert(State.Connections, conn)
            Notify("Rainbow aktiviert!")
        end

    elseif cmd == "trails" then
        local char = GetCharacter()
        local root = GetRootPart()
        if char and root then
            local a0 = Instance.new("Attachment", root)
            a0.Position = Vector3.new(0, 0.5, 0)
            local a1 = Instance.new("Attachment", root)
            a1.Position = Vector3.new(0, -0.5, 0)
            local trail = Instance.new("Trail")
            trail.Attachment0 = a0
            trail.Attachment1 = a1
            trail.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0,255,0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(0,0,255)),
            })
            trail.Lifetime = 1
            trail.MinLength = 0
            trail.Parent = root
            Notify("Trail aktiviert!")
        end

    elseif cmd == "infjump" then
        ToggleInfJump()

    elseif cmd == "antiafk" then
        ToggleAntiAFK()

    elseif cmd == "spam" then
        if #args > 0 then
            State.SpamMessage = table.concat(args, " ")
            State.SpamEnabled = not State.SpamEnabled
            if State.SpamEnabled then
                task.spawn(function()
                    while State.SpamEnabled do
                        game:GetService("ReplicatedStorage"):FindFirstChild("DefaultChatSystemChatEvents")
                            and game.ReplicatedStorage.DefaultChatSystemChatEvents.SayMessageRequest
                            :FireServer(State.SpamMessage, "All")
                        task.wait(State.SpamDelay)
                    end
                end)
                Notify("Spam gestartet: " .. State.SpamMessage, CONFIG.YellowColor)
            else
                Notify("Spam gestoppt", CONFIG.SubText)
            end
        end

    elseif cmd == "time" then
        local val = tonumber(args[1]) or 12
        Lighting.TimeOfDay = ("%02d:00:00"):format(math.clamp(val, 0, 24))
        Notify("Zeit: " .. val .. ":00")

    elseif cmd == "gravity" then
        local val = tonumber(args[1]) or 196.2
        Workspace.Gravity = val
        Notify("Schwerkraft: " .. val)

    elseif cmd == "fog" then
        local val = tonumber(args[1]) or 1e6
        Lighting.FogEnd = val
        Notify("Nebel-Ende: " .. val)

    elseif cmd == "ambient" then
        local r, g, b = tonumber(args[1]) or 128, tonumber(args[2]) or 128, tonumber(args[3]) or 128
        Lighting.Ambient = Color3.fromRGB(r, g, b)
        Notify(("Ambient: %d, %d, %d"):format(r, g, b))

    elseif cmd == "players" then
        local list = ""
        for i, p in ipairs(Players:GetPlayers()) do
            list = list .. i .. ". " .. p.Name .. "\n"
        end
        Notify("Spieler online: " .. #Players:GetPlayers())
        print("[IronHeadPanel] Spieler:\n" .. list)

    elseif cmd == "pos" then
        local root = GetRootPart()
        if root then
            local p = root.Position
            local msg = ("Pos: %.1f, %.1f, %.1f"):format(p.X, p.Y, p.Z)
            Notify(msg)
        end

    elseif cmd == "ping" then
        Notify("Ping: " .. math.floor(LocalPlayer:GetNetworkPing() * 1000) .. "ms")

    elseif cmd == "fps" then
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        Notify("FPS: " .. fps)

    elseif cmd == "gameid" then
        Notify("Game ID: " .. game.GameId)

    elseif cmd == "serverinfo" then
        Notify("Job ID: " .. game.JobId:sub(1, 12) .. "...")

    elseif cmd == "help" then
        Notify("Alle Commands im Panel oder /help")

    elseif cmd == "close" then
        -- handled by GUI
        Notify("Panel geschlossen")

    elseif cmd == "version" then
        Notify(CONFIG.PanelName .. " v" .. CONFIG.Version, CONFIG.AdminColor)

    elseif cmd == "credits" then
        Notify("IronHeadPanel by IronHead", CONFIG.YellowColor)

    else
        Notify("Unbekannter Command: " .. cmd, CONFIG.AdminColor)
    end
end

-- ╔══════════════════════════════════════╗
-- ║          HAUPT-GUI ERSTELLEN         ║
-- ╚══════════════════════════════════════╝

local function CreateGUI()
    -- Bestehende GUI entfernen
    if PlayerGui:FindFirstChild("IronHeadPanel") then
        PlayerGui.IronHeadPanel:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "IronHeadPanel"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = PlayerGui

    -- ┌─────────────────────────────────┐
    -- │         HAUPT-CONTAINER         │
    -- └─────────────────────────────────┘

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 720, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -360, 0.5, -260)
    MainFrame.BackgroundColor3 = CONFIG.BgDark
    MainFrame.BorderSizePixel = 0
    MainFrame.Visible = false
    MainFrame.Parent = ScreenGui

    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = MainFrame

    local mainStroke = Instance.new("UIStroke")
    mainStroke.Color = CONFIG.AdminColor
    mainStroke.Thickness = 2
    mainStroke.Parent = MainFrame

    -- Gradient Hintergrund
    local mainGrad = Instance.new("UIGradient")
    mainGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 10, 25)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 18)),
    })
    mainGrad.Rotation = 135
    mainGrad.Parent = MainFrame

    -- ┌─────────────────────────────────┐
    -- │            TITELLEISTE          │
    -- └─────────────────────────────────┘

    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Size = UDim2.new(1, 0, 0, 50)
    TitleBar.BackgroundColor3 = CONFIG.BgMid
    TitleBar.BorderSizePixel = 0
    TitleBar.Parent = MainFrame

    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 12)
    titleCorner.Parent = TitleBar

    -- Accent-Linie unter Titel
    local accentLine = Instance.new("Frame")
    accentLine.Size = UDim2.new(1, 0, 0, 2)
    accentLine.Position = UDim2.new(0, 0, 1, -1)
    accentLine.BackgroundColor3 = CONFIG.AdminColor
    accentLine.BorderSizePixel = 0
    accentLine.Parent = TitleBar

    local accentGrad = Instance.new("UIGradient")
    accentGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, CONFIG.AdminColor),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 120, 50)),
        ColorSequenceKeypoint.new(1, CONFIG.AdminColor),
    })
    accentGrad.Parent = accentLine

    -- Logo / Titel Text
    local TitleIcon = Instance.new("TextLabel")
    TitleIcon.Size = UDim2.new(0, 40, 1, 0)
    TitleIcon.Position = UDim2.new(0, 10, 0, 0)
    TitleIcon.BackgroundTransparency = 1
    TitleIcon.Text = "⚙"
    TitleIcon.TextColor3 = CONFIG.AdminColor
    TitleIcon.Font = Enum.Font.GothamBold
    TitleIcon.TextSize = 22
    TitleIcon.Parent = TitleBar

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 200, 1, 0)
    TitleLabel.Position = UDim2.new(0, 48, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "IronHead"
    TitleLabel.TextColor3 = CONFIG.AdminColor
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextSize = 20
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = TitleBar

    local TitleLabel2 = Instance.new("TextLabel")
    TitleLabel2.Size = UDim2.new(0, 120, 1, 0)
    TitleLabel2.Position = UDim2.new(0, 152, 0, 0)
    TitleLabel2.BackgroundTransparency = 1
    TitleLabel2.Text = "Panel"
    TitleLabel2.TextColor3 = CONFIG.TextColor
    TitleLabel2.Font = Enum.Font.GothamBold
    TitleLabel2.TextSize = 20
    TitleLabel2.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel2.Parent = TitleBar

    local VersionLabel = Instance.new("TextLabel")
    VersionLabel.Size = UDim2.new(0, 60, 1, 0)
    VersionLabel.Position = UDim2.new(0, 270, 0, 0)
    VersionLabel.BackgroundTransparency = 1
    VersionLabel.Text = "v" .. CONFIG.Version
    VersionLabel.TextColor3 = CONFIG.SubText
    VersionLabel.Font = Enum.Font.Gotham
    VersionLabel.TextSize = 11
    VersionLabel.TextXAlignment = Enum.TextXAlignment.Left
    VersionLabel.Parent = TitleBar

    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 36, 0, 36)
    CloseBtn.Position = UDim2.new(1, -44, 0.5, -18)
    CloseBtn.BackgroundColor3 = Color3.fromRGB(180, 30, 30)
    CloseBtn.Text = "✕"
    CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 16
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Parent = TitleBar
    Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

    CloseBtn.MouseButton1Click:Connect(function()
        State.PanelOpen = false
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 720, 0, 520)
        MainFrame.Position = UDim2.new(0.5, -360, 0.5, -260)
    end)

    -- Minimize Button
    local MinBtn = Instance.new("TextButton")
    MinBtn.Size = UDim2.new(0, 36, 0, 36)
    MinBtn.Position = UDim2.new(1, -86, 0.5, -18)
    MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
    MinBtn.Text = "—"
    MinBtn.TextColor3 = CONFIG.SubText
    MinBtn.Font = Enum.Font.GothamBold
    MinBtn.TextSize = 14
    MinBtn.BorderSizePixel = 0
    MinBtn.Parent = TitleBar
    Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

    -- ╔══════════════════════════════════╗
    -- ║      IHP ICON (rechts oben)      ║
    -- ╚══════════════════════════════════╝
    local LogoFrame = Instance.new("Frame")
    LogoFrame.Name = "IHP_Logo"
    LogoFrame.Size = UDim2.new(0, 100, 0, 100)
    LogoFrame.Position = UDim2.new(1, -118, 0, -28)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.ZIndex = 10
    LogoFrame.ClipsDescendants = false
    LogoFrame.Parent = MainFrame

    -- Glow-Ring außen
    local glowRing = Instance.new("Frame")
    glowRing.Size = UDim2.new(1, 0, 1, 0)
    glowRing.BackgroundColor3 = CONFIG.AdminColor
    glowRing.BackgroundTransparency = 0.65
    glowRing.BorderSizePixel = 0
    glowRing.ZIndex = 10
    glowRing.Parent = LogoFrame
    Instance.new("UICorner", glowRing).CornerRadius = UDim.new(0.5, 0)

    -- Roter Rand-Kreis
    local borderCircle = Instance.new("Frame")
    borderCircle.Size = UDim2.new(0, 88, 0, 88)
    borderCircle.Position = UDim2.new(0.5, -44, 0.5, -44)
    borderCircle.BackgroundColor3 = CONFIG.AdminColor
    borderCircle.BorderSizePixel = 0
    borderCircle.ZIndex = 11
    borderCircle.Parent = LogoFrame
    Instance.new("UICorner", borderCircle).CornerRadius = UDim.new(0.5, 0)

    -- Dunkler Innenkreis
    local innerCircle = Instance.new("Frame")
    innerCircle.Size = UDim2.new(0, 74, 0, 74)
    innerCircle.Position = UDim2.new(0.5, -37, 0.5, -37)
    innerCircle.BackgroundColor3 = CONFIG.BgDark
    innerCircle.BorderSizePixel = 0
    innerCircle.ZIndex = 12
    innerCircle.Parent = LogoFrame
    Instance.new("UICorner", innerCircle).CornerRadius = UDim.new(0.5, 0)

    local innerGrad = Instance.new("UIGradient")
    innerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(28, 8, 8)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(8, 8, 18)),
    })
    innerGrad.Rotation = 135
    innerGrad.Parent = innerCircle

    -- "IHP" Text
    local logoText = Instance.new("TextLabel")
    logoText.Size = UDim2.new(0, 68, 0, 36)
    logoText.Position = UDim2.new(0.5, -34, 0.5, -22)
    logoText.BackgroundTransparency = 1
    logoText.Text = "IHP"
    logoText.TextColor3 = CONFIG.AdminColor
    logoText.Font = Enum.Font.GothamBlack
    logoText.TextSize = 28
    logoText.ZIndex = 13
    logoText.Parent = LogoFrame

    -- "PANEL" Subtext
    local logoSub = Instance.new("TextLabel")
    logoSub.Size = UDim2.new(0, 68, 0, 16)
    logoSub.Position = UDim2.new(0.5, -34, 0.5, 14)
    logoSub.BackgroundTransparency = 1
    logoSub.Text = "PANEL"
    logoSub.TextColor3 = Color3.fromRGB(180, 180, 210)
    logoSub.Font = Enum.Font.GothamBold
    logoSub.TextSize = 9
    logoSub.ZIndex = 13
    logoSub.Parent = LogoFrame

    -- Pulsier-Animation
    task.spawn(function()
        while LogoFrame and LogoFrame.Parent do
            TweenService:Create(glowRing, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.4
            }):Play()
            task.wait(1.2)
            TweenService:Create(glowRing, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
                BackgroundTransparency = 0.78
            }):Play()
            task.wait(1.2)
        end
    end)

    -- Drag-Funktionalität
    local dragging, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    -- ┌─────────────────────────────────┐
    -- │             TABS                │
    -- └─────────────────────────────────┘

    local TabBar = Instance.new("Frame")
    TabBar.Name = "TabBar"
    TabBar.Size = UDim2.new(0, 140, 1, -52)
    TabBar.Position = UDim2.new(0, 0, 0, 52)
    TabBar.BackgroundColor3 = CONFIG.BgMid
    TabBar.BorderSizePixel = 0
    TabBar.Parent = MainFrame

    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 0)
    tabCorner.Parent = TabBar

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Padding = UDim.new(0, 4)
    TabLayout.Parent = TabBar

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingTop = UDim.new(0, 8)
    TabPadding.PaddingLeft = UDim.new(0, 8)
    TabPadding.PaddingRight = UDim.new(0, 8)
    TabPadding.Parent = TabBar

    -- Content Area
    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "ContentArea"
    ContentArea.Size = UDim2.new(1, -148, 1, -58)
    ContentArea.Position = UDim2.new(0, 146, 0, 54)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local tabs = {}
    local tabPages = {}
    local activeTab = nil

    local function SetActiveTab(name)
        for tname, btn in pairs(tabs) do
            if tname == name then
                btn.BackgroundColor3 = CONFIG.AdminColor
                btn.TextColor3 = Color3.fromRGB(255, 255, 255)
            else
                btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
                btn.TextColor3 = CONFIG.SubText
            end
        end
        for pname, page in pairs(tabPages) do
            page.Visible = (pname == name)
        end
        activeTab = name
    end

    local function AddTab(name, icon)
        local btn = Instance.new("TextButton")
        btn.Name = "Tab_" .. name
        btn.Size = UDim2.new(1, 0, 0, 38)
        btn.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
        btn.Text = icon .. "  " .. name
        btn.TextColor3 = CONFIG.SubText
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.TextXAlignment = Enum.TextXAlignment.Left
        btn.BorderSizePixel = 0
        btn.Parent = TabBar
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        local pad = Instance.new("UIPadding")
        pad.PaddingLeft = UDim.new(0, 10)
        pad.Parent = btn

        local page = Instance.new("ScrollingFrame")
        page.Name = "Page_" .. name
        page.Size = UDim2.new(1, 0, 1, 0)
        page.BackgroundTransparency = 1
        page.ScrollBarThickness = 4
        page.ScrollBarImageColor3 = CONFIG.AdminColor
        page.Visible = false
        page.Parent = ContentArea

        local pageLayout = Instance.new("UIListLayout")
        pageLayout.Padding = UDim.new(0, 8)
        pageLayout.Parent = page

        local pagePad = Instance.new("UIPadding")
        pagePad.PaddingTop = UDim.new(0, 8)
        pagePad.PaddingLeft = UDim.new(0, 4)
        pagePad.PaddingRight = UDim.new(0, 12)
        pagePad.Parent = page

        -- Auto resize
        pageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            page.CanvasSize = UDim2.new(0, 0, 0, pageLayout.AbsoluteContentSize.Y + 20)
        end)

        btn.MouseButton1Click:Connect(function()
            SetActiveTab(name)
        end)

        tabs[name] = btn
        tabPages[name] = page
        return page
    end

    -- ┌─────────────────────────────────┐
    -- │        TOGGLE BUTTON HELPER     │
    -- └─────────────────────────────────┘

    local function CreateToggle(parent, labelText, stateKey, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 44)
        row.BackgroundColor3 = CONFIG.BgLight
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -70, 1, 0)
        lbl.Position = UDim2.new(0, 12, 0, 0)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = CONFIG.TextColor
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local toggle = Instance.new("TextButton")
        toggle.Size = UDim2.new(0, 50, 0, 26)
        toggle.Position = UDim2.new(1, -60, 0.5, -13)
        toggle.BackgroundColor3 = State[stateKey] and CONFIG.GreenColor or Color3.fromRGB(60, 60, 80)
        toggle.Text = State[stateKey] and "AN" or "AUS"
        toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
        toggle.Font = Enum.Font.GothamBold
        toggle.TextSize = 11
        toggle.BorderSizePixel = 0
        toggle.Parent = row
        Instance.new("UICorner", toggle).CornerRadius = UDim.new(0, 13)

        toggle.MouseButton1Click:Connect(function()
            callback()
            task.wait(0.05)
            toggle.BackgroundColor3 = State[stateKey] and CONFIG.GreenColor or Color3.fromRGB(60, 60, 80)
            toggle.Text = State[stateKey] and "AN" or "AUS"
        end)

        return row
    end

    local function CreateSlider(parent, labelText, min, max, default, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 60)
        row.BackgroundColor3 = CONFIG.BgLight
        row.BorderSizePixel = 0
        row.Parent = parent
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 8)

        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(0.6, 0, 0, 24)
        lbl.Position = UDim2.new(0, 12, 0, 4)
        lbl.BackgroundTransparency = 1
        lbl.Text = labelText
        lbl.TextColor3 = CONFIG.TextColor
        lbl.Font = Enum.Font.GothamBold
        lbl.TextSize = 13
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = row

        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0.35, 0, 0, 24)
        valLabel.Position = UDim2.new(0.62, 0, 0, 4)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(default)
        valLabel.TextColor3 = CONFIG.AdminColor
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextSize = 13
        valLabel.TextXAlignment = Enum.TextXAlignment.Right
        valLabel.Parent = row

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -24, 0, 8)
        track.Position = UDim2.new(0, 12, 0, 36)
        track.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
        track.BorderSizePixel = 0
        track.Parent = row
        Instance.new("UICorner", track).CornerRadius = UDim.new(0, 4)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
        fill.BackgroundColor3 = CONFIG.AdminColor
        fill.BorderSizePixel = 0
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

        local handle = Instance.new("TextButton")
        handle.Size = UDim2.new(0, 16, 0, 16)
        handle.Position = UDim2.new((default - min) / (max - min), -8, 0.5, -8)
        handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        handle.Text = ""
        handle.BorderSizePixel = 0
        handle.ZIndex = 2
        handle.Parent = track
        Instance.new("UICorner", handle).CornerRadius = UDim.new(0.5, 0)

        local sliding = false
        handle.MouseButton1Down:Connect(function() sliding = true end)
        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
        end)
        UserInputService.InputChanged:Connect(function(i)
            if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
                local abs = track.AbsolutePosition
                local size = track.AbsoluteSize
                local rel = math.clamp((i.Position.X - abs.X) / size.X, 0, 1)
                local val = math.floor(min + (max - min) * rel)
                fill.Size = UDim2.new(rel, 0, 1, 0)
                handle.Position = UDim2.new(rel, -8, 0.5, -8)
                valLabel.Text = tostring(val)
                callback(val)
            end
        end)

        return row
    end

    local function CreateButton(parent, text, color, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, 0, 0, 40)
        btn.BackgroundColor3 = color or CONFIG.AdminColor
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamBold
        btn.TextSize = 13
        btn.BorderSizePixel = 0
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)

        btn.MouseButton1Click:Connect(callback)
        btn.MouseEnter:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {
                BackgroundColor3 = Color3.new(
                    math.min(color.R + 0.1, 1),
                    math.min(color.G + 0.1, 1),
                    math.min(color.B + 0.1, 1)
                )
            }):Play()
        end)
        btn.MouseLeave:Connect(function()
            TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundColor3 = color or CONFIG.AdminColor}):Play()
        end)

        return btn
    end

    local function CreateSection(parent, title)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(1, 0, 0, 24)
        sec.BackgroundTransparency = 1
        sec.Text = "▸ " .. title
        sec.TextColor3 = CONFIG.AdminColor
        sec.Font = Enum.Font.GothamBold
        sec.TextSize = 12
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.Parent = parent
        return sec
    end

    -- ════════════════════════════════════
    --          TAB: MOVEMENT
    -- ════════════════════════════════════
    local movePage = AddTab("Movement", "🏃")

    CreateSection(movePage, "BEWEGUNG")
    CreateToggle(movePage, "✈  Fly Modus", "FlyEnabled", ToggleFly)
    CreateToggle(movePage, "👻  Noclip", "NoclipEnabled", ToggleNoclip)
    CreateToggle(movePage, "🔁  Infinite Jump", "InfJump", ToggleInfJump)
    CreateSlider(movePage, "WalkSpeed", 0, 500, 16, function(v)
        local hum = GetHumanoid()
        if hum then hum.WalkSpeed = v end
        State.WalkSpeedVal = v
    end)
    CreateSlider(movePage, "JumpPower", 0, 500, 50, function(v)
        local hum = GetHumanoid()
        if hum then hum.JumpPower = v end
        State.JumpPowerVal = v
    end)
    CreateSection(movePage, "TELEPORT")
    CreateButton(movePage, "📍 Zur Spawn teleportieren", Color3.fromRGB(40, 80, 140), function()
        ExecuteCommand("goto 0 5 0")
    end)
    CreateButton(movePage, "🎯 Respawnen", Color3.fromRGB(40, 100, 60), function()
        ExecuteCommand("respawn")
    end)

    -- ════════════════════════════════════
    --          TAB: PLAYER
    -- ════════════════════════════════════
    local playerPage = AddTab("Player", "👤")

    CreateSection(playerPage, "ÜBERLEBEN")
    CreateToggle(playerPage, "🛡  God Mode", "GodMode", ToggleGodMode)
    CreateToggle(playerPage, "👻  Unsichtbar", "Invisible", function()
        ExecuteCommand("invisible")
    end)
    CreateToggle(playerPage, "🧊  Einfrieren", "Frozen", function()
        ExecuteCommand("freeze me")
    end)
    CreateSection(playerPage, "AKTIONEN")
    CreateButton(playerPage, "❤ Vollständig heilen", CONFIG.GreenColor, function()
        ExecuteCommand("heal me")
    end)
    CreateButton(playerPage, "💀 Kill selbst", Color3.fromRGB(140, 30, 30), function()
        ExecuteCommand("kill me")
    end)
    CreateButton(playerPage, "🪑 Hinsetzen", Color3.fromRGB(60, 60, 120), function()
        ExecuteCommand("sit")
    end)
    CreateSection(playerPage, "AUSSEHEN")
    CreateButton(playerPage, "🌈 Rainbow Charakter", Color3.fromRGB(120, 50, 120), function()
        ExecuteCommand("rainbow")
    end)
    CreateButton(playerPage, "✨ Trail Effekt", Color3.fromRGB(50, 100, 120), function()
        ExecuteCommand("trails")
    end)
    CreateSlider(playerPage, "Charakter-Größe", 1, 10, 1, function(v)
        ExecuteCommand("size " .. v)
    end)

    -- ════════════════════════════════════
    --          TAB: VISUALS
    -- ════════════════════════════════════
    local visualPage = AddTab("Visuals", "👁")

    CreateSection(visualPage, "ESP")
    CreateToggle(visualPage, "🔴  ESP (Spieler sehen)", "ESPEnabled", ToggleESP)

    CreateSection(visualPage, "BELEUCHTUNG")
    CreateToggle(visualPage, "☀  FullBright", "FullBright", ToggleFullBright)
    CreateSlider(visualPage, "Field of View", 1, 120, 70, function(v)
        Camera.FieldOfView = v
        State.FovVal = v
    end)
    CreateSlider(visualPage, "Blur-Effekt", 0, 56, 0, function(v)
        local blur = Lighting:FindFirstChild("IHP_Blur") or Instance.new("BlurEffect", Lighting)
        blur.Name = "IHP_Blur"
        blur.Size = v
    end)
    CreateSection(visualPage, "UMGEBUNG")
    CreateSlider(visualPage, "Tageszeit (0-24)", 0, 24, 12, function(v)
        Lighting.TimeOfDay = ("%02d:00:00"):format(v)
    end)
    CreateSlider(visualPage, "Schwerkraft", 0, 500, 196, function(v)
        Workspace.Gravity = v
    end)

    -- ════════════════════════════════════
    --          TAB: TOOLS
    -- ════════════════════════════════════
    local toolsPage = AddTab("Tools", "🔧")

    CreateSection(toolsPage, "SPIELER")
    CreateToggle(toolsPage, "⏱  Anti-AFK", "AntiAFK", ToggleAntiAFK)
    CreateSection(toolsPage, "SERVER-INFO")
    CreateButton(toolsPage, "📋 Alle Spieler anzeigen", Color3.fromRGB(40, 60, 100), function()
        ExecuteCommand("players")
    end)
    CreateButton(toolsPage, "📍 Position anzeigen", Color3.fromRGB(50, 80, 50), function()
        ExecuteCommand("pos")
    end)
    CreateButton(toolsPage, "📶 Ping anzeigen", Color3.fromRGB(60, 80, 60), function()
        ExecuteCommand("ping")
    end)
    CreateButton(toolsPage, "🎮 FPS anzeigen", Color3.fromRGB(70, 60, 90), function()
        ExecuteCommand("fps")
    end)
    CreateButton(toolsPage, "🆔 Game ID", Color3.fromRGB(60, 60, 80), function()
        ExecuteCommand("gameid")
    end)

    -- ════════════════════════════════════
    --       TAB: COMMANDS (CMD)
    -- ════════════════════════════════════
    local cmdPage = AddTab("Commands", "💻")

    -- Suchfeld
    local searchFrame = Instance.new("Frame")
    searchFrame.Size = UDim2.new(1, 0, 0, 40)
    searchFrame.BackgroundColor3 = CONFIG.BgLight
    searchFrame.BorderSizePixel = 0
    searchFrame.Parent = cmdPage
    Instance.new("UICorner", searchFrame).CornerRadius = UDim.new(0, 8)

    local searchIcon = Instance.new("TextLabel")
    searchIcon.Size = UDim2.new(0, 30, 1, 0)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Text = "🔍"
    searchIcon.TextSize = 14
    searchIcon.Parent = searchFrame

    local searchBox = Instance.new("TextBox")
    searchBox.Size = UDim2.new(1, -36, 1, 0)
    searchBox.Position = UDim2.new(0, 32, 0, 0)
    searchBox.BackgroundTransparency = 1
    searchBox.PlaceholderText = "Command suchen..."
    searchBox.PlaceholderColor3 = CONFIG.SubText
    searchBox.Text = ""
    searchBox.TextColor3 = CONFIG.TextColor
    searchBox.Font = Enum.Font.Gotham
    searchBox.TextSize = 13
    searchBox.TextXAlignment = Enum.TextXAlignment.Left
    searchBox.ClearTextOnFocus = false
    searchBox.Parent = searchFrame

    -- Commands Liste
    local cmdScroll = Instance.new("ScrollingFrame")
    cmdScroll.Size = UDim2.new(1, 0, 1, -54)
    cmdScroll.Position = UDim2.new(0, 0, 0, 50)
    cmdScroll.BackgroundTransparency = 1
    cmdScroll.ScrollBarThickness = 4
    cmdScroll.ScrollBarImageColor3 = CONFIG.AdminColor
    cmdScroll.Parent = cmdPage

    local cmdLayout = Instance.new("UIListLayout")
    cmdLayout.Padding = UDim.new(0, 4)
    cmdLayout.Parent = cmdScroll

    cmdLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        cmdScroll.CanvasSize = UDim2.new(0, 0, 0, cmdLayout.AbsoluteContentSize.Y + 10)
    end)

    local cmdItems = {}

    local function RenderCommands(filter)
        for _, item in ipairs(cmdItems) do item:Destroy() end
        cmdItems = {}
        filter = filter and filter:lower() or ""

        local currentCat = ""
        for _, c in ipairs(COMMANDS) do
            if filter == "" or c.name:lower():find(filter) or c.desc:lower():find(filter) then
                if c.cat ~= currentCat then
                    currentCat = c.cat
                    local catLabel = Instance.new("TextLabel")
                    catLabel.Size = UDim2.new(1, 0, 0, 22)
                    catLabel.BackgroundTransparency = 1
                    catLabel.Text = "── " .. c.cat:upper() .. " ──"
                    catLabel.TextColor3 = CONFIG.AdminColor
                    catLabel.Font = Enum.Font.GothamBold
                    catLabel.TextSize = 11
                    catLabel.Parent = cmdScroll
                    table.insert(cmdItems, catLabel)
                end

                local row = Instance.new("TextButton")
                row.Size = UDim2.new(1, 0, 0, 46)
                row.BackgroundColor3 = CONFIG.BgLight
                row.Text = ""
                row.BorderSizePixel = 0
                row.Parent = cmdScroll
                Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)
                table.insert(cmdItems, row)

                local cmdName = Instance.new("TextLabel")
                cmdName.Size = UDim2.new(0.45, 0, 0.5, 0)
                cmdName.Position = UDim2.new(0, 10, 0, 2)
                cmdName.BackgroundTransparency = 1
                cmdName.Text = "/" .. c.name .. (c.args ~= "" and " " .. c.args or "")
                cmdName.TextColor3 = CONFIG.AccentColor
                cmdName.Font = Enum.Font.GothamBold
                cmdName.TextSize = 12
                cmdName.TextXAlignment = Enum.TextXAlignment.Left
                cmdName.Parent = row

                local cmdDesc = Instance.new("TextLabel")
                cmdDesc.Size = UDim2.new(1, -10, 0.5, 0)
                cmdDesc.Position = UDim2.new(0, 10, 0.5, 0)
                cmdDesc.BackgroundTransparency = 1
                cmdDesc.Text = c.desc
                cmdDesc.TextColor3 = CONFIG.SubText
                cmdDesc.Font = Enum.Font.Gotham
                cmdDesc.TextSize = 11
                cmdDesc.TextXAlignment = Enum.TextXAlignment.Left
                cmdDesc.Parent = row

                -- Klick um Command in CMD-Bar zu setzen
                row.MouseButton1Click:Connect(function()
                    SetActiveTab("CMD Bar")
                end)
            end
        end
    end

    RenderCommands()
    searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        RenderCommands(searchBox.Text)
    end)

    -- ════════════════════════════════════
    --       TAB: CMD BAR (HAUPT-FEATURE)
    -- ════════════════════════════════════
    local cmdBarPage = AddTab("CMD Bar", "⌨")

    -- CMD Input Frame
    local inputSection = Instance.new("Frame")
    inputSection.Size = UDim2.new(1, 0, 0, 60)
    inputSection.BackgroundColor3 = CONFIG.BgLight
    inputSection.BorderSizePixel = 0
    inputSection.Parent = cmdBarPage
    Instance.new("UICorner", inputSection).CornerRadius = UDim.new(0, 10)

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Color = CONFIG.AdminColor
    inputStroke.Thickness = 1.5
    inputStroke.Parent = inputSection

    local inputPrefix = Instance.new("TextLabel")
    inputPrefix.Size = UDim2.new(0, 28, 1, 0)
    inputPrefix.BackgroundTransparency = 1
    inputPrefix.Text = "/"
    inputPrefix.TextColor3 = CONFIG.AdminColor
    inputPrefix.Font = Enum.Font.GothamBold
    inputPrefix.TextSize = 18
    inputPrefix.Parent = inputSection

    local CmdInput = Instance.new("TextBox")
    CmdInput.Name = "CmdInput"
    CmdInput.Size = UDim2.new(1, -100, 1, 0)
    CmdInput.Position = UDim2.new(0, 28, 0, 0)
    CmdInput.BackgroundTransparency = 1
    CmdInput.PlaceholderText = "Command eingeben..."
    CmdInput.PlaceholderColor3 = CONFIG.SubText
    CmdInput.Text = ""
    CmdInput.TextColor3 = CONFIG.TextColor
    CmdInput.Font = Enum.Font.GothamBold
    CmdInput.TextSize = 14
    CmdInput.TextXAlignment = Enum.TextXAlignment.Left
    CmdInput.ClearTextOnFocus = false
    CmdInput.Parent = inputSection

    local ExecBtn = Instance.new("TextButton")
    ExecBtn.Size = UDim2.new(0, 70, 0, 36)
    ExecBtn.Position = UDim2.new(1, -76, 0.5, -18)
    ExecBtn.BackgroundColor3 = CONFIG.AdminColor
    ExecBtn.Text = "▶ RUN"
    ExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ExecBtn.Font = Enum.Font.GothamBold
    ExecBtn.TextSize = 11
    ExecBtn.BorderSizePixel = 0
    ExecBtn.Parent = inputSection
    Instance.new("UICorner", ExecBtn).CornerRadius = UDim.new(0, 8)

    local function RunCmd()
        local text = CmdInput.Text
        if text ~= "" then
            ExecuteCommand(text)
            CmdInput.Text = ""
        end
    end

    ExecBtn.MouseButton1Click:Connect(RunCmd)
    CmdInput.FocusLost:Connect(function(entered)
        if entered then RunCmd() end
    end)

    -- History Navigation
    CmdInput.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.Up then
            State.HistoryIndex = math.min(State.HistoryIndex + 1, #State.CommandHistory)
            if State.CommandHistory[State.HistoryIndex] then
                CmdInput.Text = State.CommandHistory[State.HistoryIndex]
            end
        elseif input.KeyCode == Enum.KeyCode.Down then
            State.HistoryIndex = math.max(State.HistoryIndex - 1, 0)
            CmdInput.Text = State.CommandHistory[State.HistoryIndex] or ""
        end
    end)

    -- Hinweis Label
    local hintLabel = Instance.new("TextLabel")
    hintLabel.Size = UDim2.new(1, 0, 0, 20)
    hintLabel.BackgroundTransparency = 1
    hintLabel.Text = "↑↓ Verlauf  |  ENTER = Ausführen  |  Prefix '/' optional"
    hintLabel.TextColor3 = CONFIG.SubText
    hintLabel.Font = Enum.Font.Gotham
    hintLabel.TextSize = 11
    hintLabel.Parent = cmdBarPage

    -- Schnellzugriff Buttons
    local quickLabel = Instance.new("TextLabel")
    quickLabel.Size = UDim2.new(1, 0, 0, 20)
    quickLabel.BackgroundTransparency = 1
    quickLabel.Text = "▸ SCHNELLZUGRIFF"
    quickLabel.TextColor3 = CONFIG.AdminColor
    quickLabel.Font = Enum.Font.GothamBold
    quickLabel.TextSize = 12
    quickLabel.TextXAlignment = Enum.TextXAlignment.Left
    quickLabel.Parent = cmdBarPage

    local quickCmds = {
        {"💀 Loop Kill",  "repeatkill me true", Color3.fromRGB(140,20,20)},
        {"💥 EXPLODE!",  "explode",    Color3.fromRGB(200,70,0)},
        {"⚡ Speed x5",  "speed 80",   Color3.fromRGB(40,80,140)},
        {"🛡 God ON",    "god",         CONFIG.GreenColor},
        {"👁 ESP ON",    "esp",         Color3.fromRGB(180,40,40)},
        {"✈ Fly ON",    "fly",         Color3.fromRGB(60,80,160)},
        {"👻 Noclip",   "noclip",      Color3.fromRGB(80,50,140)},
        {"🔆 Fullbright","fullbright",  Color3.fromRGB(140,120,20)},
        {"❤ Heal",      "heal me",     Color3.fromRGB(40,140,60)},
        {"🔄 Respawn",  "respawn",     Color3.fromRGB(80,60,40)},
        {"⚖ Reset Speed","speed 16",  Color3.fromRGB(50,50,80)},
        {"🌈 Rainbow",  "rainbow",     Color3.fromRGB(120,40,120)},
        {"✨ Trail",     "trails",      Color3.fromRGB(40,100,120)},
        {"🌑 Nacht",    "time 0",      Color3.fromRGB(20,20,60)},
    }

    local grid = Instance.new("Frame")
    grid.Size = UDim2.new(1, 0, 0, 160)
    grid.BackgroundTransparency = 1
    grid.Parent = cmdBarPage

    local gridLayout = Instance.new("UIGridLayout")
    gridLayout.CellSize = UDim2.new(0.5, -4, 0, 36)
    gridLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    gridLayout.Parent = grid

    for _, qc in ipairs(quickCmds) do
        local qbtn = Instance.new("TextButton")
        qbtn.BackgroundColor3 = qc[3]
        qbtn.Text = qc[1]
        qbtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        qbtn.Font = Enum.Font.GothamBold
        qbtn.TextSize = 12
        qbtn.BorderSizePixel = 0
        qbtn.Parent = grid
        Instance.new("UICorner", qbtn).CornerRadius = UDim.new(0, 6)

        qbtn.MouseButton1Click:Connect(function()
            ExecuteCommand(qc[2])
        end)
    end

    -- Alle commands liste am unteren Rand der CMD-Bar seite
    local allCmdLabel = Instance.new("TextLabel")
    allCmdLabel.Size = UDim2.new(1, 0, 0, 20)
    allCmdLabel.BackgroundTransparency = 1
    allCmdLabel.Text = "▸ ALLE COMMANDS"
    allCmdLabel.TextColor3 = CONFIG.AdminColor
    allCmdLabel.Font = Enum.Font.GothamBold
    allCmdLabel.TextSize = 12
    allCmdLabel.TextXAlignment = Enum.TextXAlignment.Left
    allCmdLabel.Parent = cmdBarPage

    local miniCmdScroll = Instance.new("ScrollingFrame")
    miniCmdScroll.Size = UDim2.new(1, 0, 0, 180)
    miniCmdScroll.BackgroundColor3 = CONFIG.BgLight
    miniCmdScroll.BorderSizePixel = 0
    miniCmdScroll.ScrollBarThickness = 4
    miniCmdScroll.ScrollBarImageColor3 = CONFIG.AdminColor
    miniCmdScroll.Parent = cmdBarPage
    Instance.new("UICorner", miniCmdScroll).CornerRadius = UDim.new(0, 8)

    local miniLayout = Instance.new("UIListLayout")
    miniLayout.Padding = UDim.new(0, 0)
    miniLayout.Parent = miniCmdScroll

    miniLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        miniCmdScroll.CanvasSize = UDim2.new(0, 0, 0, miniLayout.AbsoluteContentSize.Y)
    end)

    for _, c in ipairs(COMMANDS) do
        local row = Instance.new("TextButton")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundTransparency = 1
        row.BorderSizePixel = 0
        row.Text = ""
        row.Parent = miniCmdScroll

        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(0.45, 0, 1, 0)
        txt.Position = UDim2.new(0, 8, 0, 0)
        txt.BackgroundTransparency = 1
        txt.Text = "/" .. c.name
        txt.TextColor3 = CONFIG.AccentColor
        txt.Font = Enum.Font.GothamBold
        txt.TextSize = 12
        txt.TextXAlignment = Enum.TextXAlignment.Left
        txt.Parent = row

        local desc = Instance.new("TextLabel")
        desc.Size = UDim2.new(0.54, 0, 1, 0)
        desc.Position = UDim2.new(0.45, 0, 0, 0)
        desc.BackgroundTransparency = 1
        desc.Text = c.desc
        desc.TextColor3 = CONFIG.SubText
        desc.Font = Enum.Font.Gotham
        desc.TextSize = 11
        desc.TextXAlignment = Enum.TextXAlignment.Left
        desc.Parent = row

        -- Klick befüllt CMD-Input
        row.MouseButton1Click:Connect(function()
            CmdInput.Text = c.name .. (c.args ~= "" and " " or "")
            CmdInput:CaptureFocus()
        end)

        row.MouseEnter:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundTransparency = 0.85}):Play()
            row.BackgroundColor3 = CONFIG.AdminColor
        end)
        row.MouseLeave:Connect(function()
            TweenService:Create(row, TweenInfo.new(0.1), {BackgroundTransparency = 1}):Play()
        end)
    end

    -- ════════════════════════════════════
    --       TAB: INFO
    -- ════════════════════════════════════
    local infoPage = AddTab("Info", "ℹ")

    CreateSection(infoPage, "ÜBER DAS SCRIPT")

    local infoBox = Instance.new("Frame")
    infoBox.Size = UDim2.new(1, 0, 0, 140)
    infoBox.BackgroundColor3 = CONFIG.BgLight
    infoBox.BorderSizePixel = 0
    infoBox.Parent = infoPage
    Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 10)
    Instance.new("UIStroke", infoBox).Color = CONFIG.AdminColor

    local infoText = Instance.new("TextLabel")
    infoText.Size = UDim2.new(1, -20, 1, -20)
    infoText.Position = UDim2.new(0, 10, 0, 10)
    infoText.BackgroundTransparency = 1
    infoText.Text = [[⚙  IronHeadPanel v2.0

🔴  ESP System — Spieler durch Wände sehen
✈   Fly System — Fliegen mit WASD
👻  Noclip — Durch Wände gehen
🛡   God Mode — Unverwundbarkeit
☀   Fullbright — Volle Helligkeit
⌨   CMD Bar — Rechte Shift öffnet Panel
💻  35+ Admin Commands verfügbar]]
    infoText.TextColor3 = CONFIG.TextColor
    infoText.Font = Enum.Font.Gotham
    infoText.TextSize = 12
    infoText.TextXAlignment = Enum.TextXAlignment.Left
    infoText.TextYAlignment = Enum.TextYAlignment.Top
    infoText.Parent = infoBox

    CreateSection(infoPage, "KEYBINDS")
    local keybindBox = Instance.new("Frame")
    keybindBox.Size = UDim2.new(1, 0, 0, 90)
    keybindBox.BackgroundColor3 = CONFIG.BgLight
    keybindBox.BorderSizePixel = 0
    keybindBox.Parent = infoPage
    Instance.new("UICorner", keybindBox).CornerRadius = UDim.new(0, 10)

    local keybindText = Instance.new("TextLabel")
    keybindText.Size = UDim2.new(1, -20, 1, -10)
    keybindText.Position = UDim2.new(0, 10, 0, 5)
    keybindText.BackgroundTransparency = 1
    keybindText.Text = "RECHTE SHIFT  →  Panel öffnen / schließen\nW/A/S/D + SPACE  →  Fly-Steuerung\nLINKE SHIFT (im Fly)  →  Boost\nPFEIL HOCH/RUNTER  →  CMD-Verlauf"
    keybindText.TextColor3 = CONFIG.TextColor
    keybindText.Font = Enum.Font.Gotham
    keybindText.TextSize = 12
    keybindText.TextXAlignment = Enum.TextXAlignment.Left
    keybindText.TextYAlignment = Enum.TextYAlignment.Top
    keybindText.Parent = keybindBox

    -- ════════════════════════════════════
    --    PLAYER LIST (rechte Seite)
    -- ════════════════════════════════════

    -- Status-Leiste unten
    local StatusBar = Instance.new("Frame")
    StatusBar.Name = "StatusBar"
    StatusBar.Size = UDim2.new(1, 0, 0, 26)
    StatusBar.Position = UDim2.new(0, 0, 1, -26)
    StatusBar.BackgroundColor3 = CONFIG.BgMid
    StatusBar.BorderSizePixel = 0
    StatusBar.ZIndex = 5
    StatusBar.Parent = MainFrame

    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 12)
    statusCorner.Parent = StatusBar

    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size = UDim2.new(1, -10, 1, 0)
    statusLabel.Position = UDim2.new(0, 10, 0, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 11
    statusLabel.TextColor3 = CONFIG.SubText
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = StatusBar

    -- Status updaten
    RunService.Heartbeat:Connect(function()
        local fps = math.floor(1 / RunService.Heartbeat:Wait())
        local ping = math.floor(LocalPlayer:GetNetworkPing() * 1000)
        local root = GetRootPart()
        local pos = root and root.Position or Vector3.zero
        statusLabel.Text = string.format(
            "FPS: %d  |  Ping: %dms  |  Pos: (%.0f, %.0f, %.0f)  |  ESP: %s  |  God: %s  |  Fly: %s",
            fps, ping, pos.X, pos.Y, pos.Z,
            State.ESPEnabled and "✓" or "✗",
            State.GodMode and "✓" or "✗",
            State.FlyEnabled and "✓" or "✗"
        )
    end)

    -- Standard Tab setzen
    SetActiveTab("CMD Bar")

    -- Open/Close Animation
    local function OpenPanel()
        MainFrame.Visible = true
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, 720, 0, 520),
            Position = UDim2.new(0.5, -360, 0.5, -260)
        }):Play()
    end

    local function ClosePanel()
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.3)
        MainFrame.Visible = false
        MainFrame.Size = UDim2.new(0, 720, 0, 520)
        MainFrame.Position = UDim2.new(0.5, -360, 0.5, -260)
    end

    -- ╔══════════════════════════════════════╗
    -- ║     RECHTE SHIFT → PANEL ÖFFNEN     ║
    -- ╚══════════════════════════════════════╝

    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if input.KeyCode == CONFIG.OpenKey then
            State.PanelOpen = not State.PanelOpen
            if State.PanelOpen then
                OpenPanel()
                Notify("IronHeadPanel geöffnet ⚙", CONFIG.AdminColor)
            else
                ClosePanel()
            end
        end
    end)

    -- Startup Notification
    task.delay(1, function()
        Notify("IronHeadPanel v" .. CONFIG.Version .. " geladen!", CONFIG.AdminColor)
        task.wait(0.5)
        Notify("RECHTE SHIFT → Panel öffnen", CONFIG.YellowColor)
    end)

    print([[
╔══════════════════════════════════════╗
║      IronHeadPanel v2.0 geladen!     ║
║  RECHTE SHIFT → Panel öffnen/schließen ║
║  Prefix: /  |  35+ Commands          ║
╚══════════════════════════════════════╝
    ]])
end

-- ╔══════════════════════════════════════╗
-- ║              STARTEN                 ║
-- ╚══════════════════════════════════════╝

CreateGUI()
