--[[
    ═══════════════════════════════════════════════════════════════════
      MONK SCRIPTS  •  KEY SYSTEM v5 (DIAGNOSTIC EDITION)
      Har step screen pe dikhega — exact failure reason milega
    ═══════════════════════════════════════════════════════════════════
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local CONFIG = {
    Prefix    = "MONK-",
    KeySite   = "https://keysystemnymomk.vercel.app/",
    ScriptURL = "https://monk-scripts-novoline-loaderlua.vercel.app/?EXECUTOR=true",

    Accent    = Color3.fromRGB(200, 28, 54),
    Accent2   = Color3.fromRGB(255, 92, 112),
    Accent3   = Color3.fromRGB(255, 160, 175),
    Dark      = Color3.fromRGB(28, 8, 13),
    TextMain  = Color3.fromRGB(255, 246, 248),
    TextSoft  = Color3.fromRGB(220, 160, 170),
    Success   = Color3.fromRGB(90, 215, 135),
    Warn      = Color3.fromRGB(255, 185, 70),
    Fail      = Color3.fromRGB(255, 80, 95),
}

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

local FRAME_W, FRAME_H = 480, 500

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

local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(FRAME_W, FRAME_H)
main.BackgroundColor3 = CONFIG.Dark
main.BackgroundTransparency = 0.04
main.BorderSizePixel = 0
main.ZIndex = 1
main.Parent = screenGui
corner(main, 20)

gradient(main, 100, {
    {0.00, Color3.fromRGB(72, 16, 26)},
    {0.55, Color3.fromRGB(36, 9, 15)},
    {1.00, Color3.fromRGB(18, 4, 7)},
}, {{0.00, 0.05},{1.00, 0.20}})

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
    while borderGrad.Parent do
        borderGrad.Rotation = (borderGrad.Rotation + 2.5) % 360
        task.wait(0.04)
    end
end)

local uiScale = Instance.new("UIScale")
uiScale.Parent = main
local function updateScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if vp.X < 1 or vp.Y < 1 then return end
    uiScale.Scale = math.clamp(math.min(vp.X/560, vp.Y/560), 0.55, 1)
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

local iconBg = Instance.new("Frame")
iconBg.Position = UDim2.fromOffset(22, 16)
iconBg.Size = UDim2.fromOffset(38, 38)
iconBg.BorderSizePixel = 0
iconBg.ZIndex = 6
iconBg.Parent = topBar
corner(iconBg, 11)
gradient(iconBg, 45, {{0.0, CONFIG.Accent2},{1.0, CONFIG.Accent}})
stroke(iconBg, CONFIG.Accent3, 1.2, 0.4)

local iconText = Instance.new("TextLabel")
iconText.BackgroundTransparency = 1
iconText.Size = UDim2.fromScale(1, 1)
iconText.Font = Enum.Font.GothamBlack
iconText.Text = "M"
iconText.TextSize = 20
iconText.TextColor3 = Color3.fromRGB(255, 245, 246)
iconText.ZIndex = 7
iconText.Parent = iconBg

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
gradient(titleLbl, 90, {{0.0, Color3.fromRGB(255, 255, 255)},{1.0, Color3.fromRGB(255, 170, 185)}})

local subLbl = Instance.new("TextLabel")
subLbl.BackgroundTransparency = 1
subLbl.Position = UDim2.fromOffset(72, 40)
subLbl.Size = UDim2.new(1, -160, 0, 16)
subLbl.Font = Enum.Font.GothamMedium
subLbl.Text = "PREMIUM KEY SYSTEM  •  DIAGNOSTIC"
subLbl.TextSize = 10
subLbl.TextColor3 = CONFIG.Accent2
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.ZIndex = 6
subLbl.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -18, 0, 18)
closeBtn.Size = UDim2.fromOffset(30, 30)
closeBtn.BackgroundColor3 = Color3.fromRGB(52, 12, 20)
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
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

