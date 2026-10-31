# 0003. Check the modules in a minimal system

- Status: Accepted
- Date: 2026-10-29

## Context

The outputs of ADR 0002 are modules, which nothing builds on their own. #1
asks CI to evaluate them in a minimal nix-darwin and Home Manager
configuration and build the package set on `macos-15`. It also keeps
nix-darwin and Home Manager out of this repository's inputs "except as needed
by CI's evaluation", since dotfiles-mac brings its own.

## Decision

**`checks.aarch64-darwin.darwin` is a minimal system around the modules, and
nix-darwin and Home Manager are inputs for it alone.**

- The system imports `darwinModules.default`, Home Manager's darwin module,
  and `homeModules.shared` and `darwin` for one placeholder user.
  `checks/darwin.nix` sets only what a system needs and what decides what
  gets built: `allowUnfree`, the platform, state versions, `nix.enable =
  false`, Home Manager's `useGlobalPkgs` and `useUserPackages`, as
  dotfiles-mac sets them.
- Building the check builds every declared package, so `nix flake check` on
  macOS is the package build. `bin/check-flake.sh` runs it for the pre-push
  hook, `preflight` and CI.
- nix-darwin and Home Manager are top-level inputs following `nixpkgs`,
  pinned at first to dotfiles-mac's revisions. No output hands them out. A
  consumer can make them follow its own, which keeps one copy of each in its
  lock.

## Consequences

- The weekly lock PR moves them too. That changes only what this
  repository's check is built against, never what a host gets.
- The CI build is the cost of a full package set on `macos-15`: Emacs comes
  from the hypatia-emacs cache, and the nightly Neovim from the store cache
  kept per lock.
- The check proves the modules build together on macOS. It does not prove
  that `shared` evaluates on Linux; that is checked when a Linux host first
  imports it.
