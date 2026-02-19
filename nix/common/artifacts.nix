{lib, ...}: {
  perSystem = {config, ...}: let
    inherit (config) craneLib commonArgs commonArgsRelease;
  in {
    options = {
      cargoArtifacts = lib.mkOption {
        type = lib.types.package;
        default = craneLib.buildDepsOnly (commonArgs
          // {
            # Include dev dependencies for clippy offline mode
            cargoCheckExtraArgs = "--all-features";
          });
      };
      cargoArtifactsRelease = lib.mkOption {
        type = lib.types.package;
        default = craneLib.buildDepsOnly commonArgsRelease;
      };
    };
  };
}
