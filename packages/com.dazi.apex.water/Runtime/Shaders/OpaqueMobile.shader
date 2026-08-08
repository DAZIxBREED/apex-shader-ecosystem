Shader "Apex/Water/OpaqueMobile"
{
    Properties
    {
        _BaseMap("Base Texture", 2D) = "white" {}
        _BaseColor("Base Tint", Color) = (0.35,0.75,0.85,1)
        _NormalMap("Water Normal", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0,2)) = 0.65
        _NormalSpeedA("Normal Speed A", Vector) = (0.025,0.015,0,0)
        _NormalSpeedB("Normal Speed B", Vector) = (-0.015,0.02,0,0)
        _NormalBlend("Second Normal Strength", Range(0,1)) = 0.5
        _MaskMap("R Depth, B Foam/Effect", 2D) = "white" {}
        _ShallowColor("Shallow Tint", Color) = (0.15,0.85,0.8,1)
        _DeepColor("Deep Tint", Color) = (0.01,0.08,0.22,1)
        _Smoothness("Smoothness", Range(0,1)) = 0.8
        _FresnelColor("Fresnel Color", Color) = (0.65,0.9,1,1)
        _FresnelPower("Fresnel Power", Range(0.5,8)) = 3
        _FresnelStrength("Fresnel Strength", Range(0,1)) = 0.35
        _FoamColor("Foam Color", Color) = (0.8,0.95,1,1)
        _FoamStrength("Foam Strength", Range(0,2)) = 0.6
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.5,0.3,0.15,0.05)
        [Enum(Off,0,Albedo,1,Normals,2,MOS,3,UV,4,VertexColor,5,Emission,6,EffectMask,7,BakedGI,8)] _DebugMode("Debug View", Int) = 0
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+20" }
        LOD 160
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

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Surface.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Debug.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Platform.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.water/Runtime/HLSL/ApexWater_Surface.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _NormalMap; float4 _NormalMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            half4 _BaseColor;
            half4 _ShallowColor;
            half4 _DeepColor;
            half4 _FresnelColor;
            half4 _FoamColor;
            half _NormalScale;
            half2 _NormalSpeedA;
            half2 _NormalSpeedB;
            half _NormalBlend;
            half _Smoothness;
            half _FresnelPower;
            half _FresnelStrength;
            half _FoamStrength;
            half _SpectraAmount;
            half _SpectraGroup;
            half4 _SpectraBandWeights;
            int _DebugMode;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            half4 frag(ApexVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexSurfaceData surface = ApexWaterBuildSurface(
                    i,
                    _BaseMap, _BaseMap_ST, _BaseColor,
                    _NormalMap, _NormalMap_ST, _NormalScale,
                    _MaskMap, _MaskMap_ST,
                    _NormalSpeedA, _NormalSpeedB, _NormalBlend,
                    _ShallowColor.rgb, _DeepColor.rgb,
                    _Smoothness, 1.0h
                );
                surface.alpha = 1.0h;
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                ApexLightingData lighting = ApexBuildLight(i, surface, attenuation, 1.0h);
                half3 color = ApexEvaluateBaseLighting(surface, lighting);
                color = ApexWaterFinish(
                    color, surface, i,
                    _FresnelColor.rgb, _FresnelPower, _FresnelStrength,
                    _FoamColor.rgb, _FoamStrength,
                    _SpectraAmount, _SpectraGroup, _SpectraBandWeights
                );
                color = ApexDebugColor(_DebugMode, surface, i, color);
                color = ApexApplyFog(i, color);
                return half4(color, 1.0h);
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
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Surface.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Platform.cginc"
            #include "Packages/com.dazi.apex.water/Runtime/HLSL/ApexWater_Surface.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _NormalMap; float4 _NormalMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            half4 _BaseColor;
            half4 _ShallowColor;
            half4 _DeepColor;
            half _NormalScale;
            half2 _NormalSpeedA;
            half2 _NormalSpeedB;
            half _NormalBlend;
            half _Smoothness;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            half4 fragAdd(ApexVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexSurfaceData surface = ApexWaterBuildSurface(
                    i,
                    _BaseMap, _BaseMap_ST, _BaseColor,
                    _NormalMap, _NormalMap_ST, _NormalScale,
                    _MaskMap, _MaskMap_ST,
                    _NormalSpeedA, _NormalSpeedB, _NormalBlend,
                    _ShallowColor.rgb, _DeepColor.rgb,
                    _Smoothness, 1.0h
                );
                UNITY_LIGHT_ATTENUATION(attenuation, i, i.worldPos);
                ApexLightingData lighting = ApexBuildLight(i, surface, attenuation, 0.0h);
                half3 color = ApexEvaluateAddLighting(surface, lighting);
                color = ApexApplyFog(i, color);
                return half4(color, 0.0h);
            }
            ENDCG
        }
    }

    Fallback "Diffuse"
}
