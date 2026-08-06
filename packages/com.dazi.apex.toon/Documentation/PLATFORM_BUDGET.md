# Apex Toon — Platform Budget

`Apex/Toon/CharacterLite` uses three samplers (`_BaseMap`, `_NormalMap`, `_MaskMap`).

- Shader model 3.0.
- ForwardBase and ShadowCaster passes; no additive-light pass in 0.3.0.
- Banded ramp, hard specular, rim, and SpectraOverdrive response are arithmetic-only.
- Alpha clipping increases variant and overdraw considerations; use opaque materials when possible.
