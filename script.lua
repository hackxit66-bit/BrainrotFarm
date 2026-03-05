-- =============================================
-- BRAINROT FARM - CONSTRUIR E ROUBAR
-- =============================================

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer

-- CONFIGURAÇÕES
local Config = {
    AutoBreak = false,
    AutoFarm = false,
    SpeedBoost = 0,
    ESPPlayers = false,
    ESPLock = false,
    ESPLegendary = false,
    ESPMythic = false,
    ESPGod = false,
    ESPSecret = false,
    BreakRange = 20,
    FarmRange = 30,
}

-- VARIÁVEIS
local plotName = ""
local myPlotName = ""
local espInstances = {}
local activeESP = {}
local lteInstances = {}
local contadorBlocos = 0
local contadorBrainrots = 0
local quebrando = false

-- FUNÇÕES AUXILIARES
function getRoot()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

function getHumanoid()
    local character = player.Character
    return character and character:FindFirstChild("Humanoid")
end

function getTool()
    local character = player.Character
    if character then
        for _, tool in pairs(character:GetChildren()) do
            if tool:IsA("Tool") then return tool end
        end
    end
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then return tool end
        end
    end
    return nil
end

-- ENCONTRAR TERRENO
pcall(function()
    for _, plot in ipairs(Workspace.Plots:GetChildren()) do
        if plot:FindFirstChild("YourBase", true) and plot:FindFirstChild("YourBase", true).Enabled then
            plotName = plot.Name
            myPlotName = plot.Name
            break
        end
    end
end)

-- CONFIGURAÇÕES DE RARIDADE
local RaritySettings = {
    ["Legendary"] = { Color = Color3.new(1, 1, 0), Size = 50 },
    ["Mythic"] = { Color = Color3.new(1, 0, 0), Size = 50 },
    ["Brainrot God"] = { Color = Color3.new(0.5, 0, 0.5), Size = 60 },
    ["Secret"] = { Color = Color3.new(0, 0, 0), Size = 70 }
}

local MutationSettings = {
    ["Gold"] = { Color = Color3.fromRGB(255, 215, 0) },
    ["Diamond"] = { Color = Color3.fromRGB(0, 191, 255) },
    ["Rainbow"] = { Color = Color3.fromRGB(255, 192, 203) },
    ["Bloodrot"] = { Color = Color3.fromRGB(139, 0, 0) }
}

-- FUNÇÕES DE ESP
function criarESPJogador(alvo)
    if not alvo.Character then return end
    local highlight = Instance.new("Highlight")
    highlight.Name = "ESP_" .. alvo.Name
    highlight.FillColor = Color3.fromRGB(255, 0, 0)
    highlight.FillTransparency = 0.5
    highlight.Parent = alvo.Character
    table.insert(espInstances, highlight)
end

function atualizarLockESP()
    if not Config.ESPLock then
        for _, v in pairs(lteInstances) do v:Destroy() end
        lteInstances = {}
        return
    end
    for _, plot in pairs(Workspace.Plots:GetChildren()) do
        local timeLabel = plot:FindFirstChild("Purchases", true) and 
            plot.Purchases:FindFirstChild("PlotBlock", true) and
            plot.Purchases.PlotBlock.Main:FindFirstChild("BillboardGui", true) and
            plot.Purchases.PlotBlock.Main.BillboardGui:FindFirstChild("RemainingTime", true)
        if timeLabel then
            local espName = "LockTimeESP_" .. plot.Name
            local existing = plot:FindFirstChild(espName)
            local isUnlocked = timeLabel.Text == "0s"
            local displayText = isUnlocked and "🔓 UNLOCKED" or ("🔒 " .. timeLabel.Text)
            local textColor = isUnlocked and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,255,0)
            if not existing then
                local billboard = Instance.new("BillboardGui")
                billboard.Name = espName
                billboard.Size = UDim2.new(0,150,0,30)
                billboard.StudsOffset = Vector3.new(0,5,0)
                billboard.AlwaysOnTop = true
                billboard.Adornee = plot.Purchases.PlotBlock.Main
                local label = Instance.new("TextLabel")
                label.Text = displayText
                label.Size = UDim2.new(1,0,1,0)
                label.BackgroundTransparency = 1
                label.TextScaled = true
                label.TextColor3 = textColor
                label.TextStrokeColor3 = Color3.new(0,0,0)
                label.Font = Enum.Font.SourceSansBold
                label.Parent = billboard
                billboard.Parent = plot
                lteInstances[plot.Name] = billboard
            else
                existing.TextLabel.Text = displayText
                existing.TextLabel.TextColor3 = textColor
            end
        end
    end
