{
  imports = [
    ./rust-toolchain.nix
    ./crane-lib.nix
    ./args.nix
    ./artifacts.nix
    ./docker.nix
  ];

  perSystem = {config, ...}: let
    inherit (config) craneLib commonArgs commonArgsRelease cargoArtifacts cargoArtifactsRelease;
  in {
    packages = {
      synth-dev = craneLib.buildPackage (commonArgs
        // {
          inherit cargoArtifacts;
        });

      synth = craneLib.buildPackage (commonArgsRelease
        // {
          cargoArtifacts = cargoArtifactsRelease;
        });
    };
  };
}
