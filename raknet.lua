--[[
    ═══════════════════════════════════════════════════════════════════════════════
      MONK SCRIPTS  •  ROYAL VIP EDITION  (v11 — BULLETPROOF)
      All elements visible immediately · Safe entrance · Auto-login preserved
    ═══════════════════════════════════════════════════════════════════════════════
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

local CONFIG = {
    Prefix    = "MONK-",
    KeySite   = "https://keysystemnymomk.vercel.app/",
    ScriptURL = "https://pastefy.app/h2aM8Dj8/raw",

    Accent    = Color3.fromRGB(198, 26, 52),
    Accent2   = Color3.fromRGB(255, 88, 108),
    Accent3   = Color3.fromRGB(255, 158, 174),
    Accent4   = Color3.fromRGB(255, 222, 230),
    Gold      = Color3.fromRGB(238, 198, 138),
    GoldBright= Color3.fromRGB(255, 232, 178),
    GoldDeep  = Color3.fromRGB(196, 148, 78),
    Dark      = Color3.fromRGB(18, 5, 9),
    TextMain  = Color3.fromRGB(255, 250, 252),
    TextSoft  = Color3.fromRGB(226, 172, 184),
    Success   = Color3.fromRGB(92, 218, 138),
    Warn      = Color3.fromRGB(255, 188, 72),
    Fail      = Color3.fromRGB(255, 78, 94),
}

--==================== PERSISTENT KEY STORE ====================--
local KEY_FILE      = "MONK_Scripts/key.json"
local KEY_FOLDER    = "MONK_Scripts"
local VALID_SECONDS = 24 * 60 * 60

local function safeCall(fn, ...)
    if not fn then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function ensureFolder()
    safeCall(function()
        if isfolder and makefolder and not isfolder(KEY_FOLDER) then
            makefolder(KEY_FOLDER)
        end
    end)
end

local function writeKeyFile(data)
    if not writefile then return false end
    ensureFolder()
    if safeCall(writefile, KEY_FILE, data) then return true end
    if safeCall(writefile, "key.json", data) then
        KEY_FILE = "key.json"
        return true
    end
    return false
end

local function readKeyFile()
    if not isfile or not readfile then return nil end
    local path = KEY_FILE
    if not safeCall(isfile, path) and safeCall(isfile, "key.json") then path = "key.json" end
    if not safeCall(isfile, path) then return nil end
    local content = safeCall(readfile, path)
    if type(content) ~= "string" or #content < 5 then return nil end
    local decoded
    pcall(function()
        local HttpService = game:GetService("HttpService")
        decoded = HttpService:JSONDecode(content)
    end)
    if not decoded then
        local k = content:match('"key"%s*:%s*"([^"]+)"')
        local s = content:match('"saved_at"%s*:%s*(%-?%d+)')
        if k and s then decoded = { key = k, saved_at = tonumber(s) } end
    end
    return decoded
end

local function saveKey(key)
    local cleanKey = tostring(key):gsub('"', ''):gsub("\\", "")
    local payload = string.format('{"key":"%s","saved_at":%d}', cleanKey, os.time())
    return writeKeyFile(payload)
end

local function deleteKeyFile()
    safeCall(function()
        if delfile then pcall(delfile, KEY_FILE); pcall(delfile, "key.json") end
    end)
end

local function validateKeyFormat(raw)
    if type(raw) ~= "string" then return false end
    local k = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if #k <= #CONFIG.Prefix then return false end
    return string.upper(string.sub(k, 1, #CONFIG.Prefix)) == CONFIG.Prefix
end

local function isSavedKeyValid(entry)
    if not entry or not entry.key or not entry.saved_at then return false end
    if not validateKeyFormat(entry.key) then return false end
    local age = os.time() - entry.saved_at
    if age < 0 or age > VALID_SECONDS then return false end
    return true, VALID_SECONDS - age
end
--==============================================================

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

local function detectLoadstring()
    if loadstring and pcall(loadstring, "return 1") then return loadstring, "loadstring" end
    if syn and syn.loadstring and pcall(syn.loadstring, "return 1") then return syn.loadstring, "syn.loadstring" end
    if fluxus and fluxus.loadstring and pcall(fluxus.loadstring, "return 1") then return fluxus.loadstring, "fluxus.loadstring" end
    if load and pcall(load, "return 1") then return load, "load" end
    return nil, nil
end

local HEADERS = {
    ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) Roblox/WinInet",
    ["Accept"]     = "*/*",
}

local function httpFetch(url, logger)
    logger = logger or function() end
    logger("Attempting game:HttpGet...")
    local ok, res = pcall(function() return game:HttpGet(url, true) end)
    if ok and type(res) == "string" and #res > 0 then return res, "game:HttpGet" end
    if httpget then
        logger("Attempting httpget()...")
        local ok2, res2 = pcall(httpget, url)
        if ok2 and type(res2) == "string" and #res2 > 0 then return res2, "httpget" end
    end
    local list = {
        {syn and syn.request, "syn.request"},
        {fluxus and fluxus.request, "fluxus.request"},
        {http and http.request, "http.request"},
        {request, "request"},
    }
    for _, pair in ipairs(list) do
        if pair[1] then
            logger("Attempting " .. pair[2] .. "...")
            local ok3, res3 = pcall(pair[1], {Url = url, Method = "GET", Headers = HEADERS})
            if ok3 and res3 then
                local body = res3.Body or res3.body
                if type(body) == "string" and #body > 0 then return body, pair[2] end
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

--==================== AUTO-LOGIN ATTEMPT ====================--
local function tryAutoLogin()
    print("[MONK] Checking for saved key...")
    local entry = readKeyFile()
    if not entry then
        print("[MONK] No saved key found")
        return false
    end
    local valid, remaining = isSavedKeyValid(entry)
    if not valid then
        print("[MONK] Saved key expired or invalid — deleting")
        deleteKeyFile()
        return false
    end
    local hours = math.floor(remaining / 3600)
    local mins  = math.floor((remaining % 3600) / 60)
    print(string.format("[MONK] Valid key found (expires in %dh %dm)", hours, mins))

    local lsFn = detectLoadstring()
    if not lsFn then
        print("[MONK] Auto-login skipped: loadstring unavailable")
        return false
    end
    local source = httpFetch(CONFIG.ScriptURL, function(m) print("[MONK] " .. m) end)
    if not source then return false end
    if looksLikeHtml(source) then return false end
    local fn, err = lsFn(source)
    if not fn then
        print("[MONK] Auto-login failed: " .. tostring(err))
        return false
    end
    print("[MONK] Auto-login successful — executing script")
    task.wait(0.2)
    pcall(fn)
    return true
end

-- Wrap auto-login in pcall so ANY failure falls through to GUI
local autoOk, autoResult = pcall(tryAutoLogin)
if autoOk and autoResult then
    return
end
if not autoOk then
    warn("[MONK] Auto-login error (falling through): " .. tostring(autoResult))
end

--==================== MAIN GUI PATH ====================--
print("[MONK] Starting interactive key system...")

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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonkKeySystem"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = pg

local FRAME_W, FRAME_H = 510, 580

-- Golden entrance flash (sits above, disappears — safe)
local flashGold = Instance.new("Frame")
flashGold.AnchorPoint = Vector2.new(0.5, 0.5)
flashGold.Position = UDim2.fromScale(0.5, 0.5)
flashGold.Size = UDim2.fromOffset(0, 0)
flashGold.BackgroundColor3 = CONFIG.Gold
flashGold.BackgroundTransparency = 0.25
flashGold.BorderSizePixel = 0
flashGold.ZIndex = 999
flashGold.Parent = screenGui
corner(flashGold, 999)
task.spawn(function()
    pcall(function()
        tw(flashGold, {Size = UDim2.fromOffset(1400, 1400), BackgroundTransparency = 1}, 1.3, Enum.EasingStyle.Quad)
        task.wait(1.4)
        if flashGold then flashGold:Destroy() end
    end)
end)

-- Ambient glows
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
    corner(g, 34)
    return g
end
makeGlow(96, 0.96, 0)
makeGlow(56, 0.93, 0)
local glow3 = makeGlow(26, 0.82, 0)

local goldHalo = Instance.new("Frame")
goldHalo.AnchorPoint = Vector2.new(0.5, 0.5)
goldHalo.Position = UDim2.fromScale(0.5, 0.5)
goldHalo.Size = UDim2.fromOffset(FRAME_W + 8, FRAME_H + 8)
goldHalo.BackgroundColor3 = CONFIG.Gold
goldHalo.BackgroundTransparency = 0.94
goldHalo.BorderSizePixel = 0
goldHalo.ZIndex = 0
goldHalo.Parent = screenGui
corner(goldHalo, 24)

task.spawn(function()
    pcall(function()
        while goldHalo.Parent do
            tw(goldHalo, {BackgroundTransparency = 0.85}, 2.2, Enum.EasingStyle.Sine)
            task.wait(2.2)
            tw(goldHalo, {BackgroundTransparency = 0.94}, 2.2, Enum.EasingStyle.Sine)
            task.wait(2.2)
        end
    end)
end)
task.spawn(function()
    pcall(function()
        while glow3.Parent do
            tw(glow3, {BackgroundTransparency = 0.7}, 2, Enum.EasingStyle.Sine)
            task.wait(2)
            tw(glow3, {BackgroundTransparency = 0.85}, 2, Enum.EasingStyle.Sine)
            task.wait(2)
        end
    end)
end)

-- MAIN FRAME — starts small, expands. All children FULLY VISIBLE from start.
local main = Instance.new("Frame")
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(60, 60)
main.BackgroundColor3 = CONFIG.Dark
main.BackgroundTransparency = 0.04
main.BorderSizePixel = 0
main.ClipsDescendants = true
main.ZIndex = 1
main.Parent = screenGui
corner(main, 24)

gradient(main, 100, {
    {0.00, Color3.fromRGB(92, 20, 36)},
    {0.28, Color3.fromRGB(58, 12, 22)},
    {0.60, Color3.fromRGB(34, 8, 14)},
    {1.00, Color3.fromRGB(14, 3, 6)},
}, {{0.00, 0.00},{0.5, 0.05},{1.00, 0.14}})

local glassBlur = Instance.new("BackgroundBlur")
glassBlur.Size = 16
glassBlur.Parent = main

local borderStroke = Instance.new("UIStroke")
borderStroke.Thickness = 2
borderStroke.Transparency = 0.02
borderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
borderStroke.Parent = main
local borderGrad = Instance.new("UIGradient")
borderGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, CONFIG.Gold),
    ColorSequenceKeypoint.new(0.15, CONFIG.Accent2),
    ColorSequenceKeypoint.new(0.35, CONFIG.GoldBright),
    ColorSequenceKeypoint.new(0.55, CONFIG.Accent),
    ColorSequenceKeypoint.new(0.72, CONFIG.Gold),
    ColorSequenceKeypoint.new(0.88, CONFIG.Accent2),
    ColorSequenceKeypoint.new(1.00, CONFIG.Gold),
})
borderGrad.Parent = borderStroke
task.spawn(function()
    pcall(function()
        while borderGrad.Parent do
            borderGrad.Rotation = (borderGrad.Rotation + 2.5) % 360
            task.wait(0.04)
        end
    end)
end)

