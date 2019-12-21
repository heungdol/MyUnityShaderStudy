﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderOldFilm : MonoBehaviour
{
    #region Variables
    public Shader curShader;
    
    public float oldFlimEffectAmount = 1.0f;

    public Color sepiaColor = Color.white;
    public Texture2D vignetteTexture;
    public float vignetteAmount = 1.0f;

    public Texture2D scratchesTexture;
    public float scratchesYSpeed = 10.0f;
    public float scratchesXSpeed = 10.0f;

    public Texture2D dustTexture;
    public float dustYSpeed;
    public float dustXSpeed;

    private Material screenMat;
    private float randomValue;
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
            ScreenMat.SetColor ("_SepiaColor", sepiaColor);
            ScreenMat.SetFloat ("_VignetteAmount", vignetteAmount);
            ScreenMat.SetFloat ("_EffectAmount", oldFlimEffectAmount);

            if (vignetteTexture)
            {
                ScreenMat.SetTexture ("_VignetteTex", vignetteTexture);
            }

            if (scratchesTexture)
            {
                ScreenMat.SetTexture ("_ScratchesTex", scratchesTexture);
                ScreenMat.SetFloat ("_ScratchesYSpeed", scratchesYSpeed);
                ScreenMat.SetFloat ("_ScratchesXSpeed", scratchesXSpeed);
            }

            if (dustTexture)
            {
                ScreenMat.SetTexture ("_DustTex", dustTexture);
                ScreenMat.SetFloat ("_dustYSpeed", dustYSpeed);
                ScreenMat.SetFloat ("_dustXSpeed", dustXSpeed);
                ScreenMat.SetFloat ("_RandomValue", randomValue);
            }

            Graphics.Blit (sourceTexture, destTexture, ScreenMat);
        }
        else
        {
            Graphics.Blit (sourceTexture, destTexture);
        }
    }

    void Update ()
    {
        vignetteAmount = Mathf.Clamp01 (vignetteAmount);
        oldFlimEffectAmount = Mathf.Clamp (oldFlimEffectAmount, 0, 1.5f);
        randomValue = Random.Range (-1f, 1f);
    }

    void OnDisable () 
    {
        if (screenMat)
        {
            DestroyImmediate (screenMat);
        }
    }
}
