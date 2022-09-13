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

    mkdir -p $out/opt
    cp -r * $out/opt

    mkdir -p $out/bin
    makeWrapper $out/opt/EDMarketConnector.py $out/bin/EDMarketConnector \
    --prefix PATH ':' "$program_PATH" \
    --set PYTHONPATH "$PYTHONPATH"

    mkdir -p $out/share/applications
    cat > $out/share/applications/EDMarketConnector.desktop << EOF
    [Desktop Entry]
    Name=ED Market Connector
    Categories=Game
    Exec=$out/bin/EDMarketConnector
    Icon=EDMarketConnector
    Type=Application
    EOF

    mkdir -p $out/share/icons/hicolor/512x512/apps
    cp EDMarketConnector.png $out/share/icons/hicolor/512x512/apps/

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
