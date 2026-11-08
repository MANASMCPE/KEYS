--[[
    LIFE TOGETHER RP - GLASS HUB v6.0
    New: Copy Fit, Clone Player, Anti Fit Copier (White Garden Forever)
]]

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer

local CONFIG = {
    GUI_NAME = "LT_GlassHub",
    VERSION = "6.0",
    DEFAULT_SPEED = 16, DEFAULT_JUMP = 50, FLY_SPEED = 50,
    TELEPORT_OFFSET = Vector3.new(0, 3, 0),
    SAVE_FOLDER = "LT_GlassHub_Outfits",
    SPEED_LEVELS = {
        { name = "Normal", delay = 0.10 },
        { name = "Fast", delay = 0.06 },
        { name = "Ultra", delay = 0.04 },
    },
    DEFAULT_SPEED_LEVEL = 2,
    PROTECTION_BIO = "White Garden Forever",
}

local REMOTES = {
    setBio = { "set_bio", "update_bio", "change_bio", "save_bio", "set_profile_bio", "edit_bio" },
    setName = { "set_name", "update_name", "change_name", "save_name", "set_display_name", "edit_name" },
    setPhoneColor = { "set_phone_color", "update_phone_color", "change_phone_color", "phone_color" },
    getBio = { "get_bio", "fetch_bio", "get_profile", "get_profile_data" },
}

-- ============================================================
-- BLOCKED + SMART MATCHER
-- ============================================================
local BLOCKED_PLAYERS = { ["supermonkxscripts"] = true }

local function isBlocked(plr)
    if not plr then return true end
    return BLOCKED_PLAYERS[plr.Name:lower()] == true or BLOCKED_PLAYERS[plr.DisplayName:lower()] == true
end

local function getPlayerByName(query)
    query = (query or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
    if query == "" then return nil, "empty" end
    local players = Players:GetPlayers()
    for _, plr in ipairs(players) do
        if plr.Name:lower() == query then
            if isBlocked(plr) then return nil, "blocked" end
            return plr, "exact"
        end
    end
    for _, plr in ipairs(players) do
        if plr.DisplayName:lower() == query then
            if isBlocked(plr) then return nil, "blocked" end
            return plr, "displayname"
        end
    end
    if #query >= 2 then
        for _, plr in ipairs(players) do
            if plr.Name:lower():sub(1, #query) == query or plr.DisplayName:lower():sub(1, #query) == query then
                if isBlocked(plr) then return nil, "blocked" end
                return plr, "prefix"
            end
        end
    end
    if #query >= 3 then
        for _, plr in ipairs(players) do
            if plr.Name:lower():find(query, 1, true) or plr.DisplayName:lower():find(query, 1, true) then
                if isBlocked(plr) then return nil, "blocked" end
                return plr, "contains"
            end
        end
    end
    return nil, "not_found"
end

-- ============================================================
-- NET MODULE + GENERIC REMOTE TRY
-- ============================================================
local function getNetModule()
    local ok, net = pcall(function() return require(ReplicatedStorage:WaitForChild("Net", 5)) end)
    return ok and net or nil
end

local function tryRemotes(remoteList, method, ...)
    local Net = getNetModule()
    if not Net then return false end
    local args = table.pack(...)
    for _, remote in ipairs(remoteList) do
        local ok = pcall(function() Net[method](remote, table.unpack(args, 1, args.n)) end)
        if ok then return true, remote end
    end
    return false
end

-- ============================================================
-- PROTECTION HELPERS
-- ============================================================
local function setBio(text) return tryRemotes(REMOTES.setBio, "send", text) end
local function setName(text) return tryRemotes(REMOTES.setName, "send", text) end
local function setPhoneColor(c) return tryRemotes(REMOTES.setPhoneColor, "send", c) end

local function getTargetBio(plr)
    if not plr then return nil end
    for _, attr in ipairs({ "Bio", "bio", "ProfileBio", "profile_bio", "Description" }) do
        local v = plr:GetAttribute(attr)
        if v and type(v) == "string" and #v > 0 then return v end
    end
    if plr.Character then
        for _, attr in ipairs({ "Bio", "bio", "ProfileBio" }) do
            local v = plr.Character:GetAttribute(attr)
            if v and type(v) == "string" and #v > 0 then return v end
        end
    end
    local Net = getNetModule()
    if Net then
        for _, remote in ipairs(REMOTES.getBio) do
            local ok, result = pcall(function() return Net.get(remote, plr.UserId) end)
            if ok and type(result) == "string" and #result > 0 then return result end
            if ok and type(result) == "table" then
                for _, key in ipairs({ "bio", "Bio", "description", "Description" }) do
                    if type(result[key]) == "string" then return result[key] end
                end
            end
        end
    end
    return nil
end

local function getTargetPhoneColor(plr)
    if not plr or not plr.Character then return nil end
    for _, obj in ipairs(plr.Character:GetDescendants()) do
        local n = obj.Name:lower()
        if (n:find("phone") or n:find("mobile")) and obj:IsA("BasePart") then
            return obj.Color
        end
        if n:find("phone") and (obj:IsA("Tool") or obj:IsA("Model")) then
            local handle = obj:FindFirstChild("Handle") or obj.PrimaryPart
            if handle and handle:IsA("BasePart") then return handle.Color end
        end
    end
    for _, attr in ipairs({ "PhoneColor", "phone_color" }) do
        local v = plr:GetAttribute(attr)
        if typeof(v) == "Color3" then return v end
    end
    return nil
end

local function isTargetProtected(plr)
    local bio = getTargetBio(plr)
    if bio and bio:lower():find("white garden forever") then return true end
    for _, attr in ipairs({ "Protected", "AntiCopy", "anti_copier" }) do
        local v = plr:GetAttribute(attr)
        if v == true then return true end
    end
    return false
end

-- ============================================================
-- BLUR + GLASS
-- ============================================================
local blurEffect = Instance.new("BlurEffect")
blurEffect.Size = 0
blurEffect.Parent = Lighting
TweenService:Create(blurEffect, TweenInfo.new(0.4), { Size = 16 }):Play()

local function applyGlass(obj, opts)
    opts = opts or {}
    obj.BackgroundColor3 = opts.color or Color3.fromRGB(28, 33, 46)
    obj.BackgroundTransparency = opts.transparency or 0.28
    obj.BorderSizePixel = 0
    local stroke = Instance.new("UIStroke")
    stroke.Color = Color3.fromRGB(255, 255, 255)
    stroke.Transparency = opts.strokeTransparency or 0.55
    stroke.Thickness = opts.strokeThickness or 1.2
    stroke.Parent = obj
    local shine = Instance.new("UIGradient")
    shine.Rotation = 135
    shine.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    shine.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.55),
        NumberSequenceKeypoint.new(0.45, 0.9),
        NumberSequenceKeypoint.new(1, 0.95),
    }
    shine.Parent = obj
    return stroke, shine
end

