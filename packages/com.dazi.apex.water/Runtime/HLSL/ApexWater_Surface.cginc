#ifndef APEX_WATER_SURFACE_INCLUDED
#define APEX_WATER_SURFACE_INCLUDED

inline ApexSurfaceData ApexWaterBuildSurface(
    ApexVaryings i,
    sampler2D baseMap,
    float4 baseMapST,
    half4 baseColor,
    sampler2D normalMap,
    float4 normalMapST,
    half normalScale,
    sampler2D maskMap,
    float4 maskMapST,
    half2 normalSpeedA,
    half2 normalSpeedB,
    half normalBlend,
    half3 shallowColor,
    half3 deepColor,
    half smoothness,
    half opacity)
{
    ApexSurfaceData surface = ApexInitializeSurface();
    half timeValue = (half)_Time.y * ApexPlatformAnimationScalar();
    half2 baseUV = i.uv0 * baseMapST.xy + baseMapST.zw;
    half2 normalUV = i.uv0 * normalMapST.xy + normalMapST.zw;

    half4 baseSample = tex2D(baseMap, baseUV);
    half4 maskSample = tex2D(maskMap, i.uv0 * maskMapST.xy + maskMapST.zw);
    half3 normalA = ApexUnpackNormalScale(normalMap, normalUV + normalSpeedA * timeValue, normalScale);
    half2 rotatedUV = ApexRotateUV(normalUV * 1.37h, 0.785398h, half2(0.5h, 0.5h));
    half3 normalB = ApexUnpackNormalScale(normalMap, rotatedUV + normalSpeedB * timeValue, normalScale);
    half3 blendedNormalTS = ApexSafeNormalize(half3(
        normalA.xy + normalB.xy * normalBlend,
        normalA.z * normalB.z
    ));

    half depthMask = saturate(maskSample.r);
    surface.albedo = baseSample.rgb * baseColor.rgb * lerp(shallowColor, deepColor, depthMask);
    surface.normalWS = ApexTangentToWorld(blendedNormalTS, i);
    surface.emission = half3(0.0h, 0.0h, 0.0h);
    surface.metallic = 0.0h;
    surface.smoothness = smoothness;
    surface.occlusion = 1.0h;
    surface.alpha = baseSample.a * baseColor.a * opacity * i.vertexColor.a;
    surface.mask = maskSample.b;
    return surface;
}

inline half3 ApexWaterFinish(
    half3 litColor,
    ApexSurfaceData surface,
    ApexVaryings i,
    half3 fresnelColor,
    half fresnelPower,
    half fresnelStrength,
    half3 foamColor,
    half foamStrength,
    half spectraAmount,
    half spectraGroup,
    half4 spectraBandWeights)
{
    half3 viewDirection = ApexGetViewDirection(i);
    half fresnel = ApexFresnel(surface.normalWS, viewDirection, fresnelPower) * fresnelStrength;
    half foam = saturate(surface.mask * foamStrength);
    half3 color = lerp(litColor, fresnelColor, saturate(fresnel));
    color += foamColor * foam;
    color = ApexSpectraTint(color, spectraAmount, spectraGroup, spectraBandWeights);
    color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), surface.mask * spectraAmount, spectraGroup, spectraBandWeights);
    return color;
}

#endif
