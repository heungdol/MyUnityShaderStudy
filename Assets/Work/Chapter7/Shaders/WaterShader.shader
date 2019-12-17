// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Chapter7/WaterShader"
{
    Properties
    {
        _NoiseTex ("Noise Text", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Period ("Period", Range (0, 50)) = 1
        _Magnitude ("Magnitude", Range (0, 0.5)) = 0.05
        _Scale ("Scale", Range (0, 10)) = 1
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

            sampler2D _NoiseTex;
            float4 _Color;
            float _Period;
            float _Magnitude;
            float _Scale;

            struct vertInput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;

                float2 texcoord : TEXCOORD0;
            };

            struct vertOutput
            {
                float4 vertex : POSITION;
                float4 color : COLOR;
                float4 uvgrab : TEXCOORD1;
                float4 worldPos : TEXCOORD2;

                float2 texcoord : TEXCOORD0;
            };

            vertOutput vert (vertInput v)
            {
                vertOutput o;

                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uvgrab = ComputeGrabScreenPos (o.vertex);

                o.color = v.color;
                o.texcoord = v.texcoord;

                // 해당 픽셀의 게임월드공간에서의 위치
                o.worldPos = mul (unity_ObjectToWorld, v.vertex);

                return o;
            }

            half4 frag (vertOutput i) : COLOR
            {
                float sinT = sin (_Time.w / _Period);
                float disX = tex2D (_NoiseTex, i.worldPos.xy / _Scale + float2 (sinT, 0)).r - 0.5;
                float disY = tex2D (_NoiseTex, i.worldPos.xy / _Scale + float2 (0, sinT)).r - 0.5;

                float2 distortion = float2 (disX, disY);
                i.uvgrab.xy += distortion * _Magnitude;
                float4 col = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (i.uvgrab));
                return col * _Color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
