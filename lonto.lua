-- 🌸 Danh Đẹp Trai Hub | Public Stable Edition
-- Visual / Client-side / Stable

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LP = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- STATE
local S = {ESP=false, AIM=false, FLY=false, GHOST=false, SPEED=false}

-- UTILS
local function Char() return LP.Character end
local function HRP() return Char() and Char():FindFirstChild("HumanoidRootPart") end
local function Hum() return Char() and Char():FindFirstChild("Humanoid") end

local function Nearest(range)
    if not HRP() then return nil end
    local n,d
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local dist=(p.Character.HumanoidRootPart.Position-HRP().Position).Magnitude
            if dist<=(range or 400) and (not d or dist<d) then d=dist n=p.Character end
        end
    end
    return n
end

-- CLEANUP ON RESPAWN
local function CleanupBody(char)
    for _,v in ipairs(char:GetDescendants()) do
        if v:IsA("BodyVelocity") or v:IsA("BodyGyro") then v:Destroy() end
    end
end

LP.CharacterAdded:Connect(function(c)
    task.wait(0.8)
    S.FLY=false S.AIM=false
    CleanupBody(c)
    if Hum() then Hum().WalkSpeed=16 end
end)

-- UI THEME
local Theme={
    Main=Color3.fromRGB(255,130,180),
    Dark=Color3.fromRGB(255,100,160),
    Btn=Color3.fromRGB(255,180,210),
    Glow=Color3.fromRGB(255,60,140),
    Text=Color3.fromRGB(255,20,147)
}

-- GUI
local GUI=Instance.new("ScreenGui",game.CoreGui)
GUI.Name="DanhDepTraiHub"
GUI.ResetOnSpawn=false

local Main=Instance.new("Frame",GUI)
Main.Size=UDim2.fromOffset(640,380)
Main.Position=UDim2.fromScale(0.5,0.5)
Main.AnchorPoint=Vector2.new(0.5,0.5)
Main.BackgroundColor3=Theme.Main
Main.Active,Main.Draggable=true,true
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,24)
local Stroke=Instance.new("UIStroke",Main)
Stroke.Color=Theme.Glow Stroke.Thickness=3

local Title=Instance.new("TextLabel",Main)
Title.Size=UDim2.new(1,0,0,56)
Title.BackgroundTransparency=1
Title.Text="🌸 Danh Đẹp Trai Hub"
Title.Font=Enum.Font.GothamBold
Title.TextSize=26
Title.TextColor3=Theme.Text

local Tabs=Instance.new("Frame",Main)
Tabs.Position=UDim2.new(0,14,0,64)
Tabs.Size=UDim2.fromOffset(180,300)
Tabs.BackgroundColor3=Theme.Dark
Instance.new("UICorner",Tabs).CornerRadius=UDim.new(0,18)

local Pages=Instance.new("Frame",Main)
Pages.Position=UDim2.new(0,208,0,64)
Pages.Size=UDim2.fromOffset(418,300)
Pages.BackgroundColor3=Theme.Dark
Instance.new("UICorner",Pages).CornerRadius=UDim.new(0,18)

local Current
local function NewPage()
    local p=Instance.new("Frame",Pages)
    p.Size=UDim2.fromScale(1,1)
    p.BackgroundTransparency=1
    p.Visible=false
    local l=Instance.new("UIListLayout",p)
    l.Padding=UDim.new(0,10)
    l.HorizontalAlignment=Enum.HorizontalAlignment.Center
    return p
end
local function Switch(p) if Current then Current.Visible=false end Current=p p.Visible=true end
local function Tab(text,y,page)
    local b=Instance.new("TextButton",Tabs)
    b.Size=UDim2.new(1,-20,0,42)
    b.Position=UDim2.new(0,10,0,y)
    b.Text=text
    b.BackgroundColor3=Theme.Btn
    b.TextColor3=Theme.Text
    b.Font=Enum.Font.GothamBold
    b.TextSize=15
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,14)
    b.MouseButton1Click:Connect(function() Switch(page) end)
end

