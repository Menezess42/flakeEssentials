{
  description = "Ambientes essenciais de desenvolvimento: PS: TESTING ONNERSHIP";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pythonShell = import ./Python/default.nix { inherit pkgs; };
        # goShell = import ./Go/default.nix { inherit pkgs; };
        # jsShell = import ./JS/default.nix { inherit pkgs; };
      in
      {
        devShells = {
          python = pythonShell;
          # go = goShell;
          # js = jsShell;
        };
      });
}

