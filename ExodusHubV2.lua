-- ════════════════════════════════════════════════════════════════
--  Exodus Hub V2  |  Universal Aimbot + Triggerbot + Misc
--  Build  : 2026.04.16.4
--  Notes  : aimbot, triggerbot, ESP, settings, misc (inf jump,
--           noclip, fly, auto respawn, touch kill, anti-afk,
--           fps boost). red/black Kunani-style UI. keyless.
-- ════════════════════════════════════════════════════════════════

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local CoreGui          = game:GetService("CoreGui")
local Teams            = game:GetService("Teams")
local Lighting         = game:GetService("Lighting")
local VirtualUser      = game:GetService("VirtualUser")
local Camera           = workspace.CurrentCamera
local LocalPlayer      = Players.LocalPlayer
local Workspace        = workspace
local mouse            = LocalPlayer:GetMouse()

-- ════════════════════════════════════════════════════════════════
--  STATE
-- ════════════════════════════════════════════════════════════════
local State = {
    -- Aimbot
    AimbotEnabled    = false,
    AimbotKey        = nil,
    AimbotSmooth     = 8,
    AimbotFOV        = 90,
    ShowFOV          = true,
    AimbotTargetPart = "Head",
    LockTeammates    = true,
    WallCheck        = true,
    -- Triggerbot
    TriggerEnabled   = false,
    TriggerKey       = nil,
    TriggerAlwaysOn  = false,
    TriggerDelay     = 0,
    -- ESP
    ESP = {
        BoxESP       = false,
        OutlineESP   = false,
        NameESP      = false,
        DistanceESP  = false,
        ESPTeammates = false,
    },
    -- Settings
    WalkSpeed        = 16,
    JumpPower        = 50,
    Fullbright       = false,
    NoFog            = false,
    UIKey            = Enum.KeyCode.Q,
    -- Misc
    InfJump          = false,
    Noclip           = false,
    Fly              = false,
    FlySpeed         = 80,
    AutoRespawn      = false,
    TouchKill        = false,
    AntiAFK          = false,
    FPSBoost         = false,
}

local C = {
    bg      = Color3.fromRGB(10, 8, 10),
    panel   = Color3.fromRGB(18, 14, 16),
    card    = Color3.fromRGB(28, 20, 24),
    cardHov = Color3.fromRGB(38, 26, 30),
    accent  = Color3.fromRGB(230, 30, 50),
    accentB = Color3.fromRGB(140, 10, 25),
    accentD = Color3.fromRGB(90, 5, 15),
    border  = Color3.fromRGB(70, 22, 30),
    text    = Color3.fromRGB(255, 230, 232),
    dim     = Color3.fromRGB(170, 110, 120),
    white   = Color3.fromRGB(255, 255, 255),
    on      = Color3.fromRGB(220, 30, 50),
    off     = Color3.fromRGB(32, 20, 24),
    red     = Color3.fromRGB(255, 50, 60),
    green   = Color3.fromRGB(80, 210, 130),
    yellow  = Color3.fromRGB(255, 200, 60),
}

local BUILD_TAG = "v2.0.0"
local OWNER_TAG = "exodus"

-- ════════════════════════════════════════════════════════════════
--  CLEANUP
-- ════════════════════════════════════════════════════════════════
pcall(function()
    for _, g in ipairs(CoreGui:GetChildren()) do
        if g.Name == "ExodusLoader" or g.Name == "ExodusHub_GUI"
        or g.Name == "ExodusFloat" then
            g:Destroy()
        end
    end
end)

-- ════════════════════════════════════════════════════════════════
--  LOADING SCREEN
-- ════════════════════════════════════════════════════════════════
local loaderGui = Instance.new("ScreenGui")
loaderGui.Name = "ExodusLoader"
loaderGui.ResetOnSpawn = false
loaderGui.DisplayOrder = 1000
loaderGui.IgnoreGuiInset = true
pcall(function() loaderGui.Parent = CoreGui end)
if not loaderGui.Parent then loaderGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

local overlay = Instance.new("Frame", loaderGui)
overlay.Size = UDim2.new(1,0,1,0)
overlay.BackgroundColor3 = Color3.fromRGB(0,0,0)
overlay.BackgroundTransparency = 1
overlay.BorderSizePixel = 0
TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 0.5}):Play()

local card = Instance.new("Frame", loaderGui)
card.AnchorPoint = Vector2.new(0.5, 0.5)
card.Position = UDim2.new(0.5, 0, 0.65, 0)
card.Size = UDim2.new(0, 540, 0, 230)
card.BackgroundColor3 = C.bg
card.BorderSizePixel = 0
card.ClipsDescendants = true
Instance.new("UICorner", card).CornerRadius = UDim.new(0, 16)
local cardStroke = Instance.new("UIStroke", card)
cardStroke.Color = C.border
cardStroke.Thickness = 1.5

local leftBar = Instance.new("Frame", card)
leftBar.Size = UDim2.new(0, 4, 1, 0)
leftBar.BackgroundColor3 = C.accent
leftBar.BorderSizePixel = 0
local lbg = Instance.new("UIGradient", leftBar)
lbg.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C.accentD),
    ColorSequenceKeypoint.new(0.5, C.accent),
    ColorSequenceKeypoint.new(1, C.accentD),
})
lbg.Rotation = 90

local leftPanel = Instance.new("Frame", card)
leftPanel.Size = UDim2.new(0, 190, 1, 0)
leftPanel.Position = UDim2.new(0, 4, 0, 0)
leftPanel.BackgroundColor3 = C.panel
leftPanel.BorderSizePixel = 0

local rightPanel = Instance.new("Frame", card)
rightPanel.Size = UDim2.new(1, -194, 1, 0)
rightPanel.Position = UDim2.new(0, 194, 0, 0)
rightPanel.BackgroundTransparency = 1

local mono = Instance.new("TextLabel", rightPanel)
mono.Size = UDim2.new(0, 60, 0, 60)
mono.Position = UDim2.new(0, 20, 0, 20)
mono.BackgroundColor3 = C.accentB
mono.BorderSizePixel = 0
mono.Text = "E"
mono.TextColor3 = C.white
mono.Font = Enum.Font.GothamBlack
mono.TextSize = 34
Instance.new("UICorner", mono).CornerRadius = UDim.new(0, 12)
local monoG = Instance.new("UIGradient", mono)
monoG.Color = ColorSequence.new(C.accent, C.accentB)
monoG.Rotation = 45

