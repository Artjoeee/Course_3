using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ColorMusicTrigger : MonoBehaviour
{
    public Light Point1, Point2, Point3;
    public Transform cylinder;
    float intensity = 0f;

    void OnTriggerStay(Collider col)
    {
        if (col.name == "Player")
        {
            intensity = Mathf.PingPong(Time.time * 2, 5);

            Point1.intensity = intensity;
            Point2.intensity = intensity;
            Point3.intensity = intensity;

            cylinder.Rotate(Vector3.up * 50 * Time.deltaTime);
        }
    }
}

