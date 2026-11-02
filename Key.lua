--[[
    ═══════════════════════════════════════════════════════════════════════
      MONK SCRIPTS  •  PREMIUM KEY SYSTEM  (v4 — Premium Edition)
      Glassmorphism · Animated Border · Hover Physics · Pulsing Accents
    ═══════════════════════════════════════════════════════════════════════
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

--==================== CONFIG ====================--
local CONFIG = {
    Prefix    = "MONK-",
    KeySite   = "https://keysystemnymomk.vercel.app/",
    ScriptURL = "https://monk-scripts-novoline-loaderlua.vercel.app/?EXECUTOR=true",

    Accent    = Color3.fromRGB(200, 28, 54),
    Accent2   = Color3.fromRGB(255, 92, 112),
    Accent3   = Color3.fromRGB(255, 160, 175),
    Dark      = Color3.fromRGB(28, 8, 13),
    Dark2     = Color3.fromRGB(46, 12, 20),
    Dark3     = Color3.fromRGB(62, 16, 26),
    TextMain  = Color3.fromRGB(255, 246, 248),
    TextSoft  = Color3.fromRGB(220, 160, 170),
    Success   = Color3.fromRGB(90, 215, 135),
    Warn      = Color3.fromRGB(255, 185, 70),
    Fail      = Color3.fromRGB(255, 80, 95),
}
--================================================--

--==================== HELPERS ====================--
local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local a = TweenService:Create(obj, info, props); a:Play(); return a
end

local function corner(parent, r)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, r or 10); c.Parent = parent; return c
end

local function stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.Accent; s.Thickness = thick or 1.5
    s.Transparency = trans or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent; return s
end

local function gradient(parent, rot, colors, trans)
    local g = Instance.new("UIGradient")
    g.Rotation = rot or 0
    local ks = {}
    for _, c in ipairs(colors) do
        table.insert(ks, ColorSequenceKeypoint.new(c[1], c[2]))
    end
    g.Color = ColorSequence.new(ks)
    if trans then
        local ns = {}
        for _, t in ipairs(trans) do
            table.insert(ns, NumberSequenceKeypoint.new(t[1], t[2]))
        end
        g.Transparency = NumberSequence.new(ns)
    end
    g.Parent = parent
    return g
end

--==================== ROBUST HTTP ====================--
local HEADERS = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Roblox/WinInet",
    ["Accept"]     = "text/plain, */*",
}

local function tryRequest(url)
    local execs = { syn and syn.request, fluxus and fluxus.request, http and http.request, request }
    for _, fn in ipairs(execs) do
        if fn then
            local ok, res = pcall(fn, {Url = url, Method = "GET", Headers = HEADERS})
            if ok and res then
                local body = res.Body or res.body
                if type(body) == "string" and #body > 0 then return body, "request()" end
            end
        end
    end
    return nil
end

local function tryHttpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(res) == "string" and #res > 0 then return res, "game:HttpGet" end
    if httpget then
        local ok2, res2 = pcall(httpget, url)
        if ok2 and type(res2) == "string" and #res2 > 0 then return res2, "httpget" end
    end
    return nil
end

