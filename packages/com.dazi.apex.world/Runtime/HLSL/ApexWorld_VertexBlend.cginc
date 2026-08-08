#ifndef APEX_WORLD_VERTEX_BLEND_INCLUDED
#define APEX_WORLD_VERTEX_BLEND_INCLUDED

inline half ApexVertexBlendWeight(half vertexWeight, half bias, half contrast)
{
    half shifted = saturate(vertexWeight + bias);
    return saturate((shifted - 0.5h) * max(contrast, 0.01h) + 0.5h);
}

inline ApexSurfaceData ApexWorldBuildVertexBlendSurface(
    ApexVaryings i,
    sampler2D layerABase, float4 layerABaseST, half4 layerAColor,
    sampler2D layerANormal, float4 layerANormalST,
    sampler2D layerAMask, float4 layerAMaskST,
    sampler2D layerBBase, float4 layerBBaseST, half4 layerBColor,
    sampler2D layerBNormal, float4 layerBNormalST,
    sampler2D layerBMask, float4 layerBMaskST,
    half normalScale,
    half layerAMetallic, half layerASmoothness,
    half layerBMetallic, half layerBSmoothness,
    half occlusionStrength,
    half blendBias, half blendContrast,
    half4 emissionColor)
{
    ApexSurfaceData surface = ApexInitializeSurface();
    half blend = ApexVertexBlendWeight(i.vertexColor.r, blendBias, blendContrast);

    half4 baseA = tex2D(layerABase, i.uv0 * layerABaseST.xy + layerABaseST.zw) * layerAColor;
    half4 baseB = tex2D(layerBBase, i.uv0 * layerBBaseST.xy + layerBBaseST.zw) * layerBColor;
    half4 maskA = tex2D(layerAMask, i.uv0 * layerAMaskST.xy + layerAMaskST.zw);
    half4 maskB = tex2D(layerBMask, i.uv0 * layerBMaskST.xy + layerBMaskST.zw);
    ApexPackedPBR packedA = ApexDecodePackedPBR(maskA, layerAMetallic, occlusionStrength, layerASmoothness);
    ApexPackedPBR packedB = ApexDecodePackedPBR(maskB, layerBMetallic, occlusionStrength, layerBSmoothness);

    half3 normalA = ApexUnpackNormalScale(layerANormal, i.uv0 * layerANormalST.xy + layerANormalST.zw, normalScale);
    half3 normalB = ApexUnpackNormalScale(layerBNormal, i.uv0 * layerBNormalST.xy + layerBNormalST.zw, normalScale);
    half3 normalTS = ApexSafeNormalize(lerp(normalA, normalB, blend));

    surface.albedo = lerp(baseA.rgb, baseB.rgb, blend);
    surface.normalWS = ApexTangentToWorld(normalTS, i);
    surface.emission = emissionColor.rgb * emissionColor.a * lerp(packedA.mask, packedB.mask, blend);
    surface.metallic = lerp(packedA.metallic, packedB.metallic, blend);
    surface.smoothness = lerp(packedA.smoothness, packedB.smoothness, blend);
    surface.occlusion = lerp(packedA.occlusion, packedB.occlusion, blend);
    surface.alpha = lerp(baseA.a, baseB.a, blend) * i.vertexColor.a;
    surface.mask = lerp(packedA.mask, packedB.mask, blend);
    return surface;
}

#endif
