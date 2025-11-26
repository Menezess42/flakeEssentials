
{
  description = "Persistent essentials hub";

  inputs.essentials.url = "path:../.";

  outputs = { self, essentials, ... }:
  let
    system = "x86_64-linux";

    retain = {
      pythonBase = false;
      pythonML   = true;
      js         = false;
    };

    active = builtins.filter (x: x != null) [
      (if retain.pythonBase then essentials.devShells.${system}.python   else null)
      (if retain.pythonML   then essentials.devShells.${system}.pythonML else null)
      (if retain.js         then essentials.devShells.${system}.js       else null)
    ];

  in {
    packages.${system}.default = active;
  };
}
