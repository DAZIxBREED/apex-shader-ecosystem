#ifndef APEX_AVATAR_SURFACE_INCLUDED
#define APEX_AVATAR_SURFACE_INCLUDED

inline ApexSurfaceData ApexAvatarBuildSurface(
    ApexVaryings i,
    sampler2D baseMap,
    float4 baseMapST,
    half4 baseColor,
    sampler2D normalMap,
    float4 normalMapST,
    half normalScale,
    sampler2D maskMap,
    float4 maskMapST,
    half metallic,
    half occlusionStrength,
    half smoothness,
    half4 emissionColor)
{
    return ApexBuildPackedSurface(
        i,
        baseMap,
        baseMapST,
        baseColor,
        normalMap,
        normalMapST,
        normalScale,
        maskMap,
        maskMapST,
        metallic,
        occlusionStrength,
        smoothness,
        emissionColor
    );
}

inline half3 ApexAvatarBaseLighting(
    ApexSurfaceData surface,
    ApexLightingData lighting,
    half wrapAmount,
    half3 wrapColor)
{
    half3 physicallyBased = ApexEvaluateBaseLighting(surface, lighting);
    half3 wrapped = ApexEvaluateWrappedDiffuse(surface, lighting, wrapAmount, wrapColor);
    return lerp(physicallyBased, physicallyBased + wrapped * 0.25h, saturate(wrapAmount));
}

inline half3 ApexAvatarFinish(
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
    color = ApexSpectraTint(color, spectraAmount, spectraGroup, spectraBandWeights);
    color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), surface.mask * spectraAmount, spectraGroup, spectraBandWeights);
    return color;
}

#endif
