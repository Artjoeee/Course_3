using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GateTrigger : MonoBehaviour
{
    public Transform leftDoor;
    public Transform rightDoor;

    private Vector3 leftStart;
    private Vector3 rightStart;

    public GameObject flyingCube;

    void Start()
    {
        leftStart = leftDoor.position;
        rightStart = rightDoor.position;
    }

    void OnTriggerEnter(Collider col)
    {
        if (col.name == "Player")
        {
            leftDoor.position = leftStart + new Vector3(-1, 0, 0);
            rightDoor.position = rightStart + new Vector3(1, 0, 0);
        }
    }

    void OnTriggerExit(Collider col)
    {
        if (col.name == "Player")
        {
            leftDoor.position = leftStart;
            rightDoor.position = rightStart;
        }
    }

    void OnTriggerStay(Collider col)
    {
        if (col.name == "Robot" && flyingCube != null)
        {
            flyingCube.transform.Rotate(Vector3.forward * 30 * Time.deltaTime);
            //flyingCube.transform.Translate(Vector3.forward * Time.deltaTime, Space.World);
        }
    }
}

