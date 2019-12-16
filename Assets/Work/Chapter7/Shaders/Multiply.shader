// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Chapter7/Multiply"
{
    Properties
    {
        _Color ("Color", Color) = (1, 0, 0, 1)
        _MainTex ("Main Texture", 2D) = "white" {}
    }
    SubShader
    {
        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            half4 _Color;
            sampler2D _MainTex;

            struct vertInput
            {
                // position of world
                float4 pos : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            struct vertOutput 
            {
                // position of camera screen
                float4 pos : POSITION;
                float2 texcoord : TEXCOORD0;
            };

            vertOutput vert (vertInput input)
            {
                vertOutput o;

                // same with o.pos = mul (UNITY_MATRIX_MVP, input.pos);
                o.pos = UnityObjectToClipPos (input.pos);
                o.texcoord = input.texcoord;

                return o;
            }

            half4 frag (vertOutput output) : COLOR 
            {
                half4 mainColor = tex2D (_MainTex, output.texcoord);
                return mainColor * _Color;
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}
