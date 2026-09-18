--========================================================--
--              ROBLOX CLASSIC 2008 VISUAL               --
--                    CLIENT SIDE                        --
--========================================================--

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local Player = Players.LocalPlayer

--========================================================--
-- CONFIGURAÇÃO
--========================================================--

local CONFIG = {
    ClassicMaterials = true,
    ClassicStuds = true,
    ClassicLighting = true,
    RemoveModernEffects = true,
    ClassicWater = true,
    AutoReapply = true,
}

local enabled = true

--========================================================--
-- ILUMINAÇÃO CLÁSSICA
--========================================================--

local function applyLighting()

    if not enabled then
        return
    end

    pcall(function()
        Lighting.Technology = Enum.Technology.Compatibility
    end)

    Lighting.Brightness = 1

    Lighting.Ambient =
        Color3.fromRGB(128, 128, 128)

    Lighting.OutdoorAmbient =
        Color3.fromRGB(128, 128, 128)

    Lighting.ColorShift_Top =
        Color3.fromRGB(0, 0, 0)

    Lighting.ColorShift_Bottom =
        Color3.fromRGB(0, 0, 0)

    Lighting.GlobalShadows = false

    pcall(function()
        Lighting.ShadowSoftness = 0
    end)

    pcall(function()
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ExposureCompensation = 0
    end)

    -- Ambiente simples, sem neblina moderna
    Lighting.FogStart = 100000
    Lighting.FogEnd = 100000
end

--========================================================--
-- REMOVER PÓS-PROCESSAMENTO MODERNO
--========================================================--

local function removeModernEffects()

    if not CONFIG.RemoveModernEffects then
        return
    end

    for _, object in ipairs(Lighting:GetChildren()) do

        if object:IsA("BloomEffect")
        or object:IsA("ColorCorrectionEffect")
        or object:IsA("SunRaysEffect")
        or object:IsA("DepthOfFieldEffect")
        or object:IsA("Atmosphere")
        or object:IsA("BlurEffect") then

            pcall(function()
                object.Enabled = false
            end)

        end
    end
end

--========================================================--
-- MATERIAIS CLÁSSICOS
--========================================================--

local function applyClassicPart(part)

    if not enabled then
        return
    end

    if not part:IsA("BasePart") then
        return
    end

    -- MeshParts podem possuir textura própria.
    -- Não destruímos a aparência deles.
    if part:IsA("Part") then

        if CONFIG.ClassicMaterials then
            pcall(function()
                part.Material = Enum.Material.Plastic
                part.Reflectance = 0
            end)
        end

        -- Studs em cima / Inlets embaixo,
        -- característicos das construções antigas.
        if CONFIG.ClassicStuds then
            pcall(function()
                part.TopSurface = Enum.SurfaceType.Studs
                part.BottomSurface = Enum.SurfaceType.Inlet

                part.LeftSurface = Enum.SurfaceType.Smooth
                part.RightSurface = Enum.SurfaceType.Smooth
                part.FrontSurface = Enum.SurfaceType.Smooth
                part.BackSurface = Enum.SurfaceType.Smooth
            end)
        end

    elseif part:IsA("WedgePart")
    or part:IsA("CornerWedgePart")
    or part:IsA("TrussPart") then

        if CONFIG.ClassicMaterials then
            pcall(function()
                part.Material = Enum.Material.Plastic
                part.Reflectance = 0
            end)
        end

    elseif part:IsA("MeshPart") then

        -- Apenas removemos reflexo moderno.
        pcall(function()
            part.Reflectance = 0
        end)

    end
end

local function applyClassicMaterials()

    if not CONFIG.ClassicMaterials
    and not CONFIG.ClassicStuds then
        return
    end

    for _, object in ipairs(Workspace:GetDescendants()) do
        applyClassicPart(object)
    end
end

--========================================================--
-- ÁGUA MAIS SIMPLES
--========================================================--

