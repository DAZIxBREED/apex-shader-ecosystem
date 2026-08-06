# Apex Avatar — Project Workup

## Purpose

Provide a handwritten Apex PC avatar shader and a repeatable path to legal VRChat mobile avatar materials.

## 0.2.0 implementation

- Packed PBR surface with normal map, metallic, AO, effect mask, smoothness, and emission.
- Soft wrapped direct lighting, rim, alpha clip, additional lights, shadows, fog, and debug views.
- SpectraOverdrive group and four-band weighting.
- Editor fallback generator targeting SDK-provided `VRChat/Mobile/Toon Standard`, `Standard Lite`, or `Toon Lit`.

## Ownership boundaries

- Shared lighting/math/shadows remain in Apex Core.
- Mobile material generation remains in Apex Tools.
- Apex does not bypass VRChat mobile shader restrictions.

## Next work

- Unity compile matrix.
- PC avatar upload test.
- Android/Quest and iOS fallback upload tests.
- Preset profiles for skin, cloth, hair, and hard-surface avatar materials.
