{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (pkgs) dockerTools;
    inherit (config.packages) synth;
    inherit (pkgs.stdenv) isLinux;
  in {
    packages = lib.optionalAttrs isLinux {
      docker = dockerTools.buildLayeredImage {
        name = "synth";
        tag = "latest";

        contents = [
          synth
          dockerTools.caCertificates
        ];

        config = {
          Entrypoint = ["${synth}/bin/synth"];
        };
      };

      docker-debug = let
        inherit (config.packages) synth-dev;
      in
        dockerTools.buildLayeredImage {
          name = "synth-debug";
          tag = "latest";

          contents = [
            synth-dev
            dockerTools.caCertificates
            pkgs.bashInteractive
            pkgs.coreutils
          ];

          config = {
            Entrypoint = ["${synth-dev}/bin/synth"];
          };
        };
    };
  };
}
