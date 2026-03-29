local ProtectionConfig = { SecretKey = "1234", HubName = "PhatHub" }
if not _G.ProtectionConfig_SecretKey or _G.ProtectionConfig_SecretKey ~= ProtectionConfig.SecretKey then
    game.Players.LocalPlayer:Kick("\n\nLỗi: Vui lòng chạy Script thông qua Key System!")
    return
end
---------------------------------------------------------
-- ĐỂ NGUYÊN CODE ESP/AIMBOT CỦA BẠN Ở BÊN DƯỚI DÒNG NÀY
---------------------------------------------------------
-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- BONES SETUP
local BONES_R15={{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"LowerTorso","HumanoidRootPart"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"HumanoidRootPart","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},{"HumanoidRootPart","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}}
local BONES_R6={{"Head","Torso"},{"Torso","HumanoidRootPart"},{"Torso","Left Arm"},{"Torso","Right Arm"},{"HumanoidRootPart","Left Leg"},{"HumanoidRootPart","Right Leg"}}

-- HIGHLIGHT CONTAINER
local HighlightContainer = Instance.new("Folder")
HighlightContainer.Name = "PhatHub_Highlight_Container"
pcall(function() HighlightContainer.Parent = game:GetService("CoreGui") end)

-- SETTINGS
local FOV = 70 -- Mặc định 70
local AimSmoothness = 3 -- Mặc định 3
local AimPart = "Head" 
local AimMode = "Hold" -- "Hold" hoặc "Toggle"

local HoldingAim = false
local ScriptEnabled = true
local LockedTargetPart = nil -- Biến dùng để khóa chết mục tiêu

-- NEW TOGGLE SETTINGS
local ESPEnabled = true
local TeamCheckEnabled = true
local BoxEnabled = true
local SkeletonEnabled = true
local HealthBarEnabled = true
local HighlightEnabled = false
local TracerEnabled = false -- Thêm biến cho Tracer

local ESP = {}

-- TEAM CHECK FUNCTION
local function is_enemy(plr)
    if plr == LocalPlayer then return false end
    if plr.Team and LocalPlayer.Team then return plr.Team ~= LocalPlayer.Team end
    local mc = LocalPlayer.Character
    local tc = plr.Character
    if not mc or not tc or not mc.Parent or not tc.Parent then return false end
    return mc.Parent.Name ~= tc.Parent.Name
end

-- TARGET VALIDATION FUNCTION (KIỂM TRA MỤC TIÊU CÒN SỐNG/HỢP LỆ KHÔNG)
local function IsValidTarget(part)
    if not part or not part.Parent then return false end
    local hum = part.Parent:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return false end
    
    if TeamCheckEnabled then
        local plr = Players:GetPlayerFromCharacter(part.Parent)
        if plr and not is_enemy(plr) then return false end
    end
    return true
end

-- FOV CIRCLE
local FOVCircle = Drawing.new("Circle")
FOVCircle.Radius = FOV
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(255, 0, 0)
FOVCircle.Filled = false
FOVCircle.Visible = true

-- ==========================================
-- GUI SETUP (MAIN MENU)
-- ==========================================
local Gui = Instance.new("ScreenGui", game.CoreGui)

-- ==========================================
-- HELP / INSTRUCTION GUI
-- ==========================================
local HelpFrame = Instance.new("Frame", Gui)
HelpFrame.Size = UDim2.new(0, 450, 0, 260)
HelpFrame.Position = UDim2.new(0.5, -225, 0.5, -130)
HelpFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
HelpFrame.BorderSizePixel = 2
HelpFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
HelpFrame.Active = true
HelpFrame.Draggable = true

local HelpTitle = Instance.new("TextLabel", HelpFrame)
HelpTitle.Size = UDim2.new(1, -30, 0, 30)
HelpTitle.Text = " PhatHub Instructions / Hướng dẫn"
HelpTitle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
HelpTitle.TextColor3 = Color3.new(1, 1, 1)
HelpTitle.Font = Enum.Font.SourceSansBold
HelpTitle.TextSize = 16
HelpTitle.TextXAlignment = Enum.TextXAlignment.Left

