# Apex Water — Platform Budget

`Apex/Water/PoolLite` uses one transparent forward-base pass and three samplers (`_BaseMap`, `_NormalMap`, `_MaskMap`).

- Shader model 3.0.
- Two normal layers reuse the same normal texture at different UVs.
- No GrabPass, refraction buffer, depth texture, tessellation, geometry stage, or compute.
- Screen coverage and overlapping transparency are the dominant mobile risks.
