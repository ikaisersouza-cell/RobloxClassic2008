--============================================================--
--                  ROBLOX CLASSIC 2008                     --
--                  CLIENT VISUAL EDITION                   --
--============================================================--

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer

--============================================================--
-- CONFIGURAÇÃO
--============================================================--

local CONFIG = {
    ClassicLighting = true,
    ClassicMaterials = true,
    ClassicSurfaces = true,
    ClassicWater = true,
    ClassicSky = true,

    -- Reaplica alterações em objetos adicionados depois
    AutoReapply = true,

    -- Interface
    ShowGUI = true,
}

local Enabled = true

--============================================================--
-- BACKUPS
--============================================================--

local LightingBackup = {}
local PartBackup = {}
local EffectBackup = {}
local OriginalSky = nil
local ClassicSkyObject = nil

--============================================================--
-- FUNÇÕES AUXILIARES
--============================================================--

local function safeSet(object, property, value)
    pcall(function()
        object[property] = value
    end)
end

local function getParentGui()
    local ok, gui = pcall(function()
        return game:GetService("CoreGui")
    end)

    if ok and gui then
        return gui
    end

    return LocalPlayer:WaitForChild("PlayerGui")
end

--============================================================--
-- BACKUP DA ILUMINAÇÃO
--============================================================--

local function backupLighting()

    if next(LightingBackup) ~= nil then
        return
    end

    local properties = {
        "Brightness",
        "Ambient",
        "OutdoorAmbient",
        "ColorShift_Top",
        "ColorShift_Bottom",
        "GlobalShadows",
        "FogStart",
        "FogEnd",
        "ShadowSoftness",
        "ClockTime",
        "ExposureCompensation",
    }

    for _, property in ipairs(properties) do
        local ok, value = pcall(function()
            return Lighting[property]
        end)

        if ok then
            LightingBackup[property] = value
        end
    end
end

--============================================================--
-- ILUMINAÇÃO CLÁSSICA
--============================================================--

local function applyClassicLighting()

    if not Enabled or not CONFIG.ClassicLighting then
        return
    end

    backupLighting()

    -- Renderização clássica
    safeSet(Lighting, "Technology", Enum.Technology.Compatibility)

    -- Valores associados ao visual antigo
    safeSet(Lighting, "Brightness", 1)

    safeSet(
        Lighting,
        "Ambient",
        Color3.fromRGB(128, 128, 128)
    )

    safeSet(
        Lighting,
        "OutdoorAmbient",
        Color3.fromRGB(128, 128, 128)
    )

    safeSet(
        Lighting,
        "ColorShift_Top",
        Color3.fromRGB(0, 0, 0)
    )

    safeSet(
        Lighting,
        "ColorShift_Bottom",
        Color3.fromRGB(0, 0, 0)
    )

    -- O antigo visual tinha sombras globais desligadas
    safeSet(Lighting, "GlobalShadows", false)

    -- Sombras duras
    safeSet(Lighting, "ShadowSoftness", 0)

    -- Sem neblina moderna exagerada
    safeSet(Lighting, "FogStart", 100000)
    safeSet(Lighting, "FogEnd", 100000)

    -- Dia neutro
    safeSet(Lighting, "ClockTime", 14)

    safeSet(Lighting, "ExposureCompensation", 0)
end

--============================================================--
-- EFEITOS MODERNOS
--============================================================--

local function applyClassicEffects()

    for _, object in ipairs(Lighting:GetChildren()) do

        if object:IsA("PostEffect") then

            if EffectBackup[object] == nil then
                local ok, enabled = pcall(function()
                    return object.Enabled
                end)

                if ok then
                    EffectBackup[object] = enabled
                end
            end

            if object:IsA("BloomEffect")
            or object:IsA("ColorCorrectionEffect")
            or object:IsA("SunRaysEffect")
            or object:IsA("DepthOfFieldEffect")
            or object:IsA("BlurEffect") then

                safeSet(object, "Enabled", false)

            end
        end

        if object:IsA("Atmosphere") then

            if EffectBackup[object] == nil then
                EffectBackup[object] = true
            end

            safeSet(object, "Enabled", false)
        end
    end