local HelpClose = Instance.new("TextButton", HelpFrame)
HelpClose.Size = UDim2.new(0, 30, 0, 30)
HelpClose.Position = UDim2.new(1, -30, 0, 0)
HelpClose.Text = "X"
HelpClose.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
HelpClose.TextColor3 = Color3.new(1, 1, 1)
HelpClose.Font = Enum.Font.SourceSansBold
HelpClose.TextSize = 16

local HelpText = Instance.new("TextLabel", HelpFrame)
HelpText.Size = UDim2.new(1, -20, 1, -40)
HelpText.Position = UDim2.new(0, 10, 0, 35)
HelpText.BackgroundTransparency = 1
HelpText.TextColor3 = Color3.new(1, 1, 1)
HelpText.TextWrapped = true
HelpText.Font = Enum.Font.SourceSans
HelpText.TextSize = 14
HelpText.TextXAlignment = Enum.TextXAlignment.Left
HelpText.TextYAlignment = Enum.TextYAlignment.Top
HelpText.Text = "Welcome to PhatHub!\n- Aiming: Choose Hold or Toggle mode in the menu, then press 'E' to aim/lock target.\n- Aim Part: Press 'Alt' to quickly switch aiming between Head and Body.\n- ESP: Press 'F1' to reset ESP if it glitches.\n(This guide will auto-close in 60 seconds)\n\n--------------------------------------------------------------\n\nChào mừng đến với PhatHub!\n- Ngắm bắn (Aim): Chọn chế độ Hold/Toggle trong menu, nhấn phím 'E' để ngắm/khóa mục tiêu.\n- Vị trí ngắm: Nhấn phím 'Alt' để chuyển đổi nhanh giữa Đầu và Thân.\n- ESP: Nhấn phím 'F1' để làm mới ESP nếu bị lỗi.\n(Bảng hướng dẫn này sẽ tự đóng sau 60 giây)"

HelpClose.MouseButton1Click:Connect(function()
    HelpFrame:Destroy()
end)

task.delay(60, function()
    if HelpFrame and HelpFrame.Parent then
        HelpFrame:Destroy()
    end
end)
-- ==========================================

local Frame = Instance.new("Frame", Gui)
Frame.Size = UDim2.new(0, 200, 0, 520) 
Frame.Position = UDim2.new(0, 50, 0, 50)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.Active = true
Frame.Draggable = true
Frame.ClipsDescendants = true 

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, -60, 0, 30)
Title.Text = " PhatHub (Pro v7)"
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.SourceSansBold
Title.TextXAlignment = Enum.TextXAlignment.Left

-- CLOSE BUTTON (X)
local Close = Instance.new("TextButton", Frame)
Close.Size = UDim2.new(0, 30, 0, 30)
Close.Position = UDim2.new(1, -30, 0, 0)
Close.Text = "X"
Close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
Close.TextColor3 = Color3.new(1, 1, 1)
Close.Font = Enum.Font.SourceSansBold

-- MINIMIZE BUTTON (-)
local Minimize = Instance.new("TextButton", Frame)
Minimize.Size = UDim2.new(0, 30, 0, 30)
Minimize.Position = UDim2.new(1, -60, 0, 0)
Minimize.Text = "-"
Minimize.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
Minimize.TextColor3 = Color3.new(1, 1, 1)
Minimize.Font = Enum.Font.SourceSansBold

-- CONTENT FRAME
local ContentFrame = Instance.new("Frame", Frame)
ContentFrame.Size = UDim2.new(1, 0, 1, -30)
ContentFrame.Position = UDim2.new(0, 0, 0, 30)
ContentFrame.BackgroundTransparency = 1

local ESPBtn = Instance.new("TextButton", ContentFrame)
ESPBtn.Position = UDim2.new(0, 10, 0, 10)
ESPBtn.Size = UDim2.new(1, -20, 0, 30)
ESPBtn.Text = "ESP : ON (F1: Reset)"
ESPBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
ESPBtn.TextColor3 = Color3.new(1, 1, 1)

