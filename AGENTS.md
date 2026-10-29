# AGENTS.md

Rules for any coding agent working in this repository. This file is the
source of truth for them; `CLAUDE.md` points here and adds only what is
specific to Claude Code. They are a reduced copy of
`hypatia-tile/dotfiles-mac`'s `AGENTS.md` (ADR 0001).

## What this repository is

The package declarations for hypatia-tile's hosts, their versions and their
vulnerability tracking, as a Nix flake. `hypatia-tile/dotfiles-mac` imports
it as a flake input, follows its `nixpkgs`, and stays the only flake that is
built and switched (dotfiles-mac ADR 0037). Configuration of tools is not
here: it is dotfiles-mac's.

- `modules/home/shared.nix` and `modules/home/darwin.nix`: `home.packages`,
  split by whether the tool is macOS-specific (ADR 0002). The order is part of
  the store path; read ADR 0002 before moving an entry.
- `modules/darwin/`: Homebrew and fonts.
- `flake.nix`: the inputs, the overlays and the outputs, and
  `checks.aarch64-darwin.darwin`, which builds them all (ADR 0003).
- `docs/adr/`: the decisions, from 0001. A reference to an ADR or issue of
  dotfiles-mac says so (`dotfiles-mac ADR 0031`, `dotfiles-mac#57`).

## Hard rules

- **Never run `darwin-rebuild switch`, any activation script, or `sudo`.**
  Work here is build-only: `nix flake check`, `nix build`, closure diffs.
  Nothing here is applied directly; a host applies it from its own repository.
- **Commit on a feature branch without asking; never push.** The owner pushes
  and merges. Every commit runs the Git hooks, and the next report names the
  branch, each new commit's short hash and subject, and that nothing has been
  pushed.
- **`flake.lock` moves only in dedicated commits**, which `bin/check-lock.sh`
  enforces at commit time and in CI. The weekly workflow opens the PRs, the
  `lock-review` skill reviews them, and merging is always manual, by rebase.
  Build and check invocations pass `--no-update-lock-file`; ad-hoc
  `nix flake update` is refused.
- **No secrets in this repository**, ever.
- **All repository artifacts are in English**: documents, code, comments,
  commit messages, PR bodies. Conversation with the owner may be in Japanese.

These rules are enforced for every agent by `bin/agent-guard.sh`, a
pre-tool-use hook registered for Claude Code and Codex. A refusal that names
`agent-guard` is a rule taking effect, not an obstacle: hand the step to the
owner, and never rephrase the command to get past it. If the guard refuses
something the rules allow, that is a bug in the guard: say so and stop.

## How work is organised

- **The Git hooks run the gates on commit and push**, once `core.hooksPath`
  is set to `.githooks` (the owner's step). Run `bin/hooks-health.sh` before
  the first commit of a session, and if it fails, report it instead of
  committing. A commit or push a hook refuses is a finding to report, never
  one to get past.
- **Run `bin/preflight.sh` before proposing a PR.** It runs every gate CI
  runs, over the whole tree.
- Work on short-lived feature branches off `main`, with Conventional Commits.
  One concern per branch. The `pre-commit` hook refuses a commit on `main`.
- **Adding or removing a tool that is also configured in dotfiles-mac** goes
  package first, then config; removal is config first, then package, so that
  neither repository is broken in between (dotfiles-mac ADR 0037).
- **ADRs** live in `docs/adr/NNNN-slug.md`, start as `Status: Proposed`, and
  cite the issue they start from. Only the owner changes a status. An ADR is
  never edited once accepted; a changed decision gets a new ADR.
- **Skills** live in `.claude/skills/<name>/SKILL.md`, with a relative symlink
  in `.codex/skills/<name>`, because Codex reads a repository's skills only
  from there.
- **Vulnerabilities** in the tools declared here are tracked one issue per
  tool, labelled `vulnerability`, from `.github/ISSUE_TEMPLATE/vulnerability.md`.
  Runtime deferrals go in `.vulns-defer`.
- **Deferred work lives in GitHub Issues**, not as TODOs in documents.

## Working notes

- **Verify empirically; do not conclude from inference.** Confirm a claim
  about what a change builds to with a real evaluation or build before
  stating it.
- **Check the tail of files you write.** The file-writing tool occasionally
  appends a stray closing tag to a file it creates; `bin/check-stray-tags.sh`
  catches it.