local function addCorner(obj, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = obj
    return c
end

-- ============================================================
-- STORAGE
-- ============================================================
local saveFile, savedOutfits = nil, {}
local function initStorage()
    if not (writefile and readfile and isfile and makefolder and isfolder) then return false end
    if not isfolder(CONFIG.SAVE_FOLDER) then makefolder(CONFIG.SAVE_FOLDER) end
    saveFile = CONFIG.SAVE_FOLDER .. "/outfits.json"
    if not isfile(saveFile) then writefile(saveFile, "{}") end
    local ok, data = pcall(function() return HttpService:JSONDecode(readfile(saveFile)) end)
    savedOutfits = (ok and type(data) == "table") and data or {}
    return true
end
local function persist() if saveFile then pcall(function() writefile(saveFile, HttpService:JSONEncode(savedOutfits)) end) end end
local function saveOutfit(name, data) if name and name ~= "" then savedOutfits[name] = data; persist(); return true end return false end
local function deleteOutfit(name) if savedOutfits[name] then savedOutfits[name] = nil; persist(); return true end return false end
initStorage()

-- ============================================================
-- CHAT CAPTURE
-- ============================================================
local capturedCodes, codeOrder = {}, {}
local function captureChat(plr, msg)
    if isBlocked(plr) then return end
    for word in msg:gmatch("%S+") do
        local clean = word:gsub("[^%w]", ""):upper()
        if #clean >= 6 and #clean <= 8 and clean:match("%u") and clean:match("%d") then
            if not capturedCodes[clean] then
                capturedCodes[clean] = { from = plr.DisplayName, time = os.time() }
                table.insert(codeOrder, 1, clean)
                if #codeOrder > 30 then capturedCodes[table.remove(codeOrder)] = nil end
            end
        end
    end
end
for _, plr in ipairs(Players:GetPlayers()) do plr.Chatted:Connect(function(m) captureChat(plr, m) end) end
Players.PlayerAdded:Connect(function(plr) plr.Chatted:Connect(function(m) captureChat(plr, m) end) end)

-- ============================================================
-- SERIALIZE
-- ============================================================
local function serializeDescription(desc)
    local data = { accessories = {}, properties = {} }
    for _, acc in ipairs(desc:GetAccessories(true)) do
        local t = acc.AccessoryType.Name
        if not t:match("Accessory$") then t = t .. "Accessory" end
        table.insert(data.accessories, { id = acc.AssetId, type = t })
    end
    for _, k in ipairs({ "Shirt", "Pants", "GraphicTShirt", "Face", "IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation", "FallAnimation", "ClimbAnimation", "SwimAnimation", "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }) do
        local ok, v = pcall(function() return desc[k] end)
        if ok and v and v ~= 0 then data.properties[k] = v end
    end
    data.skinColor = { desc.HeadColor.R, desc.HeadColor.G, desc.HeadColor.B }
    return data
end

-- ============================================================
-- GUI SETUP
-- ============================================================
local parentGui = (gethui and gethui()) or CoreGui
for _, gui in ipairs(parentGui:GetChildren()) do
    if gui.Name == CONFIG.GUI_NAME or gui.Name == "LT_ProHub" or gui.Name == "LT_UltimateHub" or gui.Name == "MONKOutfitCopierGui" then gui:Destroy() end
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = CONFIG.GUI_NAME
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = parentGui

local shadow = Instance.new("Frame")
shadow.Size = UDim2.new(0, 540, 0, 720)
shadow.Position = UDim2.new(0.5, -270, 0.5, -350)
shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
shadow.BackgroundTransparency = 0.55
shadow.BorderSizePixel = 0
shadow.ZIndex = 0
shadow.Parent = ScreenGui
addCorner(shadow, 22)

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 700)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -340)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.ZIndex = 2
MainFrame.Parent = ScreenGui
addCorner(MainFrame, 18)
applyGlass(MainFrame, { transparency = 0.22, strokeTransparency = 0.45, strokeThickness = 1.6 })

local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 52)
TopBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
TopBar.BackgroundTransparency = 0.92
TopBar.BorderSizePixel = 0
TopBar.ZIndex = 3
TopBar.Parent = MainFrame
addCorner(TopBar, 18)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -160, 1, 0)
Title.Position = UDim2.new(0, 18, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "✦ GLASS HUB v" .. CONFIG.VERSION
Title.TextColor3 = Color3.fromRGB(245, 250, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.ZIndex = 4
Title.Parent = TopBar

local ProtectBadge = Instance.new("TextLabel")
ProtectBadge.Size = UDim2.new(0, 90, 0, 22)
ProtectBadge.Position = UDim2.new(1, -175, 0, 15)
ProtectBadge.BackgroundColor3 = Color3.fromRGB(120, 60, 200)
ProtectBadge.BackgroundTransparency = 0.35
ProtectBadge.Text = "🛡️ PROTECTED"
ProtectBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
ProtectBadge.Font = Enum.Font.GothamBold
ProtectBadge.TextSize = 10
ProtectBadge.Visible = false
ProtectBadge.ZIndex = 4
ProtectBadge.Parent = TopBar
addCorner(ProtectBadge, 6)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 30, 0, 30)
MinimizeBtn.Position = UDim2.new(1, -75, 0, 11)
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeBtn.Font = Enum.Font.GothamBold
MinimizeBtn.TextSize = 20
MinimizeBtn.ZIndex = 4
MinimizeBtn.Parent = TopBar
addCorner(MinimizeBtn, 8)
applyGlass(MinimizeBtn, { color = Color3.fromRGB(80, 90, 110), transparency = 0.4, strokeTransparency = 0.7 })

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -40, 0, 11)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 14
CloseBtn.ZIndex = 4
CloseBtn.Parent = TopBar
addCorner(CloseBtn, 8)
applyGlass(CloseBtn, { color = Color3.fromRGB(220, 70, 90), transparency = 0.35, strokeTransparency = 0.6 })

-- Tabs
local TabContainer = Instance.new("Frame")
TabContainer.Size = UDim2.new(1, -24, 0, 42)
TabContainer.Position = UDim2.new(0, 12, 0, 62)
TabContainer.BackgroundTransparency = 1
TabContainer.ZIndex = 3
TabContainer.Parent = MainFrame
local TabLayout = Instance.new("UIListLayout")
TabLayout.FillDirection = Enum.FillDirection.Horizontal
TabLayout.Padding = UDim.new(0, 6)
TabLayout.Parent = TabContainer

