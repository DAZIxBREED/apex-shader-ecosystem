# Apex World — Platform Budget

`Apex/World/Standard` uses three samplers by default and four when `_APEX_DETAIL` is enabled.

- Shader model 3.0.
- ForwardBase, ForwardAdd, ShadowCaster, and Meta passes.
- Supports lightmaps/SH, fog, stereo, and instancing.
- Prefer baked lighting; limit real-time pixel lights and disable detail where it does not survive mobile viewing distance.
- No GrabPass, tessellation, geometry stage, or compute.