local AimStatus = Instance.new("TextLabel", ContentFrame)
AimStatus.Position = UDim2.new(0, 10, 0, 50)
AimStatus.Size = UDim2.new(1, -20, 0, 30)
AimStatus.BackgroundTransparency = 1
AimStatus.TextColor3 = Color3.new(1, 1, 1)
AimStatus.TextScaled = true
AimStatus.Text = "AIM : OFF"

local FOVInput = Instance.new("TextBox", ContentFrame)
FOVInput.Position = UDim2.new(0, 10, 0, 90)
FOVInput.Size = UDim2.new(1, -20, 0, 30)
FOVInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
FOVInput.TextColor3 = Color3.new(1, 1, 1)
FOVInput.Text = "FOV: " .. FOV
FOVInput.ClearTextOnFocus = true

local SmoothInput = Instance.new("TextBox", ContentFrame)
SmoothInput.Position = UDim2.new(0, 10, 0, 130)
SmoothInput.Size = UDim2.new(1, -20, 0, 30)
SmoothInput.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SmoothInput.TextColor3 = Color3.fromRGB(255, 255, 0)
SmoothInput.Text = "Smooth: " .. AimSmoothness
SmoothInput.ClearTextOnFocus = true

local AimPartBtn = Instance.new("TextButton", ContentFrame)
AimPartBtn.Position = UDim2.new(0, 10, 0, 170)
AimPartBtn.Size = UDim2.new(1, -20, 0, 30)
AimPartBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimPartBtn.TextColor3 = Color3.fromRGB(0, 255, 255)
AimPartBtn.Text = "Aim Part: HEAD"
AimPartBtn.Font = Enum.Font.SourceSansBold

local AimModeBtn = Instance.new("TextButton", ContentFrame)
AimModeBtn.Position = UDim2.new(0, 10, 0, 210)
AimModeBtn.Size = UDim2.new(1, -20, 0, 30)
AimModeBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AimModeBtn.TextColor3 = Color3.fromRGB(255, 170, 0)
AimModeBtn.Text = "Aim Mode: HOLD"
AimModeBtn.Font = Enum.Font.SourceSansBold

local TeamCheckBtn = Instance.new("TextButton", ContentFrame)
TeamCheckBtn.Position = UDim2.new(0, 10, 0, 250)
TeamCheckBtn.Size = UDim2.new(1, -20, 0, 30)
TeamCheckBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TeamCheckBtn.TextColor3 = Color3.new(1, 1, 1)
TeamCheckBtn.Text = "Team Check: ON"
TeamCheckBtn.Font = Enum.Font.SourceSansBold

local BoxBtn = Instance.new("TextButton", ContentFrame)
BoxBtn.Position = UDim2.new(0, 10, 0, 290)
BoxBtn.Size = UDim2.new(1, -20, 0, 30)
BoxBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
BoxBtn.TextColor3 = Color3.new(1, 1, 1)
BoxBtn.Text = "Box ESP: ON"
BoxBtn.Font = Enum.Font.SourceSansBold

local SkeletonBtn = Instance.new("TextButton", ContentFrame)
SkeletonBtn.Position = UDim2.new(0, 10, 0, 330)
SkeletonBtn.Size = UDim2.new(1, -20, 0, 30)
SkeletonBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SkeletonBtn.TextColor3 = Color3.new(1, 1, 1)
SkeletonBtn.Text = "Skeleton ESP: ON"
SkeletonBtn.Font = Enum.Font.SourceSansBold

local HealthBarBtn = Instance.new("TextButton", ContentFrame)
HealthBarBtn.Position = UDim2.new(0, 10, 0, 370)
HealthBarBtn.Size = UDim2.new(1, -20, 0, 30)
HealthBarBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
HealthBarBtn.TextColor3 = Color3.new(1, 1, 1)
HealthBarBtn.Text = "Health Bar: ON"
HealthBarBtn.Font = Enum.Font.SourceSansBold