local innerGold = Instance.new("UIStroke")
innerGold.Color = CONFIG.Gold
innerGold.Thickness = 0.8
innerGold.Transparency = 0.7
innerGold.Parent = main

local topReflection = Instance.new("Frame")
topReflection.Size = UDim2.new(1, -14, 0, 118)
topReflection.Position = UDim2.fromOffset(7, 4)
topReflection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topReflection.BackgroundTransparency = 0.93
topReflection.BorderSizePixel = 0
topReflection.ZIndex = 2
topReflection.Parent = main
corner(topReflection, 22)

local bottomReflection = Instance.new("Frame")
bottomReflection.Size = UDim2.new(1, -14, 0, 46)
bottomReflection.Position = UDim2.new(0, 7, 1, -52)
bottomReflection.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
bottomReflection.BackgroundTransparency = 0.965
bottomReflection.BorderSizePixel = 0
bottomReflection.ZIndex = 2
bottomReflection.Parent = main
corner(bottomReflection, 18)

local function cornerOrnament(posX, posY, anchorX, anchorY)
    local h = Instance.new("Frame")
    h.Size = UDim2.fromOffset(28, 2)
    h.Position = UDim2.fromOffset(posX, posY)
    h.AnchorPoint = Vector2.new(anchorX, anchorY)
    h.BackgroundColor3 = CONFIG.GoldBright
    h.BorderSizePixel = 0
    h.ZIndex = 4
    h.Parent = main
    corner(h, 1)
    local v = Instance.new("Frame")
    v.Size = UDim2.fromOffset(2, 28)
    v.Position = UDim2.fromOffset(posX, posY)
    v.AnchorPoint = Vector2.new(anchorX, anchorY)
    v.BackgroundColor3 = CONFIG.GoldBright
    v.BorderSizePixel = 0
    v.ZIndex = 4
    v.Parent = main
    corner(v, 1)
    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(5, 5)
    dot.Position = UDim2.fromOffset(posX, posY)
    dot.AnchorPoint = Vector2.new(anchorX, anchorY)
    dot.BackgroundColor3 = CONFIG.GoldBright
    dot.BorderSizePixel = 0
    dot.ZIndex = 4
    dot.Parent = main
    corner(dot, 3)
