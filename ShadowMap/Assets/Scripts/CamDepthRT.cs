using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CamDepthRT : MonoBehaviour
{
    public RenderTexture mRT;
    private Camera depthCam;

    // Use this for initialization
    void Start()
    {
        depthCam = gameObject.GetComponent<Camera>();
        if (depthCam != null)
        {
            depthCam.clearFlags = CameraClearFlags.Color;
            depthCam.backgroundColor = Color.black;
            depthCam.targetTexture = mRT;

            depthCam.enabled = false;


        }

    }

    // Update is called once per frame
    void Update()
    {
        if (depthCam != null)
        {
            Shader mShader = Shader.Find("ShadowMap/DepthTextureShader");
            depthCam.RenderWithShader(mShader, "RenderType");
            Shader.SetGlobalFloat("_TexturePixelWidth", mRT.width);
            Shader.SetGlobalFloat("_TexturePixelHeight", mRT.height);
            Shader.SetGlobalTexture("_DepthTexture", mRT);
            Shader.SetGlobalMatrix("_LightSpaceMatrix", GetCameraMatrix());
        }
    }

    Matrix4x4 GetCameraMatrix()
    {
        Matrix4x4 uv = new Matrix4x4();
        uv.SetRow(0, new Vector4(0.5f, 0, 0, 0.5f));
        uv.SetRow(1, new Vector4(0, 0.5f, 0, 0.5f));
        uv.SetRow(2, new Vector4(0, 0, 1, 0));
        uv.SetRow(3, new Vector4(0, 0, 0, 1));

        Matrix4x4 worldToView = depthCam.worldToCameraMatrix;
        Matrix4x4 projection = GL.GetGPUProjectionMatrix(depthCam.projectionMatrix, false);
        return uv * projection * worldToView;
    }
}
