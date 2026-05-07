# overleaf-sync Nix flake

Nix flake providing a dev shell with [`overleaf-sync`](https://github.com/moritzgloeckl/overleaf-sync) (`ols`).

Patches applied on top of the upstream 1.2.0 release:
- Fixes project listing broken by Overleaf's May 2023 API change (`ol-prefetchedProjectsBlob`)
- Replaces the QtWebEngine login (crashes with SIGSEGV under Nix) with a CLI login supporting email/password and Google/SSO
- Sends a browser User-Agent and raw Cookie header to avoid Python cookie encoding issues

## Usage

```bash
nix develop github:Vasissualiyp/overleaf-sync
```

Or clone and run locally:

```bash
git clone <this repo>
cd overleaf-sync
nix develop
```

### Login

```bash
ols login
```

Choose **[1]** for email + password, or **[2]** for Google/SSO:

- Open DevTools (F12) → **Application → Cookies → https://www.overleaf.com**
- Copy `overleaf_session2` (starts with `s:...`)
- Copy `GCLB` if present (press Enter to skip if not)

The session cookie is saved to `.olauth` in the current directory.

### Sync a project

```bash
mkdir "My Project Name"
cd "My Project Name"
ols                        # two-way sync
ols -r                     # remote → local only
ols -l                     # local → remote only
```

The directory name must match the Overleaf project name exactly. Use `ols list` to see available project names.

### List projects

```bash
ols list
```

### Download compiled PDF

```bash
ols download -n "My Project Name"
```

## Requirements

- Nix with flakes enabled (`experimental-features = nix-command flakes`)
