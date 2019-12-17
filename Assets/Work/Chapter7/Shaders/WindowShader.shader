// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Chapter7/WindowShader"
{
    Properties
    {
        _MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
        _Color ("Color", Color) = (1, 1, 1, 1)
        _BumpMap ("Noise Text", 2D) = "bump" {}
        _Magnitude ("Magnitude", Range (0, 1)) = 0.05
    }
    SubShader
    {
        Tags 
        { 
            "Queue"="Transparent" 
            "IgnoreProjector" = "True"
            "RenderType" = "Opaque"
        }

        Grabpass {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            // 미리 정의된 변수
            sampler2D _GrabTexture;

            sampler2D _MainTex;
            sampler2D _BumpMap;
            float4 _Color;
            float _Magnitude;

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
                o.uvgrab = ComputeGrabScreenPos (o.vertex);
                o.texcoord = v.texcoord;

                return o;
            }

            half4 frag (vertOutput i) : COLOR
            {
                half4 mainColor = tex2D (_MainTex, i.texcoord);
                half4 bump = tex2D (_BumpMap, i.texcoord);
                half2 distortion = UnpackNormal (bump).rg;

                i.uvgrab.xy += distortion * _Magnitude;

                fixed4 col = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (i.uvgrab));
                return col * mainColor * _Color;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
