{ ... }:

# Caddy como reverse proxy local com TLS interno auto-assinado.
# Todos os serviços ficam em *.devdaniel.home.arpa com HTTPS.
#
# Após o primeiro `nixos-rebuild switch`, instale o certificado CA local:
#   sudo cp /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt \
#           /usr/local/share/ca-certificates/caddy-local.crt
#   sudo update-ca-certificates
# Ou importe diretamente no seu navegador (root.crt).
{
  services.caddy = {
    enable = true;

    # ── Portainer ──────────────────────────────────────────────────────────
    virtualHosts."portainer.devdaniel.home.arpa" = {
      extraConfig = ''
        tls internal
        reverse_proxy 127.0.0.1:9000
      '';
    };

    # ── n8n ────────────────────────────────────────────────────────────────
    virtualHosts."n8n.devdaniel.home.arpa" = {
      extraConfig = ''
        tls internal
        reverse_proxy 127.0.0.1:5678
      '';
    };

    # ── Uptime Kuma ────────────────────────────────────────────────────────
    virtualHosts."uptime.devdaniel.home.arpa" = {
      extraConfig = ''
        tls internal
        reverse_proxy 127.0.0.1:3001
      '';
    };

    # ── Grafana ────────────────────────────────────────────────────────────
    virtualHosts."grafana.devdaniel.home.arpa" = {
      extraConfig = ''
        tls internal
        reverse_proxy 127.0.0.1:3000
      '';
    };

    # ── Homepage / Homarr (dashboard) ──────────────────────────────────────
    virtualHosts."home.devdaniel.home.arpa" = {
      extraConfig = ''
        tls internal
        reverse_proxy 127.0.0.1:3100
      '';
    };

    # ── Adminer (DB GUI) ───────────────────────────────────────────────────
    virtualHosts."adminer.devdaniel.home.arpa" = {
      extraConfig = ''
        tls internal
        reverse_proxy 127.0.0.1:8080
      '';
    };
  };

  # Caddy precisa de porta 80 e 443. Abertas em modules/system/firewall.nix.
  # A porta 2019 (admin API) NÃO é exposta externamente.
}
