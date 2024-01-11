{
  description = "The official LabJack UD Linux and Mac OS X USB driver";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    exodriver = {
      url = "github:labjack/exodriver/v2.7.0";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, exodriver }: let
    version = "2.7.0";
    supportedSystems = [ "x86_64-linux" ];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlays.default ]; });
  in {
    overlays.default = final: prev: {
      exodriver = with final; stdenv.mkDerivation rec {
        pname = "exodriver";
        inherit version;
        src = exodriver;
        buildInputs = [ libusb1 ];
        buildPhase = ''
          cd liblabjackusb
          make clean
          make
          cd ..
        '';
        installPhase = ''
          cd liblabjackusb
          RUN_LDCONFIG=0 LINK_SO=1 PREFIX=$out make install
          cd ..

          mkdir -p $out/lib/pkgconfig
          cat <<EOF > $out/lib/pkgconfig/liblabjackusb.pc
          Name: liblabjackusb
          Description: LabJack USB Library
          Version: ${version}
          Libs: -L$out/lib -llabjackusb
          Cflags: -I$out/include
          EOF

          mkdir -p $out/lib/udev/rules.d
          cp 90-labjack.rules $out/lib/udev/rules.d
        '';
      };
    };
    packages = forAllSystems (system: {
      inherit (nixpkgsFor.${system}) exodriver;
      default = self.packages.${system}.exodriver;
    });
    nixosModules.exodriver = { pkgs, ... }: {
      nixpkgs.overlays = [ self.overlays.default ];
      environment.systemPackages = [ pkgs.exodriver ];
      services.udev.packages = [ pkgs.exodriver ];
      pkgConfigModules = [ "liblabjackusb" ];
    };
    checks = forAllSystems (system: with nixpkgsFor.${system}; rec {
      inherit (self.packages.${system}) exodriver;
      test = stdenv.mkDerivation {
        pname = "check-exodriver";
        inherit version;
        src = ./.;
        buildInputs = [ exodriver pkg-config ];
        buildPhase = ''
          gcc $(pkg-config --cflags --libs liblabjackusb) test.c -o test
          ./test
        '';
        installPhase = ''
          mkdir -p $out
        '';
      };
    });
    devShell = forAllSystems (system: nixpkgsFor.${system}.mkShell (let
      exodriver = self.packages.${system}.exodriver;
    in rec {
      buildInputs = [ exodriver ];
    }));
  };
}
