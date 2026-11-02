--[[
    ═══════════════════════════════════════════════════════════════
      MONK SCRIPTS  •  PREMIUM KEY SYSTEM
      Theme : Maroon / Red Glass   |   UI : Compact (Full Screen Nahi)
    ═══════════════════════════════════════════════════════════════
]]

local Players          = game:GetService("Players")
local TweenService     = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer

--==================== CONFIG ====================--
local CONFIG = {
    Prefix    = "MONK-",                                                   -- Key ka prefix
    KeySite   = "https://keysystemnymomk.vercel.app/",                     -- Get Key site
    ScriptURL = "https://monk-scripts-novoline-loaderlua.vercel.app/?EXECUTOR=true", -- Script URL

    Accent   = Color3.fromRGB(196, 28, 52),
    Accent2  = Color3.fromRGB(255, 84, 104),
    Dark     = Color3.fromRGB(26, 7, 11),
    Dark2    = Color3.fromRGB(48, 13, 20),
    TextMain = Color3.fromRGB(255, 240, 242),
    TextSoft = Color3.fromRGB(214, 150, 160),
}
--================================================--

--==================== HELPERS ====================--
local function tw(obj, props, t, style, dir)
    local info = TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out)
    local a = TweenService:Create(obj, info, props)
    a:Play()
    return a
end

local function corner(parent, r)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, r or 10)
    c.Parent = parent
    return c
end

local function stroke(parent, color, thick, trans)
    local s = Instance.new("UIStroke")
    s.Color = color or CONFIG.Accent
    s.Thickness = thick or 1.5
    s.Transparency = trans or 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function httpGet(url)
    local ok, res = pcall(function() return game:HttpGet(url) end)
    if ok and type(res) == "string" then return res end
    if httpget then
        local ok2, res2 = pcall(httpget, url)
        if ok2 and type(res2) == "string" then return res2 end
    end
    return nil
end

local function copyText(txt)
    if setclipboard then pcall(setclipboard, txt) return true end
    if toclipboard then pcall(toclipboard, txt) return true end
    if syn and syn.setclipboard then pcall(syn.setclipboard, txt) return true end
    return false
end
--================================================--

--==================== PARENT (Anti-Duplicate) ====================--
local parent
if gethui then
    local ok, hui = pcall(gethui)
    if ok and hui then parent = hui end
end
if not parent then
    local ok, cg = pcall(function() return game:GetService("CoreGui") end)
    if ok and cg then parent = cg end
end
if not parent then parent = LP:WaitForChild("PlayerGui") end

for _, p in ipairs({parent, LP:WaitForChild("PlayerGui")}) do
    local old = p:FindFirstChild("MonkKeySystem")
    if old then old:Destroy() end
end
--================================================================--

--==================== SCREEN GUI ====================--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MonkKeySystem"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.DisplayOrder = 999999
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local parented = pcall(function() screenGui.Parent = parent end)
if not parented or not screenGui.Parent then
    screenGui.Parent = LP:WaitForChild("PlayerGui")
end

--==================== MAIN FRAME ====================--
local main = Instance.new("Frame")
main.Name = "Main"
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.Position = UDim2.fromScale(0.5, 0.5)
main.Size = UDim2.fromOffset(400, 300)
main.BackgroundColor3 = CONFIG.Dark
main.BackgroundTransparency = 0.1
main.BorderSizePixel = 0
main.Parent = screenGui

corner(main, 18)
stroke(main, CONFIG.Accent, 1.6, 0.45)

local mainGrad = Instance.new("UIGradient")
mainGrad.Rotation = 90
mainGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0.00, Color3.fromRGB(74, 16, 26)),
    ColorSequenceKeypoint.new(0.45, Color3.fromRGB(38, 9, 15)),
    ColorSequenceKeypoint.new(1.00, Color3.fromRGB(18, 4, 8)),
})
mainGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.02),
    NumberSequenceKeypoint.new(1, 0.22),
})
mainGrad.Parent = main

-- Glassy blur behind
local bgBlur = Instance.new("BackgroundBlur")
bgBlur.Size = 14
bgBlur.Parent = main

-- Mobile auto-scale
local uiScale = Instance.new("UIScale")
uiScale.Parent = main
local function updateScale()
    local cam = workspace.CurrentCamera
    if cam then
        local vp = cam.ViewportSize
        uiScale.Scale = math.clamp(math.min(vp.X / 470, vp.Y / 380), 0.65, 1)
    end
end
updateScale()
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    local cam = workspace.CurrentCamera
    if cam then cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale) end
    updateScale()
end)

--==================== TOP BAR (Draggable) ====================--
local topBar = Instance.new("Frame")
topBar.Name = "TopBar"
topBar.Size = UDim2.new(1, 0, 0, 58)
topBar.BackgroundTransparency = 1
topBar.ZIndex = 5
topBar.Parent = main

