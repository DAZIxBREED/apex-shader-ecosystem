# Apex Fog — Project Workup

## Purpose

Apex Fog supplies inexpensive transparent atmosphere cards for haze, smoke, localized fog, and stage-volume accents in VRChat worlds.

## 0.3.0 implementation

- `Apex/Fog/CardLite` with two animated noise layers.
- Authored mask, vertex color, distance fade, height fade, and view-angle edge fade.
- Fog color/intensity and SpectraOverdrive tint/emission response.
- One transparent unlit pass with no GrabPass, geometry stage, or compute dependency.

## Performance contract

Fog is fill-rate sensitive. Use bounded cards, avoid excessive overlap, keep textures compact, and profile on standalone mobile hardware.

## Next work

- Soft intersection/depth-fade variant where the target pipeline exposes a safe depth texture.
- Cylindrical and box volume mapping variants.
- Mobile overdraw diagnostics in Apex Tools.
