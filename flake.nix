{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/release-21.11";
  inputs.unstable.url = "github:nixos/nixpkgs/master";
  outputs = { nixpkgs, ... } @ inputs:
    let
      supportedSystems = [ "x86_64-linux" "x86_64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      devEnv = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
        in
          pkgs.buildEnv {
            name = "devenv";
            paths = with pkgs; [
              hello
              babashka
              (python3.withPackages (ps: with ps; [numpy]))
            ];
          }
      );
      devShells = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          unstable = import inputs.unstable { inherit system; };
        in
        {
          release = pkgs.mkShell {
            packages = with pkgs;[
              babashka
            ];
          };
          unstable = pkgs.mkShell {
            packages = with unstable; [
              babashka
            ];
          };
          custom = let pkgs = unstable; in
            pkgs.mkShell {
              packages = [
                (pkgs.babashka.overrideAttrs (old:
                  let
                    version = "0.7.2";
                  in
                  rec {
                    inherit version;
                    src = pkgs.fetchurl {
                      url = "https://github.com/babashka/babashka/releases/download/v${version}/babashka-${version}-standalone.jar";
                      sha256 = "sha256-e3/tRSszjLt/lt23ofQz9l5fqJRbshboPvX2bo/qMmI=";
                    };
                    jar = src;
                    nativeImageBuildArgs = [
                      "-jar"
                      jar
                      "-H:CLibraryPath=${pkgs.lib.getLib pkgs.graalvmCEPackages.graalvm11-ce}/lib"
                      #"-H:CLibraryPath=${pkgs.lib.getLib old.graalvm}/lib"
                      (pkgs.lib.optionalString pkgs.stdenv.isDarwin "-H:-CheckToolchain")
                      "-H:Name=${old.executable}"
                      "--verbose"
                    ];
                  }))
              ];
            };
        }
      );
    };
}
