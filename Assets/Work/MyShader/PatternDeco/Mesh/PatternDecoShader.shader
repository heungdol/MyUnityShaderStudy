Shader "MyShader/Custom/Object_PatternDeco_Mesh"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)

        // 해당되는 값이 1이 되도록 하는 텍스쳐
        _PatternTex ("Pattern Texture", 2D) = "white" {}
        _PatternScale ("Pattern Scale", Range (1, 10)) = 1
        _PatternScaleDis ("Pattern Scale by Distance", Range (1, 20)) = 1
        _PatternRot ("Pattern Rotation", Range (0, 360)) = 0
        _PatternPow ("Pattern Power", Range (0.1, 10)) = 1

        _LightRange ("Lighting Range", Range (0, 10)) = 0.1
    }
    SubShader
    {
         Tags { 
            "RenderType"="Opaque"
            "Queue"="Transparent" 
            "ForceNoShadowCasting" = "False"
            "IgnoreProjector" = "True"
            } 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                //float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                //float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            //sampler2D _MainTex;
            //float4 _MainTex_ST;
            float4 _MainColor;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                //o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                //UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return _MainColor;
            }
            ENDCG
        }

        Pass
        {
            Cull Back
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _MainColor;
            float _LightRange;
            
            sampler2D _PatternTex;
            float _PatternScale;
            float _PatternScaleDis;
            float _PatternRot;
            float _PatternPow;

            struct vertInput
            {
                float4 position : POSITION;
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct vertOutput
            {
                float4 position : POSITION;
                float4 texcoord : TEXCOORD0;
                float3 normal : NORMAL;
                float3 screenPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
                float3 viewDir : POSITION1;
            };

            vertOutput vert (vertInput v)
            {
                vertOutput o;

                o.normal = v.normal;
                o.position = UnityObjectToClipPos (v.position.xyz + o.normal * _LightRange);
                o.texcoord = v.texcoord;

                o.screenPos = o.position.xyw;
                o.screenPos.y *= _ProjectionParams.x;

                o.worldPos = mul(unity_ObjectToWorld, v.position);

                o.viewDir = normalize (ObjSpaceViewDir (v.position));
                

                return o;
            }


            float4 frag (vertOutput i) : SV_TARGET 
            {
                //float2 screenUV = i.worldPos / i.worldPos.z;// (i.screenPos.xy / i.screenPos.z) * 0.5 + 0.5;
                float2 screenUV = (i.screenPos.xy / i.screenPos.z) * 0.5 + 0.5;
                screenUV *= float2 (1, _ScreenParams.y / _ScreenParams.x);

                // 회전
                float2x2 rotMat = float2x2 (cos (radians (_PatternRot)), -sin (radians (_PatternRot))
                                            , sin (radians (_PatternRot)), cos (radians (_PatternRot)));
                screenUV = mul (screenUV, rotMat);

                // 거리계산
                float4 originPos = mul (unity_ObjectToWorld, float4 (0, 0, 0, 1));
                float dis = distance (originPos, _WorldSpaceCameraPos.xyz);
                dis /= _PatternScaleDis;

                // 값이 작아질수록 크기도 작아진다
                //float3 screenNormal = mul (UNITY_MATRIX_V, i.normal);

                float d = dot (i.normal, i.viewDir);
                d = pow (d, _PatternPow);

                float4 patternCol = tex2D (_PatternTex, screenUV * _PatternScale * dis).r;// * float2 (1, (_ScreenParams.y / _ScreenParams.x))).r;
                //float4 patternCol = tex2D (_PatternTex, screenUV * _PatternScale).r;
                float4 resultCol;
                resultCol.rgb = _MainColor.rgb;

                if (patternCol.r < (1 - d))
                    resultCol.a = 0;
                else
                    resultCol.a = 1;

                return resultCol;
            }

            ENDCG
        }
    }
}
