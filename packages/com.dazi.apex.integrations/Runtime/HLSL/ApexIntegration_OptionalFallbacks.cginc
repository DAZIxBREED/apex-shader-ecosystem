#ifndef APEX_INTEGRATION_OPTIONAL_FALLBACKS_INCLUDED
#define APEX_INTEGRATION_OPTIONAL_FALLBACKS_INCLUDED

inline half3 ApexIntegrationAudioReactiveFallback(half3 color, half amount) { return color; }
inline half3 ApexIntegrationLightVolumeFallback(half3 color, half amount) { return color; }
inline half3 ApexIntegrationLTCGIFallback(half3 color, half amount) { return color; }
inline half3 ApexIntegrationVRSLFallback(half3 color, half amount) { return color; }

#endif
