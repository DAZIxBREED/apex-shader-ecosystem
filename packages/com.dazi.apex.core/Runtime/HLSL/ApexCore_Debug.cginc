#ifndef APEX_CORE_DEBUG_INCLUDED
#define APEX_CORE_DEBUG_INCLUDED

inline half3 ApexDebugColor(
    int mode,
    ApexSurfaceData surface,
    ApexVaryings i,
    half3 litColor)
{
    if (mode == 1) return surface.albedo;
    if (mode == 2) return surface.normalWS * 0.5h + 0.5h;
    if (mode == 3) return half3(surface.metallic, surface.occlusion, surface.smoothness);
    if (mode == 4) return half3(frac(i.uv0), 0.0h);
    if (mode == 5) return i.vertexColor.rgb;
    if (mode == 6) return surface.emission;
    if (mode == 7) return surface.mask.xxx;
    if (mode == 8) return ApexSampleBakedGI(i, surface.normalWS);
    return litColor;
}

#endif
