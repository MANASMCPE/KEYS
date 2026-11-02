--[[
    ═══════════════════════════════════════════════════════════════════════════
      MONK SCRIPTS  •  ULTRA PREMIUM KEY SYSTEM  (v7)
      Particles · Shimmer · Ripples · Ring Spinner · Corner Accents · Glow
    ═══════════════════════════════════════════════════════════════════════════
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local CONFIG = {
    Prefix    = "MONK-",
    KeySite   = "https://keysystemnymomk.vercel.app/",
    ScriptURL = "https://pastefy.app/h2aM8Dj8/raw",

    Accent    = Color3.fromRGB(200, 28, 54),
    Accent2   = Color3.fromRGB(255, 92, 112),
    Accent3   = Color3.fromRGB(255, 160, 175),
    Accent4   = Color3.fromRGB(255, 220, 228),
    Dark      = Color3.fromRGB(22, 6, 10),
    TextMain  = Color3.fromRGB(255, 248, 250),
    TextSoft  = Color3.fromRGB(220, 160, 170),
    Success   = Color3.fromRGB(90, 215, 135),
    Warn      = Color3.fromRGB(255, 185, 70),
    Fail      = Color3.fromRGB(255, 80, 95),
}

--==================== HELPERS ====================--
local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local a = TweenService:Create(obj, info, props); a:Play(); return a
end

local function corner(p, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = p; return c
end

local function stroke(p, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.Accent; s.Thickness = thick or 1.5
    s.Transparency = trans or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = p; return s
end

local function gradient(p, rot, colors, trans)
    local g = Instance.new("UIGradient")
    g.Rotation = rot or 0
    local ks = {}
    for _, c in ipairs(colors) do table.insert(ks, ColorSequenceKeypoint.new(c[1], c[2])) end
    g.Color = ColorSequence.new(ks)
    if trans then
        local ns = {}
        for _, t in ipairs(trans) do table.insert(ns, NumberSequenceKeypoint.new(t[1], t[2])) end
        g.Transparency = NumberSequence.new(ns)
    end
    g.Parent = p; return g
end

--==================== CLEANUP ====================--
local pg = LP:WaitForChild("PlayerGui")
for _, gui in ipairs(pg:GetChildren()) do
    if gui.Name == "MonkKeySystem" then pcall(function() gui:Destroy() end) end
end
if gethui then
    local ok, hui = pcall(gethui)
    if ok and hui then
        for _, gui in ipairs(hui:GetChildren()) do
            if gui.Name == "MonkKeySystem" then pcall(function() gui:Destroy() end) end
        end
    end
end

--==================== SCREEN GUI ====================--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonkKeySystem"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = pg

local FRAME_W, FRAME_H = 500, 540

-- Multi-layer ambient glow
local function makeGlow(size, trans, zIndex)
    local g = Instance.new("Frame")
    g.AnchorPoint = Vector2.new(0.5, 0.5)
    g.Position = UDim2.fromScale(0.5, 0.5)
    g.Size = UDim2.fromOffset(FRAME_W + size, FRAME_H + size)
    g.BackgroundColor3 = CONFIG.Accent
    g.BackgroundTransparency = trans
    g.BorderSizePixel = 0
    g.ZIndex = zIndex
    g.Parent = screenGui
    corner(g, 32)
    return g
end
makeGlow(60, 0.96, 0)
makeGlow(36, 0.90, 0)
makeGlow(18, 0.80, 0)

-- Main frame
local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(FRAME_W, FRAME_H)
main.BackgroundColor3 = CONFIG.Dark
main.BackgroundTransparency = 0.02
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 1
main.Parent = screenGui
corner(main, 22)

-- Deep glass gradient
local mainGrad = gradient(main, 100, {
    {0.00, Color3.fromRGB(82, 18, 30)},
    {0.35, Color3.fromRGB(48, 11, 19)},
    {0.70, Color3.fromRGB(30, 7, 12)},
    {1.00, Color3.fromRGB(16, 3, 6)},
}, {{0.00, 0.02},{0.5, 0.08},{1.00, 0.18}})

-- Animated rotating border
local borderStroke = Instance.new("UIStroke")
borderStroke.Thickness = 1.8
borderStroke.Transparency = 0.05
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderStroke.Parent = main
local borderGrad = Instance.new("UIGradient")
borderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, CONFIG.Accent4),
    ColorSequenceKeypoint.new(0.20, CONFIG.Accent2),
    ColorSequenceKeypoint.new(0.50, CONFIG.Accent),
    ColorSequenceKeypoint.new(0.80, CONFIG.Accent2),
    ColorSequenceKeypoint.new(1.00, CONFIG.Accent4),
})
borderGrad.Parent = borderStroke
task.spawn(function()
    while borderGrad.Parent do
        borderGrad.Rotation = (borderGrad.Rotation + 3) % 360
        task.wait(0.04)
    end
end)

-- Inner highlight (glass reflection top)
local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(255, 220, 228)
innerStroke.Thickness = 1
innerStroke.Transparency = 0.9
innerStroke.Parent = main

-- Top glass reflection
local reflection = Instance.new("Frame")
reflection.Size = UDim2.new(1, -20, 0, 90)
reflection.Position = UDim2.fromOffset(10, 8)
reflection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
reflection.BackgroundTransparency = 0.96
reflection.BorderSizePixel = 0
reflection.ZIndex = 2
reflection.Parent = main
corner(reflection, 18)
gradient(reflection, 90, {{0.0, Color3.fromRGB(255,255,255)},{1.0, Color3.fromRGB(255,255,255)}}, {{0.0, 0.9},{1.0, 1.0}})

-- Particle dots floating inside
task.spawn(function()
    while main.Parent do
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(3, 3)
        dot.Position = UDim2.fromOffset(math.random(20, FRAME_W - 20), FRAME_H)
        dot.BackgroundColor3 = CONFIG.Accent3
        dot.BackgroundTransparency = 0.4
        dot.BorderSizePixel = 0
        dot.ZIndex = 2
        dot.Parent = main
        corner(dot, 2)
        local dur = math.random(40, 80) / 10
        tw(dot, {Position = UDim2.fromOffset(dot.Position.X.Offset + math.random(-20, 20), -10), BackgroundTransparency = 1}, dur, Enum.EasingStyle.Linear)
        task.delay(dur + 0.1, function() if dot then dot:Destroy() end end)
        task.wait(math.random(4, 10) / 10)
    end
end)

-- Corner accent marks
local function cornerAccent(posX, posY, anchor)
    local f = Instance.new("Frame")
    f.Size = UDim2.fromOffset(18, 2)
    f.Position = UDim2.fromOffset(posX, posY)
    f.AnchorPoint = anchor or Vector2.new(0, 0)
    f.BackgroundColor3 = CONFIG.Accent2
    f.BorderSizePixel = 0
    f.ZIndex = 4
    f.Parent = main
    corner(f, 1)
    local v = Instance.new("Frame")
    v.Size = UDim2.fromOffset(2, 18)
    v.Position = UDim2.fromOffset(0, 0)
    v.AnchorPoint = anchor or Vector2.new(0, 0)
    v.BackgroundColor3 = CONFIG.Accent2
    v.BorderSizePixel = 0
    v.ZIndex = 4
    v.Parent = main
    corner(v, 1)
    if anchor and anchor.X == 1 then
        v.Position = UDim2.fromOffset(posX - 2, posY)
    end
end
cornerAccent(14, 14, Vector2.new(0, 0))
cornerAccent(FRAME_W - 14, 14, Vector2.new(1, 0))
cornerAccent(14, FRAME_H - 14, Vector2.new(0, 1))
cornerAccent(FRAME_W - 14, FRAME_H - 14, Vector2.new(1, 1))

-- Mobile scale
local uiScale = Instance.new("UIScale")
uiScale.Parent = main
local function updateScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if vp.X < 1 or vp.Y < 1 then return end
    uiScale.Scale = math.clamp(math.min(vp.X/580, vp.Y/580), 0.5, 1)
end
updateScale()
task.spawn(function()
    local cam = workspace.CurrentCamera
    if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
    workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        local c = workspace.CurrentCamera
        if c then c:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
        updateScale()
    end)
end)