local function fetchScript(url)
    local urls = {
        url,
        url:gsub("%?EXECUTOR=true$", ""),
        url:gsub("%?EXECUTOR=true$", "?executor=true"),
    }
    for _, u in ipairs(urls) do
        local body, method = tryHttpGet(u)
        if not body then body, method = tryRequest(u) end
        if body then
            print(string.format("[MONK] Fetched via %s (%d bytes)", tostring(method), #body))
            return body, method
        end
    end
    return nil
end

local function looksLikeHtml(s)
    if type(s) ~= "string" or #s == 0 then return true end
    local head = s:sub(1, 500):lower()
    return (head:find("<!doctype") or head:find("<html") or head:find("<head")) ~= nil
end

local function getLoadstring()
    if loadstring and pcall(loadstring, "return 1") then return loadstring, "loadstring" end
    local list = {
        {syn and syn.loadstring, "syn.loadstring"},
        {fluxus and fluxus.loadstring, "fluxus.loadstring"},
        {load, "load"},
    }
    for _, p in ipairs(list) do
        if p[1] and pcall(p[1], "return 1") then return p[1], p[2] end
    end
    return nil
end
--================================================--

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
--================================================--

--==================== SCREEN GUI ====================--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonkKeySystem"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = pg

local FRAME_W, FRAME_H = 420, 350

-- Shadow / ambient glow frame behind main
local ambient = Instance.new("Frame")
ambient.AnchorPoint = Vector2.new(0.5, 0.5)
ambient.Position = UDim2.fromScale(0.5, 0.5)
ambient.Size = UDim2.fromOffset(FRAME_W + 24, FRAME_H + 24)
ambient.BackgroundColor3 = CONFIG.Accent
ambient.BackgroundTransparency = 0.88
ambient.BorderSizePixel = 0
ambient.ZIndex = 0
ambient.Parent = screenGui
corner(ambient, 28)

-- Main frame
local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(FRAME_W, FRAME_H)
main.BackgroundColor3 = CONFIG.Dark
main.BackgroundTransparency = 0.06
main.BorderSizePixel = 0
main.ClipsDescendants = false
main.ZIndex = 1
main.Parent = screenGui
corner(main, 20)

-- Glassy background gradient
gradient(main, 100, {
    {0.00, Color3.fromRGB(72, 16, 26)},
    {0.55, Color3.fromRGB(36, 9, 15)},
    {1.00, Color3.fromRGB(18, 4, 7)},
}, {
    {0.00, 0.05},
    {1.00, 0.20},
})

-- Ambient shadow behind main
local mainShadow = Instance.new("Frame")
mainShadow.AnchorPoint = Vector2.new(0.5, 0.5)
mainShadow.Position = UDim2.fromScale(0.5, 0.5)
mainShadow.Size = UDim2.new(1, 4, 1, 4)
mainShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
mainShadow.BackgroundTransparency = 0.55
mainShadow.BorderSizePixel = 0
mainShadow.ZIndex = 0
mainShadow.Parent = main
corner(mainShadow, 22)

-- Animated border stroke
local borderStroke = Instance.new("UIStroke")
borderStroke.Thickness = 1.6
borderStroke.Transparency = 0.15
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderStroke.Parent = main
local borderGrad = Instance.new("UIGradient")
borderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, CONFIG.Accent2),
    ColorSequenceKeypoint.new(0.35, CONFIG.Accent),
    ColorSequenceKeypoint.new(0.65, CONFIG.Accent2),
    ColorSequenceKeypoint.new(1.00, CONFIG.Accent),
})
borderGrad.Parent = borderStroke

task.spawn(function()
    local rot = 0
    while borderGrad.Parent do
        rot = (rot + 2.5) % 360
        borderGrad.Rotation = rot
        task.wait(0.04)
    end
end)

-- Subtle inner highlight border
local innerStroke = Instance.new("UIStroke")
innerStroke.Color = Color3.fromRGB(255, 200, 210)
innerStroke.Thickness = 1
innerStroke.Transparency = 0.92
innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
innerStroke.Parent = main

-- Mobile auto scale
local uiScale = Instance.new("UIScale")
uiScale.Parent = main
local function updateScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if vp.X < 1 or vp.Y < 1 then return end
    uiScale.Scale = math.clamp(math.min(vp.X/500, vp.Y/420), 0.62, 1)
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
topBar.Size = UDim2.new(1, 0, 0, 68)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 5
topBar.Parent = main

-- Icon badge
local iconBg = Instance.new("Frame")
iconBg.Position = UDim2.fromOffset(22, 16)
iconBg.Size = UDim2.fromOffset(38, 38)
iconBg.BorderSizePixel = 0
iconBg.ZIndex = 6
iconBg.Parent = topBar
corner(iconBg, 11)
gradient(iconBg, 45, {
    {0.0, CONFIG.Accent2},
    {1.0, CONFIG.Accent},
})
local iconStroke = stroke(iconBg, CONFIG.Accent3, 1.2, 0.4)

local iconText = Instance.new("TextLabel")
iconText.BackgroundTransparency = 1
iconText.Size = UDim2.fromScale(1, 1)
iconText.Font = Enum.Font.GothamBlack
iconText.Text = "M"
iconText.TextSize = 20
iconText.TextColor3 = Color3.fromRGB(255, 245, 246)
iconText.ZIndex = 7
iconText.Parent = iconBg

