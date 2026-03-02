using UnityEngine;

public class TankController : MonoBehaviour
{
    public Transform turretTransform;
    public Transform barrelTransform;

    public float moveSpeed = 10f;
    public float turnSpeed = 60f;

    public float turretTurnSpeed = 80f;

    public float barrelPitchSpeed = 45f;
    public float minBarrelPitch = -10f;
    public float maxBarrelPitch = 5f;

    private Rigidbody rb;
    private float barrelPitch = 0f;

    void Start()
    {
        //Cursor.lockState = CursorLockMode.Locked;

        rb = GetComponent<Rigidbody>();

        if (turretTransform == null)
        { 
            Debug.LogWarning("Turret не установлен"); 
        }

        if (barrelTransform == null)
        { 
            Debug.LogWarning("Barrel не установлен"); 
        }

        barrelPitch = barrelTransform.localEulerAngles.x;

        if (barrelPitch > 180f)
        { 
            barrelPitch -= 360f; 
        }
    }

    void FixedUpdate()
    {
        float forward = Input.GetAxis("Vertical");
        float turn = Input.GetAxis("Horizontal");

        Vector3 forwardVel = transform.forward * forward * moveSpeed;
        Vector3 newPos = rb.position + forwardVel * Time.deltaTime;
        rb.MovePosition(newPos);

        Quaternion deltaRot = Quaternion.Euler(0f, turn * turnSpeed * Time.fixedDeltaTime, 0f);
        rb.MoveRotation(rb.rotation * deltaRot);

        float turretInput = Input.GetAxis("Mouse X");

        if (turretTransform)
        {
            turretTransform.Rotate(0f, turretInput * turretTurnSpeed * Time.fixedDeltaTime, 0f, Space.Self);
        }

        float barrelInput = -Input.GetAxis("Mouse Y");

        if (barrelTransform && Mathf.Abs(barrelInput) > 0f)
        {
            barrelPitch += barrelInput * barrelPitchSpeed * Time.fixedDeltaTime;
            barrelPitch = Mathf.Clamp(barrelPitch, minBarrelPitch, maxBarrelPitch);

            Vector3 currentEuler = barrelTransform.localEulerAngles;
            barrelTransform.localRotation = Quaternion.Euler(barrelPitch, currentEuler.y, currentEuler.z);
        }
    }
}
