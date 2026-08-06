# Apex World

World and environment material shader.

Author: **DAZIxBREED**
Version: **0.3.0**
Compatibility: **Windows PCVR/Desktop, Android/Quest worlds, and iOS worlds**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented in 0.3.0

- Packed PBR inputs
- Lightmaps/SH, realtime attenuation and shadows
- Optional detail keyword
- Alpha clip
- Meta pass for baked albedo and emission
- SpectraOverdrive group/band routing
- `Apex/World/VertexBlendLite` with two independent texture/normal/mask layers blended by vertex red
- Reflection-probe quality tiers

## Dependencies

- `com.dazi.apex.core`
- `com.dazi.apex.spectraoverdrive`

## Validation boundary

Static repository validation is included. Unity shader compilation and representative device/client tests remain required before a production release.
