
# Publish this repository to GitHub

## One-command publication

With GitHub CLI installed and authenticated, publish as a private repository:

```bash
./scripts/publish_github.sh private
```

Use `public` instead only when the source is ready to be publicly visible.


The intended GitHub repository is:

```text
DAZIxBREED/apex-shader-ecosystem
```

Create an **empty** repository with that name on GitHub. Do not initialize it with a README, license, or `.gitignore`, because this repository already contains them.

Then run from this folder:

```bash
git remote add origin git@github.com:DAZIxBREED/apex-shader-ecosystem.git
git push -u origin main
git tag -a v0.1.0 -m "Apex Shader Ecosystem 0.1.0"
git push origin v0.1.0
```

For HTTPS instead of SSH:

```bash
git remote add origin https://github.com/DAZIxBREED/apex-shader-ecosystem.git
git push -u origin main
```

The tag triggers the package archive workflow after GitHub Actions is enabled.
