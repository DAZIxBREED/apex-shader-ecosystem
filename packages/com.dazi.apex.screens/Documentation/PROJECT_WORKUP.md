# Apex Screens — Project Workup

## Purpose

Apex Screens supplies low-cost emissive display materials for video players, LED walls, signage, CRT-style panels, and stage surfaces.

## 0.2.0 implementation

- `Apex/Screens/VideoPanelLite` uses `_MainTex` for common Unity/VRChat video-player assignment.
- UV rectangle/crop, horizontal and vertical flip.
- Brightness, contrast, saturation, gamma, scanlines, and vignette.
- Vertex tint, emission output, fog, and SpectraOverdrive response.
- One unlit opaque pass and one sampler.

## Next work

- Transparent/additive signage variants.
- LED pixel-grid and CRT mask variants behind explicit keywords.
- Color-space and limited/full-range presets validated against supported video players.
