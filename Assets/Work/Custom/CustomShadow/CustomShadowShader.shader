Shader "MyShader/Custom/Object_CustomShadowShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _RampTex ("Ramp Texture", 2D) = "white" {}

        //_BumpNormal ("Bumping Normal", Range (0, 0.1)) = 0.01
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

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
            };

            struct vertOutput
            {
                float4 pos : POSITION;
                fixed3 worldPos : TEXCOORD1;  
            };

            vertOutput vert (vertInput input)
            {
                vertOutput o;
                o.pos = UnityObjectToClipPos (input.pos);
                o.worldPos = mul (unity_ObjectToWorld, input.pos).xyz; 
                return o;
            }

            uniform int _Points_Length = 0;
            uniform float4 _Properties [20];
            uniform float _Radiuses [20];

            //sampler2D _HeatTex;

            half4 frag (vertOutput output) : COlOR
            {
                float4 resultCol;
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

                resultCol = (0, 0, 0, s);

                //h = saturate (h);
                //half4 color = tex2D (_HeatTex, fixed2 (h, 0.5));
                //return color;

                return resultCol;
            }
            ENDCG
        }
    }
}
