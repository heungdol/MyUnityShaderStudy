Shader "MyShader/Chapter9/ScreenDepth"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DepthPower ("Depth Power", Range (0, 1)) = 1.0
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
            fixed _DepthPower;
            sampler2D _CameraDepthTexture;

            fixed4 frag (v2f_img i) : COLOR
            {
                float depth = UNITY_SAMPLE_DEPTH ( tex2D (_CameraDepthTexture, i.uv.xy));
                depth = pow (Linear01Depth (depth), _DepthPower);

                return depth;
            }
            
            ENDCG
        }
    }
    FallBack off
}
