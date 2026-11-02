
{ config, pkgs, ... }:

{
  networking.hostName = "vpn";
  networking.useDHCP = true;

  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKFblMal3p6l4R+o/sRjWrh/NyuZeVYk21sn8uqodY0t tehnarenok@tehnarenoks-MacBook-Pro.local"
  ];

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 22 443 ];
  };

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
}
