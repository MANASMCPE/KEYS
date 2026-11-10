--[[══════════════════════════════════════════════════════════════════════════
      LIFE TOGETHER RP · AUTH0R PRO TROLLER (V17)
      ══════════════════════════════════════════════════════════════════════════
      ✅ Player List Fixed (ZIndex 100, Mobile+PC Support)
      ✅ Self Tab: Fire Trail, Rainbow, Fake Admin, Item Orbit, Confetti
      ✅ Target Tab: Real Trap, Void, Bring, Fling, Car Drop, Size Lagger
      ✅ 100% Server-Sided (FE)
══════════════════════════════════════════════════════════════════════════]]
if not game:IsLoaded() then game.Loaded:Wait() end
task.wait(0.1)

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local lp = Players.LocalPlayer

local selectedPlayer = nil
local net = nil
local allItems = {}
local isTrapping = false
local trapThread = nil
local lastPos = nil
local activeThreads = {}

-- ═══════════════ NET MODULE & ITEMS ═══════════════
task.spawn(function()
    pcall(function()
        local M = ReplicatedStorage:WaitForChild("Modules", 10)
        local C = M:WaitForChild("Core", 10)
        net = require(C:WaitForChild("Net", 10))
    end)
    local Pl = ReplicatedStorage:FindFirstChild("LargePlaceables")
    if Pl then
        for _, item in ipairs(Pl:GetChildren()) do
            if item:IsA("Model") then table.insert(allItems, item) end
        end
    end
end)

-- ═══════════════ HELPERS ═══════════════
local function getDesc(player)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    return hum and hum:GetAppliedDescription()
end

local function buildOutfit(desc, scale)
    if not desc then return nil end
    return {
        accessories = {},
        properties = {
            HeightScale = scale, WidthScale = scale, DepthScale = scale, HeadScale = math.min(scale, 50),
            Shirt = desc.Shirt, Pants = desc.Pants, Face = desc.Face,
        }
    }
end

local function TakeOwnership(hrp)
    if hrp then pcall(function() hrp:SetNetworkOwner(lp) end) end
end

-- ═══════════════ TARGET FEATURES ═══════════════
-- 1. REAL TRAPPER
local function ClearTrap(pos)
    if not net or not pos then return end
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") then
            local isItem = false
            for _, item in ipairs(allItems) do
                if obj.Name == item.Name then isItem = true break end
            end
            if isItem then
                local part = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
                if part and (part.Position - pos).Magnitude < 30 then
                    local cd = obj:FindFirstChildWhichIsA("ClickDetector", true)
                    if cd then pcall(function() net.send("interaction", cd, "Pick Up") end) end
                    pcall(function() obj:Destroy() end)
                end
            end
        end
    end
end

