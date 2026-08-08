#!/usr/bin/env python3
"""Static validation for the Apex Unity package monorepo."""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ROOT / "packages"
VERSION = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
REQUIRED = (
    "package.json",
    "README.md",
    "LICENSE.txt",
    "Documentation/PROJECT_WORKUP.md",
    "Documentation/PLATFORM_BUDGET.md",
)
MOBILE_WORLD = {
    "com.dazi.apex.world", "com.dazi.apex.water", "com.dazi.apex.fog",
    "com.dazi.apex.fx", "com.dazi.apex.screens", "com.dazi.apex.toon",
}
EXPECTED_SHADERS = {
    "Apex/Core/Debug", "Apex/Avatar/Standard", "Apex/World/Standard",
    "Apex/World/VertexBlendLite", "Apex/Water/PoolLite",
    "Apex/Water/OpaqueMobile", "Apex/Fog/CardLite",
    "Apex/FX/HologramLite", "Apex/FX/DissolveCutout",
    "Apex/Screens/VideoPanelLite", "Apex/Screens/LEDPanelLite",
    "Apex/Toon/CharacterLite",
}
QUALITY_SHADERS = (
    "com.dazi.apex.avatar/Runtime/Shaders/Standard.shader",
    "com.dazi.apex.world/Runtime/Shaders/Standard.shader",
    "com.dazi.apex.world/Runtime/Shaders/VertexBlendLite.shader",
    "com.dazi.apex.fx/Runtime/Shaders/DissolveCutout.shader",
    "com.dazi.apex.toon/Runtime/Shaders/CharacterLite.shader",
)
INCLUDE_RE = re.compile(r'#include\s+"Packages/([^/"]+)/(.*?)"')
SHADER_RE = re.compile(r'\bShader\s+"([^"]+)"')
PROPERTY_RE = re.compile(r'^\s*(?:\[[^\]]+\]\s*)*(_\w+)\s*\(', re.MULTILINE)
TARGET_RE = re.compile(r'#pragma\s+target\s+([0-9.]+)')
BLOCK_COMMENTS = re.compile(r'/\*.*?\*/', re.DOTALL)
LINE_COMMENTS = re.compile(r'//.*')

errors: list[str] = []
warnings: list[str] = []
manifests: dict[str, tuple[Path, dict]] = {}
shader_names: dict[str, Path] = {}


def fail(message: str) -> None:
    errors.append(message)


def clean(text: str) -> str:
    return LINE_COMMENTS.sub("", BLOCK_COMMENTS.sub("", text))


def balanced(text: str, opening: str = "{", closing: str = "}") -> bool:
    depth = 0
    for character in text:
        if character == opening:
            depth += 1
        elif character == closing:
            depth -= 1
            if depth < 0:
                return False
    return depth == 0


def require_text(path: Path, needles: tuple[str, ...]) -> None:
    if not path.exists():
        fail(f"missing required file: {path.relative_to(ROOT)}")
        return
    text = path.read_text(encoding="utf-8")
    for needle in needles:
        if needle not in text:
            fail(f"{path.relative_to(ROOT)} missing required contract: {needle}")


try:
    repository = json.loads((ROOT / "repository.json").read_text(encoding="utf-8"))
except Exception as exc:
    fail(f"invalid repository.json: {exc}")
    repository = {}
if repository.get("version") != VERSION:
    fail("repository.json version does not match VERSION")
if repository.get("unity") != "2022.3.22f1":
    fail("repository.json Unity baseline must be 2022.3.22f1")

for package_dir in sorted(path for path in PACKAGES.iterdir() if path.is_dir()):
    for relative in REQUIRED:
        if not (package_dir / relative).exists():
            fail(f"{package_dir.name}: missing {relative}")
    try:
        manifest = json.loads((package_dir / "package.json").read_text(encoding="utf-8"))
    except Exception as exc:
        fail(f"{package_dir.name}: invalid package.json: {exc}")
        continue
    name = manifest.get("name")
    if name != package_dir.name:
        fail(f"{package_dir.name}: manifest name is {name!r}")
    if manifest.get("version") != VERSION:
        fail(f"{package_dir.name}: version must be {VERSION}")
    if manifest.get("unity") != "2022.3":
        fail(f"{package_dir.name}: Unity baseline must be 2022.3")
    for sample in manifest.get("samples", []):
        if not sample.get("displayName") or not sample.get("path"):
            fail(f"{package_dir.name}: sample entries require displayName and path")
        elif not (package_dir / sample["path"]).exists():
            fail(f"{package_dir.name}: missing sample path {sample['path']}")
    manifests[name] = (package_dir, manifest)

