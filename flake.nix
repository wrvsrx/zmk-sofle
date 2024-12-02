{
  description = "flake template";

  inputs = {
    flake-lock.url = "github:wrvsrx/flake-lock";
    nixpkgs.follows = "flake-lock/nixpkgs";
    flake-parts.follows = "flake-lock/flake-parts";
    west2nix = {
      url = "github:wrvsrx/west2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.zephyr-nix.follows = "zephyr-nix";
    };
    zephyr-nix = {
      url = "github:wrvsrx/zephyr-nix";
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
            s = pkgs.callPackage ./. {
              inherit (inputs.west2nix.lib.mkWest2nix { inherit pkgs; })
                mkWestDependencies
                ;
              zephyr = inputs.zephyr-nix.packages.${system};
            };
          in
          rec {
            inherit (s) packages;
            devShells.default = pkgs.mkShell {
              inputsFrom = [ packages.sofle_reset ];

              env = {
                Zephyr_DIR = "zephyr/share/zephyr-package/cmake";
              };
              nativeBuildInputs =
                let
                  pythonPackages = import ./nix { inherit pkgs; };
                in
                [
                  inputs.west2nix.packages.${system}.default
                  pythonPackages.keymap-drawer
                ];
            };
            formatter = pkgs.nixfmt-rfc-style;
          };
      }
    );
}
