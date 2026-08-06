# Apex Tools

Editor authoring and validation utilities.

Author: **DAZIxBREED**
Version: **0.2.0**
Compatibility: **Unity Editor only**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented in 0.2.0

- Full-project and selected-material validation, including imported shader errors, instancing, texture size/type/color-space checks, alpha-clip/transparency warnings, and mobile-avatar compatibility warnings
- VRChat mobile avatar fallback material generation with compatible texture/color/property transfer
- Packed R/G/B/A mask texture builder that reads non-readable source textures through a temporary render target and imports the result as linear data
- Compatibility contract reporting

## Dependencies

- `com.dazi.apex.core`

## Validation boundary

Static repository validation is included. Unity shader compilation and representative device/client tests remain required before a production release.
