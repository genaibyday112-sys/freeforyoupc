-- ====================================================================
-- Day Hub v2.2 | Smooth + AFK Edition (standalone, run as-is)
-- ====================================================================
local Players      = game:GetService("Players")
local Workspace    = game:GetService("Workspace")
local RunService   = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local CoreGui      = game:GetService("CoreGui")
local VirtualUser  = game:GetService("VirtualUser")

local LP = Players.LocalPlayer
local PlayerGui = LP:WaitForChild("PlayerGui")

local old = PlayerGui:FindFirstChild("DayHub_StealthBlack")
    or (gethui and gethui():FindFirstChild("DayHub_StealthBlack"))
if old then old:Destroy() end

local THEME = {
    BG_MAIN=Color3.fromRGB(10,10,12),   BG_PANEL=Color3.fromRGB(16,16,20),
    BG_ELEMENT=Color3.fromRGB(22,22,28),BG_HOVER=Color3.fromRGB(30,30,38),
    BG_ACTIVE=Color3.fromRGB(42,42,52), BORDER=Color3.fromRGB(32,32,38),
    BORDER_ACTIVE=Color3.fromRGB(75,75,90),
    TEXT_TITLE=Color3.fromRGB(245,245,250), TEXT_NORMAL=Color3.fromRGB(185,185,195),
    TEXT_MUTED=Color3.fromRGB(115,115,125), ACCENT=Color3.fromRGB(255,255,255),
    DANGER=Color3.fromRGB(225,65,65), SAFE=Color3.fromRGB(55,175,95),
}

-- ---------------- SCHEDULER (1 loop) ----------------
local Sched = { tasks={}, conn=nil }
local function schedAdd(id, fn)
    Sched.tasks[id] = fn
    if not Sched.conn then
        Sched.conn = RunService.Heartbeat:Connect(function(dt)
            for _, t in pairs(Sched.tasks) do t(dt) end
        end)
    end
end
local function schedRemove(id)
    Sched.tasks[id] = nil
    if next(Sched.tasks) == nil and Sched.conn then
        Sched.conn:Disconnect(); Sched.conn = nil
    end
end

local function getRoot()
    local c = LP.Character
    return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = LP.Character
    return c and c:FindFirstChildOfClass("Humanoid")
end

-- ---------------- UI SHELL ----------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "DayHub_StealthBlack"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
if gethui then ScreenGui.Parent = gethui()
elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui); ScreenGui.Parent = CoreGui
else
    local ok = pcall(function() ScreenGui.Parent = CoreGui end)
    if not ok or not ScreenGui.Parent then ScreenGui.Parent = PlayerGui end
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0,560,0,360)
Main.Position = UDim2.new(0.5,-280,0.5,-180)
Main.BackgroundColor3 = THEME.BG_MAIN
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", Main).Color = THEME.BORDER

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1,0,0,38)
TitleBar.BackgroundColor3 = THEME.BG_PANEL
TitleBar.BorderSizePixel = 0
Instance.new("UIStroke", TitleBar).Color = THEME.BORDER

local TitleLbl = Instance.new("TextLabel", TitleBar)
TitleLbl.Size = UDim2.new(1,-120,1,0)
TitleLbl.Position = UDim2.new(0,14,0,0)
TitleLbl.BackgroundTransparency = 1
TitleLbl.Font = Enum.Font.GothamBold
TitleLbl.Text = "DAY HUB  |  SMOOTH + AFK"
TitleLbl.TextColor3 = THEME.TEXT_TITLE
TitleLbl.TextSize = 13
TitleLbl.TextXAlignment = Enum.TextXAlignment.Left

local MinBtn = Instance.new("TextButton", TitleBar)
MinBtn.Size = UDim2.new(0,26,0,26)
MinBtn.Position = UDim2.new(1,-62,0.5,-13)
MinBtn.BackgroundColor3 = THEME.BG_ELEMENT
MinBtn.Text = "—"
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextColor3 = THEME.TEXT_NORMAL
MinBtn.TextSize = 12
MinBtn.BorderSizePixel = 0
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0,5)

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0,26,0,26)
CloseBtn.Position = UDim2.new(1,-32,0.5,-13)
CloseBtn.BackgroundColor3 = THEME.BG_ELEMENT
CloseBtn.Text = "✕"
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextColor3 = THEME.TEXT_NORMAL
CloseBtn.TextSize = 12
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0,5)

