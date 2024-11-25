{
  stdenv,
  zephyr, # from zephyr-nix
  callPackage,
  cmake,
  ninja,
  west2nix,
  gitMinimal,
  gcc-arm-embedded,
  lib,
}:

let
  west2nixHook = west2nix.mkWest2nixHook {
    manifest = ./west2nix.toml;
  };

in
{
  packages = {
    sofle_reset = stdenv.mkDerivation {
      name = "sofle_reset";
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
        "nice_nano_v2"
        "--"
        "-DZMK_CONFIG=${./config}"
        "-DSHIELD=settings_left"
      ];
      installPhase = ''
        mkdir $out
        cp ./build/zephyr/zmk.elf $out/
      '';
    };
    sofle_left = stdenv.mkDerivation {
      name = "sofle_left";
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
        "sofle_left"
        "--"
        "-DZMK_CONFIG=${./config}"
        "-DSHIELD=nice_view_adapter;nice_view"
      ];
      installPhase = ''
        mkdir $out
        cp ./build/zephyr/zmk.elf $out/
      '';
    };
    sofle_right = stdenv.mkDerivation {
      name = "sofle_right";
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
        "sofle_right"
        "--"
        "-DZMK_CONFIG=${./config}"
        "-DSHIELD=nice_view_adapter;nice_view"
      ];
      installPhase = ''
        mkdir $out
        cp ./build/zephyr/zmk.elf $out/
      '';
    };
  };
}
