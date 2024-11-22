{ buildKeyboard }:
{
  packages = {
    sofle_reset = buildKeyboard {
      name = "sofle_reset";
      src = ./.;
      board = "nice_nano_v2";
      shield = "settings_reset";
      zephyrDepsHash = "sha256-H/ZlKyRiEZmDkVE3SSVcFsEF9tQ7XOCgbQ2tPpO2Pys=";
    };
    sofle_left = buildKeyboard {
      name = "sofle_left";
      src = ./.;
      board = "sofle_left";
      shield = "nice_view_adapter nice_view";
      zephyrDepsHash = "sha256-H/ZlKyRiEZmDkVE3SSVcFsEF9tQ7XOCgbQ2tPpO2Pys=";
    };
    sofle_right = buildKeyboard {
      name = "sofle_right";
      src = ./.;
      board = "sofle_right";
      shield = "nice_view_adapter nice_view";
      zephyrDepsHash = "sha256-H/ZlKyRiEZmDkVE3SSVcFsEF9tQ7XOCgbQ2tPpO2Pys=";
    };
  };
}
