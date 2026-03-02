using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotation_Quaternion : MonoBehaviour
{
    public float speedX = 90f;
    public float speedZ = 90f;

    private Quaternion startPosition;
    private float angleX;
    private float angleZ;

    // Start is called before the first frame update
    void Start()
    {
        startPosition = transform.rotation;
    }

    // Update is called once per frame
    void Update()
    {
        angleX += speedX * Time.deltaTime;
        angleZ += speedZ * Time.deltaTime;

        //Vector3 axis = new Vector3(1, 1, 0.5f).normalized;
        //Quaternion rotation = Quaternion.AngleAxis(angleX, axis);

        Quaternion rotX = Quaternion.AngleAxis(angleX, Vector3.right);
        Quaternion rotZ = Quaternion.AngleAxis(angleZ, Vector3.forward);

        transform.rotation = startPosition * rotX * rotZ;
    }
}
