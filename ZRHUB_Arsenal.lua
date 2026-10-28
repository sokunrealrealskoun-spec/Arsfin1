local flySettings = { fly = false, flyspeed = 50 }
local c, h, bv, bav, cam, flying
local p = game.Players.LocalPlayer
local buttons = { W = false, S = false, A = false, D = false, Moving = false }

local startFly = function()
    if not p.Character or not p.Character.Head or flying then return end
    c = p.Character
    h = c.Humanoid
    h.PlatformStand = true
    cam = workspace:WaitForChild("Camera")
    bv = Instance.new("BodyVelocity")
    bav = Instance.new("BodyAngularVelocity")
    bv.Velocity, bv.MaxForce, bv.P = Vector3.new(0,0,0), Vector3.new(10000,10000,10000), 1000
    bav.AngularVelocity, bav.MaxTorque, bav.P = Vector3.new(0,0,0), Vector3.new(10000,10000,10000), 1000
    bv.Parent = c.Head
    bav.Parent = c.Head
    flying = true
    h.Died:Connect(function() flying = false end)
end

local endFly = function()
    if not p.Character or not flying then return end
    h.PlatformStand = false
    bv:Destroy()
    bav:Destroy()
    flying = false
end

game:GetService("UserInputService").InputBegan:Connect(function(input, GPE)
    if GPE then return end
    for i in pairs(buttons) do
        if i ~= "Moving" and input.KeyCode == Enum.KeyCode[i] then
            buttons[i] = true
            buttons.Moving = true
        end
    end
end)

game:GetService("UserInputService").InputEnded:Connect(function(input, GPE)
    if GPE then return end
    local a = false
    for i in pairs(buttons) do
        if i ~= "Moving" then
            if input.KeyCode == Enum.KeyCode[i] then buttons[i] = false end
            if buttons[i] then a = true end
        end
    end
    buttons.Moving = a
end)

local setVec = function(vec) return vec * (flySettings.flyspeed / vec.Magnitude) end

game:GetService("RunService").Heartbeat:Connect(function(step)
    if flying and c and c.PrimaryPart then
        local pos = c.PrimaryPart.Position
        local cf = cam.CFrame
        local ax, ay, az = cf:toEulerAnglesXYZ()
        c:SetPrimaryPartCFrame(CFrame.new(pos.x, pos.y, pos.z) * CFrame.Angles(ax, ay, az))
        if buttons.Moving then
            local t = Vector3.new()
            if buttons.W then t = t + setVec(cf.lookVector) end
            if buttons.S then t = t - setVec(cf.lookVector) end
            if buttons.A then t = t - setVec(cf.rightVector) end
            if buttons.D then t = t + setVec(cf.rightVector) end
            c:TranslateBy(t * step)
        end
    end
end)


local repo = "https://raw.githubusercontent.com/deividcomsono/Obsidian/main/"
local Library      = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager  = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

local Window = Library:CreateWindow({
    Title           = "ZR HUB",
    Footer          = "Arsenal",
    Icon            = "rbxthumb://type=Asset&id=129949624640047&w=150&h=150",
    NotifySide      = "Right",
    ShowCustomCursor = true,
    AutoShow        = true,
})

local Tabs = {
    Home       = Window:AddTab("Home",        "house"),
    Main       = Window:AddTab("Main",        "crosshair"),
    Guns = Window:AddTab("Guns", "zap"),
    Visuals    = Window:AddTab("Visuals",     "eye"),
    Extra      = Window:AddTab("Extra",       "star"),
    Skins      = Window:AddTab("Skins",       "palette"),
    Settings   = Window:AddTab("Settings",    "settings"),
    Credits    = Window:AddTab("Credits",     "user"),
    UISettings = Window:AddTab("UI Settings", "sliders-horizontal"),
}





