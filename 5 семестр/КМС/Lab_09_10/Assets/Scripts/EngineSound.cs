using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EngineSound : MonoBehaviour
{
    private bool isPlaying = false;
    public AudioSource zvtank;

    void Start()
    {
        if (zvtank == null)
        { 
            zvtank = GetComponent<AudioSource>(); 
        }

        if (zvtank == null)
        { 
            Debug.LogError("AudioSource не найден. Добавьте AudioSource на этот объект."); 
        }
    }

    void Update()
    {
        if ((Input.GetAxis("Horizontal") != 0 || Input.GetAxis("Vertical") != 0) && !isPlaying)
        {
            zvtank.Play();
            isPlaying = true;
        }

        if (Input.GetAxis("Horizontal") == 0 &&
            Input.GetAxis("Vertical") == 0 && isPlaying)
        {
            zvtank.Stop();
            isPlaying = false;
        }
    }
}
