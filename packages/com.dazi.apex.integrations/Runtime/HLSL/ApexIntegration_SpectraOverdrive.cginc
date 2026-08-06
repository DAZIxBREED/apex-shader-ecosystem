#ifndef APEX_INTEGRATION_SPECTRAOVERDRIVE_INCLUDED
#define APEX_INTEGRATION_SPECTRAOVERDRIVE_INCLUDED

// SpectraOverdrive compatibility bridge.
// These uniforms are intentionally generic so Apex can compile even when SpectraOverdrive is not installed.
// SpectraOverdrive, Udon, animation clips, or material property blocks may drive them.

float _ApexSpectraIntensity;
float4 _ApexSpectraColor;
float _ApexSpectraBeat;
float _ApexSpectraBlackout;
float _ApexSpectraStrobe;
float _ApexSpectraGroupId;

struct ApexSpectraData
{
    half intensity;
    half3 color;
    half beat;
    half blackout;
    half strobe;
    half groupId;
};

inline ApexSpectraData ApexGetSpectraData()
{
    ApexSpectraData d;
    d.intensity = saturate((half)_ApexSpectraIntensity);
    d.color = max((half3)_ApexSpectraColor.rgb, half3(1.0h, 1.0h, 1.0h));
    d.beat = saturate((half)_ApexSpectraBeat);
    d.blackout = saturate((half)_ApexSpectraBlackout);
    d.strobe = saturate((half)_ApexSpectraStrobe);
    d.groupId = (half)_ApexSpectraGroupId;
    return d;
}

inline half3 ApexApplySpectraEmission(half3 baseEmission, half mask)
{
    ApexSpectraData s = ApexGetSpectraData();
    half pulse = saturate(s.intensity + s.beat + s.strobe);
    half3 outEmission = baseEmission + s.color * pulse * mask;
    outEmission *= (1.0h - s.blackout);
    return outEmission;
}

inline half3 ApexApplySpectraTint(half3 baseColor, half amount)
{
    ApexSpectraData s = ApexGetSpectraData();
    half t = saturate(amount * (s.intensity + s.beat * 0.5h));
    return lerp(baseColor, baseColor * s.color, t) * (1.0h - s.blackout);
}

#endif
