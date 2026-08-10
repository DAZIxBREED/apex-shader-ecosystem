Shader "Apex/World/VertexBlendLite"
{
    Properties
    {
        _LayerABase("Layer A Base", 2D) = "white" {}
        _LayerAColor("Layer A Color", Color) = (1,1,1,1)
        _LayerANormal("Layer A Normal", 2D) = "bump" {}
        _LayerAMask("Layer A Mask: R Metallic, G AO, B Effect, A Smoothness", 2D) = "white" {}
        _LayerAMetallic("Layer A Metallic", Range(0,1)) = 0
        _LayerASmoothness("Layer A Smoothness", Range(0,1)) = 0.5

        _LayerBBase("Layer B Base", 2D) = "white" {}
        _LayerBColor("Layer B Color", Color) = (1,1,1,1)
        _LayerBNormal("Layer B Normal", 2D) = "bump" {}
        _LayerBMask("Layer B Mask: R Metallic, G AO, B Effect, A Smoothness", 2D) = "white" {}
        _LayerBMetallic("Layer B Metallic", Range(0,1)) = 0
        _LayerBSmoothness("Layer B Smoothness", Range(0,1)) = 0.5

        _NormalScale("Normal Scale", Range(0,2)) = 1
        _OcclusionStrength("Occlusion Strength", Range(0,1)) = 1
        _BlendBias("Vertex Red Blend Bias", Range(-1,1)) = 0
        _BlendContrast("Vertex Red Blend Contrast", Range(0.1,8)) = 1
        [HDR] _EmissionColor("Effect-Mask Emission", Color) = (0,0,0,0)
        [KeywordEnum(Standard,Mobile,High)] _APEX_QUALITY("Apex Quality Profile", Float) = 0
        _EnvironmentStrength("Reflection Probe Strength", Range(0,2)) = 1
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.25,0.25,0.25,0.25)
        [Enum(Off,0,Albedo,1,Normals,2,MOS,3,UV,4,VertexColor,5,Emission,6,EffectMask,7,BakedGI,8)] _DebugMode("Debug View", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 300

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
            #pragma shader_feature_local _ _APEX_QUALITY_STANDARD _APEX_QUALITY_MOBILE _APEX_QUALITY_HIGH

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Packing.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Surface.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Quality.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Environment.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Debug.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.world/Runtime/HLSL/ApexWorld_Surface.cginc"
            #include "Packages/com.dazi.apex.world/Runtime/HLSL/ApexWorld_VertexBlend.cginc"

            sampler2D _LayerABase; float4 _LayerABase_ST;
            sampler2D _LayerANormal; float4 _LayerANormal_ST;
            sampler2D _LayerAMask; float4 _LayerAMask_ST;
            sampler2D _LayerBBase; float4 _LayerBBase_ST;
            sampler2D _LayerBNormal; float4 _LayerBNormal_ST;
            sampler2D _LayerBMask; float4 _LayerBMask_ST;
            half4 _LayerAColor;
            half4 _LayerBColor;
            half4 _EmissionColor;
            half _LayerAMetallic;
            half _LayerASmoothness;
            half _LayerBMetallic;
            half _LayerBSmoothness;
            half _NormalScale;
            half _OcclusionStrength;
            half _BlendBias;
            half _BlendContrast;
            half _EnvironmentStrength;
            half _SpectraAmount;
            half _SpectraGroup;
            half4 _SpectraBandWeights;
            int _DebugMode;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            half4 frag(ApexVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexSurfaceData surface = ApexWorldBuildVertexBlendSurface(
                    i,
                    _LayerABase, _LayerABase_ST, _LayerAColor,
                    _LayerANormal, _LayerANormal_ST,
                    _LayerAMask, _LayerAMask_ST,
                    _LayerBBase, _LayerBBase_ST, _LayerBColor,
                    _LayerBNormal, _LayerBNormal_ST,
                    _LayerBMask, _LayerBMask_ST,
                    _NormalScale,
                    _LayerAMetallic, _LayerASmoothness,
                    _LayerBMetallic, _LayerBSmoothness,
                    _OcclusionStrength,
                    _BlendBias, _BlendContrast,
                    _EmissionColor
                );
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                ApexLightingData lighting = ApexBuildLight(i, surface, attenuation, 1.0h);
                half3 color = ApexEvaluateBaseLighting(surface, lighting) + surface.emission;
                color += ApexSampleEnvironmentReflection(surface, lighting, i.worldPos, _EnvironmentStrength);
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

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Packing.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Surface.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"
            #include "Packages/com.dazi.apex.world/Runtime/HLSL/ApexWorld_VertexBlend.cginc"

            sampler2D _LayerABase; float4 _LayerABase_ST;
            sampler2D _LayerANormal; float4 _LayerANormal_ST;
            sampler2D _LayerAMask; float4 _LayerAMask_ST;
            sampler2D _LayerBBase; float4 _LayerBBase_ST;
            sampler2D _LayerBNormal; float4 _LayerBNormal_ST;
            sampler2D _LayerBMask; float4 _LayerBMask_ST;
            half4 _LayerAColor;
            half4 _LayerBColor;
            half4 _EmissionColor;
            half _LayerAMetallic;
            half _LayerASmoothness;
            half _LayerBMetallic;
            half _LayerBSmoothness;
            half _NormalScale;
            half _OcclusionStrength;
            half _BlendBias;
            half _BlendContrast;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            half4 fragAdd(ApexVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexSurfaceData surface = ApexWorldBuildVertexBlendSurface(
                    i,
                    _LayerABase, _LayerABase_ST, _LayerAColor,
                    _LayerANormal, _LayerANormal_ST,
                    _LayerAMask, _LayerAMask_ST,
                    _LayerBBase, _LayerBBase_ST, _LayerBColor,
                    _LayerBNormal, _LayerBNormal_ST,
                    _LayerBMask, _LayerBMask_ST,
                    _NormalScale,
                    _LayerAMetallic, _LayerASmoothness,
                    _LayerBMetallic, _LayerBSmoothness,
                    _OcclusionStrength,
                    _BlendBias, _BlendContrast,
                    _EmissionColor
                );
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

            ApexShadowVaryings vertShadow(ApexShadowAttributes v)
            {
                return ApexShadowVert(v, float4(1.0, 1.0, 0.0, 0.0));
            }

            float4 fragShadow(ApexShadowVaryings i) : SV_Target
            {
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

            sampler2D _LayerABase; float4 _LayerABase_ST;
            sampler2D _LayerAMask; float4 _LayerAMask_ST;
            sampler2D _LayerBBase; float4 _LayerBBase_ST;
            sampler2D _LayerBMask; float4 _LayerBMask_ST;
            half4 _LayerAColor;
            half4 _LayerBColor;
            half _BlendBias;
            half _BlendContrast;
            half4 _EmissionColor;

            struct MetaAttributes
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
                float2 uv1 : TEXCOORD1;
                float2 uv2 : TEXCOORD2;
                fixed4 color : COLOR;
            };

            struct MetaVaryings
            {
                float4 pos : SV_POSITION;
                float2 uvA : TEXCOORD0;
                float2 uvB : TEXCOORD1;
                float2 maskUvA : TEXCOORD2;
                float2 maskUvB : TEXCOORD3;
                half blend : TEXCOORD4;
            };

            MetaVaryings vertMeta(MetaAttributes v)
            {
                MetaVaryings o;
                o.pos = UnityMetaVertexPosition(v.vertex, v.uv1, v.uv2, unity_LightmapST, unity_DynamicLightmapST);
                o.uvA = v.uv0 * _LayerABase_ST.xy + _LayerABase_ST.zw;
                o.uvB = v.uv0 * _LayerBBase_ST.xy + _LayerBBase_ST.zw;
                o.maskUvA = v.uv0 * _LayerAMask_ST.xy + _LayerAMask_ST.zw;
                o.maskUvB = v.uv0 * _LayerBMask_ST.xy + _LayerBMask_ST.zw;
                o.blend = saturate((saturate(v.color.r + _BlendBias) - 0.5h) * max(_BlendContrast, 0.01h) + 0.5h);
                return o;
            }

            half4 fragMeta(MetaVaryings i) : SV_Target
            {
                half3 albedoA = tex2D(_LayerABase, i.uvA).rgb * _LayerAColor.rgb;
                half3 albedoB = tex2D(_LayerBBase, i.uvB).rgb * _LayerBColor.rgb;
                half effectMaskA = tex2D(_LayerAMask, i.maskUvA).b;
                half effectMaskB = tex2D(_LayerBMask, i.maskUvB).b;
                half effectMask = lerp(effectMaskA, effectMaskB, i.blend);

                UnityMetaInput meta;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, meta);
                meta.Albedo = lerp(albedoA, albedoB, i.blend);
                meta.Emission = _EmissionColor.rgb * _EmissionColor.a * effectMask;
                return UnityMetaFragment(meta);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
