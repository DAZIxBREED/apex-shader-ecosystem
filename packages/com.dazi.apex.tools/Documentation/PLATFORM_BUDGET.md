# Apex Tools — Platform Budget

Apex Tools is editor-only and must not be included in player builds.

- All source files live under `Editor/` and are wrapped in `#if UNITY_EDITOR`.
- Packed-mask generation uses temporary editor memory proportional to output resolution.
- A 4096 output may allocate substantial temporary CPU/GPU memory; 1024 is the default.
- Validation scans project materials and should be run before platform builds, not every frame.
