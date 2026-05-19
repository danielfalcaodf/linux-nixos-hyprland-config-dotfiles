{ lib, ... }:

# DNS local via dnsmasq standalone (services.dnsmasq).
#
# Resolve *.devdaniel.home.arpa → IP LAN do workstation (Caddy).
# Escuta em 127.0.0.1 (workstation) e no IP LAN (outros PCs da rede).
# Consultas externas encaminhadas para 1.1.1.1 / 8.8.8.8.
#
# ─────────────────────────────────────────────────────────────────
# ⚠️  CONFIGURAÇÃO OBRIGATÓRIA ANTES DE ATIVAR
# ─────────────────────────────────────────────────────────────────
# 1. Defina um IP estático para o workstation (recomendado para homelab):
#      networking.interfaces.<INTERFACE>.ipv4.addresses = [{
#        address      = "192.168.1.100";
#        prefixLength = 24;
#      }];
#    Descubra a interface: ip route | grep default
#
# 2. Altere workstationLanIP abaixo para o IP estático escolhido.
#
# 3. Nos outros PCs da rede, configure DNS para o IP do workstation:
#    - Linux (NM): nmcli con mod <CONN> ipv4.dns "192.168.1.100"
#    - Windows:    Painel de Controle → Adaptador → DNS: 192.168.1.100
#    - Router:     Configure "DNS Server" no DHCP do roteador para o IP do workstation
#                  (todos os novos clientes receberão o DNS automaticamente)
# ─────────────────────────────────────────────────────────────────

let
  # ⬇ ALTERE AQUI para o IP estático LAN do workstation
  workstationLanIP = "192.168.1.100";
in
{
  # Desativa dnsmasq interno do NetworkManager para evitar conflito de porta 53
  networking.networkmanager.dns = lib.mkForce "none";

  # O workstation usa seu próprio dnsmasq como resolver
  networking.nameservers = [ "127.0.0.1" "1.1.1.1" ];

  services.dnsmasq = {
    enable = true;
    settings = {
      # Escuta em loopback (workstation) + IP LAN (outros PCs)
      listen-address = [ "127.0.0.1" workstationLanIP ];
      bind-interfaces = true;

      # *.devdaniel.home.arpa → IP LAN do workstation (onde o Caddy escuta)
      address = "/.devdaniel.home.arpa/${workstationLanIP}";

      # Upstream DNS para domínios públicos
      server = [ "1.1.1.1" "8.8.8.8" ];

      # Segurança: não encaminha domínios sem ponto; bloqueia reverse lookup de IPs privados
      domain-needed = true;
      bogus-priv    = true;

      # Cache de 300 entradas (melhora performance)
      cache-size = 300;
    };
  };

  # Porta 53 aberta para a rede local (necessário para outros PCs consultarem este DNS)
  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