--==================== HEADER ====================--
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 78)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 5
topBar.Parent = main

-- Icon with rotating glow
local iconGlow = Instance.new("Frame")
iconGlow.Position = UDim2.fromOffset(20, 18)
iconGlow.Size = UDim2.fromOffset(48, 48)
iconGlow.BackgroundColor3 = CONFIG.Accent
iconGlow.BackgroundTransparency = 0.7
iconGlow.BorderSizePixel = 0
iconGlow.ZIndex = 5
iconGlow.Parent = topBar
corner(iconGlow, 15)
task.spawn(function()
    while iconGlow.Parent do
        tw(iconGlow, {BackgroundTransparency = 0.5}, 1, Enum.EasingStyle.Sine)
        task.wait(1)
        tw(iconGlow, {BackgroundTransparency = 0.8}, 1, Enum.EasingStyle.Sine)
        task.wait(1)
    end
end)

local iconBg = Instance.new("Frame")
iconBg.Position = UDim2.fromOffset(24, 22)
iconBg.Size = UDim2.fromOffset(40, 40)
iconBg.BorderSizePixel = 0
iconBg.ZIndex = 6
iconBg.Parent = topBar
corner(iconBg, 12)
gradient(iconBg, 135, {{0.0, CONFIG.Accent2},{0.5, CONFIG.Accent},{1.0, Color3.fromRGB(140, 15, 32)}})
stroke(iconBg, CONFIG.Accent4, 1.3, 0.3)

local iconText = Instance.new("TextLabel")
iconText.BackgroundTransparency = 1
iconText.Size = UDim2.fromScale(1, 1)
iconText.Font = Enum.Font.GothamBlack
iconText.Text = "M"
iconText.TextSize = 22
iconText.TextColor3 = Color3.fromRGB(255, 248, 250)
iconText.ZIndex = 7
iconText.Parent = iconBg
gradient(iconText, 90, {{0.0, Color3.fromRGB(255,255,255)},{1.0, Color3.fromRGB(255,220,230)}})

