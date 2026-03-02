using System.Collections;
using UnityEngine;

public class Bot : MonoBehaviour
{
    public float moveSpeed = 3f;
    public float rotSpeedTank = 2f;

    public Transform turret;
    public Transform barrel;

    public float rotSpeedTurret = 4f;
    public float rotSpeedBarrel = 6f;
    public float minBarrelPitch = -30f;
    public float maxBarrelPitch = 15f;
    public float barrelLength = 2f;

    public GameObject projectilePrefab;

    public float shootCooldown = 3f;
    private bool canShoot = true;

    public float stopDistance = 8f;

    public float targetHeightOffset = 0f;

    public int life = 3;

    public AudioSource shootSource;

    private RaycastHit hit;

    private float currentBarrelPitch = 0f;

    private void Start()
    {
        if (shootSource == null)
        {
            shootSource = GetComponent<AudioSource>();
        }

        if (shootSource == null)
        {
            Debug.LogError("На объекте нет AudioSource. Добавьте его в инспекторе.");
        }

        if (turret == null)
        { 
            Debug.LogWarning("Turret not set on Bot."); 
        }

        if (barrel == null)
        { 
            Debug.LogWarning("Barrel not set on Bot."); 
        }

        if (barrel != null)
        {
            currentBarrelPitch = barrel.localEulerAngles.x;

            if (currentBarrelPitch > 180f)
            { 
                currentBarrelPitch -= 360f; 
            }

            currentBarrelPitch = Mathf.Clamp(currentBarrelPitch, minBarrelPitch, maxBarrelPitch);
        }
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.tag != "Player")
        { 
            return; 
        }

        Transform playerT = other.transform;

        Vector3 targetPoint = playerT.position;

        Collider playerCollider = other.GetComponent<Collider>();

        if (playerCollider != null)
        {
            targetPoint = playerCollider.bounds.center;
        }

        targetPoint += Vector3.up * targetHeightOffset;

        Vector3 toTarget = targetPoint - transform.position;

        float distance = toTarget.magnitude;

        if (distance > stopDistance)
        {
            Vector3 flatDir = new Vector3(toTarget.x, 0f, toTarget.z);

            if (flatDir.sqrMagnitude > 0.0001f)
            {
                Quaternion desiredBodyRot = Quaternion.LookRotation(flatDir);

                transform.rotation = Quaternion.Slerp(
                    transform.rotation,
                    desiredBodyRot,
                    Time.deltaTime * rotSpeedTank
                );
            }

            Vector3 forward = transform.forward * moveSpeed * Time.deltaTime;
            transform.position += forward;
        }
        else
        {
            Vector3 flatDir = new Vector3(toTarget.x, 0f, toTarget.z);

            if (flatDir.sqrMagnitude > 0.0001f)
            {
                Quaternion desiredBodyRot = Quaternion.LookRotation(flatDir);

                transform.rotation = Quaternion.Slerp(
                    transform.rotation, 
                    desiredBodyRot, 
                    Time.deltaTime * rotSpeedTank * 0.5f
                );
            }
        }

        if (turret != null)
        {
            Vector3 localTargetDir = transform.InverseTransformPoint(targetPoint);

            localTargetDir.y = 0f;

            if (localTargetDir.sqrMagnitude > 0.0001f)
            {
                Quaternion desiredLocalRot = Quaternion.LookRotation(localTargetDir);

                turret.localRotation = Quaternion.Slerp(
                    turret.localRotation,
                    desiredLocalRot,
                    Time.deltaTime * rotSpeedTurret
                );
            }
        }

        if (barrel != null && turret != null)
        {
            Vector3 dirFromBarrel = (targetPoint - barrel.position).normalized;

            Quaternion worldRot = Quaternion.LookRotation(dirFromBarrel);

            Quaternion localDesired = Quaternion.Inverse(
                Quaternion.Euler(0f, turret.rotation.eulerAngles.y, 0f)
            ) * worldRot;

            float desiredPitch = localDesired.eulerAngles.x;

            if (desiredPitch > 180f)
            { 
                desiredPitch -= 360f; 
            }

            currentBarrelPitch = Mathf.Lerp(currentBarrelPitch, desiredPitch, Time.deltaTime * rotSpeedBarrel);
            currentBarrelPitch = Mathf.Clamp(currentBarrelPitch, minBarrelPitch, maxBarrelPitch);

            barrel.localRotation = Quaternion.Euler(currentBarrelPitch, 0f, 0f);
        }

        if (barrel != null)
        {
            if (Physics.Raycast(barrel.position, barrel.forward, out hit, 200f))
            {
                if (hit.transform == playerT && canShoot)
                {
                    StartCoroutine(ShootRoutine());
                }
            }
        }
    }

    private IEnumerator ShootRoutine()
    {
        canShoot = false;

        if (projectilePrefab != null && barrel != null)
        {
            if (shootSource != null && shootSource.clip != null)
            {
                shootSource.PlayOneShot(shootSource.clip);
            }
            else
            {
                Debug.LogWarning("Не задан источник или звук выстрела.");
            }

            Vector3 spawnPos = barrel.position + barrel.forward * barrelLength;
            Quaternion spawnRot = barrel.rotation;

            Instantiate(projectilePrefab, spawnPos, spawnRot);
        }

        yield return new WaitForSeconds(shootCooldown);

        canShoot = true;
    }

    private void OnCollisionEnter(Collision col)
    {
        if (col.gameObject.CompareTag("core"))
        {
            life--;

            if (life <= 0)
            { 
                Destroy(gameObject); 
            }
        }
    }
}
