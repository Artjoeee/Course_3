using UnityEngine;
using UnityEngine.EventSystems;

public class ClickHandler : MonoBehaviour, IPointerClickHandler
{
    public int force = 200;

    public void OnPointerClick(PointerEventData eventData)
    {
        float r = Random.Range(0f, 1f);
        float g = Random.Range(0f, 1f);
        float b = Random.Range(0f, 1f);
        GetComponent<Renderer>().material.color = new Color(r, g, b);

        Vector3 target = eventData.pointerPressRaycast.worldPosition;
        Vector3 collid = Camera.main.transform.position;

        Vector3 distance = (target - collid).normalized;
        collid = distance * force;

        GetComponent<Rigidbody>().AddForceAtPosition(collid, target);
    }
}
