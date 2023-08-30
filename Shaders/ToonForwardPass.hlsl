#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/DeclareDepthTexture.hlsl"

struct Attributes
{
    float4 positionOS   : POSITION;
    float3 normalOS     : NORMAL;
    float4 tangentOS    : TANGENT;
    float2 uv           : TEXCOORD0;
    float2 backUV       : TEXCOORD1;
};

struct Varyings
{
    float2 uv           : TEXCOORD0;
    float2 backUV       : TEXCOORD1;
    float3 positionWS   : TEXCOORD2;
    half3 tangentWS     : TEXCOORD3;
    half3 bitangentWS   : TEXCOORD4;
    half3 normalWS      : TEXCOORD5;
    half3 viewDirWS     : TEXCOORD6;
    float4 positionNDC  : TEXCOORD7;
    float4 positionCS   : SV_POSITION;
};

half GetShadow(Varyings input, half3 lightDirection, half ao)
{
    half NDotL = dot(input.normalWS, lightDirection);
    half halfLambert = 0.5 * NDotL + 0.5;
    half shadow = saturate(2.0 * halfLambert * ao);
    return lerp(shadow, 1.0, step(0.9, ao));
}

half GetFaceShadow(Varyings input, half3 lightDirection)
{
    half3 F = SafeNormalize(half3(_FaceDirection.x, 0.0, _FaceDirection.z));
    half3 L = SafeNormalize(half3(lightDirection.x, 0.0, lightDirection.z));
    half FDotL = dot(F, L);
    half FCrossL = cross(F, L).y;
    
    half2 shadowUV = input.uv;
    shadowUV.x = lerp(shadowUV.x, 1.0 - shadowUV.x, step(0.0, FCrossL));
    half faceShadowMap = SAMPLE_TEXTURE2D(_FaceLightMap, sampler_FaceLightMap, shadowUV).r;
    half faceShadow = step(-0.5 * FDotL + 0.5 + _FaceShadowOffset, faceShadowMap);

    half faceMask = SAMPLE_TEXTURE2D(_FaceShadow, sampler_FaceShadow, input.uv).a;
    half maskedFaceShadow = lerp(faceShadow, 1.0, faceMask);

    return maskedFaceShadow;
}

half3 GetShadowColor(half shadow, half material, half day)
{
    int index = 4;
    index = lerp(index, 1, step(0.2, material));
    index = lerp(index, 2, step(0.4, material));
    index = lerp(index, 0, step(0.6, material));
    index = lerp(index, 3, step(0.8, material));

    half rangeMin = 0.5 + _ShadowOffset - _ShadowSmoothness;
    half rangeMax = 0.5 + _ShadowOffset;
    half2 rampUV = half2(smoothstep(rangeMin, rangeMax, shadow), index / 10.0 + 0.5 * day + 0.05);
    half3 shadowRamp = SAMPLE_TEXTURE2D(_ShadowRamp, sampler_ShadowRamp, rampUV);

    half3 shadowColor = shadowRamp * lerp(_ShadowColor.rgb, 1.0, rampUV.x);
    shadowColor = lerp(shadowColor, 1.0, step(rangeMax, shadow));

    return shadowColor;
}

half3 GetSpecular(Varyings input, half3 lightDirection, half3 baseMap, half3 lightMap)
{
    half3 H = SafeNormalize(lightDirection + input.viewDirWS);
    half NDotL = dot(input.normalWS, lightDirection);
    half NDotH = dot(input.normalWS, H);
    half blinnPhong = pow(saturate(NDotH), _SpecularSmoothness);

    half3 normalVS = TransformWorldToViewNormal(input.normalWS, true);
    half2 matcapUV = 0.5 * normalVS.xy + 0.5;
    half3 metalMap = SAMPLE_TEXTURE2D(_MetalMap, sampler_MetalMap, matcapUV);

    half3 nonMetallic = step(1.1 - blinnPhong, lightMap.b) * lightMap.r * _NonmetallicIntensity;
    half3 metallic = blinnPhong * lightMap.b * baseMap * metalMap * _MetallicIntensity;
    half3 specular = lerp(nonMetallic, metallic, step(0.9, lightMap.r));

    return specular;
}

