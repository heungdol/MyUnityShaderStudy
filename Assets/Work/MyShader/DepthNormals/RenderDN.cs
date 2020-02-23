using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderDN : MonoBehaviour {
	public Camera _camera;
	public Material _mat;
	public bool isNormalsScreen;
	// Use this for initialization
	void Start () {
		if (_camera == null)
			_camera = GetComponent<Camera> ();
		if (_camera != null)
			_camera.depthTextureMode = DepthTextureMode.DepthNormals;
	}

	void Update ()
	{
		if (isNormalsScreen)
		{
			_mat.SetFloat ("_IsNormals", 1);
		}
		else
		{
			_mat.SetFloat ("_IsNormals", 0);
		}
	}

	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		Graphics.Blit(src, dest, _mat);
	}
}