local tabs = {}
local function createTab(name, icon)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.245, 0, 1, 0)
    btn.Text = icon .. " " .. name
    btn.TextColor3 = Color3.fromRGB(230, 240, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 12
    btn.ZIndex = 4
    btn.Parent = TabContainer
    addCorner(btn, 10)
    applyGlass(btn, { color = Color3.fromRGB(40, 48, 65), transparency = 0.35, strokeTransparency = 0.7 })
    tabs[name] = btn
    return btn
end
local copierTab = createTab("Copier", "👕")
local savedTab = createTab("Saved", "💾")
local utilityTab = createTab("Utility", "⚙️")
local settingsTab = createTab("Settings", "🔧")

local ContentArea = Instance.new("Frame")
ContentArea.Size = UDim2.new(1, -24, 1, -120)
ContentArea.Position = UDim2.new(0, 12, 0, 114)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex = 3
ContentArea.Parent = MainFrame

local function newContent()
    local c = Instance.new("Frame")
    c.Size = UDim2.new(1, 0, 1, 0)
    c.BackgroundTransparency = 1
    c.Visible = false
    c.ZIndex = 3
    c.Parent = ContentArea
    return c
end
local CopierContent = newContent(); CopierContent.Visible = true
local SavedContent = newContent()
local UtilityContent = newContent()
local SettingsContent = newContent()

local function makeBtn(parent, text, pos, size, color)
    local b = Instance.new("TextButton")
    b.Size = size
    b.Position = pos
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.GothamBold
    b.TextSize = 12
    b.ZIndex = 4
    b.Parent = parent
    addCorner(b, 10)
    applyGlass(b, { color = color, transparency = 0.28, strokeTransparency = 0.55 })
    return b
end

-- ============================================================
-- COPIER TAB
-- ============================================================
local InputBox = Instance.new("TextBox")
InputBox.Size = UDim2.new(0.72, 0, 0, 46)
InputBox.PlaceholderText = "Enter name / display name / partial (2+ chars)..."
InputBox.Text = ""
InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
InputBox.PlaceholderColor3 = Color3.fromRGB(180, 190, 210)
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 13
InputBox.TextXAlignment = Enum.TextXAlignment.Left
InputBox.ClearTextOnFocus = false
InputBox.ZIndex = 4
InputBox.Parent = CopierContent
addCorner(InputBox, 10)
applyGlass(InputBox, { color = Color3.fromRGB(35, 42, 58), transparency = 0.4, strokeTransparency = 0.65 })
Instance.new("UIPadding", InputBox).PaddingLeft = UDim.new(0, 12)

local DropdownToggle = Instance.new("TextButton")
DropdownToggle.Size = UDim2.new(0.26, 0, 0, 46)
DropdownToggle.Position = UDim2.new(0.74, 0, 0, 0)
DropdownToggle.Text = "▼ Players"
DropdownToggle.TextColor3 = Color3.fromRGB(255, 255, 255)
DropdownToggle.Font = Enum.Font.GothamBold
DropdownToggle.TextSize = 13
DropdownToggle.ZIndex = 4
DropdownToggle.Parent = CopierContent
addCorner(DropdownToggle, 10)
applyGlass(DropdownToggle, { color = Color3.fromRGB(60, 120, 200), transparency = 0.3, strokeTransparency = 0.55 })

local DropdownList = Instance.new("ScrollingFrame")
DropdownList.Size = UDim2.new(1, 0, 0, 200)
DropdownList.Position = UDim2.new(0, 0, 0, 50)
DropdownList.BorderSizePixel = 0
DropdownList.Visible = false
DropdownList.ZIndex = 15
DropdownList.ScrollBarThickness = 5
DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
DropdownList.Parent = CopierContent
addCorner(DropdownList, 10)
applyGlass(DropdownList, { color = Color3.fromRGB(25, 30, 45), transparency = 0.15, strokeTransparency = 0.5 })

-- Row 1: Reveal / Steal / Save
local RevealBtn = makeBtn(CopierContent, "🔍 REVEAL", UDim2.new(0, 0, 0, 244), UDim2.new(0.32, 0, 0, 44), Color3.fromRGB(55, 120, 220))
local StealBtn = makeBtn(CopierContent, "👕 STEAL", UDim2.new(0.34, 0, 0, 244), UDim2.new(0.32, 0, 0, 44), Color3.fromRGB(230, 140, 30))
local SaveBtn = makeBtn(CopierContent, "💾 SAVE", UDim2.new(0.68, 0, 0, 244), UDim2.new(0.32, 0, 0, 44), Color3.fromRGB(140, 70, 220))

-- Row 2: Copy Fit / Clone Player  (NEW)
local CopyFitBtn = makeBtn(CopierContent, "📋 COPY FIT (FAST)", UDim2.new(0, 0, 0, 294), UDim2.new(0.48, 0, 0, 42), Color3.fromRGB(40, 180, 120))
local CloneBtn = makeBtn(CopierContent, "👥 CLONE PLAYER", UDim2.new(0.52, 0, 0, 294), UDim2.new(0.48, 0, 0, 42), Color3.fromRGB(180, 60, 200))

local ProgressBG = Instance.new("Frame")
ProgressBG.Size = UDim2.new(1, 0, 0, 8)
ProgressBG.Position = UDim2.new(0, 0, 0, 344)
ProgressBG.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ProgressBG.BackgroundTransparency = 0.85
ProgressBG.BorderSizePixel = 0
ProgressBG.ZIndex = 4
ProgressBG.Parent = CopierContent
addCorner(ProgressBG, 4)
local ProgressFill = Instance.new("Frame")
ProgressFill.Size = UDim2.new(0, 0, 1, 0)
ProgressFill.BackgroundColor3 = Color3.fromRGB(120, 230, 160)
ProgressFill.BorderSizePixel = 0
ProgressFill.ZIndex = 5
ProgressFill.Parent = ProgressBG
addCorner(ProgressFill, 4)

local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, 0, 0, 210)
ScrollFrame.Position = UDim2.new(0, 0, 0, 360)
ScrollFrame.BorderSizePixel = 0
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ScrollFrame.ZIndex = 4
ScrollFrame.Parent = CopierContent
addCorner(ScrollFrame, 10)
applyGlass(ScrollFrame, { color = Color3.fromRGB(22, 27, 40), transparency = 0.25, strokeTransparency = 0.6 })

-- ============================================================
-- SAVED TAB
-- ============================================================
local CodeInput = Instance.new("TextBox")
CodeInput.Size = UDim2.new(1, 0, 0, 42)
CodeInput.PlaceholderText = "Paste outfit code or scan chat →"
CodeInput.Text = ""
CodeInput.TextColor3 = Color3.fromRGB(255, 255, 255)
CodeInput.PlaceholderColor3 = Color3.fromRGB(180, 190, 210)
CodeInput.Font = Enum.Font.Gotham
CodeInput.TextSize = 13
CodeInput.ZIndex = 4
CodeInput.Parent = SavedContent
addCorner(CodeInput, 10)
applyGlass(CodeInput, { color = Color3.fromRGB(35, 42, 58), transparency = 0.35, strokeTransparency = 0.6 })
Instance.new("UIPadding", CodeInput).PaddingLeft = UDim.new(0, 12)

