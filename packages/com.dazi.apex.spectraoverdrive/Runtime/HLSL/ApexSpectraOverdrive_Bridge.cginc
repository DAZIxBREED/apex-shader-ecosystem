#ifndef APEX_SPECTRAOVERDRIVE_BRIDGE_INCLUDED
#define APEX_SPECTRAOVERDRIVE_BRIDGE_INCLUDED

// Apex <-> SpectraOverdrive bridge.
// Driven by SpectraOverdrive, Udon, animator clips, or material property blocks.
// Safe defaults mean shaders still compile and render normally when values are not driven.

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
    half colorIsDriven = step(0.0001h, dot(abs((half3)_ApexSpectraColor.rgb), half3(1.0h, 1.0h, 1.0h)));
    d.color = lerp(half3(1.0h, 1.0h, 1.0h), max((half3)_ApexSpectraColor.rgb, half3(0.0h, 0.0h, 0.0h)), colorIsDriven);
    d.beat = saturate((half)_ApexSpectraBeat);
    d.blackout = saturate((half)_ApexSpectraBlackout);
    d.strobe = saturate((half)_ApexSpectraStrobe);
    d.groupId = (half)_ApexSpectraGroupId;
    return d;
}

inline half3 ApexSpectraTint(half3 baseColor, half amount)
{
    ApexSpectraData s = ApexGetSpectraData();
    half t = saturate(amount * (s.intensity + s.beat * 0.5h));
    return lerp(baseColor, baseColor * s.color, t) * (1.0h - s.blackout);
}

inline half3 ApexSpectraEmission(half3 baseEmission, half mask)
{
    ApexSpectraData s = ApexGetSpectraData();
    half pulse = saturate(s.intensity + s.beat + s.strobe);
    return (baseEmission + s.color * pulse * mask) * (1.0h - s.blackout);
}

#endif
