using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Move_Key : MonoBehaviour
{
    public float speed = 5f;

    // Update is called once per frame
    void Update()
    {
        Vector3 move = Vector3.zero;

        if (Input.GetKey(KeyCode.W))
            move.y += 1;
        if (Input.GetKey(KeyCode.S))
            move.y -= 1;

        if (Input.GetKey(KeyCode.A))
            move.x -= 1;
        if (Input.GetKey(KeyCode.D))
            move.x += 1;

        if (Input.GetKey(KeyCode.Q))
            move.z += 1;
        if (Input.GetKey(KeyCode.E))
            move.z -= 1;

        transform.Translate(speed * Time.deltaTime * move);
    }
}
