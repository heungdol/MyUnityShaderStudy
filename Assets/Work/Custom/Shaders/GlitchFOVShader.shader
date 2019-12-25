Shader "MyShader/Custom/GlitchFOVShader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DepthPower ("Depth Power", Range (0, 1)) = 0.01
        _DepthStart ("Depth Start", Range (0, 0.5)) = 0.1
        _DepthEnd ("Depth End", Range (0.5, 1)) = 0.9
        _GlitchThreshold ("Glitch Threshold", Range (0, 1)) = 0.75
        _GlitchOffset ("Glitch Offset", Range (0.0, 0.1)) = 0
        
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

            fixed _DepthStart;
            fixed _DepthEnd;
            fixed _DepthPower;

            fixed _GlitchOffset;
            fixed _GlitchThreshold;

            sampler2D _CameraDepthTexture;

            fixed4 frag (v2f_img i) : COLOR
            {
                fixed4 finalCol = tex2D (_MainTex, i.uv.xy);

                float depth = UNITY_SAMPLE_DEPTH ( tex2D (_CameraDepthTexture, i.uv.xy));
                depth = pow (Linear01Depth (depth), _DepthPower);

                if (depth > _DepthEnd)
                {
                    depth = 1;
                }
                else if (_DepthEnd >= depth && depth > _DepthStart)
                {
                    float p = (depth - _DepthStart) / (_DepthEnd - _DepthStart);
                    depth = p;
                }
                else
                {
                    return finalCol;
                }

                float totalOffset = depth * _GlitchOffset;

                finalCol.r = tex2D (_MainTex, i.uv.xy - float2 (totalOffset, 0)).r;
                finalCol.g = tex2D (_MainTex, i.uv.xy).g;
                finalCol.b = tex2D (_MainTex, i.uv.xy + float2 (totalOffset, 0)).b;

                return finalCol;
            }
            
            ENDCG
        }
    }
    FallBack off
}

// 예상하지 못한 변수가 너무 많다
// 1. 배경
// 2. 사물이 겹칠때
// 3. 멀리있는 사물은 offset이 같아도 더욱 멀리있어 보인다

// 내일해보자