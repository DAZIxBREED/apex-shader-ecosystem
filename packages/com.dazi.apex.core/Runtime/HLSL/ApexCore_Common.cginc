#ifndef APEX_CORE_COMMON_INCLUDED
#define APEX_CORE_COMMON_INCLUDED

#include "UnityCG.cginc"
#include "Lighting.cginc"
#include "AutoLight.cginc"

#define APEX_VERSION_MAJOR 0
#define APEX_VERSION_MINOR 2
#define APEX_VERSION_PATCH 0

#define APEX_PI 3.14159265h
#define APEX_INV_PI 0.318309886h

struct ApexAttributes
{
    float4 vertex : POSITION;
    float3 normal : NORMAL;
    float4 tangent : TANGENT;
    float2 uv0 : TEXCOORD0;
    float2 uv1 : TEXCOORD1;
    fixed4 color : COLOR;
    UNITY_VERTEX_INPUT_INSTANCE_ID
};

struct ApexVaryings
{
    float4 pos : SV_POSITION;
    half2 uv0 : TEXCOORD0;
    half2 uv1 : TEXCOORD1;
    float3 worldPos : TEXCOORD2;
    half3 worldNormal : TEXCOORD3;
    half4 worldTangent : TEXCOORD4;
    fixed4 vertexColor : COLOR;
    UNITY_FOG_COORDS(5)
    LIGHTING_COORDS(6, 7)
    UNITY_VERTEX_OUTPUT_STEREO
};


struct ApexUnlitVaryings
{
    float4 pos : SV_POSITION;
    half2 uv0 : TEXCOORD0;
    float3 worldPos : TEXCOORD1;
    half3 worldNormal : TEXCOORD2;
    fixed4 vertexColor : COLOR;
    UNITY_FOG_COORDS(3)
    UNITY_VERTEX_OUTPUT_STEREO
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
    half mask;
};

struct ApexLightingData
{
    half3 lightDir;
    half3 viewDir;
    half3 halfDir;
    half3 lightColor;
    half3 bakedGI;
    half attenuation;
};

inline half ApexLuminance(half3 color)
{
    return dot(color, half3(0.2126h, 0.7152h, 0.0722h));
}

inline half3 ApexSafeNormalize(half3 value)
{
    return value * rsqrt(max(dot(value, value), 1e-6h));
}

inline float3 ApexSafeNormalizeFloat(float3 value)
{
    return value * rsqrt(max(dot(value, value), 1e-12));
}

inline half ApexRemap01(half value, half minimum, half maximum)
{
    return saturate((value - minimum) / max(maximum - minimum, 1e-4h));
}

inline half2 ApexRotateUV(half2 uv, half radians, half2 pivot)
{
    half sineValue;
    half cosineValue;
    sincos(radians, sineValue, cosineValue);
    uv -= pivot;
    uv = half2(
        uv.x * cosineValue - uv.y * sineValue,
        uv.x * sineValue + uv.y * cosineValue
    );
    return uv + pivot;
}

inline half3 ApexAdjustSaturation(half3 color, half saturation)
{
    half luminance = ApexLuminance(color);
    return lerp(luminance.xxx, color, saturation);
}

inline half3 ApexAdjustContrast(half3 color, half contrast)
{
    return (color - 0.5h) * contrast + 0.5h;
}

inline half ApexFresnel(half3 normalWS, half3 viewDir, half power)
{
    return pow(1.0h - saturate(dot(normalWS, viewDir)), max(power, 0.01h));
}

inline half ApexHash12(half2 value)
{
    half3 p3 = frac(half3(value.xyx) * 0.1031h);
    p3 += dot(p3, p3.yzx + 33.33h);
    return frac((p3.x + p3.y) * p3.z);
}

inline ApexVaryings ApexCoreVert(ApexAttributes v)
{
    ApexVaryings o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(ApexVaryings, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv0 = v.uv0;
#if defined(LIGHTMAP_ON)
    o.uv1 = v.uv1 * unity_LightmapST.xy + unity_LightmapST.zw;
#else
    o.uv1 = v.uv1;
#endif
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.worldTangent.xyz = UnityObjectToWorldDir(v.tangent.xyz);
    o.worldTangent.w = v.tangent.w * unity_WorldTransformParams.w;
    o.vertexColor = v.color;

    UNITY_TRANSFER_FOG(o, o.pos);
    TRANSFER_VERTEX_TO_FRAGMENT(o);
    return o;
}

inline ApexUnlitVaryings ApexCoreUnlitVert(ApexAttributes v)
{
    ApexUnlitVaryings o;
    UNITY_SETUP_INSTANCE_ID(v);
    UNITY_INITIALIZE_OUTPUT(ApexUnlitVaryings, o);
    UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
    o.pos = UnityObjectToClipPos(v.vertex);
    o.uv0 = v.uv0;
    o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
    o.worldNormal = UnityObjectToWorldNormal(v.normal);
    o.vertexColor = v.color;
    UNITY_TRANSFER_FOG(o, o.pos);
    return o;
}

inline half3 ApexGetViewDirection(ApexUnlitVaryings i)
{
    return ApexSafeNormalize(UnityWorldSpaceViewDir(i.worldPos));
}

inline half3 ApexApplyFog(ApexUnlitVaryings i, half3 color)
{
    UNITY_APPLY_FOG(i.fogCoord, color);
    return color;
}

inline half3 ApexUnpackNormalScale(sampler2D normalMap, float2 uv, half scale)
{
    half3 normalTS = UnpackNormal(tex2D(normalMap, uv));
    normalTS.xy *= scale;
    normalTS.z = sqrt(saturate(1.0h - dot(normalTS.xy, normalTS.xy)));
    return ApexSafeNormalize(normalTS);
}

inline half3 ApexTangentToWorld(half3 normalTS, ApexVaryings i)
{
    half3 normalWS = ApexSafeNormalize(i.worldNormal);
    half3 tangentWS = ApexSafeNormalize(i.worldTangent.xyz);
    half3 bitangentWS = ApexSafeNormalize(cross(normalWS, tangentWS) * i.worldTangent.w);
    return ApexSafeNormalize(
        normalTS.x * tangentWS +
        normalTS.y * bitangentWS +
        normalTS.z * normalWS
    );
}

inline half3 ApexGetViewDirection(ApexVaryings i)
{
    return ApexSafeNormalize(UnityWorldSpaceViewDir(i.worldPos));
}

inline half3 ApexApplyFog(ApexVaryings i, half3 color)
{
    UNITY_APPLY_FOG(i.fogCoord, color);
    return color;
}

#endif
