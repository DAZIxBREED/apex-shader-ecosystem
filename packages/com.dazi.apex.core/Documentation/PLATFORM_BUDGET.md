# Apex Core — Platform Budget

Apex Core adds no texture samplers by itself. Its cost is determined by the visual package that includes it.

## Baseline rules

- Built-in Render Pipeline, shader model 2.0 or 3.0.
- Single-pass stereo and GPU-instancing macros in shared vertex paths.
- `half` precision for color/material math where practical.
- No compute, geometry, hull, domain, or mandatory GrabPass features.
- Packed maps before adding independent samplers.

## Platform gates

`ApexCore_Platform.cginc` exposes Android, iOS, GLES2, and broad mobile quality scalars. Visual packages must use separate keywords or shaders when a PC feature cannot remain safe on mobile.
