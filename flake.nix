{
  description = "My personal NUR repository";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    edmarketconnector = {
      url = "https://github.com/EDCD/EDMarketConnector.git";
      type = "git";
      flake = false;
      submodules = true;
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      systems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f system);
    in
    {
      packages = forAllSystems (system: import ./default.nix {
        inherit inputs;
        pkgs = import nixpkgs {
          inherit system;
          config.allowBroken = true;
        };
      });
    };
}