half GetRim(Varyings input)
{
    half3 normalVS = TransformWorldToViewNormal(input.normalWS, true);
    float2 uv = input.positionNDC.xy / input.positionNDC.w;
    float2 offset = float2(normalVS.x * _RimOffset / _ScreenParams.x, 0.0);
    float depth = LinearEyeDepth(SampleSceneDepth(uv), _ZBufferParams);
    float offsetDepth = LinearEyeDepth(SampleSceneDepth(uv + offset), _ZBufferParams);
    half rim = smoothstep(0.0, _RimThreshold, offsetDepth - depth) * _RimIntensity;

    half NDotV = dot(input.normalWS, input.viewDirWS);
    half fresnel = pow(saturate(1.0 - NDotV), 5.0);

    return rim * fresnel;
}

Varyings ForwardPassVertex(Attributes input)
{
    VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
    VertexNormalInputs normalInput = GetVertexNormalInputs(input.normalOS, input.tangentOS);

    Varyings output = (Varyings)0;
    output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
    output.backUV = TRANSFORM_TEX(input.backUV, _BaseMap);
    output.positionWS = vertexInput.positionWS;
    output.tangentWS = normalInput.tangentWS;
    output.bitangentWS = normalInput.bitangentWS;
    output.normalWS = normalInput.normalWS;
    output.viewDirWS = GetWorldSpaceNormalizeViewDir(vertexInput.positionWS);
    output.positionNDC = vertexInput.positionNDC;
    output.positionCS = vertexInput.positionCS;

    return output;
}

half4 ForwardPassFragment(Varyings input, FRONT_FACE_TYPE facing : FRONT_FACE_SEMANTIC) : SV_TARGET
{
#if _DOUBLE_SIDED
    input.uv = lerp(input.uv, input.backUV, IS_FRONT_VFACE(facing, 0.0, 1.0));
#endif

    half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
    half3 albedo = baseMap.rgb * _BaseColor.rgb;
    half alpha = baseMap.a * _BaseColor.a;

#if _IS_FACE
    albedo = lerp(albedo, _FaceBlushColor.rgb, _FaceBlushStrength * alpha);
#endif

#if _NORMAL_MAP
    half3x3 tangentToWorld = half3x3(input.tangentWS, input.bitangentWS, input.normalWS);
    half4 normalMap = SAMPLE_TEXTURE2D(_NormalMap, sampler_NormalMap, input.uv);
    half3 normalTS = UnpackNormal(normalMap);
    half3 normalWS = TransformTangentToWorld(normalTS, tangentToWorld, true);
    input.normalWS = normalWS;
#endif

    Light mainLight = GetMainLight();
    half4 lightMap = SAMPLE_TEXTURE2D(_LightMap, sampler_LightMap, input.uv);
    half3 lightDirection = SafeNormalize(mainLight.direction);
    half material = lerp(lightMap.a, _CustomMaterialType, _UseCustomMaterialType);
#if _IS_FACE
        half shadow = GetFaceShadow(input, lightDirection);
#else
        half shadow = GetShadow(input, lightDirection, lightMap.g);
#endif
    half3 shadowColor = GetShadowColor(shadow, material, _IsDay);

    half3 specular = 0.0;
#if _SPECULAR
    specular = GetSpecular(input, lightDirection, albedo, lightMap.rgb);
#endif

    half3 emission = 0.0;
#if _EMISSION
    emission = albedo * _EmissionIntensity * step(0.5, alpha);
#endif

    half rim = 0.0;
#if _RIM
    rim = GetRim(input);
#endif

    half3 finalColor = albedo * (shadowColor + rim) + specular + emission;

    return half4(finalColor, alpha);
} 
