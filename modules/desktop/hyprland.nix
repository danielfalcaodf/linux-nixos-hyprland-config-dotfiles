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
  programs.hyprlock.enable  = true;
  services.hypridle.enable  = true;

  # XDG portal para Wayland (necessário para screenshare, file picker, etc.)
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "hyprland" "gtk" ];
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
    hyprpaper        # papel de parede
    hyprpicker       # color picker
    hyprcursor       # cursor themes
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
  ];
}
