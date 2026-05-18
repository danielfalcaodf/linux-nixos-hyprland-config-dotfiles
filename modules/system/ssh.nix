{ ... }:

{
  services.openssh = {
    enable = true;

    ports = [ 22 ];

    settings = {
      # Nunca permitir login por senha
      PasswordAuthentication       = false;
      KbdInteractiveAuthentication = false;

      # Nunca permitir login como root
      PermitRootLogin = "no";

      # Apenas usuários explicitamente listados podem conectar
      AllowUsers = [ "devdaniel" ];

      # Hardening adicional
      X11Forwarding = false;
    };
  };
}
