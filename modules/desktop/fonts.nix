{ pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;

    packages = with pkgs; [
      # Nerd Fonts (ícones em terminais / bar)
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
      nerd-fonts.hack
      nerd-fonts.symbols-only

      # Fontes de desenvolvimento
      jetbrains-mono

      # Fontes de UI
      inter
      roboto
      source-han-sans   # CJK (Chinês, Japonês, Coreano)
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji

      # Fontes de código legacy
      fira-code

      # Emoji
      noto-fonts-color-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif      = [ "Noto Serif" ];
        sansSerif  = [ "Inter" "Noto Sans" ];
        monospace  = [ "JetBrainsMono Nerd Font" ];
        emoji      = [ "Noto Color Emoji" ];
      };
    };
  };
}
