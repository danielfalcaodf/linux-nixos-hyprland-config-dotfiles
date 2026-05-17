{ ... }:

# DNS local via dnsmasq integrado ao NetworkManager.
# Resolve *.devdaniel.home.arpa → 127.0.0.1 (Caddy).
# Consultas externas são encaminhadas para 1.1.1.1 / 8.8.8.8.
#
# NOTA: networking.networkmanager.dns = "dnsmasq" está em modules/system/networking.nix.
# Este módulo apenas adiciona as entradas customizadas.
{
  # Entradas DNS customizadas para o domínio local
  environment.etc."NetworkManager/dnsmasq.d/devdaniel.conf".text = ''
    # Todos os subdomínios de devdaniel.home.arpa apontam para o Caddy local
    address=/.devdaniel.home.arpa/127.0.0.1

    # Servidores upstream para domínios públicos
    server=1.1.1.1
    server=8.8.8.8

    # Não fazer lookup para domínios sem ponto (evita vazamento)
    domain-needed
    bogus-priv
  '';
}
