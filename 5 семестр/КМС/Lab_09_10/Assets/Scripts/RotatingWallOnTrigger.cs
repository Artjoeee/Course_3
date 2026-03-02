using UnityEngine;

public class RotatingWallOnTrigger : MonoBehaviour
{
    public float rotateSpeed = 90f;

    public GameObject Wall;

    void Start()
    {
        Collider c = GetComponent<Collider>();
        c.isTrigger = true;
    }

    void OnTriggerStay(Collider other)
    {
        if (other.name == "Hull")
        {
            Wall.transform.Rotate(0f, rotateSpeed * Time.deltaTime, 0f, Space.Self);
        }
    }
}
