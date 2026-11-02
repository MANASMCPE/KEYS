--[[
    MONK PREMIUM KEY SYSTEM
    Theme: Dark Maroon / Red Glass
    Platform: Roblox LocalScript
    Creator: MonK

    IMPORTANT:
    This is a UI + FORMAT-DEMO template.
    It only checks whether the entered text starts with "MONK-".
    That is NOT secure key authentication. Anyone can type MONK-anything.
    For real access control, validate keys on a trusted server/backend.
    This template intentionally does not download or execute remote code.
]]

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local KEY_URL = "https://keysystemnymomk.vercel.app/"

local C = {
    bg = Color3.fromRGB(17, 8, 13),
    panel = Color3.fromRGB(29, 10, 18),
    panel2 = Color3.fromRGB(45, 13, 26),
    maroon = Color3.fromRGB(105, 15, 42),
    red = Color3.fromRGB(190, 28, 61),
    bright = Color3.fromRGB(235, 48, 82),
    white = Color3.fromRGB(248, 239, 243),
    muted = Color3.fromRGB(165, 139, 149),
    green = Color3.fromRGB(91, 218, 145),
}

local function notify(message)
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = "MONK  |  KEY SYSTEM",
            Text = message,
            Duration = 3
        })
    end)
end

local old = playerGui:FindFirstChild("MonKPremiumKeySystem")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "MonKPremiumKeySystem"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(360, 270)
main.Position = UDim2.new(0.5, -180, 0.5, -135)
main.BackgroundColor3 = C.bg
main.BackgroundTransparency = 0.08
main.BorderSizePixel = 0
main.Parent = gui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = main

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = C.red
mainStroke.Thickness = 1.4
mainStroke.Transparency = 0.18
mainStroke.Parent = main

local mainGradient = Instance.new("UIGradient")
mainGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(54, 13, 29)),
    ColorSequenceKeypoint.new(0.55, C.panel),
    ColorSequenceKeypoint.new(1, C.bg)
})
mainGradient.Rotation = 35
mainGradient.Parent = main

local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, -34, 0, 2)
topAccent.Position = UDim2.fromOffset(17, 0)
topAccent.BackgroundColor3 = C.bright
topAccent.BorderSizePixel = 0
topAccent.Parent = main
Instance.new("UICorner", topAccent).CornerRadius = UDim.new(1, 0)

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(20, 15)
title.Size = UDim2.new(1, -75, 0, 31)
title.Font = Enum.Font.GothamBold
title.Text = "KEY"
title.TextColor3 = C.white
title.TextSize = 23
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = main

local subtitle = Instance.new("TextLabel")
subtitle.BackgroundTransparency = 1
subtitle.Position = UDim2.fromOffset(21, 46)
subtitle.Size = UDim2.new(1, -42, 0, 18)
subtitle.Font = Enum.Font.GothamMedium
subtitle.Text = "ENTER YOUR MONK ACCESS KEY"
subtitle.TextColor3 = C.muted
subtitle.TextSize = 10
subtitle.TextXAlignment = Enum.TextXAlignment.Left
subtitle.Parent = main

local close = Instance.new("TextButton")
close.Size = UDim2.fromOffset(29, 29)
close.Position = UDim2.new(1, -45, 0, 16)
close.BackgroundColor3 = C.panel2
close.BackgroundTransparency = 0.1
close.Text = "×"
close.TextColor3 = C.white
close.TextSize = 21
close.Font = Enum.Font.GothamMedium
close.AutoButtonColor = false
close.Parent = main
Instance.new("UICorner", close).CornerRadius = UDim.new(0, 8)

local closeStroke = Instance.new("UIStroke")
closeStroke.Color = C.red
closeStroke.Transparency = 0.55
closeStroke.Parent = close

local divider = Instance.new("Frame")
divider.Position = UDim2.fromOffset(20, 76)
divider.Size = UDim2.new(1, -40, 0, 1)
divider.BackgroundColor3 = C.red
divider.BackgroundTransparency = 0.55
divider.BorderSizePixel = 0
divider.Parent = main

local inputLabel = Instance.new("TextLabel")
inputLabel.BackgroundTransparency = 1
inputLabel.Position = UDim2.fromOffset(21, 91)
inputLabel.Size = UDim2.new(1, -42, 0, 17)
inputLabel.Font = Enum.Font.GothamSemibold
inputLabel.Text = "LICENSE KEY"
inputLabel.TextColor3 = C.white
inputLabel.TextSize = 10
inputLabel.TextXAlignment = Enum.TextXAlignment.Left
inputLabel.Parent = main

