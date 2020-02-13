Shader "MyShader/Custom/Object_NoiseBump"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)

        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseDegree ("Noise Degree", Range (0, 10)) = 0.1
        _NoiseScale ("Noise Scale", Range (0.5, 10)) = 1
    }
    SubShader
    {
        Blend SrcAlpha OneMinusSrcAlpha

        Tags { 
            "RenderType"="Opaque"
            "Queue"="Transparent" 
            "ForceNoShadowCasting" = "False"
            "IgnoreProjector" = "True"
            } 

        Pass
        {
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _MainColor;

            sampler2D _NoiseTex;
            float4 _NoiseTex_ST;

            float _NoiseDegree;
            float _NoiseScale;

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
                float3 viewDir : POSITION1;
            };

            vertOutput vert (vertInput v)
            {
                vertOutput o;

                o.normal = v.normal;
                o.texcoord = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, v.position);

                // 여기서 uv 계산을 끝내야함
                float noise = tex2Dlod  (_NoiseTex, float4 (o.worldPos.xy / _NoiseScale, 0, 0)).r;

                o.position = UnityObjectToClipPos (v.position.xyz + o.normal * noise * _NoiseDegree);
                o.viewDir = normalize (ObjSpaceViewDir (v.position));

                return o;
            }

            float4 frag (vertOutput i) : SV_TARGET 
            {
                return _MainColor;
            }
            ENDCG
        }
    }
}