local ApplyCodeBtn = makeBtn(SavedContent, "✅ APPLY CODE", UDim2.new(0, 0, 0, 48), UDim2.new(0.48, 0, 0, 40), Color3.fromRGB(40, 180, 120))
local ScanCodeBtn = makeBtn(SavedContent, "🔍 SCAN CHAT", UDim2.new(0.52, 0, 0, 48), UDim2.new(0.48, 0, 0, 40), Color3.fromRGB(150, 70, 220))

local SavedList = Instance.new("ScrollingFrame")
SavedList.Size = UDim2.new(1, 0, 1, -160)
SavedList.Position = UDim2.new(0, 0, 0, 96)
SavedList.BorderSizePixel = 0
SavedList.ScrollBarThickness = 5
SavedList.CanvasSize = UDim2.new(0, 0, 0, 0)
SavedList.ZIndex = 4
SavedList.Parent = SavedContent
addCorner(SavedList, 10)
applyGlass(SavedList, { color = Color3.fromRGB(22, 27, 40), transparency = 0.25, strokeTransparency = 0.6 })

local SavedFooter = Instance.new("TextLabel")
SavedFooter.Size = UDim2.new(1, 0, 0, 34)
SavedFooter.Position = UDim2.new(0, 0, 1, -36)
SavedFooter.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SavedFooter.BackgroundTransparency = 0.88
SavedFooter.Text = "No saved outfits yet"
SavedFooter.TextColor3 = Color3.fromRGB(210, 220, 240)
SavedFooter.Font = Enum.Font.Gotham
SavedFooter.TextSize = 12
SavedFooter.ZIndex = 4
SavedFooter.Parent = SavedContent
addCorner(SavedFooter, 10)

-- ============================================================
-- UTILITY TAB
-- ============================================================
local function createToggleRow(parent, text, posY, cb)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, 0, 0, 44)
    f.Position = UDim2.new(0, 0, 0, posY)
    f.ZIndex = 4
    f.Parent = parent
    addCorner(f, 10)
    applyGlass(f, { color = Color3.fromRGB(35, 42, 58), transparency = 0.4, strokeTransparency = 0.68 })

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -80, 1, 0)
    lbl.Position = UDim2.new(0, 14, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 14
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 5
    lbl.Parent = f

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 52, 0, 30)
    btn.Position = UDim2.new(1, -64, 0, 7)
    btn.Text = "OFF"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 11
    btn.ZIndex = 5
    btn.Parent = f
    addCorner(btn, 8)
    applyGlass(btn, { color = Color3.fromRGB(90, 95, 110), transparency = 0.4, strokeTransparency = 0.7 })

    local on = false
    btn.MouseButton1Click:Connect(function()
        on = not on
        btn.Text = on and "ON" or "OFF"
        btn.BackgroundColor3 = on and Color3.fromRGB(40, 180, 100) or Color3.fromRGB(90, 95, 110)
        cb(on, btn)
    end)
    return btn
end

-- ANTI FIT COPIER (TOP — most important)
local protectBtn = createToggleRow(UtilityContent, "🛡️ ANTI FIT COPIER (White Garden Forever)", 0, function(on, btn)
    if on then
        local ok, remote = setBio(CONFIG.PROTECTION_BIO)
        ProtectBadge.Visible = true
        if ok then
            btn.Text = "ON ✓"
            print("[Protection] Bio set via remote:", remote)
        else
            btn.Text = "ON*"
            print("[Protection] No bio remote found. Protection is visual-only.")
        end
        -- Also set local attribute so OTHER copies of this same script can detect
        pcall(function() LocalPlayer:SetAttribute("Protected", true) end)
        pcall(function() LocalPlayer:SetAttribute("AntiCopy", true) end)
        pcall(function() LocalPlayer:SetAttribute("Bio", CONFIG.PROTECTION_BIO) end)
    else
        setBio("")
        ProtectBadge.Visible = false
        btn.Text = "OFF"
        pcall(function() LocalPlayer:SetAttribute("Protected", false) end)
        pcall(function() LocalPlayer:SetAttribute("AntiCopy", false) end)
        pcall(function() LocalPlayer:SetAttribute("Bio", nil) end)
    end
end)

-- Fly
local flying, flyConn = false, nil
createToggleRow(UtilityContent, "✈️ Fly (WASD + Space/Ctrl)", 52, function(s)
    flying = s
    if s then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local bg = Instance.new("BodyGyro", hrp); bg.P = 9e4; bg.MaxTorque = Vector3.new(9e9, 9e9, 9e9); bg.CFrame = hrp.CFrame
        local bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(9e9, 9e9, 9e9); bv.Velocity = Vector3.new()
        flyConn = RunService.Heartbeat:Connect(function()
            if not flying or not hrp.Parent then bg:Destroy(); bv:Destroy(); if flyConn then flyConn:Disconnect() end; return end
            local d = Vector3.new()
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then d += workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then d -= workspace.CurrentCamera.CFrame.LookVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then d -= workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then d += workspace.CurrentCamera.CFrame.RightVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.new(0, 1, 0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.new(0, 1, 0) end
            bv.Velocity = d * CONFIG.FLY_SPEED
            bg.CFrame = workspace.CurrentCamera.CFrame
        end)
    else
        if flyConn then flyConn:Disconnect() end
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then for _, v in ipairs(hrp:GetChildren()) do if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end end end
    end
end)

-- Noclip
local noclipConn = nil
createToggleRow(UtilityContent, "🚪 Noclip", 104, function(s)
    if s then
        noclipConn = RunService.Stepped:Connect(function()
            local c = LocalPlayer.Character
            if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
        end)
    else
        if noclipConn then noclipConn:Disconnect() end
        local c = LocalPlayer.Character
        if c then for _, p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = true end end end
    end
end)

createToggleRow(UtilityContent, "⚡ Speed Boost (100)", 156, function(s)
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.WalkSpeed = s and 100 or CONFIG.DEFAULT_SPEED end
end)
createToggleRow(UtilityContent, "🦘 Jump Boost (150)", 208, function(s)
    local h = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
    if h then h.JumpPower = s and 150 or CONFIG.DEFAULT_JUMP end
end)

local TeleportBtn = makeBtn(UtilityContent, "📍 TELEPORT TO PLAYER", UDim2.new(0, 0, 0, 264), UDim2.new(1, 0, 0, 46), Color3.fromRGB(60, 190, 190))

-- ============================================================
-- SETTINGS TAB
-- ============================================================
local function makeLabel(parent, text, posY, color)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, 0, 0, 28)
    l.Position = UDim2.new(0, 0, 0, posY)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = color or Color3.fromRGB(225, 230, 245)
    l.Font = Enum.Font.Gotham
    l.TextSize = 13
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.ZIndex = 4
    l.Parent = parent
    return l
end

