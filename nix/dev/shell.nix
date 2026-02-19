{
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) pre-commit craneLib;
  in {
    devShells.default =
      craneLib.devShell.override {
        mkShell = pkgs.mkShell.override {
          inherit (pkgs.llvmPackages_latest) stdenv;
        };
      } ({
          inherit (config) checks;

          packages =
            # [
            #   pkgs.mdformat
            #   pkgs.mdbook
            #   pkgs.mdbook-mermaid
            #   pkgs.mdbook-admonish
            #   pkgs.mdbook-linkcheck
            #   pkgs.jq
            #   pkgs.tree
            # ]
            # ++
            pre-commit.settings.enabledPackages;

          shellHook = ''
            ${pre-commit.installationScript}
          '';
        }
        // (builtins.removeAttrs config.commonArgsRelease ["pname" "src" "stdenv"]));
  };
}
