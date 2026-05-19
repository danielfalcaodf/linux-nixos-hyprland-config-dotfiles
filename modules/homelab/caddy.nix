{ pkgs, ... }:

# Caddy como reverse proxy local com TLS interno auto-assinado.
# Todos os serviços ficam em *.devdaniel.home.arpa com HTTPS.
#
# ── Certificado CA local ───────────────────────────────────────────────────
# O Caddy gera uma CA interna em:
#   /var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt
#
# Um serviço systemd copia esse arquivo para /etc/caddy/local-root-ca.crt
# (acessível via HTTP em http://<IP-LAN>:8888/ca.crt para fácil distribuição).
#
# Para instalar o CA nos clientes, veja a seção "DNS local e CA do Caddy" no INSTALL.md.
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

    # ── Distribuição do CA cert (HTTP, sem TLS) ────────────────────────────
    # Acessível em http://<IP-LAN>:8888/ca.crt para outros PCs instalarem.
    virtualHosts.":8888" = {
      extraConfig = ''
        root * /etc/caddy
        file_server
        header Content-Disposition "attachment; filename=caddy-local-ca.crt"
      '';
    };
  };

  # Copia o CA cert gerado pelo Caddy para /etc/caddy/ca.crt (readable por todos)
  # Executa após o Caddy iniciar e sempre que reiniciar.
  systemd.services.caddy-export-ca = {
    description    = "Exporta CA do Caddy para /etc/caddy/ca.crt";
    after          = [ "caddy.service" ];
    wantedBy       = [ "multi-user.target" ];
    serviceConfig = {
      Type            = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "caddy-export-ca" ''
        CA_SRC="/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt"
        CA_DST="/etc/caddy/ca.crt"
        for i in $(seq 1 10); do
          if [ -f "$CA_SRC" ]; then
            mkdir -p /etc/caddy
            cp "$CA_SRC" "$CA_DST"
            chmod 644 "$CA_DST"
            echo "CA exportado para $CA_DST"
            exit 0
          fi
          sleep 3
        done
        echo "CA do Caddy ainda não existe — rode novamente após o Caddy inicializar."
        exit 1
      '';
    };
  };

  # Caddy: 80, 443 (Firewall em modules/system/firewall.nix)
  # Distribuição do CA: 8888 (HTTP, sem HTTPS)
  networking.firewall.allowedTCPPorts = [ 8888 ];
}