end
cornerOrnament(14, 14, 0, 0)
cornerOrnament(FRAME_W - 14, 14, 1, 0)
cornerOrnament(14, FRAME_H - 14, 0, 1)
cornerOrnament(FRAME_W - 14, FRAME_H - 14, 1, 1)

local uiScale = Instance.new("UIScale")
uiScale.Parent = main
local function updateScale()
    local cam = workspace.CurrentCamera
    if not cam then return end
    local vp = cam.ViewportSize
    if vp.X < 1 or vp.Y < 1 then return end
    uiScale.Scale = math.clamp(math.min(vp.X/610, vp.Y/610), 0.5, 1)
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

-- SAFE EXPANSION — only tween the frame size, nothing else
task.spawn(function()
    pcall(function()
        task.wait(0.1)
        tw(main, {Size = UDim2.fromOffset(FRAME_W, FRAME_H)}, 0.7, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
    end)
end)

-- Diagonal shimmer
task.delay(1.5, function()
    task.spawn(function()
        pcall(function()
            while main.Parent do
                local band = Instance.new("Frame")
                band.Size = UDim2.new(0, 80, 1, 0)
                band.Position = UDim2.new(0, -120, 0, 0)
                band.BackgroundColor3 = Color3.fromRGB(255, 245, 220)
                band.BackgroundTransparency = 0.92
                band.BorderSizePixel = 0
                band.ZIndex = 3
                band.Rotation = 15
                band.Parent = main
                local bandGrad = Instance.new("UIGradient")
                bandGrad.Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(0.5, 0.4),
                    NumberSequenceKeypoint.new(1, 1),
                })
                bandGrad.Parent = band
                tw(band, {Position = UDim2.new(1, 60, 0, 0)}, 2.4, Enum.EasingStyle.Linear)
                task.delay(2.5, function() if band then band:Destroy() end end)
                task.wait(4.5)
            end
        end)
    end)
end)

--==================== HEADER ====================--
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 96)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 5
topBar.Parent = main

local crownGlow = Instance.new("Frame")
crownGlow.Position = UDim2.fromOffset(16, 20)
crownGlow.Size = UDim2.fromOffset(58, 58)
crownGlow.BackgroundColor3 = CONFIG.Gold
crownGlow.BackgroundTransparency = 0.55
crownGlow.BorderSizePixel = 0
crownGlow.ZIndex = 5
crownGlow.Parent = topBar
corner(crownGlow, 18)
task.spawn(function()
    pcall(function()
        while crownGlow.Parent do
            tw(crownGlow, {BackgroundTransparency = 0.3, Size = UDim2.fromOffset(62, 62), Position = UDim2.fromOffset(14, 18)}, 1.3, Enum.EasingStyle.Sine)
            task.wait(1.3)
            tw(crownGlow, {BackgroundTransparency = 0.7, Size = UDim2.fromOffset(58, 58), Position = UDim2.fromOffset(16, 20)}, 1.3, Enum.EasingStyle.Sine)
            task.wait(1.3)
        end
    end)
end)

