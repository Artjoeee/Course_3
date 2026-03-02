using UnityEngine;

public class Projectile : MonoBehaviour
{
    public float speed = 40f;

    public float lifeSeconds = 3f;

    public GameObject explosionPrefab;

    public float explosionLifetime = 2f;
    public string targetTag = "goal";

    public AudioSource audioSource;

    private Rigidbody rb;
    private Renderer rend;
    private Collider col;
    private bool hasCollided = false;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        rend = GetComponent<Renderer>();
        col = GetComponent<Collider>();

        audioSource = GetComponent<AudioSource>();

        if (audioSource == null)
        {
            audioSource = gameObject.AddComponent<AudioSource>();
            audioSource.playOnAwake = false;
        }
    }

    void Start()
    {
        Destroy(gameObject, lifeSeconds);

        if (rb == null)
        {
            Debug.LogWarning("Projectile: Rigidbody отсутствует. Добавьте Rigidbody.");
        }
    }

    void Update()
    {
        if (rb.isKinematic == true)
        {
            transform.position += transform.forward * speed * Time.deltaTime;
        }
    }

    void OnCollisionEnter(Collision collision)
    {
        if (hasCollided)
        { 
            return;
        }

        hasCollided = true;

        //if (!string.IsNullOrEmpty(targetTag))
        //{
        //    if (!collision.gameObject.CompareTag(targetTag))
        //    {
        //        Destroy(gameObject);
        //        return;
        //    }
        //}

        if (rend != null)
        { 
            rend.enabled = false; 
        }

        if (col != null)
        {
            col.enabled = false;
        }

        Vector3 contactPoint = transform.position;

        if (collision.contactCount > 0)
        {
            contactPoint = collision.contacts[0].point;
        }

        if (explosionPrefab != null)
        {
            GameObject ex = Instantiate(explosionPrefab, contactPoint, Quaternion.identity);
            Destroy(ex, explosionLifetime);
        }

        if (audioSource != null)
        {
            audioSource.PlayOneShot(audioSource.clip);
        }

        Rigidbody targetRb = collision.rigidbody;

        if (targetRb != null)
        {
            Vector3 pushDir = (collision.transform.position - transform.position).normalized;
            float pushStrength = 5f;

            targetRb.AddForce(pushDir * pushStrength, ForceMode.Impulse);
        }

        Destroy(gameObject, 0.1f);
    }
}
