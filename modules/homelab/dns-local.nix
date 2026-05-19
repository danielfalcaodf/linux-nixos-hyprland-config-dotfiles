{ ... }:

# DNS local via services.dnsmasq (módulo NixOS oficial).
#
# Resolve *.devdaniel.home.arpa → IP LAN do workstation (Caddy).
# Escuta em 127.0.0.1 (workstation) e no IP LAN (outros PCs da rede).
# Consultas externas encaminhadas para 1.1.1.1 / 8.8.8.8.
#
# O módulo dnsmasq com resolveLocalQueries = true (padrão) injeta
# 127.0.0.1 em /etc/resolv.conf automaticamente via resolvconf.
# NÃO é necessário alterar networking.networkmanager.dns.
#
# ─────────────────────────────────────────────────────────────────
# ⚠️  CONFIGURAÇÃO OBRIGATÓRIA ANTES DE ATIVAR
# ─────────────────────────────────────────────────────────────────
# 1. Altere workstationLanIP abaixo para o IP estático do workstation.
#    Descubra: ip route get 1.1.1.1 | grep src
#
# 2. Nos outros PCs da rede, aponte o DNS para o IP do workstation:
#    - Linux (NM): nmcli con mod <CONN> ipv4.dns "<IP>"
#    - Windows:    Painel → Adaptador → IPv4 → DNS: <IP>
#    - Router:     DHCP → DNS Server: <IP> (todos os clientes recebem automaticamente)
# ─────────────────────────────────────────────────────────────────

let
  workstationLanIP = "192.168.1.100";
in
{
  services.dnsmasq = {
    enable = true;
    settings = {
      listen-address = [ "127.0.0.1" workstationLanIP ];
      bind-interfaces = true;

      address = "/.devdaniel.home.arpa/${workstationLanIP}";

      server = [ "1.1.1.1" "8.8.8.8" ];

      domain-needed = true;
      bogus-priv    = true;
      cache-size    = 300;
    };
  };

  networking.firewall.allowedTCPPorts = [ 53 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
