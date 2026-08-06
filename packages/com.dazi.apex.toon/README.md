# Apex Toon

Banded toon material shader.

Author: **DAZIxBREED**
Version: **0.3.0**
Compatibility: **World objects across targets; custom avatar use is PC-only in VRChat**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented in 0.3.0

- Banded direct lighting and colored shadow
- Hard specular control
- Normal map and AO/effect mask
- Rim and emission
- Alpha clip and shadow caster
- SpectraOverdrive group/band routing
- Standard-compatible property names and exact `VRCFallback="toonstandard"` metadata

## Dependencies

- `com.dazi.apex.core`
- `com.dazi.apex.spectraoverdrive`

## Avatar note

This custom toon shader can be used for PC avatars, but mobile avatar uploads must use an SDK-provided `VRChat/Mobile` shader. World objects may use custom shaders on mobile builds subject to performance testing.

## Validation boundary

Static repository validation is included. Unity shader compilation and representative device/client tests remain required before a production release.