local HighlightBtn = Instance.new("TextButton", ContentFrame)
HighlightBtn.Position = UDim2.new(0, 10, 0, 410)
HighlightBtn.Size = UDim2.new(1, -20, 0, 30)
HighlightBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
HighlightBtn.TextColor3 = Color3.new(1, 1, 1)
HighlightBtn.Text = "Highlight: OFF"
HighlightBtn.Font = Enum.Font.SourceSansBold

local TracerBtn = Instance.new("TextButton", ContentFrame)
TracerBtn.Position = UDim2.new(0, 10, 0, 450)
TracerBtn.Size = UDim2.new(1, -20, 0, 30)
TracerBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TracerBtn.TextColor3 = Color3.new(1, 1, 1)
TracerBtn.Text = "Tracer: OFF"
TracerBtn.Font = Enum.Font.SourceSansBold

-- ==========================================
-- TARGET HUD GUI
-- ==========================================
local TargetHud = Instance.new("Frame", Gui)
TargetHud.Size = UDim2.new(0, 150, 0, 75) 
TargetHud.Position = UDim2.new(0.5, 100, 0.5, -30)
TargetHud.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
TargetHud.BorderSizePixel = 2
TargetHud.BorderColor3 = Color3.fromRGB(255, 0, 0)
TargetHud.Active = true
TargetHud.Draggable = true
TargetHud.Visible = false

local TargetName = Instance.new("TextLabel", TargetHud)
TargetName.Size = UDim2.new(1, 0, 0.4, 0)
TargetName.BackgroundTransparency = 1
TargetName.TextColor3 = Color3.new(1, 1, 1)
TargetName.TextScaled = true
TargetName.Font = Enum.Font.SourceSansBold
TargetName.Text = "Name"

local TargetHealth = Instance.new("TextLabel", TargetHud)
TargetHealth.Size = UDim2.new(1, 0, 0.4, 0)
TargetHealth.Position = UDim2.new(0, 0, 0.4, 0)
TargetHealth.BackgroundTransparency = 1
TargetHealth.TextColor3 = Color3.fromRGB(0, 255, 0)
TargetHealth.TextScaled = true
TargetHealth.Font = Enum.Font.SourceSansBold
TargetHealth.Text = "HP: 100/100"

local TargetAimAssist = Instance.new("TextLabel", TargetHud)
TargetAimAssist.Size = UDim2.new(1, 0, 0.2, 0)
TargetAimAssist.Position = UDim2.new(0, 0, 0.8, 0)
TargetAimAssist.BackgroundTransparency = 1
TargetAimAssist.TextColor3 = Color3.fromRGB(200, 200, 200)
TargetAimAssist.TextScaled = false
TargetAimAssist.TextSize = 12
TargetAimAssist.Font = Enum.Font.SourceSansItalic
TargetAimAssist.Text = "Aim Assist: HEAD"

-- ==========================================
-- BUTTON EVENTS (LOGIC)
-- ==========================================

local isMinimized = false
Minimize.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
   
    if isMinimized then
        Minimize.Text = "+"
        ContentFrame.Visible = false
        Frame.Size = UDim2.new(0, 200, 0, 30)
    else
        Minimize.Text = "-"
        ContentFrame.Visible = true
        Frame.Size = UDim2.new(0, 200, 0, 520)
    end
end)

Close.MouseButton1Click:Connect(function()
    ScriptEnabled = false
    for _, data in pairs(ESP) do
        
        if data.Box then data.Box:Remove() end
        if data.HpBg then data.HpBg:Remove() end
        if data.Hp then data.Hp:Remove() end
        if data.Tracer then data.Tracer:Remove() end
        for _, line in pairs(data.Skeleton) do line:Remove() end
        if data.HL then data.HL:Destroy() end
    end
    FOVCircle:Remove()
    HighlightContainer:Destroy()
    Gui:Destroy()
end)

