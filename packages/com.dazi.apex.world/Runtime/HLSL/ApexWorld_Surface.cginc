#ifndef APEX_WORLD_SURFACE_INCLUDED
#define APEX_WORLD_SURFACE_INCLUDED

inline ApexSurfaceData ApexWorldBuildSurface(
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
    half4 emissionColor,
    sampler2D detailMap,
    float4 detailMapST,
    half4 detailColor,
    half detailStrength)
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
        metallic,
        occlusionStrength,
        smoothness,
        emissionColor
    );

#if defined(_APEX_DETAIL)
    half3 detail = tex2D(detailMap, i.uv0 * detailMapST.xy + detailMapST.zw).rgb * detailColor.rgb;
    half3 doubledDetail = detail * 2.0h;
    surface.albedo *= lerp(half3(1.0h, 1.0h, 1.0h), doubledDetail, saturate(detailStrength));
#endif
    return surface;
}

inline half3 ApexWorldFinish(
    half3 color,
    ApexSurfaceData surface,
    half spectraAmount,
    half spectraGroup,
    half4 spectraBandWeights)
{
    color = ApexSpectraTint(color, spectraAmount, spectraGroup, spectraBandWeights);
    color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), surface.mask * spectraAmount, spectraGroup, spectraBandWeights);
    return color;
}

#endif
