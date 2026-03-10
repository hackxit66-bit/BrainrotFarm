--[[
    BRAINROT COLLECTOR v1.0
    Interface elegante para controle de brainrots
    Criado para Roblox
]]

-- Services
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TextChatService = game:GetService("TextChatService")
local plr = Players.LocalPlayer
local playerGui = plr:WaitForChild("PlayerGui")

-- Configurações do script
local config = {
    updateTargetInterval = 0.1,
    acceptableDistance = 4,
    tweenSpeed = 51.261,
    running = false,
    autoCollect = false,
    showNotifications = true,
    selectedRarity = "All" -- All, Common, Rare, Epic, Legendary, Mythic, God, Secret
}

-- Lista de brainrots por raridade
local brainrots = {
    Common = {
        "Noobini Pizzanini",
        "Lirilì Larilà",
        "Tim Cheese",
        "Fluriflura",
        "Talpa Di Fero",
        "Svinina Bombardino",
        "Pipi Kiwi",
        "Pipi Corni"
    },
    Rare = {
        "Trippi Troppi",
        "Tung Tung Tung Sahur",
        "Gangster Footera",
        "Bandito Bobritto",
        "Boneca Ambalabu",
        "Cacto Hipopotamo",
        "Ta Ta Ta Ta Sahur",
        "Tric Trac Baraboom",
        "Pipi Avocado"
    },
    Epic = {
        "Cappuccino Assassino",
        "Brr Brr Patapim",
        "Trulimero Trulicina",
        "Bambini Crostini",
        "Bananita Dolphinita",
        "Perochello Lemonchello",
        "Brri Brri Bicus Dicus Bombicus",
        "Avocadini Guffo",
        "Ti Ti Ti Sahur",
        "Salamino Penguino",
        "Penguino Cocosino"
    },
    Legendary = {
        "Burbaloni Loliloli",
        "Chimpazini Bananini",
        "Ballerina Cappuccina",
        "Chef Crabracadabra",
        "Lionel Cactuseli",
        "Glorbo Fruttodrillo",
        "Blueberrini Octopusini",
        "Strawberelli Flamingelli",
        "Cocosini Mama",
        "Pandaccini Bananini",
        "Pi Pi Watermelon",
        "Sigma Boy"
    },
    Mythic = {
        "Frigo Camelo",
        "Orangutini Ananassini",
        "Rhino Toasterino",
        "Bombardiro Crocodilo",
        "Spioniro Golubiro",
        "Bombombini Gusini",
        "Avocadorilla",
        "Zibra Zubra Zibralini",
        "Tigrilini Watermelini",
        "Cavallo Virtuso",
        "Gorillo Watermelondrillo",
        "Tob Tobi Tobi",
        "Ganganzelli Trulala",
        "Te Te Te Sahur"
    },
    God = {
        "Cocofanto Elefanto",
        "Girafa Celestre",
        "Gattatino Neonino",
        "Matteo",
        "Tralalero Tralala",
        "Los Crocodillitos",
        "Espresso Signora",
        "Odin Din Din Dun",
        "Statutino Libertino",
        "Tukanno Bananno",
        "Trenostruzzo Turbo 3000",
        "Trippi Troppi Troppa Trippa",
        "Ballerino Lololo",
        "Los Tungtungtungcitos",
        "Piccione Macchina",
        "Los Orcalitos",
        "Tigroligre Frutonni",
        "Orcalero Orcala",
        "Bulbito Bandito Traktorito"
    },
    Secret = {
        "La Vacca Saturno Saturnita",
        "Karkerkar Kurkur",
        "Chimpanzini Spiderini",
        "Agarrini la Palini",
        "Los Tralaleritos",
        "Las Tralaleritas",
        "Las Vaquitas Saturnitas",
        "Graipuss Medussi",
        "Chicleteira Bicicleteira",
        "La Grande Combinasion",
        "Los Combinasionas",
        "Nuclearo Dinossauro",
        "Los Hotspotsitos",
        "Garama and Madundung",
        "Dragon Cannelloni",
        "Torrtuginni Dragonfrutini",
        "Pot Hotspot",
        "Esok Sekolah"
    }
}

-- Criar mapa de nomes permitidos
local allowedNames = {}
for rarity, names in pairs(brainrots) do
    for _, name in ipairs(names) do
        allowedNames[name] = (rarity == "Secret" or rarity == "God") -- Secret e God como admin
    end
end