local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(i)
    if i.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true; dragStart = i.Position; startPos = Main.Position
        i.Changed:Connect(function()
            if i.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
UIS.InputChanged:Connect(function(i)
    if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
        local d = i.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+d.X,
                                  startPos.Y.Scale, startPos.Y.Offset+d.Y)
    end
end)

local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(0,135,1,-38)
TabBar.Position = UDim2.new(0,0,0,38)
TabBar.BackgroundColor3 = THEME.BG_PANEL
TabBar.BorderSizePixel = 0
Instance.new("UIStroke", TabBar).Color = THEME.BORDER

local TabContainer = Instance.new("Frame", TabBar)
TabContainer.Size = UDim2.new(1,-12,1,-12)
TabContainer.Position = UDim2.new(0,6,0,6)
TabContainer.BackgroundTransparency = 1
Instance.new("UIListLayout", TabContainer).Padding = UDim.new(0,4)

local Content = Instance.new("Frame", Main)
Content.Size = UDim2.new(1,-143,1,-46)
Content.Position = UDim2.new(0,139,0,42)
Content.BackgroundTransparency = 1

local tabs, activeTab = {}, nil
local function createTab(name, icon)
    local page = Instance.new("ScrollingFrame", Content)
    page.Size = UDim2.new(1,-4,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = THEME.BORDER_ACTIVE
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    Instance.new("UIListLayout", page).Padding = UDim.new(0,8)

    local btn = Instance.new("TextButton", TabContainer)
    btn.Size = UDim2.new(1,0,0,32)
    btn.BackgroundColor3 = THEME.BG_ELEMENT
    btn.BorderSizePixel = 0
    btn.Text = (icon and (icon.."  ") or "")..name
    btn.Font = Enum.Font.GothamMedium
    btn.TextColor3 = THEME.TEXT_MUTED
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Left
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local function activate()
        for _, t in pairs(tabs) do
            t.Page.Visible = false
            t.Btn.BackgroundColor3 = THEME.BG_ELEMENT
            t.Btn.TextColor3 = THEME.TEXT_MUTED
        end
        page.Visible = true
        activeTab = name
        btn.BackgroundColor3 = THEME.BG_ACTIVE
        btn.TextColor3 = THEME.TEXT_TITLE
    end
    btn.MouseButton1Click:Connect(activate)
    tabs[name] = { Page=page, Btn=btn }
    if not activeTab then activate() end
    return page
end

local function createSwitch(parent, titleText, subtitleText, defaultState, callback, activeColor)
    local state = defaultState or false
    local colorOn = activeColor or THEME.SAFE
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0, subtitleText and 46 or 38)
    btn.BackgroundColor3 = THEME.BG_ELEMENT
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = ""
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,6)

    local t = Instance.new("TextLabel", btn)
    t.Size = UDim2.new(1,-65,0, subtitleText and 20 or 38)
    t.Position = UDim2.new(0,12,0, subtitleText and 5 or 0)
    t.BackgroundTransparency = 1
    t.Font = Enum.Font.GothamMedium
    t.Text = titleText
    t.TextColor3 = THEME.TEXT_TITLE
    t.TextSize = 12
    t.TextXAlignment = Enum.TextXAlignment.Left
    if subtitleText then
        local s = Instance.new("TextLabel", btn)
        s.Size = UDim2.new(1,-65,0,16)
        s.Position = UDim2.new(0,12,0,24)
        s.BackgroundTransparency = 1
        s.Font = Enum.Font.Gotham
        s.Text = subtitleText
        s.TextColor3 = THEME.TEXT_MUTED
        s.TextSize = 10
        s.TextXAlignment = Enum.TextXAlignment.Left
    end
    local pill = Instance.new("Frame", btn)
    pill.Size = UDim2.new(0,44,0,22)
    pill.Position = UDim2.new(1,-54,0.5,-11)
    pill.BackgroundColor3 = state and colorOn or THEME.BG_PANEL
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
    local dot = Instance.new("Frame", pill)
    dot.Size = UDim2.new(0,16,0,16)
    dot.Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    dot.BackgroundColor3 = THEME.TEXT_TITLE
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local function paint(s2)
        state = s2
        TweenService:Create(pill, TweenInfo.new(0.16), {BackgroundColor3 = state and colorOn or THEME.BG_PANEL}):Play()
        TweenService:Create(dot, TweenInfo.new(0.16), {
            Position = state and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
        }):Play()
    end
    btn.MouseButton1Click:Connect(function()
        paint(not state)
        if callback then callback(state) end
    end)
    return btn
