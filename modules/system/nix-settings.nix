{ ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSy8="
    ];

    # Usuários confiáveis para usar caches adicionais
    trusted-users = [ "root" "daniel" ];
  };

  # Coleta de lixo automática semanal
  nix.gc = {
    automatic = true;
    dates     = "weekly";
    options   = "--delete-older-than 14d";
  };

  # Otimizar store automaticamente após builds
  nix.settings.auto-optimise-store = true;
}
