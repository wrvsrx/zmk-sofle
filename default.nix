{
  stdenv,
  stdenvNoCC,
  keymap-drawer,
  zephyr, # from zephyr-nix
  callPackage,
  cmake,
  ninja,
  mkWest2nixHook,
  gitMinimal,
  lib,
  symlinkJoin,
  qemu,
  runCommand,
}:

let
  west2nixHook = mkWest2nixHook {
    manifest = ./west2nix.toml;
  };
  buildSofle =
    {
      name ? board,
      board,
      shields,
    }:
    stdenv.mkDerivation {
      inherit name;
      src = ./.;
      nativeBuildInputs = [
        west2nixHook
        (zephyr.pythonEnv.override {
          zephyr-src =
            (lib.lists.findFirst (x: x.name == "zephyr") null west2nixHook.projectsWithFakeGit).src;
        })
        (zephyr.hosttools-nix.override { qemu_full = qemu; })
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
        ("-DZMK_CONFIG=${./.}" + "/config")
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
    eyelash_sofle_reset = buildSofle {
      name = "eyelash_sofle_reset";
      board = "eyelash_sofle_left";
      shields = [ "settings_reset" ];
    };
    eyelash_sofle_left = buildSofle {
      board = "eyelash_sofle_left";
      shields = [ "nice_view" ];
    };
    eyelash_sofle_right = buildSofle {
      board = "eyelash_sofle_right";
      shields = [ "nice_view_custom" ];
    };
    eyelash_sofle_keymap = stdenvNoCC.mkDerivation {
      name = "eyelash_sofle_keymap";
      src = ./.;
      nativeBuildInputs = [ keymap-drawer ];
      buildPhase = ''
        keymap -c keymap-drawer/config.yaml parse -z config/eyelash_sofle.keymap > eyelash_sofle.yaml
        XDG_CACHE_HOME=$PWD/keymap-drawer/cache keymap -c keymap-drawer/config.yaml draw -j config/eyelash_sofle.json eyelash_sofle.yaml > eyelash_sofle.svg
      '';
      installPhase = ''
        mkdir _p $out
        cp eyelash_sofle.svg $out
      '';
    };
    default = symlinkJoin {
      name = "sofle-firmware";
      paths = [
        eyelash_sofle_reset
        eyelash_sofle_left
        eyelash_sofle_right
        eyelash_sofle_keymap
      ];
    };
  };
}
