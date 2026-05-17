{ pkgs, ... }:

{
  # ── Identificação do Host ──────────────────────────────────────────────────
  networking.hostName = "devdaniel";

  # ── Localização ───────────────────────────────────────────────────────────
  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "pt_BR.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "pt_BR.UTF-8";
    LC_IDENTIFICATION = "pt_BR.UTF-8";
    LC_MEASUREMENT    = "pt_BR.UTF-8";
    LC_MONETARY       = "pt_BR.UTF-8";
    LC_NAME           = "pt_BR.UTF-8";
    LC_NUMERIC        = "pt_BR.UTF-8";
    LC_PAPER          = "pt_BR.UTF-8";
    LC_TELEPHONE      = "pt_BR.UTF-8";
    LC_TIME           = "pt_BR.UTF-8";
  };

  # ── Teclado no console ────────────────────────────────────────────────────
  console.keyMap = "br-abnt2";

  # ── Bootloader ────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # ── X11 / Teclado gráfico ─────────────────────────────────────────────────
  services.xserver.xkb = {
    layout  = "br";
    variant = "abnt2";
  };

  # ── Pacotes globais mínimos ───────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
  ];

  # IMPORTANTE: não altere este valor após a primeira instalação.
  # Consulte: https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "25.05";
}