local rTitle = Instance.new("TextLabel", rightPanel)
rTitle.Size = UDim2.new(1, -100, 0, 26)
rTitle.Position = UDim2.new(0, 92, 0, 24)
rTitle.BackgroundTransparency = 1
rTitle.Text = "Exodus Hub"
rTitle.TextColor3 = C.text
rTitle.Font = Enum.Font.GothamBlack
rTitle.TextSize = 20
rTitle.TextXAlignment = Enum.TextXAlignment.Left

local rTag = Instance.new("TextLabel", rightPanel)
rTag.Size = UDim2.new(1, -100, 0, 16)
rTag.Position = UDim2.new(0, 92, 0, 52)
rTag.BackgroundTransparency = 1
rTag.Text = "V2  ·  Keyless  ·  Universal"
rTag.TextColor3 = C.accent
rTag.Font = Enum.Font.GothamBold
rTag.TextSize = 11
rTag.TextXAlignment = Enum.TextXAlignment.Left

local rBy = Instance.new("TextLabel", rightPanel)
rBy.Size = UDim2.new(1, -100, 0, 14)
rBy.Position = UDim2.new(0, 92, 0, 70)
rBy.BackgroundTransparency = 1
rBy.Text = "by " .. OWNER_TAG
rBy.TextColor3 = C.dim
rBy.Font = Enum.Font.Gotham
rBy.TextSize = 10
rBy.TextXAlignment = Enum.TextXAlignment.Left

local rDiv = Instance.new("Frame", rightPanel)
rDiv.Size = UDim2.new(1, -40, 0, 1)
rDiv.Position = UDim2.new(0, 20, 0, 100)
rDiv.BackgroundColor3 = C.border
rDiv.BorderSizePixel = 0

local rStatus = Instance.new("TextLabel", rightPanel)
rStatus.Size = UDim2.new(1, -40, 0, 16)
rStatus.Position = UDim2.new(0, 20, 0, 112)
rStatus.BackgroundTransparency = 1
rStatus.Text = "Initialising..."
rStatus.TextColor3 = C.dim
rStatus.Font = Enum.Font.Gotham
rStatus.TextSize = 11
rStatus.TextXAlignment = Enum.TextXAlignment.Left

local rTrack = Instance.new("Frame", rightPanel)
rTrack.Size = UDim2.new(1, -40, 0, 5)
rTrack.Position = UDim2.new(0, 20, 0, 140)
rTrack.BackgroundColor3 = C.card
rTrack.BorderSizePixel = 0
Instance.new("UICorner", rTrack).CornerRadius = UDim.new(1, 0)

local rFill = Instance.new("Frame", rTrack)
rFill.Size = UDim2.new(0, 0, 1, 0)
rFill.BackgroundColor3 = C.accent
rFill.BorderSizePixel = 0
Instance.new("UICorner", rFill).CornerRadius = UDim.new(1, 0)
local rfg = Instance.new("UIGradient", rFill)
rfg.Color = ColorSequence.new(C.accentB, C.accent)

local rPct = Instance.new("TextLabel", rightPanel)
rPct.Size = UDim2.new(1, -40, 0, 16)
rPct.Position = UDim2.new(0, 20, 0, 154)
rPct.BackgroundTransparency = 1
rPct.Text = "0%"
rPct.TextColor3 = C.accent
rPct.Font = Enum.Font.GothamBold
rPct.TextSize = 10
rPct.TextXAlignment = Enum.TextXAlignment.Right

local rVer = Instance.new("TextLabel", rightPanel)
rVer.Size = UDim2.new(1, -40, 0, 16)
rVer.Position = UDim2.new(0, 20, 1, -26)
rVer.BackgroundTransparency = 1
rVer.Text = BUILD_TAG .. "  ·  " .. OWNER_TAG
rVer.TextColor3 = C.border
rVer.Font = Enum.Font.Gotham
rVer.TextSize = 9
rVer.TextXAlignment = Enum.TextXAlignment.Right

local STEPS = {
    {label="Services",  sub="Loading core modules"},
    {label="Interface", sub="Building UI"},
    {label="Aimbot",    sub="Configuring aim"},
    {label="Trigger",   sub="Wiring trigger"},
    {label="ESP",       sub="Setting visuals"},
    {label="Misc",      sub="Loading misc"},
    {label="Ready",     sub="Finishing up"},
}

local stepDots, stepLabels = {}, {}
for i, step in ipairs(STEPS) do
    local y = 14 + (i-1) * 30
    if i < #STEPS then
        local line = Instance.new("Frame", leftPanel)
        line.Size = UDim2.new(0, 2, 0, 18)
        line.Position = UDim2.new(0, 21, 0, y+14)
        line.BackgroundColor3 = C.border
        line.BorderSizePixel = 0
    end
    local dot = Instance.new("Frame", leftPanel)
    dot.Size = UDim2.new(0, 12, 0, 12)
    dot.Position = UDim2.new(0, 16, 0, y+1)
    dot.BackgroundColor3 = C.border
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)
    stepDots[i] = dot

    local lbl = Instance.new("TextLabel", leftPanel)
    lbl.Size = UDim2.new(1, -40, 0, 14)
    lbl.Position = UDim2.new(0, 36, 0, y)
    lbl.BackgroundTransparency = 1
    lbl.Text = step.label
    lbl.TextColor3 = C.dim
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 11
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    stepLabels[i] = lbl

    local sub = Instance.new("TextLabel", leftPanel)
    sub.Size = UDim2.new(1, -40, 0, 10)
    sub.Position = UDim2.new(0, 36, 0, y+14)
    sub.BackgroundTransparency = 1
    sub.Text = step.sub
    sub.TextColor3 = C.border
    sub.Font = Enum.Font.Gotham
    sub.TextSize = 9
    sub.TextXAlignment = Enum.TextXAlignment.Left
end

TweenService:Create(card, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
    Position = UDim2.new(0.5, 0, 0.5, 0)
}):Play()
task.wait(0.55)

