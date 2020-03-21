Shader "MyEffect/Sprite_Rain"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseOffset ("Noise Effect", Range (0, 10)) = 0
    }
    SubShader
    {
        Cull Back
        
        Tags 
        { 
            "RenderType"="Opaque"
            "Queue"="Transparent" 
            "ForceNoShadowCasting" = "False"
            "IgnoreProjector" = "True"
        } 

        Grabpass {}

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 uvgrab : TEXCOORD1;
                //UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _GrabTexture; 
            float _NoiseOffset;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.uvgrab = ComputeGrabScreenPos (o.vertex);
                ///UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                //UNITY_APPLY_FOG(i.fogCoord, col);

                fixed4 grabCol = tex2Dproj (_GrabTexture, UNITY_PROJ_COORD (i.uvgrab + float4 (0, _NoiseOffset, 0, 0) * col.a));

                return grabCol;
            }
            ENDCG
        }
    }
}
