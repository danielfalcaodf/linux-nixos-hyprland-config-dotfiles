{ pkgs, lib, config, ... }:

# RustDesk — acesso remoto open-source
#
# Este módulo:
# 1. Instala o cliente RustDesk (para acessar outros PCs)
# 2. Sobe o servidor relay + rendezvous self-hosted (opcional)
#
# Para habilitar o servidor self-hosted (hbbs + hbbs):
#   services.rustdesk-server.enable = true;  (veja abaixo)
#
# RealVNC: NÃO configurado aqui. RustDesk é a alternativa open-source preferida.
# Documentação RealVNC disponível em: https://www.realvnc.com/en/connect/download/vnc/
{
  # ── Cliente RustDesk ───────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    rustdesk  # GUI para acessar e ser acessado remotamente
  ];

  # ── Servidor RustDesk self-hosted (relay + rendezvous) ────────────────────
  # Descomente para rodar o servidor na mesma máquina.
  # Clientes devem apontar para o IP desta máquina nas configurações do RustDesk.
  #
  # services.rustdesk-server = {
  #   enable    = true;
  #   relayIP   = "127.0.0.1"; # substitua pelo IP/hostname real da máquina
  #   openFirewall = false;     # gerenciado por modules/system/firewall.nix
  # };
  #
  # Se habilitar, adicione em modules/system/firewall.nix:
  #   allowedTCPPorts = [ 21115 21116 21117 21118 21119 ];
  #   allowedUDPPorts = [ 21116 ];
}
