{
  description = "Ambientes essenciais de desenvolvimento: PS: TESTING ONNERSHIP";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
    # flake.nix (essentials) — trecho relevante
    outputs = { self, nixpkgs, flake-utils }:
      flake-utils.lib.eachDefaultSystem (system:
        let
          pkgs = import nixpkgs { inherit system; config.doCheck = false; };

          pythonShell = import ./Python/default.nix { inherit pkgs; };
          pythonMLShell = import ./PythonML/default.nix { inherit pkgs; };
          jsShell = import ./Js/default.nix { inherit pkgs; };

        in {
          # Devshells para uso rápido (compatibilidade)
          devShells = {
            python    = pythonShell.shell;     # mkShell pronto
            pythonML  = pythonMLShell.shell;   # mkShell pronto (opcional)
            js        = jsShell.shell;
          };

          # Modules exportáveis para composição
          modules = {
            python = {
              base = pythonShell.module;      # { buildInputs, shellHook, env, ... }
            };
            ml = {
              python = pythonMLShell.module;  # { buildInputs, shellHook, env, ... }
            };
            js = { base = jsShell.module; };
          };
        });
  # outputs = { self, nixpkgs, flake-utils }:
  #   flake-utils.lib.eachDefaultSystem (system:
  #     let
  #       pkgs = import nixpkgs { inherit system;  config.doCheck = false;};
  #       pythonShell = import ./Python/default.nix { inherit pkgs; };
  #       # goShell = import ./Go/default.nix { inherit pkgs; };
  #       jsShell = import ./Js/default.nix {inherit pkgs; };
  #       pythonMLShell = import ./PythonML/default.nix {inherit pkgs; };
  #     in
  #     {
  #       devShells = {
  #         python = pythonShell;
  #         js  = jsShell;
  #         pythonML = pythonMLShell;
  #       };
  #     });
}

