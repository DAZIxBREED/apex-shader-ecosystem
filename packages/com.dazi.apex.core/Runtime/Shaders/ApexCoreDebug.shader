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
            #include "Packages/com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
            sampler2D _BaseMap; float4 _BaseMap_ST; fixed4 _BaseColor;
            ApexVaryings vert(ApexAttributes v){ return ApexCoreVert(v); }
            fixed4 frag(ApexVaryings i) : SV_Target
            {
                fixed4 c = tex2D(_BaseMap, TRANSFORM_TEX(i.uv0, _BaseMap)) * _BaseColor;
                c.rgb = ApexApplyFog(i, c.rgb);
                return c;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