end

local function createSlider(parent, labelText, minV, maxV, defaultV, callback)
    local c = Instance.new("Frame", parent)
    c.Size = UDim2.new(1,0,0,52)
    c.BackgroundColor3 = THEME.BG_ELEMENT
    c.BorderSizePixel = 0
    Instance.new("UICorner", c).CornerRadius = UDim.new(0,6)

    local lbl = Instance.new("TextLabel", c)
    lbl.Size = UDim2.new(1,-70,0,24)
    lbl.Position = UDim2.new(0,12,0,4)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamMedium
    lbl.Text = labelText
    lbl.TextColor3 = THEME.TEXT_TITLE
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local val = Instance.new("TextLabel", c)
    val.Size = UDim2.new(0,55,0,24)
    val.Position = UDim2.new(1,-65,0,4)
    val.BackgroundTransparency = 1
    val.Font = Enum.Font.GothamBold
    val.Text = tostring(defaultV)
    val.TextColor3 = THEME.ACCENT
    val.TextSize = 12
    val.TextXAlignment = Enum.TextXAlignment.Right

    local track = Instance.new("TextButton", c)
    track.Size = UDim2.new(1,-24,0,8)
    track.Position = UDim2.new(0,12,0,32)
    track.BackgroundColor3 = THEME.BG_PANEL
    track.BorderSizePixel = 0
    track.Text = ""
    track.AutoButtonColor = false
    Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

    local fill = Instance.new("Frame", track)
    fill.Size = UDim2.new((defaultV-minV)/(maxV-minV),0,1,0)
    fill.BackgroundColor3 = THEME.ACCENT
    fill.BorderSizePixel = 0
    Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

    local sliding = false
    local function update(input)
        local x = math.clamp((input.Position.X - track.AbsolutePosition.X)/track.AbsoluteSize.X, 0, 1)
        local v = math.floor(minV + (maxV-minV)*x)
        fill.Size = UDim2.new((v-minV)/(maxV-minV),0,1,0)
        val.Text = tostring(v)
        if callback then callback(v) end
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = true; update(i) end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
    end)
    UIS.InputChanged:Connect(function(i)
        if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then update(i) end
    end)
end

local function createButton(parent, text, color, cb)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1,0,0,34)
    b.BackgroundColor3 = color or THEME.BG_ELEMENT
    b.BorderSizePixel = 0
    b.Font = Enum.Font.GothamMedium
    b.Text = text
    b.TextColor3 = THEME.TEXT_TITLE
    b.TextSize = 12
    Instance.new("UICorner", b).CornerRadius = UDim.new(0,6)
    b.MouseButton1Click:Connect(cb)
    return b
end

-- ====================================================================
-- STATE
-- ====================================================================
local State = {
    fly={on=false,speed=50,gyro=nil,vel=nil},
    noclip={on=false,conn=nil},
    walk={on=false,value=16},
    esp={on=false,highlights={}},
    boost={on=false,conn=nil,disabled={}},
    antiAfk={on=false,conn=nil},
    afk={on=false,overlay=nil,prevAntiAfk=false},
}

-- ====================================================================
-- FLY
-- ====================================================================
local function flyStop()
    local f = State.fly
    f.on = false
    schedRemove("fly")
    if f.gyro then f.gyro:Destroy(); f.gyro = nil end
    if f.vel  then f.vel:Destroy();  f.vel  = nil end
    local h = getHum()
    if h then h.PlatformStand = false end
end

local function flyStart()
    local root = getRoot()
    if not root then return end
    local f = State.fly
    local cam = Workspace.CurrentCamera
    f.on = true
    f.gyro = Instance.new("BodyGyro")
    f.gyro.P = 9e4
    f.gyro.MaxTorque = Vector3.new(9e9,9e9,9e9)
    f.gyro.CFrame = root.CFrame
    f.gyro.Parent = root
    f.vel = Instance.new("BodyVelocity")
    f.vel.Velocity = Vector3.zero
    f.vel.MaxForce = Vector3.new(9e9,9e9,9e9)
    f.vel.Parent = root

    schedAdd("fly", function()
        if not f.on then return end
        local r = getRoot(); if not r then return end
        local d = Vector3.zero
        if UIS:IsKeyDown(Enum.KeyCode.W)         then d += cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S)         then d -= cam.CFrame.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A)         then d -= cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D)         then d += cam.CFrame.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space)     then d += Vector3.yAxis end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d -= Vector3.yAxis end
        f.vel.Velocity = d.Magnitude > 0 and d.Unit * f.speed or Vector3.zero
        f.gyro.CFrame  = cam.CFrame
    end)
