Shader "MyShader/Custom/DistortionByShape"
{
    Properties
    {
        _Dummy ("Dummy", 2D) = "bump" {}
        _Magnitude ("Magnitude", Range (-0.5, 0.5)) = 0
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

            sampler2D _GrabTexture;
            sampler2D _Dummy;
            float _Magnitude;

            struct vertInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct vertOutput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float4 uvgrab : TEXCOORD1;
                float3 normal : NORMAL;
            };

            vertOutput vert (vertInput v)
            {
                vertOutput o;

                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uvgrab = ComputeGrabScreenPos (o.vertex);
                o.texcoord = v.texcoord;
                o.normal = v.normal;

                return o;
            }

            half4 frag (vertOutput i) : COLOR
            {
                float2 colBump = i.normal.rg;
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
