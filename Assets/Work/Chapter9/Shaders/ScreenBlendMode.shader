Shader "MyShader/Chapter9/ScreenBlendMode"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlendTex ("Blend Texture", 2D) = "white" {}
        _Opacity ("Blend Opacity", Range (0, 1)) = 1
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
            uniform sampler2D _BlendTex;
            fixed _Opacity;

            fixed4 frag (v2f_img i) : COLOR
            {
                fixed4 renderTex = tex2D (_MainTex, i.uv);
                fixed4 blendTex = tex2D (_BlendTex, i.uv);
                //fixed4 blendedMultiply = renderTex * blendTex;
                //fixed4 blendedAdd = renderTex + blendTex;
                fixed4 blendedScreen = (1.0 - ((1.0 - renderTex) * (1.0 - blendTex)));
                renderTex = lerp (renderTex, blendedScreen, _Opacity);

                return renderTex;
            }
            
            ENDCG
        }
    }
    FallBack off
}
