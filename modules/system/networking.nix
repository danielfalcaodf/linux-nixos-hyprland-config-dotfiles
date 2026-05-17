{ ... }:

{
  # NetworkManager é a forma mais simples para desktop/workstation
  networking.networkmanager = {
    enable = true;
    # dnsmasq integrado: resolve *.devdaniel.home.arpa localmente
    # (configurado em modules/homelab/dns-local.nix)
    dns = "dnsmasq";
  };

  # IPv6: habilite se sua rede suportar
  networking.enableIPv6 = true;
}