end

--============================================================--
-- SKYBOX HISTÓRICO 2005-2008
--============================================================--

local function removeClassicSky()

    if ClassicSkyObject and ClassicSkyObject.Parent then
        pcall(function()
            ClassicSkyObject:Destroy()
        end)
    end

    ClassicSkyObject = nil
end

local function loadClassicSky()

    if not Enabled or not CONFIG.ClassicSky then
        return
    end

    -- Evita duplicação
    removeClassicSky()

    -- Salva o sky original uma vez
    if not OriginalSky then

        local currentSky = Lighting:FindFirstChildOfClass("Sky")

        if currentSky then
            pcall(function()
                OriginalSky = currentSky:Clone()
            end)
        end
    end

    -- Remove céu atual
    local currentSky = Lighting:FindFirstChildOfClass("Sky")

    if currentSky then
        pcall(function()
            currentSky:Destroy()
        end)
    end

    -- Asset do Creator Store:
    -- "Old ROBLOX Skybox (better textures)"
    -- 2005-2008
    local ok, objects = pcall(function()
        return game:GetObjects("rbxassetid://672859297")
    end)

    if not ok or not objects then
        warn("Não foi possível carregar o skybox clássico.")
        return
    end

    local foundSky = nil

    -- Procura Sky dentro do asset
    for _, object in ipairs(objects) do

        if object:IsA("Sky") then
            foundSky = object
            break
        end

        local descendant = object:FindFirstChildWhichIsA(
            "Sky",
            true
        )

        if descendant then
            foundSky = descendant
            break
        end
    end

    if foundSky then

        local clone = foundSky:Clone()
        clone.Name = "Classic2008Sky"
        clone.Parent = Lighting

        ClassicSkyObject = clone

        -- Configurações celestes discretas
        safeSet(clone, "StarCount", 0)
        safeSet(clone, "CelestialBodiesShown", true)
        safeSet(clone, "SunAngularSize", 11)
        safeSet(clone, "MoonAngularSize", 0)

        print("✓ Skybox clássico 2005-2008 carregado.")

    else

        warn("O asset não contém um objeto Sky utilizável.")

    end

    -- Destrói containers temporários
    for _, object in ipairs(objects) do

        if object ~= foundSky
        and object.Parent == nil then

            pcall(function()
                object:Destroy()
            end)
        end
    end
end

--============================================================--
-- BACKUP DAS PARTES
--============================================================--

local function backupPart(part)

    if PartBackup[part] then
        return
    end

    if not part:IsA("BasePart") then
        return
    end

    local data = {}

    local okMaterial, material =
        pcall(function()
            return part.Material
        end)

    if okMaterial then
        data.Material = material
    end

    local okReflectance, reflectance =
        pcall(function()
            return part.Reflectance
        end)

    if okReflectance then
        data.Reflectance = reflectance
    end

    if part:IsA("Part") then

        local properties = {
            "TopSurface",
            "BottomSurface",
            "LeftSurface",
            "RightSurface",
            "FrontSurface",
            "BackSurface",
        }

        for _, property in ipairs(properties) do

            local ok, value =
                pcall(function()
                    return part[property]
                end)

            if ok then
                data[property] = value
            end
        end
    end

    PartBackup[part] = data
end

--============================================================--
-- MATERIAIS / SUPERFÍCIES CLÁSSICAS
--============================================================--

