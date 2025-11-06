{pkgs}:
pkgs.mkShell {
  name = "essentials-python-env";
  config.doCheck=false;
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
  ];
  shellHook = ''
    echo "Ambiente Python Essencial carregado!"
  '';
}
