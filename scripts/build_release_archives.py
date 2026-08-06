#!/usr/bin/env python3
"""Build one reproducible tar.gz archive per Apex UPM package."""
from __future__ import annotations
import gzip
import shutil
import tarfile
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ROOT / "packages"
VERSION = (ROOT / "VERSION").read_text(encoding="utf-8").strip()
OUTPUT = ROOT / "artifacts"


def reset_metadata(info: tarfile.TarInfo) -> tarfile.TarInfo:
    info.uid = info.gid = 0
    info.uname = info.gname = ""
    info.mtime = 0
    return info


def main() -> int:
    if OUTPUT.exists():
        shutil.rmtree(OUTPUT)
    OUTPUT.mkdir(parents=True)
    for package in sorted(p for p in PACKAGES.iterdir() if p.is_dir()):
        archive = OUTPUT / f"{package.name}-{VERSION}.tar.gz"
        with archive.open("wb") as raw:
            with gzip.GzipFile(filename="", mode="wb", fileobj=raw, mtime=0) as gz:
                with tarfile.open(fileobj=gz, mode="w") as tar:
                    tar.add(package, arcname="package", recursive=True, filter=reset_metadata)
        print(archive.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
