using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScriptScale : MonoBehaviour
{
    public float scaleSpeedX = 0.5f;
    public float scaleSpeedY = 0.5f;

    // Update is called once per frame
    void Update()
    {
        Vector3 s = transform.localScale;

        s.x += scaleSpeedX * Time.deltaTime;
        s.y += scaleSpeedY * Time.deltaTime;

        transform.localScale = s;
    }
}
