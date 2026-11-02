
{ config, pkgs, ... }:

{
  networking.hostName = "vpn";
  networking.useDHCP = true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 YOUR_PUBLIC_SSH_KEY"
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
