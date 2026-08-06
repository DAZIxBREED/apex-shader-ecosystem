# Apex Core

Shared handwritten HLSL foundation.

Author: **DAZIxBREED**
Version: **0.2.0**
Compatibility: **Windows PCVR/Desktop and mobile world shader support through dependent packages**
Pipeline: **Unity 2022.3.22f1 Built-in Render Pipeline, handwritten vertex/fragment HLSL/CG**

## Implemented in 0.2.0

- Stereo/instancing-aware lit and unlit vertex paths
- Correct tangent basis and normal scaling
- Packed R metallic / G AO / B effect / A smoothness surfaces
- Baked lightmap or SH ambient GI
- Forward direct, ambient, additional-light, toon, wrap, and rim functions
- Shadow caster helpers, platform gates, fog, color/math helpers, and debug views

## Dependencies

- none

## Validation boundary

Static repository validation is included. Unity shader compilation and representative device/client tests remain required before a production release.
