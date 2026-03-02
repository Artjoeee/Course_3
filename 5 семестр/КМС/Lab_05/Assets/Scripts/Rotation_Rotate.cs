using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation_Rotate : MonoBehaviour
{
    public float angularSpeedY = 90f;

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(0f, angularSpeedY * Time.deltaTime, 0f, Space.Self);
    }
}
