{ pkgs, ... }:

{
  # PipeWire — servidor de áudio moderno para Wayland/Hyprland
  services.pulseaudio.enable = false;  # PulseAudio desabilitado; usar PipeWire

  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;
    pulse.enable      = true;
    jack.enable       = false; # habilite se precisar de JACK

    wireplumber.enable = true;
  };

  # RTKit para prioridade de tempo-real no áudio
  security.rtkit.enable = true;

  # Bluetooth com suporte a áudio
  hardware.bluetooth = {
    enable      = true;
    powerOnBoot = false; # ligue manualmente quando necessário
    settings.General.Enable = "Source,Sink,Media,Socket";
  };

  services.blueman.enable = true;

  # Pacotes de controle de áudio e Bluetooth
  environment.systemPackages = with pkgs; [
    pamixer      # controle de volume no terminal
    pavucontrol  # GUI PulseAudio/PipeWire
    overskride   # GUI Bluetooth moderna (GTK4)
  ];
}
