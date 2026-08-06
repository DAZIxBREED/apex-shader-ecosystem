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
REQUIRED = ["package.json", "README.md", "LICENSE.txt", "Documentation/PROJECT_WORKUP.md", "Documentation/PLATFORM_BUDGET.md"]
LOCAL_INCLUDE = re.compile(r'#include\s+"Packages/([^/"]+)/(.*?)"')

errors: list[str] = []
warnings: list[str] = []
manifests: dict[str, tuple[Path, dict]] = {}

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
        errors.append(f"{package_dir.name}: unity baseline must be 2022.3")
    manifests[name] = (package_dir, manifest)

for name, (package_dir, manifest) in manifests.items():
    for dependency, version in manifest.get("dependencies", {}).items():
        if dependency.startswith("com.dazi.apex."):
            if dependency not in manifests:
                errors.append(f"{name}: missing local dependency package {dependency}")
            elif version != manifests[dependency][1].get("version"):
                errors.append(f"{name}: dependency {dependency} uses {version}, local package is {manifests[dependency][1].get('version')}")

for package_dir, _manifest in manifests.values():
    for asset in sorted(package_dir.rglob("*")):
        if asset.name.endswith(".meta"):
            continue
        meta = asset.with_name(asset.name + ".meta")
        if not meta.exists():
            errors.append(f"missing Unity metadata: {meta.relative_to(ROOT)}")
        if asset.is_file() and asset.suffix in {".shader", ".cginc", ".hlsl"}:
            text = asset.read_text(encoding="utf-8")
            for package_name, relative in LOCAL_INCLUDE.findall(text):
                target = PACKAGES / package_name / relative
                if not target.exists():
                    errors.append(f"{asset.relative_to(ROOT)} includes missing {target.relative_to(ROOT)}")

for package_dir, manifest in manifests.values():
    description = str(manifest.get("description", "")).lower()
    if "placeholder" in description or "stub" in description:
        warnings.append(f"{package_dir.name}: description still contains placeholder/stub wording")

print(f"Validated {len(manifests)} Apex packages at version {EXPECTED_VERSION}.")
for warning in warnings:
    print(f"WARNING: {warning}")
if errors:
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    print(f"Validation failed with {len(errors)} error(s).", file=sys.stderr)
    raise SystemExit(1)
print("Validation passed.")
