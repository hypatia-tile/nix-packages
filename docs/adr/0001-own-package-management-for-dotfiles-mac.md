# 0001. Own package management for dotfiles-mac

- Status: Proposed
- Date: 2026-10-29

## Context

`hypatia-tile/dotfiles-mac` declared both what is installed and how each tool
is configured, with one `flake.lock` for all of it. Its ADR 0037 moves the
first half here: the package declarations, their versions and their
vulnerability tracking. The problem, the stages and the decisions behind them
are recorded in hypatia-tile/dotfiles-mac#310. Stage 1 of that plan is this
repository's bootstrap, #1. Nothing consumes this repository until stage 2.

dotfiles-mac stays the only flake that is built and switched. It imports this
one as a flake input and follows its `nixpkgs`.

## Decision

**This repository declares what is installed and at which version, and keeps
a reduced copy of dotfiles-mac's rules for working on it.**

- **What it holds:** the copies of dotfiles-mac's
  `modules/home/packages.nix`, `modules/darwin/homebrew.nix` and
  `modules/darwin/fonts.nix`, with their comments; `nixpkgs` and the three
  overlays, pinned to the revisions dotfiles-mac pinned at the split; and the
  vulnerability tracking (the `vulnerability` label, its issue template, and
  `.vulns-defer`). The deferrals and issues themselves move in stage 3.
- **History is not carried.** The first commit names the dotfiles-mac commit
  the files were copied from; `git log` there holds the rest. Carried commit
  messages would autolink `#N` to this repository's issues. For the same
  reason, references in copied comments name dotfiles-mac (`dotfiles-mac
  ADR 0031`, `dotfiles-mac#57`) unless they mean this repository.
- **The hard rules are dotfiles-mac's**, stated in `AGENTS.md`: never switch,
  activate or `sudo`; commit on feature branches, never push; `flake.lock`
  moves only in dedicated commits; no secrets; English.
- **They are enforced the same way.** `bin/agent-guard.sh` is a copy of
  dotfiles-mac's, registered for Claude Code and Codex, less the rule for that
  repository's archived legacy repositories. The Git hooks run Lefthook in the
  devShell, with the gates that apply here: Nix format and lint, Markdown,
  shell, stray tags, the guard's own cases, branch, lock, secrets and
  commitlint. `bin/preflight.sh` runs them all; CI runs them too.
- **Versions move weekly**, by the same `update-flake-lock` workflow as
  dotfiles-mac. Its PRs are reviewed with the `lock-review` skill and merged
  by the owner, by rebase.

## Consequences

- The rules and gates exist twice, so the copies can drift. A drift found is
  an inbox entry in dotfiles-mac, not a reason to make this repository depend
  on it (dotfiles-mac ADR 0037).
- The copied scripts keep dotfiles-mac's references in their comments. They
  stay accurate, but explaining a gate can mean reading dotfiles-mac's ADRs.
- dotfiles-mac's skills check, abbreviation and zsh checks, and Neovim checks
  have no counterpart here, because nothing here is in their scope. A skill
  added here must still be linked into `.codex/skills` by hand.
- A merged lock update here changes no machine. A host takes it when its own
  repository moves its `nix-packages` input, under its own lock rules.
