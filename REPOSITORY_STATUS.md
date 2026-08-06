
# Repository Status

**Version:** 0.1.0  
**Maturity:** Pre-alpha clean-room foundation  
**Primary pipeline:** Unity 2022.3 Built-in Render Pipeline  
**Minimum design targets:** iOS, Android, Quest standalone, PCVR

## What is real now

- Twelve separate Unity Package Manager packages.
- Shared handwritten HLSL/CG structs, packing, lighting, platform gates, and debug helpers.
- One baseline shader in each visual package.
- A dedicated SpectraOverdrive uniform bridge with safe defaults.
- Static dependency/include validation, deterministic Unity metadata, and release packaging.
- Importable sample materials.

## What is not yet proven

- The shaders have not been batch-compiled on every target platform in this repository environment.
- VRChat SDK validation and platform upload tests are still required.
- Advanced features named in package roadmaps are not implied to exist merely because a package has been created.
- Performance budgets require measurements on representative iOS, Android, Quest, and PCVR hardware.

This repository should be treated as the starting implementation, not a production-complete shader suite.
