{
  description = "For Civo Navigate Demo";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-23.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs-unstable {
            system = system;
        };

        basePackages = with pkgs; [
          kubectl
          kustomize
          kubernetes-helm
          kind
          kubectx
          istioctl
        ];

        customOverrides = self: super: {
          # Overrides go here
        };
      in
      {

        devShell = pkgs.mkShell {
          buildInputs = basePackages;
        };
      }
    );
}
