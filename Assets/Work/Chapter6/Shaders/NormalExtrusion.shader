Shader "MyShader/Chapter6/NormalExtrusion"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _ExtrusionTex ("Extrusion Map", 2D) = "white" {}
        _Amount ("Extrusion Amount", Range (-0.001, 0.001)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _ExtrusionTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        float _Amount;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void vert (inout appdata_full v)
        {
            // vert 함수내에 수정하기 위해선
            // tex2D > tex2Dlod
            // IN.uv_MainTex > v.texcoord.xy
            float4 tex = tex2Dlod (_ExtrusionTex, float4 (v.texcoord.xy, 0, 0));

            float extrusion = tex.r * 2 -1;
            v.vertex.xyz += v.normal * _Amount * extrusion;
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
