{
  stdenv,
  zephyr, # from zephyr-nix
  callPackage,
  cmake,
  ninja,
  west2nix,
  gitMinimal,
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
      buildPhase = ''
        ls -alh
        false
      '';
      westBuildFlags = [
        "-s"
        "zmk/app"
        "-b"
        "nice_nano_v2"
        "--"
        "-DZMK_CONFIG=config"
        "-SHIELD=setting_reset"
      ];
      installPhase = ''
        mkdir $out
        cp ./build/zephyr/zephyr.elf $out/
      '';
    };
  };
}
