{ pkgs }:
let
# módulo que será reutilizável por outros flakes
pythonModule = {
        buildInputs = with pkgs; [
            (python313.withPackages (ps: [
                ps.pip
                ps.jedi
                ps.jedi-language-server
                ps.black
                ps.flake8
                ps.sentinel
                ps.python-lsp-server
                ps.virtualenv
                ps.pyflakes
                ps.isort
                ps.debugpy
            ]))

            pyright
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
