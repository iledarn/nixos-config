# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

A flake-based NixOS configuration managing multiple hosts with different NixOS releases. The repo is symlinked to `/etc/nixos`.

## Build & Deploy

```bash
# Rebuild current host (gram990 is the active machine)
sudo nixos-rebuild switch --flake .#gram990

# Test without making it the boot default
sudo nixos-rebuild test --flake .#gram990

# Format all Nix files (uses alejandra)
nix fmt

# Update flake inputs
nix flake update

# Edit secrets
EDITOR=vim sops sops/secrets.yaml
```

There are no tests or linting beyond `nix fmt`.

## Architecture

### Flake Structure (`flake.nix`)
- `mkSystem` function creates NixOS configurations for each host
- Each host is pinned to a specific nixpkgs release (23.11, 24.11, 25.05)
- `pkgsUnstable` is imported separately for bleeding-edge packages (codex, kiro, claude-code)
- `specialArgs` passes `hostname`, `username`, `pkgsUnstable` to all modules

### Hosts
| Host | nixpkgs | User | Notes |
|------|---------|------|-------|
| gram990 | 25.05 | iledarn | Current active machine |
| gram | 24.11 | ildarn | Personal laptop |
| scnsoft | 23.11 | ildar | Older AMD machine |
| kaertech | 23.11 | ildar | Work AMD machine |

Hardware configs live in `hosts/{hostname}/hardware-configuration.nix` (auto-generated, rarely hand-edited).

### Key Files
- **`common-configuration.nix`** — Shared system config (services, networking, boot, desktop). Imported by all hosts. Contains a `hyprland` specialisation that swaps GNOME/GDM for Hyprland/Greetd.
- **`home.nix`** — Home Manager config for the user. All hosts share the same `home.nix`. Contains packages, shell config, Hyprland bindings, wrapper scripts, MCP server setup, activation scripts.
- **`neovim.nix`** — Neovim plugin and LSP configuration. Imported by `home.nix`.
- **`dconf.nix`** — GNOME dconf settings (generated via `dconf2nix`). Imported by `home.nix`.
- **`nvim/`** — Lua config files for Neovim plugins (loaded via `xdg.configFile`).
- **`sops/`** — Encrypted secrets (`secrets.yaml`) and SOPS config (`.sops.yaml`). Uses age encryption.

### Secrets (SOPS-nix)
Secrets are age-encrypted in `sops/secrets.yaml` and decrypted at activation to `/run/user/1000/secrets/`. Referenced in config as `${config.sops.secrets.<name>.path}`. Age key must be at `~/.config/sops/age/keys.txt`.

Managed secrets: `openai_api_key`, `google_client_id`, `google_client_secret`, `github_pat`, `context7_api_key`.

### Wrapper Scripts Pattern
Several tools are wrapped in `home.nix` to inject secrets as environment variables without exposing them system-wide. Example: `codexWithMcpTokens` wraps codex with GitHub PAT and Context7 API key.

### Activation Scripts
`home.nix` contains activation scripts that generate config files for external tools (e.g., `~/.codex/config.toml`, `~/.kiro/settings/mcp.json`) at Home Manager activation time, merging secrets with static configuration.

## Conventions

- Nix formatting uses **alejandra** (configured as `nix fmt`)
- Usernames differ per host — always use the `username` variable, never hardcode
- Unstable packages go through `pkgsUnstable` — don't add them to the host's main nixpkgs
- New host: add entry in `flake.nix` via `mkSystem`, create `hosts/{name}/hardware-configuration.nix`
- Neovim plugin Lua configs go in `nvim/` directory and are mapped via `xdg.configFile` in `home.nix`
