using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RobotMove : MonoBehaviour
{
    public float speed = 5f;

    void Update()
    {
        float moveX = 0;
        float moveZ = 0;

        if (Input.GetKey(KeyCode.E))
        { 
            moveX = -1; 
        }
        if (Input.GetKey(KeyCode.R))
        {
            moveX = 1; 
        }
        if (Input.GetKey(KeyCode.T))
        { 
            moveZ = 1;
        }
        if (Input.GetKey(KeyCode.Y))
        { 
            moveZ = -1;
        }

        Vector3 move = new Vector3(moveX, 0, moveZ);
        transform.Translate(move * speed * Time.deltaTime, Space.World);
    }
}