local iconBg = Instance.new("Frame")
iconBg.Position = UDim2.fromOffset(22, 26)
iconBg.Size = UDim2.fromOffset(46, 46)
iconBg.BorderSizePixel = 0
iconBg.ZIndex = 6
iconBg.Parent = topBar
corner(iconBg, 14)
gradient(iconBg, 135, {
    {0.0, CONFIG.GoldBright},
    {0.35, CONFIG.Gold},
    {0.70, CONFIG.GoldDeep},
    {1.0, Color3.fromRGB(148, 106, 52)},
})
stroke(iconBg, CONFIG.Accent4, 1.5, 0.2)

local iconText = Instance.new("TextLabel")
iconText.BackgroundTransparency = 1
iconText.Size = UDim2.fromScale(1, 1)
iconText.Font = Enum.Font.GothamBlack
iconText.Text = "♛"
iconText.TextSize = 28
iconText.TextColor3 = Color3.fromRGB(96, 22, 34)
iconText.ZIndex = 7
iconText.Parent = iconBg

local titleLbl = Instance.new("TextLabel")
titleLbl.BackgroundTransparency = 1
titleLbl.Position = UDim2.fromOffset(84, 18)
titleLbl.Size = UDim2.new(1, -190, 0, 30)
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.Text = "MONK SCRIPTS"
titleLbl.TextSize = 23
titleLbl.TextColor3 = CONFIG.TextMain
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 6
titleLbl.Parent = topBar
gradient(titleLbl, 0, {
    {0.00, Color3.fromRGB(255, 255, 255)},
    {0.42, Color3.fromRGB(255, 255, 255)},
    {0.50, CONFIG.GoldBright},
    {0.58, Color3.fromRGB(255, 255, 255)},
    {1.00, Color3.fromRGB(255, 255, 255)},
})

local subLbl = Instance.new("TextLabel")
subLbl.BackgroundTransparency = 1
subLbl.Position = UDim2.fromOffset(84, 48)
subLbl.Size = UDim2.new(1, -190, 0, 16)
subLbl.Font = Enum.Font.GothamBold
subLbl.Text = "ROYAL ACCESS  ♛  VIP MEMBER"
subLbl.TextSize = 10
subLbl.TextColor3 = CONFIG.Gold
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.ZIndex = 6
subLbl.Parent = topBar

local statusPill = Instance.new("Frame")
statusPill.Position = UDim2.fromOffset(84, 68)
statusPill.Size = UDim2.fromOffset(112, 18)
statusPill.BackgroundColor3 = Color3.fromRGB(58, 14, 22)
statusPill.BackgroundTransparency = 0.35
statusPill.BorderSizePixel = 0
statusPill.ZIndex = 6
statusPill.Parent = topBar
corner(statusPill, 9)
stroke(statusPill, CONFIG.Gold, 1, 0.4)

local statusDot = Instance.new("Frame")
statusDot.Position = UDim2.fromOffset(7, 7)
statusDot.Size = UDim2.fromOffset(4, 4)
statusDot.BackgroundColor3 = CONFIG.Success
statusDot.BorderSizePixel = 0
statusDot.ZIndex = 7
statusDot.Parent = statusPill
corner(statusDot, 2)

local statusTxt = Instance.new("TextLabel")
statusTxt.BackgroundTransparency = 1
statusTxt.Position = UDim2.fromOffset(18, 0)
statusTxt.Size = UDim2.new(1, -20, 1, 0)
statusTxt.Font = Enum.Font.GothamBold
statusTxt.Text = "SERVERS ONLINE"
statusTxt.TextSize = 9
statusTxt.TextColor3 = CONFIG.GoldBright
statusTxt.TextXAlignment = Enum.TextXAlignment.Left
statusTxt.ZIndex = 7
statusTxt.Parent = statusPill

task.spawn(function()
    pcall(function()
        while statusDot.Parent do
            tw(statusDot, {BackgroundTransparency = 0.5}, 1, Enum.EasingStyle.Sine)
            task.wait(1)
            tw(statusDot, {BackgroundTransparency = 0}, 1, Enum.EasingStyle.Sine)
            task.wait(1)
        end
    end)
end)

local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -20, 0, 22)
closeBtn.Size = UDim2.fromOffset(34, 34)
closeBtn.BackgroundColor3 = Color3.fromRGB(52, 12, 20)
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 15
closeBtn.TextColor3 = CONFIG.Gold
closeBtn.AutoButtonColor = false
closeBtn.BorderSizePixel = 0
closeBtn.ZIndex = 7
closeBtn.Parent = topBar
corner(closeBtn, 10)
stroke(closeBtn, CONFIG.Gold, 1.2, 0.35)
closeBtn.MouseEnter:Connect(function()
    tw(closeBtn, {BackgroundColor3 = CONFIG.Accent, TextColor3 = CONFIG.TextMain}, 0.16)
end)
closeBtn.MouseLeave:Connect(function()
    tw(closeBtn, {BackgroundColor3 = Color3.fromRGB(52, 12, 20), TextColor3 = CONFIG.Gold}, 0.16)
end)
closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local dividerGlow = Instance.new("Frame")
dividerGlow.Position = UDim2.fromOffset(22, 92)
dividerGlow.Size = UDim2.new(1, -44, 0, 3)
dividerGlow.BackgroundColor3 = CONFIG.Gold
dividerGlow.BackgroundTransparency = 0.65
dividerGlow.BorderSizePixel = 0
dividerGlow.ZIndex = 3
dividerGlow.Parent = main
corner(dividerGlow, 2)

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(22, 93)
divider.Size = UDim2.new(1, -44, 0, 1)
divider.BackgroundColor3 = CONFIG.GoldBright
divider.BackgroundTransparency = 0.15
divider.BorderSizePixel = 0
divider.ZIndex = 4
divider.Parent = main

