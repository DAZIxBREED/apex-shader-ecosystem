#!/usr/bin/env bash
set -euo pipefail

repo="DAZIxBREED/apex-shader-ecosystem"
version="$(tr -d '[:space:]' < VERSION)"
branch="$(git branch --show-current)"

if ! command -v gh >/dev/null 2>&1; then
  echo "GitHub CLI (gh) is required." >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "Authenticate with: gh auth login" >&2
  exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
  git remote add origin "https://github.com/${repo}.git"
fi

git push -u origin "$branch"

if [[ "$branch" == "main" ]]; then
  if ! git rev-parse "v${version}" >/dev/null 2>&1; then
    git tag -a "v${version}" -m "Apex Shader Ecosystem ${version}"
  fi
  git push origin "v${version}"
  echo "Published ${repo} main and v${version}."
else
  echo "Published branch ${branch}. Open a pull request, merge it, then tag v${version} from main."
fi
