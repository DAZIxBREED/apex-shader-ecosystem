# Apex Avatar

PCVR/Desktop custom avatar material shader.

Author: **DAZIxBREED**
Version: **0.2.0**
Compatibility: **PCVR/Desktop custom shader; Android/Quest/iOS use generated SDK mobile fallback**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented in 0.2.0

- Packed PBR inputs
- Soft wrap lighting and rim light
- Alpha clip
- Forward additional lights and shadows
- SpectraOverdrive group/band routing
- Standard-compatible property names and exact `VRCFallback="toonstandard"` metadata
- Apex Tools mobile fallback workflow

## Dependencies

- `com.dazi.apex.core`
- `com.dazi.apex.spectraoverdrive`

## VRChat mobile avatar rule

VRChat does not permit custom shaders on Android/Quest mobile avatars, and iOS follows the mobile rules. Use **Apex > Mobile Avatar Fallback Builder** from `com.dazi.apex.tools` to create a second material using an SDK-provided `VRChat/Mobile` shader.

## Validation boundary

Static repository validation is included. Unity shader compilation and representative device/client tests remain required before a production release.
