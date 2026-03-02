using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerMove : MonoBehaviour
{
    public float speed = 5f;
    public float rotSpeed = 10f;

    void Update()
    {
        float moveX = Input.GetAxis("Horizontal");
        float moveZ = Input.GetAxis("Vertical");

        Vector3 move = new Vector3(moveX, 0, moveZ);
        transform.Translate(move * speed * Time.deltaTime, Space.World);

        float rotY = Input.GetAxis("Mouse X") * rotSpeed;
        transform.Rotate(0, rotY, 0);
    }
}