-- Criar GUI principal
local function createGUI()
    -- ScreenGui principal
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotCollector"
    screenGui.Parent = playerGui
    screenGui.ResetOnSpawn = false
    
    -- Frame principal (fundo transparente)
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 350, 0, 500)
    mainFrame.Position = UDim2.new(0, 20, 0.5, -250)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BackgroundTransparency = 0.1
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Sombra
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxassetid://1316045217"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.5
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.Parent = mainFrame
    
    -- Gradiente superior
    local topGradient = Instance.new("UIGradient")
    topGradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(40, 40, 60)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 30))
    })
    topGradient.Rotation = 90
    topGradient.Parent = mainFrame
    
    -- Bordas arredondadas
    local corners = Instance.new("UICorner")
    corners.CornerRadius = UDim.new(0, 10)
    corners.Parent = mainFrame
    
    -- Título
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "🧠 BRAINROT COLLECTOR"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    -- Linha decorativa
    local line = Instance.new("Frame")
    line.Name = "Line"
    line.Size = UDim2.new(0.9, 0, 0, 2)
    line.Position = UDim2.new(0.05, 0, 0, 50)
    line.BackgroundColor3 = Color3.fromRGB(100, 200, 255)
    line.BorderSizePixel = 0
    line.Parent = mainFrame
    
    -- Frame de status
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(0.9, 0, 0, 60)
    statusFrame.Position = UDim2.new(0.05, 0, 0, 60)
    statusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    statusFrame.BackgroundTransparency = 0.3
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = mainFrame
    
    local statusCorners = Instance.new("UICorner")
    statusCorners.CornerRadius = UDim.new(0, 5)
    statusCorners.Parent = statusFrame
    
    -- Status text
    local statusText = Instance.new("TextLabel")
    statusText.Name = "StatusText"
    statusText.Size = UDim2.new(1, -20, 0.5, 0)
    statusText.Position = UDim2.new(0, 10, 0, 5)
    statusText.BackgroundTransparency = 1
    statusText.Text = "⚪ Desativado"
    statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    statusText.TextXAlignment = Enum.TextXAlignment.Left
    statusText.Font = Enum.Font.GothamSemibold
    statusText.TextSize = 14
    statusText.Parent = statusFrame
    
    -- Contador
    local counterText = Instance.new("TextLabel")
    counterText.Name = "CounterText"
    counterText.Size = UDim2.new(1, -20, 0.5, 0)
    counterText.Position = UDim2.new(0, 10, 0.5, 0)
    counterText.BackgroundTransparency = 1
    counterText.Text = "Coletados: 0"
    counterText.TextColor3 = Color3.fromRGB(200, 200, 200)
    counterText.TextXAlignment = Enum.TextXAlignment.Left
    counterText.Font = Enum.Font.Gotham
    counterText.TextSize = 12
    counterText.Parent = statusFrame
    
    -- Botões principais
    local function createButton(name, text, posY, color, callback)
        local btn = Instance.new("TextButton")
        btn.Name = name
        btn.Size = UDim2.new(0.9, 0, 0, 40)
        btn.Position = UDim2.new(0.05, 0, 0, posY)
        btn.BackgroundColor3 = color
        btn.Text = text
        btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.BorderSizePixel = 0
        btn.Parent = mainFrame
        
        local btnCorners = Instance.new("UICorner")
        btnCorners.CornerRadius = UDim.new(0, 5)
        btnCorners.Parent = btn
        
        -- Efeito hover
        btn.MouseEnter:Connect(function()
            btn.BackgroundColor3 = color:Lerp(Color3.fromRGB(255, 255, 255), 0.2)
        end)
        
        btn.MouseLeave:Connect(function()
            btn.BackgroundColor3 = color
        end)
        
        btn.MouseButton1Click:Connect(callback)
        
        return btn
    end
    
    -- Criar botões
    local startBtn = createButton("StartBtn", "▶ INICIAR COLETA", 130, Color3.fromRGB(0, 200, 100), function()
        config.running = true
        config.autoCollect = true
        statusText.Text = "🟢 Coletando..."
        statusText.TextColor3 = Color3.fromRGB(100, 255, 100)
        startCollecting()
    end)
    
    local stopBtn = createButton("StopBtn", "⏹ PARAR COLETA", 180, Color3.fromRGB(200, 50, 50), function()
        config.running = false
        config.autoCollect = false
        statusText.Text = "⚪ Desativado"
        statusText.TextColor3 = Color3.fromRGB(255, 100, 100)
    end)
    
    -- Dropdown de raridade
    local rarityFrame = Instance.new("Frame")
    rarityFrame.Name = "RarityFrame"
    rarityFrame.Size = UDim2.new(0.9, 0, 0, 40)
    rarityFrame.Position = UDim2.new(0.05, 0, 0, 235)
    rarityFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    rarityFrame.BackgroundTransparency = 0.3
    rarityFrame.BorderSizePixel = 0
    rarityFrame.Parent = mainFrame
    
    local rarityCorners = Instance.new("UICorner")
    rarityCorners.CornerRadius = UDim.new(0, 5)
    rarityCorners.Parent = rarityFrame
    
    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Name = "RarityLabel"
    rarityLabel.Size = UDim2.new(0.4, 0, 1, 0)
    rarityLabel.Position = UDim2.new(0, 10, 0, 0)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = "Raridade:"
    rarityLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Font = Enum.Font.Gotham
    rarityLabel.TextSize = 14
    rarityLabel.Parent = rarityFrame
    
    local rarityDropdown = Instance.new("TextButton")
    rarityDropdown.Name = "RarityDropdown"
    rarityDropdown.Size = UDim2.new(0.5, 0, 0.8, 0)
    rarityDropdown.Position = UDim2.new(0.45, 0, 0.1, 0)
    rarityDropdown.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
    rarityDropdown.Text = "Todos"
    rarityDropdown.TextColor3 = Color3.fromRGB(255, 255, 255)
    rarityDropdown.Font = Enum.Font.Gotham
    rarityDropdown.TextSize = 13
    rarityDropdown.BorderSizePixel = 0
    rarityDropdown.Parent = rarityFrame
    
    local dropdownCorners = Instance.new("UICorner")
    dropdownCorners.CornerRadius = UDim.new(0, 3)
    dropdownCorners.Parent = rarityDropdown
    
    -- Lista de raridades
    local rarities = {"Todos", "Common", "Rare", "Epic", "Legendary", "Mythic", "God", "Secret"}
    local currentRarity = 1
    
    rarityDropdown.MouseButton1Click:Connect(function()
        currentRarity = currentRarity % #rarities + 1
        rarityDropdown.Text = rarities[currentRarity]
        config.selectedRarity = rarities[currentRarity]
    end)
    
    -- Botão de notificações
    local notifBtn = createButton("NotifBtn", "🔔 Notificações: ON", 290, Color3.fromRGB(100, 100, 200), function()
        config.showNotifications = not config.showNotifications
        notifBtn.Text = "🔔 Notificações: " .. (config.showNotifications and "ON" or "OFF")
        notifBtn.BackgroundColor3 = config.showNotifications and Color3.fromRGB(100, 100, 200) or Color3.fromRGB(80, 80, 80)
    end)
    
    -- Lista de brainrots próximos
    local listFrame = Instance.new("ScrollingFrame")
    listFrame.Name = "ListFrame"
    listFrame.Size = UDim2.new(0.9, 0, 0, 120)
    listFrame.Position = UDim2.new(0.05, 0, 0, 340)
    listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    listFrame.BackgroundTransparency = 0.3
    listFrame.BorderSizePixel = 0
    listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    listFrame.ScrollBarThickness = 5
    listFrame.Parent = mainFrame
    
    local listCorners = Instance.new("UICorner")
    listCorners.CornerRadius = UDim.new(0, 5)
    listCorners.Parent = listFrame
    
    local listTitle = Instance.new("TextLabel")
    listTitle.Name = "ListTitle"
    listTitle.Size = UDim2.new(1, 0, 0, 25)
    listTitle.Position = UDim2.new(0, 0, 0, 0)
    listTitle.BackgroundTransparency = 1
    listTitle.Text = "📋 Brainrots Disponíveis"
    listTitle.TextColor3 = Color3.fromRGB(200, 200, 255)
    listTitle.Font = Enum.Font.GothamSemibold
    listTitle.TextSize = 12
    listTitle.Parent = listFrame
    
    -- Botão de fechar
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -40, 0, 10)
    closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    closeBtn.Text = "✕"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = mainFrame
    
    local closeCorners = Instance.new("UICorner")
    closeCorners.CornerRadius = UDim.new(0, 15)
    closeCorners.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        screenGui:Destroy()
        config.running = false
    end)
    
    -- Botão para mover a GUI
    local dragFrame = Instance.new("Frame")
    dragFrame.Name = "DragFrame"
    dragFrame.Size = UDim2.new(1, -50, 0, 50)
    dragFrame.Position = UDim2.new(0, 0, 0, 0)
    dragFrame.BackgroundTransparency = 1
    dragFrame.Parent = mainFrame
    
    local dragging = false
    local dragOffset = Vector2.new()
    
    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragOffset = Vector2.new(input.Position.X - mainFrame.AbsolutePosition.X, input.Position.Y - mainFrame.AbsolutePosition.Y)
        end
    end)
    
    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            mainFrame.Position = UDim2.new(0, input.Position.X - dragOffset.X, 0, input.Position.Y - dragOffset.Y)
        end
    end)
    
    dragFrame.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    return {
        screenGui = screenGui,
        statusText = statusText,
        counterText = counterText,
        listFrame = listFrame
    }
