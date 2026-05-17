{ pkgs, lib, config, ... }:

# WayVNC — servidor VNC nativo para Wayland/Hyprland
#
# Permite acesso remoto à sessão Hyprland existente via protocolo VNC.
# Clientes compatíveis: Remmina, TigerVNC, RealVNC Viewer, TurboVNC.
#
# IMPORTANTE: WayVNC acessa a sessão Wayland do usuário.
# Deve ser iniciado APÓS o Hyprland estar rodando.
#
# Para iniciar manualmente:
#   wayvnc 127.0.0.1 5900        (apenas local, via túnel SSH)
#   wayvnc 0.0.0.0 5900          (rede local — abra porta no firewall)
#
# Acesso seguro recomendado via túnel SSH:
#   ssh -L 5900:127.0.0.1:5900 daniel@devdaniel.local
#   # depois conecte o cliente VNC em 127.0.0.1:5900
{
  options.homelab.wayvnc.enable = lib.mkEnableOption "WayVNC (VNC Wayland)";

  config = lib.mkIf config.homelab.wayvnc.enable {

    environment.systemPackages = with pkgs; [
      wayvnc
      remmina  # cliente VNC/RDP para acessar outros PCs
    ];

    # Serviço systemd de usuário para iniciar WayVNC automaticamente
    # após a sessão Hyprland subir.
    # O serviço é definido por usuário — cada usuário pode habilitar:
    #   systemctl --user enable --now wayvnc.service
    systemd.user.services.wayvnc = {
      description = "WayVNC Wayland VNC Server";
      after       = [ "graphical-session.target" ];
      wants       = [ "graphical-session.target" ];
      partOf      = [ "graphical-session.target" ];

      serviceConfig = {
        # Bind apenas em localhost por padrão (acesse via túnel SSH)
        ExecStart = "${pkgs.wayvnc}/bin/wayvnc 127.0.0.1 5900";
        Restart   = "on-failure";
        RestartSec = "5s";
      };
    };

    # Para expor na rede local (menos seguro), adicione em firewall.nix:
    #   networking.firewall.allowedTCPPorts = [ 5900 ];
  };
}
