Shader "MyShader/Custom/Screen_ToonAmbientOcclusion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_PatternTex ("Pattern Texture", 2D) = "black" {}
		_PatternColor ("Pattern Color", Color) = (0, 0, 0, 1) 
		_PatternScale ("Pattern Scale", Float) = 0.1
		_CheckGap ("Check Gap", Range (0, 0.1)) = 0.1
		_CheckNums ("Check Nums", Int) = 5
		//_ThresholdN ("Threshold Normals Dot", Range (-1, 1)) = 0
		_ThresholdD ("Threshold Depths Gap", Range (-1, 1)) = 0.05 
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
			sampler2D _PatternTex;

			int _CheckNums;

			float _PatternScale;
			float4 _PatternColor;
			float _CheckGap;
			//float _ThresholdN;
			float _ThresholdD;

			// 서로 간섭하지 않는 관계라면 0, 아니면 1 반환 
			// 긍데 솔찍히 왜 이런 조건이어야 하는지 내 머리론 안굴려짐 ㅎㅎ 막하다 된거임
			int CheckDepths (float2 uv0, float2 uv1)
			{
				// 이거는 현재 해당되는 중심픽셀
				float depth = tex2D(_CameraDepthTexture, uv0).r;
				depth = pow (depth, 0.5);

				// 이거는 체크할 픽셀
				float _depth = tex2D(_CameraDepthTexture, uv1 ).r;
				_depth = pow (_depth, 0.5);

				// 그다음 깊이의 관계를 따짐
				if (depth - _depth > 0)
					return 0;

				else if (depth - _depth < _ThresholdD)
					return 0;

				return 1;
			}

			float DotNormals (float2 uv0, float2 uv1)
			{
				// 먼저 깊이관계
				if (CheckDepths (uv0, uv1) == 0)
					return 1;
				
				// 이거는 현재 해당되는 중심픽셀
				fixed4 col = tex2D(_CameraDepthNormalsTexture, uv0);
				float depth;
				float3 normal;
				DecodeDepthNormal(col, depth, normal);

				// 이거는 체크할 픽셀
				fixed4 _col = tex2D(_CameraDepthNormalsTexture, uv1);
				float _depth;
				float3 _normal;
				DecodeDepthNormal(_col, _depth, _normal);

				float result = dot (normal, _normal);
				result = result * 0.5 + 0.5;

				return result;
			}

			// _ScreenParams
			// float4	x is the width of the camera’s target texture in pixels
			// y is the height of the camera’s target texture in pixels
			// z is 1.0 + 1.0/width
			// w is 1.0 + 1.0/height
			// -totalOffset * (_ScreenParams.x / _ScreenParams.y)

			fixed4 frag (v2f i) : SV_Target
			{
				// 홀수로만 하자
				// 성능 때문에 어쩔 수 없이 하드코딩
				int total = 0;

				float averageDots = 0;
				
				for (int x = -_CheckNums; x <= _CheckNums; x++)
				{
					for (int y = -_CheckNums; y <= _CheckNums; y++)
					{
						if (distance (x, y) > _CheckNums)	continue;

						averageDots += DotNormals (i.uv, i.uv + float2 (x * _CheckGap, y * _CheckGap * (_ScreenParams.x / _ScreenParams.y)));
						total++;
					}
				}
				
				// 평평할수록 1에 가깝다
				averageDots /= total;
				
				// 패턴 읽어오기
				float patternCol = tex2D (_PatternTex, i.uv * _PatternScale * float2 (1, (_ScreenParams.y / _ScreenParams.x))).r;

				float4 mainCol = tex2D (_MainTex, i.uv);

				float3 totalCol = ((1 - averageDots) * patternCol * _PatternColor.a) * _PatternColor.rgb 
								+ (1 - (1 - averageDots) * patternCol * _PatternColor.a) * mainCol.rgb;

				return float4 (totalCol, 1);
			}
			ENDCG
		}
	}
}
