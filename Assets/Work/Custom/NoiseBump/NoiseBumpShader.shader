Shader "MyShader/Custom/Object_NoiseBump"
{
    Properties
    {
        //_MainTex ("Texture", 2D) = "white" {}
        _MainColor ("Main Color", Color) = (1, 1, 1, 1)

        _TempTex ("Temp Texture", 2D) = "white" {}
 
        _NoiseTex ("Noise Texture", 2D) = "white" {}
        _NoiseDegree ("Noise Degree", Range (0, 10)) = 0.1
        _NoiseScale ("Noise Scale", Range (0.5, 10)) = 1

       // _DissolveTex ("Dissolve Tex", 2D) = "white" {}
       // _DissolvePow ("Dissolve Pow", Range (0.5, 2)) = 1
       // _DissolvePro ("Dissolve Progretion", Range (0, 1)) = 0
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
            #pragma target 3.0

            #include "UnityCG.cginc"

            float4 _MainColor;

            sampler2D _TempTex;

            sampler2D _NoiseTex;
            float _NoiseDegree;
            float _NoiseScale;

            //sampler2D _DissolveTex;
           // float _DissolvePro;
           // float _DissolvePow;

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
                float3 lightDir : POSITION1;
            };

            vertOutput vert (vertInput v)
            {
                vertOutput o;

                o.normal = v.normal;
                o.texcoord = v.texcoord;
                o.worldPos = mul(unity_ObjectToWorld, v.position);

                // 여기서 uv 계산을 끝내야함
                float noise = tex2Dlod  (_NoiseTex, float4 (o.worldPos.xy / _NoiseScale, 0, 0)).r;
                noise = noise * 2 - 1;

                o.position = UnityObjectToClipPos (v.position.xyz + o.normal * noise * _NoiseDegree);
               //o.viewDir = normalize (ObjSpaceViewDir (v.position));
                o.lightDir = ObjSpaceLightDir (v.position);

                return o;
            }

            float4 frag (vertOutput i) : SV_TARGET 
            {
                //float dissolve = tex2D (_DissolveTex, i.worldPos.xy / i.worldPos.z).r;
               // dissolve = pow (dissolve, _DissolvePow);
               // dissolve = (1 - _DissolvePro) + dissolve;

               // float a = 1;
               // a = (dissolve > 1) ? 1 : 0;

                float d = dot (i.normal, i.lightDir);
                d = d * 0.5 + 0.5;

                float3 temp = tex2D (_TempTex, float2 (d,  0.5)).rgb;

                return float4 (_MainColor.rgb * temp, 1 );
            }
            ENDCG
        }
    }
}
