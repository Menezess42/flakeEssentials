{ pkgs }:

let
  python = pkgs.python313;
in
let
  mlModule = {
    buildInputs = with pkgs; [
      (python.withPackages (ps: [
        ps.torch-bin
        ps.setuptools
      ]))
      cudaPackages.cudatoolkit
      cudaPackages.cudnn
    ];

    shellHook = ''
      echo "[Python ML] Ambiente ML carregado com PyTorch + CUDA"
      export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
      export LD_LIBRARY_PATH=${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn}/lib:$LD_LIBRARY_PATH
    '';

    env = {
      # se quiser expor algo via module.env, coloque aqui
    };
  };

  mlShell = pkgs.mkShell {
    name = "essentials-python-ml-env";
    buildInputs = mlModule.buildInputs;
    shellHook = mlModule.shellHook;
  };
in
{
  module = mlModule;
  shell  = mlShell;
}
# { pkgs }:
#
# let
#   python = pkgs.python313;
# in
# pkgs.mkShell {
#   name = "essentials-python-ml-env";
#
#   # Python + Torch GPU embutido
#   buildInputs = [
#     (python.withPackages (ps: [
#       ps.pytorch-bin          # PyTorch com CUDA embutido
#       ps.setuptools
#     ]))
#
#     # CUDA runtime e cuDNN carregados automaticamente
#     pkgs.cudaPackages.cudatoolkit
#     pkgs.cudaPackages.cudnn
#   ];
#
#   # Variáveis para que torch.cuda.is_available() dê True sem setup manual
#   shellHook = ''
#     echo "[Python ML Essentials] Ambiente ML carregado com PyTorch + CUDA"
#
#     export CUDA_PATH=${pkgs.cudaPackages.cudatoolkit}
#     export LD_LIBRARY_PATH=${pkgs.cudaPackages.cudatoolkit}/lib:${pkgs.cudaPackages.cudnn}/lib:$LD_LIBRARY_PATH
#
#     # Teste rápido
#     python - << 'EOF'
# import torch
# print("Torch:", torch.__version__)
# print("CUDA disponível:", torch.cuda.is_available())
# EOF
#   '';
# }
