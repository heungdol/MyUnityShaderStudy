using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderToonAO : MonoBehaviour {
	public Camera _camera;
	public Material _mat;

	void Start () {
		if (_camera == null)
			_camera = GetComponent<Camera> ();
		if (_camera != null)
			_camera.depthTextureMode = DepthTextureMode.DepthNormals;
	}

	void Update ()
	{

	}

	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		Graphics.Blit(src, dest, _mat);
	}
}

/*
// 5 바이트 5로 25개 검사
				int num0 = 0;
				//int num1 = checkNum * checkNum;
				num0 += CheckPixels (i.uv, i.uv + float2 (-2 * checkAreaRateX, -2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-1 * checkAreaRateX, -2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (0 * checkAreaRateX, -2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (1 * checkAreaRateX, -2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (2 * checkAreaRateX, -2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-2 * checkAreaRateX, -1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-1 * checkAreaRateX, -1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (0 * checkAreaRateX, -1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (1 * checkAreaRateX, -1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (2 * checkAreaRateX, -1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-2 * checkAreaRateX, 0 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-1 * checkAreaRateX, 0 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (0 * checkAreaRateX, 0 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (1 * checkAreaRateX, 0 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (2 * checkAreaRateX, 0 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-2 * checkAreaRateX, 1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-1 * checkAreaRateX, 1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (0 * checkAreaRateX, 1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (1 * checkAreaRateX, 1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (2 * checkAreaRateX, 1 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-2 * checkAreaRateX, 2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (-1 * checkAreaRateX, 2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (0 * checkAreaRateX, 2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (1 * checkAreaRateX, 2 * checkAreaRateY));
				num0 += CheckPixels (i.uv, i.uv + float2 (2 * checkAreaRateX, 2 * checkAreaRateY));

				// 요거 비율로 판단
				float checkRate = num0 / 25;
				checkRate = 1 - checkRate;
*/