--==================== INPUT ====================--
local inputLbl = Instance.new("TextLabel")
inputLbl.BackgroundTransparency = 1
inputLbl.Position = UDim2.fromOffset(24, 82)
inputLbl.Size = UDim2.new(1, -48, 0, 16)
inputLbl.Font = Enum.Font.GothamBold
inputLbl.Text = "ENTER YOUR LICENSE KEY"
inputLbl.TextSize = 10
inputLbl.TextColor3 = CONFIG.TextSoft
inputLbl.TextXAlignment = Enum.TextXAlignment.Left
inputLbl.ZIndex = 3
inputLbl.Parent = main

local inputHolder = Instance.new("Frame")
inputHolder.Position = UDim2.fromOffset(22, 102)
inputHolder.Size = UDim2.new(1, -44, 0, 44)
inputHolder.BackgroundColor3 = Color3.fromRGB(14, 4, 7)
inputHolder.BackgroundTransparency = 0.12
inputHolder.BorderSizePixel = 0
inputHolder.ZIndex = 3
inputHolder.Parent = main
corner(inputHolder, 11)
local inputStroke = stroke(inputHolder, CONFIG.Accent, 1.2, 0.45)

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

--==================== BUTTONS ====================--
local function makeButton(text, yPos, primary)
    local btn = Instance.new("TextButton")
    btn.Position = UDim2.fromOffset(22, yPos)
    btn.Size = UDim2.new(1, -44, 0, 42)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ZIndex = 3
    btn.Parent = main
    corner(btn, 11)
    local scale = Instance.new("UIScale"); scale.Parent = btn

    if primary then
        btn.BackgroundColor3 = CONFIG.Accent
        gradient(btn, 90, {{0.0, Color3.fromRGB(228, 50, 76)},{1.0, Color3.fromRGB(158, 18, 38)}})
    else
        btn.BackgroundColor3 = Color3.fromRGB(68, 18, 28)
        gradient(btn, 90, {{0.0, Color3.fromRGB(82, 22, 34)},{1.0, Color3.fromRGB(56, 14, 22)}})
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
    end)
    btn.MouseLeave:Connect(function()
        tw(scale, {Scale = 1}, 0.2)
        tw(s, {Transparency = primary and 0.35 or 0.45, Thickness = 1.3}, 0.22)
    end)
    btn.MouseButton1Down:Connect(function() tw(scale, {Scale = 0.97}, 0.08) end)
    btn.MouseButton1Up:Connect(function() tw(scale, {Scale = 1.02}, 0.14) end)

    return btn, lbl, s, scale
end

local verifyBtn, verifyLbl, verifyStroke, verifyScale = makeButton("VERIFY KEY", 154, true)
local getKeyBtn, getKeyLbl, getKeyStroke, getKeyScale = makeButton("GET KEY", 204, false)

--==================== DEBUG CONSOLE (on-screen) ====================--
local debugLabel = Instance.new("TextLabel")
debugLabel.BackgroundTransparency = 1
debugLabel.Position = UDim2.fromOffset(24, 260)
debugLabel.Size = UDim2.new(1, -48, 0, 16)
debugLabel.Font = Enum.Font.GothamBold
debugLabel.Text = "▸ DIAGNOSTIC LOG"
debugLabel.TextSize = 10
debugLabel.TextColor3 = CONFIG.Accent2
debugLabel.TextXAlignment = Enum.TextXAlignment.Left
debugLabel.ZIndex = 3
debugLabel.Parent = main

local debugBox = Instance.new("Frame")
debugBox.Position = UDim2.fromOffset(22, 278)
debugBox.Size = UDim2.new(1, -44, 0, 190)
debugBox.BackgroundColor3 = Color3.fromRGB(8, 2, 5)
debugBox.BackgroundTransparency = 0.1
debugBox.BorderSizePixel = 0
debugBox.ZIndex = 3
debugBox.Parent = main
corner(debugBox, 10)
stroke(debugBox, CONFIG.Accent, 1, 0.6)

