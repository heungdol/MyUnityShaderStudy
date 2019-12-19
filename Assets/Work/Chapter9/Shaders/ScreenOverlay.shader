Shader "MyShader/Chapter9/ScreenOverlay"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _BlendTex ("Blend Textuer", 2D) = "white" {}
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

            fixed OverlayBlendMode (fixed basePixel, fixed blendPixel)
            {
                if (basePixel < 0.5)
                    return (2.0 * basePixel * blendPixel);

                return (1.0 - 2.0 * (1.0 - basePixel) * (1.0 - blendPixel));
            }

            fixed4 OverlayBlendMode (fixed4 base, fixed4 blend)
            {
                fixed4 ret = float4 (1, 1, 1, 1);
                ret.r = OverlayBlendMode (base.r, blend.r);
                ret.g = OverlayBlendMode (base.g, blend.g);
                ret.b = OverlayBlendMode (base.b, blend.b);
                return ret;
            }

            fixed4 frag (v2f_img i) : COLOR
            {
                fixed4 renterTex = tex2D (_MainTex, i.uv);
                fixed4 blendTex = tex2D (_BlendTex, i.uv);
                fixed4 blendedImage = OverlayBlendMode (renterTex, blendTex);
                renterTex = lerp (renterTex, blendedImage, _Opacity);
                
                return renterTex;
            }
            
            ENDCG
        }
    }
    FallBack off
}
