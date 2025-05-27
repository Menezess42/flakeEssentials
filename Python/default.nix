{ pkgs ? import <nixpkgs> {
overlays = [
      (final: prev: {
        python311 = prev.python311.override {
          packageOverrides = pyself: pysuper: {
            buildPythonPackage = args: pysuper.buildPythonPackage (args // {
              doCheck = false;
              checkInputs = [];
              nativeCheckInputs = [];
              checkPhase = ''
                echo "[checkPhase] Skipping tests (disabled by overlay)."
              '';
            });
          };
        };
      })
    ];
  }
}:
pkgs.mkShell {
  name = "essentials-python-env";

  buildInputs = with pkgs; [
    python311
    python311Packages.pip
    # IDE Like Features
    pyright
    python311Packages.jedi
    python311Packages.jedi-language-server
    python311Packages.black
    python311Packages.flake8
    python311Packages.sentinel
    python311Packages.python-lsp-server
    python311Packages.virtualenv
    python311Packages.pyflakes
    python311Packages.isort
    # Libs for the book
    python311Packages.matplotlib
    python311Packages.seaborn
    python311Packages.numpy
  ];

  shellHook = ''
    echo "Ambiente Python Essencial carregado!"
  '';
}