local debugScroll = Instance.new("ScrollingFrame")
debugScroll.Size = UDim2.fromScale(1, 1)
debugScroll.BackgroundTransparency = 1
debugScroll.BorderSizePixel = 0
debugScroll.ScrollBarThickness = 3
debugScroll.ScrollBarImageColor3 = CONFIG.Accent
debugScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
debugScroll.ZIndex = 4
debugScroll.Parent = debugBox

local debugLayout = Instance.new("UIListLayout")
debugLayout.Padding = UDim.new(0, 2)
debugLayout.SortOrder = Enum.SortOrder.LayoutOrder
debugLayout.Parent = debugScroll

local debugPad = Instance.new("UIPadding")
debugPad.PaddingLeft = UDim.new(0, 8)
debugPad.PaddingRight = UDim.new(0, 8)
debugPad.PaddingTop = UDim.new(0, 6)
debugPad.PaddingBottom = UDim.new(0, 6)
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
    debugScroll.CanvasSize = UDim2.new(0, 0, 0, debugLayout.AbsoluteContentSize.Y + 12)
    debugScroll.CanvasPosition = Vector2.new(0, debugScroll.CanvasSize.Y.Offset)
    print("[MONK]", msg)
end

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

--==================== ENVIRONMENT CHECK ====================--
log("=== ENVIRONMENT CHECK ===", CONFIG.Accent2)

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

-- loadstring check
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

if lsFn then
    log("✓ loadstring: " .. lsName, CONFIG.Success)
else
    log("✗ loadstring NOT AVAILABLE", CONFIG.Fail)
end

-- HTTP check
local httpFns = {}
if syn and syn.request then table.insert(httpFns, "syn.request") end
if fluxus and fluxus.request then table.insert(httpFns, "fluxus.request") end
if http and http.request then table.insert(httpFns, "http.request") end
if request then table.insert(httpFns, "request") end
if game.HttpGet then table.insert(httpFns, "game:HttpGet") end
if httpget then table.insert(httpFns, "httpget") end

if #httpFns > 0 then
    log("✓ HTTP methods: " .. table.concat(httpFns, ", "), CONFIG.Success)
else
    log("✗ No HTTP method available!", CONFIG.Fail)
end

log("=== READY ===", CONFIG.Accent2)

