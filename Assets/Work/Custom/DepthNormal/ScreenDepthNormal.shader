// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Custom/ScreenDepthNormal"
{
    Properties
    {
        _MainTex ("Base (RGB)", 2D) = "white" {}
        _DepthPower ("Depth Power", Range (0, 1)) = 1.0
        _DepthStartPoint ("Depth Start Point", Range (0, 0.5)) = 0
        _DepthEndPoint ("Depth End Point", Range (0.5, 1)) = 1
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            sampler2D _CameraDepthNormalsTexture;
            
            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 scrPos : TEXCOORD1;
            };

            v2f vert (appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos (v.vertex);
                o.scrPos = ComputeScreenPos (o.pos);
                o.scrPos.y = 1 - o.scrPos.y;

                return o;
            }

            sampler2D _MainTex;

            half4 frag (v2f i) : COLOR
            {
                float3 normalValues;
                float depthValue;

                DecodeDepthNormal (tex2D (_CameraDepthNormalsTexture, i.scrPos.xy), depthValue, normalValues);

                return depthValue;
            }
            ENDCG
        }
    }
    FallBack off
}
