
{
  description = "Xray VPN image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    sops-nix.url = "github:Mic92/sops-nix/a8627b21b910";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, sops-nix, ... }: {
    nixosConfigurations.vpn = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./configuration.nix
        sops-nix.nixosModules.sops
      ];
    };
  };
}
