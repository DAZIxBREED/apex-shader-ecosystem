# Apex SpectraOverdrive Bridge

Apex-native show-control uniform contract.

Author: **DAZIxBREED**
Version: **0.2.0**
Compatibility: **All Apex visual targets**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented in 0.2.0

- Intensity, color, beat, blackout, and strobe values
- Four weighted frequency/control bands
- Broadcast or exact group routing
- Neutral behavior when no driver is present
- `_ApexSpectra...` globals for ordinary Unity `Shader.SetGlobal*` drivers
- `_UdonApexSpectra...` globals plus `_UdonApexSpectraActive` for VRChat `VRCShader.SetGlobal` adapters
- Compatibility overloads for 0.1 materials

## Dependencies

- `com.dazi.apex.core`

## Validation boundary

Static repository validation is included. Unity shader compilation and representative device/client tests remain required before a production release.
