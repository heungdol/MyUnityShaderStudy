Shader "MyShader/Custom/Object_PatternTint"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}

        _PatternTex ("Pattern Texture", 2D) = "white" {}
        _PatternColor ("Pattern Color", Color) = (0, 0, 0, 0)
        _PatternScale ("Pattern Scale", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        CGPROGRAM
        #pragma surface surf Lambert

        struct Input {
          float2 uv_MainTex;
          float2 uv_PatternTex;
        };

        sampler2D _MainTex;

        sampler2D _PatternTex;
        float4 _PatternColor;
        float _PatternScale;

        void surf (Input IN, inout SurfaceOutput o) {
            float2 patternUV = IN.uv_PatternTex * _PatternScale;
            float patternCol = tex2D (_PatternTex, patternUV).r;

            float3 resultCol;
            float3 mainCol = tex2D (_MainTex, IN.uv_MainTex).rgb;

            resultCol = (patternCol * _PatternColor.a) * _PatternColor.rgb + (1 - patternCol * _PatternColor.a) * mainCol.rgb;
            o.Albedo = resultCol;
            o.Alpha = 1;
        }
      ENDCG
    }
}
