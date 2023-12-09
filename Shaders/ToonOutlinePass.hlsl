#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float4 color        : COLOR;
    float2 uv           : TEXCOORD0;
    float3 smoothNormal : TEXCOORD7;
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
};

float GetOutlineWidth(float positionVS_Z)
{
    float fovFactor = 2.414 / UNITY_MATRIX_P[1].y;
    float z = abs(positionVS_Z * fovFactor);

    float4 params = _OutlineWidthParams;
    float k = saturate((z - params.x) / (params.y - params.x));
    float width = lerp(params.z, params.w, k);

    return 0.01 * _OutlineWidth * width;
}

float4 GetOutlinePosition(VertexPositionInputs vertexInput, VertexNormalInputs normalInput, half4 vertexColor)
{
    float z = vertexInput.positionVS.z;
    float width = GetOutlineWidth(z) * vertexColor.a;

    half3 normalVS = TransformWorldToViewNormal(normalInput.normalWS);
    normalVS = SafeNormalize(half3(normalVS.xy, 0.0));

    float3 positionVS = vertexInput.positionVS;
    positionVS += 0.01 * _OutlineZOffset * SafeNormalize(positionVS);
    positionVS += width * normalVS;

    float4 positionCS = TransformWViewToHClip(positionVS);
    positionCS.xy += _ScreenOffset.zw * positionCS.w;

    return positionCS;
}

Varyings OutlinePassVertex(Attributes input)
{
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    half3x3 tangentToWorld = half3x3(normalInput.tangentWS, normalInput.bitangentWS, normalInput.normalWS);
    half3 normalTS = 2.0 * (input.smoothNormal - 0.5);
    half3 normalWS = TransformTangentToWorld(normalTS, tangentToWorld, true);
    normalInput.normalWS = lerp(normalInput.normalWS, normalWS, _UseSmoothNormal);

    float4 positionCS = GetOutlinePosition(vertexInput, normalInput, input.color);

    Varyings output = (Varyings)0;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.positionCS = positionCS;

    return output;
}

half4 OutlinePassFragment(Varyings input) : SV_TARGET
{
    half4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv);
    half material = lightMap.a;

    half4 color = _OutlineColor5;
    color = lerp(color, _OutlineColor4, step(0.2, material));
    color = lerp(color, _OutlineColor3, step(0.4, material));
    color = lerp(color, _OutlineColor2, step(0.6, material));
    color = lerp(color, _OutlineColor, step(0.8, material));

    return color;
}
