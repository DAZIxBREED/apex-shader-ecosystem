#ifndef APEX_FX_DISSOLVE_INCLUDED
#define APEX_FX_DISSOLVE_INCLUDED

inline half ApexDissolveClipValue(half noiseValue, half dissolveAmount)
{
    return noiseValue - saturate(dissolveAmount);
}

inline half ApexDissolveEdge(half noiseValue, half dissolveAmount, half edgeWidth)
{
    half delta = noiseValue - saturate(dissolveAmount);
    return 1.0h - smoothstep(0.0h, max(edgeWidth, 1e-4h), delta);
}

#endif
