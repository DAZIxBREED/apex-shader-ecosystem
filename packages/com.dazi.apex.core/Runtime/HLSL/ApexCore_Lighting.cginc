#ifndef APEX_CORE_LIGHTING_INCLUDED
#define APEX_CORE_LIGHTING_INCLUDED

inline ApexLightingData ApexBuildMainLight(ApexVaryings i, ApexSurfaceData s)
{
    ApexLightingData l;
    l.lightDir = ApexSafeNormalize(_WorldSpaceLightPos0.xyz);
    l.viewDir = ApexSafeNormalize(_WorldSpaceCameraPos.xyz - i.worldPos);
    l.halfDir = ApexSafeNormalize(l.lightDir + l.viewDir);
    l.lightColor = _LightColor0.rgb;
    l.ambient = ShadeSH9(half4(s.normalWS, 1.0h));
    l.attenuation = 1.0h;
    return l;
}

inline half3 ApexLambert(ApexSurfaceData s, ApexLightingData l)
{
    half ndotl = saturate(dot(s.normalWS, l.lightDir));
    half3 diffuse = s.albedo * (l.ambient + l.lightColor * ndotl * l.attenuation);
    half specPower = lerp(8.0h, 96.0h, s.smoothness);
    half spec = pow(saturate(dot(s.normalWS, l.halfDir)), specPower) * s.smoothness;
    return diffuse + spec * l.lightColor * lerp(0.04h, 1.0h, s.metallic);
}

#endif
