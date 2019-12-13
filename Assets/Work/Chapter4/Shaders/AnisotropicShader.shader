Shader "MyShader/Chapter4/AnisotropicShader"
{
    Properties
    {
        _MainTint ("Diffuse Tint", Color) = (1, 1, 1, 1)
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _SpecularColor ("Specular Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular Amount", Range (0, 1)) = 0.5
        _SpecPow ("Specular Power", Range (0, 1)) = 0.5
        _AnisoDir ("Anisotropic Direction", 2D) = "bump" {}
        _AnisoOffset ("Anisotropic Offset", Range (-1, 1)) = -0.2
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Anisotropic
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _AnisoDir;
        float4 _MainTint;
        float4 _SpecularColor;
        float _AnisoOffset;
        float _Specular;
        float _SpecPow;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_AnisoDir;
        };

        struct SurfaceAnisoOutput 
        {
            fixed3 Albedo;
            fixed3 Normal;
            fixed3 Emission;
            fixed3 AnisoDirection;
            half Specular;
            fixed Gloss;
            fixed Alpha;
        };

        //UNITY_INSTANCING_BUFFER_START(Props)
        //UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceAnisoOutput o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex) * _MainTint;
            float anisoTex = UnpackNormal (tex2D (_AnisoDir, IN.uv_AnisoDir));

            o.AnisoDirection = anisoTex;
            o.Specular = _Specular;
            o.Gloss = _SpecPow;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }

        fixed4 LightingAnisotropic (SurfaceAnisoOutput s, fixed3 lightDir, half3 viewDir, fixed atten)
        {
            fixed3 halfVector = normalize (normalize (lightDir) + normalize (viewDir));

            float NdotL = saturate (dot (s.Normal, lightDir));
            float HdotA = dot (normalize (s.Normal + s.AnisoDirection), halfVector);

            float aniso = max (0, sin (radians ((HdotA + _AnisoOffset) * 360)));
            float spec = saturate (pow (aniso, s.Gloss * 128) * s.Specular);

            fixed4 c;
            c.rgb = ((s.Albedo * _LightColor0.rgb * NdotL) + (_LightColor0.rgb * _SpecularColor.rgb * spec)) * atten;
            c.a = s.Alpha;

            return c;
        }
        ENDCG
    }
    FallBack "Diffuse"
}
