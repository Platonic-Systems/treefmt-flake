# treefmt-flake

A [`flake-parts`](https://github.com/hercules-ci/flake-parts) module to work with [treefmt](https://github.com/numtide/treefmt).

## Status

This flake module would be be more useful after https://github.com/srid/treefmt-flake/issues/1 - because, then the flakeModule will encapsulate more than just a `check`.

## Usage

See [this PR](https://github.com/srid/haskell-template/pull/36) for a complete example.

```nix
  outputs = { self, flake-parts, nixpkgs, treefmt-flake, ... }:
    flake-parts.lib.mkFlake { inherit self; } {
      imports = [
        treefmt-flake.flakeModule
      ];
      perSystem = { lib, config, pkgs, system, ... }:
        {
          # Provided by treefmt-flake.flakeModule
          treefmt.formatters = {
            inherit (pkgs)
              nixpkgs-fmt;
            inherit (pkgs.nodePackages)
              purs-tidy;
          };

          devShells = {
            default = pkgs.mkShell {
              buildInputs = (with pkgs; [
                ...
              ] ++ config.treefmt.buildInputs);
            };
          };
        };
    };
```

This adds a `.#checks.<system>.treefmt` flake output that checks that the project tree is already autoformatted.

It also adds a `.#apps.<system>.format` output that can can be used to format your project using `nix run .#format`.