end

function atualizarBrainrotESP()
    if not next(activeESP) then return end
    for _, plot in pairs(Workspace.Plots:GetChildren()) do
        if plot.Name ~= myPlotName then
            for _, child in pairs(plot:GetDescendants()) do
                if child.Name == "Rarity" and child:IsA("TextLabel") and RaritySettings[child.Text] then
                    local parentModel = child.Parent.Parent
                    local espName = child.Text .. "_ESP"
                    local existing = parentModel:FindFirstChild(espName)
                    if activeESP[child.Text] and not existing then
                        local settings = RaritySettings[child.Text]
                        local billboard = Instance.new("BillboardGui")
                        billboard.Name = espName
                        billboard.Size = UDim2.new(0,150,0,settings.Size)
                        billboard.StudsOffset = Vector3.new(0,3,0)
                        billboard.AlwaysOnTop = true
                        local label = Instance.new("TextLabel")
                        label.Text = child.Parent.DisplayName.Text
                        label.Size = UDim2.new(1,0,1,0)
                        label.BackgroundTransparency = 1
                        label.TextScaled = true
                        label.TextColor3 = settings.Color
                        label.TextStrokeColor3 = Color3.new(0,0,0)
                        label.Font = Enum.Font.SourceSansBold
                        label.Parent = billboard
                        billboard.Parent = parentModel
                        table.insert(espInstances, billboard)
                    end
                end
            end
        end
    end
end

function limparESP()
    for _, v in pairs(espInstances) do pcall(function() v:Destroy() end) end
    for _, v in pairs(lteInstances) do pcall(function() v:Destroy() end) end
    espInstances = {}; lteInstances = {}
end

-- FUNÇÕES DE FARM
function encontrarBlocosQuebraveis()
    local blocos = {}; local root = getRoot(); if not root then return blocos end
    local nomes = {"Brick","Block","Wall","Part","Base","Wood","Stone","Metal","Glass"}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Position then
            for _, nome in pairs(nomes) do
                if obj.Name:find(nome) and (not obj.Parent or obj.Parent.Name ~= player.Name) then
                    local dist = (obj.Position - root.Position).Magnitude
                    if dist < Config.BreakRange then table.insert(blocos, {obj = obj, dist = dist}); break end
                end
            end
        end
    end
    table.sort(blocos, function(a,b) return a.dist < b.dist end); return blocos
end

function encontrarBrainrots()
    local itens = {}; local root = getRoot(); if not root then return itens end
    local nomes = {"Brain","Rot","Meme","Emote","Brainrot","Laugh","Cry","Angry","Happy"}
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("Part") and obj.Position then
            for _, nome in pairs(nomes) do
                if obj.Name:find(nome) then
                    local dist = (obj.Position - root.Position).Magnitude
                    if dist < Config.FarmRange then table.insert(itens, {obj = obj, dist = dist}); break end
                end
            end
        end
    end
    table.sort(itens, function(a,b) return a.dist < b.dist end); return itens
end

function quebrarBloco(bloco)
    if not bloco or quebrando then return end
    quebrando = true; local root = getRoot()
    if root then
        root.CFrame = bloco.CFrame * CFrame.new(0,0,3); wait(0.1)
        local tool = getTool(); if tool then tool.Parent = player.Character; wait(0.1) end
        if bloco:FindFirstChild("ClickDetector") then fireclickdetector(bloco.ClickDetector) end
        wait(0.2); contadorBlocos = contadorBlocos + 1
    end
    quebrando = false
end