local input = Instance.new("TextBox")
input.Name = "KeyInput"
input.Position = UDim2.fromOffset(20, 114)
input.Size = UDim2.new(1, -40, 0, 43)
input.BackgroundColor3 = Color3.fromRGB(35, 13, 23)
input.BackgroundTransparency = 0.05
input.BorderSizePixel = 0
input.ClearTextOnFocus = false
input.Font = Enum.Font.GothamMedium
input.PlaceholderText = "MONK-XXXXXX"
input.PlaceholderColor3 = C.muted
input.Text = ""
input.TextColor3 = C.white
input.TextSize = 13
input.TextXAlignment = Enum.TextXAlignment.Left
input.Parent = main
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 9)

local inputPadding = Instance.new("UIPadding")
inputPadding.PaddingLeft = UDim.new(0, 13)
inputPadding.PaddingRight = UDim.new(0, 10)
inputPadding.Parent = input

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = C.maroon
inputStroke.Thickness = 1
inputStroke.Transparency = 0.15
inputStroke.Parent = input

local function makeButton(text, position, size, primary)
    local button = Instance.new("TextButton")
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = primary and C.maroon or C.panel2
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Font = Enum.Font.GothamBold
    button.Text = text
    button.TextColor3 = C.white
    button.TextSize = 11
    button.Parent = main
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 9)

    local stroke = Instance.new("UIStroke")
    stroke.Color = primary and C.bright or C.red
    stroke.Transparency = primary and 0.2 or 0.48
    stroke.Thickness = 1
    stroke.Parent = button

    button.MouseEnter:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.16), {
            BackgroundColor3 = primary and C.red or C.maroon
        }):Play()
    end)
    button.MouseLeave:Connect(function()
        TweenService:Create(button, TweenInfo.new(0.16), {
            BackgroundColor3 = primary and C.maroon or C.panel2
        }):Play()
    end)
    return button
end

local verify = makeButton(
    "VERIFY KEY",
    UDim2.fromOffset(20, 171),
    UDim2.new(0.61, -20, 0, 40),
    true
)

local getKey = makeButton(
    "GET KEY  ↗",
    UDim2.new(0.61, 10, 0, 171),
    UDim2.new(0.39, -30, 0, 40),
    false
)

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(21, 220)
status.Size = UDim2.new(1, -42, 0, 18)
status.Font = Enum.Font.GothamMedium
status.Text = "●  WAITING FOR VERIFICATION"
status.TextColor3 = C.muted
status.TextSize = 10
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = main

local footer = Instance.new("TextLabel")
footer.BackgroundTransparency = 1
footer.Position = UDim2.fromOffset(20, 245)
footer.Size = UDim2.new(1, -40, 0, 13)
footer.Font = Enum.Font.Gotham
footer.Text = "MONK SYSTEM  •  PREMIUM ACCESS"
footer.TextColor3 = C.muted
footer.TextTransparency = 0.25
footer.TextSize = 8
footer.Parent = main

local function setStatus(message, color)
    status.Text = "●  " .. message
    status.TextColor3 = color or C.muted
end

getKey.MouseButton1Click:Connect(function()
    local copied = false

    -- Clipboard functions are not part of standard Roblox LocalScripts.
    -- If the environment provides setclipboard, use it; otherwise show the URL.
    pcall(function()
        if typeof(setclipboard) == "function" then
            setclipboard(KEY_URL)
            copied = true
        end
    end)

    if copied then
        setStatus("KEY LINK COPIED", C.green)
        notify("KEY LINK COPIED")
    else
        setStatus("OPEN / COPY THE KEY LINK BELOW", C.muted)
        notify("KEY LINK IS SHOWN IN THE STATUS AREA")
        print("MONK KEY LINK: " .. KEY_URL)
    end
end)

verify.MouseButton1Click:Connect(function()
    local entered = input.Text

    if entered:sub(1, 5):upper() == "MONK-" and #entered > 5 then
        setStatus("PREFIX FORMAT ACCEPTED - DEMO ONLY", C.green)
        notify("FORMAT ACCEPTED - DEMO ONLY")
    else
        setStatus("INVALID KEY FORMAT", C.bright)
        notify("INVALID KEY - GET A KEY FIRST")
    end
end)

close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

-- Drag support for mouse and touch; drag starts only from the title region.
local dragging = false
local dragInput
local dragStart
local startPosition

local function updateDrag(inputObject)
    local delta = inputObject.Position - dragStart
    main.Position = UDim2.new(
        startPosition.X.Scale,
        startPosition.X.Offset + delta.X,
        startPosition.Y.Scale,
        startPosition.Y.Offset + delta.Y
    )
end

title.InputBegan:Connect(function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseButton1
        or inputObject.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = inputObject.Position
        startPosition = main.Position

        inputObject.Changed:Connect(function()
            if inputObject.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(inputObject)
    if inputObject.UserInputType == Enum.UserInputType.MouseMovement
        or inputObject.UserInputType == Enum.UserInputType.Touch then
        dragInput = inputObject
    end
end)

UserInputService.InputChanged:Connect(function(inputObject)
    if dragging and inputObject == dragInput then
        updateDrag(inputObject)
    end
end)

notify("MONK PREMIUM KEY SYSTEM LOADED")
