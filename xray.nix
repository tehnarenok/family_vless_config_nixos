
{ pkgs }:

let
  version = "1.8.8";
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "xray-custom";
  inherit version;

  src = pkgs.fetchurl {
    url = "https://github.com/XTLS/Xray-core/releases/download/v${version}/Xray-linux-64.zip";
    hash = "sha256-wmLf7fH4VIexMNT1mCAasKRbRUCiWgdNMLZVnlChp0E=";
  };

  nativeBuildInputs = [ pkgs.unzip ];

  unpackPhase = ''
    unzip "$src"
  '';

  installPhase = ''
    mkdir -p $out/bin
    install -m755 xray $out/bin/xray
  '';
}