function coletarBrainrot(brainrot)
    if not brainrot then return end
    local root = getRoot()
    if root then
        root.CFrame = brainrot.CFrame * CFrame.new(0,3,0); wait(0.1)
        if brainrot:FindFirstChild("ClickDetector") then fireclickdetector(brainrot.ClickDetector) end
        contadorBrainrots = contadorBrainrots + 1
    end
end

-- LOOP DE FARM
spawn(function() while true do wait(0.3)
    if Config.AutoBreak then local b = encontrarBlocosQuebraveis(); if #b>0 then quebrarBloco(b[1].obj) end end
    if Config.AutoFarm then local b = encontrarBrainrots(); if #b>0 then coletarBrainrot(b[1].obj) end end
end end)

-- LOOP DE ESP
spawn(function() while true do wait(0.5)
    if Config.ESPLock then atualizarLockESP() end
    if next(activeESP) ~= nil then atualizarBrainrotESP() end
end end)

-- =============================================
-- INTERFACE
-- =============================================
local gui = Instance.new("ScreenGui"); gui.Name = "BrainrotFarm"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui")
local frame = Instance.new("Frame"); frame.Size = UDim2.new(0,300,0,450); frame.Position = UDim2.new(0.5,-150,0.5,-225); frame.BackgroundColor3 = Color3.fromRGB(25,25,35); frame.BackgroundTransparency = 0.1; frame.Active = true; frame.Draggable = true; frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,10)

local title = Instance.new("TextLabel"); title.Size = UDim2.new(1,0,0,40); title.BackgroundColor3 = Color3.fromRGB(255,100,100); title.Text = "🧠 BRAINROT FARM"; title.TextColor3 = Color3.new(1,1,1); title.TextSize = 18; title.Font = Enum.Font.GothamBold; title.Parent = frame
Instance.new("UICorner", title).CornerRadius = UDim.new(0,10)

local lockLabel = Instance.new("TextLabel"); lockLabel.Size = UDim2.new(0.9,0,0,25); lockLabel.Position = UDim2.new(0.05,0,0.12,0); lockLabel.BackgroundColor3 = Color3.fromRGB(40,40,50); lockLabel.Text = "🔒 Lock Time: ..."; lockLabel.TextColor3 = Color3.new(1,1,1); lockLabel.TextSize = 12; lockLabel.Font = Enum.Font.GothamBold; lockLabel.Parent = frame
Instance.new("UICorner", lockLabel).CornerRadius = UDim.new(0,5)

local statsLabel = Instance.new("TextLabel"); statsLabel.Size = UDim2.new(0.9,0,0,25); statsLabel.Position = UDim2.new(0.05,0,0.2,0); statsLabel.BackgroundColor3 = Color3.fromRGB(40,40,50); statsLabel.Text = "📊 Blocos: 0 | Brainrots: 0"; statsLabel.TextColor3 = Color3.fromRGB(255,215,0); statsLabel.TextSize = 11; statsLabel.Font = Enum.Font.GothamBold; statsLabel.Parent = frame
Instance.new("UICorner", statsLabel).CornerRadius = UDim.new(0,5)

local farmSection = Instance.new("TextLabel"); farmSection.Size = UDim2.new(0.9,0,0,20); farmSection.Position = UDim2.new(0.05,0,0.27,0); farmSection.BackgroundTransparency = 1; farmSection.Text = "⚙️ FARM"; farmSection.TextColor3 = Color3.fromRGB(255,215,0); farmSection.TextSize = 14; farmSection.Font = Enum.Font.GothamBold; farmSection.TextXAlignment = Enum.TextXAlignment.Left; farmSection.Parent = frame

local btnBreak = Instance.new("TextButton"); btnBreak.Size = UDim2.new(0.8,0,0,30); btnBreak.Position = UDim2.new(0.1,0,0.32,0); btnBreak.BackgroundColor3 = Color3.fromRGB(0,100,200); btnBreak.Text = "🔨 AUTO BREAK OFF"; btnBreak.TextColor3 = Color3.new(1,1,1); btnBreak.TextSize = 12; btnBreak.Font = Enum.Font.GothamBold; btnBreak.Parent = frame
Instance.new("UICorner", btnBreak).CornerRadius = UDim.new(0,5)

