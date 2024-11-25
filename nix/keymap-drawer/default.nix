{
  buildPythonPackage,
  fetchPypi,
  pydantic,
  pcpp,
  pyyaml,
  platformdirs,
  pydantic-settings,
  tree-sitter,
  tree-sitter-devicetree,
  poetry-core,
  pythonRelaxDepsHook,
}:
buildPythonPackage rec {
  pname = "keymap-drawer";
  version = "0.19.0";
  pyproject = true;

  nativeBuildInputs = [
    poetry-core
    pythonRelaxDepsHook
  ];

  pythonRelaxDeps = [ "tree-sitter" ];

  src = fetchPypi {
    pname = "keymap_drawer";
    inherit version;
    sha256 = "sha256-/+QWhDXJeS/qJGzHb8K9Fa5EyqEl5zI2it/vPl9AtO4=";
  };

  propagatedBuildInputs = [
    pydantic
    pcpp
    pyyaml
    platformdirs
    pydantic-settings
    tree-sitter
    tree-sitter-devicetree
  ];

}
