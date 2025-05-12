{ pkgs }:

pkgs.mkShell {
  name = "essentials-python-env";
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
                # Libs for the book
                python311Packages.matplotlib
                python311Packages.numpy
  ];
  shellHook = ''
    echo "Ambiente Python Essencial carregado!"
  '';
}
