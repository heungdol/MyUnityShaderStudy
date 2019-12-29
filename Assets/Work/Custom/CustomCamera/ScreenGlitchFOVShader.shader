Shader "MyShader/Custom/ScreenGlitchFOVShader"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DepthPower ("Depth Power", Range (0, 1)) = 0.01
        _DepthStart ("Depth Start", Range (0, 0.5)) = 0.1
        _DepthEnd ("Depth End", Range (0.5, 1)) = 0.9
        _DepthThreshold ("Depth Glitch Threshold", Range (0, 1)) = 0.5

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
            #include "ScreenGlitchFOVShader.cginc"
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
// glitch 시킬때 서로의 depth를 비교해보자

// 실패
// 서로 깊이가 다른 사물이 겹치는 경우 세밀한 글리치를 스크립트상에서 구현할 수 없음