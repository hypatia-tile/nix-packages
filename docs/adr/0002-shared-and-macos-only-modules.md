# 0002. Shared and macOS-only modules, with an explicit order

- Status: Proposed
- Date: 2026-10-29

## Context

This repository serves one host today, `Kazukis-MacBook-Air` (nix-darwin and
Home Manager), and `hypatia-tile/nixos-config` may import the part that is not
macOS-specific later (#1, hypatia-tile/dotfiles-mac#310). dotfiles-mac places
its payloads by the same rule: by whether the tool is macOS-specific, not by
which host has it today (dotfiles-mac ADR 0034). Its ADR 0037 chose no option
interface: modules are imported as they are.

Stage 2 of dotfiles-mac#310 requires dotfiles-mac, built against this
repository, to give the same system store path as before the split. Two facts
measured while bootstrapping make the order of `home.packages` part of that:

- `buildEnv` serialises its paths in order. Moving only `myEmacs` within
  dotfiles-mac's list changed the system derivation; forcing the same list
  back in did not.
- The module system merges list definitions from two imports in reverse import
  order: `imports = [ a b ]` gives `b ++ a`, on the pinned nixpkgs.

`myEmacs` is the only macOS-specific entry of dotfiles-mac's
`home.packages`: hypatia-tile/emacs-flake builds for `aarch64-darwin` alone
and patches the Cocoa port. It sat in the middle of the list.

## Decision

**Three outputs carry the declarations, imported as they are:**

- `homeModules.shared`: `home.packages` for every host.
- `homeModules.darwin`: `home.packages` for macOS hosts, defined with
  `lib.mkBefore`, so that these entries come first whatever order a host
  imports the two modules in.
- `darwinModules.default`: Homebrew and fonts, which are nix-darwin options
  and so macOS-only by construction, and `nixpkgs.overlays = [
  overlays.default ]`, so a nix-darwin host gets the overlays by importing it.

`overlays.default` composes neovim-nightly, rust and emacs-flake **in that
order**, dotfiles-mac's at the split.

To meet stage 2, dotfiles-mac first moves `myEmacs` to the start of its list
(hypatia-tile/dotfiles-mac#314), which changes its store path and not its
contents. Its stage 2 then compares against that commit. A package is placed
here by the same rule as the rest: in `darwin` only if the tool itself is
macOS-specific. colima and docker are shared: both run on Linux.

## Consequences

- A new macOS-only package lands at the start of the list, not beside related
  tools. The comments in `modules/home/darwin.nix` say why.
- Checked before the first commit: with `myEmacs` moved first in
  dotfiles-mac's list, the 52 derivations of `shared` and `darwin` equal
  dotfiles-mac's, in both import orders, and the Brewfile and fonts are equal.
- The modules rely on facts a host provides: `allowUnfree` (zsh-abbr,
  claude-code, cursor-cli and others are unfree) is set by the host, as
  dotfiles-mac sets it today. dotfiles-mac ADR 0037 records such facts as a
  known gap.
- A NixOS host importing `shared` gets the tools as nixpkgs builds them on
  Linux. `docker` there includes the daemon, since nixpkgs builds the client
  alone only on darwin.
