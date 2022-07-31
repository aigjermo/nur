# This file provides all the buildable and cacheable packages and
# package outputs in your package set. These are what gets built by CI,
# so if you correctly mark packages as
#
# - broken (using `meta.broken`),
# - unfree (using `meta.license.free`), and
# - locally built (using `preferLocalBuild`)
#
# then your CI will be able to build and cache only those packages for
# which this is possible.

{ system ? builtins.currentSystem }:

let
  flake = builtins.getFlake (toString ./.);
  inputs = flake.inputs;
  pkgs = import (inputs.nixpkgs) { inherit system; };
  nurAttrs = import ./default.nix { inherit system pkgs inputs; };

  isReserved = n: n == "lib" || n == "overlays" || n == "modules";
  isDerivation = p: builtins.isAttrs p && p ? type && p.type == "derivation";
  isBuildable = p: !(p.meta.broken or false) && p.meta.license.free or true;
  isCacheable = p: !(p.preferLocalBuild or false);
  shouldRecurseForDerivations = p: builtins.isAttrs p && p.recurseForDerivations or false;

  outputsOf = p: map (o: p.${o}) p.outputs;
  concatMap = builtins.concatMap or (f: xs: builtins.concatLists (map f xs));

  nurPkgs =
  let
    nameValuePair = n: v: { name = n; value = v; };
    flattenPkgs = s:
      let
        f = p:
          if shouldRecurseForDerivations p then flattenPkgs p
          else if isDerivation p then [ p ]
          else [ ];
      in
      concatMap f (builtins.attrValues s);
  in
    flattenPkgs
      (builtins.listToAttrs
        (map (n: nameValuePair n nurAttrs.${n})
          (builtins.filter (n: !isReserved n)
            (builtins.attrNames nurAttrs))));

  buildPkgs = builtins.filter isBuildable nurPkgs;
  cachePkgs = builtins.filter isCacheable buildPkgs;
in
{
  inherit buildPkgs cachePkgs;

  buildOutputs = concatMap outputsOf buildPkgs;
  cacheOutputs = concatMap outputsOf cachePkgs;
}