-- Title
local titleLbl = Instance.new("TextLabel")
titleLbl.BackgroundTransparency = 1
titleLbl.Position = UDim2.fromOffset(72, 12)
titleLbl.Size = UDim2.new(1, -160, 0, 28)
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.Text = "MONK SCRIPTS"
titleLbl.TextSize = 20
titleLbl.TextColor3 = CONFIG.TextMain
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 6
titleLbl.Parent = topBar
gradient(titleLbl, 90, {
    {0.0, Color3.fromRGB(255, 255, 255)},
    {1.0, Color3.fromRGB(255, 170, 185)},
})

-- Subtitle with pulsing dot
local subLbl = Instance.new("TextLabel")
subLbl.BackgroundTransparency = 1
subLbl.Position = UDim2.fromOffset(72, 40)
subLbl.Size = UDim2.new(1, -160, 0, 16)
subLbl.Font = Enum.Font.GothamMedium
subLbl.Text = "PREMIUM KEY SYSTEM"
subLbl.TextSize = 10
subLbl.TextColor3 = CONFIG.Accent2
subLbl.TextTransparency = 0.15
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.ZIndex = 6
subLbl.Parent = topBar

-- Small pulsing status dot next to subtitle
local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(6, 6)
statusDot.Position = UDim2.fromOffset(60, 45)
statusDot.BackgroundColor3 = CONFIG.Accent2
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 7
statusDot.Parent = topBar
corner(statusDot, 3)

task.spawn(function()
    while statusDot.Parent do
        tw(statusDot, {BackgroundTransparency = 0.15}, 0.7, Enum.EasingStyle.Sine)
        task.wait(0.7)
        tw(statusDot, {BackgroundTransparency = 0.75}, 0.7, Enum.EasingStyle.Sine)
        task.wait(0.7)
    end
end)

-- Close button
local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -18, 0, 18)
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.BackgroundColor3 = Color3.fromRGB(52, 12, 20)
closeBtn.BackgroundTransparency = 0.3
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.TextColor3 = CONFIG.Accent2
closeBtn.AutoButtonColor = false
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 7
closeBtn.Parent = topBar
corner(closeBtn, 9)
stroke(closeBtn, CONFIG.Accent, 1, 0.5)

closeBtn.MouseEnter:Connect(function()
    tw(closeBtn, {BackgroundColor3 = CONFIG.Accent, BackgroundTransparency = 0, TextColor3 = CONFIG.TextMain}, 0.18)
end)
closeBtn.MouseLeave:Connect(function()
    tw(closeBtn, {BackgroundColor3 = Color3.fromRGB(52, 12, 20), BackgroundTransparency = 0.3, TextColor3 = CONFIG.Accent2}, 0.18)
end)
closeBtn.MouseButton1Click:Connect(function()
    screenGui:Destroy()
end)

-- Divider with glow
local dividerGlow = Instance.new("Frame")
dividerGlow.Position = UDim2.fromOffset(22, 66)
dividerGlow.Size = UDim2.new(1, -44, 0, 4)
dividerGlow.BackgroundColor3 = CONFIG.Accent
dividerGlow.BackgroundTransparency = 0.82
dividerGlow.BorderSizePixel = 0
dividerGlow.ZIndex = 2
dividerGlow.Parent = main
corner(dividerGlow, 2)

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(22, 68)
divider.Size = UDim2.new(1, -44, 0, 1)
divider.BackgroundColor3 = CONFIG.Accent
divider.BackgroundTransparency = 0.35
divider.BorderSizePixel = 0
divider.ZIndex = 3
divider.Parent = main

--==================== INPUT LABEL ====================--
local inputLbl = Instance.new("TextLabel")
inputLbl.BackgroundTransparency = 1
inputLbl.Position = UDim2.fromOffset(24, 84)
inputLbl.Size = UDim2.new(1, -48, 0, 16)
inputLbl.Font = Enum.Font.GothamBold
inputLbl.Text = "ENTER YOUR LICENSE KEY"
inputLbl.TextSize = 10
inputLbl.TextColor3 = CONFIG.TextSoft
inputLbl.TextXAlignment = Enum.TextXAlignment.Left
inputLbl.ZIndex = 3
inputLbl.Parent = main

