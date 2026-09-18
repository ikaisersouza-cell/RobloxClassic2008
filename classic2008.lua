local Lighting = game:GetService("Lighting")

-- Iluminação clássica
pcall(function()
    Lighting.Technology = Enum.Technology.Compatibility
end)

Lighting.Brightness = 1
Lighting.Ambient = Color3.fromRGB(128,128,128)
Lighting.OutdoorAmbient = Color3.fromRGB(128,128,128)
Lighting.GlobalShadows = false

pcall(function()
    Lighting.ShadowSoftness = 0
end)

-- Remover efeitos modernos
for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("BloomEffect")
    or v:IsA("ColorCorrectionEffect")
    or v:IsA("SunRaysEffect")
    or v:IsA("DepthOfFieldEffect")
    or v:IsA("Atmosphere") then
        v:Destroy()
    end
end

-- Peças com aparência simples
for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("BasePart") then
        pcall(function()
            v.Material = Enum.Material.Plastic
            v.Reflectance = 0
        end)
    end
end

print("Roblox Classic 2008 ativado!")
