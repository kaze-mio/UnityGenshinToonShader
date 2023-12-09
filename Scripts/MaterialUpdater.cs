using System.Collections.Generic;
using UnityEngine;

public class MaterialUpdater : MonoBehaviour
{
    [SerializeField]
    private GameObject m_HeadBone;

    [SerializeField]
    private Vector3 m_HeadDirection = Vector3.up;

    [SerializeField]
    private List<SkinnedMeshRenderer> m_FaceRenderers;

    private void Update()
    {
        if (m_FaceRenderers == null || m_HeadBone == null)
        {
            return;
        }
        Vector3 direction = m_HeadBone.transform.rotation * m_HeadDirection;
        foreach (var renderer in m_FaceRenderers)
        {
            foreach (var material in renderer.materials)
            {
                material.SetVector("_FaceDirection", direction);
            }
        }
    }
}
