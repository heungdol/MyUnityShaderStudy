Shader "MyShader/Custom/Object_Shockwave"
{
    Properties
    {
        _Magnitude ("Magnitude", Range (0, 1)) = 0
     }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "Queue"="Transparent" 
            "ForceNoShadowCasting" = "False"
            "IgnoreProjector" = "True"
            } 
            

        Grabpass {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            sampler2D _GrabTexture;
            float _Magnitude;

            struct vertInput
            {
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct vertOutput
            {
                UNITY_FOG_COORDS(1)
                float4 vertex : POSITION;
                float4 texcoord : TEXCOORD0;
                float4 uvgrab : TEXCOORD1;
                float3 normal : NORMAL;
                float3 viewDir : POSITION1;
            };

            vertOutput vert (vertInput v)
            {
                vertOutput o;

                o.vertex = UnityObjectToClipPos (v.vertex);
                o.uvgrab = ComputeGrabScreenPos (o.vertex);
                o.texcoord = v.texcoord;
                o.normal = v.normal;
                o.viewDir = normalize (ObjSpaceViewDir (v.vertex));
                UNITY_TRANSFER_FOG(o,o.vertex);

                return o;
            }

            half3 GetScreenNormalByViewDir (half3 vd, half3 nor)
            {
                half3 result;

                float d = dot (-vd, nor);
                result = nor - (-vd * d);

                return result;// normalize (result);
            }

            half4 frag (vertOutput i) : COLOR
            {
                // 이거때매 한참 삽질함
                float3 screenNormal = GetScreenNormalByViewDir (i.viewDir, i.normal);
                screenNormal = mul (UNITY_MATRIX_V, screenNormal);

                float vdn = dot (i.viewDir, i.normal);

                // 방향을 가지는 왜곡정도
                float2 shockDegree = screenNormal.xy * vdn;

                float4 totalUvgrab = i.uvgrab;
                totalUvgrab.rg += shockDegree * _Magnitude;// + float4 (_Speed * _Time [3], _Speed * _Time [3], 0, 0));

                fixed4 col = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (totalUvgrab));
                return col;
            }
            ENDCG
        }
    }
}
