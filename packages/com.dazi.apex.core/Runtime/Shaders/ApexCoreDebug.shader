Shader "Apex/Core/Debug"
{
    Properties
    {
        _BaseMap("Base Map", 2D) = "white" {}
        _BaseColor("Base Color", Color) = (1,1,1,1)
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry" }
        LOD 100
        Pass
        {
            Name "FORWARD_BASE"
            Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            #pragma target 2.0
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #pragma multi_compile_instancing
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            sampler2D _BaseMap; float4 _BaseMap_ST; half4 _BaseColor;
            ApexUnlitVaryings vert(ApexAttributes v){ return ApexCoreUnlitVert(v); }
            half4 frag(ApexUnlitVaryings i) : SV_Target
            {
                UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(i);
                half4 c = tex2D(_BaseMap, TRANSFORM_TEX(i.uv0, _BaseMap)) * _BaseColor;
                c.rgb = ApexApplyFog(i, c.rgb);
                return c;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