ESPBtn.MouseButton1Click:Connect(function()
    ESPEnabled = not ESPEnabled
    ESPBtn.Text = "ESP : " .. (ESPEnabled and "ON (F1: Reset)" or "OFF")
end)

FOVInput.FocusLost:Connect(function()
    local num = tonumber(FOVInput.Text)
    if num and num > 0 then
        FOV = num;
        FOVCircle.Radius = FOV; FOVInput.Text = "FOV: " .. FOV
    else
        FOVInput.Text = "FOV: " .. FOV
    end
end)

SmoothInput.FocusLost:Connect(function()
    local num = tonumber(SmoothInput.Text)
    if num and num > 0 then
        AimSmoothness = num; SmoothInput.Text = "Smooth: " .. AimSmoothness
    else
        SmoothInput.Text = "Smooth: " .. AimSmoothness
    end
end)

local function SwitchAimPart()
    if AimPart == "Head" then
       
        AimPart = "HumanoidRootPart"
        AimPartBtn.Text = "Aim Part: BODY"
        TargetAimAssist.Text = "Aim Assist: BODY"
    else
        AimPart = "Head"
        AimPartBtn.Text = "Aim Part: HEAD"
        TargetAimAssist.Text = "Aim Assist: HEAD"
    end
end

AimPartBtn.MouseButton1Click:Connect(SwitchAimPart)

AimModeBtn.MouseButton1Click:Connect(function()
    if AimMode == "Hold" then
        AimMode = "Toggle"; AimModeBtn.Text = "Aim Mode: TOGGLE"
    else
    
        AimMode = "Hold"; AimModeBtn.Text = "Aim Mode: HOLD"
        HoldingAim = false
        LockedTargetPart = nil -- Reset target lock
    end
end)

TeamCheckBtn.MouseButton1Click:Connect(function()
    TeamCheckEnabled = not TeamCheckEnabled
    TeamCheckBtn.Text = "Team Check: " .. (TeamCheckEnabled and "ON" or "OFF")
end)

BoxBtn.MouseButton1Click:Connect(function()
    BoxEnabled = not BoxEnabled
    BoxBtn.Text = "Box ESP: " .. (BoxEnabled and "ON" or "OFF")
end)

SkeletonBtn.MouseButton1Click:Connect(function()
    SkeletonEnabled = not SkeletonEnabled
    SkeletonBtn.Text = "Skeleton ESP: " .. (SkeletonEnabled and "ON" or "OFF")
end)

HealthBarBtn.MouseButton1Click:Connect(function()
    HealthBarEnabled = not HealthBarEnabled
    HealthBarBtn.Text = "Health Bar: " .. (HealthBarEnabled and "ON" or "OFF")
end)

HighlightBtn.MouseButton1Click:Connect(function()
    HighlightEnabled = not HighlightEnabled
    HighlightBtn.Text = "Highlight: " .. (HighlightEnabled and "ON" or "OFF")
    if HighlightEnabled then
        SkeletonEnabled = false
        SkeletonBtn.Text = "Skeleton ESP: OFF"
    end
end)

TracerBtn.MouseButton1Click:Connect(function()
    TracerEnabled = not TracerEnabled
    TracerBtn.Text = "Tracer: " .. (TracerEnabled and "ON" or "OFF")
end)

