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
        
        # Import the clean interface
        config = import ./config.nix;
        
        # Import pure library functions
        lib = import ./lib.nix { inherit pkgs; lib = pkgs.lib; };
        
        # Core logic - pure functional pipeline
        mappings = lib.essentialMappings essentials system;
        selectedShells = lib.selectShells config mappings;
        allInputs = lib.collectInputs selectedShells;
        statusMessage = lib.generateStatusMessage config;
        anchorCommands = lib.generateAnchorCommands allInputs;

        # Scripts - the only impure part (side effects)
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
          
          # Clear old roots
          sudo rm -f "${lib.constants.gcrootDir}"/*
          
          # Create new roots
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
        # Packages for composition
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

        # User-friendly apps
        apps = {
          # Main action: protect essentials from GC
          anchor = {
            type = "app";
            program = "${anchorScript}/bin/anchor-essentials";
          };
          
          # Remove protection (allow GC to clean)
          release = {
            type = "app";
            program = "${releaseScript}/bin/release-essentials";
          };
          
          # Check current status
          status = {
            type = "app";
            program = "${statusScript}/bin/status-essentials";
          };
          
          # Aliases for convenience
          default = self.apps.${system}.status;
          on = self.apps.${system}.anchor;
          off = self.apps.${system}.release;
        };

        # Development shell
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
# {
#   description = "FlakeEssentials Hub - Persistent Environment Anchor";
#
#   inputs = {
#     nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
#     flake-utils.url = "github:numtide/flake-utils";
#     essentials.url = "path:..";
#   };
#
#   outputs = { self, nixpkgs, flake-utils, essentials }:
#     flake-utils.lib.eachDefaultSystem (system:
#       let
#         pkgs = import nixpkgs { inherit system; };
#
#         # Configuração: marque true para manter persistente
#         config = {
#           js = false;
#           pythonBase = false;
#           pythonML = true;
#         };
#
#         # Função que seleciona os shells baseado na config
#         selectedShells = builtins.filter 
#           (shell: shell != null)
#           [
#             (if config.js then essentials.devShells.${system}.js else null)
#             (if config.pythonBase then essentials.devShells.${system}.python else null)
#             (if config.pythonML then essentials.devShells.${system}.pythonML else null)
#           ];
#
#         # Coleta todos os buildInputs dos shells selecionados
#         allInputs = builtins.concatLists (
#           map (shell: shell.buildInputs) selectedShells
#         );
#
#         # Script para criar GC roots permanentes
#         anchorScript = pkgs.writeShellScriptBin "anchor-essentials" ''
#           set -e
#
#           GCROOT_DIR="/nix/var/nix/gcroots/flakeEssentials"
#
#           echo "🔒 Creating persistent GC roots for FlakeEssentials..."
#
#           # Cria o diretório se não existir
#           sudo mkdir -p "$GCROOT_DIR"
#
#           # Remove roots antigos
#           sudo rm -f "$GCROOT_DIR"/*
#
#           # Cria roots para cada input selecionado
#           ${builtins.concatStringsSep "\n" (
#             pkgs.lib.lists.imap0 (i: input: ''
#               echo "  → Anchoring: ${input.name or input}"
#               sudo ln -sf "${input}" "$GCROOT_DIR/essential-${toString i}"
#             '') allInputs
#           )}
#
#           echo "✓ Anchored ${toString (builtins.length allInputs)} packages"
#           echo ""
#           echo "Active essentials:"
#           ${if config.js then ''echo "  ✓ JavaScript"'' else ""}
#           ${if config.pythonBase then ''echo "  ✓ Python Base"'' else ""}
#           ${if config.pythonML then ''echo "  ✓ Python ML"'' else ""}
#           echo ""
#           echo "These will survive 'nix-collect-garbage -d'"
#         '';
#
#         # Script para remover GC roots
#         releaseScript = pkgs.writeShellScriptBin "release-essentials" ''
#           set -e
#
#           GCROOT_DIR="/nix/var/nix/gcroots/flakeEssentials"
#
#           echo "🔓 Releasing FlakeEssentials GC roots..."
#           sudo rm -rf "$GCROOT_DIR"
#           echo "✓ Done. Run 'nix-collect-garbage' to free space."
#         '';
#
#       in
#       {
#         # Package que agrega todas as dependências
#         packages = {
#           default = pkgs.buildEnv {
#             name = "flakeEssentials-anchor";
#             paths = allInputs;
#             pathsToLink = [ "/bin" "/lib" "/share" ];
#           };
#
#           anchor = anchorScript;
#           release = releaseScript;
#         };
#
#         # Apps para facilitar o uso
#         apps = {
#           anchor = {
#             type = "app";
#             program = "${anchorScript}/bin/anchor-essentials";
#           };
#           release = {
#             type = "app";
#             program = "${releaseScript}/bin/release-essentials";
#           };
#         };
#
#         # DevShell para desenvolvimento/teste
#         devShells.default = pkgs.mkShell {
#           name = "flakeEssentials-hub";
#           buildInputs = allInputs ++ [ anchorScript releaseScript ];
#           shellHook = ''
#             echo "🔧 FlakeEssentials Hub Management"
#             echo ""
#             echo "Commands:"
#             echo "  anchor-essentials  - Create persistent GC roots"
#             echo "  release-essentials - Remove GC roots"
#             echo ""
#             echo "Active configuration:"
#             ${if config.js then ''echo "  ✓ JavaScript"'' else ""}
#             ${if config.pythonBase then ''echo "  ✓ Python Base"'' else ""}
#             ${if config.pythonML then ''echo "  ✓ Python ML"'' else ""}
#           '';
#         };
#       });
# }