for i = 1, #STEPS do
    stepDots[i].BackgroundColor3 = C.accent
    stepLabels[i].TextColor3 = C.text
    local pct = i / #STEPS
    TweenService:Create(rFill, TweenInfo.new(0.28, Enum.EasingStyle.Quad), {
        Size = UDim2.new(pct, 0, 1, 0)
    }):Play()
    rPct.Text = math.floor(pct * 100) .. "%"
    rStatus.Text = STEPS[i].sub .. "..."
    task.wait(0.28)
    stepDots[i].BackgroundColor3 = C.green
    local chk = Instance.new("TextLabel", stepDots[i])
    chk.Size = UDim2.new(1,0,1,0)
    chk.BackgroundTransparency = 1
    chk.Text = "✓"
    chk.TextColor3 = C.white
    chk.Font = Enum.Font.GothamBlack
    chk.TextSize = 8
end

rFill.Size = UDim2.new(1,0,1,0)
rPct.Text = "100%"
rStatus.Text = "Ready!"
rStatus.TextColor3 = C.green
task.wait(0.35)

TweenService:Create(card, TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In), {
    Position = UDim2.new(0.5, 0, -0.3, 0)
}):Play()
TweenService:Create(overlay, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
task.wait(0.42)
loaderGui:Destroy()

-- ════════════════════════════════════════════════════════════════
--  FOV CIRCLE
-- ════════════════════════════════════════════════════════════════
local FOVCircle
pcall(function()
    FOVCircle = Drawing.new("Circle")
    FOVCircle.Color = C.accent
    FOVCircle.Thickness = 1.5
    FOVCircle.NumSides = 64
    FOVCircle.Filled = false
    FOVCircle.Visible = true
end)

local function isTeammate(p)
    return LocalPlayer.Team and p.Team == LocalPlayer.Team
end
local function getESPColor(p)
    if #Teams:GetChildren() > 0 and p.TeamColor then return p.TeamColor.Color end
    return C.accent
end

-- ════════════════════════════════════════════════════════════════
--  MAIN GUI
-- ════════════════════════════════════════════════════════════════
local Gui = Instance.new("ScreenGui")
pcall(function() Gui.Parent = CoreGui end)
if not Gui.Parent then Gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
Gui.Name = "ExodusHub_GUI"
Gui.ResetOnSpawn = false
Gui.DisplayOrder = 999
Gui.IgnoreGuiInset = true

local Win = Instance.new("Frame", Gui)
Win.Size = UDim2.new(0, 460, 0, 360)
Win.Position = UDim2.new(0.5, -230, 0.5, -180)
Win.BackgroundColor3 = C.bg
Win.BorderSizePixel = 0
Win.ClipsDescendants = true
Instance.new("UICorner", Win).CornerRadius = UDim.new(0, 14)
local winStroke = Instance.new("UIStroke", Win)
winStroke.Color = C.border
winStroke.Thickness = 1.2

local TBar = Instance.new("Frame", Win)
TBar.Size = UDim2.new(1,0,0,36)
TBar.BackgroundColor3 = C.panel
TBar.BorderSizePixel = 0

local TBarDiv = Instance.new("Frame", TBar)
TBarDiv.Size = UDim2.new(1,0,0,1)
TBarDiv.Position = UDim2.new(0,0,1,-1)
TBarDiv.BackgroundColor3 = C.border
TBarDiv.BorderSizePixel = 0

local accentTag = Instance.new("Frame", TBar)
accentTag.Size = UDim2.new(0,3,0,20)
accentTag.Position = UDim2.new(0,12,0.5,-10)
accentTag.BackgroundColor3 = C.accent
accentTag.BorderSizePixel = 0
Instance.new("UICorner", accentTag).CornerRadius = UDim.new(1,0)

local mark2 = Instance.new("Frame", TBar)
mark2.Size = UDim2.new(0, 20, 0, 20)
mark2.Position = UDim2.new(0, 20, 0.5, -10)
mark2.BackgroundColor3 = C.accentB
mark2.BorderSizePixel = 0
Instance.new("UICorner", mark2).CornerRadius = UDim.new(0, 5)
local mark2Txt = Instance.new("TextLabel", mark2)
mark2Txt.Size = UDim2.new(1,0,1,0)
mark2Txt.BackgroundTransparency = 1
mark2Txt.Text = "E"
mark2Txt.TextColor3 = C.white
mark2Txt.Font = Enum.Font.GothamBlack
mark2Txt.TextSize = 12

local TTitle = Instance.new("TextLabel", TBar)
TTitle.Size = UDim2.new(1,-150,1,0)
TTitle.Position = UDim2.new(0,46,0,0)
TTitle.BackgroundTransparency = 1
TTitle.Text = "Exodus Hub V2  |  Keyless"
TTitle.TextColor3 = C.text
TTitle.Font = Enum.Font.GothamBlack
TTitle.TextSize = 13
TTitle.TextXAlignment = Enum.TextXAlignment.Left

local TVer = Instance.new("TextLabel", TBar)
TVer.Size = UDim2.new(0,70,1,0)
TVer.Position = UDim2.new(1,-94,0,0)
TVer.BackgroundTransparency = 1
TVer.Text = "by " .. OWNER_TAG
TVer.TextColor3 = C.dim
TVer.Font = Enum.Font.Gotham
TVer.TextSize = 10
TVer.TextXAlignment = Enum.TextXAlignment.Right

local function headerBtn(xOff, lbl, col)
    local b = Instance.new("TextButton", TBar)
    b.Size = UDim2.new(0,22,0,22)
    b.Position = UDim2.new(1,xOff,0.5,-11)
    b.BackgroundColor3 = col
    b.BorderSizePixel = 0
    b.Text = lbl
    b.TextColor3 = C.white
    b.Font = Enum.Font.GothamBold
    b.TextSize = 11
    b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
    b.MouseEnter:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=col:Lerp(C.white,0.3)}):Play()
    end)
    b.MouseLeave:Connect(function()
        TweenService:Create(b,TweenInfo.new(0.1),{BackgroundColor3=col}):Play()
    end)
    return b
end

local HideBtn  = headerBtn(-28, "−", Color3.fromRGB(70,30,36))
local CloseBtn = headerBtn(-54, "×", Color3.fromRGB(200,40,50))