local titleLbl = Instance.new("TextLabel")
titleLbl.BackgroundTransparency = 1
titleLbl.Position = UDim2.fromOffset(22, 9)
titleLbl.Size = UDim2.new(1, -90, 0, 28)
titleLbl.Font = Enum.Font.GothamBlack
titleLbl.Text = "KEY"
titleLbl.TextSize = 24
titleLbl.TextColor3 = CONFIG.TextMain
titleLbl.TextXAlignment = Enum.TextXAlignment.Left
titleLbl.ZIndex = 6
titleLbl.Parent = topBar

local titleGrad = Instance.new("UIGradient")
titleGrad.Rotation = 90
titleGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 150, 168)),
})
titleGrad.Parent = titleLbl

local subLbl = Instance.new("TextLabel")
subLbl.BackgroundTransparency = 1
subLbl.Position = UDim2.fromOffset(23, 35)
subLbl.Size = UDim2.new(1, -90, 0, 14)
subLbl.Font = Enum.Font.GothamMedium
subLbl.Text = "MONK SCRIPTS  •  PREMIUM"
subLbl.TextSize = 10
subLbl.TextColor3 = CONFIG.Accent2
subLbl.TextTransparency = 0.15
subLbl.TextXAlignment = Enum.TextXAlignment.Left
subLbl.ZIndex = 6
subLbl.Parent = topBar

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.AnchorPoint = Vector2.new(1, 0)
closeBtn.Position = UDim2.new(1, -16, 0, 16)
closeBtn.Size = UDim2.fromOffset(28, 28)
closeBtn.BackgroundColor3 = Color3.fromRGB(60, 14, 22)
closeBtn.BackgroundTransparency = 0.25
closeBtn.Text = "✕"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 13
closeBtn.TextColor3 = CONFIG.Accent2
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 7
closeBtn.Parent = topBar
corner(closeBtn, 8)
stroke(closeBtn, CONFIG.Accent, 1, 0.6)

closeBtn.MouseEnter:Connect(function() tw(closeBtn, {BackgroundColor3 = CONFIG.Accent, TextColor3 = CONFIG.TextMain}, 0.15) end)
closeBtn.MouseLeave:Connect(function() tw(closeBtn, {BackgroundColor3 = Color3.fromRGB(60, 14, 22), TextColor3 = CONFIG.Accent2}, 0.15) end)
closeBtn.MouseButton1Click:Connect(function()
    tw(main, {Size = UDim2.fromOffset(0, 0)}, 0.18)
    task.delay(0.2, function() screenGui:Destroy() end)
end)

-- Divider
local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(22, 60)
divider.Size = UDim2.new(1, -44, 0, 1)
divider.BackgroundColor3 = CONFIG.Accent
divider.BackgroundTransparency = 0.65
divider.BorderSizePixel = 0
divider.Parent = main

--==================== INPUT LABEL ====================--
local inputLbl = Instance.new("TextLabel")
inputLbl.BackgroundTransparency = 1
inputLbl.Position = UDim2.fromOffset(22, 74)
inputLbl.Size = UDim2.new(1, -44, 0, 14)
inputLbl.Font = Enum.Font.GothamBold
inputLbl.Text = "ENTER YOUR KEY"
inputLbl.TextSize = 11
inputLbl.TextColor3 = CONFIG.TextSoft
inputLbl.TextXAlignment = Enum.TextXAlignment.Left
inputLbl.Parent = main

--==================== INPUT BOX ====================--
local inputHolder = Instance.new("Frame")
inputHolder.Position = UDim2.fromOffset(22, 92)
inputHolder.Size = UDim2.new(1, -44, 0, 44)
inputHolder.BackgroundColor3 = Color3.fromRGB(14, 4, 7)
inputHolder.BackgroundTransparency = 0.18
inputHolder.BorderSizePixel = 0
inputHolder.Parent = main
corner(inputHolder, 10)
local inputStroke = stroke(inputHolder, CONFIG.Accent, 1.2, 0.55)

local keyBox = Instance.new("TextBox")
keyBox.Position = UDim2.fromOffset(14, 0)
keyBox.Size = UDim2.new(1, -28, 1, 0)
keyBox.BackgroundTransparency = 1
keyBox.Font = Enum.Font.GothamMedium
keyBox.Text = ""
keyBox.PlaceholderText = "MONK-XXXXXXXXXX"
keyBox.PlaceholderColor3 = Color3.fromRGB(118, 55, 66)
keyBox.TextColor3 = CONFIG.TextMain
keyBox.TextSize = 14
keyBox.TextXAlignment = Enum.TextXAlignment.Left
keyBox.ClearTextOnFocus = false
keyBox.Parent = inputHolder

