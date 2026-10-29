---
name: lock-review
description: Review a weekly update-flake-lock pull request in nix-packages and drive it to a merge decision — confirm the diff is lock-only, run the gates, judge the closure diff of the check system (where version changes are the expected outcome rather than a red flag), name the notable bumps and any vulnerability they fix or bring, and hand the rebase merge to the owner. Use when a chore(deps) flake.lock PR is open.
---

# lock-review

The `update-flake-lock` workflow opens a `chore(deps): update flake.lock` PR
every Saturday at 06:00 JST. Merging is always manual (ADR 0001); this is the
procedure for deciding. It is dotfiles-mac's `lock-review`, adapted: here a
merged lock changes no machine until a host's repository moves its
`nix-packages` input, and that repository reviews the move with its own
`lock-review`.

## Steps

1. **Find the PR and check it out.**
   `gh pr list --state open --label dependencies`, then
   `gh pr checkout <n>`. The workflow reuses the branch
   `update_flake_lock_action` each week.

2. **Confirm the diff is lock-only.**
   `git diff main... --stat` must show `flake.lock` and nothing else. Anything
   else on the branch means the workflow misfired: stop and report.

3. **Run the gates.** `bin/preflight.sh`. A gate that fails is usually the
   new toolchain at work, since the linters come from the devShell the lock
   pins, and it is still a finding. The workflow's PRs get no CI, so this run
   is the evidence the PR has.

4. **Diff the check system's closure.** Build it on `main` and on the branch,
   and compare:

   ```sh
   nix build --no-update-lock-file -o /tmp/np-new .#checks.aarch64-darwin.darwin
   git switch main
   nix build --no-update-lock-file -o /tmp/np-old .#checks.aarch64-darwin.darwin
   git switch -
   nix store diff-closures /tmp/np-old /tmp/np-new
   ```

   Version movement is the expected outcome. Judge these instead:
   - every moved node is an upstream version bump of something already
     declared, with no unexplained **additions or removals**;
   - the net closure size change is plausible: bootstrap paths dropping out
     is normal, a large unexplained gain is not.

5. **Record the notable bumps.** Name the packages the owner uses daily with
   old → new versions. A dozen named bumps is reviewable; 150 nodes is not.
   Run `vulns repo .` and say whether the bump fixes or brings a finding,
   naming the `vulnerability` issue it touches.

6. **Report, and leave the merge to the owner.** Merge with **`--rebase`,
   never `--squash`**, so the lock update survives as its own dedicated
   commit: `! gh pr merge <n> --rebase`. Say that merged is not applied: a
   host takes it when its repository moves its `nix-packages` input.

## Rules

- Never push, never merge, never switch: those are the owner's.
- Never run `nix flake update`. Updates come from the workflow or the owner;
  build and check invocations pass `--no-update-lock-file`.
- A genuine breakage is a reason to **hold** the PR, not to rerun it until it
  passes. Holding a week costs nothing: the next scheduled run supersedes it.
