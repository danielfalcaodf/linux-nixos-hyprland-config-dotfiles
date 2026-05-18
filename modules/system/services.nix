{ pkgs, ... }:

# Serviços e programas de desktop de uso geral.
# Inclui gestão de configurações (dconf/xfconf), gerenciador de arquivos,
# firmware updates e ferramentas multimídia.
{
  # ── Desktop integration ───────────────────────────────────────────────────
  programs.dconf.enable  = true;   # necessário para GTK4 e GNOME settings
  programs.thunar.enable = true;   # gerenciador de arquivos
  programs.xfconf.enable = true;   # backend de configuração do Thunar/XFCE

  # Thumbnails e pré-visualizações no Thunar
  services.tumbler.enable = true;

  # ── Firmware updates ──────────────────────────────────────────────────────
  services.fwupd.enable = true;    # atualização de firmware via LVFS/fwupd

  # ── Multimídia e utilitários ──────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Reprodução de mídia
    mpv                # player de vídeo/áudio leve e poderoso
    ffmpeg             # processamento de áudio/vídeo no terminal
    yt-dlp             # download de vídeos (também em dev/packages.nix para CLI devs)

    # Controle de reprodução (MPRIS)
    playerctl          # controle de media players via linha de comando

    # Manipulação de imagens
    imagemagick        # conversão e manipulação de imagens no terminal

    # Interface
    avizo              # OSD (on-screen display) para volume e brilho no Wayland
  ];
}
