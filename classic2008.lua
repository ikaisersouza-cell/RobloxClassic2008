```lua
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    return
end

local CONFIG = {
    ClassicLighting = true,
    ClassicMaterials = true,
    ClassicSurfaces = true,
    ClassicWater = true,
    ClassicSky = true,
    AutoReapply = true,
}

local Enabled = true

local LightingBackup = {}
local PartBackup = {}
local EffectBackup = {}
local OriginalSky = nil
local ClassicSkyObject = nil

local function safeSet(object, property, value)
    pcall(function()
        object[property] = value
    end)
end

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

local function applyClassicLighting()

    if not Enabled or not CONFIG.ClassicLighting then
        return
    end

    backupLighting()

    safeSet(Lighting, "Technology", Enum.Technology.Compatibility)
    safeSet(Lighting, "Brightness", 1)
    safeSet(Lighting, "Ambient", Color3.fromRGB(128, 128, 128))
    safeSet(Lighting, "OutdoorAmbient", Color3.fromRGB(128, 128, 128))
    safeSet(Lighting, "ColorShift_Top", Color3.fromRGB(0, 0, 0))
    safeSet(Lighting, "ColorShift_Bottom", Color3.fromRGB(0, 0, 0))
    safeSet(Lighting, "GlobalShadows", false)
    safeSet(Lighting, "ShadowSoftness", 0)
    safeSet(Lighting, "FogStart", 100000)
    safeSet(Lighting, "FogEnd", 100000)
    safeSet(Lighting, "ClockTime", 14)
    safeSet(Lighting, "ExposureCompensation", 0)
end

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

    removeClassicSky()

    if not OriginalSky then

        local currentSky = Lighting:FindFirstChildOfClass("Sky")

        if currentSky then
            pcall(function()
                OriginalSky = currentSky:Clone()
            end)
        end
    end

    local currentSky = Lighting:FindFirstChildOfClass("Sky")

    if currentSky then
        pcall(function()
            currentSky:Destroy()
        end)
    end

    local ok, objects = pcall(function()
        return game:GetObjects("rbxassetid://672859297")
    end)

    if not ok or not objects then
        warn("Não foi possível carregar o skybox clássico.")
        return
    end

    local foundSky = nil

    for _, object in ipairs(objects) do

        if object:IsA("Sky") then
            foundSky = object
            break
        end

        local descendant = object:FindFirstChildWhichIsA("Sky", true)

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

        safeSet(clone, "StarCount", 0)
        safeSet(clone, "CelestialBodiesShown", true)
        safeSet(clone, "SunAngularSize", 11)
        safeSet(clone, "MoonAngularSize", 0)

    else

        warn("O asset não contém um objeto Sky utilizável.")

    end

    for _, object in ipairs(objects) do

        if object ~= foundSky
        and object.Parent == nil then

            pcall(function()
                object:Destroy()
            end)
        end
    end
end

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

local function applyClassicPart(part)

    if not Enabled then
        return
    end

    if not part:IsA("BasePart") then
        return
    end

    backupPart(part)

    if CONFIG.ClassicMaterials then

        safeSet(
            part,
            "Material",
            Enum.Material.Plastic
        )

        safeSet(part, "Reflectance", 0)
    end

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

local function ApplyClassic()

    if not Enabled then
        return
    end

    applyClassicLighting()
    applyClassicEffects()
    loadClassicSky()
    applyClassicMaterials()
    applyClassicWater()
end

local function RestoreOriginal()

    Enabled = false

    for property, value in pairs(LightingBackup) do
        safeSet(Lighting, property, value)
    end

    for object, value in pairs(EffectBackup) do

        if object and object.Parent then
            safeSet(object, "Enabled", value)
        end
    end

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

    for part, data in pairs(PartBackup) do

        if part and part.Parent then

            for property, value in pairs(data) do
                safeSet(part, property, value)
            end

        end
    end
end

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

UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if gameProcessed then
        return
    end

    if input.KeyCode == Enum.KeyCode.P then

        if Enabled then
            RestoreOriginal()
        else
            Enabled = true
            ApplyClassic()
        end

    end
end)

ApplyClassic()
```