-- Title with shimmer
local titleLbl = Instance.new("TextLabel")
titleLbl.BackgroundTransparency = 1
titleLbl.Position = UDim2.fromOffset(76, 16)
titleLbl.Size = UDim2.new(1, -170, 0, 28)
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.Text = "MONK SCRIPTS"
titleLbl.TextSize = 22
titleLbl.TextColor3 = CONFIG.TextMain
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 6
titleLbl.Parent = topBar
local titleGrad = gradient(titleLbl, 0, {
    {0.00, Color3.fromRGB(255, 255, 255)},
    {0.45, Color3.fromRGB(255, 255, 255)},
    {0.50, Color3.fromRGB(255, 190, 200)},
    {0.55, Color3.fromRGB(255, 255, 255)},
    {1.00, Color3.fromRGB(255, 255, 255)},
})
task.spawn(function()
    local offset = 0
    while titleGrad.Parent do
        offset = (offset + 0.008) % 1
        local k1 = offset - 0.05
        local k2 = offset
        local k3 = offset + 0.05
        local function clampK(k) return math.clamp(k, 0, 1) end
        titleGrad.Offset = Vector2.new(-1 + offset * 3, 0)
        task.wait(0.03)
    end
end)

local subLbl = Instance.new("TextLabel")
subLbl.BackgroundTransparency = 1
subLbl.Position = UDim2.fromOffset(76, 44)
subLbl.Size = UDim2.new(1, -170, 0, 16)
subLbl.Font = Enum.Font.GothamBold
subLbl.Text = "PREMIUM KEY SYSTEM  ◆  ULTRA"
subLbl.TextSize = 10
subLbl.TextColor3 = CONFIG.Accent2
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.ZIndex = 6
subLbl.Parent = topBar

-- Pulsing status dot
local statusDotGlow = Instance.new("Frame")
statusDotGlow.Position = UDim2.fromOffset(63, 49)
statusDotGlow.Size = UDim2.fromOffset(12, 12)
statusDotGlow.BackgroundColor3 = CONFIG.Accent2
statusDotGlow.BackgroundTransparency = 0.7
statusDotGlow.BorderSizePixel = 0
statusDotGlow.ZIndex = 6
statusDotGlow.Parent = topBar
corner(statusDotGlow, 6)

local statusDot = Instance.new("Frame")
statusDot.Position = UDim2.fromOffset(66, 52)
statusDot.Size = UDim2.fromOffset(6, 6)
statusDot.BackgroundColor3 = CONFIG.Accent2
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 7
statusDot.Parent = topBar
corner(statusDot, 3)

task.spawn(function()
    while statusDot.Parent do
        tw(statusDotGlow, {Size = UDim2.fromOffset(16, 16), Position = UDim2.fromOffset(61, 47), BackgroundTransparency = 0.5}, 0.8, Enum.EasingStyle.Sine)
        task.wait(0.8)
        tw(statusDotGlow, {Size = UDim2.fromOffset(12, 12), Position = UDim2.fromOffset(63, 49), BackgroundTransparency = 0.8}, 0.8, Enum.EasingStyle.Sine)
        task.wait(0.8)
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -20, 0, 22)
closeBtn.Size = UDim2.fromOffset(34, 34)
closeBtn.BackgroundColor3 = Color3.fromRGB(52, 12, 20)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15
closeBtn.TextColor3 = CONFIG.Accent2
closeBtn.AutoButtonColor = false
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 7
closeBtn.Parent = topBar
corner(closeBtn, 10)
local closeStroke = stroke(closeBtn, CONFIG.Accent, 1.2, 0.4)

closeBtn.MouseEnter:Connect(function()
    tw(closeBtn, {BackgroundColor3 = CONFIG.Accent, TextColor3 = CONFIG.TextMain}, 0.16)
    tw(closeStroke, {Transparency = 0.1, Thickness = 2}, 0.16)
end)
closeBtn.MouseLeave:Connect(function()
    tw(closeBtn, {BackgroundColor3 = Color3.fromRGB(52, 12, 20), TextColor3 = CONFIG.Accent2}, 0.16)
    tw(closeStroke, {Transparency = 0.4, Thickness = 1.2}, 0.16)
end)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

-- Divider line with glow
local dividerGlow = Instance.new("Frame")
dividerGlow.Position = UDim2.fromOffset(22, 72)
dividerGlow.Size = UDim2.new(1, -44, 0, 4)
dividerGlow.BackgroundColor3 = CONFIG.Accent
dividerGlow.BackgroundTransparency = 0.7
dividerGlow.BorderSizePixel = 0
dividerGlow.ZIndex = 3
dividerGlow.Parent = main
corner(dividerGlow, 2)

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(22, 74)
divider.Size = UDim2.new(1, -44, 0, 1)
divider.BackgroundColor3 = CONFIG.Accent2
divider.BackgroundTransparency = 0.15
divider.BorderSizePixel = 0
divider.ZIndex = 4
divider.Parent = main

--==================== INPUT ====================--
local inputLbl = Instance.new("TextLabel")
inputLbl.BackgroundTransparency = 1
inputLbl.Position = UDim2.fromOffset(24, 90)
inputLbl.Size = UDim2.new(1, -48, 0, 16)
inputLbl.Font = Enum.Font.GothamBold
inputLbl.Text = "◈  ENTER YOUR LICENSE KEY"
inputLbl.TextSize = 10
inputLbl.TextColor3 = CONFIG.TextSoft
inputLbl.TextXAlignment = Enum.TextXAlignment.Left
inputLbl.ZIndex = 3
inputLbl.Parent = main

