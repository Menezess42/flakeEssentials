<div align="center">
<h1>Flake Essentials</h1>
<img width="300" height="300" alt="flakeEssentials" src="https://github.com/user-attachments/assets/488c77ea-234d-414a-a197-f0d32c03fa5d" />
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
- **Protect heavy environments from garbage collection when needed**

---

## Provided Essentials

- **Python** - Base Python development environment
- **Python + ML** - Python with Machine Learning libraries (CUDA, TensorFlow, PyTorch, etc.)
- **JavaScript / Node.js** - Modern JavaScript/TypeScript development

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

## Circuit Breaker 🔒

### The Problem

When using `direnv` with Nix flakes, each project creates a `.direnv` folder that maintains references to its dependencies. When you delete a project's `.direnv` (or the entire project), those dependencies become eligible for garbage collection. 

For heavy environments like Python ML (with CUDA, TensorFlow, etc.), this means:
- Running `nix-collect-garbage -d` removes everything
- Next time you create a project using that essential, it rebuilds from scratch
- Hours of compilation time and gigabytes of downloads are wasted

### The Solution

The **Circuit Breaker** is a declarative GC root management system that keeps selected essentials "anchored" in the Nix store, preventing them from being garbage collected even when no active projects are using them.

### How It Works

The Circuit Breaker creates persistent symbolic links in `/nix/var/nix/gcroots/flakeEssentials/` that point to your selected essentials. These GC roots survive `nix-collect-garbage -d` and keep all dependencies alive.

When you create a new project that needs an anchored essential:
- ✅ No downloads
- ✅ No compilation
- ✅ Instant devShell activation

### Usage

#### 1. Configure which essentials to protect

Edit `hub/config.nix`:

```nix
{
  js = false;           # Don't protect JavaScript
  pythonBase = false;   # Don't protect Python base
  pythonML = true;      # Protect Python ML (it's heavy!)
}
```

#### 1.5 If a new essentials is created
Edit `hub/lib.nix`. Adding the new essentials to the list
```nix
  # Maps config keys to their corresponding essential shells
  # This is the ONLY place where you need to add new essentials
  essentialMappings = essentials: system: {
    js = essentials.devShells.${system}.js or null;
    pythonBase = essentials.devShells.${system}.python or null;
    pythonML = essentials.devShells.${system}.pythonML or null;
    # Add more mappings as essentials are created:
    # rust = essentials.devShells.${system}.rust or null;
  };
```

#### 2. Activate the Circuit Breaker

```bash
cd flakeEssentials/hub
nix run .#anchor
```

This creates GC roots for all essentials marked as `true` in your config.

#### 3. Check status

```bash
nix run .#status
```

Shows which essentials are currently protected.

#### 4. Deactivate protection (when you want to free space)

```bash
nix run .#release
```

Removes all GC roots, allowing the next `nix-collect-garbage` to clean up.

### Available Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `nix run .#anchor` | `nix run .#on` | Activate protection for configured essentials |
| `nix run .#release` | `nix run .#off` | Remove protection (allow GC) |
| `nix run .#status` | `nix run .` | Show current protection status |

### Architecture

The Circuit Breaker consists of three clean, separated components:

```
hub/
├── config.nix   # Interface: declare what to protect
├── lib.nix      # Core: pure functional logic
└── flake.nix    # Motor: orchestration and side effects
```

**Benefits:**
- Single Responsibility Principle: each file has one job
- DRY: essentials list defined once
- Testable: all logic is pure functions
- Extensible: adding new essentials requires only 2 lines
- Self-documenting: clear names and comments

---

## Example Usage

### Basic Project Setup

```nix
{
  description = "My Project";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    essentials.url = "path:/path/to/flakeEssentials";
  };
  
  outputs = { self, nixpkgs, flake-utils, essentials }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        baseShell = essentials.devShells.${system}.python;
        mlShell = essentials.devShells.${system}.pythonML;
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = [
            # Project-specific tools
          ] ++ baseShell.buildInputs ++ mlShell.buildInputs;
          
          shellHook = ''
            echo "Custom project shell"
          '';
        };
      });
}
```

### With Circuit Breaker Protection

```bash
# 1. Protect heavy ML environment
cd flakeEssentials/hub
# Edit config.nix: pythonML = true
nix run .#anchor

# 2. Work on your ML project
cd ~/projects/my-ml-project
direnv allow  # Instant activation, no downloads!

# 3. Finish the project and clean up
rm -rf ~/projects/my-ml-project

# 4. Run aggressive garbage collection
sudo nix-collect-garbage -d

# 5. Start a new ML project later
cd ~/projects/new-ml-project
direnv allow  # Still instant! No rebuilds!
```

---

## Workflow Recommendation

For **frequently used, heavy essentials** (like Python ML):
- Keep them anchored with Circuit Breaker
- Save hours of compilation time
- Trade-off: ~5-10GB of disk space

For **lightweight or rarely used essentials** (like JavaScript):
- Don't anchor them
- Let GC clean them when unused
- Rebuilds are fast anyway

---

## Adding New Essentials

1. Create the essential directory and implementation
2. Export it in the root `flake.nix`
3. Add it to Circuit Breaker:
   - Add config option in `hub/config.nix`
   - Add mapping in `hub/lib.nix` under `essentialMappings`

---

## License

This project is licensed under the MIT License.