end

local function flySet(on) if on then flyStart() else flyStop() end end

-- ====================================================================
-- NOCLIP (Stepped — ก่อน physics)
-- ====================================================================
local function noclipStop()
    local n = State.noclip
    n.on = false
    if n.conn then n.conn:Disconnect(); n.conn = nil end
    local c = LP.Character
    if c then
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = true end
        end
    end
end

local function noclipStart()
    local n = State.noclip
    n.on = true
    n.conn = RunService.Stepped:Connect(function()
        local c = LP.Character; if not c then return end
        for _, p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end)
end

local function noclipSet(on) if on then noclipStart() else noclipStop() end end

-- ====================================================================
-- WALKSPEED LOCK
-- ====================================================================
local function walkSet(on)
    local w = State.walk
    w.on = on
    if on then
        schedAdd("walk", function()
            local h = getHum()
            if h and h.WalkSpeed ~= w.value then h.WalkSpeed = w.value end
        end)
    else
        schedRemove("walk")
        local h = getHum()
        if h then h.WalkSpeed = 16 end
    end
end

-- ====================================================================
-- ESP
-- ====================================================================
local function applyESP(plr)
    local e = State.esp
    if not e.on then return end
    if plr == LP then return end
    if not plr.Character then return end
    if e.highlights[plr] then return end
    local hl = Instance.new("Highlight", ScreenGui)
    hl.Adornee = plr.Character
    hl.FillColor = Color3.fromRGB(0,255,0)
    hl.FillTransparency = 0.5
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    e.highlights[plr] = hl
end

local function clearESP()
    for p, hl in pairs(State.esp.highlights) do hl:Destroy() end
    State.esp.highlights = {}
end

local function espSet(on)
    State.esp.on = on
    if on then
        for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
        schedAdd("esp", function()
            for p, hl in pairs(State.esp.highlights) do
                if not p.Character or not p.Parent then hl:Destroy(); State.esp.highlights[p] = nil
                else hl.Adornee = p.Character end
            end
        end)
    else
        schedRemove("esp")
        clearESP()
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() applyESP(p) end)
end)
Players.PlayerRemoving:Connect(function(p)
    if State.esp.highlights[p] then State.esp.highlights[p]:Destroy(); State.esp.highlights[p] = nil end
end)

-- ====================================================================
-- FPS BOOST
-- ====================================================================
local function boostStrip(obj)
    local b = State.boost
    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam")
       or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles")
       or obj:IsA("Highlight") or obj:IsA("Light") or obj:IsA("PostEffect") then
        if obj.Enabled then obj.Enabled = false; table.insert(b.disabled, obj) end
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    elseif obj:IsA("BasePart") then
        obj.CastShadow = false
        obj.Material = Enum.Material.SmoothPlastic
        obj.Reflectance = 0
    end
end

local function boostSet(on)
    local b = State.boost
    b.on = on
    if on then
        pcall(function() if setfpscap then setfpscap(60) end end)
        pcall(function()
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 9e9
            Lighting.ShadowSoftness = 0
        end)
        for _, v in ipairs(Lighting:GetDescendants()) do boostStrip(v) end
        for _, v in ipairs(Workspace:GetDescendants()) do boostStrip(v) end
        if not b.conn then
            b.conn = Workspace.DescendantAdded:Connect(function(o)
                if State.boost.on then boostStrip(o) end
            end)
        end
    else
        if b.conn then b.conn:Disconnect(); b.conn = nil end
        pcall(function()
            Lighting.GlobalShadows = true
            Lighting.FogEnd = 100000
        end)
        for _, o in ipairs(b.disabled) do pcall(function() o.Enabled = true end) end
        b.disabled = {}
    end
end

-- ====================================================================
-- ANTI-AFK
-- ====================================================================
local function antiAfkSet(on)
    local a = State.antiAfk
    a.on = on
    if on and not a.conn then
        a.conn = LP.Idled:Connect(function()
            pcall(function()
                VirtualUser:CaptureController()
                VirtualUser:ClickButton2(Vector2.zero)
            end)
        end)
    elseif not on and a.conn then
        a.conn:Disconnect(); a.conn = nil
    end
