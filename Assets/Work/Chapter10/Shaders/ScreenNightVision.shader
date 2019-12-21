Shader "MyShader/Chapter10/ScreenNightVision"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _VignetteTex ("Vignette Texture", 2D) = "white" {}
        _ScanLineTex ("Scan Line Texture", 2D) = "white" {}
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseXSpeed ("Noise X Speed", Float) = 100
        _NoiseYSpeed ("Noise Y Speed", Float) = 100
        _ScanLineTileAmount ("Scan Line Tile Amount", Float) = 4
        _NightVisionColor ("Night Vision Color", Color) = (1, 1, 1, 1)
        _Contrast ("Contrast", Range (0, 4)) = 2
        _Brightness ("Brightness", Range (0, 2)) = 1
        _RandomValue ("Random Value", Float) = 0
        _Distortion ("Distrotion", Float) = 2
        _Scale ("Scale", Float) = 0.8
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert_img // 미리 정의되어 있는 vert_img
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "UnityCG.cginc"

            // uniform 함수
            // 모든 셰이더에서 공통적으로 사용할 수 있도록 하는 변수
            // 전역변수 형태
            uniform sampler2D _MainTex;
            uniform sampler2D _VignetteTex;
            uniform sampler2D _ScanLineTex;
            uniform sampler2D _NoiseTex;
            fixed _NoiseXSpeed;
            fixed _NoiseYSpeed;
            fixed _ScanLineTileAmount;
            fixed4 _NightVisionColor;
            fixed _Contrast;
            fixed _Brightness;
            fixed _RandomValue;
            fixed _Distortion;
            fixed _Scale;

            // 렌즈 왜곡 알고리즘
            float2 barrelDistortion (float2 coord)
            {
                float2 h = coord.xy - float2 (0.5, 0.5);
                float r2 = h.x * h.x + h.y * h.y;
                float f = 1 + r2 * (_Distortion * sqrt (r2));
                return f * _Scale * h + 0.5;
            }

            fixed4 frag (v2f_img i) : COLOR
            {
                half2 distortedUV = barrelDistortion (i.uv);
                fixed4 renderTex = tex2D (_MainTex, distortedUV);
                fixed4 vignetteTex = tex2D (_VignetteTex, i.uv);

                half2 scanLineUV = half2 (i.uv.x * _ScanLineTileAmount, i.uv.y * _ScanLineTileAmount);
                fixed4 scanLineTex = tex2D (_ScanLineTex, scanLineUV);
                
                half2 noiseUV = half2 (i.uv.x + (_RandomValue * _SinTime.z * _NoiseXSpeed), i.uv.y + (_Time.x * _NoiseYSpeed));
                fixed4 noiseTex = tex2D (_NoiseTex, noiseUV);

                fixed lum = dot (fixed3 (0.299, 0.587, 0.114), renderTex.rgb);
                lum += _Brightness;

                fixed4 finalColor = (lum * 2) + _NightVisionColor;
                finalColor = pow (finalColor, _Contrast);
                finalColor *= vignetteTex;
                finalColor *= scanLineTex * noiseTex;

                return finalColor;
            }
            
            ENDCG
        }
    }
    FallBack off
}
