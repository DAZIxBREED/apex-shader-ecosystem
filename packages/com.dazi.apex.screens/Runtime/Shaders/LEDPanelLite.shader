Shader "Apex/Screens/LEDPanelLite"
{
    Properties
    {
        [NoScaleOffset] _MainTex("Video Texture", 2D) = "black" {}
        _Tint("Tint", Color) = (1,1,1,1)
        _UVRect("UV Rect (Offset XY, Scale ZW)", Vector) = (0,0,1,1)
        [Toggle] _FlipX("Flip Horizontally", Float) = 0
        [Toggle] _FlipY("Flip Vertically", Float) = 0
        _PixelCount("LED Pixel Count XY", Vector) = (128,72,0,0)
        _PixelGap("LED Gap", Range(0,0.9)) = 0.12
        _SubpixelStrength("RGB Subpixel Strength", Range(0,1)) = 0.2
        _Brightness("Brightness", Range(0,6)) = 1
        _Contrast("Contrast", Range(0,2)) = 1
        _Saturation("Saturation", Range(0,2)) = 1
        _Gamma("Gamma", Range(0.25,4)) = 1
        [HDR] _EmissionColor("Emission Multiplier", Color) = (1,1,1,1)
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _SpectraGroup("Spectra Group (0 = Broadcast)", Float) = 0
        _SpectraBandWeights("Spectra Band Weights", Vector) = (0.25,0.25,0.25,0.25)
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 120
        Cull Back
        ZWrite On

        Pass
        {
            Name "LED_PANEL"
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
            half4 _PixelCount;
            half4 _EmissionColor;
            half _FlipX;
            half _FlipY;
            half _PixelGap;
            half _SubpixelStrength;
            half _Brightness;
            half _Contrast;
            half _Saturation;
            half _Gamma;
            half _SpectraAmount;
            half _SpectraGroup;
            half4 _SpectraBandWeights;

            ApexUnlitVaryings vert(ApexAttributes v) { return ApexCoreUnlitVert(v); }

            half4 frag(ApexUnlitVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                half2 uv = ApexScreenUV(i.uv0, _UVRect, _FlipX, _FlipY);
                half2 pixelCount = max(_PixelCount.xy, half2(1.0h, 1.0h));
                half2 sampleUV = ApexScreenPixelCenterUV(uv, pixelCount);
                half4 video = tex2D(_MainTex, sampleUV) * _Tint;
                half3 color = ApexGradeScreen(video.rgb, _Brightness, _Contrast, _Saturation, _Gamma);
                half aperture = ApexScreenPixelAperture(uv, pixelCount, _PixelGap);
                color *= aperture * ApexScreenRGBSubpixelMask(uv, pixelCount, _SubpixelStrength);
                color *= _EmissionColor.rgb;
                color = ApexSpectraTint(color, _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color += ApexSpectraEmission(half3(0.0h, 0.0h, 0.0h), aperture * _SpectraAmount, _SpectraGroup, _SpectraBandWeights);
                color = ApexApplyFog(i, color);
                return half4(color, video.a);
            }
            ENDCG
        }
    }

    Fallback "Unlit/Texture"
}
