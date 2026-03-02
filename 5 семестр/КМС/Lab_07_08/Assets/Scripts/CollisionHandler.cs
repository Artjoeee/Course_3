using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CollisionHandler : MonoBehaviour
{
    public Texture tex1;
    public Texture tex2;
    public GameObject Cube1;
    public Texture newTex;

    void OnCollisionEnter(Collision col)
    {
        //if (col.gameObject.name == "Cube1" || col.gameObject.name == "Cube2")
        //{
        //    col.gameObject.GetComponent<Renderer>().material.color = Color.red;
        //}

        if (col.gameObject.name == "Cube1")
        { 
            col.gameObject.GetComponent<Renderer>().material.mainTexture = tex1; 
        }

        if (col.gameObject.name == "Cube2")
        { 
            col.gameObject.GetComponent<Renderer>().material.mainTexture = tex2; 
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.T))
        {
            Cube1.GetComponent<Renderer>().material.mainTexture = newTex;
        }
    }
}
