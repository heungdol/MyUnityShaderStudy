// 다중 포인트 라이트에 영향을 받는 셰이더

Shader "MyShader/Custom/Object_MultiLightTest"
{
    Properties
    {
		_MainTex ("Main Texture", 2D) = "white" {}
        _RampTex ("Ramp Texture", 2D) = "white" {}
		_RampPow ("Ramp Power", Float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque"
		"LightMode"="Vertex" }
        LOD 200

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"
			#include "Lighting.cginc"

			sampler2D _MainTex;
			sampler2D _RampTex;
			float _RampPow;

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
                float3 worldPos : TEXCOORD2;
            };

			float4x4 inverse(float4x4 input)
			{
				#define minor(a,b,c) determinant(float3x3(input.a, input.b, input.c))
				//determinant(float3x3(input._22_23_23, input._32_33_34, input._42_43_44))
				
				float4x4 cofactors = float4x4(
					minor(_22_23_24, _32_33_34, _42_43_44), 
					-minor(_21_23_24, _31_33_34, _41_43_44),
					minor(_21_22_24, _31_32_34, _41_42_44),
					-minor(_21_22_23, _31_32_33, _41_42_43),
					
					-minor(_12_13_14, _32_33_34, _42_43_44),
					minor(_11_13_14, _31_33_34, _41_43_44),
					-minor(_11_12_14, _31_32_34, _41_42_44),
					minor(_11_12_13, _31_32_33, _41_42_43),
					
					minor(_12_13_14, _22_23_24, _42_43_44),
					-minor(_11_13_14, _21_23_24, _41_43_44),
					minor(_11_12_14, _21_22_24, _41_42_44),
					-minor(_11_12_13, _21_22_23, _41_42_43),
					
					-minor(_12_13_14, _22_23_24, _32_33_34),
					minor(_11_13_14, _21_23_24, _31_33_34),
					-minor(_11_12_14, _21_22_24, _31_32_34),
					minor(_11_12_13, _21_22_23, _31_32_33)
				);
				#undef minor
				return transpose(cofactors) / determinant(input);
			}

            vertOutput vert (vertInput v)
            {
                vertOutput o;

                o.normal = v.normal;
                o.texcoord = v.texcoord;
				o.position = UnityObjectToClipPos (v.position.xyz);
                o.worldPos = mul(unity_ObjectToWorld, v.position);

                return o;
            }

			half4 frag (vertOutput i) : COLOR
			{
				 
				int lightNum = 0;

				float totalDot = 0;
				float3 totalColor = float3 (0, 0, 0);

				for (int index = 0; index < 8; index++)
				{
					// 포인트 라이트가 아니면 거른다
					if (unity_LightPosition [index].w != 1)
						continue;

					//float3 lightDir = i.worldPos - unity_LightPosition
					float3 lightWorldPos = mul( inverse(UNITY_MATRIX_MV), unity_LightPosition[index]).xyz;
					float3 lightDir = i.worldPos - lightWorldPos;	lightDir = normalize (lightDir);

					totalDot += dot (i.normal, lightDir) * unity_LightAtten [index].z;
					totalColor += unity_LightColor [index].xyz * unity_LightAtten [index].z;
					
					lightNum++;
				}


				totalDot /= lightNum;
				totalColor /= lightNum;

				float2 tempUV = float2 (totalDot, 0.5);
				float3 tempColor = tex2Dlod (_RampTex, float4 (tempUV, 0, 0));
				float3 mainColor = tex2Dlod (_MainTex, i.texcoord);

				return float4 (mainColor * tempColor, 1);
			}	
			ENDCG
		}
    }
  //  FallBack "Diffuse"
}
