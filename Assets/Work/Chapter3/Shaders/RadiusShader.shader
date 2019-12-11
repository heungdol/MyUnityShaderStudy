Shader "MyShader/Chapter3/RadiusShader"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white"{}
        _Center ("Center", Vector) = (200, 0, 200, 0)
        _Radius ("Radius", Float) = 100
        _RadiusColor ("Radius Color", Color) = (1, 0, 0, 1)
        _RadiusWidth ("Radius Width", Float) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        float3 _Center;
        float _Radius;
        float4 _RadiusColor;
        float _RadiusWidth;

        sampler2D _MainTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldPos;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float d = distance (_Center, IN.worldPos);

            if ((d > _Radius) && (d < _Radius + _RadiusWidth))
            {
                o.Albedo = _RadiusColor;
            }
            else
            {
                o.Albedo = tex2D (_MainTex, IN.uv_MainTex).rgb;
            }
        }
        ENDCG
    }
    FallBack "Diffuse"
}
