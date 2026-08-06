Shader "Apex/World/Standard"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0,2)) = 1
        _MaskMap("Mask: R Metallic, G AO, B Effect, A Smoothness", 2D) = "white" {}
        _Metallic("Metallic", Range(0,1)) = 0
        _Smoothness("Smoothness", Range(0,1)) = 0.5
        _OcclusionStrength("Occlusion Strength", Range(0,1)) = 1
        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0,0)

        [Toggle(_APEX_DETAIL)] _DetailEnabled("Detail Layer", Float) = 0
        _DetailMap("Detail Map", 2D) = "gray" {}
        _DetailColor("Detail Color", Color) = (1,1,1,1)
        _DetailStrength("Detail Strength", Range(0,1)) = 0

        [Toggle] _AlphaClip("Alpha Clip", Float) = 0
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5

        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.25,0.25,0.25,0.25)
        [Enum(Off,0,Albedo,1,Normals,2,MOS,3,UV,4,VertexColor,5,Emission,6,EffectMask,7,BakedGI,8)] _DebugMode("Debug View", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 250

        Pass
        {
            Name "FORWARD_BASE"
            Tags { "LightMode"="ForwardBase" }
            ZWrite On

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma shader_feature_local _APEX_DETAIL

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Packing.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Surface.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Debug.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.world/Runtime/HLSL/ApexWorld_Surface.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _NormalMap; float4 _NormalMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            sampler2D _DetailMap; float4 _DetailMap_ST;
            half4 _BaseColor;
            half4 _EmissionColor;
            half4 _DetailColor;
            half _NormalScale;
            half _Metallic;
            half _Smoothness;
            half _OcclusionStrength;
            half _DetailStrength;
            half _AlphaClip;
            half _Cutoff;
            half _SpectraAmount;
            half _SpectraGroup;
            half4 _SpectraBandWeights;
            int _DebugMode;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            half4 frag(ApexVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexSurfaceData surface = ApexWorldBuildSurface(
                    i, _BaseMap, _BaseMap_ST, _BaseColor,
                    _NormalMap, _NormalMap_ST, _NormalScale,
                    _MaskMap, _MaskMap_ST,
                    _Metallic, _OcclusionStrength, _Smoothness,
                    _EmissionColor,
                    _DetailMap, _DetailMap_ST, _DetailColor, _DetailStrength
                );
                ApexApplyAlphaClip(surface.alpha, _Cutoff, _AlphaClip);
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                ApexLightingData lighting = ApexBuildLight(i, surface, attenuation, 1.0h);
                half3 color = ApexEvaluateBaseLighting(surface, lighting) + surface.emission;
                color = ApexWorldFinish(color, surface, _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color = ApexDebugColor(_DebugMode, surface, i, color);
                color = ApexApplyFog(i, color);
                return half4(color, surface.alpha);
            }
            ENDCG
        }

        Pass
        {
            Name "FORWARD_ADD"
            Tags { "LightMode"="ForwardAdd" }
            Blend One One
            ZWrite Off
            Fog { Color (0,0,0,0) }

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment fragAdd
            #pragma multi_compile_fwdadd_fullshadows
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #pragma shader_feature_local _APEX_DETAIL

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Packing.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Surface.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.world/Runtime/HLSL/ApexWorld_Surface.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _NormalMap; float4 _NormalMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            sampler2D _DetailMap; float4 _DetailMap_ST;
            half4 _BaseColor;
            half4 _EmissionColor;
            half4 _DetailColor;
            half _NormalScale;
            half _Metallic;
            half _Smoothness;
            half _OcclusionStrength;
            half _DetailStrength;
            half _AlphaClip;
            half _Cutoff;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            half4 fragAdd(ApexVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexSurfaceData surface = ApexWorldBuildSurface(
                    i, _BaseMap, _BaseMap_ST, _BaseColor,
                    _NormalMap, _NormalMap_ST, _NormalScale,
                    _MaskMap, _MaskMap_ST,
                    _Metallic, _OcclusionStrength, _Smoothness,
                    _EmissionColor,
                    _DetailMap, _DetailMap_ST, _DetailColor, _DetailStrength
                );
                ApexApplyAlphaClip(surface.alpha, _Cutoff, _AlphaClip);
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                ApexLightingData lighting = ApexBuildLight(i, surface, attenuation, 0.0h);
                half3 color = ApexEvaluateAddLighting(surface, lighting);
                color = ApexApplyFog(i, color);
                return half4(color, 0.0h);
            }
            ENDCG
        }

        Pass
        {
            Name "SHADOW_CASTER"
            Tags { "LightMode"="ShadowCaster" }
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vertShadow
            #pragma fragment fragShadow
            #pragma multi_compile_shadowcaster
            #pragma multi_compile_instancing

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Shadow.cginc"
            sampler2D _BaseMap;
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half _AlphaClip;
            half _Cutoff;

            ApexShadowVaryings vertShadow(ApexShadowAttributes v)
            {
                return ApexShadowVert(v, _BaseMap_ST);
            }

            float4 fragShadow(ApexShadowVaryings i) : SV_Target
            {
                half alpha = tex2D(_BaseMap, i.uv0).a * _BaseColor.a;
                half clipValue = lerp(1.0h, alpha - _Cutoff, step(0.5h, _AlphaClip));
                clip(clipValue);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }

        Pass
        {
            Name "META"
            Tags { "LightMode"="Meta" }
            Cull Off

            CGPROGRAM
            #pragma vertex vertMeta
            #pragma fragment fragMeta
            #include "UnityCG.cginc"
            #include "UnityMetaPass.cginc"

            sampler2D _BaseMap;
            float4 _BaseMap_ST;
            half4 _BaseColor;
            half4 _EmissionColor;

            struct ApexMetaAttributes
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
            };

            struct ApexMetaVaryings
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            ApexMetaVaryings vertMeta(ApexMetaAttributes v)
            {
                ApexMetaVaryings o;
                o.pos = UnityMetaVertexPosition(v.vertex, v.uv1, v.uv2, unity_LightmapST, unity_DynamicLightmapST);
                o.uv = TRANSFORM_TEX(v.uv0, _BaseMap);
                return o;
            }

            half4 fragMeta(ApexMetaVaryings i) : SV_Target
            {
                half4 baseSample = tex2D(_BaseMap, i.uv) * _BaseColor;
                UnityMetaInput meta;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, meta);
                meta.Albedo = baseSample.rgb;
                meta.Emission = _EmissionColor.rgb * _EmissionColor.a;
                return UnityMetaFragment(meta);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
