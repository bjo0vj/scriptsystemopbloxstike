-- ==========================================
-- 1. ĐIỀN 3 THÔNG TIN CỦA BẠN VÀO ĐÂY:
-- ==========================================
local PlatoID = "22995" 
local PlatoToken = "a6b10490-b2b0-4790-9168-5bced1293248" 
local Link_Raw_Script_Loi = "https://raw.githubusercontent.com/bjo0vj/scriptsystemopbloxstike/refs/heads/main/script.lua" 

-- ==========================================
-- PHẦN CODE BÊN DƯỚI GIỮ NGUYÊN KHÔNG SỬA
-- ==========================================
local Plato = loadstring(game:HttpGet("https://api.platoboost.com/public/library/v1.lua"))()

local KeyGui = Instance.new("ScreenGui", game.CoreGui)
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

GetKeyBtn.MouseButton1Click:Connect(function()
    Status.Text = "Đang tạo link, chờ chút..."
    local success, link = Plato.GetLink({
        Identifier = PlatoID,
        Configuration = PlatoToken
    })
    if success then
        setclipboard(link)
        Status.Text = "Đã copy link! Ra Google Chrome dán nhé."
    else
        Status.Text = "Lỗi tạo link! Hãy thử lại."
    end
end)

CheckBtn.MouseButton1Click:Connect(function()
    local nhap = KeyInput.Text
    if nhap == "" then Status.Text = "Bạn chưa dán Key!" return end
    
    Status.Text = "Đang kiểm tra Key..."
    Plato.Verify({
        Identifier = PlatoID,
        Configuration = PlatoToken,
        Key = nhap,
        Success = function()
            Status.Text = "Key đúng! Đang mở script..."
            task.wait(1)
            KeyGui:Destroy()
            
            -- GỬI MẬT KHẨU "1234" ĐỂ MỞ KHÓA SCRIPT LÕI
            _G.ProtectionConfig_SecretKey = "1234" 
            
            -- GỌI SCRIPT LÕI TỪ GITHUB VỀ CHẠY
            loadstring(game:HttpGet(Link_Raw_Script_Loi))()
        end,
        Failure = function()
            Status.Text = "Key sai hoặc hết hạn!"
        end

    })
end)
