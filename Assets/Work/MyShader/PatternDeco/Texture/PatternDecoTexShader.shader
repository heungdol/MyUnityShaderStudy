Shader "MyShader/Custom/Object_PatternDeco_Texture"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)

        // 해당되는 값이 1이 되도록 하는 텍스쳐
        _PatternTex ("Pattern Texture", 2D) = "white" {}
        _PatternScale ("Pattern Scale", Range (1, 20)) = 1
        _PatternPow ("Pattern Power", Range (0.1, 10)) = 1
        _PatternRot ("Pattern Rotation", Range (0, 360)) = 0

        _AreaTex ("Area Texture", 2D) = "white" {}
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha

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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 screenPos : TEXCOORD1;
                float3 worldPos : TEXCOORD2;
            };

            float4 _MainColor;

            sampler2D _PatternTex;
            float _PatternScale;
            float _PatternPow;
            float _PatternRot;

            sampler2D _AreaTex;
            float4 _AreaTex_ST;
            

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _AreaTex);

                o.screenPos = o.vertex.xyw;
                o.screenPos.y *= _ProjectionParams.x;

                o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float2 screenUV = mul (unity_WorldToObject, i.worldPos);/// i.vertex.w;//(i.screenPos.xy / i.screenPos.z) * 0.5 + 0.5;
                //float2 screenUV = (i.screenPos.xy / i.screenPos.z) * 0.5 + 0.5;

                // 회전
                float2x2 rotMat = float2x2 (cos (radians (_PatternRot)), -sin (radians (_PatternRot))
                                            , sin (radians (_PatternRot)), cos (radians (_PatternRot)));
                screenUV = mul (screenUV, rotMat);

                float4 areaCol = tex2D (_AreaTex, i.uv);
                //float4 patternCol = tex2D (_PatternTex, screenUV * _PatternScale * float2 (1, (_ScreenParams.y / _ScreenParams.x))).r;
                float4 patternCol = tex2D (_PatternTex, screenUV * _PatternScale).r;
                patternCol = pow (patternCol, _PatternPow);
                float4 resultCol;

                resultCol.rgb = _MainColor.rgb;

                if (patternCol.r < (1 - areaCol.r))
                    resultCol.a = 0;
                else
                    resultCol.a = 1;


                return resultCol;
            }
            ENDCG
        }
    }
}
