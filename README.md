# nix-packages

What is installed on hypatia-tile's hosts, and at which version: Nix packages,
Homebrew casks and brews, and fonts, with the pinned `nixpkgs` and overlays
they come from, and the tracking of their vulnerabilities.

[`hypatia-tile/dotfiles-mac`](https://github.com/hypatia-tile/dotfiles-mac)
imports this flake and stays the only flake that is built and switched; the
configuration of each tool lives there.

## Outputs

| Output | What it is |
|---|---|
| `overlays.default` | neovim-nightly, rust-overlay and emacs-flake, in that order |
| `homeModules.shared` | Home Manager `home.packages` for every host |
| `homeModules.darwin` | Home Manager `home.packages` for macOS hosts only |
| `darwinModules.default` | nix-darwin Homebrew and fonts, and the overlay above |

A nix-darwin host with Home Manager imports `darwinModules.default`, and
`homeModules.shared` and `homeModules.darwin` for its user, and follows this
flake's `nixpkgs`. Unfree packages are declared here, so the host sets
`nixpkgs.config.allowUnfree`.

## Working on it

`AGENTS.md` has the rules, and `docs/adr/` the decisions. After cloning, the
owner installs the Git hooks once:

```sh
git config core.hooksPath .githooks
```

`bin/preflight.sh` runs every gate; on macOS, `nix flake check` builds every
declared package in a minimal system without switching anything.
