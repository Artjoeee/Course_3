using UnityEngine;

public class PlaneController : MonoBehaviour
{
    public GameObject cubePrefab;
    public GameObject prefab1;
    public float spawnHeight = 5f;

    private float planeSize = 10f;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.Q))
        {
            SpawnCube();
        }

        if (Input.GetKeyDown(KeyCode.Space))
        {
            SpawnSphere();
        }

        if (Input.GetKey(KeyCode.W))
        {
            transform.Rotate(Vector3.forward * Time.deltaTime * 30f);
        }
    }

    void SpawnCube()
    {
        float x = Random.Range(-planeSize / 2, planeSize / 2);
        float z = Random.Range(-planeSize / 2, planeSize / 2);
        Vector3 pos = new Vector3(x, spawnHeight, z);

        if (cubePrefab == null)
        {
            GameObject cube = GameObject.CreatePrimitive(PrimitiveType.Cube);
            cube.transform.position = pos;
            cube.AddComponent<Rigidbody>();
        }
        else
        {
            Instantiate(cubePrefab, pos, Quaternion.identity);
        }
    }

    void SpawnSphere()
    {
        if (prefab1 == null)
        {
            Debug.LogWarning("Не указан prefab1");
            return;
        }

        float x = Random.Range(-planeSize / 2, planeSize / 2);
        float z = Random.Range(-planeSize / 2, planeSize / 2);
        Vector3 pos = new Vector3(x, spawnHeight, z);

        Instantiate(prefab1, pos, Quaternion.identity);
    }
}
