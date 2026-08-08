# Apex Core — Project Workup

## Purpose

Apex Core is the dependency floor for every handwritten Apex shader.

## 0.3.0 implementation

- Shared BIRP vertex/varying contracts, stereo, instancing, tangent-space conversion, packed surfaces, lightmaps/SH, forward lights, attenuation/shadows, fog, and debug views.
- Mobile/Standard/High local quality contract.
- Reflection-probe environment sampling with roughness mip selection, box-projection support, Fresnel, occlusion, and high-tier energy compensation.
- Reusable shadow and surface helpers plus version macros.

## Next work

- Compile the full pass/keyword matrix in Unity on Direct3D 11, Vulkan/GLES3, and Metal.
- Add captured compiler regression tests and formal include API compatibility policy.
