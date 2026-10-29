# CLAUDE.md

The rules for working in this repository are in **`AGENTS.md`**, which is
tool-agnostic and is the source of truth for them. Everything below is
specific to Claude Code and adds to it rather than restating it.

@AGENTS.md

## Guardrails

`bin/agent-guard.sh` is registered in `.claude/settings.json` as a
`PreToolUse` hook, and is the authoritative enforcement for every agent. The
`permissions` lists in the same file are a second layer, specific to Claude
Code:

- **deny**: `darwin-rebuild switch` / `activate`, `sudo darwin-rebuild`,
  `git push`, `nix flake update`;
- **allow**: the read-only verification commands (`nix flake check`,
  `nix build`, `nix eval`, `nix store diff-closures`, `git`
  status/diff/log/ls-files/branch), and `git commit`, which the Git hooks
  gate.

`gh` is in neither list, because a prefix cannot tell a write from a read.
Only the guard decides `gh`: it allows reading and authoring PRs and issues,
refuses `gh pr merge` and writes through `gh api`, and asks about anything
else. Merging is the owner's, so it is handed over as `! gh pr merge …`.
