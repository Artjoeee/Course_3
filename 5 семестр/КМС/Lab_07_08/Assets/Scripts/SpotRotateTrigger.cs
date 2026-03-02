using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpotRotateTrigger : MonoBehaviour
{
    public Light Spot;

    void OnTriggerStay(Collider col)
    {
        if (col.name == "Player")
        { 
            Spot.transform.Rotate(Vector3.up * 120 * Time.deltaTime); 
        }
    }
}

