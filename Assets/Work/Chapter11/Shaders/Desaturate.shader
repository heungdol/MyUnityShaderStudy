Shader "MyShader/Chapter11/Desaturate"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _DesatValue ("Desaturate", Range (0, 1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        sampler2D _MainTex;
        fixed _DesatValue;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex);
            // Luminance: 흑백
            c.rgb = lerp (c.rgb, Luminance (c.rgb), _DesatValue);
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
