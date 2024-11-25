{ pkgs }:
rec {
  keymap-drawer = pkgs.python3.pkgs.callPackage ./keymap-drawer { inherit tree-sitter-devicetree; };
  tree-sitter-devicetree = pkgs.python3.pkgs.callPackage ./tree-sitter-devicetree { };
}
