# Publishing Updates to GitHub

The repository remote is:

```text
https://github.com/DAZIxBREED/apex-shader-ecosystem.git
```

## Authenticate

GitHub account passwords are not accepted for HTTPS Git operations. Use GitHub CLI:

```bash
gh auth login
gh auth refresh -h github.com -s workflow
gh auth setup-git
```

The `workflow` scope is required because this repository contains files under `.github/workflows/`.

## Push the current development branch

```bash
git push -u origin "$(git branch --show-current)"
```

## Merge through a pull request

```bash
gh pr create --fill --draft
```

After validation and review, merge the PR into `main`.

## Tag a release

Use the exact value in `VERSION`:

```bash
version="$(cat VERSION)"
git switch main
git pull --ff-only
git tag -a "v${version}" -m "Apex Shader Ecosystem ${version}"
git push origin main "v${version}"
```