-- Tier badges
local tierRow = Instance.new("Frame")
tierRow.Position = UDim2.fromOffset(22, 106)
tierRow.Size = UDim2.new(1, -44, 0, 22)
tierRow.BackgroundTransparency = 1
tierRow.ZIndex = 3
tierRow.Parent = main

local function makeBadge(text, xOff, w, gold)
    local b = Instance.new("Frame")
    b.Position = UDim2.fromOffset(xOff, 0)
    b.Size = UDim2.fromOffset(w, 20)
    b.BackgroundColor3 = gold and Color3.fromRGB(72, 46, 18) or Color3.fromRGB(48, 12, 20)
    b.BackgroundTransparency = 0.35
    b.BorderSizePixel = 0
    b.ZIndex = 4
    b.Parent = tierRow
    corner(b, 10)
    stroke(b, gold and CONFIG.GoldBright or CONFIG.Accent2, 1, 0.4)
    local l = Instance.new("TextLabel")
    l.BackgroundTransparency = 1
    l.Size = UDim2.fromScale(1, 1)
    l.Font = Enum.Font.GothamBold
    l.Text = text
    l.TextSize = 9
    l.TextColor3 = gold and CONFIG.GoldBright or CONFIG.Accent3
    l.ZIndex = 5
    l.Parent = b
    return b
end

makeBadge("◆  ELITE", 0, 82, true)
makeBadge("◇  VERIFIED", 90, 92, false)
makeBadge("★  PRIORITY", 190, 96, true)

-- Input
local inputLbl = Instance.new("TextLabel")
inputLbl.BackgroundTransparency = 1
inputLbl.Position = UDim2.fromOffset(24, 140)
inputLbl.Size = UDim2.new(1, -48, 0, 16)
inputLbl.Font = Enum.Font.GothamBold
inputLbl.Text = "◈  LICENSE KEY"
inputLbl.TextSize = 10
inputLbl.TextColor3 = CONFIG.TextSoft
inputLbl.TextXAlignment = Enum.TextXAlignment.Left
inputLbl.ZIndex = 3
inputLbl.Parent = main

local inputHolder = Instance.new("Frame")
inputHolder.Position = UDim2.fromOffset(22, 160)
inputHolder.Size = UDim2.new(1, -44, 0, 52)
inputHolder.BackgroundColor3 = Color3.fromRGB(10, 2, 5)
inputHolder.BackgroundTransparency = 0.15
inputHolder.BorderSizePixel = 0
inputHolder.ZIndex = 3
inputHolder.Parent = main
corner(inputHolder, 13)
gradient(inputHolder, 90, {
    {0.0, Color3.fromRGB(16, 4, 8)},
    {1.0, Color3.fromRGB(30, 8, 14)},
}, {{0.0, 0.0},{1.0, 0.15}})
local inputStroke = stroke(inputHolder, CONFIG.Gold, 1.3, 0.35)

local inputGlowStroke = Instance.new("UIStroke")
inputGlowStroke.Color = CONFIG.Accent2
inputGlowStroke.Thickness = 4
inputGlowStroke.Transparency = 0.92
inputGlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
inputGlowStroke.Parent = inputHolder

local keyIcon = Instance.new("TextLabel")
keyIcon.BackgroundTransparency = 1
keyIcon.Position = UDim2.fromOffset(14, 0)
keyIcon.Size = UDim2.fromOffset(22, 52)
keyIcon.Font = Enum.Font.GothamBold
keyIcon.Text = "⚿"
keyIcon.TextSize = 20
keyIcon.TextColor3 = CONFIG.Gold
keyIcon.ZIndex = 4
keyIcon.Parent = inputHolder

local keyBox = Instance.new("TextBox")
keyBox.Position = UDim2.fromOffset(44, 0)
keyBox.Size = UDim2.new(1, -58, 1, 0)
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
    tw(inputStroke, {Color = CONFIG.GoldBright, Transparency = 0.05, Thickness = 1.8}, 0.2)
    tw(inputGlowStroke, {Transparency = 0.5, Thickness = 5}, 0.3)
    tw(keyIcon, {TextColor3 = CONFIG.GoldBright}, 0.2)
end)
keyBox.FocusLost:Connect(function(enter)
    tw(inputStroke, {Color = CONFIG.Gold, Transparency = 0.35, Thickness = 1.3}, 0.25)
    tw(inputGlowStroke, {Transparency = 0.92, Thickness = 4}, 0.35)
    tw(keyIcon, {TextColor3 = CONFIG.Gold}, 0.25)
    if enter and _G.__MONK_VERIFY then _G.__MONK_VERIFY() end
end)