end

-- ====================================================================
-- AFK MODE
-- ====================================================================
local function afkExit()
    if not State.afk.on then return end
    State.afk.on = false
    if not State.afk.prevAntiAfk and State.antiAfk.on then
        antiAfkSet(false)
    end
    if State.afk.overlay then
        State.afk.overlay:Destroy()
        State.afk.overlay = nil
    end
    print("[Day Hub] AFK OFF")
end

local function afkEnter()
    if State.afk.on then return end
    State.afk.on = true
    State.afk.prevAntiAfk = State.antiAfk.on

    if not State.antiAfk.on then antiAfkSet(true) end
    if State.fly.on    then flySet(false)    end
    if State.noclip.on then noclipSet(false) end

    local ov = Instance.new("Frame")
    ov.Name = "AFK_Overlay"
    ov.Size = UDim2.new(1, 0, 1, 0)
    ov.Position = UDim2.new(0, 0, 0, 0)
    ov.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ov.BorderSizePixel = 0
    ov.ZIndex = 999
    ov.Parent = ScreenGui

    local blocker = Instance.new("TextButton")
    blocker.Size = UDim2.new(1, 0, 1, 0)
    blocker.BackgroundTransparency = 1
    blocker.Text = ""
    blocker.ZIndex = 1000
    blocker.Parent = ov

    local exitBtn = Instance.new("TextButton")
    exitBtn.Size = UDim2.new(0, 220, 0, 52)
    exitBtn.Position = UDim2.new(0.5, -110, 0.5, -26)
    exitBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
    exitBtn.BorderSizePixel = 0
    exitBtn.Text = "✕  ออกโหมด AFK"
    exitBtn.Font = Enum.Font.GothamBold
    exitBtn.TextColor3 = Color3.fromRGB(245, 245, 250)
    exitBtn.TextSize = 15
    exitBtn.ZIndex = 1001
    exitBtn.AutoButtonColor = false
    Instance.new("UICorner", exitBtn).CornerRadius = UDim.new(0, 8)
    local stroke = Instance.new("UIStroke", exitBtn)
    stroke.Color = Color3.fromRGB(75, 75, 90)
    exitBtn.Parent = ov

    exitBtn.MouseEnter:Connect(function()
        exitBtn.BackgroundColor3 = Color3.fromRGB(42, 42, 52)
        stroke.Color = Color3.fromRGB(120, 120, 140)
    end)
    exitBtn.MouseLeave:Connect(function()
        exitBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
        stroke.Color = Color3.fromRGB(75, 75, 90)
    end)
    exitBtn.MouseButton1Click:Connect(function() afkExit() end)

    local hint = Instance.new("TextLabel")
    hint.Size = UDim2.new(1, 0, 0, 24)
    hint.Position = UDim2.new(0, 0, 1, -40)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Gotham
    hint.Text = "Anti-AFK เปิดอยู่  •  กดปุ่มด้านบนเพื่อออก"
    hint.TextColor3 = Color3.fromRGB(90, 90, 100)
    hint.TextSize = 12
    hint.ZIndex = 1001
    hint.Parent = ov

    State.afk.overlay = ov
    print("[Day Hub] AFK ON")
end

-- ====================================================================
-- TABS
-- ====================================================================
local FlyPage = createTab("Fly", "🚀")
createSwitch(FlyPage, "โหมดบิน (Fly Mode)", "Space ขึ้น / LeftShift ลง", false, flySet)
createSlider(FlyPage, "ความเร็วการบิน", 10, 300, 50, function(v) State.fly.speed = v end)
createSwitch(FlyPage, "ล็อคความเร็วเดิน", "กันเกมรีเซ็ตกลับเป็น 16", false, walkSet)
createSlider(FlyPage, "ความเร็วเดิน", 16, 250, 16, function(v)
    State.walk.value = v
    local h = getHum()
    if h and State.walk.on then h.WalkSpeed = v end
end)
createSwitch(FlyPage, "เดินทะลุกำแพง (Noclip)", "ปิดการชน", false, noclipSet)

