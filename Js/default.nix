{pkgs}:
pkgs.mkShell {
  name = "essentials-js-env";
  config.doCheck=false;
  buildInputs = with pkgs; [
  javascript-typescript-langserver
  eslint
  nodejs
  nodePackages.prettier
  prettierd
  typescript-language-server
  typescript
  typescript-language-server
  typescript
  vscode-langservers-extracted
  tailwindcss-language-server
  ];
  shellHook = ''
      echo "Ambiente JS Essencial carregado!"
      '';
}
