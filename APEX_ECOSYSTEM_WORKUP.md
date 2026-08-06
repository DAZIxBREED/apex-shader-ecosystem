# Apex Shader Ecosystem — Master Workup

## Mission

Build a clean-room, modular, handwritten HLSL/CG shader ecosystem for Unity 2022.3.22f1 Built-in Render Pipeline and VRChat-oriented content.

Apex targets Windows PCVR/Desktop plus Android/Quest and iOS **worlds**. For avatars, Apex owns the PC custom shader and the tooling that generates SDK-approved mobile fallback materials; it does not attempt to bypass VRChat's mobile avatar shader restrictions.

## Architecture

Apex remains separated into one shared Core package and independent visual/tooling packages. Each package owns its shaders, focused HLSL modules, documentation, and performance budget. Shared math, surface, lighting, shadow, platform, and debug behavior belongs in Core rather than being copied into every shader.

## Mandatory platform design

Mobile-world shader paths must:

- require no compute, geometry, hull, domain, or tessellation stages
- avoid GrabPass and mandatory screen copies
- remain at Shader Model 3.0 or lower
- prefer `half`/`fixed` where stable
- use packed maps before additional samplers
- keep transparency limited and explicitly budgeted
- support single-pass stereo and instancing where applicable
- use baked lighting for world geometry whenever possible

Mobile avatar paths must use SDK-provided `VRChat/Mobile` shaders and should be generated/tested as separate materials.

## SpectraOverdrive compatibility standard

Visual packages consume a shared bridge containing:

- intensity and RGB color
- beat and strobe pulses
- blackout
- four weighted bands
- broadcast/exact group routing
- neutral defaults when no driver is active

SpectraOverdrive compatibility must not force external packages to be installed merely for Apex shaders to compile. Ordinary Unity drivers use `_Apex...` globals; VRChat Udon adapters use `_UdonApex...` globals because `VRCShader.SetGlobal` requires the `_Udon` prefix for user-defined values.

## 0.2.0 completion standard

- package manifests and deterministic Unity metadata
- one distinct implemented shader per visual package
- shared Core surface, lighting, lightmap, shadow, stereo, instancing, platform, and debug code
- SpectraOverdrive routing and dependency-free optional integration globals
- Standard-compatible avatar/toon fallback metadata and mobile avatar fallback generator
- packed mask authoring tool
- static package/dependency/ShaderLab/fallback validation and deterministic release packaging
- accurate platform documentation

## Next implementation sequence

1. Import and compile the package matrix in Unity 2022.3.22f1.
2. Fix shader compiler differences across Direct3D 11, Vulkan/GLES3 Android, and Metal iOS.
3. Build a dedicated validation Unity project with test scenes and materials.
4. Add preset/material inspectors and platform-quality presets.
5. Expand World, Avatar, Water, Fog, FX, Screens, and Toon into additional focused shaders without creating a hidden mega-shader.
