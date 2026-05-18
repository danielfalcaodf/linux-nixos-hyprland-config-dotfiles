{ pkgs, ... }:

{
  # Definição do usuário principal
  users.users.devdaniel = {
    isNormalUser = true;
    description  = "Daniel";
    shell        = pkgs.fish;

    extraGroups = [
      "wheel"          # sudo
      "docker"         # Docker sem sudo
      "networkmanager" # gerenciar redes
      "audio"          # áudio
      "video"          # vídeo / câmera
      "input"          # dispositivos de entrada
    ];

    # Adicione suas chaves SSH públicas aqui (nunca chaves privadas!)
    # openssh.authorizedKeys.keys = [
    #   "ssh-ed25519 AAAA... daniel@outro-pc"
    # ];
  };

  # Fish shell habilitado no sistema
  programs.fish.enable = true;

  # Aumentar tamanho do runtime dir (útil para containers, Wayland, etc.)
  services.logind.settings.Login.RuntimeDirectorySize = "4G";
}
