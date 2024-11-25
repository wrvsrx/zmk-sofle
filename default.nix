{
  stdenv,
  zephyr, # from zephyr-nix
  callPackage,
  cmake,
  ninja,
  west2nix,
  gitMinimal,
  lib,
  symlinkJoin,
}:

let
  west2nixHook = west2nix.mkWest2nixHook {
    manifest = ./west2nix.toml;
  };
  buildSofle =
    { board, shields }:
    stdenv.mkDerivation {
      name = board;
      src = ./.;
      buildInputs = [
        (zephyr.sdk.override {
          targets = [
            "arm-zephyr-eabi"
          ];
        })
        west2nixHook
        zephyr.pythonEnv
        zephyr.hosttools-nix
        gitMinimal
        cmake
        ninja
      ];
      dontUseCmakeConfigure = true;
      env.Zephyr_DIR = "../zephyr/share/zephyr-package/cmake";
      westBuildFlags = [
        "-s"
        "../zmk/app"
        "-b"
        board
        "--"
        "-DZMK_CONFIG=${./config}"
        "-DSHIELD=${lib.concatStringsSep ";" shields}"
      ];
      installPhase = ''
        mkdir $out
        cp ./build/zephyr/zmk.uf2 $out/$name.uf2
      '';
    };
in
{
  packages = rec {
    sofle_reset = buildSofle {
      board = "nice_nano_v2";
      shields = [ "settings_left" ];
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
