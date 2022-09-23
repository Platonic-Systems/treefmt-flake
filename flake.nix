{
  description = "A `flake-parts` module for treefmt";
  inputs = {
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };
  outputs = { self, ... }: {
    flakeModule = ./flake-module.nix;
  };
}
