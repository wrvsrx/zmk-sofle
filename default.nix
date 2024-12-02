{
  stdenv,
  zephyr, # from zephyr-nix
  callPackage,
  cmake,
  ninja,
  mkWestDependencies,
  gitMinimal,
  lib,
  symlinkJoin,
  runCommand,
}:

let
  westDependencies = mkWestDependencies {
    west2nixToml = ./west2nix.toml;
  };
  buildSofle =
    { board, shields }:
    let
      westBuildFlags = [
        "-s"
        "zmk/app"
        "-b"
        board
        "--"
        "-DZMK_CONFIG=${./config}"
        "-DSHIELD=${lib.concatStringsSep ";" shields}"
      ];
    in
    stdenv.mkDerivation {
      name = board;
      src = ./.;
      nativeBuildInputs = [
        (zephyr.pythonEnv.override {
          zephyr-src = westDependencies + "/zephyr";
        })
        zephyr.hosttools-nix
        gitMinimal
        cmake
        ninja
      ];
      buildInputs = [
        (zephyr.sdk.override {
          targets = [
            "arm-zephyr-eabi"
          ];
        })
      ];
      dontUseCmakeConfigure = true;
      configurePhase = ''
        cp --no-preserve=mode -r ${westDependencies}/* .
        west init -l config
      '';
      buildPhase = ''
        west build ${lib.escapeShellArgs westBuildFlags}
      '';
      env.Zephyr_DIR = "zephyr/share/zephyr-package/cmake";
      installPhase = ''
        mkdir $out
        cp ./build/zephyr/zmk.uf2 $out/$name.uf2
      '';
    };
in
{
  packages = rec {
    inherit westDependencies;
    sofle_reset = buildSofle {
      board = "nice_nano_v2";
      shields = [ "settings_reset" ];
    };
    sofle_left = buildSofle {
      board = "sofle_left";
      shields = [
        "nice_view_adapter"
        "nice_view"
      ];
    };
    sofle_right = buildSofle {
      board = "sofle_right";
      shields = [
        "nice_view_adapter"
        "nice_view"
      ];
    };
    default = symlinkJoin {
      name = "sofle-firmware";
      paths = [
        sofle_reset
        sofle_left
        sofle_right
      ];
    };
  };
}
