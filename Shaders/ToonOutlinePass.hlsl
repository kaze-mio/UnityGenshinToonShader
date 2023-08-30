#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 uv           : TEXCOORD0;
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float4 positionCS   : SV_POSITION;
};

float3 GetOutlinePosition(VertexPositionInputs vertexInput, VertexNormalInputs normalInput)
{
    float z = abs(vertexInput.positionVS.z);
    float width = _OutlineWidth * saturate(z) * 0.001;
    return vertexInput.positionWS + normalInput.normalWS * width;
}

Varyings OutlinePassVertex(Attributes input)
{
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    float3 positionWS = GetOutlinePosition(vertexInput, normalInput);

    Varyings output = (Varyings)0;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.positionCS = TransformWorldToHClip(positionWS);

    return output;
}

half4 OutlinePassFragment(Varyings input) : SV_TARGET
{
    return _OutlineColor;
}