-- ==========================================
-- ESP CORE FUNCTIONS
-- ==========================================
local function CreateESP(player)
    if player == LocalPlayer then return end
    ESP[player] = {
        Box = Drawing.new("Square"),
        HpBg = Drawing.new("Line"),
        Hp = Drawing.new("Line"),
        Tracer = Drawing.new("Line"),
        Skeleton = {},
        HL = Instance.new("Highlight")
    }
    
    ESP[player].Box.Thickness = 2
   
    ESP[player].Box.Color = Color3.fromRGB(255, 0, 0)
    ESP[player].Box.Filled = false
    ESP[player].Box.Visible = false

    ESP[player].HpBg.Thickness = 3
    ESP[player].HpBg.Color = Color3.new(0, 0, 0)
    ESP[player].HpBg.Visible = false

    ESP[player].Hp.Thickness = 2
    ESP[player].Hp.Color = Color3.new(0, 1, 0)
    ESP[player].Hp.Visible = false
    
    ESP[player].Tracer.Thickness = 1.5
    ESP[player].Tracer.Color = Color3.new(1, 1, 1)
    ESP[player].Tracer.Visible = false

    for i = 1, 15 do
        local line = Drawing.new("Line")
        line.Thickness = 1.5
        line.Color = Color3.new(1, 1, 1)
        line.Visible = false
        ESP[player].Skeleton[i] = line
    end
    
    ESP[player].HL.FillColor = Color3.fromRGB(255, 0, 0)
    ESP[player].HL.OutlineColor = Color3.fromRGB(255, 255, 255)
    ESP[player].HL.FillTransparency = 0.5
    ESP[player].HL.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    ESP[player].HL.Enabled = false
    ESP[player].HL.Parent = HighlightContainer
end

local function RemoveESP(player)
    if ESP[player] then
 
        if ESP[player].Box then ESP[player].Box:Remove() end
        if ESP[player].HpBg then ESP[player].HpBg:Remove() end
        if ESP[player].Hp then ESP[player].Hp:Remove() end
        if ESP[player].Tracer then ESP[player].Tracer:Remove() end
        for _, line in pairs(ESP[player].Skeleton) do line:Remove() end
        if ESP[player].HL then ESP[player].HL:Destroy() end
        ESP[player] = nil
    end
end

local function ResetESP()
    for player, _ in pairs(ESP) do RemoveESP(player) end
    ESP = {} 
    for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)
Players.PlayerRemoving:Connect(RemoveESP)

local function GetClosest()
    local closest = nil
    local shortest = FOV 
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            if TeamCheckEnabled and not is_enemy(player) then continue end
     
            local char = player.Character
            if char and char.Parent and char:IsDescendantOf(workspace) then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local part = char:FindFirstChild(AimPart)
                if hum and part and hum.Health > 0 then
          
                    local pos, visible = Camera:WorldToViewportPoint(part.Position)
                    if visible then
                        local dist = (Vector2.new(pos.X, pos.Y) - center).Magnitude
                        if dist < shortest then
      
                            shortest = dist
                            closest = part
                        end
                    end
  
                end
            end
        end
    end
    return closest
end

-- ==========================================
-- INPUTS
-- ==========================================
UIS.InputBegan:Connect(function(input, gp)
    if gp and UIS:GetFocusedTextBox() then return end
    if input.KeyCode == Enum.KeyCode.E then
        if AimMode == "Hold" then
            HoldingAim = true
        elseif AimMode == "Toggle" then
            HoldingAim = not HoldingAim
            if not HoldingAim then LockedTargetPart = nil end
        end
    elseif input.KeyCode == Enum.KeyCode.F1 then
        ResetESP()
        AimStatus.Text = "ESP RESET OK!"
        AimStatus.TextColor3 = Color3.fromRGB(0, 255, 255)
    elseif input.KeyCode == Enum.KeyCode.LeftAlt or input.KeyCode == Enum.KeyCode.RightAlt then
   
        SwitchAimPart()
    end
end)

UIS.InputEnded:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.E then
        if AimMode == "Hold" then
            HoldingAim = false
            LockedTargetPart = nil -- Nhả ngắm thì xóa target lock
        end
    end
end)

