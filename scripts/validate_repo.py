#!/usr/bin/env python3
"""Static repository validator for the Apex Unity package monorepo."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ROOT / "packages"
EXPECTED_VERSION = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
REQUIRED = [
    "package.json",
    "README.md",
    "LICENSE.txt",
    "Documentation/PROJECT_WORKUP.md",
    "Documentation/PLATFORM_BUDGET.md",
]
LOCAL_INCLUDE = re.compile(r'#include\s+"Packages/([^/"]+)/(.*?)"')
SHADER_NAME = re.compile(r'\bShader\s+"([^"]+)"')
SHADER_PROPERTY = re.compile(r'^\s*(?:\[[^\]]+\]\s*)*(_\w+)\s*\(', re.MULTILINE)
MATERIAL_UNIFORM = re.compile(r'\b(?:sampler(?:1D|2D|3D|CUBE)|(?:half|float|fixed)(?:[234](?:x[234])?)?)\s+(_\w+)\s*;')
TARGET = re.compile(r'#pragma\s+target\s+([0-9.]+)')
PARAMETER_TRANSFORM_TEX = re.compile(r'TRANSFORM_TEX\s*\([^,]+,\s*([a-z]\w*)\s*\)')
COMMENT_BLOCK = re.compile(r'/\*.*?\*/', re.DOTALL)
COMMENT_LINE = re.compile(r'//.*')
MOBILE_WORLD_PACKAGES = {
    "com.dazi.apex.world",
    "com.dazi.apex.water",
    "com.dazi.apex.fog",
    "com.dazi.apex.fx",
    "com.dazi.apex.screens",
    "com.dazi.apex.toon",
}
FORBIDDEN_MOBILE_PATTERNS = {
    "GrabPass": re.compile(r'\bGrabPass\b'),
    "geometry stage": re.compile(r'#pragma\s+geometry\b'),
    "hull stage": re.compile(r'#pragma\s+hull\b'),
    "domain stage": re.compile(r'#pragma\s+domain\b'),
    "compute include": re.compile(r'\.compute\b'),
}

errors: list[str] = []
warnings: list[str] = []
manifests: dict[str, tuple[Path, dict]] = {}
shader_names: dict[str, Path] = {}


def without_comments(text: str) -> str:
    return COMMENT_LINE.sub("", COMMENT_BLOCK.sub("", text))


def balanced(text: str, opening: str, closing: str) -> bool:
    depth = 0
    for character in text:
        if character == opening:
            depth += 1
        elif character == closing:
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


if EXPECTED_VERSION != "0.2.0":
    warnings.append(f"development version is {EXPECTED_VERSION}; validator was authored for 0.2.0")

try:
    repository = json.loads((ROOT / "repository.json").read_text(encoding="utf-8"))
    if repository.get("version") != EXPECTED_VERSION:
        errors.append("repository.json version does not match VERSION")
    if repository.get("unity") != "2022.3.22f1":
        errors.append("repository.json Unity baseline must be 2022.3.22f1")
except Exception as exc:
    errors.append(f"invalid repository.json: {exc}")
    repository = {}

for package_dir in sorted(p for p in PACKAGES.iterdir() if p.is_dir()):
    for required in REQUIRED:
        if not (package_dir / required).exists():
            errors.append(f"{package_dir.name}: missing {required}")

    manifest_path = package_dir / "package.json"
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"{package_dir.name}: invalid package.json: {exc}")
        continue

    name = manifest.get("name")
    if name != package_dir.name:
        errors.append(f"{package_dir.name}: manifest name is {name!r}")
    if manifest.get("version") != EXPECTED_VERSION:
        errors.append(f"{package_dir.name}: version is {manifest.get('version')!r}, expected {EXPECTED_VERSION}")
    if manifest.get("unity") != "2022.3":
        errors.append(f"{package_dir.name}: package Unity baseline must be 2022.3")
    for sample in manifest.get("samples", []):
        sample_path = package_dir / str(sample.get("path", ""))
        if not sample.get("displayName") or not sample.get("path"):
            errors.append(f"{package_dir.name}: sample entries require displayName and path")
        elif not sample_path.exists():
            errors.append(f"{package_dir.name}: sample path does not exist: {sample_path.relative_to(ROOT)}")

    if (package_dir / "Samples~").exists() and not manifest.get("samples"):
        warnings.append(f"{package_dir.name}: contains Samples~ but package.json exposes no samples")

    manifests[name] = (package_dir, manifest)

for name, (_package_dir, manifest) in manifests.items():
    for dependency, version in manifest.get("dependencies", {}).items():
        if dependency.startswith("com.dazi.apex."):
            if dependency not in manifests:
                errors.append(f"{name}: missing local dependency package {dependency}")
            elif version != manifests[dependency][1].get("version"):
                errors.append(
                    f"{name}: dependency {dependency} uses {version}, "
                    f"local package is {manifests[dependency][1].get('version')}"
                )

for package_name, (package_dir, manifest) in manifests.items():
    declared_dependencies = set(manifest.get("dependencies", {}))
    for asset in sorted(package_dir.rglob("*")):
        if asset.name.endswith(".meta"):
            continue

        meta = asset.with_name(asset.name + ".meta")
        if not meta.exists():
            errors.append(f"missing Unity metadata: {meta.relative_to(ROOT)}")

        if not asset.is_file() or asset.suffix not in {".shader", ".cginc", ".hlsl"}:
            continue

        text = asset.read_text(encoding="utf-8")
        cleaned = without_comments(text)

        for included_package, relative in LOCAL_INCLUDE.findall(text):
            target = PACKAGES / included_package / relative
            if not target.exists():
                errors.append(f"{asset.relative_to(ROOT)} includes missing {target.relative_to(ROOT)}")
            if included_package != package_name and included_package not in declared_dependencies:
                errors.append(
                    f"{package_name}: {asset.relative_to(package_dir)} includes {included_package} "
                    "without declaring it as a package dependency"
                )

        if not balanced(cleaned, "{", "}"):
            errors.append(f"{asset.relative_to(ROOT)} has unbalanced braces")

        for parameter_name in PARAMETER_TRANSFORM_TEX.findall(cleaned):
            errors.append(
                f"{asset.relative_to(ROOT)} passes function parameter {parameter_name!r} to TRANSFORM_TEX; "
                "use the explicit ST vector because Unity's macro token-pastes <name>_ST"
            )
        if cleaned.count("CGPROGRAM") != cleaned.count("ENDCG"):
            errors.append(f"{asset.relative_to(ROOT)} has mismatched CGPROGRAM/ENDCG blocks")
        if cleaned.count("HLSLPROGRAM") != cleaned.count("ENDHLSL"):
            errors.append(f"{asset.relative_to(ROOT)} has mismatched HLSLPROGRAM/ENDHLSL blocks")

        if asset.suffix == ".shader":
            names = SHADER_NAME.findall(cleaned)
            if len(names) != 1:
                errors.append(f"{asset.relative_to(ROOT)} must declare exactly one Shader name")
            else:
                shader_name = names[0]
                if shader_name in shader_names:
                    errors.append(
                        f"duplicate shader name {shader_name!r}: "
                        f"{shader_names[shader_name].relative_to(ROOT)} and {asset.relative_to(ROOT)}"
                    )
                shader_names[shader_name] = asset

            properties = SHADER_PROPERTY.findall(cleaned)
            if len(properties) != len(set(properties)):
                errors.append(f"{asset.relative_to(ROOT)} declares duplicate ShaderLab properties")
            property_set = set(properties)
            for uniform in MATERIAL_UNIFORM.findall(cleaned):
                if uniform in property_set:
                    continue
                if uniform.endswith("_ST") and uniform[:-3] in property_set:
                    continue
                errors.append(
                    f"{asset.relative_to(ROOT)} declares material uniform {uniform} without a matching ShaderLab property"
                )

            if "#pragma multi_compile_instancing" not in cleaned:
                errors.append(f"{asset.relative_to(ROOT)} must compile an instancing variant")
            if "UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX" not in cleaned:
                errors.append(f"{asset.relative_to(ROOT)} has no fragment-stage stereo eye setup")

        if package_name in MOBILE_WORLD_PACKAGES:
            for label, pattern in FORBIDDEN_MOBILE_PATTERNS.items():
                if pattern.search(cleaned):
                    errors.append(f"{asset.relative_to(ROOT)} uses forbidden mobile-world construct: {label}")
            for target_value in TARGET.findall(cleaned):
                if float(target_value) > 3.0:
                    errors.append(
                        f"{asset.relative_to(ROOT)} targets shader model {target_value}; "
                        "mobile-world packages are capped at 3.0"
                    )

spectra_bridge = PACKAGES / "com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc"
if spectra_bridge.exists():
    spectra_text = spectra_bridge.read_text(encoding="utf-8")
    for required_global in (
        "_UdonApexSpectraActive",
        "_UdonApexSpectraIntensity",
        "_UdonApexSpectraColor",
        "_UdonApexSpectraBands",
        "_UdonApexSpectraBlackout",
    ):
        if required_global not in spectra_text:
            errors.append(f"SpectraOverdrive bridge missing VRChat-safe global {required_global}")

integration_bridge = PACKAGES / "com.dazi.apex.integrations/Runtime/HLSL/ApexIntegration_OptionalFallbacks.cginc"
if integration_bridge.exists():
    integration_text = integration_bridge.read_text(encoding="utf-8")
    if "_UdonApexIntegrationActive" not in integration_text:
        errors.append("Integration bridge missing VRChat-safe _UdonApexIntegrationActive global")

core_common = PACKAGES / "com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc"
if core_common.exists():
    core_text = core_common.read_text(encoding="utf-8")
    version_macros = (
        f"#define APEX_VERSION_MAJOR {EXPECTED_VERSION.split('.')[0]}",
        f"#define APEX_VERSION_MINOR {EXPECTED_VERSION.split('.')[1]}",
        f"#define APEX_VERSION_PATCH {EXPECTED_VERSION.split('.')[2]}",
    )
    for macro in version_macros:
        if macro not in core_text:
            errors.append(f"ApexCore_Common.cginc missing version macro: {macro}")

avatar_readme = PACKAGES / "com.dazi.apex.avatar/README.md"
if avatar_readme.exists():
    avatar_text = avatar_readme.read_text(encoding="utf-8").lower()
    if "pcvr/desktop custom shader" not in avatar_text or "vrchat/mobile" not in avatar_text:
        errors.append("Apex Avatar README must state the PC custom shader and SDK mobile fallback contract")

# VRChat fallback property transfer depends on exact tag/property names. Keep both
# custom PC character shaders aligned with the supported toon-standard fallback.
for relative_shader in (
    "com.dazi.apex.avatar/Runtime/Shaders/Standard.shader",
    "com.dazi.apex.toon/Runtime/Shaders/CharacterLite.shader",
):
    shader_path = PACKAGES / relative_shader
    if not shader_path.exists():
        errors.append(f"missing character fallback shader: {relative_shader}")
        continue
    shader_text = without_comments(shader_path.read_text(encoding="utf-8"))
    if '"VRCFallback"="toonstandard"' not in shader_text:
        errors.append(f"{relative_shader} must declare exact VRCFallback=toonstandard metadata")
    fallback_properties = {"_MainTex", "_Color", "_BumpMap", "_BumpScale"}
    declared_properties = set(SHADER_PROPERTY.findall(shader_text))
    missing_fallback_properties = sorted(fallback_properties - declared_properties)
    if missing_fallback_properties:
        errors.append(
            f"{relative_shader} is missing Standard-compatible fallback properties: "
            + ", ".join(missing_fallback_properties)
        )

expected_packages = sorted(manifests)
listed_packages = sorted(repository.get("packages", []))
if expected_packages != listed_packages:
    errors.append("repository.json package list does not match package directories")

tools_dir = PACKAGES / "com.dazi.apex.tools"
if tools_dir.exists():
    for source in tools_dir.rglob("*.cs"):
        if "Editor" not in source.parts:
            errors.append(f"Apex Tools runtime leak: {source.relative_to(ROOT)} is not under Editor/")
        source_text = source.read_text(encoding="utf-8")
        if "#if UNITY_EDITOR" not in source_text or "#endif" not in source_text:
            errors.append(f"{source.relative_to(ROOT)} must be guarded by UNITY_EDITOR")
        if not balanced(without_comments(source_text), "{", "}"):
            errors.append(f"{source.relative_to(ROOT)} has unbalanced C# braces")

for sample_material in (PACKAGES / "com.dazi.apex.examples/Samples~").rglob("*.mat"):
    material_text = sample_material.read_text(encoding="utf-8")
    if "m_EnableInstancingVariants: 1" not in material_text:
        warnings.append(f"sample material has instancing disabled: {sample_material.relative_to(ROOT)}")

for package_dir, manifest in manifests.values():
    description = str(manifest.get("description", "")).lower()
    if "placeholder" in description or "stub" in description:
        warnings.append(f"{package_dir.name}: description still contains placeholder/stub wording")

print(f"Validated {len(manifests)} Apex packages at version {EXPECTED_VERSION}.")
print(f"Discovered {len(shader_names)} unique ShaderLab shaders.")
for warning in warnings:
    print(f"WARNING: {warning}")
if errors:
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    print(f"Validation failed with {len(errors)} error(s).", file=sys.stderr)
    raise SystemExit(1)
print("Validation passed.")