local Sidebar = Instance.new("Frame", Win)
Sidebar.Size = UDim2.new(0,100,1,-36)
Sidebar.Position = UDim2.new(0,0,0,36)
Sidebar.BackgroundColor3 = C.panel
Sidebar.BorderSizePixel = 0

local SideDiv = Instance.new("Frame", Win)
SideDiv.Size = UDim2.new(0,1,1,-36)
SideDiv.Position = UDim2.new(0,100,0,36)
SideDiv.BackgroundColor3 = C.border
SideDiv.BorderSizePixel = 0

local ContentArea = Instance.new("Frame", Win)
ContentArea.Size = UDim2.new(1,-101,1,-36)
ContentArea.Position = UDim2.new(0,101,0,36)
ContentArea.BackgroundTransparency = 1
ContentArea.ClipsDescendants = true

local FloatGui = Instance.new("ScreenGui")
pcall(function() FloatGui.Parent = CoreGui end)
if not FloatGui.Parent then FloatGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end
FloatGui.Name = "ExodusFloat"
FloatGui.ResetOnSpawn = false
FloatGui.Enabled = false

local FloatBtn = Instance.new("TextButton", FloatGui)
FloatBtn.Size = UDim2.new(0,130,0,30)
FloatBtn.Position = UDim2.new(1,-140,0,10)
FloatBtn.BackgroundColor3 = C.accentB
FloatBtn.BorderSizePixel = 0
FloatBtn.Text = "Exodus Hub V2"
FloatBtn.TextColor3 = C.white
FloatBtn.Font = Enum.Font.GothamBold
FloatBtn.TextSize = 12
FloatBtn.AutoButtonColor = false
Instance.new("UICorner", FloatBtn).CornerRadius = UDim.new(0,8)
Instance.new("UIStroke", FloatBtn).Color = C.accent

HideBtn.MouseButton1Click:Connect(function() Gui.Enabled = false; FloatGui.Enabled = true end)
CloseBtn.MouseButton1Click:Connect(function()
    Gui:Destroy()
    FloatGui:Destroy()
    if FOVCircle then FOVCircle.Visible = false end
end)
FloatBtn.MouseButton1Click:Connect(function() Gui.Enabled = true; FloatGui.Enabled = false end)

local dragOn, dragStart, winStart = false, nil, nil
TBar.InputBegan:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragOn = true
        dragStart = inp.Position
        winStart = Win.Position
    end
end)
TBar.InputEnded:Connect(function(inp)
    if inp.UserInputType == Enum.UserInputType.MouseButton1
    or inp.UserInputType == Enum.UserInputType.Touch then
        dragOn = false
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if not dragOn then return end
    if inp.UserInputType == Enum.UserInputType.MouseMovement
    or inp.UserInputType == Enum.UserInputType.Touch then
        Win.Position = UDim2.new(
            winStart.X.Scale, winStart.X.Offset + (inp.Position.X - dragStart.X),
            winStart.Y.Scale, winStart.Y.Offset + (inp.Position.Y - dragStart.Y)
        )
    end
end)

-- ── tab system ──────────────────────────────────────────────────
local tabs, tabBtns = {}, {}
local activePage = nil

local sidePad = Instance.new("UIPadding", Sidebar)
sidePad.PaddingTop = UDim.new(0,6)
sidePad.PaddingLeft = UDim.new(0,6)
sidePad.PaddingRight = UDim.new(0,6)
local sideList = Instance.new("UIListLayout", Sidebar)
sideList.SortOrder = Enum.SortOrder.LayoutOrder
sideList.Padding = UDim.new(0,3)

local function setPage(name)
    if activePage == name then return end
    activePage = name
    for n, pg in pairs(tabs) do pg.Visible = (n == name) end
    for n, btn in pairs(tabBtns) do
        local on = (n == name)
        TweenService:Create(btn, TweenInfo.new(0.15), {
            BackgroundColor3 = on and C.card or Color3.fromRGB(0,0,0),
            BackgroundTransparency = on and 0 or 1,
        }):Play()
        local lb = btn:FindFirstChildOfClass("TextLabel")
        if lb then lb.TextColor3 = on and C.text or C.dim end
    end
end

local function addTab(name, icon, order)
    local btn = Instance.new("TextButton", Sidebar)
    btn.Size = UDim2.new(1,0,0,48)
    btn.BackgroundColor3 = Color3.fromRGB(0,0,0)
    btn.BackgroundTransparency = 1
    btn.BorderSizePixel = 0
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.LayoutOrder = order
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local ico = Instance.new("TextLabel", btn)
    ico.Size = UDim2.new(1,0,0,20)
    ico.Position = UDim2.new(0,0,0,6)
    ico.BackgroundTransparency = 1
    ico.Text = icon
    ico.TextSize = 16
    ico.Font = Enum.Font.GothamBold
    ico.TextColor3 = C.dim

    local lb = Instance.new("TextLabel", btn)
    lb.Size = UDim2.new(1,0,0,14)
    lb.Position = UDim2.new(0,0,0,28)
    lb.BackgroundTransparency = 1
    lb.Text = name
    lb.TextSize = 10
    lb.Font = Enum.Font.GothamBold
    lb.TextColor3 = C.dim

    btn.MouseButton1Click:Connect(function() setPage(name) end)
    btn.MouseEnter:Connect(function()
        if activePage ~= name then
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=0.7}):Play()
        end
    end)
    btn.MouseLeave:Connect(function()
        if activePage ~= name then
            TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundTransparency=1}):Play()
        end
    end)

    local page = Instance.new("ScrollingFrame", ContentArea)
    page.Size = UDim2.new(1,0,1,0)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = C.border
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.Visible = false

    local pl = Instance.new("UIListLayout", page)
    pl.SortOrder = Enum.SortOrder.LayoutOrder
    pl.Padding = UDim.new(0,4)
    local pp = Instance.new("UIPadding", page)
    pp.PaddingLeft = UDim.new(0,10)
    pp.PaddingRight = UDim.new(0,10)
    pp.PaddingTop = UDim.new(0,8)
    pp.PaddingBottom = UDim.new(0,10)

    tabs[name] = page
    tabBtns[name] = btn
    return page
end

-- ── row builders ────────────────────────────────────────────────
local rowLO = 0
local function RLO() rowLO += 1; return rowLO end

