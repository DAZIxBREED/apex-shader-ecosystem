# Installing Apex from Git

Apex is a monorepo of separate Unity packages. Keep every installed Apex package on the same Git ref.

## Package Manager UI

Use **Window > Package Manager > + > Add package from git URL**. Install Core and SpectraOverdrive first, then the visual or tooling packages you need.

Current pre-alpha Core URL:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#main
```

Replace the final package folder for other packages. For reproducible projects, replace `main` with an exact commit SHA after you have chosen a known-good revision.

> Do not pin to a `vX.Y.Z` fragment unless that Git tag actually exists in the repository.

## Project manifest example

Add the desired direct Git dependencies to the `dependencies` object in your Unity project's `Packages/manifest.json`:

```json
{
  "dependencies": {
    "com.dazi.apex.core": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.core#main",
    "com.dazi.apex.spectraoverdrive": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.spectraoverdrive#main",
    "com.dazi.apex.integrations": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.integrations#main",
    "com.dazi.apex.avatar": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.avatar#main",
    "com.dazi.apex.world": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.world#main",
    "com.dazi.apex.water": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.water#main",
    "com.dazi.apex.fog": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.fog#main",
    "com.dazi.apex.fx": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.fx#main",
    "com.dazi.apex.screens": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.screens#main",
    "com.dazi.apex.toon": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.toon#main",
    "com.dazi.apex.tools": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.tools#main",
    "com.dazi.apex.examples": "https://github.com/DAZIxBREED/apex-shader-ecosystem.git?path=/packages/com.dazi.apex.examples#main"
  }
}
```

Keep existing Unity and VRChat package entries in the same object; the snippet only shows Apex entries.

## Validation project

Open `ValidationProject/` in Unity 2022.3.22f1 to import every package through local `file:` dependencies. Use **Apex Validation > Build Scene And Validate** or the documented batch entry point.

## Local development

For a cloned repository, add packages from disk using each package's `package.json`, or use `file:` entries in the project manifest. Local packages are useful while editing HLSL because changes appear without publishing a new Git ref.

## Samples

After installing `com.dazi.apex.examples`, open the package in Package Manager and import **Quick Start Materials** from its Samples tab.
