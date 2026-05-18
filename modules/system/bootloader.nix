{ pkgs, ... }:

# Bootloader: systemd-boot (EFI) com Plymouth para splash screen.
# ATENÇÃO: não altere boot.loader.* após a primeira instalação sem backups.
#
# Plymouth provê animação visual durante o boot. O tema catppuccin-macchiato
# é consistente com o tema do sistema.
#
# ── VM vs Bare-metal ─────────────────────────────────────────────────────────
# Esta branch (feat/vm-compat) tem Plymouth e initrd.systemd DESATIVADOS para
# compatibilidade com VMs (sem suporte KMS/DRM).
# Para bare-metal, use a branch feat/devdaniel-nixos-config que os habilita.
{
  # ── Configurações do bootloader ───────────────────────────────────────────
  boot.loader.timeout = 2;

  # ── Kernel / initrd ───────────────────────────────────────────────────────
  boot.consoleLogLevel = 3;
  # boot.initrd.systemd.enable desativado — causa travamento em VM sem KMS

  # ── Plymouth desativado (VM sem suporte KMS/DRM) ──────────────────────────
  boot.plymouth.enable = false;
}
