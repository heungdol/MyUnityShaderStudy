// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "MyShader/Custom/Object_ColorfulToon"
{
    Properties 
    {
        _MainTex ("Base (RGB) Alpha (A)", 2D) = "white" {}

        _RampTex ("Ramp Texture", 2D) = "white" {}

        _SpecCol ("Specular Color", Color) = (1, 1, 1, 1)
        _SpecRange ("Specular Threshold", Range (0, 1)) = 0.75
        _SpecWidth ("Specular Width", Range (0, 1)) = 0.1
        _SpecPow ("Specular Power", Range (0.1, 10)) = 1
        [IntRange]_SpecLevel ("Specular Level", Range (1, 10)) = 2
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
                    float3  lightDir    : TEXCOORD2;
                    float3 normal		: TEXCOORD1;
                    float3 worldPos : TEXCOORD3;
                    //float3  lightDir    : TEXCOORD4;
                    LIGHTING_COORDS(3,4)                            // Macro to send shadow & attenuation to the vertex shader.
                };
 
                v2f vert (appdata_tan v)
                {
                    v2f o;
                    
                    o.pos = UnityObjectToClipPos( v.vertex);
                    o.uv = v.texcoord.xy;
					
					o.normal =  v.normal;

                    o.worldPos = mul(unity_ObjectToWorld, v.vertex);

                    //o.worldNormal = UnityObjectToWorldNormal (v.normal);

                    o.lightDir = ObjSpaceLightDir(v.vertex);

                    TRANSFER_VERTEX_TO_FRAGMENT(o);                 // Macro to send shadow & attenuation to the fragment shader.
                    return o;
                }
 
                sampler2D _MainTex;
                sampler2D _RampTex;

                float4 _SpecCol;

                float _SpecRange;
                float _SpecWidth;
                float _SpecPow;
                int _SpecLevel;


                fixed4 frag(v2f i) : COLOR
                {
                    float4 resultCol;

                    fixed atten = LIGHT_ATTENUATION(i); // Macro to get you the combined shadow & attenuation value.
                    fixed4 tex = tex2D(_MainTex, i.uv);

                    float3 worldNormal = UnityObjectToWorldNormal (i.normal);

                    float3 viewDir = normalize (_WorldSpaceCameraPos.xyz - i.worldPos);
                    float3 lightDir;

                    if (_WorldSpaceLightPos0.w == 0)
                        lightDir = _WorldSpaceLightPos0.xyz;
                    else
                        lightDir = normalize (_WorldSpaceLightPos0.xyz - i.worldPos);

                    float3 halfDir = normalize (viewDir + lightDir);
                    float spec = dot (worldNormal, halfDir);
                    spec = pow (spec, _SpecPow);

                    float4 specCol;

                    float3 totalNor = worldNormal * 0.5 + 0.5;
                    totalNor = round (totalNor * _SpecLevel) / _SpecLevel;

                    if (spec > _SpecRange + _SpecRange * _SpecWidth)
                    {
                        specCol.rgb = _SpecCol.rgb;
                        specCol.a = _SpecCol.a;
                    }
                    else if (_SpecRange + _SpecRange * _SpecWidth > spec && spec > _SpecRange)
                    {
                        specCol.rgb = totalNor.xyz;
                        specCol.a = _SpecCol.a;
                    }
                    else if (_SpecRange > spec)
                    {
                        specCol.a = 0;
                    }

                    fixed diff = saturate(dot(i.normal, i.lightDir));
                    //diff = diff * 0.5 + 0.5;
                    diff *= atten;

                    float3 rampColor = tex2Dlod (_RampTex, float4 (diff, 0.5, 0, 0)).rgb;

                    
                    resultCol.rgb = tex * rampColor;
                    resultCol.rgb = specCol.a * specCol.rgb + (1 - specCol.a) * resultCol.rgb;
                    //resultCol.rgb += specCol;

                    resultCol.a = 1;

                    return resultCol;
                }
            ENDCG
        }
 
    }
    //FallBack "VertexLit"  
}