--==================== INPUT BOX ====================--
local inputHolder = Instance.new("Frame")
inputHolder.Position = UDim2.fromOffset(22, 104)
inputHolder.Size = UDim2.new(1, -44, 0, 44)
inputHolder.BackgroundColor3 = Color3.fromRGB(14, 4, 7)
inputHolder.BackgroundTransparency = 0.15
inputHolder.BorderSizePixel = 0
inputHolder.ZIndex = 3
inputHolder.Parent = main
corner(inputHolder, 11)
gradient(inputHolder, 90, {
    {0.0, Color3.fromRGB(20, 6, 10)},
    {1.0, Color3.fromRGB(30, 9, 14)},
}, {
    {0.0, 0.05},
    {1.0, 0.30},
})
local inputStroke = stroke(inputHolder, CONFIG.Accent, 1.2, 0.45)

-- Inner glow
local inputGlow = Instance.new("UIStroke")
inputGlow.Color = CONFIG.Accent2
inputGlow.Thickness = 3
inputGlow.Transparency = 0.9
inputGlow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
inputGlow.Parent = inputHolder

local keyBox = Instance.new("TextBox")
keyBox.Position = UDim2.fromOffset(16, 0)
keyBox.Size = UDim2.new(1, -32, 1, 0)
keyBox.BackgroundTransparency = 1
keyBox.Font = Enum.Font.GothamMedium
keyBox.Text = ""
keyBox.PlaceholderText = "MONK-XXXXXXXXXX"
keyBox.PlaceholderColor3 = Color3.fromRGB(140, 70, 82)
keyBox.TextColor3 = CONFIG.TextMain
keyBox.TextSize = 14
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.ClearTextOnFocus = false
keyBox.ZIndex = 4
keyBox.Parent = inputHolder

keyBox.Focused:Connect(function()
    tw(inputStroke, {Transparency = 0.05, Thickness = 1.8}, 0.18)
    tw(inputGlow, {Transparency = 0.5, Thickness = 4}, 0.25)
end)
keyBox.FocusLost:Connect(function(enter)
    tw(inputStroke, {Transparency = 0.45, Thickness = 1.2}, 0.22)
    tw(inputGlow, {Transparency = 0.9, Thickness = 3}, 0.3)
    if enter and _G.__MONK_VERIFY then _G.__MONK_VERIFY() end
end)

