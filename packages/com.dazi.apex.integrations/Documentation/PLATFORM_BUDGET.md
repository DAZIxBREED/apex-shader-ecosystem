# Apex Integrations — Platform Budget

## Minimum targets

- iOS
- Quest
- Android
- PCVR

## Mobile-safe defaults

- Prefer `#pragma target 2.0` or `3.0` unless a feature truly requires more.
- Avoid compute, geometry, tessellation, and required GrabPass.
- Prefer `half`/`fixed` where reasonable.
- Prefer 1–4 textures for mobile starter shaders.
- Use packed maps before adding more samplers.
- Add PC-only expansion only behind clear keywords or separate shaders.

## SpectraOverdrive

SpectraOverdrive support should consume existing material properties and the Apex integration bridge without forcing package dependencies outside Apex unless explicitly documented.
