#ifndef APEX_TOON_SURFACE_INCLUDED
#define APEX_TOON_SURFACE_INCLUDED

inline ApexSurfaceData ApexToonBuildSurface(
    ApexVaryings i,
    sampler2D baseMap,
    float4 baseMapST,
    half4 baseColor,
    sampler2D normalMap,
    float4 normalMapST,
    half normalScale,
    sampler2D maskMap,
    float4 maskMapST,
    half occlusionStrength,
    half4 emissionColor)
{
    ApexSurfaceData surface = ApexBuildPackedSurface(
        i,
        baseMap,
        baseMapST,
        baseColor,
        normalMap,
        normalMapST,
        normalScale,
        maskMap,
        maskMapST,
        0.0h,
        occlusionStrength,
        0.25h,
        emissionColor
    );
    surface.metallic = 0.0h;
    return surface;
}

inline half3 ApexToonFinish(
    half3 color,
    ApexSurfaceData surface,
    ApexLightingData lighting,
    half3 rimColor,
    half rimPower,
    half rimIntensity,
    half spectraAmount,
    half spectraGroup,
    half4 spectraBandWeights)
{
    color += ApexEvaluateRim(surface, lighting, rimColor, rimPower, rimIntensity);
    color += surface.emission;
    color = ApexSpectraTint(color, spectraAmount, spectraGroup, spectraBandWeights);
    color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), surface.mask * spectraAmount, spectraGroup, spectraBandWeights);
    return color;
}

#endif