--==================== BUTTONS ====================--
local function makeButton(text, yPos, primary)
    local btn = Instance.new("TextButton")
    btn.Position = UDim2.fromOffset(22, yPos)
    btn.Size = UDim2.new(1, -44, 0, 44)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true
    btn.ZIndex = 3
    btn.Parent = main
    corner(btn, 11)

    local scale = Instance.new("UIScale")
    scale.Parent = btn

    if primary then
        btn.BackgroundColor3 = CONFIG.Accent
        gradient(btn, 90, {
            {0.0, Color3.fromRGB(228, 50, 76)},
            {1.0, Color3.fromRGB(158, 18, 38)},
        })
    else
        btn.BackgroundColor3 = Color3.fromRGB(68, 18, 28)
        gradient(btn, 90, {
            {0.0, Color3.fromRGB(82, 22, 34)},
            {1.0, Color3.fromRGB(56, 14, 22)},
        })
    end

    local s = stroke(btn, primary and CONFIG.Accent3 or CONFIG.Accent, 1.3, primary and 0.35 or 0.45)

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text
    lbl.TextSize = 14
    lbl.TextColor3 = primary and Color3.fromRGB(255, 248, 249) or CONFIG.Accent3
    lbl.ZIndex = 4
    lbl.Parent = btn

    btn.MouseEnter:Connect(function()
        tw(scale, {Scale = 1.02}, 0.16, Enum.EasingStyle.Back)
        tw(s, {Transparency = 0.05, Thickness = 2}, 0.18)
        if primary then
            tw(btn, {BackgroundColor3 = Color3.fromRGB(214, 38, 62)}, 0.18)
        else
            tw(btn, {BackgroundColor3 = Color3.fromRGB(86, 24, 36)}, 0.18)
        end
    end)
    btn.MouseLeave:Connect(function()
        tw(scale, {Scale = 1}, 0.2)
        tw(s, {Transparency = primary and 0.35 or 0.45, Thickness = 1.3}, 0.22)
        if primary then
            tw(btn, {BackgroundColor3 = CONFIG.Accent}, 0.22)
        else
            tw(btn, {BackgroundColor3 = Color3.fromRGB(68, 18, 28)}, 0.22)
        end
    end)
    btn.MouseButton1Down:Connect(function()
        tw(scale, {Scale = 0.97}, 0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        tw(scale, {Scale = 1.02}, 0.14)
    end)

    return btn, lbl, s, scale
end

local verifyBtn, verifyLbl, verifyStroke, verifyScale = makeButton("VERIFY KEY", 158, true)
local getKeyBtn, getKeyLbl, getKeyStroke, getKeyScale = makeButton("GET KEY", 212, false)

--==================== FOOTER ====================--
local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(22, 274)
footer.Size = UDim2.new(1, -44, 0, 16)
footer.Font = Enum.Font.Gotham
footer.Text = "Key format: MONK-XXXX   •   Secure Access"
footer.TextSize = 10
footer.TextColor3 = CONFIG.TextSoft
footer.TextTransparency = 0.5
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

--==================== NOTIFICATIONS ====================--
local activeNotifs = {}
local function notify(titleText, msgText, accentColor, duration)
    duration = duration or 3
    if not screenGui.Parent then return end
    local idx = #activeNotifs

    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0, -90)
    holder.Size = UDim2.fromOffset(380, 62)
    holder.BackgroundColor3 = Color3.fromRGB(34, 10, 15)
    holder.BackgroundTransparency = 0.05
    holder.BorderSizePixel = 0
    holder.ClipsDescendants = false
    holder.ZIndex = 200
    holder.Parent = screenGui
    corner(holder, 13)
    gradient(holder, 90, {
        {0.0, Color3.fromRGB(58, 16, 24)},
        {1.0, Color3.fromRGB(30, 8, 13)},
    })
    stroke(holder, accentColor, 1.3, 0.25)

    -- Accent bar
    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(0, 12)
    bar.Size = UDim2.new(0, 3, 1, -24)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.ZIndex = 201
    bar.Parent = holder
    corner(bar, 2)

    -- Glow behind bar
    local barGlow = Instance.new("Frame")
    barGlow.Position = UDim2.fromOffset(-4, 8)
    barGlow.Size = UDim2.new(0, 12, 1, -16)
    barGlow.BackgroundColor3 = accentColor
    barGlow.BackgroundTransparency = 0.85
    barGlow.BorderSizePixel = 0
    barGlow.ZIndex = 200
    barGlow.Parent = holder
    corner(barGlow, 6)

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.fromOffset(20, 8)
    t.Size = UDim2.new(1, -34, 0, 18)
    t.Font = Enum.Font.GothamBold
    t.Text = titleText
    t.TextSize = 13
    t.TextColor3 = accentColor
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 201
    t.Parent = holder

    local m = Instance.new("TextLabel")
    m.BackgroundTransparency = 1
    m.Position = UDim2.fromOffset(20, 28)
    m.Size = UDim2.new(1, -34, 0, 22)
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
    local targetY = 20 + idx * 72
    tw(holder, {Position = UDim2.new(0.5, 0, 0, targetY)}, 0.32, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        if holder and holder.Parent then
            tw(holder, {Position = UDim2.new(0.5, 0, 0, -90)}, 0.28)
            task.wait(0.32)
            for i, v in ipairs(activeNotifs) do
                if v == holder then table.remove(activeNotifs, i) break end
            end
            if holder then holder:Destroy() end
        end
    end)
end

