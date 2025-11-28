{ pkgs, lib }:
let
  constants = {
    gcrootDir = "/nix/var/nix/gcroots/flakeEssentials";
    gcrootPrefix = "essential";
  };

  essentialMappings = essentials: system: {
    js = essentials.devShells.${system}.js or null;
    pythonBase = essentials.devShells.${system}.python or null;
    pythonML = essentials.devShells.${system}.pythonML or null;
  };

  selectShells = config: mappings:
    builtins.filter 
      (shell: shell != null)
      (lib.attrsets.mapAttrsToList
        (name: shell: if config.${name} or false then shell else null)
        mappings
      );

  collectInputs = shells:
    builtins.concatLists (
      map (shell: shell.buildInputs or []) shells
    );

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
