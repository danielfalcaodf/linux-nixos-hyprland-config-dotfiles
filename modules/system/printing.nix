{ ... }:

# Impressão via CUPS.
# Para impressoras de rede, habilite também avahi (mDNS).
{
  services.printing.enable = true;

  # Para descoberta automática de impressoras de rede, descomente:
  # services.avahi = {
  #   enable    = true;
  #   nssmdns4  = true;
  #   openFirewall = true;
  # };
}
