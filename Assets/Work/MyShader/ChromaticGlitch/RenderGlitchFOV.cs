using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class RenderGlitchFOV : MonoBehaviour {
	public Camera _camera;
	public Material _mat;
	// Use this for initialization
	void Start () {

	}

	void OnRenderImage(RenderTexture src, RenderTexture dest) {
		Graphics.Blit(src, dest, _mat);
	}
}
