Shader "Apex/FX/HologramLite"
{
    Properties
    {
        _BaseMap("Hologram Texture", 2D) = "white" {}
        [HDR] _BaseColor("Hologram Color", Color) = (0.05,0.75,1,0.65)
        _MaskMap("Effect Mask", 2D) = "white" {}
        _Opacity("Opacity", Range(0,1)) = 0.65
        _ScanlineDensity("Scanline Density", Range(1,200)) = 45
        _ScanlineSpeed("Scanline Speed", Range(-10,10)) = 1.5
        _ScanlineSharpness("Scanline Sharpness", Range(0.1,8)) = 3
        _ScanlineStrength("Scanline Strength", Range(0,2)) = 0.7
        _FresnelPower("Fresnel Power", Range(0.5,8)) = 2
        _FresnelStrength("Fresnel Strength", Range(0,3)) = 1
        _FlickerAmount("Flicker Amount", Range(0,1)) = 0.08
        _FlickerSpeed("Flicker Speed", Range(1,60)) = 20
        _GlitchStrength("Vertex Glitch Strength", Range(0,0.1)) = 0.005
        _GlitchDensity("Vertex Glitch Density", Range(1,100)) = 35
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.1,0.3,0.4,0.2)
    }

    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent+20" "IgnoreProjector"="True" }
        LOD 150
        Blend SrcAlpha One
        ZWrite Off
        Cull Back

        Pass
        {
            Name "HOLOGRAM"
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma target 3.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.fx/Runtime/HLSL/ApexFX_Surface.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            half4 _BaseColor;
            half _Opacity;
            half _ScanlineDensity;
            half _ScanlineSpeed;
            half _ScanlineSharpness;
            half _ScanlineStrength;
            half _FresnelPower;
            half _FresnelStrength;
            half _FlickerAmount;
            half _FlickerSpeed;
            half _GlitchStrength;
            half _GlitchDensity;
            half _SpectraAmount;
            half _SpectraGroup;
            half4 _SpectraBandWeights;

            ApexUnlitVaryings vert(ApexAttributes v)
            {
                half band = step(0.96h, frac(v.vertex.y * _GlitchDensity + (half)_Time.y * 3.0h));
                half glitch = sin((half)_Time.y * 23.0h + v.vertex.y * 11.0h) * _GlitchStrength * band;
                v.vertex.xz += glitch;
                return ApexCoreUnlitVert(v);
            }

            half4 frag(ApexUnlitVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                half4 baseSample = tex2D(_BaseMap, TRANSFORM_TEX(i.uv0, _BaseMap));
                half mask = tex2D(_MaskMap, TRANSFORM_TEX(i.uv0, _MaskMap)).r;
                half scanline = ApexHologramScanline(i.worldPos, _ScanlineDensity, _ScanlineSpeed, _ScanlineSharpness);
                half fresnel = ApexFresnel(ApexSafeNormalize(i.worldNormal), ApexGetViewDirection(i), _FresnelPower);
                half flicker = ApexHologramFlicker(_FlickerAmount, _FlickerSpeed);

                half3 color = baseSample.rgb * _BaseColor.rgb;
                color *= 1.0h + scanline * _ScanlineStrength + fresnel * _FresnelStrength;
                color *= flicker;
                color = ApexSpectraTint(color, _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), mask * _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color = ApexApplyFog(i, color);

                half alpha = baseSample.a * _BaseColor.a * _Opacity * mask;
                alpha *= saturate(0.35h + scanline + fresnel);
                return half4(color, alpha);
            }
            ENDCG
        }
    }

    Fallback Off
}