local Combat=NewPage()
local Visual=NewPage()
local Move=NewPage()
Tab("⚔ Combat",10,Combat)
Tab("👁 Visual",60,Visual)
Tab("🏃 Movement",110,Move)
Switch(Combat)

local function Toggle(parent,text,cb)
    local t=Instance.new("TextButton",parent)
    t.Size=UDim2.new(1,-20,0,40)
    t.Text=text.." : OFF"
    t.BackgroundColor3=Theme.Btn
    t.TextColor3=Theme.Text
    t.Font=Enum.Font.Gotham
    t.TextSize=14
    Instance.new("UICorner",t).CornerRadius=UDim.new(0,12)
    local on=false
    t.MouseButton1Click:Connect(function()
        on=not on
        t.Text=text.." : "..(on and "ON" or "OFF")
        cb(on)
    end)
end

-- ESP
local ESP={}
local function ClearESP(p)
    if ESP[p] then ESP[p]:Remove() ESP[p]=nil end
end
Players.PlayerRemoving:Connect(ClearESP)

RunService.RenderStepped:Connect(function()
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            if not ESP[p] then
                ESP[p]=Drawing.new("Square")
                ESP[p].Color=Theme.Glow
                ESP[p].Thickness=2
            end
            local pos,on=Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if on and S.ESP then
                ESP[p].Visible=true
                ESP[p].Size=Vector2.new(38,58)
                ESP[p].Position=Vector2.new(pos.X-19,pos.Y-29)
            else
                ESP[p].Visible=false
            end
        else
            ClearESP(p)
        end
    end
end)

-- AIMBOT (smooth camera lock)
RunService.RenderStepped:Connect(function()
    if S.AIM and HRP() then
        local t=Nearest(320)
        if t then
            local look=CFrame.new(Camera.CFrame.Position,t.HumanoidRootPart.Position)
            Camera.CFrame=Camera.CFrame:Lerp(look,0.15)
        end
    end
end)

-- GHOST
local function Ghost(on)
    if not Char() then return end
    for _,v in ipairs(Char():GetChildren()) do
        if v:IsA("BasePart") then
            v.Transparency=on and 0.7 or 0
            v.CanCollide=not on
        end
    end
end

-- SPEED
local function Speed(on)
    if Hum() then Hum().WalkSpeed=on and 38 or 16 end
end

-- FLY (safe)
local BV,BG
local function Fly(on)
    if not HRP() then return end
    if on then
        BV=Instance.new("BodyVelocity",HRP())
        BG=Instance.new("BodyGyro",HRP())
        BV.MaxForce=Vector3.new(9e9,9e9,9e9)
        BG.MaxTorque=Vector3.new(9e9,9e9,9e9)
        RunService.RenderStepped:Connect(function()
            if S.FLY and HRP() then
                BV.Velocity=Camera.CFrame.LookVector*70
                BG.CFrame=Camera.CFrame
            end
        end)
    else
        if BV then BV:Destroy() BV=nil end
        if BG then BG:Destroy() BG=nil end
    end
end

-- FLOATING BUTTONS
local function Float(text,x,cb)
    local b=Instance.new("TextButton",GUI)
    b.Size=UDim2.fromOffset(48,48)
    b.Position=UDim2.new(0,x,0.45,0)
    b.Text=text
    b.BackgroundColor3=Theme.Glow
    b.TextColor3=Color3.new(1,1,1)
    b.Font=Enum.Font.GothamBold
    b.TextSize=14
    b.Active,b.Draggable=true,true
    Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
    b.MouseButton1Click:Connect(cb)
end

Float("ESP",18,function() S.ESP=not S.ESP end)
Float("AIM",74,function() S.AIM=not S.AIM end)
Float("FLY",130,function() S.FLY=not S.FLY Fly(S.FLY) end)

-- TOGGLES
Toggle(Combat,"Aimbot",function(v) S.AIM=v end)
Toggle(Visual,"ESP",function(v) S.ESP=v end)
Toggle(Visual,"Ghost",function(v) S.GHOST=v Ghost(v) end)
Toggle(Move,"Speed",function(v) S.SPEED=v Speed(v) end)
Toggle(Move,"Fly",function(v) S.FLY=v Fly(v) end)
