{ pkgs, ... }:

# Bootloader: systemd-boot (EFI) com Plymouth para splash screen.
# ATENÇÃO: não altere boot.loader.* após a primeira instalação sem backups.
#
# Plymouth provê animação visual durante o boot. O tema catppuccin-macchiato
# é consistente com o tema do sistema. Não é o gerenciador de boot em si —
# apenas a tela de splash que aparece antes do login.
{
  # ── Configurações do bootloader ───────────────────────────────────────────
  # NOTA: boot.loader.systemd-boot.enable e boot.loader.efi.canTouchEfiVariables
  # são definidos em hosts/devdaniel/configuration.nix (específicos do hardware).

  boot.loader.timeout = 2;      # segundos para selecionar o sistema no menu

  # ── Kernel / initrd ───────────────────────────────────────────────────────
  boot.consoleLogLevel = 3;            # suprimir mensagens verbose do kernel
  boot.initrd.systemd.enable = true;   # systemd no initrd (mais rápido e confiável)

  # ── Plymouth — splash screen ──────────────────────────────────────────────
  boot.plymouth = {
    enable = true;
    font   = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
    themePackages = [ pkgs.catppuccin-plymouth ];
    theme  = "catppuccin-macchiato";
  };
}
