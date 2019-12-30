// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Custom/DistortionByBump"
{
    Properties
    {
        _NormalTex ("Normal Texture", 2D) = "bump" {}
        _Magnitude ("Magnitude", Range (0, 1)) = 0.05
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

            sampler2D _NormalTex;
            float _Magnitude;
            //float _Speed;

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
                half4 bump = tex2D (_NormalTex, i.texcoord);
                float2 colBump = UnpackNormal (bump).rg;
                //colBump -= 0.5;

                float4 totalUvgrab = i.uvgrab;
                totalUvgrab.rg += colBump * _Magnitude;// + float4 (_Speed * _Time [3], _Speed * _Time [3], 0, 0));

                fixed4 col = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (totalUvgrab));
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