-- ===================== Home =====================
do
    local Players = game:GetService("Players")
    local RunService = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    local lp = Players.LocalPlayer
    local me = Tabs.Home:AddLeftGroupbox("ZRHUB", "user-round")
    local avatar = Instance.new("ImageLabel")
    avatar.BackgroundTransparency = 1
    avatar.Size = UDim2.new(1.4, 0, 1.4, 0)
    avatar.Position = UDim2.new(-0.2, 0, -0.2, 0)
    avatar.ScaleType = Enum.ScaleType.Fit
    avatar.Image = "rbxthumb://type=AvatarThumbnail&id=" .. tostring(lp.UserId) .. "&w=420&h=420"
    local pass
    pcall(function() pass = me:AddUIPassthrough("ZR_HomeAvatar", { Instance = avatar, Height = 225 }) end)
    task.spawn(function()
        local ok, image = pcall(function()
            return Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.AvatarThumbnail, Enum.ThumbnailSize.Size420x420)
        end)
        if ok and type(image) == "string" then pcall(function() avatar.Image = image end) end
        task.wait(0.1)
        local parent = avatar.Parent
        if parent and pass then
            local function fit()
                local x = parent.AbsoluteSize.X
                if x > 0 then pcall(function() pass:SetHeight(math.clamp(x, 180, 270)) end) end
            end
            fit()
            parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(fit)
        end
    end)
    local statsBox = Tabs.Home:AddRightGroupbox("Statistics", "blinds")
    local lTime = statsBox:AddLabel("Current time: <b>--:--</b>")
    local lFps = statsBox:AddLabel("FPS: <b>--</b>")
    local lPing = statsBox:AddLabel("Ping: <b>-- ms</b>")
    statsBox:AddDivider()
    local lPlayers = statsBox:AddLabel("Players in server: <b>--</b>")
    local lElapsed = statsBox:AddLabel("Elapsed time: <b>0 seconds</b>")
    local started, frames = tick(), 0
    local fc = RunService.RenderStepped:Connect(function() frames += 1 end)
    task.spawn(function()
        while not Library.Unloaded do
            task.wait(1)
            local fps = frames
            frames = 0
            pcall(function() lTime:SetText(string.format("Current time: <b>%s</b>", os.date("%H:%M"))) end)
            pcall(function() lFps:SetText("FPS: <b>" .. fps .. "</b>") end)
            pcall(function() lPing:SetText("Ping: <b>" .. math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue() + 0.5) .. " ms</b>") end)
            pcall(function() lPlayers:SetText("Players in server: <b>" .. #Players:GetPlayers() .. " / " .. Players.MaxPlayers .. "</b>") end)
            pcall(function() lElapsed:SetText("Elapsed time: <b>" .. math.floor(tick() - started) .. " seconds</b>") end)
        end
        fc:Disconnect()
    end)
end

local HitboxBox = Tabs.Main:AddLeftGroupbox("Hitbox Settings", "target")

-- ===================== Silent Aim =====================
do
    local RS = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local LP = Players.LocalPlayer
    local SA = { on = false, highlight = true }
    local hl, hlChar = nil, nil

    local function isEnemy(p)
        if p == LP then return false end
        local c = p.Character
        if not c or not c:FindFirstChild("HumanoidRootPart") then return false end
        local h = c:FindFirstChildOfClass("Humanoid")
        if not h or h.Health <= 0 then return false end
        if c:GetAttribute("DIED") then return false end
        local s = p:FindFirstChild("Status")
        local t = s and s:FindFirstChild("Team")
        if not t or t.Value == "Spectator" then return false end
        local ms = LP:FindFirstChild("Status")
        local mt = ms and ms:FindFirstChild("Team")
        if mt and t.Value == mt.Value then return false end
        return true
    end
    local function getPos(p)
        local r = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        return r and (r.Position + Vector3.new(0, 1.5, 0)) or nil
    end
    local function getNearest(fromPos)
        local cam = workspace.CurrentCamera
        if not cam then return nil end
        local look = cam.CFrame.LookVector
        local best, bestDist = nil, math.huge
        for _, p in ipairs(Players:GetPlayers()) do
            if isEnemy(p) then
                local pos = getPos(p)
                if pos then
                    local d = pos - fromPos
                    if d.Unit:Dot(look) >= 0 and d.Magnitude < bestDist then
                        bestDist = d.Magnitude
                        best = { player = p, position = pos }
                    end
                end
            end
        end
        return best
    end
    local function setHL(t)
        local c = t and t.player and t.player.Character or nil
        if c == hlChar and hl and hl.Parent then return end
        hlChar = c
        if hl then hl:Destroy() hl = nil end
        if c then
            hl = Instance.new("Highlight")
            hl.Adornee = c
            hl.FillColor = Color3.new(1, 0, 0)
            hl.FillTransparency = 0.5
            hl.OutlineColor = Color3.new(1, 0, 0)
            hl.OutlineTransparency = 0
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Parent = game:GetService("CoreGui")
        end
    end

    -- the shot's ray is bent toward the nearest enemy in front of you (only while the switch is on)
    local GF, origCast
    local function hook()
        if origCast then return true end
        local ok, mod = pcall(function() return require(RS:WaitForChild("Modules", 5):WaitForChild("GeneralFunctions", 5)) end)
        if not ok or type(mod) ~= "table" or type(mod.cast) ~= "function" then return false end
        GF, origCast = mod, mod.cast
        GF.cast = function(ray, filter)
            if SA.on and ray and ray.Origin and ray.Direction and ray.Direction.Magnitude >= 20 then
                local t = getNearest(ray.Origin)
                if t then
                    local dir = (t.position - ray.Origin).Unit * ray.Direction.Magnitude
                    return origCast(Ray.new(ray.Origin, dir), filter)
                end
            end
            return origCast(ray, filter)
        end
        return true
    end

    HitboxBox:AddToggle("SilentAim", {
        Text = "Silent Aim",
        Default = false,
        Tooltip = "Your shots go to the nearest enemy in front of you",
        Callback = function(v)
            SA.on = v
            if v and not hook() then
                SA.on = false
                Library:Notify({ Title = "Silent Aim", Description = "Couldn't find the game's shooting module.", Time = 4 })
            end
            if not v then setHL(nil) end
        end,
    }):AddKeyPicker("SilentAimKey", { Default = "None", SyncToggleState = true, Mode = "Toggle", Text = "Silent Aim" })
    HitboxBox:AddToggle("SilentAimHighlight", {
        Text = "Highlight Target",
        Default = true,
        Tooltip = "Red outline on who Silent Aim will hit",
        Callback = function(v) SA.highlight = v if not v then setHL(nil) end end,
    })
    HitboxBox:AddDivider()

    task.spawn(function()
        while not Library.Unloaded do
            task.wait(0.1)
            local cam = workspace.CurrentCamera
            local h = LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
            if SA.on and SA.highlight and cam and h and h.Health > 0 and LP.Character:FindFirstChild("HumanoidRootPart") then
                setHL(getNearest(cam.CFrame.Position))
            elseif hl then
                setHL(nil)
            end
        end
        setHL(nil)
    end)
    Library:OnUnload(function()
        SA.on = false
        if GF and origCast then GF.cast = origCast end
        setHL(nil)
    end)
end

local hitboxEnabled      = false
local noCollisionEnabled = false
local hitbox_original    = {}
local hitboxSize         = 21
local hitboxTransparency = 6
local hitboxTeamCheck    = "FFA"
local defaultBodyParts   = { "UpperTorso", "Head", "HumanoidRootPart" }
local Players            = game:GetService("Players")
local LocalPlayer        = Players.LocalPlayer

local function savedPart(player, part)
    if not hitbox_original[player] then hitbox_original[player] = {} end
    if not hitbox_original[player][part.Name] then
        hitbox_original[player][part.Name] = {
            CanCollide   = part.CanCollide,
            Transparency = part.Transparency,
            Size         = part.Size,
        }
    end
end

local function restoredPart(player)
    if not hitbox_original[player] then return end
    for partName, props in pairs(hitbox_original[player]) do
        local part = player.Character and player.Character:FindFirstChild(partName)
        if part and part:IsA("BasePart") then
            part.CanCollide   = props.CanCollide
            part.Transparency = props.Transparency
            part.Size         = props.Size
        end
    end
end

local function findClosestPart(player, partName)
    if not player.Character then return nil end
    for _, part in ipairs(player.Character:GetChildren()) do
        if part:IsA("BasePart") and part.Name:lower():match(partName:lower()) then
            return part
        end
    end
end

local function isHitboxEnemy(player)
    if hitboxTeamCheck == "FFA" or hitboxTeamCheck == "Everyone" then return true end
    return player.Team ~= LocalPlayer.Team
end

local function extendHitbox(player)
    for _, partName in ipairs(defaultBodyParts) do
        local part = player.Character and
            (player.Character:FindFirstChild(partName) or findClosestPart(player, partName))
        if part and part:IsA("BasePart") then
            savedPart(player, part)
            part.CanCollide   = not noCollisionEnabled
            part.Transparency = hitboxTransparency / 10
            part.Size         = Vector3.new(hitboxSize, hitboxSize, hitboxSize)
        end
    end
end

local function updateHitboxes()
    for _, v in ipairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
            if isHitboxEnemy(v) then extendHitbox(v) else restoredPart(v) end
        end
    end
end

local function checkDeadPlayers()
    for player in pairs(hitbox_original) do
        if not player.Parent or not player.Character
        or not player.Character:IsDescendantOf(game) then
            restoredPart(player)
            hitbox_original[player] = nil
        end
    end
end

local function onPlayerAdded(player)
    player.CharacterAdded:Connect(function()
        task.wait(0.1)
        if hitboxEnabled then updateHitboxes() end
    end)
    player.CharacterRemoving:Connect(function()
        restoredPart(player)
        hitbox_original[player] = nil
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end

HitboxBox:AddButton({
    Text    = "Initialize Hitbox (Click First)",
    Tooltip = "Must click before enabling hitbox",
    Func = function()
        coroutine.wrap(function()
            while true do
                if hitboxEnabled then
                    updateHitboxes()
                    checkDeadPlayers()
                end
                task.wait(0.1)
            end
        end)()
    end,
})

HitboxBox:AddToggle("HitboxEnabled", {
    Text    = "Enable Hitbox",
    Default = false,
    Callback = function(enabled)
        hitboxEnabled = enabled
        if not enabled then
            for _, player in ipairs(Players:GetPlayers()) do restoredPart(player) end
            hitbox_original = {}
        else
            updateHitboxes()
        end
    end,
})

HitboxBox:AddSlider("HitboxSize", {
    Text     = "Hitbox Size",
    Default  = 21,
    Min      = 1,
    Max      = 25,
    Rounding = 0,
    Callback = function(value)
        hitboxSize = value
        if hitboxEnabled then updateHitboxes() end
    end,
})

HitboxBox:AddSlider("HitboxTransparency", {
    Text     = "Hitbox Transparency",
    Default  = 6,
    Min      = 0,
    Max      = 10,
    Rounding = 0,
    Callback = function(value)
        hitboxTransparency = value
        if hitboxEnabled then updateHitboxes() end
    end,
})

HitboxBox:AddDropdown("HitboxTeamCheck", {
    Text    = "Team Check",
    Values  = { "FFA", "Team-Based", "Everyone" },
    Default = 1,
    Callback = function(value)
        hitboxTeamCheck = value
        if hitboxEnabled then updateHitboxes() end
    end,
})

HitboxBox:AddToggle("NoCollision", {
    Text    = "No Collision",
    Default = false,
    Callback = function(enabled)
        noCollisionEnabled = enabled
        coroutine.wrap(function()
            while noCollisionEnabled do
                if hitboxEnabled then updateHitboxes() end
                task.wait(0.01)
            end
            if hitboxEnabled then updateHitboxes() end
        end)()
    end,
})


local AutoFarmBox = Tabs.Main:AddRightGroupbox("AutoFarm", "crosshair")

AutoFarmBox:AddToggle("AutoFarm", {
    Text    = "AutoFarm",
    Tooltip = "Warning: May result in a ban",
    Risky   = true,
    Default = false,
    Callback = function(bool)
        getgenv().AutoFarm = bool
        local runConn, mouseDown = nil, false
        local plr = game.Players.LocalPlayer
        local camera = game.Workspace.CurrentCamera

        game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value =
            bool and "Infinite Ammo" or ""

        local function closestPlayer()
            local closest, closestDist = nil, math.huge
            for _, ep in pairs(game.Players:GetPlayers()) do
                if ep ~= plr and ep.TeamColor ~= plr.TeamColor and ep.Character then
                    local hrp = ep.Character:FindFirstChild("HumanoidRootPart")
                    local hum = ep.Character:FindFirstChild("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local dist = (plr.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                        if dist < closestDist then closestDist = dist; closest = ep end
                    end
                end
            end
            return closest
        end

        local function AutoFarmLoop()
            game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 12
            runConn = game:GetService("RunService").Stepped:Connect(function()
                if getgenv().AutoFarm then
                    local cp = closestPlayer()
                    if cp and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                        local eRoot = cp.Character.HumanoidRootPart
                        plr.Character.HumanoidRootPart.CFrame =
                            CFrame.new(eRoot.Position - eRoot.CFrame.LookVector * 2 + Vector3.new(0,2,0))
                        if cp.Character:FindFirstChild("Head") then
                            camera.CFrame = CFrame.new(camera.CFrame.Position, cp.Character.Head.Position)
                        end
                        if not mouseDown then mouse1press(); mouseDown = true end
                    else
                        if mouseDown then mouse1release(); mouseDown = false end
                    end
                else
                    if runConn then runConn:Disconnect() end
                    if mouseDown then mouse1release(); mouseDown = false end
                end
            end)
        end

        plr.CharacterAdded:Connect(function()
            wait(0.5)
            if getgenv().AutoFarm then AutoFarmLoop() end
        end)

        if bool then
            wait(0.5); AutoFarmLoop()
        else
            game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = ""
            getgenv().AutoFarm = false
            game:GetService("ReplicatedStorage").wkspc.TimeScale.Value = 1
            if runConn then runConn:Disconnect() end
            if mouseDown then mouse1release() end
        end
    end,
})


local TriggerBox = Tabs.Main:AddRightGroupbox("Triggerbot", "crosshair")

getgenv().triggerb   = false
local trigTeamCheck  = "Team-Based"
local trigDelay      = 0.2
local trigAlive      = true

TriggerBox:AddToggle("TriggerEnabled", {
    Text    = "Enable Triggerbot",
    Default = false,
    Callback = function(state) getgenv().triggerb = state end,
})

TriggerBox:AddDropdown("TriggerTeamCheck", {
    Text    = "Team Check Mode",
    Values  = { "FFA", "Team-Based", "Everyone" },
    Default = 2,
    Callback = function(v) trigTeamCheck = v end,
})

TriggerBox:AddSlider("TriggerDelay", {
    Text     = "Shot Delay",
    Default  = 2,
    Min      = 1,
    Max      = 10,
    Rounding = 0,
    Callback = function(v) trigDelay = v / 10 end,
})

local function isTriggerEnemy(tp)
    if trigTeamCheck == "FFA" then return true end
    if trigTeamCheck == "Everyone" then return tp ~= game.Players.LocalPlayer end
    return tp.Team ~= game.Players.LocalPlayer.Team
end

local function checkHealth()
    local char = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then hum.HealthChanged:Connect(function(hp) trigAlive = hp > 0 end) end
end
game.Players.LocalPlayer.CharacterAdded:Connect(checkHealth)
checkHealth()

game:GetService("RunService").RenderStepped:Connect(function()
    if getgenv().triggerb and trigAlive then
        local plr = game.Players.LocalPlayer
        local mouse = plr:GetMouse()
        local target = mouse.Target
        if target and target.Parent:FindFirstChild("Humanoid")
        and target.Parent.Name ~= plr.Name then
            local tp = game:GetService("Players"):FindFirstChild(target.Parent.Name)
            if tp and isTriggerEnemy(tp) then
                mouse1press(); wait(trigDelay); mouse1release()
            end
        end
    end
end)



local TPWalk = false
local TPWalkingConnection = nil
local currentSpeed = 1.0

local function getHum()
    local character = game:GetService("Players").LocalPlayer.Character
    if character then return character:FindFirstChildOfClass("Humanoid") end
end

local function getChar()
    return game:GetService("Players").LocalPlayer.Character
end

local function stopTPWalk()
    TPWalk = false
    if TPWalkingConnection then
        TPWalkingConnection:Disconnect()
        TPWalkingConnection = nil
    end
end

local function startTPWalk()
    if TPWalkingConnection then
        TPWalkingConnection:Disconnect()
        TPWalkingConnection = nil
    end
    TPWalk = true
    TPWalkingConnection = game:GetService("RunService").Stepped:Connect(function(_, deltaTime)
        if TPWalk then
            local humanoid = getHum()
            if humanoid and humanoid.MoveDirection.Magnitude > 0 then
                local character = getChar()
                if character then
                    character:TranslateBy(humanoid.MoveDirection * currentSpeed * deltaTime * 10)
                end
            end
        end
    end)
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if TPWalk then startTPWalk() end
end)

local flySpeed = 70
local flying = false
local plr = game.Players.LocalPlayer
local camera = workspace.CurrentCamera

local function startFly()
    local char = plr.Character
    if not char then return end
    local root = char:WaitForChild("HumanoidRootPart")
    local hum = char:WaitForChild("Humanoid")
    local bv = Instance.new("BodyVelocity", root)
    bv.MaxForce = Vector3.new(1e6, 1e6, 1e6)
    bv.Velocity = Vector3.new(0, 0, 0)
    local bg = Instance.new("BodyGyro", root)
    bg.MaxTorque = Vector3.new(1e6, 1e6, 1e6)
    bg.P = 10000
    hum:ChangeState(Enum.HumanoidStateType.Swimming)
    task.spawn(function()
        while flying and char and root do
            local moveDir = hum.MoveDirection
            bv.Velocity = moveDir.Magnitude > 0 and moveDir * flySpeed or Vector3.new(0, 0, 0)
            bg.CFrame = camera.CFrame
            hum:ChangeState(Enum.HumanoidStateType.Swimming)
            task.wait()
        end
        bv:Destroy()
        bg:Destroy()
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end)
end

game:GetService("Players").LocalPlayer.CharacterAdded:Connect(function()
    task.wait(0.5)
    if flying then startFly() end
end)



local PlayerBox = Tabs.Main:AddRightGroupbox("Player", "user")
PlayerBox:AddToggle("FlyEnabled", {
    Text    = "Fly",
    Tooltip = "Toggle fly mode",
    Default = false,
    Callback = function(enabled)
        flying = enabled
        if flying then startFly() end
    end,
})

PlayerBox:AddDivider()
local isNoClipEnabled = false

PlayerBox:AddToggle("SpeedBoostEnabled", {
    Text    = "Speed Boost",
    Tooltip = "Teleport-based speed boost",
    Default = false,
    Callback = function(enabled)
        if enabled then startTPWalk() else stopTPWalk() end
    end,
})

PlayerBox:AddSlider("SpeedBoostAmount", {
    Text     = "Speed Amount",
    Default  = 1,
    Min      = 1,
    Max      = 10,
    Rounding = 1,
    Callback = function(value)
        currentSpeed = value
    end,
})

PlayerBox:AddDivider()

PlayerBox:AddToggle("NoClip", {
    Text    = "Toggle NoClip",
    Tooltip = "Pass through walls",
    Default = false,
    Callback = function(enabled)
        isNoClipEnabled = enabled
        local function toggleNoClip()
            while isNoClipEnabled do
                local char = game.Players.LocalPlayer.Character
                if char then
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then part.CanCollide = false end
                    end
                end
                game:GetService("RunService").Stepped:Wait()
            end
            local char = game.Players.LocalPlayer.Character
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = true end
                end
            end
        end
        if isNoClipEnabled then spawn(toggleNoClip) end
    end,
})

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if isNoClipEnabled then
        spawn(function()
            while isNoClipEnabled do
                for _, part in pairs(character:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
                game:GetService("RunService").Stepped:Wait()
            end
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end)
    end
end)


local GunBox = Tabs.Guns:AddLeftGroupbox("Overpower Gun", "zap")

GunBox:AddToggle("InfiniteAmmo", {
    Text    = "Infinite Ammo",
    Default = false,
    Callback = function(v)
        game:GetService("ReplicatedStorage").wkspc.CurrentCurse.Value = v and "Infinite Ammo" or ""
    end,
})

local origVals = { FireRate={}, ReloadTime={}, EReloadTime={}, Auto={}, Spread={}, Recoil={} }

GunBox:AddToggle("FastReload", {
    Text    = "Fast Reload",
    Default = false,
    Callback = function(x)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetChildren()) do
            if v:FindFirstChild("ReloadTime") then
                if x then
                    origVals.ReloadTime[v] = origVals.ReloadTime[v] or v.ReloadTime.Value
                    v.ReloadTime.Value = 0.01
                else v.ReloadTime.Value = origVals.ReloadTime[v] or 0.8 end
            end
            if v:FindFirstChild("EReloadTime") then
                if x then
                    origVals.EReloadTime[v] = origVals.EReloadTime[v] or v.EReloadTime.Value
                    v.EReloadTime.Value = 0.01
                else v.EReloadTime.Value = origVals.EReloadTime[v] or 0.8 end
            end
        end
    end,
})

GunBox:AddToggle("FastFireRate", {
    Text    = "Fast Fire Rate",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "FireRate" or v.Name == "BFireRate" then
                if state then
                    origVals.FireRate[v] = origVals.FireRate[v] or v.Value
                    v.Value = 0.02
                else v.Value = origVals.FireRate[v] or 0.8 end
            end
        end
    end,
})

GunBox:AddToggle("AlwaysAuto", {
    Text    = "Always Auto",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game.ReplicatedStorage.Weapons:GetDescendants()) do
            if v.Name == "Auto" or v.Name == "AutoFire" or v.Name == "Automatic"
            or v.Name == "AutoShoot" or v.Name == "AutoGun" then
                if state then
                    origVals.Auto[v] = origVals.Auto[v] ~= nil and origVals.Auto[v] or v.Value
                    v.Value = true
                else v.Value = origVals.Auto[v] or false end
            end
        end
    end,
})

