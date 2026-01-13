{
  description = "Python Development Shell";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
    };

    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
    };
  };

  outputs = { nixpkgs, pyproject-nix, uv2nix, pyproject-build-systems, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      lib = nixpkgs.lib;

      # Reads ./pyproject.toml and ./uv.lock
      workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };

      # Overlay generated from uv.lock
      uvOverlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel";
      };

      python = pkgs.python3;

      pythonSet =
        (pkgs.callPackage pyproject-nix.build.packages { inherit python; })
          .overrideScope (lib.composeManyExtensions [
            pyproject-build-systems.overlays.wheel
            uvOverlay
          ]);

      venv = pythonSet.mkVirtualEnv "dev-env" workspace.deps.default;
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          venv
          pkgs.uv
          pkgs.quarto
        ];
      };
    };
}
