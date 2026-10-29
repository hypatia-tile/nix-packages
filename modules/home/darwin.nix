# home.packages for macOS hosts only: tools that are macOS-specific
# (ADR 0002).
#
# lib.mkBefore puts these at the start of the list, whatever order a host
# imports this module and shared.nix in. The order is part of the store path,
# and the module system merges two imports' definitions in reverse import
# order (measured on the pinned nixpkgs), so it is set here rather than left
# to the import.
{ lib, pkgs, ... }:
{
  home.packages = lib.mkBefore (
    with pkgs;
    [
      # Emacs 31.1 with the frame-transparency patch, from the emacs-flake
      # overlay (dotfiles-mac ADR 0031). Replaces Homebrew's emacs-plus@30.
      # Its configuration is not managed here: ~/.emacs.d is its own
      # repository and stays a live checkout.
      #
      # macOS-only: emacs-flake builds for aarch64-darwin alone, and the
      # patch targets the Cocoa (NS) port.
      myEmacs
    ]
  );
}