local inputHolder = Instance.new("Frame")
inputHolder.Position = UDim2.fromOffset(22, 110)
inputHolder.Size = UDim2.new(1, -44, 0, 48)
inputHolder.BackgroundColor3 = Color3.fromRGB(12, 3, 6)
inputHolder.BackgroundTransparency = 0.1
inputHolder.BorderSizePixel = 0
inputHolder.ZIndex = 3
inputHolder.Parent = main
corner(inputHolder, 12)
gradient(inputHolder, 90, {
    {0.0, Color3.fromRGB(18, 5, 9)},
    {1.0, Color3.fromRGB(32, 9, 15)},
}, {{0.0, 0.05},{1.0, 0.25}})
local inputStroke = stroke(inputHolder, CONFIG.Accent, 1.3, 0.4)

local inputGlowStroke = Instance.new("UIStroke")
inputGlowStroke.Color = CONFIG.Accent2
inputGlowStroke.Thickness = 4
inputGlowStroke.Transparency = 0.92
inputGlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
inputGlowStroke.Parent = inputHolder

-- Key icon
local keyIcon = Instance.new("TextLabel")
keyIcon.BackgroundTransparency = 1
keyIcon.Position = UDim2.fromOffset(14, 0)
keyIcon.Size = UDim2.fromOffset(20, 48)
keyIcon.Font = Enum.Font.GothamBold
keyIcon.Text = "⚿"
keyIcon.TextSize = 18
keyIcon.TextColor3 = CONFIG.Accent2
keyIcon.ZIndex = 4
keyIcon.Parent = inputHolder

local keyBox = Instance.new("TextBox")
keyBox.Position = UDim2.fromOffset(42, 0)
keyBox.Size = UDim2.new(1, -56, 1, 0)
keyBox.BackgroundTransparency = 1
keyBox.Font = Enum.Font.GothamMedium
keyBox.Text = ""
keyBox.PlaceholderText = "MONK-XXXXXXXXXX"
keyBox.PlaceholderColor3 = Color3.fromRGB(130, 65, 78)
keyBox.TextColor3 = CONFIG.TextMain
keyBox.TextSize = 14
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.ClearTextOnFocus = false
keyBox.ZIndex = 4
keyBox.Parent = inputHolder

keyBox.Focused:Connect(function()
    tw(inputStroke, {Transparency = 0.05, Thickness = 1.8}, 0.2)
    tw(inputGlowStroke, {Transparency = 0.55, Thickness = 5}, 0.3)
    tw(keyIcon, {TextColor3 = CONFIG.Accent4}, 0.2)
end)
keyBox.FocusLost:Connect(function(enter)
    tw(inputStroke, {Transparency = 0.4, Thickness = 1.3}, 0.25)
    tw(inputGlowStroke, {Transparency = 0.92, Thickness = 4}, 0.35)
    tw(keyIcon, {TextColor3 = CONFIG.Accent2}, 0.25)
    if enter and _G.__MONK_VERIFY then _G.__MONK_VERIFY() end
end)