local function sectionLbl(parent, text)
    local f = Instance.new("Frame", parent)
    f.Size = UDim2.new(1,0,0,22)
    f.BackgroundTransparency = 1
    f.LayoutOrder = RLO()
    local l = Instance.new("TextLabel", f)
    l.Size = UDim2.new(1,0,1,0)
    l.BackgroundTransparency = 1
    l.Text = text:upper()
    l.TextColor3 = C.accentB
    l.Font = Enum.Font.GothamBold
    l.TextSize = 9
    l.TextXAlignment = Enum.TextXAlignment.Left
    return f
end

local function makeToggleRow(parent, label, default, onChange)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = RLO()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(1,-56,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local pill = Instance.new("Frame", row)
    pill.Size = UDim2.new(0,38,0,20)
    pill.Position = UDim2.new(1,-46,0.5,-10)
    pill.BackgroundColor3 = default and C.on or C.off
    pill.BorderSizePixel = 0
    Instance.new("UICorner", pill).CornerRadius = UDim.new(1,0)
    local ps = Instance.new("UIStroke", pill)
    ps.Color = default and C.accent or C.border; ps.Thickness = 1

    local dot = Instance.new("Frame", pill)
    dot.Size = UDim2.new(0,14,0,14)
    dot.Position = default and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
    dot.BackgroundColor3 = C.white
    dot.BorderSizePixel = 0
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)

    local isOn = default or false
    local function setVal(v)
        isOn = v
        TweenService:Create(pill,TweenInfo.new(0.18),{BackgroundColor3=v and C.on or C.off}):Play()
        TweenService:Create(ps,TweenInfo.new(0.18),{Color=v and C.accent or C.border}):Play()
        TweenService:Create(dot,TweenInfo.new(0.18,Enum.EasingStyle.Back),{
            Position=v and UDim2.new(1,-17,0.5,-7) or UDim2.new(0,3,0.5,-7)
        }):Play()
        if onChange then onChange(v) end
    end

    row.MouseButton1Click:Connect(function() setVal(not isOn) end)
    row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardHov}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end)
    return setVal
end

local function makeInputRow(parent, label, default, onChange)
    local row = Instance.new("Frame", parent)
    row.Size = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    row.LayoutOrder = RLO()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.6,0,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local box = Instance.new("TextBox", row)
    box.Size = UDim2.new(0,72,0,26)
    box.Position = UDim2.new(1,-78,0.5,-13)
    box.BackgroundColor3 = C.bg
    box.BorderSizePixel = 0
    box.Text = tostring(default)
    box.TextColor3 = C.text
    box.Font = Enum.Font.GothamBold
    box.TextSize = 12
    box.ClearTextOnFocus = true
    Instance.new("UICorner", box).CornerRadius = UDim.new(0,6)
    local bs = Instance.new("UIStroke", box); bs.Color = C.border; bs.Thickness = 1

    box.Focused:Connect(function() TweenService:Create(bs,TweenInfo.new(0.12),{Color=C.accent}):Play() end)
    box.FocusLost:Connect(function()
        TweenService:Create(bs,TweenInfo.new(0.12),{Color=C.border}):Play()
        local n = tonumber(box.Text)
        if n then box.Text = tostring(n); if onChange then onChange(n) end
        else box.Text = tostring(default) end
    end)
    return box
end

local function makeButtonRow(parent, label, onClick)
    local btn = Instance.new("TextButton", parent)
    btn.Size = UDim2.new(1,0,0,34)
    btn.BackgroundColor3 = C.accentD
    btn.BorderSizePixel = 0
    btn.Text = label
    btn.TextColor3 = C.white
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.AutoButtonColor = false
    btn.LayoutOrder = RLO()
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)
    Instance.new("UIStroke", btn).Color = C.accent

    btn.MouseEnter:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.accentB}):Play() end)
    btn.MouseLeave:Connect(function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.accentD}):Play() end)
    btn.MouseButton1Click:Connect(function()
        TweenService:Create(btn,TweenInfo.new(0.08),{BackgroundColor3=C.accent}):Play()
        task.delay(0.16,function() TweenService:Create(btn,TweenInfo.new(0.1),{BackgroundColor3=C.accentD}):Play() end)
        if onClick then pcall(onClick) end
    end)
    return btn
end

local function makeKeyRow(parent, label, stateKey)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = RLO()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.55,0,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local keyBtn = Instance.new("TextButton", row)
    keyBtn.Size = UDim2.new(0,80,0,22)
    keyBtn.Position = UDim2.new(1,-86,0.5,-11)
    keyBtn.BackgroundColor3 = C.bg
    keyBtn.BorderSizePixel = 0
    local curKey = State[stateKey]
    keyBtn.Text = curKey and curKey.Name or "—"
    keyBtn.TextColor3 = C.dim
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 10
    keyBtn.AutoButtonColor = false
    Instance.new("UICorner", keyBtn).CornerRadius = UDim.new(0,4)
    local ks = Instance.new("UIStroke", keyBtn); ks.Color = C.border; ks.Thickness = 1

    local listening = false; local kConn
    keyBtn.MouseButton1Click:Connect(function()
        if listening then return end
        listening = true
        keyBtn.Text = "..."
        keyBtn.TextColor3 = C.accent
        TweenService:Create(ks,TweenInfo.new(0.1),{Color=C.accent}):Play()
        kConn = UserInputService.InputBegan:Connect(function(inp, gp)
            if gp then return end
            if inp.UserInputType == Enum.UserInputType.Keyboard then
                if inp.KeyCode == Enum.KeyCode.Escape then
                    State[stateKey] = nil
                    keyBtn.Text = "—"
                else
                    State[stateKey] = inp.KeyCode
                    keyBtn.Text = inp.KeyCode.Name
                end
                keyBtn.TextColor3 = C.text
                TweenService:Create(ks,TweenInfo.new(0.1),{Color=C.border}):Play()
                listening = false
                if kConn then kConn:Disconnect(); kConn = nil end
            end
        end)
    end)
    row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardHov}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end)
    return keyBtn
end

