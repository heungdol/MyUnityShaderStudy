// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Chapter7/GrabShader"
{
    Properties
    {
        //_GrabTexture ("Grab Texture", 2D) = "white" {}
        _Noise ("Noise Texture", 2D) = "gray" {}
       // _Speed ("Noise Offset Speed", Range (0, 10)) = 0
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

            sampler2D _Noise;
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
                fixed4 noise = tex2D (_Noise, i.texcoord);
                noise = (noise - 0.5) * 2;

                float4 totalUvgrab = i.uvgrab;
                totalUvgrab += noise;// + float4 (_Speed * _Time [3], _Speed * _Time [3], 0, 0));

                fixed4 col = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (totalUvgrab));
                return col;
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
