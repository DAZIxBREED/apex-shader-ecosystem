#ifndef APEX_SCREENS_SURFACE_INCLUDED
#define APEX_SCREENS_SURFACE_INCLUDED

inline half2 ApexScreenUV(half2 uv, half4 uvRect, half flipX, half flipY)
{
    uv.x = lerp(uv.x, 1.0h - uv.x, step(0.5h, flipX));
    uv.y = lerp(uv.y, 1.0h - uv.y, step(0.5h, flipY));
    return uvRect.xy + uv * uvRect.zw;
}

inline half3 ApexGradeScreen(
    half3 color,
    half brightness,
    half contrast,
    half saturation,
    half gammaValue)
{
    color *= max(brightness, 0.0h);
    color = ApexAdjustContrast(color, contrast);
    color = ApexAdjustSaturation(color, saturation);
    color = pow(max(color, 0.0h), rcp(max(gammaValue, 0.01h)));
    return color;
}

inline half ApexScreenVignette(half2 uv, half strength, half softness)
{
    half2 centered = abs(uv * 2.0h - 1.0h);
    half edge = max(centered.x, centered.y);
    return 1.0h - smoothstep(1.0h - softness, 1.0h, edge) * strength;
}

inline half2 ApexScreenPixelCenterUV(half2 uv, half2 pixelCount)
{
    half2 count = max(pixelCount, half2(1.0h, 1.0h));
    return (floor(uv * count) + 0.5h) / count;
}

inline half ApexScreenPixelAperture(half2 uv, half2 pixelCount, half gap)
{
    half2 cell = frac(uv * max(pixelCount, half2(1.0h, 1.0h)));
    half2 edgeDistance = min(cell, 1.0h - cell);
    half safeGap = saturate(gap) * 0.5h;
    return step(safeGap, edgeDistance.x) * step(safeGap, edgeDistance.y);
}

inline half3 ApexScreenRGBSubpixelMask(half2 uv, half2 pixelCount, half strength)
{
    half phase = frac(uv.x * max(pixelCount.x, 1.0h));
    half3 stripe = half3(
        1.0h - step(0.3333h, phase),
        step(0.3333h, phase) * (1.0h - step(0.6667h, phase)),
        step(0.6667h, phase)
    );
    return lerp(half3(1.0h, 1.0h, 1.0h), stripe * 3.0h, saturate(strength));
}

#endif
