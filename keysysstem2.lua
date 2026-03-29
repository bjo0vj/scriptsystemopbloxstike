-- ==========================================
-- 1. ĐIỀN THÔNG TIN CỦA BẠN VÀO ĐÂY:
-- ==========================================
local PlatoID = 22995
local Link_Raw_Script_Loi = "https://raw.githubusercontent.com/bjo0vj/scriptsystemopbloxstike/main/script.lua" 

-- ==========================================
-- GIAO DIỆN VÀ LOGIC CHECK KEY BÊN TRONG (CHỐNG LỖI NIL)
-- ==========================================
local KeyGui = Instance.new("ScreenGui")
-- Bọc pcall để chống lỗi CoreGui trên các bản hack yếu
local success = pcall(function() KeyGui.Parent = game.CoreGui end)
if not success then KeyGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui") end

local MainFrame = Instance.new("Frame", KeyGui)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.5, -150, 0.5, -100)
MainFrame.Size = UDim2.new(0, 300, 0, 180)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Font = Enum.Font.SourceSansBold
Title.Text = "PhatHub - Key System"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.TextSize = 18

local KeyInput = Instance.new("TextBox", MainFrame)
KeyInput.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
KeyInput.Position = UDim2.new(0.1, 0, 0.35, 0)
KeyInput.Size = UDim2.new(0.8, 0, 0, 35)
KeyInput.PlaceholderText = "Dán Key Platoboost vào đây..."
KeyInput.Text = ""
KeyInput.TextColor3 = Color3.new(1, 1, 1)

local CheckBtn = Instance.new("TextButton", MainFrame)
CheckBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
CheckBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
CheckBtn.Size = UDim2.new(0.35, 0, 0, 35)
CheckBtn.Text = "Check Key"
CheckBtn.TextColor3 = Color3.new(1, 1, 1)
CheckBtn.Font = Enum.Font.SourceSansBold

local GetKeyBtn = Instance.new("TextButton", MainFrame)
GetKeyBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
GetKeyBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
GetKeyBtn.Size = UDim2.new(0.35, 0, 0, 35)
GetKeyBtn.Text = "Lấy Key"
GetKeyBtn.TextColor3 = Color3.new(1, 1, 1)
GetKeyBtn.Font = Enum.Font.SourceSansBold

local Status = Instance.new("TextLabel", MainFrame)
Status.BackgroundTransparency = 1
Status.Position = UDim2.new(0, 0, 0.88, 0)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Text = "Vui lòng lấy Key để tiếp tục!"
Status.TextColor3 = Color3.fromRGB(200, 200, 200)

-- ==========================================
-- LOGIC NÚT BẤM (VIẾT TRỰC TIẾP, ĐÁP LUÔN API PHỤ)
-- ==========================================
GetKeyBtn.MouseButton1Click:Connect(function()
    local link = "https://gateway.platoboost.com/a/" .. tostring(PlatoID)
    setclipboard(link)
    Status.Text = "Đã copy link! Ra Google Chrome dán nhé."
end)

CheckBtn.MouseButton1Click:Connect(function()
    local nhap = KeyInput.Text
    if nhap == "" then Status.Text = "Bạn chưa dán Key!" return end
    Status.Text = "Đang kiểm tra Key với Server..."
    
    local req = request or http_request or (syn and syn.request)
    if not req then
        Status.Text = "Lỗi: Phần mềm hack không hỗ trợ Check Key!"
        return
    end

    local HttpService = game:GetService("HttpService")
    local successAPI, res = pcall(function()
        return req({
            Url = "https://api.platoboost.com/v1/public/whitelist/verify",
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = HttpService:JSONEncode({
                service = PlatoID,
                key = nhap,
                identifier = tostring(game.Players.LocalPlayer.UserId)
            })
        })
    end)

    if successAPI and res and res.Body then
        local ok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
        if ok and data.success == true then
            Status.Text = "Key chuẩn! Đang mở script..."
            task.wait(1)
            KeyGui:Destroy()
            
            -- GỬI MẬT KHẨU "1234" ĐỂ MỞ KHÓA SCRIPT LÕI
            _G.ProtectionConfig_SecretKey = "1234" 
            
            -- GỌI SCRIPT LÕI TỪ GITHUB VỀ CHẠY
            loadstring(game:HttpGet(Link_Raw_Script_Loi))()
        else
            Status.Text = "Key sai hoặc hết hạn!"
        end
    else
        Status.Text = "Lỗi máy chủ Platoboost! Thử lại sau."
    end
end)