end

-- Lógica de coleta
local function tweenToAnimal(animal, guiElements)
    if not config.running then return end

    local playerHRP = workspace[plr.Name]:WaitForChild("HumanoidRootPart")
    local lastUpdate = 0

    local hrp = animal:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local targetPos = hrp.Position

    local distance = (targetPos - playerHRP.Position).Magnitude
    local tweenTime = distance / config.tweenSpeed
    local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
    local tween = TweenService:Create(playerHRP, tweenInfo, {CFrame = CFrame.new(targetPos)})
    tween:Play()

    while config.running and (playerHRP.Position - targetPos).Magnitude > config.acceptableDistance do
        local now = tick()
        if now - lastUpdate > config.updateTargetInterval then
            local newHrp = animal:FindFirstChild("HumanoidRootPart")
            if newHrp then
                targetPos = newHrp.Position
            else
                break
            end

            lastUpdate = now
            tween:Cancel()

            distance = (targetPos - playerHRP.Position).Magnitude
            tweenTime = distance / config.tweenSpeed
            tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Linear)
            tween = TweenService:Create(playerHRP, tweenInfo, {CFrame = CFrame.new(targetPos)})
            tween:Play()
        end
        task.wait(0.1)
    end
    tween:Cancel()
end

-- Iniciar coleta
function startCollecting()
    local guiElements = createGUI()
    local animalsFolder = workspace:WaitForChild("MovingAnimals")
    local collectedCount = 0
    
    animalsFolder.ChildAdded:Connect(function(animal)
        if not config.running then return end
        
        task.wait(1) -- Pequena pausa para carregar
        
        local hrp = animal:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        
        local info = hrp:FindFirstChild("Info")
        if not info then return end
        
        local overhead = info:FindFirstChild("AnimalOverhead")
        if not overhead then return end
        
        local displayName = overhead:FindFirstChild("DisplayName")
        if not displayName then return end
        
        local name = displayName.Text
        
        -- Verificar raridade
        local shouldCollect = false
        if config.selectedRarity == "Todos" then
            shouldCollect = allowedNames[name] ~= nil
        else
            for _, n in ipairs(brainrots[config.selectedRarity] or {}) do
                if n == name then
                    shouldCollect = true
                    break
                end
            end
        end
        
        if shouldCollect then
            if config.showNotifications then
                guiElements.statusText.Text = "🟢 Coletando: " .. name
            end
            
            tweenToAnimal(animal, guiElements)
            
            local promptAttachment = hrp:FindFirstChild("PromptAttachment")
            if promptAttachment then
                local prompt = promptAttachment:FindFirstChild("ProximityPrompt")
                if prompt then
                    prompt:InputHoldBegin()
                    task.wait(1)
                    prompt:InputHoldEnd()
                    
                    if hrp:FindFirstChildOfClass("Sound") then
                        collectedCount = collectedCount + 1
                        guiElements.counterText.Text = "Coletados: " .. collectedCount
                        
                        -- Adicionar à lista
                        local item = Instance.new("TextLabel")
                        item.Size = UDim2.new(1, -10, 0, 20)
                        item.Position = UDim2.new(0, 5, 0, 25 + (collectedCount * 20))
                        item.BackgroundTransparency = 1
                        item.Text = "✅ " .. name
                        item.TextColor3 = Color3.fromRGB(150, 255, 150)
                        item.TextXAlignment = Enum.TextXAlignment.Left
                        item.Font = Enum.Font.Gotham
                        item.TextSize = 11
                        item.Parent = guiElements.listFrame
                        
                        guiElements.listFrame.CanvasSize = UDim2.new(0, 0, 0, 45 + (collectedCount * 20))
                    end
                end
            end
        end
    end)
end

-- Iniciar GUI
createGUI()]]