Shader "MyShader/Chapter9/ScreenGrayScale"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Brightness ("Brightness", Range (0, 1)) = 1
        _Saturation ("Saturation", Range (0, 1)) = 1
        _Constrast ("Constrast", Range (0, 1)) = 1
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
            fixed _Brightness;
            fixed _Saturation;
            fixed _Constrast;

            float3 ConstrastSaturationBrightness (float3 color, float brt, float sat, float con)
            {
                float avgLumR = 0.5;
                float avgLumG = 0.5;
                float avgLumB = 0.5;
                float3 avgLumin = float3 (avgLumR, avgLumG, avgLumB);

                float3 luminanceCoeff = float3 (0.2125, 0.7154, 0.0721);
                float3 brtColor = color * brt;

                float intensityf = dot (brtColor, luminanceCoeff);

                float3 intensity = float3 (intensityf, intensityf, intensityf);
                
                float3 satColor = lerp (intensity, brtColor, sat);
                float3 conColor = lerp (avgLumin, satColor, con);

                return conColor;
            }

            fixed4 frag (v2f_img i) : COLOR
            {
                fixed4 renderTex = tex2D (_MainTex, i.uv);
                renderTex.rgb = ConstrastSaturationBrightness (renderTex.rgb, _Brightness, _Saturation, _Constrast);
                return renderTex;
            }
            
            ENDCG
        }
    }
    FallBack off
}
