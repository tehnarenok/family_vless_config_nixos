
{ lib, config, pkgs, ... }:

{
  networking.hostName = "vpn";

  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  boot.initrd.availableKernelModules = [
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    "virtiofs"
  ];

  boot.kernelParams = [
    "console=tty0"
    "console=ttyS0,115200n8"
  ];

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFblMal3p6l4R+o/sRjWrh/NyuZeVYk21sn8uqodY0t tehnarenok@tehnarenoks-MacBook-Pro.local"
  ];

  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

  sops.secrets.xray = {
    sopsFile = ./secrets/xray.json;
    format = "json";
    key = "";
    mode = "0400";
  };

  services.xray = {
    enable = true;
    package = import ./xray.nix { inherit pkgs; };
    settingsFile = config.sops.secrets.xray.path;
  };

  systemd.services.xray = {
    requires = [ "sops-nix.service" ];
    after = [ "sops-nix.service" ];
  };

  system.stateVersion = "25.11";

  systemd.services."serial-getty@ttyS0".enable = true;

  networking.useDHCP = lib.mkDefault true;

  services.cloud-init = {
    enable = true;

    settings = {
      datasource_list = [ "Ec2" ];

      datasource = {
        Ec2 = {
          strict_id = false;
        };
      };
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 443 ];
  };
}
