{ ... }:

# VirtualBox Guest Additions — necessário para evitar trava de boot na VM.
#
# Sem este módulo, o kernel tenta enumerar devices gráficos (DRM/KMS) que
# não existem no VirtualBox, travando em "create static device nodes" /
# "coldplug" durante o boot.
#
# Este módulo é importado APENAS na branch feat/vm-compat (não no bare-metal).
{
  # Habilita Guest Additions: instala módulos do kernel vboxguest, vboxvideo,
  # vboxsf e o serviço de integração com o host.
  virtualisation.virtualbox.guest = {
    enable = true;
    # dragAndDrop: compartilhar arquivos via drag-and-drop entre host e VM
    dragAndDrop = true;
  };

  # Carregar os módulos no initrd para resolver o travamento antes do udev
  boot.initrd.kernelModules = [
    "vboxguest"   # módulo core (comunicação host-guest)
    "vboxvideo"   # driver de vídeo VBoxSVGA/VBoxVGA (evita trava KMS)
  ];

  # Aumentar log de kernel para facilitar diagnóstico em VM (opcional)
  # boot.consoleLogLevel = 7;  # descomente se precisar de mais detalhes no boot
}
