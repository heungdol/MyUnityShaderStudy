using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderNightVision : MonoBehaviour
{
    #region Variables
    public Shader curShader;
    public float contrast;
    public float brightness;
    public Color nightVisionColor = Color.green;
    public Texture2D vignetteTexture;
    public Texture2D scanLineTexture;
    public float scanLineTileAmount = 4.0f;
    public Texture2D nightVisionNoise;
    public float noiseXSpeed = 100;
    public float noiseYSpeed = 100;
    public float distortion = 0.2f;
    public float scale = 0.8f;
    private float randomValue = 0;
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
            ScreenMat.SetFloat ("_Contrast", contrast);
            ScreenMat.SetFloat ("_Brightness", brightness);
            ScreenMat.SetColor ("_NightVisionColor", nightVisionColor);
            ScreenMat.SetFloat ("_RandomValue", randomValue);
            ScreenMat.SetFloat ("_Distortion", distortion);
            ScreenMat.SetFloat ("_Scale", scale);

            if (vignetteTexture)
            {
                ScreenMat.SetTexture ("_VignetteTex", vignetteTexture);
            }

            if (scanLineTexture)
            {
                ScreenMat.SetTexture ("_ScanLineTex", scanLineTexture);
                ScreenMat.SetFloat ("_ScanLineTileAmount", scanLineTileAmount);
            }

            if (nightVisionNoise)
            {
                ScreenMat.SetTexture ("_NoiseTex", nightVisionNoise);
                ScreenMat.SetFloat ("_NoiseXSpeed", noiseXSpeed);
                ScreenMat.SetFloat ("_NoiseYSpeed", noiseYSpeed);
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
        contrast = Mathf.Clamp (contrast, 0.0f, 4.0f);
        brightness = Mathf.Clamp (brightness, 0.0f, 2.0f);
        randomValue = Mathf.Clamp (randomValue, -1f, 1f);
        distortion = Mathf.Clamp (distortion, -1f, 1f);
        scale = Mathf.Clamp (scale, 0.0f, 3.0f);
    }

    void OnDisable () 
    {
        if (screenMat)
        {
            DestroyImmediate (screenMat);
        }
    }
}
