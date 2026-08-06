# Apex Shader Ecosystem — Master Workup

## Mission

Build a clean-room, modular, handwritten HLSL/CG shader ecosystem for Unity Built-in Render Pipeline and VRChat-style content. Apex must target iOS, Quest, Android, and PCVR as the minimum platform floor, not as afterthought ports.

## Architecture

Apex is separated into one shared Core package and several independent feature packages. Each project owns its own shaders, HLSL modules, documentation, and editor tooling. No package should become a hidden mega-shader.

## Mandatory platform design

All packages must provide a mobile-safe path:

- no compute shader requirement
- no geometry/tessellation requirement
- avoid screen grabs as a required feature
- prefer half precision where safe
- packed maps over many textures
- branch/gate expensive features
- keep Quest/iOS/Android variants minimal
- prefer one-pass fallback modes

## SpectraOverdrive compatibility standard

Every visual project must be able to react to SpectraOverdrive-style show data through a common bridge:

- `ApexSpectraData.intensity`
- `ApexSpectraData.color`
- `ApexSpectraData.beat`
- `ApexSpectraData.blackout`
- `ApexSpectraData.strobe`
- `ApexSpectraData.groupId`

If SpectraOverdrive is not installed or not driving these uniforms, Apex must still compile and behave normally.

## Completion standard for each package

Each package is done for 0.1.0 when it has:

- package manifest
- README
- PROJECT_WORKUP.md
- at least one compiling shader
- at least one shared include
- mobile-safe default behavior
- SpectraOverdrive compatibility note
- clear list of owned features and refused features
