# Apex SpectraOverdrive Bridge — Project Workup

## Purpose

Provide a clean, shared bridge between Apex shader packages and SpectraOverdrive show-control systems.

## Minimum targets

- iOS
- Quest
- Android
- PCVR

## What this project owns

- SpectraOverdrive material uniform contract
- HLSL data struct for show-control values
- safe fallback behavior when values are not driven
- documentation for Udon/material-property drivers

## What this project refuses to own

- Avatar shading
- World shading
- Water/fog/FX shading
- Full SpectraOverdrive show authoring logic
- Udon show scheduler logic

## Completion bar for 0.1.0

- HLSL bridge include exists
- all visual Apex packages can include it
- default values compile safely
- blackout/tint/emission helpers exist
