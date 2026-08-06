#ifndef APEX_CORE_DEBUG_INCLUDED
#define APEX_CORE_DEBUG_INCLUDED

inline half3 ApexDebugColor(int mode, ApexSurfaceData s, ApexVaryings i, half3 litColor)
{
    if (mode == 1) return s.albedo;
    if (mode == 2) return s.normalWS * 0.5h + 0.5h;
    if (mode == 3) return half3(s.metallic, s.occlusion, s.smoothness);
    if (mode == 4) return half3(i.uv0, 0.0h);
    return litColor;
}

#endif
