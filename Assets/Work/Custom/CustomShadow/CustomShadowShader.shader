// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "MyShader/Custom/Object_CustomShadowShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RampTex ("Ramp Texture", 2D) = "white" {}

        _PatternCol ("Pattern Color", Color) = (0, 0, 0, 1)
        _PatternTex ("Pattern Texture", 2D) = "white" {}
        _PatternScale ("Pattern Scale", Float) = 10
        _PatternPow ("Pattern Power", Range (0.1, 10)) = 1

        //_BumpNormal ("Bumping Normal", Range (0, 0.1)) = 0.01
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "Queue"="Transparent" 
            "ForceNoShadowCasting" = "False"
            "IgnoreProjector" = "True"
            } 
        //LOD 200

        // 먼저 빛을 받는 일반적인 셰이더
        CGPROGRAM
        #pragma surface surf ToonSytle
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _RampTex;
        fixed4 _Color;

        struct Input
        {
            float2 uv_MainTex;
        };

        void surf (Input IN, inout SurfaceOutput o)
        {
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        
        float4 LightingToonSytle (SurfaceOutput s, float3 lightDir, float3 viewDir, float atten)
        {
            float4 result;

            float lDotN = dot (lightDir, s.Normal);
            lDotN = lDotN * 0.5 + 0.5;

            float aa = atten * atten;

            float2 rampUV = float2 (aa, 0.5);
            float3 rampCol = tex2D (_RampTex, rampUV).rgb;

            result.xyz = s.Albedo * rampCol * _LightColor0 * atten;
            result.w = 1;

            return result;
        }
        ENDCG

       
        // 두번째 단계로 그림자를 그린다
        Blend SrcAlpha OneMinusSrcAlpha 

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            //float _BumpNormal;
            
            struct vertInput
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
            };

            struct vertOutput
            {
                float4 pos : POSITION;
                float3 normal : NORMAL;
                fixed3 worldPos : TEXCOORD1;  
                float3 screenPos : TEXCOORD2;
            };

            vertOutput vert (vertInput input)
            {
                vertOutput o;
                o.pos = UnityObjectToClipPos (input.pos);

                o.normal = input.normal;

                o.worldPos = mul (unity_ObjectToWorld, input.pos).xyz; 

                o.screenPos = o.pos.xyw;
                o.screenPos.y *= _ProjectionParams.x;

                return o;
            }

            float4 _PatternCol;
            sampler2D _PatternTex;
            float _PatternScale;
            float _PatternPow;

            uniform int _Points_Length = 0;
            uniform float4 _Properties [20];
            //uniform float _Radiuses [20];

            float4 _Color;

            //sampler2D _HeatTex;

            half4 frag (vertOutput output) : SV_TARGET
            {
                float s = 0;

                for (int i = 0; i < _Points_Length; i++)
                {
                    half di = distance (output.worldPos, _Properties [i].xyz);
                    half ri = _Properties [i].w;

                    if (di < ri)
                    {
                        half hi = 1 - saturate (di / ri);
                        s += hi;
                    }
                }

                s = saturate (s);
                s = pow (s, _PatternPow);

                float resultAlpha = 0;
                float2 screenUV = mul (unity_WorldToObject, output.worldPos);
                float patternCol = tex2D (_PatternTex, screenUV * _PatternScale).r;
                
                if (patternCol < (1 - s))
                    resultAlpha = 0;
                else
                    resultAlpha = 1;

                return float4 (_PatternCol.rgb, resultAlpha);
            }
            ENDCG
        }
    }
}
