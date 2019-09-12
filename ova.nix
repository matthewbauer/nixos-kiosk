{ lib, ... }:

with lib;

{
  # FIXME: UUID detection is currently broken
  boot.loader.grub.fsIdentifier = "provided";

  # Allow mounting of shared folders.
  users.users.demo.extraGroups = [ "vboxsf" ];

  # Add some more video drivers to give X11 a shot at working in
  # VMware and QEMU.
  services.xserver.videoDrivers = mkOverride 40 [ "virtualbox" "vmware" "cirrus" "vesa" "modesetting" ];

  powerManagement.enable = lib.mkForce false;

  hardware.pulseaudio.systemWide = true; # Needed since we run plasma as root.

}
