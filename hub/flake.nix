{
  description = "FlakeEssentials Hub - Persistent Environment Anchor";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Referencia o flake pai
    essentials.url = "path:..";
  };

  outputs = { self, nixpkgs, flake-utils, essentials }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        # Configuração: marque true para manter persistente
        config = {
          js = true;
          pythonBase = false;
          pythonML = true;
        };

        # Função que seleciona os shells baseado na config
        selectedShells = builtins.filter 
          (shell: shell != null)
          [
            (if config.js then essentials.devShells.${system}.js else null)
            (if config.pythonBase then essentials.devShells.${system}.python else null)
            (if config.pythonML then essentials.devShells.${system}.pythonML else null)
          ];

        # Coleta todos os buildInputs dos shells selecionados
        allInputs = builtins.concatLists (
          map (shell: shell.buildInputs) selectedShells
        );

      in
      {
        # Package que agrega todas as dependências selecionadas
        packages.default = pkgs.buildEnv {
          name = "flakeEssentials-anchor";
          paths = allInputs;
          pathsToLink = [ "/bin" "/lib" "/share" ];
        };

        # Também exporta como devShell caso você queira testar
        devShells.default = pkgs.mkShell {
          name = "flakeEssentials-hub";
          buildInputs = allInputs;
          shellHook = ''
            echo "🔒 FlakeEssentials Hub - Anchored Environments:"
            ${if config.js then ''echo "  ✓ JavaScript"'' else ""}
            ${if config.pythonBase then ''echo "  ✓ Python Base"'' else ""}
            ${if config.pythonML then ''echo "  ✓ Python ML"'' else ""}
          '';
        };
      });
}
