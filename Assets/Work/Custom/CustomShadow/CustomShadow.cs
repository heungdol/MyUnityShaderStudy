using UnityEngine;

public class CustomShadow : MonoBehaviour
{
    public CustomShadowManager shadowManager;
    public float radius;
    //public Color color; // 그림자 색깔은 같잖아

    // 그림자 또는 빛
    // 빛이라면 그림자 덮어씌움
    //public bool isLight;

    void Awake ()
    {
        shadowManager = (CustomShadowManager)FindObjectOfType (typeof (CustomShadowManager));
    }

    void OnEnable ()
    {
        shadowManager.AddShadowToList (GetComponent <CustomShadow> ());
    }

    void OnDisable ()
    {
        shadowManager.RemoveShadowFromList (GetComponent <CustomShadow> ());
    }
    
    public float GetRadius ()
    {
        return radius;
    }
}
