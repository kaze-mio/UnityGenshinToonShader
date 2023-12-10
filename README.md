# UnityGenshinToonShader

A custom genshin-like toon shader, based on URP

基于 URP 的仿原神风格化渲染着色器

## Supported Features

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

## Scripts

- **MaterialUpdater** : pass face direction to material

## References

- A Unity sample project, for rendering Genshin characters like Nahida.

  [NahidaRenderProject](https://github.com/kaze-mio/NahidaRenderProject)

- A genshin-like post processing render feature, based on URP.

  [UnityGenshinPostProcessing](https://github.com/kaze-mio/UnityGenshinPostProcessing)

## Render Examples

![image_0](Images/image_0.png)
![image_1](Images/image_1.png)

