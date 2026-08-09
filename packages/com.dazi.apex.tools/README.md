# Apex Tools

Editor authoring and validation utilities.

Author: **DAZIxBREED**
Version: **0.3.2**
Compatibility: **Unity Editor only**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented

- Full-project and selected-material validation, including instancing, texture size/type/color-space checks, alpha-clip/transparency warnings, and mobile-avatar compatibility warnings.
- Synchronous shader compiler audit across every required Apex shader pass, including Standard, Mobile, High, and detail-enabled profiles where applicable.
- Machine-readable compiler report with Unity version, build target, graphics API, compiler platform, source file/line, severity, shader/profile context, and pass counts.
- VRChat mobile avatar fallback material generation with compatible texture/color/property transfer and pairing JSON.
- Packed R/G/B/A mask texture builder that reads non-readable source textures through a temporary render target and imports the result as linear data.
- Quality profiles and Avatar material presets.
- Shader variant stripping/reporting, global bridge diagnostics, and validation scene generation.
- Shared AssetDatabase-safe generated-folder handling for Apex editor output.

## Dependencies

- `com.dazi.apex.core`

## Compiler audit

Use **Apex > Validation > Run Shader Compiler Audit** for the compiler-only path, or **Apex > Validation > Run Full Project Validation** to combine compiler results with project/material validation. Batch validation includes the same compiler audit and fails on compiler errors.

The generated report is written to:

```text
Assets/ApexValidation/Generated/ApexShaderCompilerReport.json
```

## Validation boundary

The compiler audit requires the Unity editor and validates the active editor build target/graphics API. Repository CI still performs static source/package validation separately. Direct3D 11, Vulkan/GLES3, Metal, VRChat SDK, stereo, and device validation must be executed in their respective environments before a production release.