-- Buttons — VISIBLE FROM CREATION, no transparency toggle
local function makeButton(text, yPos, primary, icon)
    local btn = Instance.new("TextButton")
    btn.Position = UDim2.fromOffset(22, yPos)
    btn.Size = UDim2.new(1, -44, 0, 50)
    btn.Text = ""
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.ClipsDescendants = true
    btn.BackgroundTransparency = 0
    btn.Visible = true
    btn.ZIndex = 3
    btn.Parent = main
    corner(btn, 14)
    local scale = Instance.new("UIScale"); scale.Parent = btn

    if primary then
        btn.BackgroundColor3 = CONFIG.Accent
        gradient(btn, 90, {
            {0.0, Color3.fromRGB(240, 62, 90)},
            {0.45, Color3.fromRGB(198, 26, 52)},
            {1.0, Color3.fromRGB(144, 14, 32)},
        })
    else
        btn.BackgroundColor3 = Color3.fromRGB(52, 14, 22)
        gradient(btn, 90, {
            {0.0, Color3.fromRGB(78, 22, 34)},
            {1.0, Color3.fromRGB(46, 12, 20)},
        })
    end

    local s = stroke(btn, primary and CONFIG.Accent4 or CONFIG.Gold, 1.5, primary and 0.2 or 0.35)

    local shimmer = Instance.new("Frame")
    shimmer.Size = UDim2.new(0, 80, 1, 0)
    shimmer.Position = UDim2.new(0, -100, 0, 0)
    shimmer.BackgroundColor3 = Color3.fromRGB(255, 250, 230)
    shimmer.BackgroundTransparency = 0.8
    shimmer.BorderSizePixel = 0
    shimmer.ZIndex = 4
    shimmer.Parent = btn
    local shimmerGrad = Instance.new("UIGradient")
    shimmerGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0.3),
        NumberSequenceKeypoint.new(1, 1),
    })
    shimmerGrad.Parent = shimmer

    local iconLbl = Instance.new("TextLabel")
    iconLbl.BackgroundTransparency = 1
    iconLbl.Position = UDim2.fromOffset(20, 0)
    iconLbl.Size = UDim2.fromOffset(20, 50)
    iconLbl.Font = Enum.Font.GothamBold
    iconLbl.Text = icon or ""
    iconLbl.TextSize = 16
    iconLbl.TextColor3 = primary and Color3.fromRGB(255, 242, 246) or CONFIG.GoldBright
    iconLbl.TextTransparency = 0
    iconLbl.ZIndex = 5
    iconLbl.Parent = btn

    local lbl = Instance.new("TextLabel")
    lbl.BackgroundTransparency = 1
    lbl.Position = UDim2.fromOffset(0, 0)
    lbl.Size = UDim2.fromScale(1, 1)
    lbl.Font = Enum.Font.GothamBold
    lbl.Text = text
    lbl.TextSize = 14
    lbl.TextColor3 = primary and Color3.fromRGB(255, 250, 250) or CONFIG.GoldBright
    lbl.TextTransparency = 0
    lbl.ZIndex = 5
    lbl.Parent = btn

    local function doRipple(mx, my)
        local ripple = Instance.new("Frame")
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.fromOffset(mx, my)
        ripple.Size = UDim2.fromOffset(0, 0)
        ripple.BackgroundColor3 = Color3.fromRGB(255, 250, 230)
        ripple.BackgroundTransparency = 0.6
        ripple.BorderSizePixel = 0
        ripple.ZIndex = 6
        ripple.Parent = btn
        corner(ripple, 100)
        tw(ripple, {Size = UDim2.fromOffset(240, 240), BackgroundTransparency = 1}, 0.6)
        task.delay(0.65, function() if ripple then ripple:Destroy() end end)
    end

    btn.MouseEnter:Connect(function()
        tw(scale, {Scale = 1.035}, 0.18, Enum.EasingStyle.Back)
        tw(s, {Transparency = 0.02, Thickness = 2.4}, 0.2)
        tw(shimmer, {Position = UDim2.new(1, 20, 0, 0)}, 0.75, Enum.EasingStyle.Quad)
        task.delay(0.75, function()
            if shimmer and shimmer.Parent then shimmer.Position = UDim2.new(0, -100, 0, 0) end
        end)
    end)
    btn.MouseLeave:Connect(function()
        tw(scale, {Scale = 1}, 0.22)
        tw(s, {Transparency = primary and 0.2 or 0.35, Thickness = 1.5}, 0.24)
    end)
    btn.MouseButton1Down:Connect(function() tw(scale, {Scale = 0.96}, 0.08) end)
    btn.MouseButton1Up:Connect(function()
        tw(scale, {Scale = 1.035}, 0.14)
        local mx, my = UserInputService:GetMouseLocation()
        doRipple(mx - btn.AbsolutePosition.X, my - btn.AbsolutePosition.Y)
    end)

    return btn, lbl, s, scale, iconLbl, shimmer
end

local verifyBtn, verifyLbl, verifyStroke, verifyScale, verifyIcon, verifyShimmer = makeButton("VERIFY KEY", 228, true, "✓")
local getKeyBtn, getKeyLbl, getKeyStroke, getKeyScale, getKeyIcon, getKeyShimmer = makeButton("GET KEY", 286, false, "✦")

-- Spinner
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
corner(ring, 100)

local spinnerActive = false
task.spawn(function()
    pcall(function()
        while spinnerHolder.Parent do
            if spinnerActive then ringGrad.Rotation = (ringGrad.Rotation + 12) % 360 end
            task.wait(0.02)
        end
    end)
end)

local function showSpinner(show)
    spinnerActive = show
    spinnerHolder.Visible = show
    verifyIcon.Visible = not show
end

-- Debug log
local debugLabel = Instance.new("TextLabel")
debugLabel.BackgroundTransparency = 1
debugLabel.Position = UDim2.fromOffset(24, 348)
debugLabel.Size = UDim2.new(1, -48, 0, 14)
debugLabel.Font = Enum.Font.GothamBold
debugLabel.Text = "◈  DIAGNOSTIC LOG"
debugLabel.TextSize = 9
debugLabel.TextColor3 = CONFIG.TextSoft
debugLabel.TextXAlignment = Enum.TextXAlignment.Left
debugLabel.ZIndex = 3
debugLabel.Parent = main