local function applyClassicPart(part)

    if not Enabled then
        return
    end

    if not part:IsA("BasePart") then
        return
    end

    backupPart(part)

    -- O Roblox antigo não tinha o conjunto moderno
    -- de materiais que existe hoje; Plastic é a aproximação.
    if CONFIG.ClassicMaterials then

        safeSet(
            part,
            "Material",
            Enum.Material.Plastic
        )

        safeSet(part, "Reflectance", 0)
    end

    -- Superfícies clássicas.
    -- Somente Parts normais possuem essas superfícies.
    if CONFIG.ClassicSurfaces and part:IsA("Part") then

        safeSet(
            part,
            "TopSurface",
            Enum.SurfaceType.Studs
        )

        safeSet(
            part,
            "BottomSurface",
            Enum.SurfaceType.Inlet
        )

        -- Laterais lisas, como nos builds antigos.
        safeSet(
            part,
            "LeftSurface",
            Enum.SurfaceType.Smooth
        )

        safeSet(
            part,
            "RightSurface",
            Enum.SurfaceType.Smooth
        )

        safeSet(
            part,
            "FrontSurface",
            Enum.SurfaceType.Smooth
        )

        safeSet(
            part,
            "BackSurface",
            Enum.SurfaceType.Smooth
        )
    end
end

local function applyClassicMaterials()

    if not Enabled then
        return
    end

    for _, object in ipairs(Workspace:GetDescendants()) do
        applyClassicPart(object)
    end
end

--============================================================--
-- ÁGUA
--============================================================--

local function applyClassicWater()

    if not Enabled or not CONFIG.ClassicWater then
        return
    end

    local terrain = Workspace:FindFirstChildOfClass("Terrain")

    if not terrain then
        return
    end

    safeSet(terrain, "WaterReflectance", 0)
    safeSet(terrain, "WaterWaveSize", 0)
    safeSet(terrain, "WaterWaveSpeed", 0)
    safeSet(terrain, "WaterTransparency", 0.35)
end

--============================================================--
-- APLICAÇÃO COMPLETA
--============================================================--

local function ApplyClassic()

    if not Enabled then
        return
    end

    applyClassicLighting()
    applyClassicEffects()
    loadClassicSky()
    applyClassicMaterials()
    applyClassicWater()

    print("======================================")
    print(" ROBLOX CLASSIC 2008")
    print(" Visual clássico ativado")
    print("======================================")
end

--============================================================--
-- RESTAURAR
--============================================================--

local function RestoreOriginal()

    Enabled = false

    -- Iluminação
    for property, value in pairs(LightingBackup) do
        safeSet(Lighting, property, value)
    end

    -- Efeitos
    for object, value in pairs(EffectBackup) do

        if object and object.Parent then
            safeSet(object, "Enabled", value)
        end
    end

    -- Sky clássico
    removeClassicSky()

    local currentSky = Lighting:FindFirstChildOfClass("Sky")

    if currentSky then
        pcall(function()
            currentSky:Destroy()
        end)
    end

    if OriginalSky then

        pcall(function()
            OriginalSky:Clone().Parent = Lighting
        end)
    end

    -- Partes
    for part, data in pairs(PartBackup) do

        if part and part.Parent then

            for property, value in pairs(data) do
                safeSet(part, property, value)
            end

        end
    end

    print("✓ Visual original restaurado.")
end

--============================================================--
-- GUI
--============================================================--

