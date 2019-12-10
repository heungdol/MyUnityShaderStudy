Shader "MyShader/NormalShader"
{
    Properties
    {
        _MainTint ("Diffuse Tint", Color) = (0, 1, 0, 1)
        _NormalTex ("Normal Map", 2D) = "bump" {}
        _NormalMapIntensity ("Normal intensity", Range (0, 3)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard fullforwardshadows
        #pragma target 3.0

        float4 _MainTint;
        float _NormalMapIntensity;
        sampler2D _NormalTex;

        struct Input
        {
            float2 uv_NormalTex;
        };

        UNITY_INSTANCING_BUFFER_START(Props)
        UNITY_INSTANCING_BUFFER_END(Props)
        
        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float3 normalMap = UnpackNormal (tex2D (_NormalTex, IN.uv_NormalTex));
            normalMap.x *= _NormalMapIntensity;
            normalMap.y *= _NormalMapIntensity;

            o.Albedo = _MainTint;
            o.Normal = normalize (normalMap);
        }

        ENDCG
    }
    FallBack "Diffuse"
}