local function makePartRow(parent, label)
    local row = Instance.new("TextButton", parent)
    row.Size = UDim2.new(1,0,0,36)
    row.BackgroundColor3 = C.card
    row.BorderSizePixel = 0
    row.Text = ""
    row.AutoButtonColor = false
    row.LayoutOrder = RLO()
    Instance.new("UICorner", row).CornerRadius = UDim.new(0,8)

    local lbl = Instance.new("TextLabel", row)
    lbl.Size = UDim2.new(0.55,0,1,0)
    lbl.Position = UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = C.text
    lbl.Font = Enum.Font.GothamBold
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left

    local parts = {"Head","HumanoidRootPart","Torso","UpperTorso","LowerTorso"}
    local idx = 1
    local cycleBtn = Instance.new("TextButton", row)
    cycleBtn.Size = UDim2.new(0,110,0,22)
    cycleBtn.Position = UDim2.new(1,-116,0.5,-11)
    cycleBtn.BackgroundColor3 = C.accentD
    cycleBtn.BorderSizePixel = 0
    cycleBtn.Text = State.AimbotTargetPart
    cycleBtn.TextColor3 = C.text
    cycleBtn.Font = Enum.Font.GothamBold
    cycleBtn.TextSize = 10
    cycleBtn.AutoButtonColor = false
    Instance.new("UICorner", cycleBtn).CornerRadius = UDim.new(0,4)

    cycleBtn.MouseButton1Click:Connect(function()
        idx = (idx % #parts) + 1
        State.AimbotTargetPart = parts[idx]
        cycleBtn.Text = parts[idx]
        TweenService:Create(cycleBtn,TweenInfo.new(0.08),{BackgroundColor3=C.accent}):Play()
        task.delay(0.12,function() TweenService:Create(cycleBtn,TweenInfo.new(0.1),{BackgroundColor3=C.accentD}):Play() end)
    end)
    row.MouseEnter:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.cardHov}):Play() end)
    row.MouseLeave:Connect(function() TweenService:Create(row,TweenInfo.new(0.1),{BackgroundColor3=C.card}):Play() end)
end

local function gap(parent)
    local f = Instance.new("Frame", parent); f.Size = UDim2.new(1,0,0,4)
    f.BackgroundTransparency = 1; f.LayoutOrder = RLO()
end

-- ════════════════════════════════════════════════════════════════
--  TABS
-- ════════════════════════════════════════════════════════════════
local pgAim     = addTab("Aimbot",   "🎯", 1)
local pgTrig    = addTab("Trigger",  "⚡", 2)
local pgESP     = addTab("ESP",      "👁",  3)
local pgSet     = addTab("Settings", "⚙️",  4)
local pgMisc    = addTab("Misc",     "🔧", 5)

-- ════════════════════════════════════════════════════════════════
--  AIMBOT PAGE
-- ════════════════════════════════════════════════════════════════
sectionLbl(pgAim, "Aim Lock")
makeToggleRow(pgAim, "Aimbot Enabled", false, function(v) State.AimbotEnabled = v end)
makeToggleRow(pgAim, "Team Check (skip mates)", true, function(v) State.LockTeammates = v end)
makeToggleRow(pgAim, "Wall Check", true, function(v) State.WallCheck = v end)
makeToggleRow(pgAim, "Show FOV Circle", true, function(v)
    State.ShowFOV = v
    if FOVCircle then pcall(function() FOVCircle.Visible = v end) end
end)
gap(pgAim)
sectionLbl(pgAim, "Target")
makePartRow(pgAim, "Target Part")
makeKeyRow(pgAim, "Aim Key (hold)", "AimbotKey")
gap(pgAim)
sectionLbl(pgAim, "Values")
makeInputRow(pgAim, "FOV Radius", State.AimbotFOV, function(v)
    State.AimbotFOV = math.clamp(v, 10, 600)
end)
makeInputRow(pgAim, "Smooth (1=snap)", State.AimbotSmooth, function(v)
    State.AimbotSmooth = math.clamp(v, 1, 100)
end)

-- ════════════════════════════════════════════════════════════════
--  TRIGGERBOT PAGE
-- ════════════════════════════════════════════════════════════════
sectionLbl(pgTrig, "Trigger")
makeToggleRow(pgTrig, "Triggerbot Enabled", false, function(v) State.TriggerEnabled = v end)
makeToggleRow(pgTrig, "Always On (no key)", false, function(v) State.TriggerAlwaysOn = v end)
gap(pgTrig)
sectionLbl(pgTrig, "Key")
makeKeyRow(pgTrig, "Trigger Key (hold)", "TriggerKey")
gap(pgTrig)
sectionLbl(pgTrig, "Timing")
makeInputRow(pgTrig, "Fire Delay (ms)", 0, function(v) State.TriggerDelay = math.clamp(v, 0, 2000) end)

-- ════════════════════════════════════════════════════════════════
--  ESP PAGE
-- ════════════════════════════════════════════════════════════════
sectionLbl(pgESP, "ESP Options")
makeToggleRow(pgESP, "Box ESP", false, function(v) State.ESP.BoxESP = v end)
makeToggleRow(pgESP, "Outline ESP", false, function(v) State.ESP.OutlineESP = v end)
makeToggleRow(pgESP, "Name ESP", false, function(v) State.ESP.NameESP = v end)
makeToggleRow(pgESP, "Distance ESP", false, function(v) State.ESP.DistanceESP = v end)
makeToggleRow(pgESP, "Show Teammates", false, function(v) State.ESP.ESPTeammates = v end)

-- ════════════════════════════════════════════════════════════════
--  SETTINGS PAGE
-- ════════════════════════════════════════════════════════════════
sectionLbl(pgSet, "Player")
makeInputRow(pgSet, "Walk Speed", 16, function(v)
    State.WalkSpeed = math.clamp(v, 0, 500)
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = State.WalkSpeed end
end)
makeInputRow(pgSet, "Jump Power", 50, function(v)
    State.JumpPower = math.clamp(v, 0, 500)
    local c = LocalPlayer.Character
    local h = c and c:FindFirstChildOfClass("Humanoid")
    if h then
        h.UseJumpPower = true
        h.JumpPower = State.JumpPower
    end
end)
gap(pgSet)
sectionLbl(pgSet, "Visual")
makeToggleRow(pgSet, "Fullbright", false, function(v)
    State.Fullbright = v
    Lighting.Brightness = v and 2 or 1
    Lighting.ClockTime = v and 14 or Lighting.ClockTime
    Lighting.FogEnd = v and 9e9 or 100000
    Lighting.GlobalShadows = not v
end)
makeToggleRow(pgSet, "No Fog", false, function(v)
    State.NoFog = v
    Lighting.FogEnd = v and 9e9 or 100000
end)
gap(pgSet)
sectionLbl(pgSet, "UI Key")
makeKeyRow(pgSet, "Toggle UI Key", "UIKey")

