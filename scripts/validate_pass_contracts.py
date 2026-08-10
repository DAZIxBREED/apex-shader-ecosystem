#!/usr/bin/env python3
"""Validate Apex ShaderLab pass contracts and 0.3.4 parity invariants."""
from __future__ import annotations

import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PACKAGES = ROOT / "packages"
CATALOG = PACKAGES / "com.dazi.apex.tools/Editor/ApexShaderCatalog.cs"

EXPECTED_PASS_SETS: dict[str, tuple[str, ...]] = {
    "Apex/Core/Debug": ("FORWARD_BASE",),
    "Apex/Avatar/Standard": ("FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER"),
    "Apex/World/Standard": ("FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER", "META"),
    "Apex/World/VertexBlendLite": ("FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER", "META"),
    "Apex/Water/PoolLite": ("FORWARD_BASE",),
    "Apex/Water/OpaqueMobile": ("FORWARD_BASE", "FORWARD_ADD"),
    "Apex/Fog/CardLite": ("UNLIT_FOG",),
    "Apex/FX/HologramLite": ("HOLOGRAM",),
    "Apex/FX/DissolveCutout": ("FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER", "META"),
    "Apex/Screens/VideoPanelLite": ("VIDEO_PANEL",),
    "Apex/Screens/LEDPanelLite": ("LED_PANEL",),
    "Apex/Toon/CharacterLite": ("FORWARD_BASE", "FORWARD_ADD", "SHADOW_CASTER", "META"),
}

SEMANTIC_CONTRACTS: dict[str, tuple[str, ...]] = {
    "com.dazi.apex.core/Runtime/HLSL/ApexCore_Shadow.cginc": (
        "fixed4 color : COLOR;",
        "half vertexAlpha : TEXCOORD2;",
        "o.vertexAlpha = v.color.a;",
    ),
    "com.dazi.apex.avatar/Runtime/Shaders/Standard.shader": (
        "* _Color.a * i.vertexAlpha",
    ),
    "com.dazi.apex.world/Runtime/Shaders/Standard.shader": (
        "* _BaseColor.a * i.vertexAlpha",
        "fixed4 vertexColor : COLOR;",
        "* _BaseColor * i.vertexColor",
        "#pragma shader_feature_local _APEX_DETAIL",
    ),
    "com.dazi.apex.world/Runtime/Shaders/VertexBlendLite.shader": (
        "sampler2D _LayerAMask; float4 _LayerAMask_ST;",
        "sampler2D _LayerBMask; float4 _LayerBMask_ST;",
        "half effectMaskA = tex2D(_LayerAMask, i.maskUvA).b;",
        "half effectMaskB = tex2D(_LayerBMask, i.maskUvB).b;",
        "meta.Emission = _EmissionColor.rgb * _EmissionColor.a * effectMask;",
    ),
    "com.dazi.apex.fx/Runtime/Shaders/DissolveCutout.shader": (
        '#include "Packages/com.dazi.apex.fx/Runtime/HLSL/ApexFX_Dissolve.cginc"',
        "clip(ApexDissolveClipValue(noiseValue, _DissolveAmount));",
        "half edge = ApexDissolveEdge(noiseValue, _DissolveAmount, _EdgeWidth);",
        "* _BaseColor.rgb * i.vertexColor.rgb",
    ),
    "com.dazi.apex.toon/Runtime/Shaders/CharacterLite.shader": (
        'Name "FORWARD_ADD"',
        'Name "META"',
        "* _Color.a * i.vertexAlpha",
        "fixed4 vertexColor : COLOR;",
        "* _Color * i.vertexColor",
    ),
}

SHADER_RE = re.compile(r'\bShader\s+"([^"]+)"')
PASS_NAME_RE = re.compile(r'\bName\s+"([^"]+)"')
CATALOG_RE = re.compile(
    r'new\s+ShaderContract\(\s*"([^"]+)"\s*((?:,\s*"[^"]+")*)\s*\)'
)
STRING_RE = re.compile(r'"([^"]+)"')


def discover_shader_passes() -> dict[str, tuple[str, ...]]:
    discovered: dict[str, tuple[str, ...]] = {}
    for path in sorted(PACKAGES.rglob("*.shader")):
        text = path.read_text(encoding="utf-8")
        names = SHADER_RE.findall(text)
        if len(names) != 1:
            raise SystemExit(f"{path.relative_to(ROOT)} must declare exactly one Shader name")
        shader_name = names[0]
        pass_names = tuple(PASS_NAME_RE.findall(text))
        if shader_name in discovered:
            raise SystemExit(f"duplicate shader name while validating passes: {shader_name}")
        discovered[shader_name] = pass_names
    return discovered


def discover_catalog_contracts() -> dict[str, tuple[str, ...]]:
    text = CATALOG.read_text(encoding="utf-8")
    contracts: dict[str, tuple[str, ...]] = {}
    for shader_name, tail in CATALOG_RE.findall(text):
        contracts[shader_name] = tuple(STRING_RE.findall(tail))
    return contracts


def validate_semantic_contracts(errors: list[str]) -> None:
    for relative, required_snippets in SEMANTIC_CONTRACTS.items():
        path = PACKAGES / relative
        if not path.exists():
            errors.append(f"missing parity-contract file: packages/{relative}")
            continue
        text = path.read_text(encoding="utf-8")
        for snippet in required_snippets:
            if snippet not in text:
                errors.append(
                    f"packages/{relative}: missing 0.3.4 parity invariant {snippet!r}"
                )


def main() -> None:
    shader_passes = discover_shader_passes()
    catalog_contracts = discover_catalog_contracts()
    errors: list[str] = []

    if set(shader_passes) != set(EXPECTED_PASS_SETS):
        missing = sorted(set(EXPECTED_PASS_SETS) - set(shader_passes))
        unexpected = sorted(set(shader_passes) - set(EXPECTED_PASS_SETS))
        if missing:
            errors.append("missing shader pass contracts: " + ", ".join(missing))
        if unexpected:
            errors.append("unexpected shaders without pass contracts: " + ", ".join(unexpected))

    for shader_name, expected in EXPECTED_PASS_SETS.items():
        actual = shader_passes.get(shader_name)
        if actual is not None and actual != expected:
            errors.append(
                f"{shader_name}: expected ordered passes {expected}, found {actual}"
            )
        catalog = catalog_contracts.get(shader_name)
        if catalog != expected:
            errors.append(
                f"ApexShaderCatalog {shader_name}: expected {expected}, found {catalog}"
            )

    if set(catalog_contracts) != set(EXPECTED_PASS_SETS):
        missing = sorted(set(EXPECTED_PASS_SETS) - set(catalog_contracts))
        unexpected = sorted(set(catalog_contracts) - set(EXPECTED_PASS_SETS))
        if missing:
            errors.append("catalog missing contracts: " + ", ".join(missing))
        if unexpected:
            errors.append("catalog has unexpected contracts: " + ", ".join(unexpected))

    validate_semantic_contracts(errors)

    if errors:
        for error in errors:
            print("ERROR:", error)
        raise SystemExit(1)

    print(
        f"Validated exact pass contracts for {len(EXPECTED_PASS_SETS)} Apex shaders "
        f"and {len(SEMANTIC_CONTRACTS)} parity-invariant files."
    )


if __name__ == "__main__":
    main()
