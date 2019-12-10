Shader "MyShader/ScrollingUVs"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _ScrollXSpeed ("X Scroll Speed", Range (0, 10)) = 2
        _ScrollYSpeed ("Y Scroll Speed", Range (0, 10)) = 2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

         struct Input
        {
            float2 uv_MainTex;
        };

        fixed4 _Color;

        fixed _ScrollXSpeed;
        float _ScrollYSpeed;
        sampler2D _MainTex;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed2 scrolledUV = IN.uv_MainTex;

            fixed xScrollValue = _ScrollXSpeed * _Time;
            fixed yScrollValue = _ScrollYSpeed * _Time;

            scrolledUV += fixed2 (xScrollValue, yScrollValue);

            half4 c = tex2D (_MainTex, scrolledUV);
            o.Albedo = c.rgb;
            o.Alpha =c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
