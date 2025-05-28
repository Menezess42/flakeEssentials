{pkgs}:
pkgs.mkShell {
  name = "essentials-python-env";
  config.doCheck=false;
  buildInputs = with pkgs; [
                python311
                python311Packages.pip
                # IDE Like Features
                pyright
                python311Packages.pip
                python311Packages.jedi
                python311Packages.jedi-language-server
                python311Packages.black
                python311Packages.flake8
                python311Packages.sentinel
                python311Packages.python-lsp-server
                python311Packages.virtualenv
                python311Packages.pyflakes  # Linter Pyflakes
                python311Packages.isort
  ];
  shellHook = ''
    echo "Ambiente Python Essencial carregado!"
  '';
}
