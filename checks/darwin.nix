# The least a nix-darwin + Home Manager system needs around this repository's
# modules, so that `nix flake check` evaluates them and builds every package
# they declare (ADR 0003). It mirrors what dotfiles-mac sets around them where
# that decides what gets built; everything else is a placeholder.
{
  nixpkgs.hostPlatform = "aarch64-darwin";

  # zsh-abbr, claude-code, cursor-cli and others are unfree. dotfiles-mac
  # sets this in its own modules/darwin/nix.nix, so the host decides it.
  nixpkgs.config.allowUnfree = true;

  # Determinate Nix owns the daemon on the host, so nix-darwin does not.
  nix.enable = false;

  system.stateVersion = 6;
  # Homebrew's options need a user to run as.
  system.primaryUser = "ci";
  users.users.ci.home = "/Users/ci";

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.ci.home.stateVersion = "25.05";
  };
}
