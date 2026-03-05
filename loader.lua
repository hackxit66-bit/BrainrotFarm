-- =============================================
-- BRAINROT FARM - LOADER OFICIAL
-- =============================================
-- GitHub: hackxit66-bit/BrainrotFarm
-- Versão: 1.0
-- Use esta linha no executor: 
-- loadstring(game:HttpGet("https://raw.githubusercontent.com/hackxit66-bit/BrainrotFarm/main/loader.lua"))()
-- =============================================

local repo = "hackxit66-bit"
local nomeScript = "BrainrotFarm"
local versaoAtual = "1.0"

print("🧠 BRAINROT FARM - CARREGANDO...")
print("=================================")

-- Limpar cache antigo
if getgenv().BrainrotFarm then
    getgenv().BrainrotFarm = nil
end

-- Função para baixar o script principal
local function baixarScript()
    local url = "https://raw.githubusercontent.com/" .. repo .. "/" .. nomeScript .. "/main/script.lua"
    local sucesso, resultado = pcall(function()
        return game:HttpGet(url)
    end)
    if sucesso and resultado then
        return resultado
    else
        print("❌ ERRO: Não foi possível baixar o script!")
        print("   Verifique sua conexão ou o link:")
        print("   " .. url)
        return nil
    end
end

-- Baixar e executar
local scriptConteudo = baixarScript()
if scriptConteudo then
    print("✅ Script baixado com sucesso!")
    print("🚀 Executando...")
    local func, err = loadstring(scriptConteudo)
    if func then
        local ok, erroExec = pcall(func)
        if ok then
            print("✅ BRAINROT FARM CARREGADO!")
        else
            print("❌ Erro ao executar: " .. tostring(erroExec))
        end
    else
        print("❌ Erro ao compilar: " .. tostring(err))
    end
else
    print("❌ Falha no carregamento!")
end

print("=================================")
