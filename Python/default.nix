{ pkgs ? import <nixpkgs> {} }:
#{ pkgs }:
let
  lib = pkgs.lib;

  disableAllTests = self: super:
    let
      overrideTests = pkg: pkg.overrideAttrs (_: {
        # desliga both doCheck e checkPhase
        doCheck    = false;
        checkPhase = ''
          echo ">>> testes desativados <<<"
        '';
      });
    in {
      # substitui todo o conjunto python3Packages
      python3Packages = super.python3Packages.override {
        packageOverrides = ps: lib.mapAttrs (_: pkg: overrideTests pkg) ps;
      };
    };
in
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
                python311Packages.seaborn
                python311Packages.numpy
  ];
  overlays = [ disableAllTests ];
  shellHook = ''
    echo "Ambiente Python Essencial carregado!"
  '';
}
