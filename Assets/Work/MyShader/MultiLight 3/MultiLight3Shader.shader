// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Custom/Object_Toon3"
{
    Properties 
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}

        _ColorW ("Ramp Color 0", Color) = (1, 1, 1, 1)
        _ColorB ("Ramp Color 1", Color) = (0, 0, 0, 1)

        _RampTex ("Ramp Texture", 2D) = "black" {}
        _RampPow ("Ramp Power", Range (0.1, 2)) = 1
        _RampPowCol ("Ramp Color Power", Range (0.1, 2)) = 1
    }
    SubShader 
    {
        Tags {"Queue" = "Geometry" "RenderType" = "Opaque"}
        Pass 
        {
            Tags
			{
				"LightMode" = "ForwardBase"
			}
           	CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase                       // This line tells Unity to compile this pass for forward add, giving attenuation information for the light.
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            struct v2f
            {
                float4  pos         : SV_POSITION;
                float2  uv          : TEXCOORD0;
                //float3  lightDir    : TEXCOORD2;
                float3 normal		: TEXCOORD1;
                LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
            };

            v2f vert (appdata_tan v)
            {
                v2f o;
                
                o.pos = UnityObjectToClipPos( v.vertex);
                o.uv = v.texcoord.xy;
                
                //o.lightDir = ObjSpaceLightDir(v.vertex);
                
                o.normal =  v.normal;
                TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                return o;
            }

            sampler2D _MainTex;
            fixed4 _Color;

            fixed4 _ColorW;
            fixed4 _ColorB;

            sampler2D _RampTex;
            float _RampPow;
            float _RampPowCol;

            fixed4 frag(v2f i) : COLOR
            {
                fixed4 result = tex2D(_MainTex, i.uv);

                fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.

                fixed diff = dot(i.normal, _WorldSpaceLightPos0.xyz);
                diff = diff * 0.5 + 0.5 ;
                diff *= atten;
                diff = pow (diff, _RampPow);

                float shade = tex2D (_RampTex, float2 (diff, 0.5)).r;
                shade = pow (shade, _RampPowCol);
                float3 shadeColor = lerp (_ColorB, _ColorW, shade);

                result.rgb *= _Color.rgb;
                result.rgb *= _LightColor0.rgb * shadeColor;
                result.a = 1;

                return result;
            }
            ENDCG
        }
 
        Pass {
            Tags {"LightMode" = "ForwardAdd"}                       // Again, this pass tag is important otherwise Unity may not give the correct light information.
            Blend SrcAlpha OneMinusSrcAlpha

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd                       // This line tells Unity to compile this pass for forward add, giving attenuation information for the light.
            
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            
            struct v2f
            {
                float4  pos         : SV_POSITION;
                float2  uv          : TEXCOORD0;
                //float3  lightDir    : TEXCOORD2;
                float3 normal		: TEXCOORD1;
                float3 worldPos : TEXCOORD4;
                LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
                
            };

            v2f vert (appdata_tan v)
            {
                v2f o;
                
                o.pos = UnityObjectToClipPos( v.vertex);
                o.uv = v.texcoord.xy;
                
                //o.lightDir = ObjSpaceLightDir(v.vertex);
                
                o.normal =  v.normal;
                TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 _ColorW;
            fixed4 _ColorB;

            sampler2D _RampTex;
            float _RampPow;
            float _RampPowCol;

            fixed4 frag(v2f i) : COLOR
            {          
                fixed atten = LIGHT_ATTENUATION(i);

                float3 lightDir =  _WorldSpaceLightPos0.xyz - i.worldPos;
                lightDir = normalize (lightDir);

                fixed diff = dot(i.normal, lightDir);
                diff = diff * 0.5 + 0.5;
                diff *= atten * 2;
                diff = pow (diff, _RampPow);

                float shade = tex2D (_RampTex, float2 (diff, 0.5)).r;
                shade = pow (shade, _RampPowCol);

                //float3 shadeStart = tex2D (_RampTex, float2 (1, 0.5));
                //float3 shadeEnd = tex2D (_RampTex, float2 (0, 0.5));

                //float3 shadeAlpha3 = (shade - shadeEnd) / (shadeStart - shadeEnd);
                //float shadeAlpha = (shadeAlpha3.r + shadeAlpha3.g + shadeAlpha3.b) / 3;

                fixed4 result = 1;

                result.rgb = _LightColor0.rgb;// * lerp (_ColorB, _ColorW, shade);
                result.a = shade;

                return result;
            }
            ENDCG
        }
    }
}