local btnFarm = Instance.new("TextButton"); btnFarm.Size = UDim2.new(0.8,0,0,30); btnFarm.Position = UDim2.new(0.1,0,0.4,0); btnFarm.BackgroundColor3 = Color3.fromRGB(0,150,0); btnFarm.Text = "🧠 AUTO FARM OFF"; btnFarm.TextColor3 = Color3.new(1,1,1); btnFarm.TextSize = 12; btnFarm.Font = Enum.Font.GothamBold; btnFarm.Parent = frame
Instance.new("UICorner", btnFarm).CornerRadius = UDim.new(0,5)

local speedLabel = Instance.new("TextLabel"); speedLabel.Size = UDim2.new(0.8,0,0,20); speedLabel.Position = UDim2.new(0.1,0,0.48,0); speedLabel.BackgroundTransparency = 1; speedLabel.Text = "⚡ Speed Boost: 0"; speedLabel.TextColor3 = Color3.new(1,1,1); speedLabel.TextSize = 11; speedLabel.Font = Enum.Font.Gotham; speedLabel.TextXAlignment = Enum.TextXAlignment.Left; speedLabel.Parent = frame

local sliderBg = Instance.new("Frame"); sliderBg.Size = UDim2.new(0.8,0,0,15); sliderBg.Position = UDim2.new(0.1,0,0.52,0); sliderBg.BackgroundColor3 = Color3.fromRGB(50,50,60); sliderBg.Parent = frame
Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0,5)
local sliderFill = Instance.new("Frame"); sliderFill.Size = UDim2.new(0,0,1,0); sliderFill.BackgroundColor3 = Color3.fromRGB(0,200,255); sliderFill.Parent = sliderBg
Instance.new("UICorner", sliderFill).CornerRadius = UDim.new(0,5)
local sliderButton = Instance.new("TextButton"); sliderButton.Size = UDim2.new(1,0,1,0); sliderButton.BackgroundTransparency = 1; sliderButton.Text = ""; sliderButton.Parent = sliderBg

local espSection = Instance.new("TextLabel"); espSection.Size = UDim2.new(0.9,0,0,20); espSection.Position = UDim2.new(0.05,0,0.6,0); espSection.BackgroundTransparency = 1; espSection.Text = "👁️ ESP"; espSection.TextColor3 = Color3.fromRGB(255,215,0); espSection.TextSize = 14; espSection.Font = Enum.Font.GothamBold; espSection.TextXAlignment = Enum.TextXAlignment.Left; espSection.Parent = frame

local espBotoes = {
    {nome = "👤 Players", var = "ESPPlayers", pos = 0.65},
    {nome = "🔒 Lock", var = "ESPLock", pos = 0.7},
    {nome = "⭐ Legendary", var = "ESPLegendary", pos = 0.75},
    {nome = "🔥 Mythic", var = "ESPMythic", pos = 0.8},
    {nome = "👑 God", var = "ESPGod", pos = 0.85},
    {nome = "❓ Secret", var = "ESPSecret", pos = 0.9},
}

for i, info in ipairs(espBotoes) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.35,0,0,25)
    btn.Position = UDim2.new(0.1, (i%2==0 and 165 or 0), info.pos, 0)
    btn.BackgroundColor3 = Color3.fromRGB(100,100,100)
    btn.Text = info.nome .. " OFF"
    btn.TextColor3 = Color3.new(1,1,1)
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.Parent = frame
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,5)
    
    btn.MouseButton1Click:Connect(function()
        Config[info.var] = not Config[info.var]
        btn.Text = info.nome .. (Config[info.var] and " ON" or " OFF")
        btn.BackgroundColor3 = Config[info.var] and Color3.fromRGB(0,150,0) or Color3.fromRGB(100,100,100)
        if info.var == "ESPPlayers" and Config.ESPPlayers then
            for _, p in pairs(Players:GetPlayers()) do if p~=player then criarESPJogador(p) end end
        elseif info.var:find("ESP") and info.var ~= "ESPPlayers" and info.var ~= "ESPLock" then
            local nome = info.nome:gsub("^. ","")
            activeESP[nome] = Config[info.var]
        end
    end)