local PlayerPage = createTab("Player", "👤")
local selectedTarget = nil
local TargetCard = Instance.new("Frame", PlayerPage)
TargetCard.Size = UDim2.new(1,0,0,40)
TargetCard.BackgroundColor3 = THEME.BG_PANEL
TargetCard.BorderSizePixel = 0
Instance.new("UICorner", TargetCard).CornerRadius = UDim.new(0,6)
Instance.new("UIStroke", TargetCard).Color = THEME.BORDER
local TargetLbl = Instance.new("TextLabel", TargetCard)
TargetLbl.Size = UDim2.new(1,-20,1,0)
TargetLbl.Position = UDim2.new(0,12,0,0)
TargetLbl.BackgroundTransparency = 1
TargetLbl.Font = Enum.Font.GothamMedium
TargetLbl.Text = "Target: ยังไม่ได้เลือก"
TargetLbl.TextColor3 = THEME.TEXT_MUTED
TargetLbl.TextSize = 12
TargetLbl.TextXAlignment = Enum.TextXAlignment.Left

local PlayerScroll = Instance.new("ScrollingFrame", PlayerPage)
PlayerScroll.Size = UDim2.new(1,0,0,120)
PlayerScroll.BackgroundColor3 = THEME.BG_ELEMENT
PlayerScroll.BorderSizePixel = 0
PlayerScroll.ScrollBarThickness = 3
PlayerScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", PlayerScroll).CornerRadius = UDim.new(0,6)
Instance.new("UIListLayout", PlayerScroll).Padding = UDim.new(0,4)

local function refreshPlayers()
    for _, ch in ipairs(PlayerScroll:GetChildren()) do
        if ch:IsA("TextButton") then ch:Destroy() end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then
            local b = Instance.new("TextButton", PlayerScroll)
            b.Size = UDim2.new(1,0,0,26)
            b.BackgroundColor3 = (selectedTarget==p) and THEME.BG_ACTIVE or THEME.BG_PANEL
            b.BorderSizePixel = 0
            b.Font = Enum.Font.Gotham
            b.Text = p.DisplayName.." (@"..p.Name..")"
            b.TextColor3 = (selectedTarget==p) and THEME.TEXT_TITLE or THEME.TEXT_NORMAL
            b.TextSize = 11
            Instance.new("UICorner", b).CornerRadius = UDim.new(0,4)
            b.MouseButton1Click:Connect(function()
                selectedTarget = p
                TargetLbl.Text = "Target: "..p.DisplayName
                TargetLbl.TextColor3 = THEME.TEXT_TITLE
                refreshPlayers()
            end)
        end
    end
end
createButton(PlayerPage, "🔄 รีเฟรชรายชื่อ", THEME.BG_ELEMENT, refreshPlayers)
createButton(PlayerPage, "📍 วาร์ปไปหาเป้าหมาย", THEME.BG_ELEMENT, function()
    if not selectedTarget or not selectedTarget.Character then return end
    local tr = selectedTarget.Character:FindFirstChild("HumanoidRootPart")
    local mr = getRoot()
    if tr and mr then mr.CFrame = tr.CFrame * CFrame.new(0,0,3) end
end)
refreshPlayers()

local VisualsPage = createTab("Visuals", "👁️")
createSwitch(VisualsPage, "Player ESP (Green)", "เรืองแสงเขียว ทะลุกำแพง", false, espSet, THEME.SAFE)

local SettingsPage = createTab("Settings", "⚙️")
createSwitch(SettingsPage, "Ultra FPS Boost", "ตัดหญ้า/เงา/เอฟเฟกต์ + ล็อค 60", false, boostSet, THEME.SAFE)
createSwitch(SettingsPage, "Anti-AFK", "กันหลุดเมื่ออยู่นิ่ง", false, antiAfkSet, THEME.SAFE)
createButton(SettingsPage, "🌙  โหมด AFK (จอดำประหยัดไฟ)", THEME.BG_ELEMENT, afkEnter)

-- ====================================================================
-- RESPAWN HANDLING
-- ====================================================================
LP.CharacterAdded:Connect(function()
    if State.fly.on then
        flyStop()
        task.wait(0.2)
        flyStart()
    end
end)

-- ====================================================================
-- CLEANUP + BUTTONS
-- ====================================================================
local function cleanupAll()
    afkExit()
    flyStop(); noclipStop(); walkSet(false)
    espSet(false); boostSet(false); antiAfkSet(false)
end

local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(Main, TweenInfo.new(0.22, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = minimized and UDim2.new(0,560,0,38) or UDim2.new(0,560,0,360)
    }):Play()
end)

CloseBtn.MouseButton1Click:Connect(function()
    cleanupAll()
    ScreenGui:Destroy()
end)

print("[Day Hub] v2.2 Smooth + AFK — loaded.")
