{
  description = "Package declarations, their versions and their vulnerability tracking for hypatia-tile's hosts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Emacs, pinned and patched in its own flake (dotfiles-mac ADR 0031).
    #
    # Deliberately no `inputs.nixpkgs.follows`. That flake applies a patch, so
    # its Emacs is not in cache.nixos.org and it publishes to a cache of its
    # own, built by its CI against its own lock. Making it follow this
    # repository's nixpkgs would build a different derivation, miss that cache
    # every time, and put a twenty-minute Emacs build back on the machine.
    emacs-flake.url = "github:hypatia-tile/emacs-flake";

    # Only for `checks`: the modules are evaluated and built in a minimal
    # nix-darwin + Home Manager system (ADR 0003). No output hands them out;
    # a consumer brings its own and may make these follow it.
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      neovim-nightly-overlay,
      rust-overlay,
      emacs-flake,
      nix-darwin,
      home-manager,
      ...
    }:
    let
      inherit (nixpkgs) lib;
    in
    {
      # The order is dotfiles-mac's at the split, and it is part of the result:
      # a later overlay sees the earlier ones' packages (ADR 0002).
      overlays.default = lib.composeManyExtensions [
        neovim-nightly-overlay.overlays.default
        rust-overlay.overlays.default
        emacs-flake.overlays.default
      ];

      # home.packages. A host imports `shared`, and `darwin` too on macOS
      # (ADR 0002).
      homeModules = {
        shared = ./modules/home/shared.nix;
        darwin = ./modules/home/darwin.nix;
      };

      # Homebrew, fonts, and the overlays above, so that a nix-darwin host
      # gets `pkgs.myEmacs` and the rest by importing this one module.
      darwinModules.default = {
        imports = [ ./modules/darwin ];
        nixpkgs.overlays = [ self.overlays.default ];
      };

      # The modules in a minimal system, as a host would import them
      # (ADR 0003). Building it builds every declared package; nothing is
      # switched or activated.
      checks.aarch64-darwin.darwin =
        (nix-darwin.lib.darwinSystem {
          modules = [
            self.darwinModules.default
            home-manager.darwinModules.home-manager
            ./checks/darwin.nix
            {
              home-manager.users.ci.imports = [
                self.homeModules.shared
                self.homeModules.darwin
              ];
            }
          ];
        }).system;

      # The tools the gates run with, pinned by flake.lock. Hooks, preflight
      # and CI all run inside this shell, so a linter's version moves only
      # when the lock does. x86_64-linux is the Ubuntu runners.
      devShells = lib.genAttrs [ "aarch64-darwin" "x86_64-linux" ] (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              commitlint
              deadnix
              gitleaks
              jq
              lefthook
              markdownlint-cli2
              nixfmt
              python3
              shellcheck
              statix
            ];
          };
        }
      );
    };
}