GunBox:AddToggle("NoSpread", {
    Text    = "No Spread",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
            if v.Name == "MaxSpread" or v.Name == "Spread" or v.Name == "SpreadControl" then
                if state then
                    origVals.Spread[v] = origVals.Spread[v] or v.Value
                    v.Value = 0
                else v.Value = origVals.Spread[v] or 1 end
            end
        end
    end,
})

GunBox:AddToggle("NoRecoil", {
    Text    = "No Recoil",
    Default = false,
    Callback = function(state)
        for _, v in pairs(game:GetService("ReplicatedStorage").Weapons:GetDescendants()) do
            if v.Name == "RecoilControl" or v.Name == "Recoil" then
                if state then
                    origVals.Recoil[v] = origVals.Recoil[v] or v.Value
                    v.Value = 0
                else v.Value = origVals.Recoil[v] or 1 end
            end
        end
    end,
})


local EspBox    = Tabs.Visuals:AddLeftGroupbox("ESP v1", "eye")
local EspOptBox = Tabs.Visuals:AddRightGroupbox("ESP Options", "layers")

local aj = loadstring(game:HttpGet("https://rawscript.vercel.app/api/raw/esp_1"))()

EspBox:AddToggle("EspEnabled", {
    Text = "Enable ESP", Default = false,
    Callback = function(K) aj:Toggle(K); aj.Players = K end,
})
EspBox:AddToggle("EspTracers", {
    Text = "Tracers", Default = false,
    Callback = function(K) aj.Tracers = K end,
})
EspBox:AddToggle("EspNames", {
    Text = "Names", Default = false,
    Callback = function(K) aj.Names = K end,
})
EspBox:AddToggle("EspBoxes", {
    Text = "Boxes", Default = false,
    Callback = function(K) aj.Boxes = K end,
})
EspBox:AddToggle("EspTeamColor", {
    Text = "Team Color", Default = false,
    Callback = function(L) aj.TeamColor = L end,
})
EspBox:AddToggle("EspTeammates", {
    Text = "Show Teammates", Default = false,
    Callback = function(L) aj.TeamMates = L end,
})
EspBox:AddLabel("ESP Color"):AddColorPicker("EspColor", {
    Default  = Color3.fromRGB(255, 255, 255),
    Callback = function(P) aj.Color = P end,
})

