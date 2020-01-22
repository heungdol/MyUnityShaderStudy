// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// 보통 레벨디자인의 stage 레이어에서 사용될 것임
Shader "MyShader/Custom/Object_PatternShadow"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}

        _PatternTex ("Pattern Texture", 2D) = "black" {}
        _PatternScale ("Pattern Scale", Float) = 10
        _PatternPow ("Pattern Power", Range (0.1, 10)) = 1
    }
    SubShader
    {
        // 첫단계: 라이팅을 받는 일반적인 셰이더

        // 두번째단계: 메쉬를 약간 부풀리고 거기위에 그림자 그려넣기

        Tags { "Queue"="Transparent" }
        //Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
            struct vertInput
            {
                float4 pos : POSITION;
            };

            struct vertOutput
            {
                float4 pos : POSITION;
                fixed3 worldPos : TEXCOORD1;  
            };

            vertOutput vert (vertInput input)
            {
                vertOutput o;
                o.pos = UnityObjectToClipPos (input.pos);
                o.worldPos = mul (unity_ObjectToWorld, input.pos).xyz;
                return o;
            }

            ///uniform int _Points_Length = 0;
            //uniform float3 _Points [20];
            //uniform float2 _Properties [20];

            //sampler2D _HeatTex;

            half4 frag (vertOutput output) : COlOR
            {
                half h = 0;
                for (int i = 0; i < _Points_Length; i++)
                {
                    half di = distance (output.worldPos, _Points [i].xyz);
                    half ri = _Properties [i].x;
                    half hi = 1 - saturate (di / ri);
                    h += hi * _Properties [i].y;
                }

                h = saturate (h);
                half4 color = tex2D (_HeatTex, fixed2 (h, 0.5));
                return color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
