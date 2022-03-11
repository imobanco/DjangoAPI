{
  description = "Flake do DjangoAPI";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    podman-rootless.url = "github:ES-Nix/podman-rootless/from-nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, podman-rootless }:
    flake-utils.lib.eachDefaultSystem (system:
      let

        pkgsAllowUnfree = import nixpkgs {
          inherit system;
          # Caso se precise usar pacotes não free
          config = { allowUnfree = true; };
        };

      in
      {

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [

            bashInteractive
            coreutils

            curl
            gnumake
            podman-rootless.defaultPackage.${system}
            poetry
            python3
            postgresql_14
            tmate
          ];

          shellHook = ''
            echo "Entering the nix devShell"
          '';
        };
      });
}