-- ════════════════════════════════════════════════════════════════
--  MISC PAGE
-- ════════════════════════════════════════════════════════════════
sectionLbl(pgMisc, "Movement")
makeToggleRow(pgMisc, "Infinite Jump", false, function(v) State.InfJump = v end)
makeToggleRow(pgMisc, "Noclip", false, function(v)
    State.Noclip = v
    if not v then
        local c = LocalPlayer.Character
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = true end
            end
        end
    end
end)
makeToggleRow(pgMisc, "Fly", false, function(v) State.Fly = v end)
makeInputRow(pgMisc, "Fly Speed", 80, function(v) State.FlySpeed = math.clamp(v, 1, 500) end)
gap(pgMisc)
sectionLbl(pgMisc, "Utility")
makeToggleRow(pgMisc, "Auto Respawn", false, function(v) State.AutoRespawn = v end)
makeToggleRow(pgMisc, "Anti-AFK", false, function(v)
    State.AntiAFK = v
    if v then pcall(function() VirtualUser:ActivateVirtualCursor(Vector2.new(0,0)) end) end
end)
makeToggleRow(pgMisc, "FPS Boost", false, function(v)
    State.FPSBoost = v
    if v then
        for _, obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail")
                or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
                    obj.Enabled = false
                elseif obj:IsA("BasePart") then
                    obj.CastShadow = false
                end
            end)
        end
        pcall(function() setfpscap(999) end)
    end
end)
gap(pgMisc)
sectionLbl(pgMisc, "Danger")
makeButtonRow(pgMisc, "Kill Aura (Touch Kill)", function()
    State.TouchKill = not State.TouchKill
end)

-- ════════════════════════════════════════════════════════════════
--  GAME LOOPS
-- ════════════════════════════════════════════════════════════════

-- ── helpers ───────────────────────────────────────────────────
local function getChar()
    return LocalPlayer.Character
end
local function getHRP()
    local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart")
end
local function getHum()
    local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid")
end

local function getNearestTarget()
    local cam = workspace.CurrentCamera
    local vp = cam.ViewportSize
    local center = Vector2.new(vp.X/2, vp.Y/2)
    local best, bestDist = nil, State.AimbotFOV

    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if State.LockTeammates and isTeammate(p) then continue end
        local char = p.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if not hum or hum.Health <= 0 then continue end
        local part = char:FindFirstChild(State.AimbotTargetPart)
            or char:FindFirstChild("HumanoidRootPart")
        if not part then continue end

        if State.WallCheck then
            local rp = RaycastParams.new()
            rp.FilterDescendantsInstances = {getChar(), char}
            rp.FilterType = Enum.RaycastFilterType.Exclude
            local origin = cam.CFrame.Position
            local result = workspace:Raycast(origin, (part.Position - origin), rp)
            if result then continue end
        end

        local screenPos, onScreen = cam:WorldToViewportPoint(part.Position)
        if not onScreen then continue end
        local dist = Vector2.new(screenPos.X, screenPos.Y) - center
        local mag = dist.Magnitude
        if mag < bestDist then
            bestDist = mag
            best = {player=p, char=char, part=part, screen=dist}
        end
    end
    return best
end

-- ── Aimbot ───────────────────────────────────────────────────
local camConn
RunService.RenderStepped:Connect(function()
    -- FOV circle update
    if FOVCircle then
        pcall(function()
            local vp = workspace.CurrentCamera.ViewportSize
            FOVCircle.Position = Vector2.new(vp.X/2, vp.Y/2)
            FOVCircle.Radius   = State.AimbotFOV
            FOVCircle.Visible  = State.ShowFOV
        end)
    end

    if not State.AimbotEnabled then return end
    local keyOk = State.AimbotKey == nil or UserInputService:IsKeyDown(State.AimbotKey)
    if not keyOk then return end

    local target = getNearestTarget()
    if not target then return end

    local cam = workspace.CurrentCamera
    local smooth = math.clamp(State.AimbotSmooth, 1, 100)
    local goal = CFrame.new(cam.CFrame.Position, target.part.Position)
    cam.CFrame = cam.CFrame:Lerp(goal, 1 / smooth)
end)

-- ── Triggerbot ────────────────────────────────────────────────
local trigLastFire = 0
RunService.Heartbeat:Connect(function()
    if not State.TriggerEnabled then return end
    local keyOk = State.TriggerAlwaysOn
        or (State.TriggerKey ~= nil and UserInputService:IsKeyDown(State.TriggerKey))
    if not keyOk then return end

    local cam = workspace.CurrentCamera
    local vp = cam.ViewportSize
    local ray = cam:ScreenPointToRay(vp.X/2, vp.Y/2)
    local rp = RaycastParams.new()
    rp.FilterDescendantsInstances = {getChar() or {}}
    rp.FilterType = Enum.RaycastFilterType.Exclude
    local res = workspace:Raycast(ray.Origin, ray.Direction * 1000, rp)

    if res and res.Instance then
        local char = res.Instance.Parent
        local hum = char:FindFirstChildOfClass("Humanoid")
            or (char.Parent and char.Parent:FindFirstChildOfClass("Humanoid"))
        if hum and hum.Health > 0 then
            -- Check not teammate
            for _, p in ipairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and (p.Character == char or p.Character == char.Parent) then
                    if State.LockTeammates and isTeammate(p) then break end
                    if tick() - trigLastFire < (State.TriggerDelay / 1000) then break end
                    trigLastFire = tick()
                    if mouse1press then mouse1press(); task.delay(0.03, function() if mouse1release then mouse1release() end end)
                    elseif mouse1click then mouse1click()
                    elseif VirtualInputManager then
                        pcall(function()
                            VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,1)
                            task.delay(0.03,function() VirtualInputManager:SendMouseButtonEvent(0,0,0,false,game,1) end)
                        end)
                    end
                    break
                end
            end
        end
    end
