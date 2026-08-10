# Apex Tools

Editor authoring and validation utilities.

Author: **DAZIxBREED**
Version: **0.3.4**
Compatibility: **Unity Editor only**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented

- Full-project and selected-material validation, including instancing, texture size/type/color-space checks, alpha-clip/transparency warnings, and mobile-avatar compatibility warnings.
- Exact ordered ShaderLab pass-contract validation through `ApexShaderCatalog`; Package Doctor compares Unity's actual pass names/order with the locked contract.
- Pass-aware synchronous shader compiler audit across every required Apex shader and supported quality/stress profile.
- Machine-readable compiler report with Unity version, build target, graphics API, compiler platform, source file/line, severity, shader/profile context, active pass names, and requested pass-compile counts.
- Stress-profile validation-scene generation with Standard/Mobile/High fixtures, generated checker-alpha texture, generated vertex-gradient blend mesh, and machine-readable fixture manifest.
- VRChat mobile avatar fallback material generation with compatible property transfer and pairing JSON.
- Packed R/G/B/A mask texture builder, quality profiles, Avatar material presets, shader variant stripping/reporting, and global bridge diagnostics.

## 0.3.4 parity validation

The repository validator and Package Doctor agree on the intentional pass set for every current Apex shader. Static CI also protects the concrete parity fixes for vertex-alpha shadows, World Meta parity, masked VertexBlend Meta emission, Dissolve shared clip/edge math, and Toon additional-light/Meta coverage.

## Dependencies

- `com.dazi.apex.core`

## Compiler audit

Use **Apex > Validation > Run Shader Compiler Audit** for compiler-only validation or **Apex > Validation > Run Full Project Validation** for pass contracts + materials + compiler diagnostics.

Generated reports live under:

```text
Assets/ApexValidation/Generated/
```

## Validation boundary

Unity compiler/stress validation still requires the Unity editor. Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK, stereo, and physical-device validation remain target-runtime gates.
