#ifndef APEX_FOG_SURFACE_INCLUDED
#define APEX_FOG_SURFACE_INCLUDED

struct ApexFogData
{
    half3 color;
    half alpha;
    half noise;
};

inline ApexFogData ApexBuildFog(
    ApexUnlitVaryings i,
    sampler2D noiseMap,
    float4 noiseMapST,
    sampler2D maskMap,
    float4 maskMapST,
    half2 speedA,
    half2 speedB,
    half density,
    half3 fogColor,
    half distanceStart,
    half distanceEnd,
    half heightMinimum,
    half heightMaximum,
    half edgePower)
{
    ApexFogData fog;
    half timeValue = (half)_Time.y * ApexPlatformAnimationScalar();
    half2 uv = i.uv0 * noiseMapST.xy + noiseMapST.zw;
    half noiseA = tex2D(noiseMap, uv + speedA * timeValue).r;
    half noiseB = tex2D(noiseMap, uv * 1.71h + speedB * timeValue).g;
    half authoredMask = tex2D(maskMap, i.uv0 * maskMapST.xy + maskMapST.zw).r;

    half noise = saturate(noiseA * noiseB * 2.0h);
    half distanceToCamera = distance(_WorldSpaceCameraPos.xyz, i.worldPos);
    half distanceFade = ApexRemap01(distanceToCamera, distanceStart, distanceEnd);
    half heightFade = 1.0h - ApexRemap01(i.worldPos.y, heightMinimum, heightMaximum);
    half facing = pow(saturate(abs(dot(ApexSafeNormalize(i.worldNormal), ApexGetViewDirection(i)))), max(edgePower, 0.01h));

    fog.noise = noise;
    fog.color = fogColor * i.vertexColor.rgb;
    fog.alpha = saturate(noise * authoredMask * density * distanceFade * heightFade * facing * i.vertexColor.a);
    return fog;
}

#endif