for name, (_, manifest) in manifests.items():
    for dependency, dependency_version in manifest.get("dependencies", {}).items():
        if not dependency.startswith("com.dazi.apex."):
            continue
        if dependency not in manifests:
            fail(f"{name}: missing local dependency {dependency}")
        elif dependency_version != VERSION:
            fail(f"{name}: dependency {dependency} must use {VERSION}")

for package_name, (package_dir, manifest) in manifests.items():
    dependencies = set(manifest.get("dependencies", {}))
    for asset in sorted(package_dir.rglob("*")):
        if asset.name.endswith(".meta"):
            continue
        meta = asset.with_name(asset.name + ".meta")
        if not meta.exists():
            fail(f"missing Unity metadata: {meta.relative_to(ROOT)}")
        if not asset.is_file() or asset.suffix not in {".shader", ".cginc", ".hlsl"}:
            continue
        text = asset.read_text(encoding="utf-8")
        stripped = clean(text)
        if not balanced(stripped):
            fail(f"{asset.relative_to(ROOT)} has unbalanced braces")
        if stripped.count("CGPROGRAM") != stripped.count("ENDCG"):
            fail(f"{asset.relative_to(ROOT)} has mismatched CGPROGRAM/ENDCG")
        if re.search(r'TRANSFORM_TEX\s*\([^,]+,\s*[a-z]\w*\s*\)', stripped):
            fail(f"{asset.relative_to(ROOT)} passes a function parameter to TRANSFORM_TEX")
        for included_package, relative in INCLUDE_RE.findall(text):
            target = PACKAGES / included_package / relative
            if not target.exists():
                fail(f"{asset.relative_to(ROOT)} includes missing {target.relative_to(ROOT)}")
            if included_package != package_name and included_package not in dependencies:
                fail(f"{package_name}: include of {included_package} lacks package dependency")
        if asset.suffix == ".shader":
            names = SHADER_RE.findall(stripped)
            if len(names) != 1:
                fail(f"{asset.relative_to(ROOT)} must declare exactly one Shader name")
            else:
                shader_name = names[0]
                if shader_name in shader_names:
                    fail(f"duplicate Shader name: {shader_name}")
                shader_names[shader_name] = asset
            properties = PROPERTY_RE.findall(stripped)
            if len(properties) != len(set(properties)):
                fail(f"{asset.relative_to(ROOT)} has duplicate ShaderLab properties")
            if "#pragma multi_compile_instancing" not in stripped:
                fail(f"{asset.relative_to(ROOT)} lacks instancing variants")
            if "UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX" not in stripped:
                fail(f"{asset.relative_to(ROOT)} lacks fragment stereo setup")
        if package_name in MOBILE_WORLD:
            for forbidden in (r'\bGrabPass\b', r'#pragma\s+(?:geometry|hull|domain)\b', r'\.compute\b'):
                if re.search(forbidden, stripped):
                    fail(f"{asset.relative_to(ROOT)} uses a forbidden mobile-world construct")
            for target in TARGET_RE.findall(stripped):
                if float(target) > 3.0:
                    fail(f"{asset.relative_to(ROOT)} exceeds shader model 3.0")

missing_shaders = sorted(EXPECTED_SHADERS - set(shader_names))
if missing_shaders:
    fail("missing expected shaders: " + ", ".join(missing_shaders))

