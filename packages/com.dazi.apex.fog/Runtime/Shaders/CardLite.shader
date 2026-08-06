Shader "Apex/Fog/CardLite"
{
    Properties
    {
        _NoiseMap("Noise Texture", 2D) = "white" {}
        _MaskMap("Shape Mask", 2D) = "white" {}
        [HDR] _FogColor("Fog Color", Color) = (0.45,0.55,0.7,1)
        _Density("Density", Range(0,3)) = 0.5
        _SpeedA("Noise Speed A", Vector) = (0.01,0.005,0,0)
        _SpeedB("Noise Speed B", Vector) = (-0.007,0.012,0,0)
        _DistanceStart("Near Fade Start", Float) = 0.5
        _DistanceEnd("Near Fade End", Float) = 3
        _HeightMinimum("Full Density Height", Float) = -100
        _HeightMaximum("Zero Density Height", Float) = 100
        _EdgePower("View Edge Softness", Range(0.1,8)) = 1.5
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.4,0.35,0.2,0.05)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent+10" "IgnoreProjector"="True" }
        LOD 100
        Blend SrcAlpha OneMinusSrcAlpha
        ZWrite Off
        Cull Off

        Pass
        {
            Name "UNLIT_FOG"
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Platform.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.fog/Runtime/HLSL/ApexFog_Surface.cginc"

            sampler2D _NoiseMap; float4 _NoiseMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            half4 _FogColor;
            half _Density;
            half2 _SpeedA;
            half2 _SpeedB;
            half _DistanceStart;
            half _DistanceEnd;
            half _HeightMinimum;
            half _HeightMaximum;
            half _EdgePower;
            half _SpectraAmount;
            half _SpectraGroup;
            half4 _SpectraBandWeights;

            ApexUnlitVaryings vert(ApexAttributes v) { return ApexCoreUnlitVert(v); }

            half4 frag(ApexUnlitVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                ApexFogData fog = ApexBuildFog(
                    i,
                    _NoiseMap, _NoiseMap_ST,
                    _MaskMap, _MaskMap_ST,
                    _SpeedA, _SpeedB,
                    _Density, _FogColor.rgb,
                    _DistanceStart, _DistanceEnd,
                    _HeightMinimum, _HeightMaximum,
                    _EdgePower
                );
                half3 color = ApexSpectraTint(fog.color, _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), fog.noise * _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color = ApexApplyFog(i, color);
                return half4(color, fog.alpha * _FogColor.a);
            }
            ENDCG
        }
    }

    Fallback Off
}