--==================== VALIDATION ====================--
local function isValidKey(raw)
    if type(raw) ~= "string" then return false end
    local k = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if #k <= #CONFIG.Prefix then return false end
    return string.upper(string.sub(k, 1, #CONFIG.Prefix)) == CONFIG.Prefix
end

local unlocking = false

local function unlockScript()
    if unlocking then return end
    unlocking = true
    verifyLbl.Text = "VERIFYING..."
    verifyBtn.Interactable = false
    tw(verifyScale, {Scale = 1}, 0.1)

    -- Success glow flash
    local flash = Instance.new("UIStroke")
    flash.Color = CONFIG.Success
    flash.Thickness = 6
    flash.Transparency = 0.3
    flash.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    flash.Parent = verifyBtn
    tw(flash, {Transparency = 1, Thickness = 10}, 0.7)
    task.delay(0.75, function() if flash and flash.Parent then flash:Destroy() end end)

    notify("KEY VERIFIED", "Script fetch ho rahi hai...", CONFIG.Success, 3)
    task.wait(0.4)

    local lsFn, lsName = getLoadstring()
    if not lsFn then
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        notify("EXECUTOR ERROR", "loadstring disabled hai. Executor me ON karo.", CONFIG.Fail, 5)
        return
    end
    print("[MONK] loadstring:", lsName)

    local source = fetchScript(CONFIG.ScriptURL)
    if not source then
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        notify("LOAD FAILED", "Script fetch nahi hui. Internet/URL check karo.", CONFIG.Fail, 4)
        return
    end

    print("[MONK] Source length:", #source)

    if looksLikeHtml(source) then
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        notify("URL ERROR", "Server ne HTML bheja, Lua script nahi. URL check karo.", CONFIG.Fail, 5)
        return
    end

    local fn, compileErr = lsFn(source)
    if not fn then
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        notify("COMPILE ERROR", tostring(compileErr or "Syntax error"):sub(1, 90), CONFIG.Fail, 5)
        return
    end

    screenGui:Destroy()
    task.wait(0.15)

    local ok, runErr = pcall(fn)
    if not ok then warn("[MONK] Runtime error:", tostring(runErr)) end
end

local function verifyKey()
    if unlocking then return end
    if isValidKey(keyBox.Text) then
        unlockScript()
    else
        notify("INVALID KEY", "Key galat hai! Key link is given below.", CONFIG.Fail, 3)

        -- Error shake + flash
        tw(inputStroke, {Color = CONFIG.Fail, Transparency = 0}, 0.1)
        tw(inputGlow, {Color = CONFIG.Fail, Transparency = 0.3}, 0.1)
        task.wait(0.15)
        tw(inputStroke, {Color = CONFIG.Accent, Transparency = 0.45}, 0.4)
        tw(inputGlow, {Color = CONFIG.Accent2, Transparency = 0.9}, 0.5)

        local orig = main.Position
        for i = 1, 6 do
            main.Position = orig + UDim2.fromOffset((i % 2 == 0) and 7 or -7, 0)
            task.wait(0.035)
        end
        main.Position = orig

        if getKeyBtn and getKeyBtn.Parent then
            tw(getKeyBtn, {BackgroundColor3 = Color3.fromRGB(140, 40, 55)}, 0.15)
            task.delay(1.2, function()
                if getKeyBtn and getKeyBtn.Parent then
                    tw(getKeyBtn, {BackgroundColor3 = Color3.fromRGB(68, 18, 28)}, 0.3)
                end
            end)
        end
    end
end

_G.__MONK_VERIFY = verifyKey
verifyBtn.MouseButton1Click:Connect(verifyKey)

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
    tw(getKeyStroke, {Color = CONFIG.Success, Transparency = 0.1}, 0.15)
    task.delay(1.6, function()
        if getKeyLbl and getKeyLbl.Parent then getKeyLbl.Text = old end
        if getKeyStroke and getKeyStroke.Parent then
            tw(getKeyStroke, {Color = CONFIG.Accent, Transparency = 0.45}, 0.3)
        end
    end)
end)

--==================== ENTRANCE ANIMATION ====================--
main.BackgroundTransparency = 1
tw(main, {BackgroundTransparency = 0.06}, 0.4)

task.wait(0.2)
notify("WELCOME", "Apni MONK- key enter karke verify karo.", CONFIG.Accent2, 3)
print("[MONK] v4 Premium ready ✓")