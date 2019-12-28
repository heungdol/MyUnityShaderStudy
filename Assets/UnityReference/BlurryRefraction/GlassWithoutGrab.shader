// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Similar to regular FX/Glass/Stained BumpDistort shader
// from standard Effects package, just without grab pass,
// and samples a texture with a different name.

Shader "FX/Glass/Stained BumpDistort (no grab)" {
	Properties {
		_GlitchOffset ("Glitch Offset", Range (0, 0.1)) = 0
	}

	Category {

		// We must be transparent, so other objects are drawn before this one.
		Tags { "Queue"="Transparent" "RenderType"="Opaque" }

		SubShader {

			Pass {
				Name "BASE"
				Tags { "LightMode" = "Always" }
				
				CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#include "UnityCG.cginc"

				struct appdata_t {
					float4 vertex : POSITION;
					float2 texcoord: TEXCOORD0;
				};

				struct v2f {
					float4 vertex : POSITION;
					float4 uvgrab : TEXCOORD0;
					//float2 uvbump : TEXCOORD1;
					//float2 uvmain : TEXCOORD2;
					//UNITY_FOG_COORDS(3)
				};

				float _GlitchOffset;

				v2f vert (appdata_t v)
				{
					v2f o;
					o.vertex = UnityObjectToClipPos(v.vertex);
					#if UNITY_UV_STARTS_AT_TOP
					float scale = -1.0;
					#else
					float scale = 1.0;
					#endif
					o.uvgrab = o.vertex;
					o.uvgrab.xy = (float2(o.vertex.x, o.vertex.y*scale) + o.vertex.w) * 0.5;
					//o.uvgrab.zw = o.vertex.zw;
					//o.uvbump = TRANSFORM_TEX( v.texcoord, _BumpMap );
					//o.uvmain = TRANSFORM_TEX( v.texcoord, _MainTex );
					//UNITY_TRANSFER_FOG(o,o.vertex);
					return o;
				}

				sampler2D _GrabBlurTexture;
				float4 _GrabBlurTexture_TexelSize;
				sampler2D _BumpMap;
				sampler2D _MainTex;

				half4 frag (v2f i) : SV_Target
				{
					// calculate perturbed coordinates
					// we could optimize this by just reading the x & y without reconstructing the Z
					//half2 bump = UnpackNormal(tex2D( _BumpMap, i.uvbump )).rg;
					//float2 offset = bump * _BumpAmt * _GrabBlurTexture_TexelSize.xy;
					//i.uvgrab.xy = offset * i.uvgrab.z + i.uvgrab.xy;
					
					half4 col = tex2Dproj (_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab));

					fixed colR = tex2Dproj (_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab + fixed4 (_GlitchOffset, 0, 0, 0))).x;
					fixed colG = tex2Dproj (_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab + fixed4 (0, 0, 0, 0))).y;
					fixed colB = tex2Dproj (_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab + fixed4 (-_GlitchOffset, 0, 0, 0))).z;
					//half4 tint = tex2D(_MainTex, i.uvmain);
					//col = lerp (col, tint, _TintAmt);

					//col.r = tex2Dproj (_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab + fixed4 (0, 0, 0, 0)));
					//col.b = tex2Dproj (_GrabBlurTexture, UNITY_PROJ_COORD(i.uvgrab + fixed4 (0, 0, 0, 0)));
					//UNITY_APPLY_FOG(i.fogCoord, col);

					return fixed4 (colR, colG, colB, 1);
				}
				ENDCG
			}
		}
	}
}
