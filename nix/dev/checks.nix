{
  perSystem = {config, ...}: let
    inherit (config) craneLib commonArgs cargoArtifacts;
  in {
    checks = {
      inherit (config.packages) synth-dev;

      synth-clippy = craneLib.cargoClippy (
        commonArgs
        // {
          inherit cargoArtifacts;
          cargoClippyExtraArgs = "--all-targets -- --deny warnings";
        }
      );

      synth-doc = craneLib.cargoDoc (
        commonArgs
        // {
          inherit cargoArtifacts;
        }
      );

      synth-fmt = craneLib.cargoFmt (
        commonArgs
        // {
          cargoExtraArgs = "--all";
        }
      );

      synth-nextest = craneLib.cargoNextest (
        commonArgs
        // {
          inherit cargoArtifacts;
          partitions = 1;
          partitionType = "count";
        }
      );
    };
  };
}
