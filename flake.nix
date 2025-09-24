{
  description = "Ambientes essenciais de desenvolvimento: PS: TESTING ONNERSHIP";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system;  config.doCheck = false;};
        pythonShell = import ./Python/default.nix { inherit pkgs; };
        # goShell = import ./Go/default.nix { inherit pkgs; };
        jsShell = import ./Js/default.nix {inherit pkgs; };
      in
      {
        devShells = {
          python = pythonShell;
          js  = jsShell;
        };
      });
}

