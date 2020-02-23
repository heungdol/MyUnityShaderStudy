// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

shader "MyShader/Custom/Object_Dissolve"
{
    Properties 
    {
        _MainTex ("Main Texture", 2D) = "white" {}

        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseScale ("Noise Scale", Range (0.5, 10)) = 1

        _EdgeCol ("Edge Color", Color) = (1, 1, 1, 1)
        _Level ("Dissolution Level", Range (0, 1)) = 0.1
        _Edge ("Edge width", Range (0, 1)) = 0.1
    }

    SubShader
    {
        Tags
        {
            "Queue" = "Transparent"
            "RenderType" = "Transparent"
        }
        LOD 100

        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            //Cull Off
            //Lighting Off
            //ZWrite Off
            //Fog {Mode Off}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float4 _MainTex_ST;
            
            sampler2D _NoiseTex;
            float _NoiseScale;

            float4 _EdgeCol;
            float _Level;
            float _Edge;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f 
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uv = TRANSFORM_TEX (v.uv, _MainTex);

                return o;
            }

            fixed4 frag (v2f i) : SV_TARGET
            {
                if (_Level == 1)
                    discard;

                float cutout = tex2D (_NoiseTex, i.uv/ _NoiseScale).r;
                float4 col = tex2D (_MainTex, i.uv);
                col.a = 1;

                if (cutout < _Level)
                {
                    if (cutout < _Level-(lerp (_Edge, 0, cutout)))
                        discard;
                    col = _EdgeCol;
                }

                return col;
            }
            ENDCG
        }
    }
}