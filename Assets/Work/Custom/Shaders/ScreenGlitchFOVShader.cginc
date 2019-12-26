uniform sampler2D _MainTex;

fixed _DepthStart;
fixed _DepthEnd;
fixed _DepthPower;
fixed _DepthThreshold;

fixed _GlitchOffset;

sampler2D _CameraDepthTexture;

fixed getDepth (fixed2 inputUV)
{
    fixed ret = UNITY_SAMPLE_DEPTH ( tex2D (_CameraDepthTexture, inputUV));
    ret = pow (Linear01Depth (ret), _DepthPower);

    if (ret > _DepthEnd)
    {
        ret = 1;
    }
    else if (_DepthEnd >= ret && ret > _DepthStart)
    {
        float p = (ret - _DepthStart) / (_DepthEnd - _DepthStart);
        ret = p;
    }
    else
    {
        ret = 0;
    }

    return ret;
}


fixed4 frag (v2f_img i) : COLOR
{
    fixed currentDepth = getDepth (i.uv.xy);

    fixed2 inputUVLeft = i.uv.xy + fixed2 (_GlitchOffset, 0);
    fixed2 inputUVRight = i.uv.xy - fixed2 (_GlitchOffset, 0);

    fixed targetDepthLeft = getDepth (inputUVLeft);
    fixed targetDepthRight = getDepth (inputUVRight);
    
    fixed4 finalCol = tex2D (_MainTex, i.uv.xy);
    
    // left
    if (currentDepth > targetDepthLeft && targetDepthLeft > _DepthThreshold )
    {
        finalCol.r = tex2D (_MainTex, i.uv.xy + fixed2 (_GlitchOffset, 0)).r;
    }

    // right
    if (currentDepth > targetDepthRight && targetDepthRight > _DepthThreshold)
    {
        finalCol.b = tex2D (_MainTex, i.uv.xy - fixed2 ( _GlitchOffset, 0)).b;
    }

    return finalCol;
}