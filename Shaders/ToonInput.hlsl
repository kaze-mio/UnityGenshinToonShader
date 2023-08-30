#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

CBUFFER_START(UnityPerMaterial)
    float4  _BaseMap_ST;
    half4   _BaseColor;
    half    _IsDay;
    half    _Cull;
    half    _SrcBlend;
    half    _DstBlend;

    half    _ShadowOffset;
    half    _ShadowSmoothness;
    half4   _ShadowColor;
    half    _UseCustomMaterialType;
    half    _CustomMaterialType;

    half    _EmissionIntensity;

    half4   _FaceDirection;
    half    _FaceShadowOffset;
    half4   _FaceBlushColor;
    half    _FaceBlushStrength;

    half    _SpecularSmoothness;
    half    _NonmetallicIntensity;
    half    _MetallicIntensity;

    half    _RimOffset;
    half    _RimThreshold;
    half    _RimIntensity;

    half    _OutlineWidth;
    half4   _OutlineColor;
CBUFFER_END

TEXTURE2D(_BaseMap);            SAMPLER(sampler_BaseMap);
TEXTURE2D(_LightMap);           SAMPLER(sampler_LightMap);
TEXTURE2D(_ShadowRamp);         SAMPLER(sampler_ShadowRamp);
TEXTURE2D(_NormalMap);          SAMPLER(sampler_NormalMap);
TEXTURE2D(_FaceLightMap);       SAMPLER(sampler_FaceLightMap);
TEXTURE2D(_FaceShadow);         SAMPLER(sampler_FaceShadow);
TEXTURE2D(_MetalMap);           SAMPLER(sampler_MetalMap);
