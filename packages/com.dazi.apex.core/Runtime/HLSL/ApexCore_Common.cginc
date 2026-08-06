#ifndef APEX_CORE_COMMON_INCLUDED
#define APEX_CORE_COMMON_INCLUDED

#include "UnityCG.cginc"
#include "Lighting.cginc"

#define APEX_VERSION_MAJOR 0
#define APEX_VERSION_MINOR 1
#define APEX_VERSION_PATCH 0

struct ApexAttributes
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    fixed4 color : COLOR;
};

struct ApexVaryings
{
    float4 pos : SV_POSITION;
    half2 uv0 : TEXCOORD0;
    half2 uv1 : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    half3 worldNormal : TEXCOORD3;
    half3 worldTangent : TEXCOORD4;
    half3 worldBitangent : TEXCOORD5;
    fixed4 vertexColor : COLOR;
    UNITY_FOG_COORDS(6)
};

struct ApexSurfaceData
{
    half3 albedo;
    half3 normalWS;
    half3 emission;
    half metallic;
    half smoothness;
    half occlusion;
    half alpha;
};

struct ApexLightingData
{
    half3 lightDir;
    half3 viewDir;
    half3 halfDir;
    half3 lightColor;
    half3 ambient;
    half attenuation;
};

inline ApexVaryings ApexCoreVert(ApexAttributes v)
{
    ApexVaryings o;
    UNITY_INITIALIZE_OUTPUT(ApexVaryings, o);
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv0 = v.uv0;
    o.uv1 = v.uv1;
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldTangent = UnityObjectToWorldDir(v.tangent.xyz);
    o.worldBitangent = cross(o.worldNormal, o.worldTangent) * v.tangent.w;
    o.vertexColor = v.color;
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}

inline half3 ApexSafeNormalize(half3 v)
{
    return normalize(v + half3(1e-4h, 1e-4h, 1e-4h));
}

inline half3 ApexUnpackNormalScale(sampler2D normalMap, float2 uv, half scale)
{
    half3 n = UnpackNormal(tex2D(normalMap, uv));
    n.xy *= scale;
    return ApexSafeNormalize(n);
}

inline half3 ApexTangentToWorld(half3 normalTS, ApexVaryings i)
{
    half3x3 tbn = half3x3(ApexSafeNormalize(i.worldTangent), ApexSafeNormalize(i.worldBitangent), ApexSafeNormalize(i.worldNormal));
    return ApexSafeNormalize(mul(normalTS, tbn));
}

inline half3 ApexApplyFog(ApexVaryings i, half3 color)
{
    UNITY_APPLY_FOG(i.fogCoord, color);
    return color;
}

#endif
