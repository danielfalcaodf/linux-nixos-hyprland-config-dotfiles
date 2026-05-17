{ ... }:

{
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      22   # SSH
      80   # HTTP  → Caddy (redireciona para HTTPS)
      443  # HTTPS → Caddy (reverse proxy dos apps)
    ];

    # Portas abertas apenas se os módulos opcionais estiverem habilitados:
    # 3389  — XRDP   (habilitar em modules/remote-access/xrdp-xfce.nix)
    # 5900  — WayVNC (habilitar em modules/remote-access/wayvnc.nix)
    # 21115-21117, 21119 — RustDesk (habilitar em modules/remote-access/rustdesk.nix)

    # Bloquear acesso externo às portas de bancos de dados e serviços internos.
    # Todos os serviços internos são acessados via Caddy reverse proxy.
    allowedUDPPorts = [];
  };
}
