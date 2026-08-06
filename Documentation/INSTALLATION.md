# Installing Apex from Git

Apex is a monorepo of separate Unity packages. Pin every package to the same tag or commit.

## Package Manager UI

Use **Window > Package Manager > + > Add package from git URL**. Install Core and SpectraOverdrive first, then the visual or tooling packages you need.

Example pinned Core URL:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#v0.3.0
```

Replace the final package folder for other packages.

## Project manifest example

Add the desired direct Git dependencies to the `dependencies` object in your Unity project's `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.dazi.apex.core": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#v0.3.0",
    "com.dazi.apex.spectraoverdrive": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.spectraoverdrive#v0.3.0",
    "com.dazi.apex.integrations": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.integrations#v0.3.0",
    "com.dazi.apex.avatar": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.avatar#v0.3.0",
    "com.dazi.apex.world": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.world#v0.3.0",
    "com.dazi.apex.water": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.water#v0.3.0",
    "com.dazi.apex.fog": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.fog#v0.3.0",
    "com.dazi.apex.fx": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.fx#v0.3.0",
    "com.dazi.apex.screens": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.screens#v0.3.0",
    "com.dazi.apex.toon": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.toon#v0.3.0",
    "com.dazi.apex.tools": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.tools#v0.3.0",
    "com.dazi.apex.examples": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.examples#v0.3.0"
  }
}
```

Keep existing Unity and VRChat package entries in the same object; the snippet only shows Apex entries.

## Validation project

Open `ValidationProject/` in Unity 2022.3.22f1 to import every package through local `file:` dependencies. Use **Apex Validation > Build Scene And Validate** or the documented batch entry point.

## Local development

For a cloned repository, add packages from disk using each package's `package.json`, or use `file:` entries in the project manifest. Local packages are useful while editing HLSL because changes appear without publishing a new tag.

## Samples

After installing `com.dazi.apex.examples`, open the package in Package Manager and import **Quick Start Materials** from its Samples tab.
