#!/usr/bin/env bash
set -euo pipefail

visibility="${1:-private}"
case "$visibility" in
  private|public) ;;
  *) echo "Usage: $0 [private|public]" >&2; exit 2 ;;
esac

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required: https://cli.github.com/" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Authenticate first with: gh auth login" >&2
  exit 1
fi

if git remote get-url origin >/dev/null 2>&1; then
  echo "An origin remote already exists: $(git remote get-url origin)" >&2
  echo "Remove or change it before running this publisher." >&2
  exit 1
fi

gh repo create DAZIxBREED/apex-shader-ecosystem \
  "--${visibility}" \
  --source=. \
  --remote=origin \
  --push

git push origin v0.1.0

echo "Published DAZIxBREED/apex-shader-ecosystem (${visibility}) with tag v0.1.0."
