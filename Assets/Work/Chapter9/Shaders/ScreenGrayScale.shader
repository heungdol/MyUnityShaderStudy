Shader "MyShader/Chapter9/ScreenGrayScale"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _Luminosity ("Luminosity", Range (0, 1)) = 1.0
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
            fixed _Luminosity;

            fixed4 frag (v2f_img i) : COLOR
            {
                fixed4 renderTex = tex2D (_MainTex, i.uv);
                float luminosity = 0.299 * renderTex.r + 0.587 * renderTex.g + 0.114 * renderTex.b;
                float4 finalColor = lerp (renderTex, luminosity, _Luminosity);

                renderTex.rgb = finalColor;
                return renderTex;
            }
            
            ENDCG
        }
    }
    FallBack off
}