--==================== VALIDATION ====================--
local function isValidKey(raw)
    if type(raw) ~= "string" then return false end
    local k = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if #k <= #CONFIG.Prefix then return false end
    return string.upper(string.sub(k, 1, #CONFIG.Prefix)) == CONFIG.Prefix
end

--==================== ROBUST HTTP FETCH ====================--
local HEADERS = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Roblox/WinInet",
    ["Accept"]     = "*/*",
}

local function tryHttpGet(url)
    log("Trying game:HttpGet...", CONFIG.TextSoft)
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(res) == "string" and #res > 0 then
        return res, "game:HttpGet"
    end
    log("  game:HttpGet: " .. (ok and ("empty/length " .. tostring(#(res or ""))) or tostring(res)), CONFIG.Warn)

    if httpget then
        log("Trying httpget()...", CONFIG.TextSoft)
        local ok2, res2 = pcall(httpget, url)
        if ok2 and type(res2) == "string" and #res2 > 0 then
            return res2, "httpget"
        end
        log("  httpget: " .. (ok2 and "empty" or tostring(res2)), CONFIG.Warn)
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
                if type(body) == "string" and #body > 0 then
                    return body, pair[2]
                end
                log("  " .. pair[2] .. ": empty body", CONFIG.Warn)
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
        or head:find("404") or head:find("not found") or head:find("error")) ~= nil
end

local function fetchScript(url)
    log("=== FETCHING SCRIPT ===", CONFIG.Accent2)
    log("URL: " .. url, CONFIG.TextSoft)

    local body, method = tryHttpGet(url)
    if not body then
        body, method = tryRequest(url)
    end

    if body then
        log("✓ Fetched via " .. method .. " (" .. #body .. " bytes)", CONFIG.Success)
        log("Preview: " .. body:sub(1, 80):gsub("\n", " "), CONFIG.TextSoft)
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
    holder.Position = UDim2.new(0.5, 0, 0, -90)
    holder.Size = UDim2.fromOffset(380, 62)
    holder.BackgroundColor3 = Color3.fromRGB(34, 10, 15)
    holder.BackgroundTransparency = 0.05
    holder.BorderSizePixel = 0
    holder.ZIndex = 200
    holder.Parent = screenGui
    corner(holder, 13)
    gradient(holder, 90, {{0.0, Color3.fromRGB(58, 16, 24)},{1.0, Color3.fromRGB(30, 8, 13)}})
    stroke(holder, accentColor, 1.3, 0.25)

    local bar = Instance.new("Frame")
    bar.Position = UDim2.fromOffset(0, 12)
    bar.Size = UDim2.new(0, 3, 1, -24)
    bar.BackgroundColor3 = accentColor
    bar.BorderSizePixel = 0
    bar.ZIndex = 201
    bar.Parent = holder
    corner(bar, 2)

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

--==================== UNLOCK FLOW ====================--
local unlocking = false

local function unlockScript()
    if unlocking then return end
    unlocking = true
    verifyLbl.Text = "VERIFYING..."
    verifyBtn.Interactable = false
    verifyScale.Scale = 1

    log("=== VERIFY START ===", CONFIG.Accent2)

    -- Step 1: loadstring
    if not lsFn then
        log("✗ BLOCKED: loadstring disabled", CONFIG.Fail)
        notify("EXECUTOR ERROR", "loadstring disabled hai. Executor settings me ON karo.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        return
    end
    log("✓ loadstring ready (" .. lsName .. ")", CONFIG.Success)

    -- Step 2: fetch
    local source = fetchScript(CONFIG.ScriptURL)

    if not source then
        log("✗ FETCH FAILED", CONFIG.Fail)
        notify("FETCH FAILED", "Internet/URL issue. Log dekho screen pe.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        return
    end

    -- Step 3: HTML check
    if looksLikeHtml(source) then
        log("✗ URL returned HTML (404/error page)", CONFIG.Fail)
        log("URL wrong ya expired hai!", CONFIG.Fail)
        notify("URL ERROR", "Server ne HTML bheja. URL galat/expired. Log dekho.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        return
    end
    log("✓ Not HTML — looks like Lua", CONFIG.Success)

    -- Step 4: compile
    log("Compiling script...", CONFIG.TextSoft)
    local fn, compileErr = lsFn(source)
    if not fn then
        log("✗ COMPILE ERROR", CONFIG.Fail)
        log("  " .. tostring(compileErr):sub(1, 200), CONFIG.Fail)
        notify("COMPILE ERROR", tostring(compileErr):sub(1, 100), CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        return
    end
    log("✓ Compiled OK", CONFIG.Success)

    -- Step 5: execute
    log("Executing script...", CONFIG.Warn)
    notify("KEY VERIFIED", "Script execute ho rahi hai...", CONFIG.Success, 2.5)
    task.wait(0.5)

    screenGui:Destroy()
    task.wait(0.15)

    local ok, runErr = pcall(fn)
    if not ok then
        warn("[MONK] Runtime error: " .. tostring(runErr))
    else
        print("[MONK] Script executed successfully")
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
        log("✓ Key format OK (MONK- prefix)", CONFIG.Success)
        unlockScript()
    else
        log("✗ Invalid key format", CONFIG.Fail)
        notify("INVALID KEY", "Key galat hai! MONK- se start honi chahiye.", CONFIG.Fail, 3)

        tw(inputStroke, {Color = CONFIG.Fail, Transparency = 0}, 0.1)
        task.wait(0.15)
        tw(inputStroke, {Color = CONFIG.Accent, Transparency = 0.45}, 0.4)

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
    task.delay(1.6, function()
        if getKeyLbl and getKeyLbl.Parent then getKeyLbl.Text = old end
    end)
end)

log("=== GUI READY ===", CONFIG.Success)
notify("READY", "Key daalo aur Verify dabao. Log screen pe dikhega.", CONFIG.Accent2, 3)