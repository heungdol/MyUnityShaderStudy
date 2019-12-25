using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RenderGlitchFOV : MonoBehaviour
{
#region Variables
    public Shader curShader;
    
    public float depthStart = 0.25f;
    public float dpethEnd = 0.75f;

    public float depthPower = 0.3f;
    public float glitchThreshold = 0.2f;
    public float glitchOffset;
    
    private Material screenMat;
    #endregion

    // 보여주기식 ScreenMat
    // 보여주지 않고 하나의 데이터만 가지게 하는 screenMat

    #region Properties
    Material ScreenMat
    {
        get
        {
            if (screenMat == null)
            {
                screenMat = new Material (curShader);
                screenMat.hideFlags = HideFlags.HideAndDontSave;
            }
            return screenMat;
        }
    }
    #endregion

    // 빌드된 해당 플랫폼에서 지원하는 이미지이펙트인지 확인
    // 지원하지 않아도 에러가 뜨지 않도록 해준다
    void Start () 
    {
        if (!SystemInfo.supportsImageEffects)
        {
            enabled = false;
            return;
        }

        if (!curShader && !curShader.isSupported)
        {
            enabled = false;
        }
    }

    void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curShader != null)
        {
            ScreenMat.SetFloat ("_DepthPower", depthPower);
            ScreenMat.SetFloat ("_DepthStart", depthStart);
            ScreenMat.SetFloat ("_DepthEnd", dpethEnd);

            ScreenMat.SetFloat ("_GlitchOffset", glitchOffset);
            ScreenMat.SetFloat ("_GlitchThreshold", glitchThreshold);
            
            Graphics.Blit (sourceTexture, destTexture, ScreenMat);
        }
        else
        {
            Graphics.Blit (sourceTexture, destTexture);
        }
    }

    void Update ()
    {
        //Camera.main.depthTextureMode = DepthTextureMode.Depth;
        depthStart = Mathf.Clamp (depthStart, 0.0f, 0.5f);
        dpethEnd = Mathf.Clamp (dpethEnd, 0.5f, 1f);
        depthPower = Mathf.Clamp (depthPower, 0.0f, 1f);

        glitchThreshold = Mathf.Clamp (glitchThreshold, 0.0f, 1.0f);
        glitchOffset = Mathf.Clamp (glitchOffset, 0.0f, 0.1f);
        
    }

    void OnDisable () 
    {
        if (screenMat)
        {
            DestroyImmediate (screenMat);
        }
    }
}