--==================== BUTTON FACTORY ====================--
local function makeButton(text, yPos, primary, icon)
    local btn = Instance.new("TextButton")
    btn.Position = UDim2.fromOffset(22, yPos)
    btn.Size = UDim2.new(1, -44, 0, 46)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = main
    corner(btn, 12)
    local scale = Instance.new("UIScale"); scale.Parent = btn

    if primary then
        btn.BackgroundColor3 = CONFIG.Accent
        gradient(btn, 90, {{0.0, Color3.fromRGB(232, 55, 82)},{0.5, Color3.fromRGB(196, 28, 54)},{1.0, Color3.fromRGB(148, 16, 34)}})
    else
        btn.BackgroundColor3 = Color3.fromRGB(56, 14, 22)
        gradient(btn, 90, {{0.0, Color3.fromRGB(78, 20, 32)},{1.0, Color3.fromRGB(50, 12, 20)}})
    end

    local s = stroke(btn, primary and CONFIG.Accent4 or CONFIG.Accent2, 1.4, primary and 0.3 or 0.4)

    -- Shimmer overlay
    local shimmer = Instance.new("Frame")
    shimmer.Size = UDim2.new(0, 60, 1, 0)
    shimmer.Position = UDim2.new(0, -80, 0, 0)
    shimmer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    shimmer.BackgroundTransparency = 0.85
    shimmer.BorderSizePixel = 0
    shimmer.ZIndex = 4
    shimmer.Parent = btn
    local shimmerGrad = Instance.new("UIGradient")
    shimmerGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1),
    })
    shimmerGrad.Parent = shimmer

    -- Icon + label
    local iconLbl = Instance.new("TextLabel")
    iconLbl.BackgroundTransparency = 1
    iconLbl.Position = UDim2.fromOffset(16, 0)
    iconLbl.Size = UDim2.fromOffset(20, 46)
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.Text = icon or ""
    iconLbl.TextSize = 16
    iconLbl.TextColor3 = primary and Color3.fromRGB(255, 240, 245) or CONFIG.Accent3
    iconLbl.ZIndex = 5
    iconLbl.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.fromOffset(0, 0)
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text
    lbl.TextSize = 14
    lbl.TextColor3 = primary and Color3.fromRGB(255, 248, 250) or CONFIG.Accent3
    lbl.ZIndex = 5
    lbl.Parent = btn

    -- Ripple function
    local function doRipple(mx, my)
        local ripple = Instance.new("Frame")
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.fromOffset(mx, my)
        ripple.Size = UDim2.fromOffset(0, 0)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ripple.BackgroundTransparency = 0.7
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 6
        ripple.Parent = btn
        corner(ripple, 100)
        tw(ripple, {Size = UDim2.fromOffset(200, 200), BackgroundTransparency = 1}, 0.5)
        task.delay(0.55, function() if ripple then ripple:Destroy() end end)
    end

    btn.MouseEnter:Connect(function()
        tw(scale, {Scale = 1.03}, 0.18, Enum.EasingStyle.Back)
        tw(s, {Transparency = 0.05, Thickness = 2.2}, 0.2)
        tw(shimmer, {Position = UDim2.new(1, 20, 0, 0)}, 0.7, Enum.EasingStyle.Quad)
        task.delay(0.7, function()
            if shimmer and shimmer.Parent then
                shimmer.Position = UDim2.new(0, -80, 0, 0)
            end
        end)
    end)
    btn.MouseLeave:Connect(function()
        tw(scale, {Scale = 1}, 0.22)
        tw(s, {Transparency = primary and 0.3 or 0.4, Thickness = 1.4}, 0.24)
    end)
    btn.MouseButton1Down:Connect(function()
        tw(scale, {Scale = 0.96}, 0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(scale, {Scale = 1.03}, 0.14)
        local mx, my = UserInputService:GetMouseLocation()
        doRipple(mx - btn.AbsolutePosition.X, my - btn.AbsolutePosition.Y)
    end)

    return btn, lbl, s, scale, iconLbl
end

local verifyBtn, verifyLbl, verifyStroke, verifyScale, verifyIcon = makeButton("VERIFY KEY", 170, true, "✓")
local getKeyBtn, getKeyLbl, getKeyStroke, getKeyScale, getKeyIcon = makeButton("GET KEY", 224, false, "🔑")

--==================== RING SPINNER (inside verify button) ====================--
local spinnerHolder = Instance.new("Frame")
spinnerHolder.Size = UDim2.fromOffset(20, 20)
spinnerHolder.Position = UDim2.new(0.5, -10, 0.5, -10)
spinnerHolder.BackgroundTransparency = 1
spinnerHolder.Visible = false
spinnerHolder.ZIndex = 10
spinnerHolder.Parent = verifyBtn

local ring = Instance.new("Frame")
ring.Size = UDim2.fromScale(1, 1)
ring.BackgroundTransparency = 1
ring.ZIndex = 10
ring.Parent = spinnerHolder
local ringGrad = Instance.new("UIGradient")
ringGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 255, 255, 0)),
})
ringGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0.0, 0),
    NumberSequenceKeypoint.new(1.0, 1),
})
ringGrad.Parent = ring
local ringStroke = Instance.new("UIStroke")
ringStroke.Color = Color3.fromRGB(255, 255, 255)
ringStroke.Thickness = 3
ringStroke.Transparency = 0
ringStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
ringStroke.Parent = ring
local ringCorner = corner(ring, 100)

local spinnerActive = false
task.spawn(function()
    while spinnerHolder.Parent do
        if spinnerActive then
            ringGrad.Rotation = (ringGrad.Rotation + 12) % 360
        end
        task.wait(0.02)
    end
end)

local function showSpinner(show)
    spinnerActive = show
    spinnerHolder.Visible = show
    if show then
        verifyIcon.Visible = false
    else
        verifyIcon.Visible = true
    end
end

--==================== DEBUG CONSOLE ====================--
local debugLabel = Instance.new("TextLabel")
debugLabel.BackgroundTransparency = 1
debugLabel.Position = UDim2.fromOffset(24, 284)
debugLabel.Size = UDim2.new(1, -48, 0, 16)
debugLabel.Font = Enum.Font.GothamBold
debugLabel.Text = "◈  DIAGNOSTIC LOG"
debugLabel.TextSize = 10
debugLabel.TextColor3 = CONFIG.Accent2
debugLabel.TextXAlignment = Enum.TextXAlignment.Left
debugLabel.ZIndex = 3
debugLabel.Parent = main

local debugBox = Instance.new("Frame")
debugBox.Position = UDim2.fromOffset(22, 302)
debugBox.Size = UDim2.new(1, -44, 0, 200)
debugBox.BackgroundColor3 = Color3.fromRGB(6, 1, 3)
debugBox.BackgroundTransparency = 0.05
debugBox.BorderSizePixel = 0
debugBox.ZIndex = 3
debugBox.Parent = main
corner(debugBox, 11)
stroke(debugBox, CONFIG.Accent, 1.2, 0.5)
gradient(debugBox, 90, {
    {0.0, Color3.fromRGB(10, 3, 6)},
    {1.0, Color3.fromRGB(6, 1, 3)},
})