local esp_data  = {}
local esp_title = "dontask"

local function makeESP(parent, label)
    local bb = Instance.new("BillboardGui")
    local tl = Instance.new("TextLabel")
    bb.Name = esp_title; bb.Parent = parent
    bb.AlwaysOnTop = true
    bb.Size = UDim2.new(0,50,0,50)
    bb.StudsOffset = Vector3.new(0,2,0)
    tl.Parent = bb
    tl.BackgroundTransparency = 1
    tl.Size = UDim2.new(1,0,1,0)
    tl.Text = label
    tl.TextColor3 = Color3.new(1,0,0)
    tl.TextScaled = false
    return bb
end

local function applyESP(obj, label)
    if obj:IsA("TouchTransmitter") then
        local parent = obj.Parent
        if not parent:FindFirstChild(esp_title) then
            esp_data[parent] = makeESP(parent, label)
        end
    end
end

local function toggleESP(enable, name, label)
    if enable then
        for _, v in ipairs(game.Workspace:GetDescendants()) do
            if v:IsA("TouchTransmitter") and v.Parent.Name == name then
                applyESP(v, label)
            end
        end
        game.Workspace.DescendantAdded:Connect(function(d)
            if d:IsA("TouchTransmitter") and d.Parent.Name == name then
                applyESP(d, label)
            end
        end)
    else
        for parent, e in pairs(esp_data) do
            if parent and e then e:Destroy(); esp_data[parent] = nil end
        end
    end
