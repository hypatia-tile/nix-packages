#!/usr/bin/env bash
# The flake evaluates and its modules build, against the locked inputs:
# `nix flake check`, whose `checks.aarch64-darwin.darwin` is a minimal
# nix-darwin + Home Manager system around the modules, so building it builds
# every declared package (ADR 0003). Build only; nothing is switched or
# activated.
#
# Only Nix files and the lock can change what the flake evaluates to.
#
# The check is aarch64-darwin, so this runs on macOS only. It needs nothing
# from the check devShell beyond nix itself.
#
# Usage: bin/check-flake.sh [--applies] [FILE...]
#        (the contract is in bin/lib/check.sh; FILE only decides whether the
#        whole check runs)
set -euo pipefail
# shellcheck source=lib/check.sh source-path=SCRIPTDIR
. "$(dirname "$0")/lib/check.sh"

scope '*.nix' flake.lock
check_gate "$@"

need nix
if [[ $(uname -s) != Darwin ]]; then
  echo "$(basename "$0"): the check system is darwin; run this on macOS" >&2
  exit 2
fi

step 'flake check' nix flake check --no-update-lock-file -L

exit "$CHECK_FAILED"
