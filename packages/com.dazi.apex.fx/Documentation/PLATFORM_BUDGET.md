# Apex FX — Platform Budget

`Apex/FX/HologramLite` uses one additive pass and two samplers (`_BaseMap`, `_MaskMap`).

- Shader model 3.0.
- Vertex glitch is arithmetic-only and does not add a texture lookup.
- Scanlines, flicker, and Fresnel are arithmetic-only.
- Additive overdraw can become expensive; avoid large stacked transparent meshes on mobile.
