// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Custom/Object_Toon"
{
    Properties 
    {
        _Color ("Main Color", Color) = (1,1,1,1)
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}
        _ShadowCol ("Shadow Color", Color) = (0, 0, 0, 1)
        [IntRange] _ShadowLevel ("Shadow Level", Range (1, 9)) = 2
        _ShadowPow ("Shadow Power", Range (0.1, 10)) = 1
        //_RampTex ("Ramp Texture", 2D) = "white" {}
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
              // This Pass tag is important or Unity may not give it the correct light information.
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
                    float3  lightDir    : TEXCOORD2;
                    float3 normal		: TEXCOORD1;
                    LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
                };
 
                v2f vert (appdata_tan v)
                {
                    v2f o;
                    
                    o.pos = UnityObjectToClipPos( v.vertex);
                    o.uv = v.texcoord.xy;
                   	
					o.lightDir = ObjSpaceLightDir(v.vertex);
					
					o.normal =  v.normal;
                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                    return o;
                }
 
                sampler2D _MainTex;
                fixed4 _Color;
                fixed4 _ShadowCol;

                //sampler2D _RampTex;
                //fixed4 _LightColor0; // Colour of the light used in this pass.
 
                fixed4 frag(v2f i) : COLOR
                {
                    //i.lightDir = normalize(i.lightDir);
                    
                    fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
                    //float shadow = SHADOW_ATTENUATION(i);
                    fixed4 tex = tex2D(_MainTex, i.uv);
                    
                    tex *= _Color;
                   
					//fixed3 normal = i.normal;                    
                    //fixed diff = saturate(dot(i.normal, i.lightDir));
                    //diff = diff * 0.5 + 0.5;
                    //diff *= atten;
                   // diff *= shadow;

                    //fixed rampColor = tex2D (_RampTex, float2 (diff, 0.5));
                   // fixed rampDefault = tex2D (_RampTex, float2 (0, 0.5));
                                        
                    fixed4 c;
                    //c.rgb = (UNITY_LIGHTMODEL_AMBIENT.rgb * 2 * tex.rgb);         // Ambient term. Only do this in Forward Base. It only needs calculating once.
                    c.rgb = _ShadowCol * tex.rgb;
                    //c.rgb += (tex.rgb * _LightColor0.rgb * rampColor);// * (atten * 2); // Diffuse and specular.
                    //c.a = tex.a + _LightColor0.a * atten;
                    c.a = 1;
                    return c;
                }
            ENDCG
        }
 
        Pass {
            Tags {"LightMode" = "ForwardAdd"}                       // Again, this pass tag is important otherwise Unity may not give the correct light information.
            Blend One One                                           // Additively blend this pass with the previous one(s). This pass gets run once per pixel light.
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
                    float3  lightDir    : TEXCOORD2;
                    float3 normal		: TEXCOORD1;
                    float3 worldPos : TEXCOORD4;
                    LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
                    
                };
 
                v2f vert (appdata_tan v)
                {
                    v2f o;
                    
                    o.pos = UnityObjectToClipPos( v.vertex);
                    o.uv = v.texcoord.xy;
                   	
					o.lightDir = ObjSpaceLightDir(v.vertex);
					
					o.normal =  v.normal;
                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                    
                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                    return o;
                }
 
                sampler2D _MainTex;
                fixed4 _Color;

                fixed4 _ShadowCol;
                int _ShadowLevel;
                float _ShadowPow;

               // sampler2D _RampTex;
 
                //fixed4 _LightColor0; // Colour of the light used in this pass.
 
                fixed4 frag(v2f i) : COLOR
                {
                    i.lightDir = normalize(i.lightDir);
                    
                    fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
                    //float shadow = SHADOW_ATTENUATION(i);
                    fixed3 col = tex2D(_MainTex, i.uv).rgb;
                    
                    col *= _Color.rgb;
                   
					fixed3 normal = i.normal;                    
                    fixed diff = saturate(dot(i.normal, i.lightDir));
                    diff = diff * 0.5 + 0.5;
                    diff *= atten;
                    diff = pow (diff, _ShadowPow);
                    //float dis = distance (i.worldPos, _WorldSpaceLightPos0);
                    
                    //diff *= shadow;

                    float gap = 1.0 / (_ShadowLevel);
                    float3 rampColor;

                    /*for (int i = 0; i < _ShadowLevel; i++)
                    {
                        if (i * gap <= diff)
                        {
                            //rampColor += lerp (0, _LightColor0.rgb, gap);
                           // rampColor *= (1, _LightColor0.rgb, i * gap);
                            //break;
                            if (i * gap <= diff && diff < (i+1)*gap)
                            {
                                if ((i * gap) - diff > diff - ((i+1) * gap))
                                    rampColor = lerp (0, _LightColor0.rgb, (i * gap));
                                else
                                    rampColor = lerp (0, _LightColor0.rgb, ((i+1) * gap));
                            
                            }
                            
                        }

                       // if (i == _ShadowLevel)
                        //    return atten;
                    }*/

                   // float lightLevel = diff / gap;
                    //lightLevel = round (lightLevel);
                    //lightLevel = lightLevel / (_ShadowLevel+1);

                    // 일단 하드코딩
                    float lightLevel = round (diff * 10) * 0.1;

                    if (0.7 <= lightLevel && lightLevel <= 1)
                    {
                        rampColor = _LightColor0.rgb;
                    }
                    else if (0.4 <= lightLevel && lightLevel < 0.7)
                    {
                        rampColor = lerp (0, _LightColor0.rgb, 0.5);
                    }
                    else
                    {
                        rampColor = 0;
                    }


                    

                    //fixed rampColor = tex2D (_RampTex, float2 (diff, 0.5));
 
                    fixed4 c;
                    //c.rgb = (UNITY_LIGHTMODEL_AMBIENT.rgb * 2 * tex.rgb);         // Ambient term. Only do this in Forward Base. It only needs calculating once.
                    //c.rgb = (tex.rgb * _LightColor0.rgb * rampColor);// * (atten * 2); // Diffuse and specular.
                    
                    

                    c.rgb = col * rampColor;
                    c.a = 1;

                    return c; 
                }
            ENDCG
        }
    }
    FallBack "VertexLit"    // Use VertexLit's shadow caster/receiver passes.
}