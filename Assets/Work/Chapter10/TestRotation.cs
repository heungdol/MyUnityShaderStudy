using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestRotation : MonoBehaviour
{
    public float rotationPerSec = 10f;

    void Update ()
    {
        gameObject.transform.Rotate (Vector3.up * rotationPerSec * Time.deltaTime);
    }
}