end

EspOptBox:AddToggle("AmmoESP", {
    Text = "Ammo Box ESP", Default = false,
    Callback = function(e) toggleESP(e, "DeadAmmo", "Ammo Box") end,
})
EspOptBox:AddToggle("HPESP", {
    Text = "HP Jug ESP", Default = false,
    Callback = function(e) toggleESP(e, "DeadHP", "HP Jar") end,
})


local ArmBox    = Tabs.Skins:AddLeftGroupbox("Arm Skins", "palette")
local GunSkinBox = Tabs.Skins:AddRightGroupbox("Gun Skins", "palette")

local armMat = "Plastic"
local armCol = Color3.fromRGB(50,50,50)
local armOn  = false

ArmBox:AddDropdown("ArmMaterial", {
    Text = "Arm Material",
    Values = {"Plastic","ForceField","Wood","Grass"},
    Default = 1,
    Callback = function(v) armMat = v end,
})
ArmBox:AddLabel("Arm Color"):AddColorPicker("ArmColor", {
    Default = Color3.fromRGB(50,50,50),
    Callback = function(c) armCol = c end,
})
ArmBox:AddToggle("ArmCharms", {
    Text = "Arm Charms", Default = false,
    Callback = function(L)
        armOn = L
        if armOn then
            spawn(function()
                while true do
                    wait(0.01)
                    if not armOn then break end
                    local arms = workspace.Camera:FindFirstChild("Arms")
                    if arms then
                        for _, O in pairs(arms:GetDescendants()) do
                            if O.Name == "Right Arm" or O.Name == "Left Arm" then
                                if O:IsA("BasePart") then
                                    O.Material = Enum.Material[armMat]
                                    O.Color = armCol
                                end
                            elseif O:IsA("SpecialMesh") and O.TextureId == "" then
                                O.TextureId = "rbxassetid://0"
                                O.VertexColor = Vector3.new(armCol.R, armCol.G, armCol.B)
                            elseif O.Name == "L" or O.Name == "R" then
                                O:Destroy()
                            end
                        end
                    end
                end
            end)
        end
    end,
})