local function SpawnTrap(pos)
    if not net or #allItems == 0 then return end
    local ground = pos - Vector3.new(0, 2.8, 0)
    for i = 1, 4 do
        local item = allItems[math.random(1, #allItems)]
        pcall(function() net.get("large_place", item, CFrame.new(ground + Vector3.new(math.random(-1,1), 0, math.random(-1,1)))) end)
        task.wait(0.02)
    end
    for layer = 0, 1 do
        for i = 1, 16 do
            local angle = (i / 16) * math.pi * 2
            local r = 2.5
            local p = ground + Vector3.new(math.cos(angle)*r, layer*3, math.sin(angle)*r)
            local item = allItems[math.random(1, #allItems)]
            pcall(function() net.get("large_place", item, CFrame.lookAt(p, ground)) end)
            task.wait(0.02)
        end
    end
    for i = 1, 4 do
        local item = allItems[math.random(1, #allItems)]
        pcall(function() net.get("large_place", item, CFrame.new(ground + Vector3.new(math.random(-1,1), 6, math.random(-1,1)))) end)
        task.wait(0.02)
    end
end

local function StartTrap(target)
    if isTrapping or not target.Character then return end
    isTrapping = true
    trapThread = task.spawn(function()
        while isTrapping do
            local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local moved = lastPos and (hrp.Position - lastPos).Magnitude or 999
                if moved > 1 then
                    if lastPos then ClearTrap(hrp.Position) task.wait(0.1) end
                    SpawnTrap(hrp.Position)
                    lastPos = hrp.Position
                end
            end
            task.wait(0.1)
        end
    end)
end

local function StopTrap()
    isTrapping = false
    if trapThread then task.cancel(trapThread) trapThread = nil end
    if selectedPlayer and selectedPlayer.Character then
        local hrp = selectedPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then ClearTrap(hrp.Position) end
    end
end

-- 2. VOID
local function FE_Void(target)
    local char = target.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    TakeOwnership(hrp)
    task.wait(0.1)
    local pos = CFrame.new(hrp.Position.X, 50000, hrp.Position.Z)
    for i = 1, 5 do
        char:PivotTo(pos)
        hrp.AssemblyLinearVelocity = Vector3.new(0, -99999, 0)
        task.wait(0.05)
    end
    pcall(function() hum.Health = 0 end)
end

-- 3. FLING
local function FE_Fling(target)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    TakeOwnership(hrp)
    for i = 1, 10 do
        hrp.AssemblyLinearVelocity = Vector3.new(math.random(-100000, 100000), 100000, math.random(-100000, 100000))
        hrp.AssemblyAngularVelocity = Vector3.new(math.random(-100000, 100000), math.random(-100000, 100000), math.random(-100000, 100000))
        task.wait(0.05)
    end
end

-- 4. SIZE LAGGER
local function FE_SizeLagger(target)
    local desc = getDesc(target)
    if not desc then return end
    local big = buildOutfit(desc, 5000)
    local small = buildOutfit(desc, 0.01)
    local normal = buildOutfit(desc, 1)
    task.spawn(function()
        for i = 1, 10 do
            pcall(function() net.send("wear_outfit_from_desc", big) end)
            task.wait(0.1)
            pcall(function() net.send("wear_outfit_from_desc", small) end)
            task.wait(0.1)
        end
        pcall(function() net.send("wear_outfit_from_desc", normal) end)
    end)
end

-- 5. CAR DROP
local function FE_CarDrop(target)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local cars = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj:FindFirstChildWhichIsA("VehicleSeat") then
            local primary = obj.PrimaryPart or obj:FindFirstChildWhichIsA("BasePart", true)
            if primary then table.insert(cars, {model = obj, part = primary}) end
        end
    end
    if #cars == 0 then return end
    local car = cars[math.random(1, #cars)]
    pcall(function()
        car.part:SetNetworkOwner(lp)
        task.wait(0.05)
        car.model:PivotTo(CFrame.new(hrp.Position + Vector3.new(0, 30, 0)))
        car.part.AssemblyLinearVelocity = Vector3.new(0, -200, 0)
    end)
end

-- 6. FREEZE
local function FE_Freeze(target)
    local hrp = target.Character and target.Character:FindFirstChild("HumanoidRootPart")
    if hrp then TakeOwnership(hrp) hrp.Anchored = true end
end

-- ═══════════════ SELF FEATURES (NEW & IMPROVED) ═══════════════
-- 1. FIRE TRAIL
local function Self_FireTrail()
    if activeThreads.FireTrail then
        task.cancel(activeThreads.FireTrail)
        activeThreads.FireTrail = nil
        return
    end
    activeThreads.FireTrail = task.spawn(function()
        while activeThreads.FireTrail do
            task.wait(0.2)
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local firePart = Instance.new("Part")
                firePart.Size = Vector3.new(2, 1, 2)
                firePart.Transparency = 1
                firePart.Anchored = true
                firePart.CanCollide = false
                firePart.CFrame = hrp.CFrame
                firePart.Parent = workspace
                local fire = Instance.new("Fire")
                fire.Size = 10
                fire.Parent = firePart
                task.delay(3, function() firePart:Destroy() end)
            end
        end
    end)
end

-- 2. RAINBOW
local function Self_Rainbow()
    if activeThreads.Rainbow then
        task.cancel(activeThreads.Rainbow)
        activeThreads.Rainbow = nil
        return
    end
    activeThreads.Rainbow = task.spawn(function()
        while activeThreads.Rainbow do
            task.wait(0.1)
            local char = lp.Character
            if char then
                for _, v in pairs(char:GetDescendants()) do
                    if v:IsA("BasePart") then
                        pcall(function() v.Color = Color3.fromHSV(tick() % 1, 1, 1) end)
                    end
                end
            end
        end
    end)
end

-- 3. FAKE ADMIN TAG
local function Self_FakeAdmin()
    local char = lp.Character
    local head = char and char:FindFirstChild("Head")
    if not head then return end
    if head:FindFirstChild("AdminTag") then
        head.AdminTag:Destroy()
        return
    end
    local bb = Instance.new("BillboardGui")
    bb.Name = "AdminTag"
    bb.Size = UDim2.new(0, 150, 0, 40)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = head
    local txt = Instance.new("TextLabel", bb)
    txt.Size = UDim2.new(1, 0, 1, 0)
    txt.BackgroundTransparency = 1
    txt.Text = "👑 [ADMIN] 👑"
    txt.TextColor3 = Color3.fromRGB(255, 50, 50)
    txt.Font = Enum.Font.FredokaOne
    txt.TextSize = 20
    txt.TextStrokeTransparency = 0
end

-- 4. ITEM ORBIT
local function Self_ItemOrbit()
    if activeThreads.Orbit then
        task.cancel(activeThreads.Orbit)
        activeThreads.Orbit = nil
        return
    end
    activeThreads.Orbit = task.spawn(function()
        local angle = 0
        while activeThreads.Orbit do
            task.wait(0.05)
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp and net and #allItems > 0 then
                angle = angle + 0.1
                for i = 1, 3 do
                    local item = allItems[math.random(1, #allItems)]
                    local offset = Vector3.new(math.cos(angle + i * 2) * 5, 2, math.sin(angle + i * 2) * 5)
                    pcall(function() net.get("large_place", item, hrp.CFrame + offset) end)
                end
            end
        end
    end)
end

-- 5. CONFETTI AURA
local function Self_Confetti()
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    local e = Instance.new("ParticleEmitter")
    e.Texture = "rbxassetid://243660364"
    e.Color = ColorSequence.new(Color3.fromRGB(255, 100, 100))
    e.Size = NumberSequence.new(2)
    e.Lifetime = NumberRange.new(1, 2)
    e.Rate = 100
    e.Speed = NumberRange.new(10, 20)
    e.SpreadAngle = Vector2.new(360, 360)
    e.Parent = hrp
    task.delay(10, function() e:Destroy() end)
end

-- 6. INVISIBLE GHOST
local function Self_Invisible()
    local char = lp.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then pcall(function() v.Transparency = 1 end) end
        end
    end
end

local function Self_Visible()
    local char = lp.Character
    if char then
        for _, v in pairs(char:GetDescendants()) do
            if v:IsA("BasePart") then pcall(function() v.Transparency = 0 end) end
        end
    end
end

-- ═══════════════ GUI BUILD ═══════════════
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "ProTrollerV17"
ScreenGui.ResetOnSpawn = false

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 340, 0, 480)
Main.Position = UDim2.new(0.5, -170, 0.5, -240)
Main.BackgroundColor3 = Color3.fromRGB(10, 8, 12)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 12)
Instance.new("UIStroke", Main).Color = Color3.fromRGB(255, 0, 100)

local TitleBar = Instance.new("Frame", Main)
TitleBar.Size = UDim2.new(1, 0, 0, 45)
TitleBar.BackgroundColor3 = Color3.fromRGB(20, 10, 15)
TitleBar.BorderSizePixel = 0
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", TitleBar)
Title.Size = UDim2.new(1, -50, 1, 0)
Title.Position = UDim2.new(0, 15, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "☢ AUTH0R TROLLER V17"
Title.TextColor3 = Color3.fromRGB(255, 0, 100)
Title.Font = Enum.Font.FredokaOne
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left

local CloseBtn = Instance.new("TextButton", TitleBar)
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -17.5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 40, 60)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.FredokaOne
CloseBtn.TextSize = 16
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 8)
CloseBtn.MouseButton1Click:Connect(function()
    StopTrap()
    for _, thread in pairs(activeThreads) do task.cancel(thread) end
    ScreenGui:Destroy()
end)

-- Tabs
local TabBar = Instance.new("Frame", Main)
TabBar.Size = UDim2.new(1, -20, 0, 32)
TabBar.Position = UDim2.new(0, 10, 0, 55)
TabBar.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
TabBar.BorderSizePixel = 0
Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 6)

local TabTarget = Instance.new("TextButton", TabBar)
TabTarget.Size = UDim2.new(0.5, 0, 1, 0)
TabTarget.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
TabTarget.Text = "TARGET"
TabTarget.TextColor3 = Color3.fromRGB(255, 255, 255)
TabTarget.Font = Enum.Font.FredokaOne
TabTarget.TextSize = 14
Instance.new("UICorner", TabTarget).CornerRadius = UDim.new(0, 6)

local TabSelf = Instance.new("TextButton", TabBar)
TabSelf.Size = UDim2.new(0.5, 0, 1, 0)
TabSelf.Position = UDim2.new(0.5, 0, 0, 0)
TabSelf.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
TabSelf.Text = "SELF FE"
TabSelf.TextColor3 = Color3.fromRGB(150, 150, 150)
TabSelf.Font = Enum.Font.FredokaOne
TabSelf.TextSize = 14
Instance.new("UICorner", TabSelf).CornerRadius = UDim.new(0, 6)

-- ═══════════════ TARGET TAB ═══════════════
local TargetTab = Instance.new("Frame", Main)
TargetTab.Size = UDim2.new(1, -20, 1, -95)
TargetTab.Position = UDim2.new(0, 10, 0, 95)
TargetTab.BackgroundTransparency = 1

local Status = Instance.new("TextLabel", TargetTab)
Status.Size = UDim2.new(1, 0, 0, 32)
Status.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
Status.Text = "Target: None"
Status.TextColor3 = Color3.fromRGB(255, 100, 100)
Status.Font = Enum.Font.FredokaOne
Status.TextSize = 13
Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 6)

-- Player List Button
local ListBtn = Instance.new("TextButton", TargetTab)
ListBtn.Size = UDim2.new(1, 0, 0, 32)
ListBtn.Position = UDim2.new(0, 0, 0, 40)
ListBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
ListBtn.Text = "▼ SELECT TARGET"
ListBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ListBtn.Font = Enum.Font.FredokaOne
ListBtn.TextSize = 14
ListBtn.ZIndex = 5
Instance.new("UICorner", ListBtn).CornerRadius = UDim.new(0, 6)

-- Player List Frame (FIXED ZINDEX)
local ListFrame = Instance.new("ScrollingFrame", TargetTab)
ListFrame.Size = UDim2.new(1, 0, 0, 180)
ListFrame.Position = UDim2.new(0, 0, 0, 78)
ListFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 15)
ListFrame.BorderSizePixel = 0
ListFrame.Visible = false
ListFrame.ZIndex = 100
ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
Instance.new("UICorner", ListFrame).CornerRadius = UDim.new(0, 6)
local ListLayout = Instance.new("UIListLayout", ListFrame)
ListLayout.Padding = UDim.new(0, 3)

-- Feature Grid
local FeatureFrame = Instance.new("Frame", TargetTab)
FeatureFrame.Size = UDim2.new(1, 0, 0, 300)
FeatureFrame.Position = UDim2.new(0, 0, 0, 78)
FeatureFrame.BackgroundTransparency = 1

local grid = Instance.new("UIGridLayout", FeatureFrame)
grid.CellSize = UDim2.new(0.32, -3, 0, 36)
grid.CellPadding = UDim.new(0, 3, 0, 4)

local function TargetBtn(text, color, cb)
    local b = Instance.new("TextButton", FeatureFrame)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.FredokaOne
    b.TextSize = 10
    b.TextWrapped = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

local trapBtn = TargetBtn("REAL\nTRAP", Color3.fromRGB(255, 0, 100), function()
    if not selectedPlayer then return end
    if isTrapping then
        StopTrap()
        trapBtn.Text = "REAL\nTRAP"
        trapBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    else
        StartTrap(selectedPlayer)
        trapBtn.Text = "STOP\nTRAP"
        trapBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
    end
end)
TargetBtn("VOID", Color3.fromRGB(200, 50, 50), function() if selectedPlayer then FE_Void(selectedPlayer) end end)
TargetBtn("FLING", Color3.fromRGB(150, 50, 200), function() if selectedPlayer then FE_Fling(selectedPlayer) end end)
TargetBtn("FREEZE", Color3.fromRGB(50, 150, 255), function() if selectedPlayer then FE_Freeze(selectedPlayer) end end)
TargetBtn("SIZE\nLAG", Color3.fromRGB(255, 150, 0), function() if selectedPlayer then FE_SizeLagger(selectedPlayer) end end)
TargetBtn("CAR\nDROP", Color3.fromRGB(255, 100, 50), function() if selectedPlayer then FE_CarDrop(selectedPlayer) end end)

-- ═══════════════ SELF TAB ═══════════════
local SelfTab = Instance.new("Frame", Main)
SelfTab.Size = UDim2.new(1, -20, 1, -95)
SelfTab.Position = UDim2.new(0, 10, 0, 95)
SelfTab.BackgroundTransparency = 1
SelfTab.Visible = false

local SelfFrame = Instance.new("Frame", SelfTab)
SelfFrame.Size = UDim2.new(1, 0, 1, 0)
SelfFrame.BackgroundTransparency = 1

local sgrid = Instance.new("UIGridLayout", SelfFrame)
sgrid.CellSize = UDim2.new(0.32, -3, 0, 36)
sgrid.CellPadding = UDim2.new(0, 3, 0, 4)

local function SelfBtn(text, color, cb)
    local b = Instance.new("TextButton", SelfFrame)
    b.BackgroundColor3 = color
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.Font = Enum.Font.FredokaOne
    b.TextSize = 10
    b.TextWrapped = true
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    b.MouseButton1Click:Connect(cb)
    return b
end

SelfBtn("FIRE\nTRAIL", Color3.fromRGB(255, 50, 0), function() Self_FireTrail() end)
SelfBtn("RAINBOW", Color3.fromRGB(200, 100, 255), function() Self_Rainbow() end)
SelfBtn("FAKE\nADMIN", Color3.fromRGB(255, 0, 0), function() Self_FakeAdmin() end)
SelfBtn("ITEM\nORBIT", Color3.fromRGB(0, 200, 100), function() Self_ItemOrbit() end)
SelfBtn("CONFETTI", Color3.fromRGB(255, 100, 200), function() Self_Confetti() end)
SelfBtn("GHOST\n(INVIS)", Color3.fromRGB(100, 100, 100), function() Self_Invisible() end)
SelfBtn("VISIBLE", Color3.fromRGB(200, 200, 200), function() Self_Visible() end)

-- ═══════════════ LOGIC ═══════════════
local function ShowList()
    ListFrame.Visible = not ListFrame.Visible
    if ListFrame.Visible then
        ListBtn.Text = "▲ HIDE LIST"
        for _, c in ipairs(ListFrame:GetChildren()) do 
            if c:IsA("TextButton") then c:Destroy() end 
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= lp then
                local b = Instance.new("TextButton", ListFrame)
                b.Size = UDim2.new(1, -8, 0, 32)
                b.BackgroundColor3 = Color3.fromRGB(40, 20, 30)
                b.Text = p.Name
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
                b.Font = Enum.Font.FredokaOne
                b.TextSize = 13
                b.ZIndex = 101
                Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
                local selectHandler = function()
                    selectedPlayer = p
                    Status.Text = "Target: " .. p.Name
                    Status.TextColor3 = Color3.fromRGB(0, 255, 150)
                    ListFrame.Visible = false
                    ListBtn.Text = "▼ SELECT TARGET"
                end
                b.MouseButton1Click:Connect(selectHandler)
                b.Activated:Connect(selectHandler)
            end
        end
    else
        ListBtn.Text = "▼ SELECT TARGET"
    end
end

ListBtn.MouseButton1Click:Connect(ShowList)
ListBtn.Activated:Connect(ShowList)

TabTarget.MouseButton1Click:Connect(function()
    TargetTab.Visible = true
    SelfTab.Visible = false
    TabTarget.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    TabTarget.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabSelf.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
    TabSelf.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

TabSelf.MouseButton1Click:Connect(function()
    TargetTab.Visible = false
    SelfTab.Visible = true
    TabSelf.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    TabSelf.TextColor3 = Color3.fromRGB(255, 255, 255)
    TabTarget.BackgroundColor3 = Color3.fromRGB(20, 15, 20)
    TabTarget.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

pcall(function()
    local guiParent = gethui and gethui() or CoreGui
    ScreenGui.Parent = guiParent
end)
if not ScreenGui.Parent then ScreenGui.Parent = lp:WaitForChild("PlayerGui") end
print("[AUTH0R] Pro Troller V17 Loaded!")