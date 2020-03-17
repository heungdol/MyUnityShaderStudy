// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Custom/Object_Toon2"
{
    Properties 
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}

        _RampTex ("Ramp Texture", 2D) = "black" {}
        _RampPow ("Ramp Power", Range (0.1, 2)) = 1

        _OtherPow ("Other Lights Power", Range (0.1, 2)) = 1
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

            sampler2D _RampTex;
            float _RampPow;

            fixed4 frag(v2f i) : COLOR
            {
                fixed4 result = tex2D(_MainTex, i.uv);

                fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.

                float3 worldNormal = UnityObjectToWorldNormal (i.normal);

                fixed diff = dot(worldNormal, _WorldSpaceLightPos0.xyz);
                diff = diff * 0.5 + 0.5 ;
                diff *= atten;
                diff = pow (diff, _RampPow);

                float3 shade = tex2D (_RampTex, float2 (diff, 0.5));

                result.rgb *= _Color.rgb;
                result.rgb *= _LightColor0.rgb * shade.rgb;
                result.a = 1;

                return result;
            }
            ENDCG
        }
 
        Pass {
            Tags {"LightMode" = "ForwardAdd"}                       // Again, this pass tag is important otherwise Unity may not give the correct light information.
            Blend SrcAlpha OneMinusSrcAlpha
            //Blend One One                                           // Additively blend this pass with the previous one(s). This pass gets run once per pixel light.
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

            float _OtherPow;

            fixed4 frag(v2f i) : COLOR
            {          
                fixed atten = LIGHT_ATTENUATION(i);

                float3 lightDir =  _WorldSpaceLightPos0.xyz - i.worldPos;
                lightDir = normalize (lightDir);

                float3 worldNormal = UnityObjectToWorldNormal (i.normal);

                fixed diff = dot(worldNormal, lightDir);
                diff = diff * 0.5 + 0.5;
                diff *= atten;
                diff = pow (diff, _OtherPow);

                if (diff > 0.5)
                    return float4 (_LightColor0.rgb, 1);

                return float4 (0, 0, 0, 0);
            }
            ENDCG
        }
    }
    //FallBack "VertexLit"  
}