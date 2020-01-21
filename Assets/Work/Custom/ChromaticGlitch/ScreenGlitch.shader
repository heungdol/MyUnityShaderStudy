Shader "MyShader/Custom/Screen_ChromaticGlitch"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _GlitchOffset ("Glitch Offset", Range (0, 0.1)) = 0
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

            uniform sampler2D _MainTex;
            fixed _GlitchOffset;

            fixed4 frag (v2f_img i) : COLOR
            {
                //fixed4 renderTex = tex2D (_MainTex, i.uv);
                //float luminosity = 0.299 * renderTex.r + 0.587 * renderTex.g + 0.114 * renderTex.b;
                //float4 finalColor = lerp (renderTex, luminosity, _Luminosity);
                //renderTex.rgb = finalColor;
                //return renderTex;

                fixed4 col;

                fixed totalOffset = _GlitchOffset;
                //totalOffset *= _GlitchOffset;

                col.x = tex2D (_MainTex, i.uv + fixed2 (totalOffset, 0)).x;
                col.y = tex2D (_MainTex, i.uv).y;
                col.z = tex2D (_MainTex, i.uv + fixed2 (-totalOffset, 0)).z;
                col.w = tex2D (_MainTex, i.uv).w;

                return col;
            }
            
            ENDCG
        }
    }
    FallBack off
}
