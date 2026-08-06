# Apex Fog — Platform Budget

`Apex/Fog/CardLite` uses one transparent pass and two samplers (`_NoiseMap`, `_MaskMap`).

- Shader model 2.0.
- Main cost is transparent overdraw, not sampler count.
- Keep cards spatially bounded and minimize overlapping full-screen layers.
- Prefer 256–1024 grayscale noise/mask textures.
- No GrabPass, depth texture requirement, geometry stage, or compute.
