#ifndef APEX_CORE_PACKING_INCLUDED
#define APEX_CORE_PACKING_INCLUDED

struct ApexPackedPBR
{
    half metallic;
    half occlusion;
    half heightOrMask;
    half smoothness;
};

inline ApexPackedPBR ApexDecodePackedPBR(half4 packedValue)
{
    ApexPackedPBR p;
    p.metallic = packedValue.r;
    p.occlusion = packedValue.g;
    p.heightOrMask = packedValue.b;
    p.smoothness = packedValue.a;
    return p;
}

#endif
