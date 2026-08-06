#ifndef APEX_SPECTRAOVERDRIVE_BRIDGE_INCLUDED
#define APEX_SPECTRAOVERDRIVE_BRIDGE_INCLUDED

// Non-VRChat projects may drive the legacy/global values with Shader.SetGlobal*.
float _ApexSpectraIntensity;
float4 _ApexSpectraColor;
float4 _ApexSpectraBands;
float _ApexSpectraBeat;
float _ApexSpectraBlackout;
float _ApexSpectraStrobe;
float _ApexSpectraGroupId;
float _ApexSpectraTime;

// VRChat VRCShader.SetGlobal only accepts user globals prefixed with _Udon.
// Set _UdonApexSpectraActive to 1 while a VRChat/Udon driver owns the bridge.
float _UdonApexSpectraActive;
float _UdonApexSpectraIntensity;
float4 _UdonApexSpectraColor;
float4 _UdonApexSpectraBands;
float _UdonApexSpectraBeat;
float _UdonApexSpectraBlackout;
float _UdonApexSpectraStrobe;
float _UdonApexSpectraGroupId;
float _UdonApexSpectraTime;

struct ApexSpectraData
{
    half intensity;
    half3 color;
    half4 bands;
    half beat;
    half blackout;
    half strobe;
    half groupId;
    half time;
};

inline half ApexSpectraUseUdonGlobals()
{
    half signal = abs((half)_UdonApexSpectraActive);
    signal += abs((half)_UdonApexSpectraIntensity);
    signal += dot(abs((half4)_UdonApexSpectraColor), half4(1.0h, 1.0h, 1.0h, 1.0h));
    signal += dot(abs((half4)_UdonApexSpectraBands), half4(1.0h, 1.0h, 1.0h, 1.0h));
    signal += abs((half)_UdonApexSpectraBeat);
    signal += abs((half)_UdonApexSpectraBlackout);
    signal += abs((half)_UdonApexSpectraStrobe);
    return step(0.0001h, signal);
}

inline ApexSpectraData ApexGetSpectraData()
{
    ApexSpectraData data;
    half useUdon = ApexSpectraUseUdonGlobals();

    half rawIntensity = lerp((half)_ApexSpectraIntensity, (half)_UdonApexSpectraIntensity, useUdon);
    half4 rawColorValue = lerp((half4)_ApexSpectraColor, (half4)_UdonApexSpectraColor, useUdon);
    half4 rawBands = lerp((half4)_ApexSpectraBands, (half4)_UdonApexSpectraBands, useUdon);
    half rawBeat = lerp((half)_ApexSpectraBeat, (half)_UdonApexSpectraBeat, useUdon);
    half rawBlackout = lerp((half)_ApexSpectraBlackout, (half)_UdonApexSpectraBlackout, useUdon);
    half rawStrobe = lerp((half)_ApexSpectraStrobe, (half)_UdonApexSpectraStrobe, useUdon);
    half rawGroupId = lerp((half)_ApexSpectraGroupId, (half)_UdonApexSpectraGroupId, useUdon);
    half rawTime = lerp((half)_ApexSpectraTime, (half)_UdonApexSpectraTime, useUdon);

    data.intensity = saturate(rawIntensity);
    half3 rawColor = max(rawColorValue.rgb, 0.0h);
    half colorMagnitude = dot(rawColor, half3(1.0h, 1.0h, 1.0h));
    data.color = lerp(half3(1.0h, 1.0h, 1.0h), rawColor, step(0.0001h, colorMagnitude));
    data.bands = saturate(rawBands);
    data.beat = saturate(rawBeat);
    data.blackout = saturate(rawBlackout);
    data.strobe = saturate(rawStrobe);
    data.groupId = rawGroupId;
    data.time = rawTime;
    return data;
}

inline half ApexSpectraGroupWeight(ApexSpectraData data, half localGroupId)
{
    half globalIsBroadcast = 1.0h - step(0.5h, abs(data.groupId));
    half localIsBroadcast = 1.0h - step(0.5h, abs(localGroupId));
    half exactMatch = 1.0h - step(0.25h, abs(data.groupId - localGroupId));
    return saturate(globalIsBroadcast + localIsBroadcast + exactMatch);
}

inline half ApexSpectraBandValue(ApexSpectraData data, half4 weights)
{
    half normalization = max(dot(abs(weights), half4(1.0h, 1.0h, 1.0h, 1.0h)), 1e-4h);
    return saturate(dot(data.bands, weights) / normalization);
}

inline half ApexSpectraPulse(ApexSpectraData data, half localGroupId, half4 bandWeights)
{
    half groupWeight = ApexSpectraGroupWeight(data, localGroupId);
    half band = ApexSpectraBandValue(data, bandWeights);
    return saturate(data.intensity + data.beat + band + data.strobe) * groupWeight;
}

inline half ApexSpectraGroupWeight(half localGroupId)
{
    return ApexSpectraGroupWeight(ApexGetSpectraData(), localGroupId);
}

inline half ApexSpectraBandValue(half4 weights)
{
    return ApexSpectraBandValue(ApexGetSpectraData(), weights);
}

inline half ApexSpectraPulse(half localGroupId, half4 bandWeights)
{
    return ApexSpectraPulse(ApexGetSpectraData(), localGroupId, bandWeights);
}

inline half3 ApexSpectraTint(
    half3 baseColor,
    half amount,
    half localGroupId,
    half4 bandWeights)
{
    ApexSpectraData data = ApexGetSpectraData();
    half pulse = ApexSpectraPulse(data, localGroupId, bandWeights);
    half blendAmount = saturate(amount * pulse);
    half3 tinted = lerp(baseColor, baseColor * data.color, blendAmount);
    return tinted * (1.0h - data.blackout);
}

inline half3 ApexSpectraEmission(
    half3 baseEmission,
    half mask,
    half localGroupId,
    half4 bandWeights)
{
    ApexSpectraData data = ApexGetSpectraData();
    half pulse = ApexSpectraPulse(data, localGroupId, bandWeights);
    return (baseEmission + data.color * pulse * mask) * (1.0h - data.blackout);
}

// Compatibility overloads for early Apex materials.
inline half3 ApexSpectraTint(half3 baseColor, half amount)
{
    return ApexSpectraTint(baseColor, amount, 0.0h, half4(0.25h, 0.25h, 0.25h, 0.25h));
}

inline half3 ApexSpectraEmission(half3 baseEmission, half mask)
{
    return ApexSpectraEmission(baseEmission, mask, 0.0h, half4(0.25h, 0.25h, 0.25h, 0.25h));
}

#endif
