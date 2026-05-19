{ ... }:

{
  # NetworkManager é a forma mais simples para desktop/workstation
  networking.networkmanager = {
    enable = true;
    # DNS gerenciado por services.dnsmasq (modules/homelab/dns-local.nix)
    # que escuta em 127.0.0.1 e no IP LAN para outros PCs da rede.
  };

  # IPv6: habilite se sua rede suportar
  networking.enableIPv6 = true;
}
