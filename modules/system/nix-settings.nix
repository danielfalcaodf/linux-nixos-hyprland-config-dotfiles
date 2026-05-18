{ ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];

    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
      "https://numtide.cachix.org"
      "https://devenv.cachix.org"
    ];

    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSy8="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
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

  # Otimizar store automaticamente após builds e de forma programada
  nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;
}
