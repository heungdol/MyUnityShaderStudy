Shader "MyShader/Custom/Object_PatternShadowShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RampTex ("Ramp Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf ToonSytle
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _RampTex;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        
        float4 LightingToonSytle (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        {
            float4 result;

            float lDotN = dot (lightDir, s.Normal);
            lDotN = lDotN * 0.5 + 0.5;

            float aa = atten * atten;

            float2 rampUV = float2 (aa, 0.5);
            float3 rampCol = tex2D (_RampTex, rampUV).rgb;

            

            result.xyz = s.Albedo * rampCol * _LightColor0 * atten;
            result.w = 1;

            return result;
        }

        ENDCG
    }
}