local gunMat = "Plastic"
local gunCol = Color3.fromRGB(50,50,50)
local gunOn  = false

GunSkinBox:AddDropdown("GunMaterial", {
    Text = "Gun Material",
    Values = {"Plastic","ForceField","Wood","Grass"},
    Default = 1,
    Callback = function(v) gunMat = v end,
})
GunSkinBox:AddLabel("Gun Color"):AddColorPicker("GunColor", {
    Default = Color3.fromRGB(50,50,50),
    Callback = function(c) gunCol = c end,
})
GunSkinBox:AddToggle("GunCharms", {
    Text = "Gun Charms", Default = false,
    Callback = function(L)
        gunOn = L
        if gunOn then
            spawn(function()
                while true do
                    wait(0.01)
                    if not gunOn then break end
                    if workspace.Camera:FindFirstChild("Arms") then
                        for _, O in pairs(workspace.Camera.Arms:GetDescendants()) do
                            if O:IsA("MeshPart") then
                                O.Material = Enum.Material[gunMat]
                                O.Color = gunCol
                            end
                        end
                    end
                end
            end)
        end
    end,
})

GunSkinBox:AddDivider()
GunSkinBox:AddLabel("Rainbow Gun")

local rbV1  = false
local rbV2  = false
local rbH1  = 1
local rbH2  = 0
local function zigzag(X) return math.acos(math.cos(X * math.pi)) / math.pi end

GunSkinBox:AddToggle("RainbowV1", {
    Text = "Rainbow Gun v1", Default = false,
    Callback = function(s) rbV1 = s end,
})
GunSkinBox:AddToggle("RainbowV2", {
    Text = "Rainbow Gun v2 (Fast)", Default = false,
    Callback = function(s) rbV2 = s end,
})

