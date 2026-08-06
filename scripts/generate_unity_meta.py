#!/usr/bin/env python3
"""Generate stable Unity .meta files for all package assets and directories."""
from __future__ import annotations
import hashlib
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ROOT / "packages"


def guid_for(path: Path) -> str:
    rel = path.relative_to(ROOT).as_posix()
    return hashlib.sha256(("DAZIxBREED/ApexShaderEcosystem/" + rel).encode()).hexdigest()[:32]


def meta_text(path: Path) -> str:
    guid = guid_for(path)
    if path.is_dir():
        return f"fileFormatVersion: 2\nguid: {guid}\nfolderAsset: yes\nDefaultImporter:\n  externalObjects: {{}}\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n"
    if path.suffix == ".cs":
        return f"fileFormatVersion: 2\nguid: {guid}\nMonoImporter:\n  externalObjects: {{}}\n  serializedVersion: 2\n  defaultReferences: []\n  executionOrder: 0\n  icon: {{instanceID: 0}}\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n"
    if path.suffix == ".shader":
        return f"fileFormatVersion: 2\nguid: {guid}\nShaderImporter:\n  externalObjects: {{}}\n  defaultTextures: []\n  nonModifiableTextures: []\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n"
    return f"fileFormatVersion: 2\nguid: {guid}\nDefaultImporter:\n  externalObjects: {{}}\n  userData:\n  assetBundleName:\n  assetBundleVariant:\n"


def main() -> int:
    for package in sorted(p for p in PACKAGES.iterdir() if p.is_dir()):
        assets = sorted(
            (p for p in package.rglob("*") if not p.name.endswith(".meta")),
            key=lambda p: (len(p.parts), p.as_posix()),
        )
        for asset in assets:
            meta = asset.with_name(asset.name + ".meta")
            meta.write_text(meta_text(asset), encoding="utf-8", newline="\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
