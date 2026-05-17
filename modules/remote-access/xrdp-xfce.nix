{ pkgs, lib, config, ... }:

# XRDP + XFCE — acesso remoto gráfico como fallback
#
# Desabilitado por padrão. Para habilitar, adicione em hosts/devdaniel/configuration.nix:
#   homelab.xrdp.enable = true;
#
# Alternativa open-source ao RealVNC. Usa protocolo RDP (suportado por:
# Remmina, Windows Remote Desktop, FreeRDP, e muitos outros clientes).
{
  options.homelab.xrdp.enable = lib.mkEnableOption "XRDP + XFCE (acesso remoto RDP)";

  config = lib.mkIf config.homelab.xrdp.enable {

    services.xrdp = {
      enable             = true;
      openFirewall       = false;  # gerenciado por modules/system/firewall.nix
      # XFCE como desktop para sessões RDP (leve e estável)
      defaultWindowManager = "${pkgs.xfce.xfce4-session}/bin/xfce4-session";
    };

    # Habilitar XFCE para as sessões XRDP
    services.xserver = {
      enable = true;
      desktopManager.xfce.enable = true;
    };

    # Pacotes necessários para a sessão XFCE via XRDP
    environment.systemPackages = with pkgs; [
      xfce.xfce4-terminal
      xfce.thunar
      xfce.xfce4-taskmanager
    ];

    # Abrir porta RDP no firewall
    networking.firewall.allowedTCPPorts = [ 3389 ];

    # Remmina instalado para acessar outros PCs via RDP/VNC
    # environment.systemPackages = [ pkgs.remmina ];
  };
}