local debugBox = Instance.new("Frame")
debugBox.Position = UDim2.fromOffset(22, 364)
debugBox.Size = UDim2.new(1, -44, 0, 190)
debugBox.BackgroundColor3 = Color3.fromRGB(5, 1, 3)
debugBox.BackgroundTransparency = 0.1
debugBox.BorderSizePixel = 0
debugBox.ZIndex = 3
debugBox.Parent = main
corner(debugBox, 12)
stroke(debugBox, CONFIG.Accent, 1.2, 0.55)

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

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(22, FRAME_H - 22)
footer.Size = UDim2.new(1, -44, 0, 12)
footer.Font = Enum.Font.GothamBold
footer.Text = "♛  ROYAL VIP ACCESS  •  MONK SCRIPTS  ♛"
footer.TextSize = 9
footer.TextColor3 = CONFIG.Gold
footer.TextTransparency = 0.3
footer.TextXAlignment = Enum.TextXAlignment.Center
footer.ZIndex = 3
footer.Parent = main

-- Particles
task.delay(1.2, function()
    task.spawn(function()
        pcall(function()
            while main.Parent do
                local dot = Instance.new("Frame")
                local size = math.random(2, 5)
                dot.Size = UDim2.fromOffset(size, size)
                dot.Position = UDim2.fromOffset(math.random(20, FRAME_W - 20), FRAME_H + 10)
                dot.BackgroundColor3 = (math.random() > 0.5) and CONFIG.GoldBright or CONFIG.Gold
                dot.BackgroundTransparency = 0.35
                dot.BorderSizePixel = 0
                dot.ZIndex = 2
                dot.Parent = main
                corner(dot, size)
                local dur = math.random(55, 105) / 10
                tw(dot, {
                    Position = UDim2.fromOffset(dot.Position.X.Offset + math.random(-40, 40), -10),
                    BackgroundTransparency = 1,
                }, dur, Enum.EasingStyle.Linear)
                task.delay(dur + 0.1, function() if dot then dot:Destroy() end end)
                task.wait(math.random(4, 10) / 10)
            end
        end)
    end)
end)

-- Drag
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

-- Env check
local loadstringFn, loadstringName = detectLoadstring()
task.delay(0.6, function()
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
    if loadstringFn then log("OK: loadstring (" .. loadstringName .. ")", CONFIG.Success)
    else log("FAIL: loadstring not available", CONFIG.Fail) end
    local httpFns = {}
    if syn and syn.request then table.insert(httpFns, "syn.request") end
    if fluxus and fluxus.request then table.insert(httpFns, "fluxus.request") end
    if http and http.request then table.insert(httpFns, "http.request") end
    if request then table.insert(httpFns, "request") end
    if game.HttpGet then table.insert(httpFns, "game:HttpGet") end
    if httpget then table.insert(httpFns, "httpget") end
    if #httpFns > 0 then log("OK: HTTP (" .. table.concat(httpFns, ", ") .. ")", CONFIG.Success)
    else log("FAIL: no HTTP method", CONFIG.Fail) end
    if writefile and readfile and isfile then
        log("OK: file persistence available", CONFIG.Success)
    else
        log("WARN: file I/O unavailable — no auto-login", CONFIG.Warn)
    end
    log("=== READY ===", CONFIG.Accent2)
end)

