// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Custom/Object_ColorfulToon"
{
    Properties 
    {
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}

        _SpecCol ("Specular Color", Color) = (1, 1, 1, 1)

        _SpecRange0 ("Specular Range 0", Range (0, 1)) = 0.75
        _SpecRange1 ("Specular Range 1", Range (0, 1)) = 0.5

        _SpecPow ("Specular Power", Range (0.1, 10)) = 1
        
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
                    float3  worldNormal    : TEXCOORD2;
                    float3 normal		: TEXCOORD1;
                    float3 worldPos : TEXCOORD3;
                    LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
                };
 
                v2f vert (appdata_tan v)
                {
                    v2f o;
                    
                    o.pos = UnityObjectToClipPos( v.vertex);
                    o.uv = v.texcoord.xy;
					
					o.normal =  v.normal;

                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                    o.worldNormal = UnityObjectToWorldNormal (v.normal);

                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                    return o;
                }
 
                sampler2D _MainTex;

                float4 _SpecCol;

                float _SpecRange0;
                float _SpecRange1;

                float _SpecPow;

                fixed4 frag(v2f i) : COLOR
                {
                    float4 resultCol;

                    fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
                    fixed4 tex = tex2D(_MainTex, i.uv);
                    
                    //tex *= _Color;

                    float3 viewDir = normalize (_WorldSpaceCameraPos.xyz - i.worldPos);
                    float3 lightDir;

                    if (_WorldSpaceLightPos0.w == 0)
                        lightDir = _WorldSpaceLightPos0.xyz;
                    else
                        lightDir = normalize (_WorldSpaceLightPos0.xyz - i.worldPos);

                    float3 halfDir = normalize (viewDir + lightDir);
                    float spec = dot (i.worldNormal, halfDir);
                    spec = pow (spec, _SpecPow);

                    float4 specCol;

                    float3 totalNor = i.worldNormal * 0.5 + 0.5;
                    totalNor = round (totalNor * 2) / 2;

                    if (spec > _SpecRange0)
                    {
                        specCol.rgb = _SpecCol.rgb;
                        specCol.a = _SpecCol.a;
                    }
                    else if (_SpecRange0 > spec && spec > _SpecRange1)
                    {
                        specCol.rgb = totalNor.xyz;
                        specCol.a = _SpecCol.a;
                    }
                    else if (_SpecRange1 > spec)
                    {
                        specCol.a = 0;
                    }
                    
                    //float3 (round (viewDir.r * 4) / 4, round (viewDir.g * 4) / 4, round (viewDir.b * 4) / 4);

                    
                    resultCol.rgb = tex;
                    resultCol.rgb = specCol.a * specCol.rgb + (1 - specCol.a) * resultCol.rgb;
                    //resultCol.rgb += specCol;

                    resultCol.a = 1;

                    return resultCol;
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
                    float3 screenPos : TEXCOORD5;
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

                    o.screenPos = o.pos.xyw;
                    o.screenPos.y *= _ProjectionParams.x;

                    return o;
                }

                fixed4 frag(v2f i) : COLOR
                {
                    return 0; 
                }
            ENDCG
        }
    }
    FallBack "VertexLit"  
}