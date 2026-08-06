#ifndef APEX_INTEGRATION_OPTIONAL_FALLBACKS_INCLUDED
#define APEX_INTEGRATION_OPTIONAL_FALLBACKS_INCLUDED

// Non-VRChat projects may populate these globals with Shader.SetGlobal*.
float4 _ApexAudioBands;
float _ApexAudioAmplitude;
float4 _ApexLightVolumeColor;
float4 _ApexLTCGIColor;
float4 _ApexVRSLColor;

// VRChat VRCShader.SetGlobal accepts user globals with the _Udon prefix.
// Set _UdonApexIntegrationActive to 1 while an Udon-side adapter owns them.
float _UdonApexIntegrationActive;
float4 _UdonApexAudioBands;
float _UdonApexAudioAmplitude;
float4 _UdonApexLightVolumeColor;
float4 _UdonApexLTCGIColor;
float4 _UdonApexVRSLColor;

inline half ApexIntegrationUseUdonGlobals()
{
    half signal = abs((half)_UdonApexIntegrationActive);
    signal += dot(abs((half4)_UdonApexAudioBands), half4(1.0h, 1.0h, 1.0h, 1.0h));
    signal += abs((half)_UdonApexAudioAmplitude);
    signal += dot(abs((half4)_UdonApexLightVolumeColor), half4(1.0h, 1.0h, 1.0h, 1.0h));
    signal += dot(abs((half4)_UdonApexLTCGIColor), half4(1.0h, 1.0h, 1.0h, 1.0h));
    signal += dot(abs((half4)_UdonApexVRSLColor), half4(1.0h, 1.0h, 1.0h, 1.0h));
    return step(0.0001h, signal);
}

inline half4 ApexIntegrationSelectValue(float4 unityValue, float4 udonValue)
{
    return lerp((half4)unityValue, (half4)udonValue, ApexIntegrationUseUdonGlobals());
}

inline half ApexIntegrationSelectValue(float unityValue, float udonValue)
{
    return lerp((half)unityValue, (half)udonValue, ApexIntegrationUseUdonGlobals());
}

inline half ApexIntegrationAudioLevel(half4 bandWeights)
{
    half4 audioBands = saturate(ApexIntegrationSelectValue(_ApexAudioBands, _UdonApexAudioBands));
    half audioAmplitude = ApexIntegrationSelectValue(_ApexAudioAmplitude, _UdonApexAudioAmplitude);
    half normalization = max(dot(abs(bandWeights), half4(1.0h, 1.0h, 1.0h, 1.0h)), 1e-4h);
    half bands = dot(audioBands, bandWeights) / normalization;
    return saturate(max(bands, audioAmplitude));
}

inline half3 ApexIntegrationApplyAudioReactive(
    half3 color,
    half3 reactiveColor,
    half amount,
    half4 bandWeights)
{
    half level = ApexIntegrationAudioLevel(bandWeights);
    return color + reactiveColor * level * amount;
}

inline half3 ApexIntegrationApplyLightVolume(half3 color, half amount)
{
    half3 lightVolume = max(
        ApexIntegrationSelectValue(_ApexLightVolumeColor, _UdonApexLightVolumeColor).rgb,
        0.0h
    );
    half isDriven = step(0.0001h, dot(lightVolume, half3(1.0h, 1.0h, 1.0h)));
    return color * lerp(half3(1.0h, 1.0h, 1.0h), lightVolume, saturate(amount) * isDriven);
}

inline half3 ApexIntegrationApplyLTCGI(half3 emission, half amount)
{
    half3 ltcgi = max(ApexIntegrationSelectValue(_ApexLTCGIColor, _UdonApexLTCGIColor).rgb, 0.0h);
    return emission + ltcgi * saturate(amount);
}

inline half3 ApexIntegrationApplyVRSL(half3 emission, half amount)
{
    half3 vrsl = max(ApexIntegrationSelectValue(_ApexVRSLColor, _UdonApexVRSLColor).rgb, 0.0h);
    return emission + vrsl * saturate(amount);
}

// Backward-compatible function names now perform useful global-uniform integration.
inline half3 ApexIntegrationAudioReactiveFallback(half3 color, half amount)
{
    return ApexIntegrationApplyAudioReactive(color, color, amount, half4(0.25h, 0.25h, 0.25h, 0.25h));
}

inline half3 ApexIntegrationLightVolumeFallback(half3 color, half amount)
{
    return ApexIntegrationApplyLightVolume(color, amount);
}

inline half3 ApexIntegrationLTCGIFallback(half3 color, half amount)
{
    return ApexIntegrationApplyLTCGI(color, amount);
}

inline half3 ApexIntegrationVRSLFallback(half3 color, half amount)
{
    return ApexIntegrationApplyVRSL(color, amount);
}

#endif