-- Notifications
local activeNotifs = {}
local function notify(titleText, msgText, accentColor, duration)
    duration = duration or 3
    if not screenGui.Parent then return end
    local idx = #activeNotifs

    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0, -100)
    holder.Size = UDim2.fromOffset(410, 70)
    holder.BackgroundColor3 = Color3.fromRGB(26, 7, 11)
    holder.BackgroundTransparency = 0.05
    holder.BorderSizePixel = 0
    holder.ZIndex = 200
    holder.Parent = screenGui
    corner(holder, 15)
    gradient(holder, 90, {
        {0.0, Color3.fromRGB(64, 18, 27)},
        {1.0, Color3.fromRGB(24, 6, 10)},
    })
    stroke(holder, accentColor, 1.5, 0.2)

    local blur = Instance.new("BackgroundBlur")
    blur.Size = 12
    blur.Parent = holder

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
    t.Text = "♛  " .. titleText
    t.TextSize = 13
    t.TextColor3 = accentColor
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 201
    t.Parent = holder

    local m = Instance.new("TextLabel")
    m.BackgroundTransparency = 1
    m.Position = UDim2.fromOffset(22, 30)
    m.Size = UDim2.new(1, -36, 0, 30)
    m.Font = Enum.Font.Gotham
    m.Text = msgText
    m.TextSize = 11
    m.TextColor3 = Color3.fromRGB(255, 245, 247)
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextYAlignment = Enum.TextYAlignment.Top
    m.TextWrapped = true
    m.ZIndex = 201
    m.Parent = holder

    table.insert(activeNotifs, holder)
    local targetY = 20 + idx * 80
    tw(holder, {Position = UDim2.new(0.5, 0, 0, targetY)}, 0.36, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

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

-- Unlock
local unlocking = false

local function unlockScript(enteredKey)
    if unlocking then return end
    unlocking = true
    verifyLbl.Text = "VERIFYING"
    verifyBtn.Interactable = false
    showSpinner(true)
    verifyScale.Scale = 1

    log("=== VERIFY START ===", CONFIG.Accent2)

    local successRing = Instance.new("UIStroke")
    successRing.Color = CONFIG.Success
    successRing.Thickness = 6
    successRing.Transparency = 0.3
    successRing.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    successRing.Parent = verifyBtn
    tw(successRing, {Transparency = 1, Thickness = 12}, 0.85)
    task.delay(0.9, function() if successRing and successRing.Parent then successRing:Destroy() end end)

    if not loadstringFn then
        log("FAIL: loadstring disabled", CONFIG.Fail)
        notify("EXECUTOR ERROR", "loadstring is disabled. Enable it in your executor settings.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        showSpinner(false)
        return
    end

    log("Fetching script...", CONFIG.TextSoft)
    local source = httpFetch(CONFIG.ScriptURL, function(m) log(m, CONFIG.TextSoft) end)

    if not source then
        log("FAIL: fetch failed", CONFIG.Fail)
        notify("FETCH FAILED", "Network or URL issue. Check the diagnostic log.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        showSpinner(false)
        return
    end
    log("OK: fetched " .. #source .. " bytes", CONFIG.Success)

    if looksLikeHtml(source) then
        log("FAIL: HTML detected", CONFIG.Fail)
        notify("URL ERROR", "Server returned HTML instead of Lua. URL is wrong or expired.", CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        showSpinner(false)
        return
    end
    log("OK: payload is Lua", CONFIG.Success)

    log("Compiling...", CONFIG.TextSoft)
    local fn, compileErr = loadstringFn(source)
    if not fn then
        log("FAIL: compile error", CONFIG.Fail)
        log("  " .. tostring(compileErr):sub(1, 180), CONFIG.Fail)
        notify("COMPILE ERROR", tostring(compileErr):sub(1, 100), CONFIG.Fail, 6)
        unlocking = false
        verifyLbl.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        showSpinner(false)
        return
    end
    log("OK: compiled successfully", CONFIG.Success)

    if enteredKey then
        local saved = saveKey(enteredKey)
        if saved then log("OK: key saved to " .. KEY_FILE, CONFIG.Success)
        else log("WARN: could not save key", CONFIG.Warn) end
    end

    log("Executing script...", CONFIG.Warn)
    notify("KEY VERIFIED", "Saved for 24h. Executing script...", CONFIG.Success, 2.5)

    for _, child in ipairs(screenGui:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
            pcall(function() tw(child, {TextTransparency = 1}, 0.4) end)
        end
        if child:IsA("Frame") or child:IsA("ScrollingFrame") then
            pcall(function() tw(child, {BackgroundTransparency = 1}, 0.4) end)
        end
        if child:IsA("UIStroke") then
            pcall(function() tw(child, {Transparency = 1}, 0.4) end)
        end
    end

    task.wait(0.55)
    screenGui:Destroy()
    task.wait(0.1)

    local ok, runErr = pcall(fn)
    if not ok then warn("[MONK] Runtime error: " .. tostring(runErr))
    else print("[MONK] Script executed successfully") end
end

local function verifyKey()
    if unlocking then
        log("Verification already in progress...", CONFIG.Warn)
        return
    end
    log("=== KEY CHECK ===", CONFIG.Accent2)
    log("Input: " .. (keyBox.Text == "" and "(empty)" or keyBox.Text), CONFIG.TextSoft)

    if validateKeyFormat(keyBox.Text) then
        log("OK: key format valid", CONFIG.Success)
        unlockScript(keyBox.Text)
    else
        log("FAIL: invalid key format", CONFIG.Fail)
        notify("INVALID KEY", "Key is incorrect. It must start with MONK-.", CONFIG.Fail, 3)

        tw(inputStroke, {Color = CONFIG.Fail, Transparency = 0}, 0.1)
        tw(inputGlowStroke, {Color = CONFIG.Fail, Transparency = 0.3}, 0.1)
        task.wait(0.15)
        tw(inputStroke, {Color = CONFIG.Gold, Transparency = 0.35}, 0.4)
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

-- Get key
getKeyBtn.MouseButton1Click:Connect(function()
    local copied = false
    if setclipboard then copied = pcall(setclipboard, CONFIG.KeySite) end
    if not copied and toclipboard then copied = pcall(toclipboard, CONFIG.KeySite) end
    if not copied and syn and syn.setclipboard then copied = pcall(syn.setclipboard, CONFIG.KeySite) end

    if copied then
        notify("KEY LINK COPIED", "The key system link has been copied to your clipboard.", CONFIG.Success, 3)
    else
        notify("KEY LINK", "keysystemnymomk.vercel.app", CONFIG.Warn, 4)
    end

    local old = getKeyLbl.Text
    getKeyLbl.Text = "COPIED ✓"
    tw(getKeyStroke, {Color = CONFIG.Success, Transparency = 0.05}, 0.16)
    task.delay(1.6, function()
        if getKeyLbl and getKeyLbl.Parent then getKeyLbl.Text = old end
        if getKeyStroke and getKeyStroke.Parent then
            tw(getKeyStroke, {Color = CONFIG.Gold, Transparency = 0.35}, 0.3)
        end
    end)
end)

-- Welcome
task.delay(1.2, function()
    notify("WELCOME TO ROYAL VIP", "Enter your MONK- key. Valid keys save for 24h auto-login.", CONFIG.Gold, 4.5)
end)

-- SAFETY NET: after 3s, force all critical elements visible
task.delay(3, function()
    pcall(function()
        if not main or not main.Parent then return end
        main.Visible = true
        main.Size = UDim2.fromOffset(FRAME_W, FRAME_H)
        verifyBtn.Visible = true
        verifyBtn.BackgroundTransparency = 0
        verifyBtn.Size = UDim2.new(1, -44, 0, 50)
        verifyBtn.Position = UDim2.fromOffset(22, 228)
        getKeyBtn.Visible = true
        getKeyBtn.BackgroundTransparency = 0
        getKeyBtn.Size = UDim2.new(1, -44, 0, 50)
        getKeyBtn.Position = UDim2.fromOffset(22, 286)
        keyBox.Visible = true
        verifyLbl.TextTransparency = 0
        getKeyLbl.TextTransparency = 0
        verifyIcon.TextTransparency = 0
        getKeyIcon.TextTransparency = 0
        print("[MONK] Safety net applied — all elements forced visible")
    end)
end)