local debugScroll = Instance.new("ScrollingFrame")
debugScroll.Size = UDim2.fromScale(1, 1)
debugScroll.BackgroundTransparency = 1
debugScroll.BorderSizePixel = 0
debugScroll.ScrollBarThickness = 3
debugScroll.ScrollBarImageColor3 = CONFIG.Accent2
debugScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
debugScroll.ZIndex = 4
debugScroll.Parent = debugBox

local debugLayout = Instance.new("UIListLayout")
debugLayout.Padding = UDim.new(0, 2)
debugLayout.SortOrder = Enum.SortOrder.LayoutOrder
debugLayout.Parent = debugScroll

local debugPad = Instance.new("UIPadding")
debugPad.PaddingLeft = UDim.new(0, 10)
debugPad.PaddingRight = UDim.new(0, 10)
debugPad.PaddingTop = UDim.new(0, 8)
debugPad.PaddingBottom = UDim.new(0, 8)
debugPad.Parent = debugScroll

local logOrder = 0
local function log(msg, color)
    logOrder = logOrder + 1
    color = color or CONFIG.TextMain
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.new(1, 0, 0, 14)
    l.Font = Enum.Font.Code
    l.Text = "▸ " .. tostring(msg)
    l.TextSize = 11
    l.TextColor3 = color
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.TextWrapped = true
    l.LayoutOrder = logOrder
    l.ZIndex = 5
    l.Parent = debugScroll
    debugScroll.CanvasSize = UDim2.new(0, 0, 0, debugLayout.AbsoluteContentSize.Y + 16)
    debugScroll.CanvasPosition = Vector2.new(0, debugScroll.CanvasSize.Y.Offset)
    print("[MONK]", msg)
end

-- Footer
local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(22, FRAME_H - 26)
footer.Size = UDim2.new(1, -44, 0, 14)
footer.Font = Enum.Font.GothamMedium
footer.Text = "◆  SECURE ACCESS  ◆  MONK SCRIPTS  ◆"
footer.TextSize = 9
footer.TextColor3 = CONFIG.Accent3
footer.TextTransparency = 0.35
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 3
footer.Parent = main

--==================== DRAG ====================--
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil
topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
topBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--==================== ENV CHECK ====================--
log("=== ENVIRONMENT ===", CONFIG.Accent2)

local execName = "Unknown"
if syn then execName = "Synapse"
elseif Krnl then execName = "Krnl"
elseif fluxus then execName = "Fluxus"
elseif is_sirhurt_closure then execName = "SirHurt"
elseif secure_load then execName = "Sentinel"
elseif identifyexecutor then
    local ok, n = pcall(identifyexecutor)
    if ok then execName = n end
end
log("Executor: " .. execName, CONFIG.Warn)

local lsFn, lsName
if loadstring and pcall(loadstring, "return 1") then
    lsFn, lsName = loadstring, "loadstring"
elseif syn and syn.loadstring and pcall(syn.loadstring, "return 1") then
    lsFn, lsName = syn.loadstring, "syn.loadstring"
elseif fluxus and fluxus.loadstring and pcall(fluxus.loadstring, "return 1") then
    lsFn, lsName = fluxus.loadstring, "fluxus.loadstring"
elseif load and pcall(load, "return 1") then
    lsFn, lsName = load, "load"
end
if lsFn then log("✓ loadstring: " .. lsName, CONFIG.Success)
else log("✗ loadstring NOT AVAILABLE", CONFIG.Fail) end

local httpFns = {}
if syn and syn.request then table.insert(httpFns, "syn.request") end
if fluxus and fluxus.request then table.insert(httpFns, "fluxus.request") end
if http and http.request then table.insert(httpFns, "http.request") end
if request then table.insert(httpFns, "request") end
if game.HttpGet then table.insert(httpFns, "game:HttpGet") end
if httpget then table.insert(httpFns, "httpget") end
if #httpFns > 0 then log("✓ HTTP: " .. table.concat(httpFns, ", "), CONFIG.Success)
else log("✗ No HTTP available!", CONFIG.Fail) end

log("=== READY ===", CONFIG.Accent2)

