# Adapted from github:nix-community/nur-combined/repos/plabadens
{ pkgs, lib, edmarketconnector, ... }:

let
pypkgs = pkgs.python310.pkgs;

in
pypkgs.buildPythonApplication {
  pname = "EDMarketConnector";
  src = edmarketconnector;
  version = edmarketconnector.shortRev;

  format = "other";
  doCheck = false;

  propagatedBuildInputs = with pypkgs; [
    certifi
      requests
      watchdog
      semantic-version
      tkinter
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share
    cp -r * $out/share

    mkdir -p $out/bin
    makeWrapper $out/share/EDMarketConnector.py $out/bin/EDMarketConnector \
    --prefix PATH ':' "$program_PATH" \
    --set PYTHONPATH "$PYTHONPATH"

    runHook postInstall
    '';

  meta = with lib; {
    homepage = "https://github.com/EDCD/EDMarketConnector";
    description = ''
      Downloads commodity market and other station data from the game
      "Elite: Dangerous" for use with all popular online and offline trading tools.
      '';
    license = licenses.gpl2Only;
  };
}
