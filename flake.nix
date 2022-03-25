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

        poetryEnv = import ./mkPoetryEnv.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        minimal-required-packages = with pkgsAllowUnfree; [
          bash
          coreutils
          gnumake
          podman-rootless.packages.${system}.podman
        ];
      in
      rec {

        packages.poetry2nixMkPoetryApplication = import ./poetry2nix.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        packages.poetry2nixOCIImage = import ./poetry2nixOCIImage.nix {
          pkgs = nixpkgs.legacyPackages.${system};
        };

        packages.poetryEnv = poetryEnv;

        packages.install-django-api = import ./nix-src/install-django-api.nix {
          pkgs = pkgsAllowUnfree;
          inherit minimal-required-packages;
        };

        apps.install-django-api = flake-utils.lib.mkApp {
          name = "install-django-api";
          drv = packages.install-django-api;
        };

        devShell = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree; [
            poetryEnv

            bashInteractive
            coreutils

            curl
            gnumake
            podman-rootless.packages.${system}.podman
            poetry
            python3
            # postgresql_14
            # tmate

            #
            codespell
            nixpkgs-fmt
            shellcheck
            findutils
          ];

          shellHook = ''
            echo "Entering the nix devShell"
            # nix develop .# --command bash -c "python -c 'import django'"
            # find . -type f -iname '*.nix' -exec nixpkgs-fmt {} \;

            # nix build .#poetry2nixOCIImage
            # podman load < result
            # podman run -it --rm -u 0 localhost/numtild-dockertools-poetry2nix:0.0.1

            # echo "${poetryEnv}"
            # poetry config virtualenvs.in-project true
            # poetry config virtualenvs.path .
            # poetry install
          '';
        };

        devShells.debug-tools = pkgsAllowUnfree.mkShell {
          buildInputs = with pkgsAllowUnfree;
            [
              postgresql_14
            ]
            ++
            (if "${system}" == "i686-linux" then [ ]
            else if "${system}" == "aarch64-linux" then [ ]
            else if stdenv.isDarwin then [ ]
            else [ dbeaver insomnia ]);
        };

        checks = {
          nixpkgsFmt = pkgsAllowUnfree.runCommand "check-nix-format"
            {
              buildInputs = with pkgsAllowUnfree; [
                nixpkgs-fmt
              ];
            } ''
            nixpkgs-fmt --check ${./.}

            mkdir $out #success
          '';

          codeSpell = pkgsAllowUnfree.runCommand "codespell"
            {
              buildInputs = with pkgsAllowUnfree; [ findutils codespell ];
            } ''
            find ${./.} -type f -print0 | xargs -0 -n1 codespell --ignore-words=${./.}/ignore.txt -d -q 3 -

            mkdir $out #success
          '';

          shellCheck = pkgsAllowUnfree.runCommand "shellcheck"
            {
              buildInputs = with pkgsAllowUnfree; [ findutils shellcheck ];
            } ''

            find ${./.} -type f -iname '*.sh' -print0 | xargs --no-run-if-empty -0 -n1 shellcheck

            mkdir $out #success
          '';

          pythonFormatCheck = pkgsAllowUnfree.runCommand "python-format-check"
            {
              buildInputs = with pkgsAllowUnfree; [
                packages.poetryEnv
                gnumake
              ];

              nativeBuildInputs = with pkgsAllowUnfree; [ makeWrapper ];
            } ''
            mkdir $out
            cp -r ${./.}/* $out
            cd $out

            substituteInPlace Makefile \
              --replace "SHELL := /bin/bash" "SHELL := ${pkgsAllowUnfree.bash}/bin/bash"

            make fmt.check

          '';

          build = packages.poetryEnv;

        };
      });
}




