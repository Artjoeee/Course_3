using UnityEngine;

public class TankSoundController : MonoBehaviour
{
    public AudioSource engineSource;

    public float engineIdlePitch = 0.3f;
    public float engineMaxPitch = 0.5f;

    public float engineIdleVolume = 0.3f;
    public float engineMaxVolume = 0.5f;

    void Start()
    {
        if (engineSource == null)
        {
            engineSource = GetComponent<AudioSource>();
        }

        if (engineSource && engineSource.clip)
        {
            engineSource.clip = engineSource.clip;
            engineSource.loop = true;
            engineSource.Play();
        }
        else
        {
            Debug.LogError("На объекте нет AudioSource. Добавьте его в инспекторе.");
        }
    }

    void Update()
    {
        if (!engineSource)
        {
            return;
        }

        float moveInput = Mathf.Abs(Input.GetAxis("Vertical")) +
                          Mathf.Abs(Input.GetAxis("Horizontal"));

        moveInput = Mathf.Clamp01(moveInput);

        engineSource.pitch = Mathf.Lerp(engineIdlePitch, engineMaxPitch, moveInput);
        engineSource.volume = Mathf.Lerp(engineIdleVolume, engineMaxVolume, moveInput);
    }
}
