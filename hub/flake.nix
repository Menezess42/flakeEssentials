{
  description = "FlakeEssentials Circuit Breaker - Persistent Environment Management";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    essentials.url = "path:..";
  };

  outputs = { self, nixpkgs, flake-utils, essentials }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        
        config = import ./config.nix;
        
        lib = import ./lib.nix { inherit pkgs; lib = pkgs.lib; };
        
        mappings = lib.essentialMappings essentials system;
        selectedShells = lib.selectShells config mappings;
        allInputs = lib.collectInputs selectedShells;
        statusMessage = lib.generateStatusMessage config;
        anchorCommands = lib.generateAnchorCommands allInputs;

        anchorScript = pkgs.writeShellScriptBin "anchor-essentials" ''
          set -e
          
          echo "🔒 FlakeEssentials Circuit Breaker"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo ""
          
          # Create GC root directory
          if ! sudo mkdir -p "${lib.constants.gcrootDir}"; then
            echo "❌ Failed to create GC root directory"
            echo "   Make sure you have sudo privileges"
            exit 1
          fi
          
          sudo rm -f "${lib.constants.gcrootDir}"/*
          
          echo "Creating persistent GC roots..."
          ${anchorCommands}
          
          echo ""
          echo "✓ Successfully anchored ${toString (builtins.length allInputs)} packages"
          echo ""
          echo "${statusMessage}"
          echo ""
          echo "These essentials will survive 'nix-collect-garbage -d'"
          echo "Location: ${lib.constants.gcrootDir}"
        '';

        releaseScript = pkgs.writeShellScriptBin "release-essentials" ''
          set -e
          
          echo "🔓 FlakeEssentials Circuit Breaker"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo ""
          echo "Releasing all GC roots..."
          
          if [ -d "${lib.constants.gcrootDir}" ]; then
            sudo rm -rf "${lib.constants.gcrootDir}"
            echo "✓ GC roots removed"
          else
            echo "⚠️  No GC roots found (already released)"
          fi
          
          echo ""
          echo "Run 'nix-collect-garbage -d' to free disk space"
        '';

        statusScript = pkgs.writeShellScriptBin "status-essentials" ''
          echo "🔍 FlakeEssentials Circuit Breaker Status"
          echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
          echo ""
          
          if [ -d "${lib.constants.gcrootDir}" ]; then
            echo "GC Root Directory: ${lib.constants.gcrootDir}"
            echo ""
            
            count=$(find "${lib.constants.gcrootDir}" -type l 2>/dev/null | wc -l)
            
            if [ "$count" -gt 0 ]; then
              echo "Active GC Roots: $count"
              echo ""
              ls -lh "${lib.constants.gcrootDir}"
            else
              echo "⚠️  GC root directory exists but is empty"
              echo "   Run 'nix run .#anchor' to activate circuit breaker"
            fi
          else
            echo "⚠️  Circuit breaker not activated"
            echo "   Run 'nix run .#anchor' to protect your essentials"
          fi
          
          echo ""
          echo "Configuration:"
          echo "${statusMessage}"
        '';

      in
      {
        packages = {
          default = pkgs.buildEnv {
            name = "flakeEssentials-circuit-breaker";
            paths = allInputs;
            pathsToLink = [ "/bin" "/lib" "/share" ];
          };
          
          anchor = anchorScript;
          release = releaseScript;
          status = statusScript;
        };

        apps = {
          anchor = {
            type = "app";
            program = "${anchorScript}/bin/anchor-essentials";
          };
          
          release = {
            type = "app";
            program = "${releaseScript}/bin/release-essentials";
          };
          
          status = {
            type = "app";
            program = "${statusScript}/bin/status-essentials";
          };
          
          default = self.apps.${system}.status;
          on = self.apps.${system}.anchor;
          off = self.apps.${system}.release;
        };

        devShells.default = pkgs.mkShell {
          name = "flakeEssentials-circuit-breaker-shell";
          
          buildInputs = allInputs ++ [ 
            anchorScript 
            releaseScript 
            statusScript 
          ];
          
          shellHook = ''
            echo "🔧 FlakeEssentials Circuit Breaker Management Shell"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "Commands:"
            echo "  anchor-essentials   - Protect essentials from GC"
            echo "  release-essentials  - Allow GC to clean essentials"
            echo "  status-essentials   - Show current protection status"
            echo ""
            echo "${statusMessage}"
            echo ""
            echo "Edit config.nix to change which essentials are protected"
          '';
        };
      });
}
