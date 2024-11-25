{
  description = "flake template";

  inputs = {
    flake-lock.url = "github:wrvsrx/flake-lock";
    nixpkgs.follows = "flake-lock/nixpkgs";
    flake-parts.follows = "flake-lock/flake-parts";
    west2nix = {
      url = "github:adisbladis/west2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zephyr-nix.follows = "zephyr-nix";
    };
    zephyr-nix.url = "github:adisbladis/zephyr-nix";
    zephyr-nix.inputs.nixpkgs.follows = "nixpkgs";
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
            s = pkgs.callPackage ./. {
              west2nix = inputs.west2nix.lib.mkWest2nix { inherit pkgs; };
              zephyr = inputs.zephyr-nix.packages.${system};
            };
          in
          rec {
            inherit (s) packages;
            devShells.default = pkgs.mkShell {
              inputsFrom = [ packages.sofle_reset ];

              env = {
                Zephyr_DIR = "../zephyr/share/zephyr-package/cmake";
              };
              nativeBuildInputs = [ inputs.west2nix.packages.${system}.default ];
            };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );
}
