using UnityEngine;

public class BarrelShoot : MonoBehaviour
{
    public GameObject projectilePrefab;
    public float barrelLength = 1.0f;
    public AudioSource shootSource;

    void Start()
    {
        if (shootSource == null)
        {
            shootSource = GetComponent<AudioSource>();
        }

        if (shootSource == null)
        {
            Debug.LogError("На объекте нет AudioSource. Добавьте его в инспекторе.");
        }
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space))
        {
            Fire();
        }
    }

    void Fire()
    {
        if (projectilePrefab == null)
        {
            Debug.LogWarning("Projectile prefab не задан в инспекторе.");
            return;
        }

        // gameObject.GetComponent<AudioSource>().PlayOneShot(
        //     gameObject.GetComponent<AudioSource>().clip);

        if (shootSource != null && shootSource.clip != null)
        {
            shootSource.PlayOneShot(shootSource.clip);
        }
        else
        {
            Debug.LogWarning("Не задан источник или звук выстрела.");
        }

        Vector3 spawnPos = transform.position + transform.forward * barrelLength;
        Quaternion spawnRot = transform.rotation;

        Instantiate(projectilePrefab, spawnPos, spawnRot);
    }
}