keyBox.Focused:Connect(function() tw(inputStroke, {Transparency = 0.05, Thickness = 1.8}, 0.15) end)
keyBox.FocusLost:Connect(function(enter)
    tw(inputStroke, {Transparency = 0.55, Thickness = 1.2}, 0.15)
    if enter then
        -- Verify on Enter
        if _G.__MONK_VERIFY then _G.__MONK_VERIFY() end
    end
end)

--==================== BUTTONS ====================--
local function makeButton(text, yPos, primary)
    local btn = Instance.new("TextButton")
    btn.Position = UDim2.fromOffset(22, yPos)
    btn.Size = UDim2.new(1, -44, 0, 42)
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.AutoButtonColor = false
    btn.BorderSizePixel = 0
    btn.Parent = main
    corner(btn, 10)

    if primary then
        btn.BackgroundColor3 = CONFIG.Accent
        btn.TextColor3 = CONFIG.TextMain
        local g = Instance.new("UIGradient")
        g.Rotation = 90
        g.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 45, 70)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(148, 18, 36)),
        })
        g.Parent = btn
    else
        btn.BackgroundColor3 = CONFIG.Dark2
        btn.BackgroundTransparency = 0.45
        btn.TextColor3 = CONFIG.Accent2
    end

    local s = stroke(btn, primary and CONFIG.Accent2 or CONFIG.Accent, 1.4, primary and 0.55 or 0.35)

    btn.MouseEnter:Connect(function()
        tw(s, {Transparency = 0.05, Thickness = 2}, 0.15)
        tw(btn, {BackgroundTransparency = primary and 0 or 0.2}, 0.15)
    end)
    btn.MouseLeave:Connect(function()
        tw(s, {Transparency = primary and 0.55 or 0.35, Thickness = 1.4}, 0.15)
        tw(btn, {BackgroundTransparency = primary and 0 or 0.45}, 0.15)
    end)

    return btn, s
end

local verifyBtn, verifyStroke = makeButton("VERIFY KEY", 148, true)
local getKeyBtn  = makeButton("GET KEY", 200, false)

--==================== FOOTER ====================--
local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(22, 256)
footer.Size = UDim2.new(1, -44, 0, 16)
footer.Font = Enum.Font.Gotham
footer.Text = "Key format:  MONK-XXXX   •   Powered by MONK SCRIPTS"
footer.TextSize = 10
footer.TextColor3 = CONFIG.TextSoft
footer.TextTransparency = 0.35
footer.Parent = main

--==================== DRAG SYSTEM ====================--
local dragging, dragInput, dragStart, startPos = false, nil, nil, nil

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
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
        main.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)

--==================== NOTIFICATION SYSTEM ====================--
local activeNotifs = {}

