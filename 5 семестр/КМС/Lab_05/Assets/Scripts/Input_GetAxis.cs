using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Input_GetAxis : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float rotationSpeed = 100f;

    private float verticalAngle = 0f;
    private float horizontalAngle = 0f;

    // Update is called once per frame
    void Update()
    {
        float x = Input.GetAxis("Horizontal");
        float z = Input.GetAxis("Vertical");

        transform.Translate(x * moveSpeed * Time.deltaTime, 0, z * moveSpeed * Time.deltaTime);

        float mx = Input.GetAxis("Mouse X");
        float my = Input.GetAxis("Mouse Y");

        verticalAngle -= my * rotationSpeed * Time.deltaTime;
        horizontalAngle += mx * rotationSpeed * Time.deltaTime;

        verticalAngle = Mathf.Clamp(verticalAngle, 0f, 90f);

        transform.rotation = Quaternion.identity;
        transform.Rotate(verticalAngle, horizontalAngle, 0f);
    }
}
