Shader "MyShader/Custom/GlitchFOVShaderFalied"
{
    Properties
    {
        _GlitchOffset ("Glitch Offset", Range (0, 0.05)) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }

        Grabpass {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // 미리 정의된 변수
            sampler2D _GrabTexture;
            float _GlitchOffset;

            struct vertInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
            };

            struct vertOutput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float4 uvgrab : TEXCOORD1;
            };

            vertOutput vert (vertInput v)
            {
                vertOutput o;

                o.vertex = UnityObjectToClipPos (v.vertex);
                o.texcoord = v.texcoord;
                o.uvgrab = ComputeGrabScreenPos (o.vertex);

                return o;
            }

            half4 frag (vertOutput i) : COLOR
            {
                //fixed4 col = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (i.uvgrab));

                fixed colR = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (i.uvgrab + fixed4 (_GlitchOffset, 0, 0, 0))).r;
                fixed colG = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (i.uvgrab)).g;
                fixed colB = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (i.uvgrab + fixed4 (-_GlitchOffset, 0, 0, 0))).b;

                fixed4 finalCol = fixed4 (colR, colG, colB, 1);
                return finalCol;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}

//  실패
//  실패이유: 카메라의 위치에 따라 글리치의 정도가 달라진다

//  다른 구현 방안: 챕터 9의 ScreenDepth를 이용하여 구현하는 방법