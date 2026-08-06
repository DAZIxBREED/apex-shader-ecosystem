#ifndef APEX_CORE_PACKING_INCLUDED
#define APEX_CORE_PACKING_INCLUDED

struct ApexPackedPBR
{
    half metallic;
    half occlusion;
    half mask;
    half smoothness;
};

inline ApexPackedPBR ApexDecodePackedPBR(
    half4 packedValue,
    half metallicScale,
    half occlusionStrength,
    half smoothnessScale)
{
    ApexPackedPBR packed;
    packed.metallic = saturate(packedValue.r * metallicScale);
    packed.occlusion = lerp(1.0h, packedValue.g, saturate(occlusionStrength));
    packed.mask = packedValue.b;
    packed.smoothness = saturate(packedValue.a * smoothnessScale);
    return packed;
}

inline half4 ApexEncodePackedPBR(ApexPackedPBR packed)
{
    return half4(packed.metallic, packed.occlusion, packed.mask, packed.smoothness);
}

#endif
