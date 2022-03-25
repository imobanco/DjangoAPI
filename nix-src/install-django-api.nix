{ pkgs ? import <nixpkgs> { }, minimal-required-packages ? [ ] }:
pkgs.stdenv.mkDerivation rec {
  name = "install-django-api";
  buildInputs = with pkgs; [ stdenv ];
  nativeBuildInputs = with pkgs; [ makeWrapper ];
  propagatedNativeBuildInputs = with pkgs; [ openssh ripgrep ] ++ minimal-required-packages;

  src = builtins.path { path = ./.; name = "install-django-api"; };
  phases = [ "installPhase" ];

  unpackPhase = ":";

  installPhase = ''
    mkdir -p $out/bin

    cp "${src}"/install-django-api.sh $out/install-django-api.sh

    install \
    -m0755 \
    $out/install-django-api.sh \
    -D \
    $out/bin/install-django-api

    patchShebangs $out/bin/install-django-api

    wrapProgram $out/bin/install-django-api \
      --prefix PATH : "${pkgs.lib.makeBinPath (with pkgs; minimal-required-packages) }"
  '';

}