-- ==========================================
-- MAIN RENDERING LOOP
-- ==========================================
RunService.RenderStepped:Connect(function()
    if not ScriptEnabled then return end

    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local screenBottom = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y) -- Điểm bắt đầu của Tracer
    FOVCircle.Position = center

    local currentLockedPlayer = nil

    -- AIM LOGIC & HUD & TARGET LOCK
    if HoldingAim then
        -- Khóa chết mục tiêu: Chỉ tìm mục tiêu mới nếu chưa có, hoặc mục tiêu cũ đã chết/thoát
        if not LockedTargetPart or not IsValidTarget(LockedTargetPart) then
            
            LockedTargetPart = GetClosest()
        end

        if LockedTargetPart then
            currentLockedPlayer = Players:GetPlayerFromCharacter(LockedTargetPart.Parent)
            local targetPos, onScreen = Camera:WorldToViewportPoint(LockedTargetPart.Position)
            
            if onScreen then
                local moveX = (targetPos.X - center.X) / AimSmoothness
 
                local moveY = (targetPos.Y - center.Y) / AimSmoothness
                if mousemoverel then mousemoverel(moveX, moveY) end
            end

            -- TARGET HUD
            if currentLockedPlayer and currentLockedPlayer.Character then
               
                local hum = currentLockedPlayer.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    TargetName.Text = currentLockedPlayer.DisplayName
                    local currentHP = math.floor(hum.Health)
                    local maxHP = math.floor(hum.MaxHealth)
          
                    TargetHealth.Text = "HP: " .. currentHP .. " / " .. maxHP
                    
                    local hpPercent = currentHP / maxHP
                    if hpPercent > 0.6 then
          
                        TargetHealth.TextColor3 = Color3.fromRGB(0, 255, 0)
                    elseif hpPercent > 0.3 then
                        TargetHealth.TextColor3 = Color3.fromRGB(255, 170, 0)
                    else
          
                        TargetHealth.TextColor3 = Color3.fromRGB(255, 0, 0)
                    end
                    
                    TargetHud.BorderColor3 = Color3.fromRGB(0, 255, 0)
                  
                    TargetHud.Visible = true
                end
            end

            AimStatus.Text = "AIM : LOCKED"
            AimStatus.TextColor3 = Color3.fromRGB(0, 255, 0)
            FOVCircle.Color = Color3.fromRGB(0, 255, 0)
        else
            
            AimStatus.Text = "AIM : NO TARGET"
            AimStatus.TextColor3 = Color3.fromRGB(255, 170, 0)
            FOVCircle.Color = Color3.fromRGB(255, 0, 0)
            TargetHud.Visible = false
        end
    else
        LockedTargetPart = nil -- Xóa Target Lock nếu không ấn ngắm
        if AimStatus.Text ~= "ESP RESET OK!" then
     
            AimStatus.Text = "AIM : OFF"
            AimStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        FOVCircle.Color = Color3.fromRGB(255, 0, 0)
        TargetHud.Visible = false
    end

    if AimStatus.Text == "ESP RESET OK!" and not HoldingAim then
        task.delay(0.8, function()
            if not HoldingAim and AimStatus.Text == "ESP RESET OK!" then
                AimStatus.Text = "AIM : OFF"
                AimStatus.TextColor3 = Color3.fromRGB(255, 0, 0)
            end
        end)
    end

    -- ESP RENDERING
    for player, espData in pairs(ESP) do
        if espData == nil then continue end 
  
        local char = player.Character
        local isEnemy = is_enemy(player)
        local shouldShowESP = ESPEnabled and (not TeamCheckEnabled or isEnemy)
        
        if shouldShowESP and char and char.Parent and char:IsDescendantOf(workspace) then
            local hum = char:FindFirstChildOfClass("Humanoid")
            local root = char:FindFirstChild("HumanoidRootPart")
          
            local head = char:FindFirstChild("Head")

            if hum and root and head and hum.Health > 0 then
                
                -- HIGHLIGHT
                if HighlightEnabled then
                    espData.HL.Adornee = char
                    espData.HL.Enabled = true
                    if player == currentLockedPlayer then
                        espData.HL.FillColor = Color3.fromRGB(0, 255, 0)
                    else
      
                        espData.HL.FillColor = Color3.fromRGB(255, 0, 0)
                    end
                else
                    espData.HL.Enabled = false
                end

    
                local rootPos, vis1 = Camera:WorldToViewportPoint(root.Position)
                local headPos, vis2 = Camera:WorldToViewportPoint(head.Position)

                if vis1 and vis2 then
                    local height = math.abs(headPos.Y - rootPos.Y) * 1.8
                 
                    local width = height / 2

                    -- Luôn luôn tính Size và Position
                    espData.Box.Size = Vector2.new(width, height)
                    espData.Box.Position = Vector2.new(rootPos.X - width / 2, headPos.Y - (height * 0.1))
            
                    
                    -- LOGIC BOX ON/OFF
                    if BoxEnabled then
                        espData.Box.Visible = true
                     
                        if player == currentLockedPlayer then
                            espData.Box.Color = Color3.fromRGB(0, 255, 0)
                        else
                            espData.Box.Color = Color3.fromRGB(255, 0, 0)
     
                        end
                    else
                        espData.Box.Visible = false
                    end
               
                    
                    -- TRACER
                    if TracerEnabled then
                        espData.Tracer.From = screenBottom
                        espData.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                        if player == currentLockedPlayer then
                            espData.Tracer.Color = Color3.fromRGB(0, 255, 0) -- Xanh lá nếu đang bị khóa mục tiêu
                        else
      
                            espData.Tracer.Color = Color3.fromRGB(255, 255, 255)
                        end
                        espData.Tracer.Visible = true
                    else
    
                        espData.Tracer.Visible = false
                    end

                    -- HEALTH BAR
                    if HealthBarEnabled then
              
                        local hpPercent = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        local barX = espData.Box.Position.X - 6
                        local barYTop = espData.Box.Position.Y
                        local barYBottom = espData.Box.Position.Y + height
                        local hpHeight = height * hpPercent

                        espData.HpBg.From = Vector2.new(barX, barYBottom)
                        espData.HpBg.To = Vector2.new(barX, barYTop)
               
                        espData.HpBg.Visible = true

                        espData.Hp.From = Vector2.new(barX, barYBottom)
                        espData.Hp.To = Vector2.new(barX, barYBottom - hpHeight)
                        espData.Hp.Color = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), hpPercent)
  
                        espData.Hp.Visible = true
                    else
                        espData.HpBg.Visible = false
                        espData.Hp.Visible = false
    
                    end

                    -- SKELETON
                    if SkeletonEnabled then
                        local isR15 = char:FindFirstChild("UpperTorso") ~= nil
            
                        local bones = isR15 and BONES_R15 or BONES_R6

                        for i = 1, 15 do
                            local line = espData.Skeleton[i]
                     
                            local pair = bones[i]

                            if pair then
                                local p1 = char:FindFirstChild(pair[1])
                         
                                local p2 = char:FindFirstChild(pair[2])
                                if p1 and p2 then
                                    local pos1, v1 = Camera:WorldToViewportPoint(p1.Position)
              
                                    local pos2, v2 = Camera:WorldToViewportPoint(p2.Position)

                                    if v1 and v2 then
                                  
                                        line.From = Vector2.new(pos1.X, pos1.Y)
                                        line.To = Vector2.new(pos2.X, pos2.Y)
                                        line.Visible = true
      
                                    else
                                        line.Visible = false
                            
                                    end
                                else
                                    line.Visible = false
                      
                                end
                            else
                                line.Visible = false
                            
                            end
                        end
                    else
                        for _, line in pairs(espData.Skeleton) do line.Visible = false end
                    end

   
                else
                    espData.Box.Visible = false
                    espData.HpBg.Visible = false
                    espData.Hp.Visible = false
                    espData.Tracer.Visible = false
                    for _, line in pairs(espData.Skeleton) do line.Visible = false end
                end
            else
                espData.Box.Visible = false
                espData.HpBg.Visible = false
      
                espData.Hp.Visible = false
                espData.HL.Enabled = false
                espData.Tracer.Visible = false
                for _, line in pairs(espData.Skeleton) do line.Visible = false end
            end
        else
       
            espData.Box.Visible = false
            espData.HpBg.Visible = false
            espData.Hp.Visible = false
            espData.HL.Enabled = false
            espData.Tracer.Visible = false
            for _, line in pairs(espData.Skeleton) do line.Visible = false end
        end
    end
end)
