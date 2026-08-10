Shader "Apex/FX/DissolveCutout"
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
        _DissolveMap("Dissolve Noise", 2D) = "gray" {}
        _DissolveAmount("Dissolve Amount", Range(0,1)) = 0
        _EdgeWidth("Dissolve Edge Width", Range(0.001,0.25)) = 0.04
        [HDR] _EdgeColor("Dissolve Edge Color", Color) = (1,0.2,0.02,4)
        [HDR] _EmissionColor("Mask Emission", Color) = (0,0,0,0)
        [KeywordEnum(Standard,Mobile,High)] _APEX_QUALITY("Apex Quality Profile", Float) = 0
        _EnvironmentStrength("Reflection Probe Strength", Range(0,2)) = 0.5
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.15,0.35,0.35,0.15)
        [Enum(Off,0,Albedo,1,Normals,2,MOS,3,UV,4,VertexColor,5,Emission,6,EffectMask,7,BakedGI,8)] _DebugMode("Debug View", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType"="TransparentCutout" "Queue"="AlphaTest+10" }
        LOD 250
        Cull Back
        ZWrite On

        Pass
        {
            Name "FORWARD_BASE"
            Tags { "LightMode"="ForwardBase" }

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
            #include "Packages/com.dazi.apex.fx/Runtime/HLSL/ApexFX_Dissolve.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _NormalMap; float4 _NormalMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            sampler2D _DissolveMap; float4 _DissolveMap_ST;
            half4 _BaseColor;
            half4 _EdgeColor;
            half4 _EmissionColor;
            half _NormalScale;
            half _Metallic;
            half _Smoothness;
            half _OcclusionStrength;
            half _DissolveAmount;
            half _EdgeWidth;
            half _EnvironmentStrength;
            half _SpectraAmount;
            half _SpectraGroup;
            half4 _SpectraBandWeights;
            int _DebugMode;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            half4 frag(ApexVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexSurfaceData surface = ApexBuildPackedSurface(
                    i,
                    _BaseMap, _BaseMap_ST, _BaseColor,
                    _NormalMap, _NormalMap_ST, _NormalScale,
                    _MaskMap, _MaskMap_ST,
                    _Metallic, _OcclusionStrength, _Smoothness,
                    _EmissionColor
                );
                half noiseValue = tex2D(_DissolveMap, i.uv0 * _DissolveMap_ST.xy + _DissolveMap_ST.zw).r;
                clip(ApexDissolveClipValue(noiseValue, _DissolveAmount));
                half edge = ApexDissolveEdge(noiseValue, _DissolveAmount, _EdgeWidth);

                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                ApexLightingData lighting = ApexBuildLight(i, surface, attenuation, 1.0h);
                half3 color = ApexEvaluateBaseLighting(surface, lighting) + surface.emission;
                color += ApexSampleEnvironmentReflection(surface, lighting, i.worldPos, _EnvironmentStrength);
                color += _EdgeColor.rgb * _EdgeColor.a * edge;
                color = ApexSpectraTint(color, _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), max(surface.mask, edge) * _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
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
            #include "Packages/com.dazi.apex.fx/Runtime/HLSL/ApexFX_Dissolve.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _NormalMap; float4 _NormalMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            sampler2D _DissolveMap; float4 _DissolveMap_ST;
            half4 _BaseColor;
            half4 _EmissionColor;
            half _NormalScale;
            half _Metallic;
            half _Smoothness;
            half _OcclusionStrength;
            half _DissolveAmount;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            half4 fragAdd(ApexVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexSurfaceData surface = ApexBuildPackedSurface(
                    i,
                    _BaseMap, _BaseMap_ST, _BaseColor,
                    _NormalMap, _NormalMap_ST, _NormalScale,
                    _MaskMap, _MaskMap_ST,
                    _Metallic, _OcclusionStrength, _Smoothness,
                    _EmissionColor
                );
                half noiseValue = tex2D(_DissolveMap, i.uv0 * _DissolveMap_ST.xy + _DissolveMap_ST.zw).r;
                clip(ApexDissolveClipValue(noiseValue, _DissolveAmount));
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
            #include "Packages/com.dazi.apex.fx/Runtime/HLSL/ApexFX_Dissolve.cginc"

            sampler2D _DissolveMap; float4 _DissolveMap_ST;
            half _DissolveAmount;

            ApexShadowVaryings vertShadow(ApexShadowAttributes v)
            {
                return ApexShadowVert(v, _DissolveMap_ST);
            }

            float4 fragShadow(ApexShadowVaryings i) : SV_Target
            {
                half noiseValue = tex2D(_DissolveMap, i.uv0).r;
                clip(ApexDissolveClipValue(noiseValue, _DissolveAmount));
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
            #include "Packages/com.dazi.apex.fx/Runtime/HLSL/ApexFX_Dissolve.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _DissolveMap; float4 _DissolveMap_ST;
            half4 _BaseColor;
            half4 _EmissionColor;
            half4 _EdgeColor;
            half _DissolveAmount;
            half _EdgeWidth;

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
                float2 baseUV : TEXCOORD0;
                float2 dissolveUV : TEXCOORD1;
                fixed4 vertexColor : COLOR;
            };

            MetaVaryings vertMeta(MetaAttributes v)
            {
                MetaVaryings o;
                o.pos = UnityMetaVertexPosition(v.vertex, v.uv1, v.uv2, unity_LightmapST, unity_DynamicLightmapST);
                o.baseUV = v.uv0 * _BaseMap_ST.xy + _BaseMap_ST.zw;
                o.dissolveUV = v.uv0 * _DissolveMap_ST.xy + _DissolveMap_ST.zw;
                o.vertexColor = v.color;
                return o;
            }

            half4 fragMeta(MetaVaryings i) : SV_Target
            {
                half noiseValue = tex2D(_DissolveMap, i.dissolveUV).r;
                clip(ApexDissolveClipValue(noiseValue, _DissolveAmount));
                half edge = ApexDissolveEdge(noiseValue, _DissolveAmount, _EdgeWidth);
                half3 baseColor = tex2D(_BaseMap, i.baseUV).rgb * _BaseColor.rgb * i.vertexColor.rgb;
                UnityMetaInput meta;
                UNITY_INITIALIZE_OUTPUT(UnityMetaInput, meta);
                meta.Albedo = baseColor;
                meta.Emission = _EmissionColor.rgb * _EmissionColor.a + _EdgeColor.rgb * _EdgeColor.a * edge;
                return UnityMetaFragment(meta);
            }
            ENDCG
        }
    }

    Fallback "Transparent/Cutout/Diffuse"
}
