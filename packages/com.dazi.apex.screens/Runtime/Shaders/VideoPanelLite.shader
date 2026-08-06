Shader "Apex/Screens/VideoPanelLite"
{
    Properties
    {
        [NoScaleOffset] _MainTex("Video Texture", 2D) = "black" {}
        _Tint("Tint", Color) = (1,1,1,1)
        _UVRect("UV Rect (Offset XY, Scale ZW)", Vector) = (0,0,1,1)
        [Toggle] _FlipX("Flip Horizontally", Float) = 0
        [Toggle] _FlipY("Flip Vertically", Float) = 0
        _Brightness("Brightness", Range(0,4)) = 1
        _Contrast("Contrast", Range(0,2)) = 1
        _Saturation("Saturation", Range(0,2)) = 1
        _Gamma("Gamma", Range(0.25,4)) = 1
        _ScanlineStrength("Scanline Strength", Range(0,1)) = 0
        _ScanlineDensity("Scanline Density", Range(1,1000)) = 240
        _VignetteStrength("Vignette Strength", Range(0,1)) = 0
        _VignetteSoftness("Vignette Softness", Range(0.01,1)) = 0.25
        [HDR] _EmissionColor("Emission Multiplier", Color) = (1,1,1,1)
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.25,0.25,0.25,0.25)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        Cull Back
        ZWrite On

        Pass
        {
            Name "VIDEO_PANEL"
            Tags { "LightMode"="ForwardBase" }

            CGPROGRAM
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing

            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.screens/Runtime/HLSL/ApexScreens_Surface.cginc"

            sampler2D _MainTex;
            half4 _Tint;
            half4 _UVRect;
            half _FlipX;
            half _FlipY;
            half _Brightness;
            half _Contrast;
            half _Saturation;
            half _Gamma;
            half _ScanlineStrength;
            half _ScanlineDensity;
            half _VignetteStrength;
            half _VignetteSoftness;
            half4 _EmissionColor;
            half _SpectraAmount;
            half _SpectraGroup;
            half4 _SpectraBandWeights;

            ApexUnlitVaryings vert(ApexAttributes v) { return ApexCoreUnlitVert(v); }

            half4 frag(ApexUnlitVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                half2 uv = ApexScreenUV(i.uv0, _UVRect, _FlipX, _FlipY);
                half4 video = tex2D(_MainTex, uv) * _Tint;
                half3 color = ApexGradeScreen(video.rgb, _Brightness, _Contrast, _Saturation, _Gamma);

                half scanline = 1.0h - _ScanlineStrength * (0.5h + 0.5h * sin(uv.y * _ScanlineDensity * 6.2831853h));
                half vignette = ApexScreenVignette(uv, _VignetteStrength, _VignetteSoftness);
                color *= scanline * vignette * _EmissionColor.rgb;
                color = ApexSpectraTint(color, _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color = ApexApplyFog(i, color);
                return half4(color, video.a);
            }
            ENDCG
        }
    }

    Fallback "Unlit/Texture"
}
