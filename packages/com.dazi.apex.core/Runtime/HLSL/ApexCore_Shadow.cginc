#ifndef APEX_CORE_SHADOW_INCLUDED
#define APEX_CORE_SHADOW_INCLUDED

#include "UnityCG.cginc"

struct ApexShadowAttributes
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float2 uv0 : TEXCOORD0;
    fixed4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct ApexShadowVaryings
{
    V2F_SHADOW_CASTER;
    float2 uv0 : TEXCOORD1;
    half vertexAlpha : TEXCOORD2;
    UNITY_VERTEX_OUTPUT_STEREO
};

inline ApexShadowVaryings ApexShadowVert(ApexShadowAttributes v, float4 baseMapST)
{
    ApexShadowVaryings o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(ApexShadowVaryings, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
    o.uv0 = v.uv0 * baseMapST.xy + baseMapST.zw;
    o.vertexAlpha = v.color.a;
    return o;
}

#endif
