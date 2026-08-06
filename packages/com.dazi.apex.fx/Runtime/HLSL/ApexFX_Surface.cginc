#ifndef APEX_FX_SURFACE_INCLUDED
#define APEX_FX_SURFACE_INCLUDED

inline half ApexHologramScanline(float3 worldPosition, half density, half speed, half sharpness)
{
    half phase = frac(worldPosition.y * density + (half)_Time.y * speed);
    return pow(saturate(1.0h - abs(phase * 2.0h - 1.0h)), max(sharpness, 0.01h));
}

inline half ApexHologramFlicker(half amount, half speed)
{
    half randomValue = ApexHash12(half2(floor((half)_Time.y * speed), 17.0h));
    return lerp(1.0h, randomValue, saturate(amount));
}

#endif
