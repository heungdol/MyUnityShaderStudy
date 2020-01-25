using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
public class CustomShadowManager : MonoBehaviour
{
    public Material customShadowMat;
    //public float radius;
    //public Color color = Color.white;

    public List<CustomShadow> shadows;

    void Update()
    {
        if (customShadowMat != null)
        {
            //Vector3 pos = transform.position;
            //pos.y = 0f;

            customShadowMat.SetInt ("_Points_Length", shadows.Count);

            if (shadows.Count != 0)
            {
                Vector4 [] properties = new Vector4 [shadows.Count]; //(x, y, z, radius)
                //Vector4 [] colors = new Vector4 [shadows.Count];

                // 셰이더에 정보를 전달할 수 있도록 배열들로 가공한다
                for (int i = 0; i < shadows.Count; i++)
                {
                    Vector3 pos = shadows [i].gameObject.transform.position;

                    properties [i] = new Vector4 (pos.x, pos.y, pos.z, shadows [i].GetRadius ());
                    //colors [i] = shadows [i].GetColor ();
                }

                customShadowMat.SetVectorArray ("_Properties", properties);
                //customShadowMat.SetVectorArray ("_Colors", colors);
            }
        }
    }

    public void AddShadowToList (CustomShadow shadow)
    {
        shadows.Add (shadow);
    }

    public void RemoveShadowFromList (CustomShadow shadow)
    {
        shadows.Remove (shadow);
    }
}