{ supportedSystems ? [ "x86_64-linux" ] }:

with import <nixpkgs/pkgs/top-level/release-lib.nix> { inherit supportedSystems; };
with import <nixpkgs/lib>;

{

  # Minimal installer ISO
  iso = forMatchingSystems supportedSystems (system:
    hydraJob ((import <nixpkgs/nixos/lib/eval-config.nix> {
      inherit system;
      modules = [
        <nixpkgs/nixos/modules/installer/cd-dvd/iso-image.nix>
        ./configuration.nix
      ];
    }).config.system.build.isoImage));

  # A bootable VirtualBox virtual appliance as an OVA file (i.e. packaged OVF).
  ova = forMatchingSystems supportedSystems (system:
    hydraJob ((import <nixpkgs/nixos/lib/eval-config.nix> {
      inherit system;
      modules = [
        <nixpkgs/nixos/modules/virtualisation/virtualbox-image.nix>
        ./ova.nix
        ./configuration.nix
      ];
    }).config.system.build.virtualBoxOVA));

  sd = forMatchingSystems [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ] (system:
    hydraJob ((import <nixpkgs/nixos/lib/eval-config.nix> {
      inherit system;
      modules = [
        ({
          armv6l-linux = <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-raspberrypi.nix>;
          armv7l-linux = <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-armv7l-multiplatform.nix>
;
          aarch64-linux = <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>;
        }.${system})
        ./sd.nix
        ./configuration.nix
      ];
    }).config.system.build.sdImage));

}
