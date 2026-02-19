{lib, ...}: {
  perSystem = {
    config,
    pkgs,
    ...
  }: let
    inherit (config) craneLib;
    inherit (pkgs.llvmPackages_latest) clang bintools stdenv libcxx;
    inherit (pkgs) apple-sdk_15;

    mkFlags = flags: builtins.toString (map (x: "-C ${x}") flags);

    flags = [
      "linker=${clang}/bin/cc"
      "link-args=-fuse-ld=lld"
      "embed-bitcode=yes"
    ];

    inherit (craneLib.crateNameFromCargoToml {cargoToml = config.src + "/synth/Cargo.toml";}) pname version;

    mkCommonArgs = args @ {flags, ...}:
      {
        inherit pname version;
        src = craneLib.cleanCargoSource config.src;
        stdenv = _: stdenv;
        strictDeps = true;
        enableParallelBuilding = true;
        RUSTFLAGS = "-Zdylib-lto " + (mkFlags flags);

        buildInputs = [
          libcxx
        ];

        nativeBuildInputs = [
          clang
          bintools
          apple-sdk_15
        ];
      }
      // (builtins.removeAttrs args ["flags"]);
  in {
    options = {
      commonArgs = lib.mkOption {
        type = lib.types.attrs;
        default = mkCommonArgs {
          inherit flags;
          cargoProfile = "dev";
        };
      };

      commonArgsRelease = lib.mkOption {
        type = lib.types.attrs;

        default = mkCommonArgs {
          flags = flags ++ ["target-cpu=native"];
          NIX_ENFORCE_NO_NATIVE = 0;
          hardeningDisable = ["all"];
        };
      };
    };
  };
}