makeLabel(SettingsContent, "⚡ COPY SPEED", 0, Color3.fromRGB(255, 210, 130))
local SpeedBtns = {}
for i, lvl in ipairs(CONFIG.SPEED_LEVELS) do
    local b = makeBtn(SettingsContent, lvl.name, UDim2.new(0.33 * (i - 1), 0, 0, 32), UDim2.new(0.32, 0, 0, 38), i == CONFIG.DEFAULT_SPEED_LEVEL and Color3.fromRGB(40, 180, 100) or Color3.fromRGB(55, 65, 85))
    SpeedBtns[i] = b
    b.MouseButton1Click:Connect(function()
        CONFIG.DEFAULT_SPEED_LEVEL = i
        for j, bb in ipairs(SpeedBtns) do bb.BackgroundColor3 = (j == i) and Color3.fromRGB(40, 180, 100) or Color3.fromRGB(55, 65, 85) end
    end)
end

makeLabel(SettingsContent, "💾 Storage: " .. (saveFile or "In-memory only"), 85, Color3.fromRGB(160, 210, 170))
makeLabel(SettingsContent, "📁 Captured codes: " .. tostring(#codeOrder), 115, Color3.fromRGB(160, 180, 230))
makeLabel(SettingsContent, "🚫 Blocked: supermonkxscripts", 145, Color3.fromRGB(230, 130, 130))
makeLabel(SettingsContent, "🛡️ Protection bio: " .. CONFIG.PROTECTION_BIO, 175, Color3.fromRGB(200, 160, 255))
makeLabel(SettingsContent, "📌 Version: " .. CONFIG.VERSION, 205, Color3.fromRGB(190, 190, 240))
makeLabel(SettingsContent, "ℹ️ Clone tries remotes: set_name, set_bio, set_phone_color", 235, Color3.fromRGB(180, 200, 220))

-- ============================================================
-- TAB SWITCH
-- ============================================================
local contentsMap = { Copier = CopierContent, Saved = SavedContent, Utility = UtilityContent, Settings = SettingsContent }
local function setTab(name)
    for n, c in pairs(contentsMap) do c.Visible = (n == name) end
    for n, b in pairs(tabs) do
        b.BackgroundColor3 = (n == name) and Color3.fromRGB(55, 130, 220) or Color3.fromRGB(40, 48, 65)
    end
end
copierTab.MouseButton1Click:Connect(function() setTab("Copier") end)
savedTab.MouseButton1Click:Connect(function() setTab("Saved") end)
utilityTab.MouseButton1Click:Connect(function() setTab("Utility") end)
settingsTab.MouseButton1Click:Connect(function() setTab("Settings") end)

local minimized = false
MinimizeBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quart), { Size = minimized and UDim2.new(0, 520, 0, 52) or UDim2.new(0, 520, 0, 700) }):Play()
    MinimizeBtn.Text = minimized and "+" or "−"
end)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(blurEffect, TweenInfo.new(0.3), { Size = 0 }):Play()
    task.wait(0.35)
    blurEffect:Destroy()
    ScreenGui:Destroy()
end)

-- ============================================================
-- DROPDOWN
-- ============================================================
DropdownToggle.MouseButton1Click:Connect(function()
    if minimized then return end
    DropdownList.Visible = not DropdownList.Visible
    DropdownToggle.Text = DropdownList.Visible and "▲ Players" or "▼ Players"
    if not DropdownList.Visible then return end
    for _, c in ipairs(DropdownList:GetChildren()) do if c:IsA("TextButton") then c:Destroy() end end
    local idx = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        if not isBlocked(plr) then
            idx = idx + 1
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(1, -12, 0, 34)
            b.Position = UDim2.new(0, 6, 0, (idx - 1) * 36 + 4)
            b.BackgroundColor3 = Color3.fromRGB(45, 52, 70)
            b.BackgroundTransparency = 0.3
            b.Text = "  " .. plr.Name .. " (@" .. plr.DisplayName .. ")"
            b.TextColor3 = Color3.fromRGB(245, 250, 255)
            b.Font = Enum.Font.Gotham
            b.TextSize = 13
            b.TextXAlignment = Enum.TextXAlignment.Left
            b.ZIndex = 16
            b.Parent = DropdownList
            addCorner(b, 8)
            b.MouseButton1Click:Connect(function()
                InputBox.Text = plr.Name
                DropdownList.Visible = false
                DropdownToggle.Text = "▼ Players"
            end)
        end
    end
    DropdownList.CanvasSize = UDim2.new(0, 0, 0, idx * 36 + 8)
end)

-- ============================================================
-- ITEM CARD
-- ============================================================
local function clearList(listFrame)
    for _, c in ipairs(listFrame:GetChildren()) do if c:IsA("Frame") then c:Destroy() end end
end