local function createGUI()

    if not CONFIG.ShowGUI then
        return
    end

    local ParentGui = getParentGui()

    local old = ParentGui:FindFirstChild(
        "Classic2008Interface"
    )

    if old then
        old:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Classic2008Interface"
    ScreenGui.ResetOnSpawn = false

    pcall(function()
        ScreenGui.IgnoreGuiInset = true
    end)

    ScreenGui.Parent = ParentGui

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 245, 0, 185)
    Main.Position = UDim2.new(0, 15, 0.5, -92)
    Main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    Main.BorderSizePixel = 2
    Main.Parent = ScreenGui

    local Title = Instance.new("TextLabel")
    Title.Size = UDim2.new(1, 0, 0, 38)
    Title.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    Title.Text = "ROBLOX CLASSIC 2008"
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 17
    Title.Font = Enum.Font.SourceSansBold
    Title.Parent = Main

    local Status = Instance.new("TextLabel")
    Status.Size = UDim2.new(1, -20, 0, 30)
    Status.Position = UDim2.new(0, 10, 0, 44)
    Status.BackgroundTransparency = 1
    Status.Text = "● VISUAL ATIVADO"
    Status.TextColor3 = Color3.fromRGB(80, 255, 100)
    Status.TextSize = 15
    Status.Font = Enum.Font.SourceSansBold
    Status.Parent = Main

    local Toggle = Instance.new("TextButton")
    Toggle.Size = UDim2.new(1, -20, 0, 42)
    Toggle.Position = UDim2.new(0, 10, 0, 78)
    Toggle.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
    Toggle.Text = "DESATIVAR"
    Toggle.TextColor3 = Color3.fromRGB(255, 255, 255)
    Toggle.TextSize = 16
    Toggle.Font = Enum.Font.SourceSansBold
    Toggle.Parent = Main

    local Reapply = Instance.new("TextButton")
    Reapply.Size = UDim2.new(1, -20, 0, 35)
    Reapply.Position = UDim2.new(0, 10, 0, 126)
    Reapply.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Reapply.Text = "REAPLICAR VISUAL"
    Reapply.TextColor3 = Color3.fromRGB(255, 255, 255)
    Reapply.TextSize = 14
    Reapply.Font = Enum.Font.SourceSansBold
    Reapply.Parent = Main

    local Footer = Instance.new("TextLabel")
    Footer.Size = UDim2.new(1, -20, 0, 20)
    Footer.Position = UDim2.new(0, 10, 1, -22)
    Footer.BackgroundTransparency = 1
    Footer.Text = "Classic Visual • Client Side"
    Footer.TextColor3 = Color3.fromRGB(170, 170, 170)
    Footer.TextSize = 11
    Footer.Font = Enum.Font.SourceSans
    Footer.Parent = Main

    Toggle.MouseButton1Click:Connect(function()

        if Enabled then

            RestoreOriginal()

            Status.Text = "● VISUAL DESATIVADO"
            Status.TextColor3 =
                Color3.fromRGB(255, 180, 80)

            Toggle.Text = "ATIVAR"

        else

            Enabled = true

            ApplyClassic()

            Status.Text = "● VISUAL ATIVADO"
            Status.TextColor3 =
                Color3.fromRGB(80, 255, 100)

            Toggle.Text = "DESATIVAR"
        end
    end)

    Reapply.MouseButton1Click:Connect(function()

        if Enabled then
            ApplyClassic()
            Status.Text = "● VISUAL REAPLICADO"
        end
    end)
end

--============================================================--
-- AUTO REAPLICAÇÃO
--============================================================--

if CONFIG.AutoReapply then

    Workspace.DescendantAdded:Connect(function(object)

        if not Enabled then
            return
        end

        task.defer(function()

            if object:IsA("BasePart") then
                applyClassicPart(object)
            end

        end)
    end)

    Lighting.ChildAdded:Connect(function(object)

        if not Enabled then
            return
        end

        task.defer(function()

            if object:IsA("PostEffect")
            or object:IsA("Atmosphere") then

                applyClassicEffects()
            end

        end)
    end)

end

--============================================================--
-- INICIAR
--============================================================--

ApplyClassic()
createGUI()

print("")
print("============================================")
print("     ROBLOX CLASSIC 2008 VISUAL")
print("============================================")
print("✓ Compatibility")
print("✓ Ambient 128")
print("✓ Brightness 1")
print("✓ GlobalShadows OFF")
print("✓ ShadowSoftness 0")
print("✓ Plastic clássico")
print("✓ Studs / Inlets")
print("✓ Pós-processamento moderno OFF")
print("✓ Skybox 2005-2008")
print("✓ Água simplificada")
print("============================================")
