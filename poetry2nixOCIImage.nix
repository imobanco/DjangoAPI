{ pkgs ? import <nixpkgs> { } }:
let
  poetry2nixOCIImage = import ./poetry2nix.nix { inherit pkgs; };

  entrypoint = pkgs.writeScript "entrypoint.sh" ''
    #!${pkgs.stdenv.shell}
    "${ if pkgs.stdenv.hostPlatform.isDarwin then "" else pkgs.dockerTools.shadowSetup}"

    echo 'From entrypoint'
    exec "$@"
  '';

in
pkgs.dockerTools.buildLayeredImage {
  name = "django-api";
  tag = "0.0.1";

  contents = with pkgs; [
    poetry2nixOCIImage
    bashInteractive
    coreutils

    file
    which
  ];


  config = {
    Cmd = [ "${pkgs.bashInteractive}/bin/bash" ];

    Entrypoint = [ entrypoint ];
    Env = [
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bunle.crt"
    ];
  };
}
