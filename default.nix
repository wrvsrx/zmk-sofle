{
  stdenv,
  zephyr, # from zephyr-nix
  callPackage,
  cmake,
  ninja,
  mkWest2nixHook,
  gitMinimal,
  lib,
  symlinkJoin,
  runCommand,
}:

let
  west2nixHook = mkWest2nixHook {
    manifest = ./west2nix.toml;
  };
  buildSofle =
    { board, shields }:
    stdenv.mkDerivation {
      name = board;
      src = ./.;
      nativeBuildInputs = [
        west2nixHook
        (zephyr.pythonEnv.override {
          zephyr-src = (lib.lists.findFirst (x: x.name == "zephyr") null west2nixHook.projectsWithFakeGit).src;
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
      westBuildFlags = [
        "-s"
        "../zmk/app"
        "-b"
        board
        "--"
        "-DZMK_CONFIG=${./config}"
        "-DSHIELD=${lib.concatStringsSep ";" shields}"
      ];
      dontUseCmakeConfigure = true;
      env.Zephyr_DIR = "../zephyr/share/zephyr-package/cmake";
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
