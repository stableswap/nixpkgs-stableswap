{ pkgs, rustNightly, rustStable }:
let
  darwinPackages = pkgs.lib.optionals pkgs.stdenv.isDarwin
    (with pkgs.darwin.apple_sdk.frameworks;
      ([ IOKit Security CoreFoundation AppKit ]
        ++ (pkgs.lib.optionals pkgs.stdenv.isAarch64 [ System ])));
  anchorPackages = import ./anchor {
    inherit (rustNightly) rustPlatform;
    inherit (pkgs) lib pkgconfig openssl libudev stdenv fetchFromGitHub;
    inherit darwinPackages;
  };
  mkSolana = args:
    (pkgs.callPackage ./solana.nix ({
      inherit (rustStable) rustPlatform;
      inherit (pkgs)
        lib pkgconfig libudev openssl zlib fetchFromGitHub stdenv protobuf
        rustfmt;
      inherit (pkgs.llvmPackages_12) clang llvm libclang;
      inherit darwinPackages;
    } // args));
in anchorPackages // {
  solana-full = mkSolana { };
  solana-cli = mkSolana { solanaPkgs = [ "solana" "solana-keygen" ]; };

  spl-token-cli = pkgs.callPackage ./spl-token-cli.nix {
    inherit (rustNightly) rustPlatform;
    inherit (pkgs)
      lib clang llvm pkgconfig libudev openssl zlib stdenv fetchCrate;
    inherit (pkgs.llvmPackages) libclang;
    inherit darwinPackages;
  };

  rust-nightly = rustNightly.rust;
  rust-stable = rustStable.rust;
}