--==================== VALIDATION ====================--
local function isValidKey(raw)
    if type(raw) ~= "string" then return false end
    local k = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if #k <= #CONFIG.Prefix then return false end
    return string.upper(string.sub(k, 1, #CONFIG.Prefix)) == CONFIG.Prefix
end

--==================== HTTP ====================--
local HEADERS = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Roblox/WinInet",
    ["Accept"]     = "*/*",
}

local function tryHttpGet(url)
    log("Trying game:HttpGet...", CONFIG.TextSoft)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(res) == "string" and #res > 0 then return res, "game:HttpGet" end
    log("  failed: " .. (ok and "empty" or tostring(res)), CONFIG.Warn)
    if httpget then
        log("Trying httpget()...", CONFIG.TextSoft)
        local ok2, res2 = pcall(httpget, url)
        if ok2 and type(res2) == "string" and #res2 > 0 then return res2, "httpget" end
        log("  failed: " .. (ok2 and "empty" or tostring(res2)), CONFIG.Warn)
    end
    return nil
end

local function tryRequest(url)
    local list = {
        {syn and syn.request, "syn.request"},
        {fluxus and fluxus.request, "fluxus.request"},
        {http and http.request, "http.request"},
        {request, "request"},
    }
    for _, pair in ipairs(list) do
        if pair[1] then
            log("Trying " .. pair[2] .. "...", CONFIG.TextSoft)
            local ok, res = pcall(pair[1], {Url = url, Method = "GET", Headers = HEADERS})
            if ok and res then
                local body = res.Body or res.body
                if type(body) == "string" and #body > 0 then return body, pair[2] end
                log("  " .. pair[2] .. ": empty", CONFIG.Warn)
            else
                log("  " .. pair[2] .. ": " .. tostring(res), CONFIG.Warn)
            end
        end
    end
    return nil
end

local function looksLikeHtml(s)
    if type(s) ~= "string" or #s == 0 then return true end
    local head = s:sub(1, 800):lower()
    return (head:find("<!doctype") or head:find("<html") or head:find("<head")
        or head:find("404") or head:find("not found")) ~= nil
end

local function fetchScript(url)
    log("=== FETCHING SCRIPT ===", CONFIG.Accent2)
    log("URL: " .. url, CONFIG.TextSoft)
    local body, method = tryHttpGet(url)
    if not body then body, method = tryRequest(url) end
    if body then
        log("✓ Fetched via " .. method .. " (" .. #body .. " bytes)", CONFIG.Success)
        log("Preview: " .. body:sub(1, 70):gsub("\n", " "), CONFIG.TextSoft)
        return body, method
    end
    log("✗ All HTTP methods failed!", CONFIG.Fail)
    return nil
end

--==================== NOTIFICATIONS ====================--
local activeNotifs = {}
local function notify(titleText, msgText, accentColor, duration)
    duration = duration or 3
    if not screenGui.Parent then return end
    local idx = #activeNotifs

    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0, -100)
    holder.Size = UDim2.fromOffset(400, 68)
    holder.BackgroundColor3 = Color3.fromRGB(28, 8, 12)
    holder.BackgroundTransparency = 0.04
    holder.BorderSizePixel = 0
    holder.ZIndex = 200
    holder.Parent = screenGui
    corner(holder, 14)
    gradient(holder, 90, {
        {0.0, Color3.fromRGB(62, 18, 26)},
        {1.0, Color3.fromRGB(26, 7, 11)},
    })
    stroke(holder, accentColor, 1.5, 0.2)

    -- Glow behind accent bar
    local barGlow = Instance.new("Frame")
    barGlow.Position = UDim2.fromOffset(-3, 10)
    barGlow.Size = UDim2.new(0, 10, 1, -20)
    barGlow.BackgroundColor3 = accentColor
    barGlow.BackgroundTransparency = 0.8
    barGlow.BorderSizePixel = 0
    barGlow.ZIndex = 200
    barGlow.Parent = holder
    corner(barGlow, 5)

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(0, 12)
    bar.Size = UDim2.new(0, 4, 1, -24)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.ZIndex = 201
    bar.Parent = holder
    corner(bar, 2)

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.fromOffset(22, 10)
    t.Size = UDim2.new(1, -36, 0, 18)
    t.Font = Enum.Font.GothamBold
    t.Text = "◆ " .. titleText
    t.TextSize = 13
    t.TextColor3 = accentColor
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 201
    t.Parent = holder

    local m = Instance.new("TextLabel")
    m.BackgroundTransparency = 1
    m.Position = UDim2.fromOffset(22, 30)
    m.Size = UDim2.new(1, -36, 0, 28)
    m.Font = Enum.Font.Gotham
    m.Text = msgText
    m.TextSize = 11
    m.TextColor3 = Color3.fromRGB(255, 242, 244)
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextYAlignment = Enum.TextYAlignment.Top
    m.TextWrapped = true
    m.ZIndex = 201
    m.Parent = holder

    table.insert(activeNotifs, holder)
    local targetY = 20 + idx * 78
    tw(holder, {Position = UDim2.new(0.5, 0, 0, targetY)}, 0.34, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        if holder and holder.Parent then
            tw(holder, {Position = UDim2.new(0.5, 0, 0, -100)}, 0.3)
            task.wait(0.35)
            for i, v in ipairs(activeNotifs) do
                if v == holder then table.remove(activeNotifs, i) break end
            end
            if holder then holder:Destroy() end
        end
    end)
end

--==================== UNLOCK ====================--
local unlocking = false

local function unlockScript()
    if unlocking then return end
    unlocking = true
    verifyLbl.Text = "VERIFYING"
    verifyBtn.Interactable = false
    showSpinner(true)
    verifyScale.Scale = 1

    log("=== VERIFY START ===", CONFIG.Accent2)

    -- Success flash ring
    local flash = Instance.new("UIStroke")
    flash.Color = CONFIG.Success
    flash.Thickness = 6
    flash.Transparency = 0.3
    flash.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    flash.Parent = verifyBtn
    tw(flash, {Transparency = 1, Thickness = 12}, 0.8)
    task.delay(0.85, function() if flash and flash.Parent then flash:Destroy() end end)

    if not lsFn then
        log("✗ loadstring disabled", CONFIG.Fail)
        notify("EXECUTOR ERROR", "loadstring disabled. Executor settings me ON karo.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        showSpinner(false)
        return
    end
    log("✓ loadstring: " .. lsName, CONFIG.Success)

    local source = fetchScript(CONFIG.ScriptURL)
    if not source then
        log("✗ FETCH FAILED", CONFIG.Fail)
        notify("FETCH FAILED", "Internet/URL issue. Log dekho.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        showSpinner(false)
        return
    end

    if looksLikeHtml(source) then
        log("✗ HTML detected", CONFIG.Fail)
        notify("URL ERROR", "URL galat/expired. Log dekho.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        showSpinner(false)
        return
    end
    log("✓ Looks like Lua", CONFIG.Success)

    log("Compiling...", CONFIG.TextSoft)
    local fn, compileErr = lsFn(source)
    if not fn then
        log("✗ COMPILE ERROR", CONFIG.Fail)
        log("  " .. tostring(compileErr):sub(1, 180), CONFIG.Fail)
        notify("COMPILE ERROR", tostring(compileErr):sub(1, 100), CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        showSpinner(false)
        return
    end
    log("✓ Compiled OK", CONFIG.Success)

    log("Executing...", CONFIG.Warn)
    notify("KEY VERIFIED", "Script execute ho rahi hai...", CONFIG.Success, 2.5)

    -- Fade out animation
    for _, child in ipairs(screenGui:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            pcall(function() tw(child, {TextTransparency = 1}, 0.35) end)
        end
        if child:IsA("Frame") or child:IsA("ScrollingFrame") then
            pcall(function() tw(child, {BackgroundTransparency = 1}, 0.35) end)
        end
        if child:IsA("UIStroke") then
            pcall(function() tw(child, {Transparency = 1}, 0.35) end)
        end
    end

    task.wait(0.5)
    screenGui:Destroy()
    task.wait(0.1)

    local ok, runErr = pcall(fn)
    if not ok then
        warn("[MONK] Runtime error: " .. tostring(runErr))
    else
        print("[MONK] Script executed ✓")
    end
end

local function verifyKey()
    if unlocking then
        log("Already verifying...", CONFIG.Warn)
        return
    end
    log("=== KEY CHECK ===", CONFIG.Accent2)
    log("Input: " .. (keyBox.Text == "" and "(empty)" or keyBox.Text), CONFIG.TextSoft)

    if isValidKey(keyBox.Text) then
        log("✓ Format OK", CONFIG.Success)
        unlockScript()
    else
        log("✗ Invalid format", CONFIG.Fail)
        notify("INVALID KEY", "Key galat hai! MONK- se start honi chahiye.", CONFIG.Fail, 3)

        tw(inputStroke, {Color = CONFIG.Fail, Transparency = 0}, 0.1)
        tw(inputGlowStroke, {Color = CONFIG.Fail, Transparency = 0.3}, 0.1)
        task.wait(0.15)
        tw(inputStroke, {Color = CONFIG.Accent, Transparency = 0.4}, 0.4)
        tw(inputGlowStroke, {Color = CONFIG.Accent2, Transparency = 0.92}, 0.5)

        local orig = main.Position
        for i = 1, 6 do
            main.Position = orig + UDim2.fromOffset((i % 2 == 0) and 7 or -7, 0)
            task.wait(0.035)
        end
        main.Position = orig
    end
end

_G.__MONK_VERIFY = verifyKey
verifyBtn.MouseButton1Click:Connect(verifyKey)
keyBox.FocusLost:Connect(function(enter)
    if enter and _G.__MONK_VERIFY then _G.__MONK_VERIFY() end
end)

--==================== GET KEY ====================--
getKeyBtn.MouseButton1Click:Connect(function()
    local copied = false
    if setclipboard then copied = pcall(setclipboard, CONFIG.KeySite) end
    if not copied and toclipboard then copied = pcall(toclipboard, CONFIG.KeySite) end
    if not copied and syn and syn.setclipboard then copied = pcall(syn.setclipboard, CONFIG.KeySite) end

    if copied then
        notify("KEY LINK COPIED", "key system link copied ✓", CONFIG.Success, 3)
    else
        notify("KEY LINK", "keysystemnymomk.vercel.app", CONFIG.Warn, 4)
    end

    local old = getKeyLbl.Text
    getKeyLbl.Text = "COPIED ✓"
    tw(getKeyStroke, {Color = CONFIG.Success, Transparency = 0.05}, 0.16)
    task.delay(1.6, function()
        if getKeyLbl and getKeyLbl.Parent then getKeyLbl.Text = old end
        if getKeyStroke and getKeyStroke.Parent then
            tw(getKeyStroke, {Color = CONFIG.Accent2, Transparency = 0.4}, 0.3)
        end
    end)
end)

--==================== ENTRANCE ====================--
main.BackgroundTransparency = 1
for _, d in ipairs(main:GetDescendants()) do
    if d:IsA("TextLabel") or d:IsA("TextButton") then
        d.TextTransparency = d.TextTransparency + 0
    end
end
tw(main, {BackgroundTransparency = 0.02}, 0.5)

log("=== GUI READY ===", CONFIG.Success)
notify("READY", "Apni MONK- key enter karke verify karo.", CONFIG.Accent2, 3)