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
                # python311
                # python311Packages.pip
                # # IDE Like Features
                # pyright
                # python311Packages.pip
                # python311Packages.jedi
                # python311Packages.jedi-language-server
                # python311Packages.black
                # python311Packages.flake8
                # python311Packages.sentinel
                # python311Packages.python-lsp-server
                # python311Packages.virtualenv
                # python311Packages.pyflakes  # Linter Pyflakes
                # python311Packages.isort
  ];
  shellHook = ''
    echo "Ambiente JS Essencial carregado!"
  '';
}
