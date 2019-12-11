using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class SetRadiusProperties : MonoBehaviour
{
    public Material radiusMat;
    public float radius;
    public Color color = Color.white;

    void Update()
    {
        if (radiusMat != null)
        {
            Vector3 pos = transform.position;
            pos.y = 0f;

            radiusMat.SetVector ("_Center", pos);
            radiusMat.SetFloat ("_Radius", radius);
            radiusMat.SetColor ("_RadiusColor", color);
        }
    }
}
