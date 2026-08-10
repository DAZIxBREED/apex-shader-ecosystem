# Apex Tools

Editor authoring and validation utilities.

Author: **DAZIxBREED**
Version: **0.3.3**
Compatibility: **Unity Editor only**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented

- Full-project and selected-material validation, including instancing, texture size/type/color-space checks, alpha-clip/transparency warnings, and mobile-avatar compatibility warnings.
- Pass-aware synchronous shader compiler audit across every required Apex shader, including Standard, Mobile, High, detail, alpha-cutout, and combined detail+alpha stress profiles where applicable.
- Machine-readable compiler report with Unity version, build target, graphics API, compiler platform, source file/line, severity, shader/profile context, active pass names, and requested pass-compile counts.
- Stress-profile validation-scene generation with Standard/Mobile/High fixtures, generated checker-alpha texture, generated vertex-gradient blend mesh, and machine-readable fixture manifest.
- VRChat mobile avatar fallback material generation with compatible texture/color/property transfer and pairing JSON.
- Packed R/G/B/A mask texture builder that reads non-readable source textures through a temporary render target and imports the result as linear data.
- Quality profiles and Avatar material presets.
- Shader variant stripping/reporting and global bridge diagnostics.
- Shared AssetDatabase-safe generated-folder handling for Apex editor output.

## Dependencies

- `com.dazi.apex.core`

## Compiler audit

Use **Apex > Validation > Run Shader Compiler Audit** for the compiler-only path, or **Apex > Validation > Run Full Project Validation** to combine compiler results with project/material validation. Batch validation includes the same compiler audit and fails on compiler errors.

The compiler report is written to:

```text
Assets/ApexValidation/Generated/ApexShaderCompilerReport.json
```

Use **Apex > Validation > Create Or Rebuild Validation Scene** to generate the visual stress matrix and:

```text
Assets/ApexValidation/Generated/ApexValidationSceneManifest.json
```

## Validation boundary

The compiler audit and stress scene require the Unity editor and validate the active editor build target/graphics API. Repository CI still performs static source/package validation separately. Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK, stereo, and device validation must be executed in their respective environments before a production release.
