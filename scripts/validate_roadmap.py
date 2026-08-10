#!/usr/bin/env python3
"""Validate the locked Apex roadmap-to-1.0 contract."""
from __future__ import annotations

import json
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ROADMAP_JSON = ROOT / "roadmap.json"
ROADMAP_MD = ROOT / "ROADMAP.md"
RELEASE_GATES = ROOT / "Documentation" / "RELEASE_GATES.md"
README = ROOT / "README.md"

EXPECTED_SEQUENCE = [
    "0.3.4",
    "0.3.5",
    "0.3.6",
    "0.4.0",
    "0.4.1",
    "0.4.2",
    "0.5.0",
    "0.5.1",
    "0.5.2",
    "0.6.0",
    "0.6.1",
    "0.7.0",
    "0.7.1",
    "0.8.0",
    "0.8.1",
    "0.9.0",
    "0.9.1",
    "0.9.2",
    "1.0.0",
]

errors: list[str] = []


def fail(message: str) -> None:
    errors.append(message)


for required in (ROADMAP_JSON, ROADMAP_MD, RELEASE_GATES, README):
    if not required.exists():
        fail(f"missing roadmap contract file: {required.relative_to(ROOT)}")

try:
    contract = json.loads(ROADMAP_JSON.read_text(encoding="utf-8"))
except Exception as exc:
    fail(f"invalid roadmap.json: {exc}")
    contract = {}

if contract.get("schemaVersion") != 1:
    fail("roadmap.json schemaVersion must be 1")
if contract.get("status") != "locked":
    fail("roadmap.json status must remain 'locked' through the 1.0 runway")
if contract.get("baseline") != "0.3.3":
    fail("roadmap.json baseline must remain 0.3.3")
if contract.get("target") != "1.0.0":
    fail("roadmap.json target must remain 1.0.0")

rules = contract.get("rules", {})
if rules.get("packageCount") != 12:
    fail("roadmap packageCount must remain 12 before 1.0")
if rules.get("skipRequiredGates") is not False:
    fail("roadmap must forbid skipping required gates")
if rules.get("allowBreakingSpectraBefore1") is not False:
    fail("roadmap must forbid breaking Spectra ABI changes before 1.0")
if rules.get("allowNewTopLevelPackagesBefore1") is not False:
    fail("roadmap must keep the top-level package architecture frozen before 1.0")
if rules.get("allowUrpHdrpBefore1") is not False:
    fail("roadmap must keep URP/HDRP outside the pre-1.0 runway")

sequence = contract.get("sequence", [])
versions = [entry.get("version") for entry in sequence if isinstance(entry, dict)]
if versions != EXPECTED_SEQUENCE:
    fail(
        "roadmap release sequence changed; expected: "
        + ", ".join(EXPECTED_SEQUENCE)
        + " | found: "
        + ", ".join(str(version) for version in versions)
    )
if len(set(versions)) != len(versions):
    fail("roadmap release sequence contains duplicate versions")

if ROADMAP_MD.exists():
    roadmap_text = ROADMAP_MD.read_text(encoding="utf-8")
    for version in ["0.3.4", "0.4.0", "0.5.0", "0.6.0", "0.7.0", "0.8.0", "0.9.0", "1.0.0"]:
        if version not in roadmap_text:
            fail(f"ROADMAP.md does not describe required milestone {version}")
    if "Documentation/RELEASE_GATES.md" not in roadmap_text:
        fail("ROADMAP.md must link the release-gate contract")

if RELEASE_GATES.exists():
    gate_text = RELEASE_GATES.read_text(encoding="utf-8")
    for gate in (
        "Gate A",
        "Gate B",
        "Gate C",
        "Gate D",
        "Gate E",
        "Gate F",
        "Gate G",
        "Gate H",
        "Gate I",
        "Gate J",
    ):
        if gate not in gate_text:
            fail(f"release-gate contract missing {gate}")

if README.exists():
    readme_text = README.read_text(encoding="utf-8")
    if "ROADMAP.md" not in readme_text:
        fail("README must link ROADMAP.md")
    if "Documentation/RELEASE_GATES.md" not in readme_text:
        fail("README must link Documentation/RELEASE_GATES.md")

if errors:
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    print(f"Roadmap validation failed with {len(errors)} error(s).", file=sys.stderr)
    raise SystemExit(1)

print(f"Locked Apex roadmap validated: {len(EXPECTED_SEQUENCE)} planned releases through 1.0.0.")
