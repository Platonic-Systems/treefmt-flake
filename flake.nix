{
  description = "A `flake-parts` module for treefmt";
  outputs = { self, ... }: {
    flakeModule = ./flake-module.nix;
  };
}
