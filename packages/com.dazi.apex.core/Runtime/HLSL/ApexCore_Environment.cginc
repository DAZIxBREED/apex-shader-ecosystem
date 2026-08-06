#ifndef APEX_CORE_ENVIRONMENT_INCLUDED
#define APEX_CORE_ENVIRONMENT_INCLUDED

#include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Quality.cginc"
#include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"

#include "UnityStandardUtils.cginc"

inline half ApexPerceptualRoughnessToMip(half perceptualRoughness)
{
    perceptualRoughness = saturate(perceptualRoughness);
    // Matches Unity's common non-linear roughness-to-mip approximation closely
    // while remaining independent of the Standard shader implementation.
    half remapped = perceptualRoughness * (1.7h - 0.7h * perceptualRoughness);
    return remapped * 6.0h;
}

inline half3 ApexSampleEnvironmentReflection(
    ApexSurfaceData surface,
    ApexLightingData lighting,
    float3 worldPosition,
    half environmentStrength)
{
#if APEX_ENVIRONMENT_REFLECTIONS
    half3 reflectionDirection = reflect(-lighting.viewDir, surface.normalWS);
#if defined(UNITY_SPECCUBE_BOX_PROJECTION)
    reflectionDirection = BoxProjectedCubemapDirection(
        reflectionDirection,
        worldPosition,
        unity_SpecCube0_ProbePosition,
        unity_SpecCube0_BoxMin,
        unity_SpecCube0_BoxMax
    );
#endif

    half perceptualRoughness = 1.0h - surface.smoothness;
    half mip = ApexPerceptualRoughnessToMip(perceptualRoughness);
    half4 encoded = UNITY_SAMPLE_TEXCUBE_LOD(unity_SpecCube0, reflectionDirection, mip);
    half3 environment = DecodeHDR(encoded, unity_SpecCube0_HDR);

    half3 f0 = lerp(half3(0.04h, 0.04h, 0.04h), surface.albedo, surface.metallic);
    half fresnel = pow(1.0h - saturate(dot(surface.normalWS, lighting.viewDir)), 5.0h);
    half3 fresnelColor = f0 + (1.0h - f0) * fresnel;
    half horizon = saturate(1.0h + dot(reflectionDirection, surface.normalWS));
    half roughnessOcclusion = lerp(surface.occlusion, 1.0h, surface.smoothness * 0.35h);

#if APEX_HIGH_QUALITY_SPECULAR
    half energyCompensation = 1.0h + surface.metallic * surface.smoothness * 0.35h;
#else
    half energyCompensation = 1.0h;
#endif

    return environment * fresnelColor * horizon * roughnessOcclusion *
        saturate(environmentStrength) * energyCompensation;
#else
    return half3(0.0h, 0.0h, 0.0h);
#endif
}

#endif
