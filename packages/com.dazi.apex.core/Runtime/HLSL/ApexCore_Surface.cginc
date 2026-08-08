#ifndef APEX_CORE_SURFACE_INCLUDED
#define APEX_CORE_SURFACE_INCLUDED

#include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"

#include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Packing.cginc"

inline ApexSurfaceData ApexInitializeSurface()
{
    ApexSurfaceData surface;
    surface.albedo = half3(1.0h, 1.0h, 1.0h);
    surface.normalWS = half3(0.0h, 1.0h, 0.0h);
    surface.emission = half3(0.0h, 0.0h, 0.0h);
    surface.metallic = 0.0h;
    surface.smoothness = 0.5h;
    surface.occlusion = 1.0h;
    surface.alpha = 1.0h;
    surface.mask = 0.0h;
    return surface;
}

inline ApexSurfaceData ApexBuildPackedSurface(
    ApexVaryings i,
    sampler2D baseMap,
    float4 baseMapST,
    half4 baseColor,
    sampler2D normalMap,
    float4 normalMapST,
    half normalScale,
    sampler2D maskMap,
    float4 maskMapST,
    half metallicScale,
    half occlusionStrength,
    half smoothnessScale,
    half4 emissionColor)
{
    ApexSurfaceData surface = ApexInitializeSurface();
    half4 baseSample = tex2D(baseMap, i.uv0 * baseMapST.xy + baseMapST.zw);
    half4 maskSample = tex2D(maskMap, i.uv0 * maskMapST.xy + maskMapST.zw);
    ApexPackedPBR packed = ApexDecodePackedPBR(
        maskSample,
        metallicScale,
        occlusionStrength,
        smoothnessScale
    );

    half3 normalTS = ApexUnpackNormalScale(
        normalMap,
        i.uv0 * normalMapST.xy + normalMapST.zw,
        normalScale
    );

    surface.albedo = baseSample.rgb * baseColor.rgb * i.vertexColor.rgb;
    surface.normalWS = ApexTangentToWorld(normalTS, i);
    surface.emission = emissionColor.rgb * emissionColor.a;
    surface.metallic = packed.metallic;
    surface.smoothness = packed.smoothness;
    surface.occlusion = packed.occlusion;
    surface.alpha = baseSample.a * baseColor.a * i.vertexColor.a;
    surface.mask = packed.mask;
    return surface;
}

inline void ApexApplyAlphaClip(half alpha, half cutoff, half enabled)
{
    half clipValue = lerp(1.0h, alpha - cutoff, step(0.5h, enabled));
    clip(clipValue);
}

#endif
