# A flake-parts module for using treefmt (provides a check, mainly)
#
# NOTE: This module may be improved using https://github.com/numtide/treefmt/pull/169
{ self, lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib)
    mkPerSystemOption;
  inherit (lib)
    mkOption
    types;
in
{
  options = {
    perSystem = mkPerSystemOption
      ({ config, self', inputs', pkgs, system, ... }: {
        options.treefmt = mkOption {
          description = "treefmt: source code tree autoformatter";
          type = types.submodule {
            options = {
              formatters = mkOption {
                type = types.attrsOf (types.nullOr types.package);
                default = { };
                description = ''Formatter packages in use by treefmt.toml'';
              };
              # Library option (not to be set by the user)
              buildInputs = mkOption {
                type = types.listOf types.package;
                default = [ pkgs.treefmt ] ++ lib.attrValues config.treefmt.formatters;
              };
            };
          };
        };
      });
  };
  config = {
    perSystem = { config, self', inputs', pkgs, ... }: {
      checks.treefmt = pkgs.runCommandLocal "treefmt-check"
        {
          buildInputs = [ pkgs.git ] ++ config.treefmt.buildInputs;
        }
        ''
          set -e

          # treefmt uses a cache at $HOME. But we can use --no-cache
          # to make treefmt not use a cache. We still seem to need
          # to export a writable $HOME though.
          # TODO: https://github.com/numtide/treefmt/pull/174 fixes this issue
          # but we need to wait until a release is made and that release gets
          # into the nixpkgs we use.
          export HOME="$TMP"

          # `treefmt --fail-on-change` is broken for purs-tidy; So we must rely
          # on git to detect changes. An unintended advantage of this approach
          # is that when the check fails, it will print a helpful diff at the end.
          cp -r ${self} $HOME/project
          chmod -R a+w $HOME/project
          cd $HOME/project

          git init
          git config user.email "nix@localhost"
          git config user.name Nix
          git add .
          git commit -m init

          treefmt --no-cache

          git status
          git --no-pager diff --exit-code
          touch $out
        '';
    };

  };
}
