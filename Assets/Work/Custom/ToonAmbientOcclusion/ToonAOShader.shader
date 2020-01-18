Shader "MyShader/Custom/ToonAmbientOcclusion"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_CheckGap ("Check Gap", Float) = 5
		_ThresholdN ("Threshold Normals Dot", Range (-1, 1)) = 0
		_ThresholdD ("Threshold Depths Gap", Float) = 0.05 
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

			float _CheckGap;
			float _ThresholdN;
			float _ThresholdD;

			int CheckNormals (float2 uv0, float2 uv1)
			{
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

				// 먼저 노멀의 내적을 확인
				if (dot (normal, _normal) >= _ThresholdN)
					return 0;

				return 1;
			}

			float DotNormals (float2 uv0, float2 uv1)
			{
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

			int CheckDepths (float2 uv0, float2 uv1)
			{
				// 이거는 현재 해당되는 중심픽셀
				float depth = tex2D(_CameraDepthTexture, uv0).r;
				depth = pow (depth, 0.5);

				// 이거는 체크할 픽셀
				float _depth = tex2D(_CameraDepthTexture, uv1 ).r;
				_depth = pow (_depth, 0.5);

				// 그다음 깊이의 관계를 따짐
				if (_depth < depth)
					return 0;

				else if (depth - _depth < _ThresholdD)
					return 0;

				return 1;
			}

			int CheckPixels ( float2 uv0, float2 uv1)
			{
				//if (uv1.x > 1 || uv1.x < 0)
				//	return 0;
				//if (uv1.y > 1 || uv1.y < 0)
				//	return 0;
				
				if (CheckNormals (uv0, uv1) == 1)// && CheckDepths (uv0, uv1) == 1)
					return 1;

				return 0;
			}
			
			// 홀수로만 하자
			// 성능 때문에 어쩔 수 없이 하드코딩
			int num = 5;

			// _ScreenParams
			// float4	x is the width of the camera’s target texture in pixels
			// y is the height of the camera’s target texture in pixels
			// z is 1.0 + 1.0/width
			// w is 1.0 + 1.0/height

			fixed4 frag (v2f i) : SV_Target
			{
				// 높이를 기준으로 할거임
				float screenRate = _ScreenParams.y / _ScreenParams.x;

				float checkAreaRateY = _CheckGap / _ScreenParams.y;
				float checkAreaRateX = checkAreaRateY * screenRate;

				float averageDots = 0;
				
				for (int x = -(num-1)/2; x <= (num-1)/2; x++)
				{
					for (int y = -(num-1)/2; y <= (num-1)/2; y++)
					{
						averageDots += DotNormals (i.uv, i.uv + float2 (x * checkAreaRateX, y * checkAreaRateY));
					}
				}
				
				averageDots /= num * num;

				averageDots = DotNormals (i.uv, i.uv + float2 (2 * checkAreaRateX, 0 * checkAreaRateY));
				averageDots += DotNormals (i.uv, i.uv + float2 (-2 * checkAreaRateX, 0 * checkAreaRateY));
				averageDots /= 1;

				return float4 (averageDots ,averageDots, averageDots, 1);
			}
			ENDCG
		}
	}
}