game:GetService("RunService").RenderStepped:Connect(function()
    if workspace.Camera:FindFirstChild("Arms") then
        if rbV1 then
            for _, v in pairs(workspace.Camera.Arms:GetDescendants()) do
                if v.ClassName == "MeshPart" then
                    v.Color = Color3.fromHSV(zigzag(rbH1), 1, 1)
                end
            end
            rbH1 = rbH1 + 0.0001
        elseif rbV2 then
            rbH2 = rbH2 + 0.1
            if rbH2 >= 1 then rbH2 = rbH2 % 1 end
            for _, v in pairs(workspace.Camera.Arms:GetDescendants()) do
                if v.ClassName == "MeshPart" then
                    v.Color = Color3.fromHSV(rbH2, 1, 1)
                end
            end
        end
    end
end)


local ExtraBox = Tabs.Extra:AddLeftGroupbox("Misc", "star")

ExtraBox:AddToggle("ScreenMess", {
    Text = "Mess Up Screen", Default = false,
    Callback = function(state)
        if state then
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("ParticleEmitter") then
                    v.Parent = game.Players.LocalPlayer.Character["Particle Area"]
                end
            end
        else
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("ParticleEmitter") then v.Parent = workspace end
            end
        end
    end,
})

local orig_stats = {}
ExtraBox:AddToggle("MaxLevel", {
    Text = "Max Level (Visual)", Default = false,
    Callback = function(bool)
        local stats = LocalPlayer.CareerStatsCache
        if bool then
            orig_stats.Score = stats.Score.Value
            orig_stats.Kills = stats.Kills.Value
            stats.Score.Value = 1e18
            stats.Kills.Value = 1e14
        else
            if orig_stats.Score then
                stats.Score.Value = orig_stats.Score
                stats.Kills.Value = orig_stats.Kills
            end
        end
    end,
})

local nameRunLoop = false
ExtraBox:AddToggle("ChangeName", {
    Text = "Change Name (Visual)", Default = false,
    Callback = function(enabled)
        nameRunLoop = enabled
        local function applyNames()
            local gui = LocalPlayer.PlayerGui
            pcall(function()
                gui.Menew_Main.Container.PlrName.Text  = "AdvanceChan UwU"
                gui.Menew_Main.Container.PlrName2.Text = "AdvanceChan UwU"
                for i = 1, 6 do
                    workspace.KillFeed[tostring(i)].Killer.Value = "AdvanceFalling Team"
                end
                gui.GUI.Winner.Visible = false
                gui.GUI_Scorecard.Scorecard.PlayerCard.Username.Text = "AdvanceFalling Team"
            end)
        end
        if enabled then
            spawn(function()
                while nameRunLoop do applyNames(); wait(0.2) end
            end)
        end
    end,
})

ExtraBox:AddDivider()
ExtraBox:AddLabel("Chat Badges")

local badges = { "IsChad", "VIP", "OldVIP", "Romin", "IsAdmin" }
for _, badge in ipairs(badges) do
    ExtraBox:AddToggle("Badge_" .. badge, {
        Text = badge, Default = false,
        Callback = function(x)
            local plr = game.Players.LocalPlayer
            if plr:FindFirstChild(badge) then plr[badge]:Destroy(); return end
            if x then
                local v = Instance.new("IntValue", plr)
                v.Name = badge
            end
        end,
    })
end


local PerfBox   = Tabs.Settings:AddLeftGroupbox("Performance", "cpu")
local ServerBox = Tabs.Settings:AddRightGroupbox("Server", "server")

local origMats    = {}
local origDecals  = {}
local origLighting = {
    GlobalShadows = game.Lighting.GlobalShadows,
    FogEnd        = game.Lighting.FogEnd,
    Brightness    = game.Lighting.Brightness,
}
local origTerrain = {
    WaterWaveSize     = game.Workspace.Terrain.WaterWaveSize,
    WaterWaveSpeed    = game.Workspace.Terrain.WaterWaveSpeed,
    WaterReflectance  = game.Workspace.Terrain.WaterReflectance,
    WaterTransparency = game.Workspace.Terrain.WaterTransparency,
}
local origEffects = {}

PerfBox:AddToggle("AntiLag", {
    Text = "Anti Lag", Default = false,
    Callback = function(state)
        if state then
            for _, O in pairs(workspace:GetDescendants()) do
                if O:IsA("BasePart") and not O.Parent:FindFirstChild("Humanoid") then
                    origMats[O] = O.Material
                    O.Material = Enum.Material.SmoothPlastic
                end
            end
        else
            for O, mat in pairs(origMats) do
                if O and O:IsA("BasePart") then O.Material = mat end
            end
            origMats = {}
        end
    end,
})

PerfBox:AddToggle("FPSBoost", {
    Text = "FPS Boost", Default = false,
    Callback = function(state)
        local l = game.Lighting
        local t = workspace.Terrain
        if state then
            t.WaterWaveSize = 0; t.WaterWaveSpeed = 0
            t.WaterReflectance = 0; t.WaterTransparency = 0
            l.GlobalShadows = false; l.FogEnd = 9e9; l.Brightness = 0
            settings().Rendering.QualityLevel = "Level01"
            for _, v in pairs(game:GetDescendants()) do
                if v:IsA("BasePart") or v:IsA("MeshPart") then
                    origMats[v] = v.Material
                    v.Material = "Plastic"; v.Reflectance = 0
                elseif v:IsA("Decal") or v:IsA("Texture") then
                    table.insert(origDecals, v); v.Transparency = 1
                elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then
                    v.Lifetime = NumberRange.new(0)
                elseif v:IsA("Fire") or v:IsA("SpotLight") or v:IsA("Smoke") then
                    v.Enabled = false
                end
            end
            for _, e in pairs(l:GetChildren()) do
                if e:IsA("BlurEffect") or e:IsA("SunRaysEffect")
                or e:IsA("ColorCorrectionEffect") or e:IsA("BloomEffect")
                or e:IsA("DepthOfFieldEffect") then
                    origEffects[e] = e.Enabled; e.Enabled = false
                end
            end
        else
            t.WaterWaveSize     = origTerrain.WaterWaveSize
            t.WaterWaveSpeed    = origTerrain.WaterWaveSpeed
            t.WaterReflectance  = origTerrain.WaterReflectance
            t.WaterTransparency = origTerrain.WaterTransparency
            l.GlobalShadows     = origLighting.GlobalShadows
            l.FogEnd            = origLighting.FogEnd
            l.Brightness        = origLighting.Brightness
            settings().Rendering.QualityLevel = "Automatic"
            for v, mat in pairs(origMats) do
                if v and v:IsA("BasePart") then v.Material = mat end
            end
            origMats = {}
            for e, en in pairs(origEffects) do if e then e.Enabled = en end end
            origEffects = {}
            for _, v in pairs(origDecals) do
                if v and v.Parent then v.Transparency = 0 end
            end
            origDecals = {}
        end
    end,
})

