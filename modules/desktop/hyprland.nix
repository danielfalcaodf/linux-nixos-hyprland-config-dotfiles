{ pkgs, ... }:

{
  # Hyprland com UWSM (Universal Wayland Session Manager) para melhor integração
  programs.hyprland = {
    enable    = true;
    withUWSM  = true;
  };

  # Variáveis de sessão Wayland
  environment.sessionVariables = {
    NIXOS_OZONE_WL    = "1"; # Electron apps usam Wayland
    WLR_NO_HARDWARE_CURSORS = "1"; # Evita bug de cursor em VMs/remote
    XDG_SESSION_TYPE  = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
  };

  # Componentes Hyprland
  # NOTA: programs.hyprlock.enable = true já ativa services.hypridle automaticamente.
  # A linha abaixo é redundante mas explícita para documentação de intenção.
  programs.hyprlock.enable = true;
  # services.hypridle.enable = true;  # auto-ativado por programs.hyprlock.enable

  # XDG portal para Wayland (necessário para screenshare, file picker, etc.)
  # NOTA: xdg-desktop-portal-hyprland já é adicionado automaticamente por
  # programs.hyprland.enable (via cfg.portalPackage). Apenas gtk é necessário aqui.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default  = [ "hyprland" "gtk" ];
      hyprland.default = [ "hyprland" "gtk" ];
    };
  };

  # Display manager: greetd + tuigreet (leve, sem GNOME)
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd 'uwsm start hyprland-uwsm.desktop'";
      user    = "greeter";
    };
  };

  environment.systemPackages = with pkgs; [
    # Utilitários Hyprland
    pyprland         # plugin manager Hyprland
    hyprpaper        # papel de parede
    hyprpicker       # color picker
    hyprcursor       # cursor themes
    # hyprlock e hypridle NÃO listados aqui: já adicionados por programs.hyprlock.enable
    hyprpolkitagent  # polkit para Hyprland
    hyprsunset       # night light

    # Bar / notificações / launcher
    waybar
    dunst
    rofi-wayland

    # Capturas de tela e gravação
    grim
    slurp
    wf-recorder

    # Clipboard e utilitários Wayland
    wl-clipboard
    cliphist

    # Arquivos e tema
    yazi
    thunar
    xfce.thunar-volman

    # Terminal alternativo (estilo retrô)
    cool-retro-term
  ];
}