local function notify(titleText, msgText, accentColor, duration)
    duration = duration or 3
    if not screenGui.Parent then return end

    local idx = #activeNotifs

    local holder = Instance.new("Frame")
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0, -90)
    holder.Size = UDim2.fromOffset(340, 54)
    holder.BackgroundColor3 = CONFIG.Dark
    holder.BackgroundTransparency = 0.05
    holder.BorderSizePixel = 0
    holder.ZIndex = 100
    holder.Parent = screenGui
    corner(holder, 12)
    stroke(holder, accentColor, 1.3, 0.35)

    local g = Instance.new("UIGradient")
    g.Rotation = 90
    g.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(52, 14, 22)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(22, 6, 10)),
    })
    g.Parent = holder

    local accentBar = Instance.new("Frame")
    accentBar.Position = UDim2.fromOffset(0, 10)
    accentBar.Size = UDim2.new(0, 3, 1, -20)
    accentBar.BackgroundColor3 = accentColor
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 101
    accentBar.Parent = holder
    corner(accentBar, 2)

    local t = Instance.new("TextLabel")
    t.BackgroundTransparency = 1
    t.Position = UDim2.fromOffset(16, 8)
    t.Size = UDim2.new(1, -30, 0, 16)
    t.Font = Enum.Font.GothamBold
    t.Text = titleText
    t.TextSize = 13
    t.TextColor3 = accentColor
    t.TextXAlignment = Enum.TextXAlignment.Left
    t.ZIndex = 101
    t.Parent = holder

    local m = Instance.new("TextLabel")
    m.BackgroundTransparency = 1
    m.Position = UDim2.fromOffset(16, 26)
    m.Size = UDim2.new(1, -30, 0, 16)
    m.Font = Enum.Font.Gotham
    m.Text = msgText
    m.TextSize = 11
    m.TextColor3 = CONFIG.TextMain
    m.TextTransparency = 0.15
    m.TextXAlignment = Enum.TextXAlignment.Left
    m.TextTruncate = Enum.TextTruncate.AtEnd
    m.ZIndex = 101
    m.Parent = holder

    table.insert(activeNotifs, holder)

    -- Stack position
    local targetY = 20 + idx * 62
    tw(holder, {Position = UDim2.new(0.5, 0, 0, targetY)}, 0.28, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    task.delay(duration, function()
        if holder and holder.Parent then
            tw(holder, {Position = UDim2.new(0.5, 0, 0, -90), BackgroundTransparency = 1}, 0.25)
            tw(t, {TextTransparency = 1}, 0.25)
            tw(m, {TextTransparency = 1}, 0.25)
            task.wait(0.3)
            for i, v in ipairs(activeNotifs) do
                if v == holder then table.remove(activeNotifs, i) break end
            end
            holder:Destroy()
        end
    end)
end

--==================== KEY VALIDATION ====================--
local function isValidKey(raw)
    if type(raw) ~= "string" then return false end
    local k = raw:gsub("^%s+", ""):gsub("%s+$", "")
    if #k <= #CONFIG.Prefix then return false end
    return string.upper(string.sub(k, 1, #CONFIG.Prefix)) == CONFIG.Prefix
end

--==================== SCRIPT UNLOCK ====================--
local unlocking = false

local function unlockScript()
    if unlocking then return end
    unlocking = true

    verifyBtn.Text = "VERIFYING..."
    verifyBtn.Interactable = false

    notify("KEY VERIFIED ✓", "Script load ho rahi hai...", Color3.fromRGB(80, 205, 120), 2.5)

    task.wait(0.7)

    local source = httpGet(CONFIG.ScriptURL)

    if not source or type(source) ~= "string" or #source < 10 then
        unlocking = false
        verifyBtn.Text = "VERIFY KEY"
        verifyBtn.Interactable = true
        notify("LOAD FAILED", "Script fetch nahi hui, dobara try karo.", Color3.fromRGB(255, 90, 90), 3)
        return
    end

    -- GUI band karo
    tw(main, {Size = UDim2.fromOffset(0, 0), BackgroundTransparency = 1}, 0.2)
    task.wait(0.25)
    screenGui:Destroy()

    task.wait(0.1)

    local ok, err = pcall(function()
        local fn = loadstring(source)
        if not fn then error("loadstring() failed") end
        fn()
    end)

    if not ok then
        warn("[MONK KEY SYSTEM] Script error: " .. tostring(err))
    end
end

--==================== VERIFY LOGIC ====================--
local function verifyKey()
    local entered = keyBox.Text

    if isValidKey(entered) then
        unlockScript()
    else
        -- Wrong key
        notify("INVALID KEY", "Key galat hai! Key link is given below.", Color3.fromRGB(255, 70, 85), 3)

        -- Red shake + flash
        tw(inputStroke, {Color = Color3.fromRGB(255, 60, 60), Transparency = 0}, 0.12)
        task.wait(0.12)
        tw(inputStroke, {Color = CONFIG.Accent, Transparency = 0.55}, 0.35)

        local origPos = main.Position
        for i = 1, 4 do
            main.Position = origPos + UDim2.fromOffset((i % 2 == 0) and 8 or -8, 0)
            task.wait(0.04)
        end
        main.Position = origPos

        -- Get Key button highlight
        tw(getKeyBtn, {BackgroundTransparency = 0}, 0.15)
        task.delay(1.2, function()
            if getKeyBtn and getKeyBtn.Parent then
                tw(getKeyBtn, {BackgroundTransparency = 0.45}, 0.3)
            end
        end)
    end
end

_G.__MONK_VERIFY = verifyKey

verifyBtn.MouseButton1Click:Connect(verifyKey)

--==================== GET KEY LOGIC ====================--
getKeyBtn.MouseButton1Click:Connect(function()
    local copied = copyText(CONFIG.KeySite)

    if copied then
        notify("KEY LINK COPIED", "key system link copied ✓", Color3.fromRGB(80, 205, 120), 3)
    else
        notify("KEY LINK", "keysystemnymomk.vercel.app", Color3.fromRGB(255, 180, 60), 3)
    end

    local oldText = getKeyBtn.Text
    getKeyBtn.Text = "COPIED ✓"
    task.delay(1.5, function()
        if getKeyBtn and getKeyBtn.Parent then
            getKeyBtn.Text = oldText
        end
    end)
end)

--==================== OPEN ANIMATION ====================--
main.Size = UDim2.fromOffset(0, 0)
tw(main, {Size = UDim2.fromOffset(400, 300)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

notify("WELCOME", "Apni key enter karo aur verify karo.", Color3.fromRGB(255, 100, 120), 3)