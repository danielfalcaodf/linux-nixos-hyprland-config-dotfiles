{
  description = "Daniel's NixOS — devdaniel homelab + workstation";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... } @ inputs:
  let
    system = "x86_64-linux";
  in
  {
    nixosConfigurations.devdaniel = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # ── Host ─────────────────────────────────────────────────────────
        ./hosts/devdaniel/configuration.nix

        # IMPORTANTE: copie seu hardware-configuration.nix real para este caminho
        # antes de executar nixos-rebuild. Este arquivo é ignorado pelo git.
        # Veja: hosts/devdaniel/hardware-configuration.nix.example
        ./hosts/devdaniel/hardware-configuration.nix

        # ── Sistema ───────────────────────────────────────────────────────
        ./modules/system/nix-settings.nix
        ./modules/system/users.nix
        ./modules/system/networking.nix
        ./modules/system/firewall.nix
        ./modules/system/ssh.nix

        # ── Desktop ───────────────────────────────────────────────────────
        ./modules/desktop/hyprland.nix
        ./modules/desktop/audio.nix
        ./modules/desktop/fonts.nix

        # ── Desenvolvimento ───────────────────────────────────────────────
        ./modules/dev/packages.nix

        # ── Homelab ───────────────────────────────────────────────────────
        ./modules/homelab/docker.nix
        ./modules/homelab/caddy.nix
        ./modules/homelab/dns-local.nix

        # ── Acesso Remoto ─────────────────────────────────────────────────
        ./modules/remote-access/rustdesk.nix
        ./modules/remote-access/xrdp-xfce.nix
        ./modules/remote-access/wayvnc.nix

        # ── Home Manager ──────────────────────────────────────────────────
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.daniel = import ./home/daniel.nix;
          home-manager.backupFileExtension = "bak";
        }
      ];
    };
  };
}
