using UnityEngine;

public class LightTriggerFlash : MonoBehaviour
{
    public Light targetLight;

    public float activeIntensity = 10f;
    public float inactiveIntensity = 0f;

    void Start()
    {
        Collider c = GetComponent<Collider>();
        c.isTrigger = true;
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.name == "Hull" && targetLight != null)
        { 
            targetLight.intensity = activeIntensity; 
        }
    }

    void OnTriggerExit(Collider other)
    {
        if (other.name == "Hull" && targetLight != null)
        { 
            targetLight.intensity = inactiveIntensity; 
        }
    }
}
