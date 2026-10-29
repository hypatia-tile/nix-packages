# nix-darwin options that install something: Homebrew and fonts. macOS-only by
# construction, since both are nix-darwin options (ADR 0002).
{
  imports = [
    ./fonts.nix
    ./homebrew.nix
  ];
}
