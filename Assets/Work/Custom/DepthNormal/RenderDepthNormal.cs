﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderDepthNormal : MonoBehaviour
{
    #region Variables
    public Shader curShader;
    public float depthPower;
    public float depthStartPoint;
    public float depthEndPoint;
    private Material screenMat;
    private Camera cam;
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

        cam = GetComponent <Camera> ();
        cam.depthTextureMode = cam.depthTextureMode | DepthTextureMode.DepthNormals;
    }

    void OnRenderImage (RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curShader != null)
        {
            ScreenMat.SetFloat ("_DepthPower", depthPower);
            ScreenMat.SetFloat ("_DepthStartPoint", depthStartPoint);
            ScreenMat.SetFloat ("_DepthEndPoint", depthEndPoint);
            Graphics.Blit (sourceTexture, destTexture, ScreenMat);
        }
        else
        {
            Graphics.Blit (sourceTexture, destTexture);
        }
    }

    void Update ()
    {
        
        depthPower = Mathf.Clamp (depthPower, 0.0f, 1.0f);
        depthStartPoint = Mathf.Clamp (depthStartPoint, 0.0f, 0.5f);
        depthEndPoint = Mathf.Clamp (depthEndPoint, 0.5f, 1.0f);
    }

    void OnDisable () 
    {
        if (screenMat)
        {
            DestroyImmediate (screenMat);
        }
    }
}
