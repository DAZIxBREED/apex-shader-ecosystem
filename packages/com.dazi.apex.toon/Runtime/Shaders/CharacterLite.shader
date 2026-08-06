Shader "Apex/Toon/CharacterLite"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
        _NormalMap("Normal Map", 2D) = "bump" {}
        _NormalScale("Normal Scale", Range(0,2)) = 1
        _MaskMap("Mask Map R Metallic G AO B Mask A Smoothness", 2D) = "white" {}
        _EmissionColor("Emission Color", Color) = (0,0,0,0)
        _SpectraAmount("SpectraOverdrive Amount", Range(0,1)) = 0
        _DebugMode("Debug Mode", Int) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 150
        Pass
        {
            Name "FORWARD_BASE"
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Packing.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Lighting.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Platform.cginc"
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Debug.cginc"
            #include "Packages/com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
            #include "Packages/com.dazi.apex.toon/Runtime/HLSL/ApexToon_Surface.cginc"

            sampler2D _BaseMap; float4 _BaseMap_ST;
            sampler2D _NormalMap; float4 _NormalMap_ST;
            sampler2D _MaskMap; float4 _MaskMap_ST;
            fixed4 _BaseColor;
            fixed4 _EmissionColor;
            half _NormalScale;
            half _SpectraAmount;
            int _DebugMode;

            ApexVaryings vert(ApexAttributes v) { return ApexCoreVert(v); }

            fixed4 frag(ApexVaryings i) : SV_Target
            {
                ApexSurfaceData s = ApexToonBuildSurface(i, _BaseMap, _BaseMap_ST, _BaseColor, _NormalMap, _NormalMap_ST, _NormalScale, _MaskMap, _MaskMap_ST, _EmissionColor);
                ApexLightingData l = ApexBuildMainLight(i, s);
                half3 color = ApexLambert(s, l) + s.emission;
                color = ApexToonFinish(color, s, i, _SpectraAmount);
                color = ApexDebugColor(_DebugMode, s, i, color);
                color = ApexApplyFog(i, color);
                return fixed4(color, s.alpha);
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
