<div align="center">
<h1>Flake Essentials</h1>
<img width="300" height="300" alt="vaultSeer" src="https://github.com/user-attachments/assets/488c77ea-234d-414a-a197-f0d32c03fa5d" />
<hr/>
</div>

**flakeEssentials** is a shared Nix Flake hub designed to provide reusable, pre-built base development environments that can be consumed by multiple projects without rebuilding the same dependencies repeatedly.

It solves a common issue when using flakes to manage development shells: if you maintain several projects that depend on similar environments (e.g., Python, Python+ML, JavaScript), each project rebuilds everything independently, even when the versions are identical. This leads to unnecessary compilation and wasted time.

`flakeEssentials` centralizes these environments so they are built once and reused everywhere, reducing rebuilds and ensuring consistent toolchains across multiple projects.

---

## Goals

- Provide essential baseline development environments  
- Allow multiple projects to reuse the same builds  
- Eliminate repeated compilation across different flakes  
- Offer modular components that can be composed into custom devShells  
- Serve as a stable, versioned base for development tools  

---

## Provided Essentials

- Python  
- Python + ML  
- JavaScript / Node.js  

Additional environments can be added over time as needed.

---

## Architecture

`flakeEssentials` exports two layers:

### 1. Ready-to-use devShells
```nix
devShells.${system}.python
devShells.${system}.pythonML
devShells.${system}.js
```

### 2. Reusable modules
```nix
modules.python.base
modules.ml.python
modules.js.base
```


Each module includes:
- `buildInputs`
- `shellHook`
- `env`

These can be merged into custom shells in other flakes without causing duplicated dependency builds.

---

## Motivation

Without a shared flake, multiple projects that require similar environments end up rebuilding identical dependencies. Even if all of them use the same versions of Python or other tools, each flake would trigger separate builds.

With `flakeEssentials`:

- Environments are evaluated and built once  
- All projects reference these pre-built components  
- Heavy or complex environments do not need to be rebuilt per project  
- Development setups become faster and consistent across projects  

---

## Example Usage

```nix
let
  baseShell = essentials.devShells.${system}.python;
  mlShell   = essentials.devShells.${system}.pythonML;
in
{
  devShell = pkgs.mkShell {
    buildInputs =
      [
        # Project-specific tools here
      ]
      ++ baseShell.buildInputs
      ++ mlShell.buildInputs;

    shellHook = ''
      echo "Custom project shell"
    '';
  };
}
```
This merges project-specific requirements with the shared essentials environments.

----

## License
This project is licensed under the MIT License.
