# Apex Shader Ecosystem — Master Workup

## Mission

Build a clean-room, modular, handwritten HLSL/CG shader ecosystem for Unity 2022.3.22f1 Built-in Render Pipeline and VRChat-oriented content.

Apex targets Windows PCVR/Desktop plus Android/Quest and iOS **worlds**. For avatars, Apex owns the PC custom shader and tooling that generates SDK-approved mobile fallback materials.

## 0.3.0 completion standard

- Three-state local quality contract: Mobile, Standard, and High.
- Reflection-probe environment specular for supported quality tiers.
- At least two focused families in World, Water, FX, and Screens without creating a hidden mega-shader.
- Frozen SpectraOverdrive ABI 1.0 with bounded intensity/strobe safety controls.
- Batch mobile fallback generation and pairing metadata.
- Project-shared authoring profiles, variant stripping/reporting, and bridge diagnostics.
- Dedicated Unity validation project with reproducible scene generation and batch entry point.
- Static checks for all new contracts and deterministic package output.

## Mandatory platform design

Mobile-world shader paths must avoid compute, geometry, tessellation, and GrabPass; stay at Shader Model 3.0 or lower; prefer packed maps and bounded transparency; and support stereo/instancing where applicable.

Mobile avatar paths must use SDK-provided `VRChat/Mobile` shaders and remain separate from PC custom materials.

## Next implementation sequence

1. Run `ValidationProject` through Unity 2022.3.22f1 on Direct3D 11, Vulkan/GLES3, and Metal.
2. Fix actual compiler/API differences and capture the validation logs in CI artifacts.
3. Add VRChat SDK Worlds/Avatars validation overlays without making the base repository depend on the SDK.
4. Add device captures and measured sampler/pass/overdraw budgets.
5. Expand Fog, Toon, Avatar, and Integrations with focused optional families/adapters.
