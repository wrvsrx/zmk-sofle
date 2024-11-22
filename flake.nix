{
  description = "flake template";

  inputs = {
    flake-lock.url = "github:wrvsrx/flake-lock";
    nixpkgs.follows = "flake-lock/nixpkgs";
    flake-parts.follows = "flake-lock/flake-parts";
    zmk-nix = {
      url = "github:lilyinstarlight/zmk-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      { inputs, ... }:
      {
        systems = [ "x86_64-linux" ];
        perSystem =
          { pkgs, system, ... }:
          let
            s = pkgs.callPackage ./. { };
          in
          rec {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [ inputs.zmk-nix.overlays.default ];
            };

            inherit (s) packages;
            # devShells.default = pkgs.mkShell { inputsFrom = [ packages.default ]; };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );
}
