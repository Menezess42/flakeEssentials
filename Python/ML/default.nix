{ pkgs }:

let
  # Reimporta pkgs com unfree habilitado apenas aqui (isolado)
  pkgsUnfree = import pkgs.path {
    inherit (pkgs) system;
    config.allowUnfree = true;
  };

  python = pkgsUnfree.python313;

  mlModule = {
    buildInputs = [
      (python.withPackages (ps: [
        ps.torch-bin   # PyTorch com CUDA já incluído
        ps.torchvision-bin
        ps.setuptools
      ]))

      pkgsUnfree.cudaPackages.cudatoolkit
      pkgsUnfree.cudaPackages.cudnn
    ];

    shellHook = ''
      echo "[Python ML Essentials] Ambiente ML carregado com PyTorch + CUDA"

      export CUDA_PATH=${pkgsUnfree.cudaPackages.cudatoolkit}
      export LD_LIBRARY_PATH=${pkgsUnfree.cudaPackages.cudatoolkit}/lib:${pkgsUnfree.cudaPackages.cudnn}/lib:$LD_LIBRARY_PATH
    '';

    env = { };
  };

  mlShell = pkgsUnfree.mkShell {
    name = "essentials-python-ml-env";
    buildInputs = mlModule.buildInputs;
    shellHook   = mlModule.shellHook;
  };

in
{
  module = mlModule;
  shell  = mlShell;
}
