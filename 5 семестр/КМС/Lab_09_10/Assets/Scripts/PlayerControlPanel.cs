using UnityEngine;

public class PlayerControlPanel : MonoBehaviour
{
    public float tankSpeed = 5f;
    public float coreSpeed = 20f;

    private TankController tankController;
    private BarrelShoot barrelShoot;

    private bool showPanel = true;

    void Start()
    {
        tankController = FindObjectOfType<TankController>();
        barrelShoot = FindObjectOfType<BarrelShoot>();

        if (tankController == null)
        { 
            Debug.LogError("TankController не найден в сцене!"); 
        }

        if (barrelShoot == null)
        {
            Debug.LogError("BarrelShoot не найден в сцене!"); 
        }

        Cursor.lockState = CursorLockMode.None;
        Cursor.visible = true;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            ToggleCursor();
        }
    }

    void ToggleCursor()
    {
        bool locked = Cursor.lockState == CursorLockMode.Locked;

        Cursor.lockState = locked ? CursorLockMode.None : CursorLockMode.Locked;
        Cursor.visible = !locked;
    }

    private void OnGUI()
    {
        if (showPanel)
        {
            GUI.Box(new Rect(20, 20, 260, 150), "Панель управления");

            GUI.Label(new Rect(30, 50, 150, 20), "Скорость танка:");
            tankSpeed = GUI.HorizontalSlider(new Rect(150, 55, 120, 20), tankSpeed, 1f, 20f);

            if (tankController)
            { 
                tankController.moveSpeed = tankSpeed; 
            }

            GUI.Label(new Rect(30, 90, 150, 20), "Скорость снаряда:");
            coreSpeed = GUI.HorizontalSlider(new Rect(150, 95, 120, 20), coreSpeed, 5f, 70f);

            if (barrelShoot)
            { 
                barrelShoot.projectilePrefab.GetComponent<Projectile>().speed = coreSpeed; 
            }

            if (GUI.Button(new Rect(30, 125, 100, 30), "Скрыть"))
            { 
                showPanel = false; 
            }
        }
        else
        {
            if (GUI.Button(new Rect(20, 20, 100, 30), "Показать"))
            { 
                showPanel = true; 
            }
        }
    }
}
