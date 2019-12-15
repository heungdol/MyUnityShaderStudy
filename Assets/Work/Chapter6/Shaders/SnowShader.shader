Shader "MyShader/Chapter6/SnowShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Bump ("Bump", 2D) = "bump" {}
        _Snow ("Level of Snow", Range (1, -1)) = 1
        _SnowColor ("Color of Snow", Color) = (1, 1, 1, 1)
        _SnowDirection ("Direction of Snow", Vector) = (0, 1, 0)
        _SnowDepth ("Depth of Snow", Range (0, 1)) = 0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        #pragma surface surf Standard vertex:vert
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _Bump;
        float _Snow;
        float4 _SnowColor;
        float4 _Color;
        float4 _SnowDirection;
        float _SnowDepth;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_Bump;
            float3 worldNormal;
            INTERNAL_DATA
        };

        void vert (inout appdata_full v)
        {
            // mul: 행렬과 벡터를 곱한 벡터값을 반환
            // (행렬, 행렬) = 행렬
            // (행렬, 벡터) = 벡터
            // (벡터, 행렬) = 행렬
            float4 sn = mul (UNITY_MATRIX_IT_MV, _SnowDirection);
            float NdotSN = dot (v.normal, sn.xyz);

            if (NdotSN >= _Snow)
            {   
                v.vertex.xyz += normalize (sn.xyz + v.normal) * NdotSN * _SnowDepth;
            }
                
        }

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            half4 c = tex2D (_MainTex, IN.uv_MainTex);
            o.Normal = UnpackNormal (tex2D (_Bump, IN.uv_Bump));

            if (dot (WorldNormalVector (IN, o.Normal), _SnowDirection.xyz) >= _Snow)
                o.Albedo = _SnowColor.rgb;
            else
                o.Albedo = c.rgb * _Color;

            o.Alpha = 1; 
        }
        ENDCG
    }
    FallBack "Diffuse"
}
