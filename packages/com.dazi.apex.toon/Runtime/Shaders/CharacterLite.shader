Shader "Apex/Toon/CharacterLite"
{
    Properties
    {
        _MainTex("Base Map", 2D) = "white" {}
        _Color("Base Color", Color) = (1,1,1,1)
        _BumpMap("Normal Map", 2D) = "bump" {}
        _BumpScale("Normal Scale", Range(0,2)) = 1
        _MetallicGlossMap("Mask: G AO, B Effect", 2D) = "white" {}
        _OcclusionStrength("Occlusion Strength", Range(0,1)) = 1
        [HDR] _EmissionColor("Emission Color", Color) = (0,0,0,0)
        _Bands("Lighting Bands", Range(1,5)) = 3
        _ShadowThreshold("Shadow Threshold", Range(0,1)) = 0.5
        _ShadowSoftness("Shadow Softness", Range(0.001,0.25)) = 0.04
        _ShadowColor("Shadow Color", Color) = (0.35,0.38,0.55,1)
        _SpecularSize("Specular Size", Range(0.001,0.5)) = 0.08
        _SpecularIntensity("Specular Intensity", Range(0,2)) = 0.35
        [HDR] _RimColor("Rim Color", Color) = (0.35,0.55,1,1)
        _RimPower("Rim Power", Range(0.5,8)) = 3
        _RimIntensity("Rim Intensity", Range(0,2)) = 0.25
        [Toggle] _AlphaClip("Alpha Clip", Float) = 0
        _Cutoff("Alpha Cutoff", Range(0,1)) = 0.5
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.25,0.25,0.25,0.25)
        [Enum(Off,0,Albedo,1,Normals,2,MOS,3,UV,4,VertexColor,5,Emission,6,EffectMask,7,BakedGI,8)] _DebugMode("Debug View", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" "VRCFallback"="toonstandard" }
        LOD 200

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

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Packing.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Surface.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Debug.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.toon/Runtime/HLSL/ApexToon_Surface.cginc"

            sampler2D _MainTex; float4 _MainTex_ST;
            sampler2D _BumpMap; float4 _BumpMap_ST;
            sampler2D _MetallicGlossMap; float4 _MetallicGlossMap_ST;
            half4 _Color;
            half4 _EmissionColor;
            half4 _ShadowColor;
            half4 _RimColor;
            half _BumpScale;
            half _OcclusionStrength;
            half _Bands;
            half _ShadowThreshold;
            half _ShadowSoftness;
            half _SpecularSize;
            half _SpecularIntensity;
            half _RimPower;
            half _RimIntensity;
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
                ApexSurfaceData surface = ApexToonBuildSurface(
                    i,
                    _MainTex, _MainTex_ST, _Color,
                    _BumpMap, _BumpMap_ST, _BumpScale,
                    _MetallicGlossMap, _MetallicGlossMap_ST,
                    _OcclusionStrength, _EmissionColor
                );
                ApexApplyAlphaClip(surface.alpha, _Cutoff, _AlphaClip);
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                ApexLightingData lighting = ApexBuildLight(i, surface, attenuation, 1.0h);
                half3 color = ApexEvaluateToon(
                    surface, lighting,
                    _Bands, _ShadowThreshold, _ShadowSoftness,
                    _ShadowColor.rgb,
                    _SpecularSize, _SpecularIntensity
                );
                color = ApexToonFinish(
                    color, surface, lighting,
                    _RimColor.rgb, _RimPower, _RimIntensity,
                    _SpectraAmount, _SpectraGroup, _SpectraBandWeights
                );
                color = ApexDebugColor(_DebugMode, surface, i, color);
                color = ApexApplyFog(i, color);
                return half4(color, surface.alpha);
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
            sampler2D _MainTex;
            float4 _MainTex_ST;
            half4 _Color;
            half _AlphaClip;
            half _Cutoff;

            ApexShadowVaryings vertShadow(ApexShadowAttributes v)
            {
                return ApexShadowVert(v, _MainTex_ST);
            }

            float4 fragShadow(ApexShadowVaryings i) : SV_Target
            {
                half alpha = tex2D(_MainTex, i.uv0).a * _Color.a;
                half clipValue = lerp(1.0h, alpha - _Cutoff, step(0.5h, _AlphaClip));
                clip(clipValue);
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
