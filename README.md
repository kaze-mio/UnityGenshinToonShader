# UnityGenshinToonShader

A custom genshin-like toon shader, based on URP

基于 URP 的仿原神风格化渲染着色器

## Overview

Welcome to this custom toon shader for Unity, inspired by the art style of the game Genshin Impact. This shader is based on the Universal Render Pipeline (URP) and supports a wide range of features such as 

- **Light Map** (R / B for specular, G for AO, A for material type)
- **Shadow Ramp**
- **Emission**
- **Normal Map**
- **Face Shadow**, based on SDF Light Map
- **Face Blush**
- **Nonmetallic and Metallic Specular**, based on Blinn-Phong Model
- **Rim Light**, based on Depth Texture and Fresnel
- **Outline**, based on Back Facing
- **Double-Sided Rendering**

## Render Example

without post-processing:
![image_0](image_0.png)

with post-processing:
![image_1](image_1.png)

## Technologies and Frameworks

The project is built using Unity and the Universal Render Pipeline (URP). The shader code is written in High-Level Shading Language (HLSL) and includes several passes for different rendering modes such as forward rendering, shadow casting, depth-only rendering, depth normals, and outline rendering. 

The MaterialUpdater script is written in C# and uses the System.Collections.Generic and UnityEngine namespaces. It updates the materials of a character's face based on the direction of the head bone.

The shader files include:
- URPGenshinToon.shader: The main shader file with various properties for rendering objects.
- ToonOutlinePass.hlsl: Shader code for rendering outlines.
- ToonForwardPass.hlsl: Shader code for Unity's Universal Render Pipeline, including functions for calculating shadows, face shadows, specular highlights, and rim lighting.
- ToonInput.hlsl: A list of variables and buffers used in the shader program, including declarations for various textures and samplers.

# Installation

Follow the steps below to install and start working with the project:

## Step 1: Install Unity Game Engine

First, you need to have the Unity game engine installed on your system. You can download it from the official Unity website.

## Step 2: Install Universal Render Pipeline

Next, you need to install the Universal Render Pipeline (URP) in your Unity project. You can do this by going to the Unity package manager and installing the `com.unity.render-pipelines.universal` package.

## Step 3: Include Required Shader Files

The project requires several shader files to be included. These are:

- `ToonInput.hlsl`
- `ToonForwardPass.hlsl`
- `ShadowCasterPass.hlsl`
- `DepthOnlyPass.hlsl`
- `DepthNormalsPass.hlsl`
- `LitDepthNormalsPass.hlsl`
- `ToonOutlinePass.hlsl`
- `LitInput.hlsl`
- `URPGenshinToon.shader`

Ensure that these files are present in your project.

## Step 4: Include Required Textures and Samplers

The `ToonInput.hlsl` file requires the presence of several textures and samplers. These are:

- `_BaseMap`
- `_LightMap`
- `_ShadowRamp`
- `_NormalMap`
- `_FaceLightMap`
- `_FaceShadow`
- `_MetalMap`

Ensure that these are present in your project.

## Step 5: Include MaterialUpdater.cs

Finally, include the `MaterialUpdater.cs` script in your project. This script passes face direction to the material.

After following these steps, you should be able to start working with the project.

# Usage

This section provides a few basic examples of how to use the project. 

## MaterialUpdater.cs

To use the `MaterialUpdater.cs`, you need to create an instance of the `MaterialUpdater` class and call the `UpdateMaterial` method. Here is an example:

```csharp
MaterialUpdater materialUpdater = new MaterialUpdater();
materialUpdater.UpdateMaterial(myMaterial);
```

In this example, `myMaterial` is the material you want to update.

## URPGenshinToon.shader

To use the `URPGenshinToon.shader`, you need to assign it to a material in your Unity project. Here is an example:

```csharp
Material myMaterial = new Material(Shader.Find("URPGenshinToon"));
```

In this example, `myMaterial` is the material you want to apply the shader to.

## ToonOutlinePass.hlsl, ToonForwardPass.hlsl, ToonInput.hlsl

To use the `ToonOutlinePass.hlsl`, `ToonForwardPass.hlsl`, and `ToonInput.hlsl` files, you need to include them in your shader file. Here is an example:

```hlsl
#include "ToonOutlinePass.hlsl"
#include "ToonForwardPass.hlsl"
#include "ToonInput.hlsl"

void main() {
    // Your shader code here
}
```
