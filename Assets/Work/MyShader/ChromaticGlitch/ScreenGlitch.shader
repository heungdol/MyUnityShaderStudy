Shader "MyShader/Custom/Screen_ChromaticGlitch"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _GlitchOffset ("Glitch Offset", Range (-0.1, 0.1)) = 0
        [IntRange] _GlitchType ("Glitch Type", Range (0, 2)) = 0
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
            int _GlitchType;

            fixed4 frag (v2f_img i) : COLOR
            {
                fixed4 col;
                fixed totalOffset = _GlitchOffset;
                //totalOffset *= _GlitchOffset;

                //col.x = tex2D (_MainTex, i.uv + fixed2 (totalOffset, 0)).x;
                //col.y = tex2D (_MainTex, i.uv).y;
                //col.z = tex2D (_MainTex, i.uv + fixed2 (-totalOffset, 0)).z;
                //col.w = tex2D (_MainTex, i.uv).w;

                

                if (_GlitchType == 0)
                {
                    col.x = tex2D (_MainTex, i.uv + fixed2 (totalOffset, 0)).x;
                    col.y = tex2D (_MainTex, i.uv).y;
                    col.z = tex2D (_MainTex, i.uv + fixed2 (-totalOffset, 0)).z;
                    col.w = tex2D (_MainTex, i.uv).w;
                }
                else if (_GlitchType == 1)
                {
                    col.z = tex2D (_MainTex, i.uv + fixed2 (totalOffset, 0)).z;
                    col.x = tex2D (_MainTex, i.uv).x;
                    col.y = tex2D (_MainTex, i.uv + fixed2 (-totalOffset, 0)).y;
                    col.w = tex2D (_MainTex, i.uv).w;
                }
                else
                {
                    col.y = tex2D (_MainTex, i.uv + fixed2 (totalOffset, 0)).y;
                    col.z = tex2D (_MainTex, i.uv).z;
                    col.x = tex2D (_MainTex, i.uv + fixed2 (-totalOffset, 0)).x;
                    col.w = tex2D (_MainTex, i.uv).w;
                }

                return col;
            }
            
            ENDCG
        }
    }
    FallBack off
}
