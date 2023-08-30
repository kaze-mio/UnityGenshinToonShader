using System.Collections.Generic;
using UnityEngine;

public class MaterialUpdater : MonoBehaviour
{
    [SerializeField]
    private GameObject m_headBone;

    [SerializeField]
    private Vector3 m_headDirection = Vector3.up;

    [SerializeField]
    private List<SkinnedMeshRenderer> m_faceRenderers;

    private void Update()
    {
        if (m_faceRenderers == null || m_headBone == null)
        {
            return;
        }
        Vector3 direction = m_headBone.transform.rotation * m_headDirection;
        foreach (var renderer in m_faceRenderers)
        {
            foreach (var material in renderer.materials)
            {
                material.SetVector("_FaceDirection", direction);
            }
        }
    }
}
