{ pkgs }:
let
# módulo que será reutilizável por outros flakes
pythonModule = {
    buildInputs = with pkgs; [
        python311
            python311Packages.pip
# IDE Like Features
            pyright
            python313Packages.pip
            python313Packages.jedi
            python313Packages.jedi-language-server
            python313Packages.black
            python313Packages.flake8
            python313Packages.sentinel
            python313Packages.python-lsp-server
            python313Packages.virtualenv
            python313Packages.pyflakes  # Linter Pyflakes
            python313Packages.isort
            python313Packages.debugpy
# ... outras libs comuns
    ];

    shellHook = ''
        echo "Ambiente Python Essencial carregado!"
        '';

    env = {
# se precisar variáveis compartilhadas
        PYTHONNOUSERSITE = "1";
    };
};

# shell pronto (compatibilidade backward)
pythonShell = pkgs.mkShell {
    name = "essentials-python-env";
    buildInputs = pythonModule.buildInputs;
    shellHook = pythonModule.shellHook;
};
in
{
    module = pythonModule;
    shell  = pythonShell;
}
# {pkgs}:
# pkgs.mkShell {
#   name = "essentials-python-env";
#   config.doCheck=false;
#   buildInputs = with pkgs; [
#   ];
#   shellHook = ''
#     echo "Ambiente Python Essencial carregado!"
#   '';
# }
