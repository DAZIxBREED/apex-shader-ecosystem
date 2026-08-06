#ifndef APEX_CORE_LIGHTING_INCLUDED
#define APEX_CORE_LIGHTING_INCLUDED

inline half3 ApexSampleBakedGI(ApexVaryings i, half3 normalWS)
{
#if defined(LIGHTMAP_ON)
    return max(DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1)), 0.0h);
#else
    return max(ShadeSH9(half4(normalWS, 1.0h)), 0.0h);
#endif
}

inline ApexLightingData ApexBuildLight(
    ApexVaryings i,
    ApexSurfaceData surface,
    half attenuation,
    half includeBakedGI)
{
    ApexLightingData lighting;
    lighting.lightDir = ApexSafeNormalize(UnityWorldSpaceLightDir(i.worldPos));
    lighting.viewDir = ApexGetViewDirection(i);
    lighting.halfDir = ApexSafeNormalize(lighting.lightDir + lighting.viewDir);
    lighting.lightColor = _LightColor0.rgb;
    lighting.bakedGI = ApexSampleBakedGI(i, surface.normalWS) * includeBakedGI;
    lighting.attenuation = attenuation;
    return lighting;
}

inline half3 ApexEvaluateDirect(ApexSurfaceData surface, ApexLightingData lighting)
{
    half ndotl = saturate(dot(surface.normalWS, lighting.lightDir));
    half ndoth = saturate(dot(surface.normalWS, lighting.halfDir));
    half vdoth = saturate(dot(lighting.viewDir, lighting.halfDir));

    half3 diffuseColor = surface.albedo * (1.0h - surface.metallic);
    half3 f0 = lerp(half3(0.04h, 0.04h, 0.04h), surface.albedo, surface.metallic);
    half fresnel = pow(1.0h - vdoth, 5.0h);
    half3 fresnelColor = f0 + (1.0h - f0) * fresnel;

    half specularPower = exp2(1.0h + surface.smoothness * 10.0h);
    half specularNormalization = (specularPower + 8.0h) * 0.125h;
    half specularTerm = pow(ndoth, specularPower) * specularNormalization;

    half3 diffuse = diffuseColor * APEX_INV_PI;
    half3 specular = fresnelColor * specularTerm;
    half3 radiance = lighting.lightColor * lighting.attenuation * ndotl;
    return (diffuse + specular) * radiance;
}

inline half3 ApexEvaluateAmbient(ApexSurfaceData surface, ApexLightingData lighting)
{
    half metallicAmbientReduction = lerp(1.0h, 0.35h, surface.metallic);
    return surface.albedo * lighting.bakedGI * surface.occlusion * metallicAmbientReduction;
}

inline half3 ApexEvaluateBaseLighting(ApexSurfaceData surface, ApexLightingData lighting)
{
    return ApexEvaluateAmbient(surface, lighting) + ApexEvaluateDirect(surface, lighting);
}

inline half3 ApexEvaluateAddLighting(ApexSurfaceData surface, ApexLightingData lighting)
{
    return ApexEvaluateDirect(surface, lighting);
}

inline half3 ApexEvaluateWrappedDiffuse(
    ApexSurfaceData surface,
    ApexLightingData lighting,
    half wrapAmount,
    half3 wrapColor)
{
    half wrappedNdotL = saturate((dot(surface.normalWS, lighting.lightDir) + wrapAmount) / (1.0h + wrapAmount));
    half3 direct = surface.albedo * lighting.lightColor * lighting.attenuation * wrappedNdotL;
    return direct * lerp(half3(1.0h, 1.0h, 1.0h), wrapColor, wrapAmount);
}

inline half3 ApexEvaluateRim(
    ApexSurfaceData surface,
    ApexLightingData lighting,
    half3 rimColor,
    half rimPower,
    half rimIntensity)
{
    half rim = ApexFresnel(surface.normalWS, lighting.viewDir, rimPower);
    return rimColor * rim * rimIntensity * surface.occlusion;
}

inline half3 ApexEvaluateToon(
    ApexSurfaceData surface,
    ApexLightingData lighting,
    half bands,
    half shadowThreshold,
    half shadowSoftness,
    half3 shadowColor,
    half specularSize,
    half specularIntensity)
{
    half ndotl = saturate(dot(surface.normalWS, lighting.lightDir));
    half softened = smoothstep(
        shadowThreshold - shadowSoftness,
        shadowThreshold + shadowSoftness,
        ndotl
    );
    half bandCount = max(floor(bands + 0.5h), 2.0h);
    half bandSteps = bandCount - 1.0h;
    half quantized = floor(saturate(softened) * bandSteps + 0.5h) / bandSteps;
    half3 rampColor = lerp(shadowColor, half3(1.0h, 1.0h, 1.0h), quantized);

    half ndoth = saturate(dot(surface.normalWS, lighting.halfDir));
    half toonSpecular = smoothstep(1.0h - specularSize, 1.0h, ndoth) * specularIntensity;

    half3 direct = surface.albedo * rampColor * lighting.lightColor * lighting.attenuation;
    half3 ambient = surface.albedo * lighting.bakedGI * surface.occlusion;
    return direct + ambient + lighting.lightColor * lighting.attenuation * toonSpecular;
}

#endif