local function applyClassicWater()

    if not CONFIG.ClassicWater then
        return
    end

    local terrain = Workspace:FindFirstChildOfClass("Terrain")

    if not terrain then
        return
    end

    pcall(function()

        terrain.WaterReflectance = 0
        terrain.WaterTransparency = 0.35
        terrain.WaterWaveSize = 0
        terrain.WaterWaveSpeed = 0

    end)
end

--========================================================--
-- SKY CLÁSSICO
--========================================================--

local function applyClassicSky()

    if not enabled then
        return
    end

    -- Primeiro procuramos um Sky já existente.
    local sky = Lighting:FindFirstChildOfClass("Sky")

    if sky then

        pcall(function()
            sky.StarCount = 0
            sky.CelestialBodiesShown = true
            sky.SunAngularSize = 21
        end)

        return
    end

    -- Não colocamos IDs de textura inventados.
    -- Se o jogo já fornecer um skybox clássico,
    -- ele será preservado.
end

--========================================================--
-- APLICAÇÃO GERAL
--========================================================--

local function ApplyClassic()

    applyLighting()
    removeModernEffects()
    applyClassicSky()
    applyClassicMaterials()
    applyClassicWater()

    print("✓ Roblox Classic 2008 aplicado")
end

--========================================================--
-- GUI
--========================================================--

local function createGUI()

    local playerGui = Player:WaitForChild("PlayerGui")

    local old = playerGui:FindFirstChild("Classic2008GUI")

    if old then
        old:Destroy()
    end

    local gui = Instance.new("ScreenGui")
    gui.Name = "Classic2008GUI"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 220, 0, 120)
    frame.Position = UDim2.new(0, 15, 0.5, -60)
    frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    frame.BorderSizePixel = 2
    frame.Parent = gui

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 35)
    title.BackgroundTransparency = 1
    title.Text = "ROBLOX CLASSIC 2008"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 16
    title.Font = Enum.Font.SourceSansBold
    title.Parent = frame

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, -20, 0, 25)
    status.Position = UDim2.new(0, 10, 0, 35)
    status.BackgroundTransparency = 1
    status.Text = "● Visual ativado"
    status.TextColor3 = Color3.fromRGB(100, 255, 100)
    status.TextSize = 14
    status.Font = Enum.Font.SourceSans
    status.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, -20, 0, 40)
    button.Position = UDim2.new(0, 10, 0, 70)
    button.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Text = "DESATIVAR"
    button.TextSize = 15
    button.Font = Enum.Font.SourceSansBold
    button.Parent = frame

    button.MouseButton1Click:Connect(function()

        enabled = not enabled

        if enabled then

            ApplyClassic()

            status.Text = "● Visual ativado"
            status.TextColor3 =
                Color3.fromRGB(100, 255, 100)

            button.Text = "DESATIVAR"

        else

            status.Text = "● Visual pausado"
            status.TextColor3 =
                Color3.fromRGB(255, 180, 100)

            button.Text = "ATIVAR"

        end
    end)
end

--========================================================--
-- EXECUTAR
--========================================================--

ApplyClassic()
createGUI()

--========================================================--
-- AUTO-REAPLICAÇÃO
--========================================================--

if CONFIG.AutoReapply then

    Lighting.ChildAdded:Connect(function(object)

        if not enabled then
            return
        end

        task.wait(0.2)

        if object:IsA("BloomEffect")
        or object:IsA("ColorCorrectionEffect")
        or object:IsA("SunRaysEffect")
        or object:IsA("DepthOfFieldEffect")
        or object:IsA("Atmosphere")
        or object:IsA("BlurEffect") then

            pcall(function()
                object.Enabled = false
            end)
        end
    end)

    Workspace.DescendantAdded:Connect(function(object)

        if not enabled then
            return
        end

        if object:IsA("BasePart") then
            task.wait()
            applyClassicPart(object)
        end
    end)

end

print("======================================")
print("   ROBLOX CLASSIC 2008 VISUAL")
print("   Status: ATIVADO")
print("======================================")
