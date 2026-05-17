{ pkgs, ... }:

{
  # Docker daemon
  virtualisation.docker = {
    enable = true;

    # Limpeza automática semanal de imagens/containers não usados
    autoPrune = {
      enable = true;
      dates  = "weekly";
      flags  = [ "--all" ];
    };

    # Configurações do daemon
    daemon.settings = {
      # Log compacto e com limite de tamanho
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };

  # Pacotes adicionais para trabalhar com Docker
  environment.systemPackages = with pkgs; [
    docker-compose   # docker compose v2
    lazydocker       # TUI para Docker
    dive             # inspecionar layers de imagens
    ctop             # top para containers
  ];
}