require_text(
    PACKAGES / "com.dazi.apex.spectraoverdrive/Runtime/HLSL/ApexSpectraOverdrive_Bridge.cginc",
    (
        "#define APEX_SPECTRA_ABI_MAJOR 1", "#define APEX_SPECTRA_ABI_MINOR 0",
        "_UdonApexSpectraActive", "_UdonApexSpectraSafetyActive",
        "_UdonApexSpectraSafety",
    ),
)
require_text(
    PACKAGES / "com.dazi.apex.core/Runtime/HLSL/ApexCore_Common.cginc",
    ("#define APEX_VERSION_MAJOR 0", "#define APEX_VERSION_MINOR 3", "#define APEX_VERSION_PATCH 0"),
)
for filename, direct_includes in {
    "ApexCore_Surface.cginc": ("ApexCore_Common.cginc", "ApexCore_Packing.cginc"),
    "ApexCore_Lighting.cginc": ("ApexCore_Surface.cginc",),
    "ApexCore_Debug.cginc": ("ApexCore_Lighting.cginc",),
    "ApexCore_Environment.cginc": ("ApexCore_Quality.cginc", "ApexCore_Lighting.cginc"),
}.items():
    require_text(PACKAGES / "com.dazi.apex.core/Runtime/HLSL" / filename, direct_includes)

quality_contract = "#pragma shader_feature_local _ _APEX_QUALITY_STANDARD _APEX_QUALITY_MOBILE _APEX_QUALITY_HIGH"
for relative in QUALITY_SHADERS:
    path = PACKAGES / relative
    require_text(path, (quality_contract, "[KeywordEnum(Standard,Mobile,High)] _APEX_QUALITY", "_EnvironmentStrength"))

for relative in (
    "com.dazi.apex.avatar/Runtime/Shaders/Standard.shader",
    "com.dazi.apex.toon/Runtime/Shaders/CharacterLite.shader",
):
    path = PACKAGES / relative
    require_text(path, ('"VRCFallback"="toonstandard"', "_MainTex", "_Color", "_BumpMap", "_BumpScale"))

if sorted(manifests) != sorted(repository.get("packages", [])):
    fail("repository.json package list does not match package directories")

validation = ROOT / "ValidationProject"
try:
    validation_dependencies = json.loads((validation / "Packages/manifest.json").read_text(encoding="utf-8"))["dependencies"]
except Exception as exc:
    fail(f"invalid ValidationProject manifest: {exc}")
    validation_dependencies = {}
for package_name in manifests:
    expected = f"file:../../packages/{package_name}"
    if validation_dependencies.get(package_name) != expected:
        fail(f"ValidationProject must reference {package_name} as {expected}")
require_text(validation / "ProjectSettings/ProjectVersion.txt", ("2022.3.22f1",))
require_text(validation / "Assets/Editor/ApexValidationProjectEntry.cs", ("ApexValidationProjectEntry", "RunBatch"))
for asset in (validation / "Assets").rglob("*"):
    if not asset.name.endswith(".meta") and not asset.with_name(asset.name + ".meta").exists():
        fail(f"missing Unity metadata: {asset.with_name(asset.name + '.meta').relative_to(ROOT)}")

for source in (PACKAGES / "com.dazi.apex.tools").rglob("*.cs"):
    text = source.read_text(encoding="utf-8")
    if "Editor" not in source.parts:
        fail(f"Apex Tools runtime leak: {source.relative_to(ROOT)}")
    if "#if UNITY_EDITOR" not in text or "#endif" not in text:
        fail(f"{source.relative_to(ROOT)} lacks UNITY_EDITOR guard")
    if not balanced(clean(text)):
        fail(f"{source.relative_to(ROOT)} has unbalanced C# braces")

samples = sorted((PACKAGES / "com.dazi.apex.examples/Samples~").rglob("*.mat"))
if len(samples) != len(EXPECTED_SHADERS):
    fail(f"expected {len(EXPECTED_SHADERS)} sample materials, found {len(samples)}")
for sample in samples:
    if "m_EnableInstancingVariants: 1" not in sample.read_text(encoding="utf-8"):
        warnings.append(f"sample material has instancing disabled: {sample.relative_to(ROOT)}")

print(f"Validated {len(manifests)} Apex packages at version {VERSION}.")
print(f"Discovered {len(shader_names)} unique ShaderLab shaders.")
for warning in warnings:
    print(f"WARNING: {warning}")
if errors:
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    print(f"Validation failed with {len(errors)} error(s).", file=sys.stderr)
    raise SystemExit(1)
print("Validation passed.")