end)

-- ── ESP ──────────────────────────────────────────────────────
local espObjects = {}
local function cleanESP(p)
    if espObjects[p] then
        for _, d in ipairs(espObjects[p]) do pcall(function() d:Remove() end) end
        espObjects[p] = nil
    end
end
local function addESP(p)
    cleanESP(p)
    local objs = {}
    if State.ESP.BoxESP or State.ESP.OutlineESP or State.ESP.NameESP or State.ESP.DistanceESP then
        espObjects[p] = objs
    end
end

RunService.Heartbeat:Connect(function()
    local cam = workspace.CurrentCamera
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        if not State.ESP.ESPTeammates and isTeammate(p) then
            cleanESP(p); continue
        end
        local char = p.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then cleanESP(p); continue end

        local screenPos, onScreen = cam:WorldToViewportPoint(hrp.Position)
        if not onScreen then cleanESP(p); continue end

        -- Drawing-based ESP
        pcall(function()
            if not espObjects[p] then espObjects[p] = {} end
            local col = getESPColor(p)

            if State.ESP.NameESP then
                local n = espObjects[p].nameLbl
                if not n then
                    n = Drawing.new("Text")
                    n.Center = true; n.Outline = true; n.Size = 13
                    n.Font = Drawing.Fonts.Plex
                    espObjects[p].nameLbl = n
                end
                n.Position = Vector2.new(screenPos.X, screenPos.Y - 40)
                n.Text = p.DisplayName
                n.Color = col
                n.Visible = true
            elseif espObjects[p].nameLbl then
                espObjects[p].nameLbl.Visible = false
            end

            if State.ESP.DistanceESP then
                local dist = math.floor((hrp.Position - cam.CFrame.Position).Magnitude)
                local d = espObjects[p].distLbl
                if not d then
                    d = Drawing.new("Text")
                    d.Center = true; d.Outline = true; d.Size = 11
                    d.Font = Drawing.Fonts.Plex
                    espObjects[p].distLbl = d
                end
                d.Position = Vector2.new(screenPos.X, screenPos.Y + 30)
                d.Text = dist .. " studs"
                d.Color = col
                d.Visible = true
            elseif espObjects[p].distLbl then
                espObjects[p].distLbl.Visible = false
            end

            if State.ESP.BoxESP then
                local top = cam:WorldToViewportPoint((hrp.Position + Vector3.new(0,3,0)))
                local bot = cam:WorldToViewportPoint((hrp.Position - Vector3.new(0,2.5,0)))
                local h2 = math.abs(top.Y - bot.Y)
                local w2 = h2 * 0.6
                local bx = espObjects[p].box
                if not bx then
                    bx = Drawing.new("Square")
                    bx.Filled = false; bx.Thickness = 1.5
                    espObjects[p].box = bx
                end
                bx.Position = Vector2.new(screenPos.X - w2/2, math.min(top.Y, bot.Y))
                bx.Size = Vector2.new(w2, h2)
                bx.Color = col
                bx.Visible = true
            elseif espObjects[p].box then
                espObjects[p].box.Visible = false
            end
        end)
    end
end)

Players.PlayerRemoving:Connect(function(p) cleanESP(p) end)

-- ── Misc loops ────────────────────────────────────────────────
UserInputService.JumpRequest:Connect(function()
    if not State.InfJump then return end
    local hrp = getHRP()
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 55, hrp.AssemblyLinearVelocity.Z) end
end)

RunService.Stepped:Connect(function()
    if State.Noclip then
        local c = getChar()
        if c then
            for _, p in ipairs(c:GetDescendants()) do
                if p:IsA("BasePart") then p.CanCollide = false end
            end
        end
    end
end)

-- Fly
local flyBF, flyIsFlying = nil, false
RunService.Heartbeat:Connect(function()
    if not State.Fly then
        if flyBF then flyBF:Destroy(); flyBF = nil; flyIsFlying = false end
        return
    end
    local hrp = getHRP()
    if not hrp then return end
    if not flyBF then
        flyBF = Instance.new("BodyVelocity", hrp)
        flyBF.MaxForce = Vector3.new(1e6,1e6,1e6)
        flyBF.Velocity = Vector3.zero
    end
    local cam = workspace.CurrentCamera
    local mv = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv = mv + cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv = mv - cam.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv = mv - cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv = mv + cam.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv = mv + Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then mv = mv - Vector3.new(0,1,0) end
    flyBF.Velocity = mv.Magnitude > 0 and mv.Unit * State.FlySpeed or Vector3.zero
end)

-- Anti-AFK
RunService.Heartbeat:Connect(function()
    if State.AntiAFK then
        pcall(function() VirtualUser:ActivateVirtualCursor(Vector2.new(math.random(-5,5), math.random(-5,5))) end)
    end
end)

-- Touch Kill
RunService.Heartbeat:Connect(function()
    if not State.TouchKill then return end
    local hrp = getHRP()
    if not hrp then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local c = p.Character
        local h = c and c:FindFirstChildOfClass("Humanoid")
        local r = c and c:FindFirstChild("HumanoidRootPart")
        if h and r and (hrp.Position - r.Position).Magnitude < 5 then
            h.Health = 0
        end
    end
end)

-- Auto-Respawn
LocalPlayer.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        if State.AutoRespawn then task.wait(1); LocalPlayer:LoadCharacter() end
    end)
    -- Reapply walk/jump on spawn
    task.wait(0.1)
    local h2 = char:FindFirstChildOfClass("Humanoid")
    if h2 then
        h2.WalkSpeed = State.WalkSpeed
        h2.UseJumpPower = true
        h2.JumpPower = State.JumpPower
    end
end)

-- ── Toggle UI keybind ────────────────────────────────────────
UserInputService.InputBegan:Connect(function(inp, gp)
    if gp then return end
    if State.UIKey and inp.KeyCode == State.UIKey then
        Gui.Enabled = not Gui.Enabled
        if not Gui.Enabled then FloatGui.Enabled = true end
    end
end)

-- ════════════════════════════════════════════════════════════════
--  START
-- ════════════════════════════════════════════════════════════════
setPage("Aimbot")

