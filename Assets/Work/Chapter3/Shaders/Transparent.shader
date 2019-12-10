Shader "MyShader/Transparent"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
    }
    SubShader
    {
        Tags 
        { 
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderType"="Transparent" 
        }

        LOD 200

        Cull Back

        CGPROGRAM
        #pragma surface surf Standard alpha:fade

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float4 c = tex2D (_MainTex, IN.uv_MainTex) *  _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
