# Apex Examples — Project Workup

## Purpose

Apex Examples provides optional importable assets that demonstrate valid material setup without becoming a runtime dependency of any visual package.

## 0.2.0 implementation

- Quick-start materials for the current baseline shaders.
- Material defaults that match the packed-mask and SpectraOverdrive contracts.
- Setup notes for PC avatar materials and SDK mobile avatar fallbacks.

## Ownership boundaries

- Examples may depend on visual packages; visual packages never depend on Examples.
- No production shader implementation belongs here.
- Large textures, licensed media, and scene-specific SDK dependencies are excluded from the base sample set.

## Next work

- Add a compact validation scene with one object per shader family.
- Add Android/Quest, iOS, and PC comparison captures after device testing.
- Add sample SpectraOverdrive property drivers without taking ownership of the show scheduler.
