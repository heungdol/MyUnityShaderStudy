// 쓰르륵하는 효과 넣을 때 좋을 듯 i.vertex.x > _CameraDepthTexture_TexelSize.z / (1 / _Seperate)

Shader "MyShader/Custom/DNShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_IsNormals ("Depth Zero, Normals One", Float) = 0
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			sampler2D _CameraDepthNormalsTexture;
			float4 _CameraDepthNormalsTexture_TexelSize;

			sampler2D _CameraDepthTexture;
			float4 _CameraDepthTexture_TexelSize;

			float _IsNormals;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			fixed4 frag (v2f i) : SV_Target
			{
				if (_IsNormals == 1)
				{
					fixed4 col = tex2D(_CameraDepthNormalsTexture, i.uv);
					float depth;
					float3 normal;
					DecodeDepthNormal(col, depth, normal);

					return float4(normal, 1);
				}

				float4 col = float4(1, 0, 0, 1);
				float depth = tex2D(_CameraDepthTexture, i.uv).r;
				depth = pow (depth, 0.5);
				col = float4(depth, depth, depth, 1 );

				return col;	
			}
			ENDCG
		}
	}
}
