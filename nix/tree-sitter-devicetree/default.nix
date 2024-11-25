{
  buildPythonPackage,
  fetchFromGitHub,
  setuptools,
  tree-sitter,
}:

buildPythonPackage rec {
  pname = "tree-sitter-devicetree";
  version = "0.12.1";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "joelspadin";
    repo = "tree-sitter-devicetree";
    rev = "v${version}";
    hash = "sha256-UVxLF4IKRXexz+PbSlypS/1QsWXkS/iYVbgmFCgjvZM=";
  };

  buildInputs = [ tree-sitter ];

  build-system = [ setuptools ];

}
