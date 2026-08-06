# Apex Toon — Project Workup

## Purpose

Apex Toon provides a dedicated stylized lighting family for world objects and PC materials without mixing toon-specific controls into the general Avatar or World shaders.

## 0.2.0 implementation

- `Apex/Toon/CharacterLite` with base, normal, and packed mask textures.
- Configurable band count, shadow threshold/softness, shadow color, hard specular, rim light, AO, emission, alpha clip, and SpectraOverdrive response.
- ForwardBase and ShadowCaster passes with fog, instancing, and stereo setup.

## Platform contract

The custom toon shader is valid for world content on supported platforms and PC avatar materials. VRChat mobile avatar uploads must use SDK-provided mobile shaders instead.

## Next work

- Outline variants with platform-specific budgets.
- Matcap and face-shadow-map options.
- PC-only advanced hair/skin tiers separated from mobile world tiers.