local fbEnabled = false
PerfBox:AddToggle("FullBright", {
    Text = "Full Bright", Default = false,
    Callback = function(enabled)
        fbEnabled = enabled
        local Light = game:GetService("Lighting")
        local function doFB()
            if fbEnabled then
                Light.Ambient = Color3.new(1,1,1)
                Light.ColorShift_Bottom = Color3.new(1,1,1)
                Light.ColorShift_Top = Color3.new(1,1,1)
            else
                Light.Ambient = Color3.new(0.5,0.5,0.5)
                Light.ColorShift_Bottom = Color3.new(0,0,0)
                Light.ColorShift_Top = Color3.new(0,0,0)
            end
        end
        doFB()
        Light.LightingChanged:Connect(doFB)
    end,
})

ServerBox:AddButton({
    Text = "Server Hop",
    Func = function()
        local placeID = game.PlaceId
        local allIDs = {}
        local foundAnything = ""
        local actualHour = os.date("!*t").hour
        local file = pcall(function()
            allIDs = game:GetService("HttpService"):JSONDecode(readfile("NotSameServers.json"))
        end)
        if not file then
            table.insert(allIDs, actualHour)
            writefile("NotSameServers.json", game:GetService("HttpService"):JSONEncode(allIDs))
        end
        local function teleportReturner()
            local url = "https://games.roblox.com/v1/games/" .. placeID ..
                "/servers/Public?sortOrder=Asc&limit=100" ..
                (foundAnything ~= "" and "&cursor=" .. foundAnything or "")
            local site = game.HttpService:JSONDecode(game:HttpGet(url))
            if site.nextPageCursor then foundAnything = site.nextPageCursor end
            for _, v in pairs(site.data) do
                local possible = true
                local serverID = tostring(v.id)
                local num = 0
                if tonumber(v.maxPlayers) > tonumber(v.playing) then
                    for _, existing in pairs(allIDs) do
                        if num ~= 0 then
                            if serverID == tostring(existing) then possible = false end
                        else
                            if tonumber(actualHour) ~= tonumber(existing) then
                                pcall(function()
                                    delfile("NotSameServers.json")
                                    allIDs = {}
                                    table.insert(allIDs, actualHour)
                                end)
                            end
                        end
                        num = num + 1
                    end
                    if possible then
                        table.insert(allIDs, serverID)
                        wait()
                        pcall(function()
                            writefile("NotSameServers.json", game:GetService("HttpService"):JSONEncode(allIDs))
                            game:GetService("TeleportService"):TeleportToPlaceInstance(
                                placeID, serverID, game.Players.LocalPlayer)
                        end)
                        wait(4)
                    end
                end
            end
        end
        while wait() do
            pcall(teleportReturner)
            if foundAnything ~= "" then pcall(teleportReturner) end
        end
    end,
})

ServerBox:AddButton({
    Text = "Rejoin Server",
    Func = function()
        game:GetService("TeleportService"):Teleport(game.PlaceId, game.Players.LocalPlayer)
    end,
})


local KeybindBox = Tabs.Settings:AddLeftGroupbox("Keybinds", "keyboard")
KeybindBox:AddLabel("Menu Keybind"):AddKeyPicker("MenuKeybind", {
    Default = "RightShift",
    NoUI    = true,
    Text    = "Toggle Menu",
})
Library.ToggleKeybind = Options.MenuKeybind


local CreditsBox = Tabs.Credits:AddLeftGroupbox("Creadits", "user")
CreditsBox:AddLabel("Made by tung zo1os", true)

CreditsBox:AddButton({
    Text = "Copy Discord Link",
    Func = function()
        setclipboard("https://discord.gg/TCuMcKy9j4")
        Library:Notify({ Title = "Copied!", Description = "Discord link copied.", Time = 3 })
    end,
})


local UIMenuBox = Tabs.UISettings:AddLeftGroupbox("Menu", "settings")

UIMenuBox:AddToggle("ShowCustomCursor", {
    Text = "Custom Cursor", Default = true,
    Callback = function(v) Library.ShowCustomCursor = v end,
})

UIMenuBox:AddDropdown("NotificationSide", {
    Values = { "Left", "Right" }, Default = "Right",
    Text = "Notification Side",
    Callback = function(v) Library:SetNotifySide(v) end,
})

UIMenuBox:AddButton({
    Text = "Unload Script", Risky = true,
    Func = function() Library:Unload() end,
})

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ "MenuKeybind" })
ThemeManager:SetFolder("AdvanceTech_Arsenal")
SaveManager:SetFolder("AdvanceTech_Arsenal/Arsenal")
SaveManager:BuildConfigSection(Tabs.UISettings)
ThemeManager:ApplyTheme("Jester")
ThemeManager:ApplyToTab(Tabs.UISettings)
SaveManager:LoadAutoloadConfig()