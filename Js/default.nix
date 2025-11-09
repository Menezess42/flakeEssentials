{ pkgs }:
let
  # módulo reutilizável
  jsModule = {
    buildInputs = with pkgs; [
      nodejs
      eslint
      nodePackages.prettier
      prettierd
      javascript-typescript-langserver
      typescript
      typescript-language-server
      vscode-langservers-extracted
      tailwindcss-language-server
    ];

    shellHook = ''
      echo "Ambiente JS Essencial carregado!"
    '';

    env = {
      # variáveis de ambiente compartilhadas (se quiser adicionar mais)
      NODE_NO_WARNINGS = "1";
    };
  };

  # shell direto (para backward compatibility)
  jsShell = pkgs.mkShell {
    name = "essentials-js-env";
    buildInputs = jsModule.buildInputs;
    shellHook = jsModule.shellHook;
    inherit (jsModule) env;
  };

in {
  module = jsModule;
  shell  = jsShell;
}
# {pkgs}:
# pkgs.mkShell {
#   name = "essentials-js-env";
#   config.doCheck=false;
#   buildInputs = with pkgs; [
#   javascript-typescript-langserver
#   eslint
#   nodejs
#   nodePackages.prettier
#   prettierd
#   typescript-language-server
#   typescript
#   typescript-language-server
#   typescript
#   vscode-langservers-extracted
#   tailwindcss-language-server
#   ];
#   shellHook = ''
#       echo "Ambiente JS Essencial carregado!"
#       '';
# }
