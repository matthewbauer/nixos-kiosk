{ pkgs, lib, ... }:

{

  imports = [ <nixpkgs/nixos/modules/profiles/all-hardware.nix> ];

  boot.kernelParams = [ "quiet" ];
  boot.loader.timeout = lib.mkForce 0;
  boot.plymouth.enable = true;

  services.dbus.enable = true;

  environment.systemPackages = [ pkgs.hicolor-icon-theme ];

  fonts.enableDefaultFonts = true;
  xdg.icons.enable = true;
  gtk.iconCache.enable = true;

  # Shrink closure
  # nixpkgs.overlays = [(self: super: {
  #   wlroots = super.wlroots.override { freerdpEnabled = false; };
  # })];
  services.udisks2.enable = false;

  hardware.opengl.enable = true;
  # hardware.opengl.package = (pkgs.mesa.override {
  #   galliumNine = false;
  # }).drivers;
  hardware.enableRedistributableFirmware = true;

  systemd.services."cage@" = {
    enable = true;
    after = [ "systemd-user-sessions.service" "dbus.socket" "systemd-logind.service" "getty@%i.service" "plymouth-deactivate.service" "plymouth-quit.service" ];
    before = [ "graphical.target" ];
    wants = [ "dbus.socket" "systemd-logind.service" "plymouth-deactivate.service" ];
    wantedBy = [ "graphical.target" ];
    conflicts = [ "getty@%i.service" ]; # "plymouth-quit.service" "plymouth-quit-wait.service"

    restartIfChanged = false;
    serviceConfig = {
      ExecStart = "${pkgs.cage}/bin/cage -d -- ${pkgs.epiphany}/bin/epiphany";
      User = "demo";

      # ConditionPathExists = "/dev/tty0";
      IgnoreSIGPIPE = "no";

      # Log this user with utmp, letting it show up with commands 'w' and
      # 'who'. This is needed since we replace (a)getty.
      UtmpIdentifier = "%I";
      UtmpMode = "user";
      # A virtual terminal is needed.
      TTYPath = "/dev/%I";
      TTYReset = "yes";
      TTYVHangup = "yes";
      TTYVTDisallocate = "yes";
      # Fail to start if not controlling the virtual terminal.
      StandardInput = "tty-fail";
      StandardOutput = "syslog";
      StandardError = "syslog";
      # Set up a full (custom) user session for the user, required by Cage.
      PAMName = "cage";
    };
  };

  security.pam.services.cage.text = ''
    auth    required pam_unix.so nullok
    account required pam_unix.so
    session required pam_unix.so
    session required ${pkgs.systemd}/lib/security/pam_systemd.so
  '';

  systemd.targets.graphical.wants = [ "cage@tty1.service" ];

  systemd.defaultUnit = "graphical.target";

  users.users.demo = {
    isNormalUser = true;
    description = "Demo user account";
    extraGroups = [ "wheel" ];
    password = "demo";
    uid = 1000;
  };

  # Whitelist wheel users to do anything
  # This is useful for things like pkexec
  #
  # WARNING: this is dangerous for systems
  # outside the installation-cd and shouldn't
  # be used anywhere else.
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (subject.isInGroup("wheel")) {
        return polkit.Result.YES;
      }
    });
  '';

  security.sudo = {
    enable = true;
    wheelNeedsPassword = false;
  };

}