end

local btnSteal = Instance.new("TextButton"); btnSteal.Size = UDim2.new(0.8,0,0,35); btnSteal.Position = UDim2.new(0.1,0,0.96,-40); btnSteal.BackgroundColor3 = Color3.fromRGB(255,100,0); btnSteal.Text = "💰 STEAL (G)"; btnSteal.TextColor3 = Color3.new(1,1,1); btnSteal.TextSize = 14; btnSteal.Font = Enum.Font.GothamBold; btnSteal.Parent = frame
Instance.new("UICorner", btnSteal).CornerRadius = UDim.new(0,5)

local btnClose = Instance.new("TextButton"); btnClose.Size = UDim2.new(0.8,0,0,30); btnClose.Position = UDim2.new(0.1,0,0.96,-5); btnClose.BackgroundColor3 = Color3.fromRGB(100,100,100); btnClose.Text = "❌ FECHAR"; btnClose.TextColor3 = Color3.new(1,1,1); btnClose.TextSize = 12; btnClose.Font = Enum.Font.GothamBold; btnClose.Parent = frame
Instance.new("UICorner", btnClose).CornerRadius = UDim.new(0,5)

-- FUNÇÕES DOS BOTÕES
spawn(function() while true do wait(0.5)
    if Workspace.Plots and Workspace.Plots[plotName] then
        local time = Workspace.Plots[plotName].Purchases.PlotBlock.Main.BillboardGui.RemainingTime.Text
        lockLabel.Text = "🔒 Lock Time: " .. time
    end
    statsLabel.Text = string.format("📊 Blocos: %d | Brainrots: %d", contadorBlocos, contadorBrainrots)
end end)

btnBreak.MouseButton1Click:Connect(function()
    Config.AutoBreak = not Config.AutoBreak
    btnBreak.Text = Config.AutoBreak and "🔨 AUTO BREAK ON" or "🔨 AUTO BREAK OFF"
    btnBreak.BackgroundColor3 = Config.AutoBreak and Color3.fromRGB(0,200,0) or Color3.fromRGB(0,100,200)
end)

btnFarm.MouseButton1Click:Connect(function()
    Config.AutoFarm = not Config.AutoFarm
    btnFarm.Text = Config.AutoFarm and "🧠 AUTO FARM ON" or "🧠 AUTO FARM OFF"
    btnFarm.BackgroundColor3 = Config.AutoFarm and Color3.fromRGB(0,200,0) or Color3.fromRGB(0,150,0)
end)

sliderButton.MouseButton1Down:Connect(function()
    local conn
    conn = RunService.RenderStepped:Connect(function()
        local mousePos = UserInputService:GetMouseLocation()
        local absPos = sliderBg.AbsolutePosition
        local absSize = sliderBg.AbsoluteSize.X
        local percent = math.clamp((mousePos.X - absPos.X) / absSize, 0, 1)
        Config.SpeedBoost = math.floor(percent * 6 * 10) / 10
        sliderFill.Size = UDim2.new(percent,0,1,0)
        speedLabel.Text = "⚡ Speed Boost: " .. Config.SpeedBoost
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then conn:Disconnect() end
    end)
end)

btnSteal.MouseButton1Click:Connect(function()
    local root = getRoot()
    if root then root.CFrame = CFrame.new(0,-500,0); wait(1) end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if not gp and input.KeyCode == Enum.KeyCode.G then
        local root = getRoot()
        if root then root.CFrame = CFrame.new(0,-500,0); wait(1) end
    end
end)

btnClose.MouseButton1Click:Connect(function()
    limparESP()
    gui:Destroy()
end)

spawn(function() while true do wait(60)
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end end)

frame.BackgroundTransparency = 1
for i=1,10 do wait(0.02) frame.BackgroundTransparency = frame.BackgroundTransparency - 0.1 end
