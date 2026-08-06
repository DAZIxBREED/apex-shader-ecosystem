# Apex Avatar — Project Workup

## Purpose

Avatar material shaders with mobile-safe PBR/toon-lite, emission, rim, and SpectraOverdrive-reactive options.

## Minimum target platforms

- iOS
- Quest standalone
- Android
- PCVR

## Rendering contract

- Unity Built-in Render Pipeline
- handwritten vertex/fragment HLSL/CG
- mobile-safe first pass
- Quest/iOS/Android fallbacks are mandatory
- PCVR expands quality but cannot become the only valid path

## SpectraOverdrive compatibility

This package must remain compatible with SpectraOverdrive show data through the Apex SpectraOverdrive bridge. It should use intensity, color, beat, blackout, and safe strobe-style pulse data where visually useful.

## What this project owns

- Its own shader files
- Its own HLSL includes
- Its own presets/material workflow docs
- Its own performance budget

## What this project refuses to own

- Core math/platform structs belong in Apex Core
- Optional external systems belong in Apex Integrations
- Example/demo content belongs in Apex Examples
- Broad editor workflow belongs in Apex Tools

## 0.1.0 completion bar

- package imports cleanly
- starter shader compiles
- mobile-safe path exists
- docs identify feature and sampler budgets
- SpectraOverdrive behavior documented