local function createItemCard(category, assetId)
    local f = Instance.new("Frame")
    f.Size = UDim2.new(1, -8, 0, 40)
    f.ZIndex = 5
    f.Parent = ScrollFrame
    addCorner(f, 8)
    applyGlass(f, { color = Color3.fromRGB(40, 48, 65), transparency = 0.4, strokeTransparency = 0.7 })

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.66, 0, 1, 0)
    lbl.Position = UDim2.new(0, 12, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = "[" .. category .. "] Loading..."
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamMedium
    lbl.TextSize = 12
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.ZIndex = 6
    lbl.Parent = f

    task.spawn(function()
        local ok, info = pcall(function() return MarketplaceService:GetProductInfo(assetId) end)
        if ok and info then lbl.Text = "[" .. category .. "] " .. info.Name else lbl.Text = "[" .. category .. "] Unknown" end
    end)

    local copyBtn = Instance.new("TextButton")
    copyBtn.Size = UDim2.new(0, 72, 0, 26)
    copyBtn.Position = UDim2.new(1, -80, 0, 7)
    copyBtn.Text = "COPY"
    copyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    copyBtn.Font = Enum.Font.GothamBold
    copyBtn.TextSize = 11
    copyBtn.ZIndex = 6
    copyBtn.Parent = f
    addCorner(copyBtn, 6)
    applyGlass(copyBtn, { color = Color3.fromRGB(60, 130, 210), transparency = 0.3, strokeTransparency = 0.6 })
    copyBtn.MouseButton1Click:Connect(function()
        if setclipboard then
            setclipboard(tostring(assetId))
            copyBtn.Text = "✓"; copyBtn.BackgroundColor3 = Color3.fromRGB(60, 190, 100)
            task.wait(1.2)
            copyBtn.Text = "COPY"; copyBtn.BackgroundColor3 = Color3.fromRGB(60, 130, 210)
        end
    end)
end

-- ============================================================
-- APPLY HELPERS
-- ============================================================
local function applyDescription(desc, onProgress)
    local Net = getNetModule()
    if not Net then return false end
    local items = {}
    for _, acc in ipairs(desc:GetAccessories(true)) do
        local t = acc.AccessoryType.Name
        if not t:match("Accessory$") then t = t .. "Accessory" end
        table.insert(items, { id = acc.AssetId, type = t })
    end
    if desc.Pants ~= 0 then table.insert(items, { id = desc.Pants, type = "Pants" }) end
    if desc.Shirt ~= 0 then table.insert(items, { id = desc.Shirt, type = "Shirt" }) end
    if desc.GraphicTShirt ~= 0 then table.insert(items, { id = desc.GraphicTShirt, type = "TShirt" }) end
    if desc.Face ~= 0 then table.insert(items, { id = desc.Face, type = "Face" }) end
    for _, k in ipairs({ "IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation", "FallAnimation", "ClimbAnimation", "SwimAnimation", "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }) do
        local v = desc[k]
        if v and v ~= 0 then table.insert(items, { id = v, type = k }) end
    end
    pcall(function()
        Net.send("wear_outfit_from_desc", {
            accessories = {},
            properties = { Shirt = 0, Pants = 0, GraphicTShirt = 0, Face = 0, Head = 0, Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0, WalkAnimation = 0, RunAnimation = 0, JumpAnimation = 0, FallAnimation = 0, ClimbAnimation = 0, IdleAnimation = 0, SwimAnimation = 0, HeightScale = 1, HeadScale = 1, WidthScale = 1, DepthScale = 1, ProportionScale = 0, BodyTypeScale = 0 },
        })
    end)
    local delay = CONFIG.SPEED_LEVELS[CONFIG.DEFAULT_SPEED_LEVEL].delay
    local done, total = 0, #items
    for idx, item in ipairs(items) do
        task.delay((idx - 1) * delay, function()
            pcall(function() Net.get("code", tonumber(item.id), tostring(item.type)) end)
            done = done + 1
            if onProgress then onProgress(done / total) end
        end)
    end
    task.wait((total - 1) * delay + 0.5)
    pcall(function() Net.send("skin_tone", desc.HeadColor.R, desc.HeadColor.G, desc.HeadColor.B) end)
    return true
end

local function applySavedData(data, onProgress)
    local Net = getNetModule()
    if not Net then return false end
    local items = {}
    for _, acc in ipairs(data.accessories or {}) do table.insert(items, acc) end
    for _, k in ipairs({ "Shirt", "Pants", "GraphicTShirt", "Face", "IdleAnimation", "WalkAnimation", "RunAnimation", "JumpAnimation", "FallAnimation", "ClimbAnimation", "SwimAnimation", "Head", "Torso", "LeftArm", "RightArm", "LeftLeg", "RightLeg" }) do
        if data.properties[k] and data.properties[k] ~= 0 then table.insert(items, { id = data.properties[k], type = k }) end
    end
    pcall(function()
        Net.send("wear_outfit_from_desc", {
            accessories = {},
            properties = { Shirt = 0, Pants = 0, GraphicTShirt = 0, Face = 0, Head = 0, Torso = 0, LeftArm = 0, RightArm = 0, LeftLeg = 0, RightLeg = 0, WalkAnimation = 0, RunAnimation = 0, JumpAnimation = 0, FallAnimation = 0, ClimbAnimation = 0, IdleAnimation = 0, SwimAnimation = 0, HeightScale = 1, HeadScale = 1, WidthScale = 1, DepthScale = 1, ProportionScale = 0, BodyTypeScale = 0 },
        })
    end)
    local delay = CONFIG.SPEED_LEVELS[CONFIG.DEFAULT_SPEED_LEVEL].delay
    for idx, item in ipairs(items) do
        task.delay((idx - 1) * delay, function()
            pcall(function() Net.get("code", tonumber(item.id), tostring(item.type)) end)
            if onProgress then onProgress(idx / #items) end
        end)
    end
    task.wait(#items * delay + 0.5)
    if data.skinColor then pcall(function() Net.send("skin_tone", data.skinColor[1], data.skinColor[2], data.skinColor[3]) end) end
    return true
end

-- ============================================================
-- TARGET RESOLUTION + PROTECTION CHECK
-- ============================================================
local function resolveTarget()
    local p, reason = getPlayerByName(InputBox.Text)
    if reason == "blocked" then return nil, "blocked" end
    if not p or not p.Character then return nil, "not_found" end
    if isTargetProtected(p) then return nil, "protected" end
    return p, "ok"
end

-- ============================================================
-- REVEAL
-- ============================================================
RevealBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = false
    DropdownToggle.Text = "▼ Players"
    clearList(ScrollFrame)
    local p, reason = resolveTarget()
    if reason == "blocked" then RevealBtn.Text = "🚫 BLOCKED"; task.wait(2); RevealBtn.Text = "🔍 REVEAL"; return end
    if reason == "protected" then RevealBtn.Text = "🛡️ PROTECTED"; task.wait(2); RevealBtn.Text = "🔍 REVEAL"; return end
    if not p then RevealBtn.Text = "❌ NOT FOUND"; task.wait(1.5); RevealBtn.Text = "🔍 REVEAL"; return end
    RevealBtn.Text = "SCANNING..."
    task.spawn(function()
        local hum = p.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local desc = hum:GetAppliedDescription()
            if desc then
                for _, acc in ipairs(desc:GetAccessories(true)) do createItemCard(acc.AccessoryType.Name, acc.AssetId) end
                if desc.Shirt ~= 0 then createItemCard("Shirt", desc.Shirt) end
                if desc.Pants ~= 0 then createItemCard("Pants", desc.Pants) end
                if desc.GraphicTShirt ~= 0 then createItemCard("T-Shirt", desc.GraphicTShirt) end
                if desc.Face ~= 0 then createItemCard("Face", desc.Face) end
            end
        end
        RevealBtn.Text = "🔍 REVEAL"
    end)
end)

-- ============================================================
-- STEAL (with progress bar)
-- ============================================================
local stealing = false
StealBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = false
    DropdownToggle.Text = "▼ Players"
    if stealing then return end
    local p, reason = resolveTarget()
    if reason == "blocked" then StealBtn.Text = "🚫 BLOCKED"; StealBtn.BackgroundColor3 = Color3.fromRGB(220, 70, 70); task.wait(2); StealBtn.Text = "👕 STEAL"; StealBtn.BackgroundColor3 = Color3.fromRGB(230, 140, 30); return end
    if reason == "protected" then StealBtn.Text = "🛡️ PROTECTED"; StealBtn.BackgroundColor3 = Color3.fromRGB(120, 60, 200); task.wait(2); StealBtn.Text = "👕 STEAL"; StealBtn.BackgroundColor3 = Color3.fromRGB(230, 140, 30); return end
    if not p then StealBtn.Text = "❌ NOT FOUND"; task.wait(1.5); StealBtn.Text = "👕 STEAL"; return end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local desc = hum:GetAppliedDescription()
    if not desc then return end
    stealing = true
    ProgressFill.Size = UDim2.new(0, 0, 1, 0)
    StealBtn.Text = "STEALING..."
    task.spawn(function()
        local ok = applyDescription(desc, function(f) ProgressFill.Size = UDim2.new(f, 0, 1, 0) end)
        ProgressFill.Size = UDim2.new(ok and 1 or 0, 0, 1, 0)
        StealBtn.Text = ok and "✓ STOLEN" or "ERROR"
        StealBtn.BackgroundColor3 = ok and Color3.fromRGB(50, 190, 100) or Color3.fromRGB(220, 70, 70)
        task.wait(2)
        StealBtn.Text = "👕 STEAL"
        StealBtn.BackgroundColor3 = Color3.fromRGB(230, 140, 30)
        ProgressFill.Size = UDim2.new(0, 0, 1, 0)
        stealing = false
    end)
end)

-- ============================================================
-- 📋 COPY FIT (FAST) — instant, no progress animation
-- ============================================================
local copying = false
CopyFitBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = false
    DropdownToggle.Text = "▼ Players"
    if copying then return end
    local p, reason = resolveTarget()
    if reason == "blocked" then CopyFitBtn.Text = "🚫 BLOCKED"; task.wait(1.5); CopyFitBtn.Text = "📋 COPY FIT (FAST)"; return end
    if reason == "protected" then CopyFitBtn.Text = "🛡️ PROTECTED"; task.wait(1.5); CopyFitBtn.Text = "📋 COPY FIT (FAST)"; return end
    if not p then CopyFitBtn.Text = "❌ NOT FOUND"; task.wait(1.5); CopyFitBtn.Text = "📋 COPY FIT (FAST)"; return end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local desc = hum:GetAppliedDescription()
    if not desc then return end
    copying = true
    CopyFitBtn.Text = "COPYING..."
    task.spawn(function()
        local ok = applyDescription(desc, function(f) ProgressFill.Size = UDim2.new(f, 0, 1, 0) end)
        ProgressFill.Size = UDim2.new(ok and 1 or 0, 0, 1, 0)
        CopyFitBtn.Text = ok and "✓ COPIED" or "ERROR"
        CopyFitBtn.BackgroundColor3 = ok and Color3.fromRGB(50, 200, 120) or Color3.fromRGB(220, 70, 70)
        task.wait(1.5)
        CopyFitBtn.Text = "📋 COPY FIT (FAST)"
        CopyFitBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
        ProgressFill.Size = UDim2.new(0, 0, 1, 0)
        copying = false
    end)
end)

-- ============================================================
-- 👥 CLONE PLAYER — fit + name + bio + phone color
-- ============================================================
local cloning = false
CloneBtn.MouseButton1Click:Connect(function()
    DropdownList.Visible = false
    DropdownToggle.Text = "▼ Players"
    if cloning then return end
    local p, reason = resolveTarget()
    if reason == "blocked" then CloneBtn.Text = "🚫 BLOCKED"; task.wait(1.5); CloneBtn.Text = "👥 CLONE PLAYER"; return end
    if reason == "protected" then CloneBtn.Text = "🛡️ PROTECTED"; task.wait(1.5); CloneBtn.Text = "👥 CLONE PLAYER"; return end
    if not p then CloneBtn.Text = "❌ NOT FOUND"; task.wait(1.5); CloneBtn.Text = "👥 CLONE PLAYER"; return end

    cloning = true
    CloneBtn.Text = "CLONING..."
    CloneBtn.BackgroundColor3 = Color3.fromRGB(120, 40, 150)

    task.spawn(function()
        local results = { fit = false, name = false, bio = false, phone = false }

        -- 1. Fit (guaranteed)
        local hum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            local desc = hum:GetAppliedDescription()
            if desc then
                results.fit = applyDescription(desc, function(f) ProgressFill.Size = UDim2.new(f * 0.4, 0, 1, 0) end)
            end
        end
        ProgressFill.Size = UDim2.new(0.4, 0, 1, 0)

        -- 2. Name — try to set target's DisplayName
        results.name = setName(p.DisplayName)
        ProgressFill.Size = UDim2.new(0.6, 0, 1, 0)

        -- 3. Bio — read target's bio (if accessible), set on self
        local targetBio = getTargetBio(p)
        if targetBio and #targetBio > 0 then
            results.bio = setBio(targetBio)
        end
        ProgressFill.Size = UDim2.new(0.8, 0, 1, 0)

        -- 4. Phone color
        local phoneColor = getTargetPhoneColor(p)
        if phoneColor then
            results.phone = setPhoneColor(phoneColor)
        end
        ProgressFill.Size = UDim2.new(1, 0, 1, 0)

        -- Summary
        local parts = {}
        if results.fit then table.insert(parts, "Fit✓") else table.insert(parts, "Fit✗") end
        if results.name then table.insert(parts, "Name✓") else table.insert(parts, "Name✗") end
        if results.bio then table.insert(parts, "Bio✓") else table.insert(parts, "Bio✗") end
        if results.phone then table.insert(parts, "Phone✓") else table.insert(parts, "Phone✗") end

        CloneBtn.Text = table.concat(parts, " ")
        CloneBtn.BackgroundColor3 = results.fit and Color3.fromRGB(50, 190, 100) or Color3.fromRGB(220, 70, 70)
        print("[Clone] Results:", table.concat(parts, " | "))

        task.wait(3)
        CloneBtn.Text = "👥 CLONE PLAYER"
        CloneBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 200)
        ProgressFill.Size = UDim2.new(0, 0, 1, 0)
        cloning = false
    end)
end)

-- ============================================================
-- SAVE
-- ============================================================
SaveBtn.MouseButton1Click:Connect(function()
    local p, reason = resolveTarget()
    if reason == "blocked" then SaveBtn.Text = "🚫 BLOCKED"; task.wait(1.2); SaveBtn.Text = "💾 SAVE"; return end
    if reason == "protected" then SaveBtn.Text = "🛡️ PROTECTED"; task.wait(1.2); SaveBtn.Text = "💾 SAVE"; return end
    if not p then SaveBtn.Text = "❌ NOT FOUND"; task.wait(1.2); SaveBtn.Text = "💾 SAVE"; return end
    local hum = p.Character:FindFirstChildOfClass("Humanoid")
    if not hum then return end
    local desc = hum:GetAppliedDescription()
    if not desc then return end
    local name = p.Name .. "_" .. os.time()
    local data = serializeDescription(desc)
    data.sourceName = p.DisplayName
    data.savedAt = os.time()
    if saveOutfit(name, data) then
        SaveBtn.Text = "✓ SAVED"; SaveBtn.BackgroundColor3 = Color3.fromRGB(50, 190, 100)
        task.wait(1.2)
        SaveBtn.Text = "💾 SAVE"; SaveBtn.BackgroundColor3 = Color3.fromRGB(140, 70, 220)
        SavedFooter.Text = "Saved: " .. name
        renderSaved()
    end
end)

-- ============================================================
-- SAVED TAB RENDER
-- ============================================================
function renderSaved()
    clearList(SavedList)
    local list = {}
    for name, data in pairs(savedOutfits) do table.insert(list, { name = name, data = data }) end
    table.sort(list, function(a, b) return (a.data.savedAt or 0) > (b.data.savedAt or 0) end)
    for i, item in ipairs(list) do
        local f = Instance.new("Frame")
        f.Size = UDim2.new(1, -8, 0, 54)
        f.Position = UDim2.new(0, 4, 0, (i - 1) * 58 + 4)
        f.ZIndex = 5
        f.Parent = SavedList
        addCorner(f, 8)
        applyGlass(f, { color = Color3.fromRGB(40, 48, 65), transparency = 0.35, strokeTransparency = 0.65 })

        local nLbl = Instance.new("TextLabel")
        nLbl.Size = UDim2.new(0.55, 0, 0, 24)
        nLbl.Position = UDim2.new(0, 10, 0, 4)
        nLbl.BackgroundTransparency = 1
        nLbl.Text = item.name
        nLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
        nLbl.Font = Enum.Font.GothamBold
        nLbl.TextSize = 12
        nLbl.TextXAlignment = Enum.TextXAlignment.Left
        nLbl.TextTruncate = Enum.TextTruncate.AtEnd
        nLbl.ZIndex = 6
        nLbl.Parent = f

        local iLbl = Instance.new("TextLabel")
        iLbl.Size = UDim2.new(0.55, 0, 0, 18)
        iLbl.Position = UDim2.new(0, 10, 0, 28)
        iLbl.BackgroundTransparency = 1
        iLbl.Text = "From " .. (item.data.sourceName or "?") .. " • " .. #(item.data.accessories or {}) .. " items"
        iLbl.TextColor3 = Color3.fromRGB(180, 195, 220)
        iLbl.Font = Enum.Font.Gotham
        iLbl.TextSize = 10
        iLbl.TextXAlignment = Enum.TextXAlignment.Left
        iLbl.ZIndex = 6
        iLbl.Parent = f

        local applyB = Instance.new("TextButton")
        applyB.Size = UDim2.new(0, 66, 0, 28)
        applyB.Position = UDim2.new(1, -152, 0, 13)
        applyB.Text = "APPLY"
        applyB.TextColor3 = Color3.fromRGB(255, 255, 255)
        applyB.Font = Enum.Font.GothamBold
        applyB.TextSize = 11
        applyB.ZIndex = 6
        applyB.Parent = f
        addCorner(applyB, 6)
        applyGlass(applyB, { color = Color3.fromRGB(55, 130, 220), transparency = 0.3, strokeTransparency = 0.6 })
        applyB.MouseButton1Click:Connect(function()
            applyB.Text = "..."
            task.spawn(function()
                local ok = applySavedData(item.data, function(fr) ProgressFill.Size = UDim2.new(fr, 0, 1, 0) end)
                ProgressFill.Size = UDim2.new(ok and 1 or 0, 0, 1, 0)
                applyB.Text = ok and "✓" or "ERR"
                applyB.BackgroundColor3 = ok and Color3.fromRGB(50, 190, 100) or Color3.fromRGB(220, 70, 70)
                task.wait(1.5)
                applyB.Text = "APPLY"
                applyB.BackgroundColor3 = Color3.fromRGB(55, 130, 220)
                ProgressFill.Size = UDim2.new(0, 0, 1, 0)
            end)
        end)

        local delB = Instance.new("TextButton")
        delB.Size = UDim2.new(0, 60, 0, 28)
        delB.Position = UDim2.new(1, -82, 0, 13)
        delB.Text = "DEL"
        delB.TextColor3 = Color3.fromRGB(255, 255, 255)
        delB.Font = Enum.Font.GothamBold
        delB.TextSize = 11
        delB.ZIndex = 6
        delB.Parent = f
        addCorner(delB, 6)
        applyGlass(delB, { color = Color3.fromRGB(200, 70, 70), transparency = 0.3, strokeTransparency = 0.6 })
        delB.MouseButton1Click:Connect(function()
            deleteOutfit(item.name)
            renderSaved()
        end)
    end
    SavedList.CanvasSize = UDim2.new(0, 0, 0, #list * 58 + 8)
    SavedFooter.Text = #list == 0 and "No saved outfits — use 💾 SAVE in Copier tab" or (#list .. " outfit(s) saved")
end
renderSaved()

-- ============================================================
-- APPLY CODE / SCAN / TELEPORT
-- ============================================================
ApplyCodeBtn.MouseButton1Click:Connect(function()
    local code = CodeInput.Text:gsub("%s+", ""):upper()
    if #code < 5 then ApplyCodeBtn.Text = "❌ INVALID"; task.wait(1.2); ApplyCodeBtn.Text = "✅ APPLY CODE"; return end
    ApplyCodeBtn.Text = "APPLYING..."
    task.spawn(function()
        local Net = getNetModule()
        if not Net then ApplyCodeBtn.Text = "❌ NET ERROR"; task.wait(1.5); ApplyCodeBtn.Text = "✅ APPLY CODE"; return end
        local ok = pcall(function() Net.get("load_outfit", code) end)
        if not ok then pcall(function() Net.send("load_outfit", code) end) end
        task.wait(1.2)
        ApplyCodeBtn.Text = "✓ APPLIED"; ApplyCodeBtn.BackgroundColor3 = Color3.fromRGB(50, 190, 100)
        task.wait(2)
        ApplyCodeBtn.Text = "✅ APPLY CODE"; ApplyCodeBtn.BackgroundColor3 = Color3.fromRGB(40, 180, 120)
    end)
end)

ScanCodeBtn.MouseButton1Click:Connect(function()
    ScanCodeBtn.Text = "SCANNING..."
    task.spawn(function()
        task.wait(0.4)
        if #codeOrder == 0 then
            ScanCodeBtn.Text = "❌ NO CODES YET"; ScanCodeBtn.BackgroundColor3 = Color3.fromRGB(200, 70, 70)
            task.wait(2)
            ScanCodeBtn.Text = "🔍 SCAN CHAT"; ScanCodeBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
            return
        end
        CodeInput.Text = codeOrder[1]
        ScanCodeBtn.Text = "✓ " .. codeOrder[1]; ScanCodeBtn.BackgroundColor3 = Color3.fromRGB(50, 190, 100)
        task.wait(2)
        ScanCodeBtn.Text = "🔍 SCAN CHAT"; ScanCodeBtn.BackgroundColor3 = Color3.fromRGB(150, 70, 220)
    end)
end)

TeleportBtn.MouseButton1Click:Connect(function()
    local p, reason = resolveTarget()
    if reason == "blocked" or reason == "protected" then TeleportBtn.Text = "🚫 BLOCKED"; task.wait(1.2); TeleportBtn.Text = "📍 TELEPORT TO PLAYER"; return end
    if p and p.Character then
        local hrp = p.Character:FindFirstChild("HumanoidRootPart")
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and myHrp then myHrp.CFrame = hrp.CFrame + CONFIG.TELEPORT_OFFSET end
    end
end)

-- ============================================================
-- INIT
-- ============================================================
setTab("Copier")
print("[LT Glass Hub v" .. CONFIG.VERSION .. "] Loaded ✦")
print("[Protection] Bio to use: '" .. CONFIG.PROTECTION_BIO .. "'")