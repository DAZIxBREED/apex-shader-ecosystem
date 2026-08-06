# Apex Screens — Platform Budget

`Apex/Screens/VideoPanelLite` uses one opaque unlit pass and one sampler (`_MainTex`).

- Shader model 2.0.
- UV crop/flip and color grading are arithmetic-only.
- Scanline and vignette controls add arithmetic but no samplers.
- Keep unnecessary grading controls at neutral values and profile very large LED walls on mobile.
