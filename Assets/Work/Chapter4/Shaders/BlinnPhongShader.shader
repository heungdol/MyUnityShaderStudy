Shader "MyShader/Chapter4/BlinnPhongShader"
{
    Properties
    {
        _MainTint ("Diffuse Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Base", 2D) = "white" {}
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecPower ("Specular Power", Range (0.1, 60)) = 3
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf CustomBlinnPhong
        #pragma target 3.0

        struct Input
        {
            float2 uv_MainTex;
        };

        sampler2D _MainTex;
        float4 _MainTint;
        float4 _SpecularColor;
        float _SpecPower;

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutput o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        fixed4 LightingCustomBlinnPhong 
        (SurfaceOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            float3 halfVector = normalize (lightDir + viewDir);

            float NdotL = max (0, dot (s.Normal, lightDir));
            float NdotH = max (0, dot (s.Normal, halfVector));

            float spec = pow (NdotH, _SpecPower) * _SpecularColor;

            float4 color;
            color.rgb = (s.Albedo * _LightColor0.rgb * NdotL) + (_LightColor0.rgb * _SpecularColor.rgb * spec) * atten;
            color.a = s.Alpha;
            return color;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
