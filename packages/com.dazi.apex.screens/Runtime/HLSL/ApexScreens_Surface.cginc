#ifndef APEXSCREENS_SURFACE_INCLUDED
#define APEXSCREENS_SURFACE_INCLUDED

inline ApexSurfaceData ApexScreensBuildSurface(ApexVaryings i, sampler2D baseMap, float4 baseMapST, fixed4 baseColor, sampler2D normalMap, float4 normalMapST, half normalScale, sampler2D maskMap, float4 maskMapST, fixed4 emissionColor)
{
    ApexSurfaceData s;
    half4 baseSample = tex2D(baseMap, TRANSFORM_TEX(i.uv0, baseMap));
    half4 maskSample = tex2D(maskMap, TRANSFORM_TEX(i.uv0, maskMap));
    ApexPackedPBR p = ApexDecodePackedPBR(maskSample);
    half3 normalTS = ApexUnpackNormalScale(normalMap, TRANSFORM_TEX(i.uv0, normalMap), normalScale * ApexMobileFeatureScalar());
    s.albedo = baseSample.rgb * baseColor.rgb * i.vertexColor.rgb;
    s.normalWS = ApexTangentToWorld(normalTS, i);
    s.emission = emissionColor.rgb * emissionColor.a;
    s.metallic = p.metallic;
    s.smoothness = p.smoothness;
    s.occlusion = p.occlusion;
    s.alpha = baseSample.a * baseColor.a;
    s.emission += s.albedo * (1.0h + p.heightOrMask * 2.0h); s.metallic = 0;
    return s;
}

inline half3 ApexScreensFinish(half3 color, ApexSurfaceData s, ApexVaryings i, half spectraAmount)
{
    color = ApexSpectraTint(color, spectraAmount * 0.35h);
    color += ApexSpectraEmission(half3(0,0,0), spectraAmount) * 0.25h;
    return color;
}

#endif
