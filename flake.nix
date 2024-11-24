{
  description = "flake template";

  inputs = {
    flake-lock.url = "github:wrvsrx/flake-lock";
    nixpkgs.follows = "flake-lock/nixpkgs";
    flake-parts.follows = "flake-lock/flake-parts";
    west2nix = {
      url = "github:adisbladis/west2nix";
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

            # inherit (s) packages;
            devShells.default = pkgs.mkShell {
              # inputsFrom = [ packages.default ];
              nativeBuildInputs = [ inputs.west2nix.packages.${system}.default ];
            };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );
}
