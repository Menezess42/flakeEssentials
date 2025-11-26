# FlakeEssentials Circuit Breaker - Core Library
# 
# This file contains the pure functional logic for managing essentials.
# It has ZERO side effects and can be tested in isolation.

{ pkgs, lib }:
let
  # Constants - single source of truth
  constants = {
    gcrootDir = "/nix/var/nix/gcroots/flakeEssentials";
    gcrootPrefix = "essential";
  };

  # Maps config keys to their corresponding essential shells
  # This is the ONLY place where you need to add new essentials
  essentialMappings = essentials: system: {
    js = essentials.devShells.${system}.js or null;
    pythonBase = essentials.devShells.${system}.python or null;
    pythonML = essentials.devShells.${system}.pythonML or null;
    # Add more mappings as essentials are created:
    # rust = essentials.devShells.${system}.rust or null;
  };

  # Selects shells based on config
  # Pure function: config + mappings → list of shells
  selectShells = config: mappings:
    builtins.filter 
      (shell: shell != null)
      (lib.attrsets.mapAttrsToList
        (name: shell: if config.${name} or false then shell else null)
        mappings
      );

  # Extracts all buildInputs from selected shells
  # Pure function: [shells] → [packages]
  collectInputs = shells:
    builtins.concatLists (
      map (shell: shell.buildInputs or []) shells
    );

  # Generates shell hook message listing active essentials
  # Pure function: config → string
  generateStatusMessage = config:
    let
      activeEssentials = lib.attrsets.filterAttrs (_: v: v == true) config;
      essentialNames = builtins.attrNames activeEssentials;
      formatName = name: "  ✓ ${name}";
    in
    if essentialNames == [] then
      "⚠️  No essentials are currently anchored"
    else
      "🔒 Anchored essentials:\n" + 
      (builtins.concatStringsSep "\n" (map formatName essentialNames));

  # Generates bash commands to create GC root symlinks
  # Pure function: [packages] → string (bash code)
  generateAnchorCommands = inputs:
    let
      mkSymlink = i: input: 
        ''sudo ln -sf "${input}" "${constants.gcrootDir}/${constants.gcrootPrefix}-${toString i}"'';
    in
    builtins.concatStringsSep "\n" (
      lib.lists.imap0 mkSymlink inputs
    );

in
{
  inherit constants;
  inherit essentialMappings;
  inherit selectShells;
  inherit collectInputs;
  inherit generateStatusMessage;
  inherit generateAnchorCommands;
}
