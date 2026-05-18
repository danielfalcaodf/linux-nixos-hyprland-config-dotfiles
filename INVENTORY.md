# Inventário da Configuração Original — Branch `main`

> **Origem:** fork do repositório xnm. **Host:** `isitreal-laptop`. **Usuário:** `xnm`.  
> Gerado a partir de uma leitura completa de todos os módulos NixOS e dotfiles do branch `main`.

---

## Índice

- [🖥️ Sistema Base](#️-sistema-base)
- [🔒 Segurança](#-segurança)
- [🌐 Rede & SSH](#-rede--ssh)
- [🎨 Desktop & Hyprland](#-desktop--hyprland)
  - [Serviços e pacotes do Hyprland](#serviços-e-pacotes-do-hyprland)
  - [Atalhos de teclado](#atalhos-de-teclado-tabela-completa)
  - [Windowrules](#windowrules)
  - [Exec-once (autostart)](#exec-once-autostart)
- [🔊 Áudio & Bluetooth](#-áudio--bluetooth)
- [🖋️ Fontes](#️-fontes)
- [⌨️ Terminal & Shell](#️-terminal--shell)
  - [Fish](#fish-aliases-funções-plugins)
  - [Kitty](#kitty)
  - [WezTerm](#wezterm)
  - [Zellij](#zellij)
- [🧑‍💻 Desenvolvimento](#-desenvolvimento)
  - [Ferramentas CLI](#ferramentas-cli)
  - [LSP / Editores](#lsp--editores)
  - [Linguagens](#linguagens)
  - [Rust](#rust)
  - [WASM](#wasm)
- [🤖 LLM / IA](#-llm--ia)
- [🖥️ GPU (NVIDIA)](#️-gpu-nvidia)
- [💾 Virtualização](#-virtualização)
- [🔧 Hardware Específico](#-hardware-específico)
  - [YubiKey](#yubikey)
  - [Leitor de Impressão Digital](#leitor-de-impressão-digital)
  - [USB](#usb)
- [📊 Waybar](#-waybar)
- [🚀 Rofi](#-rofi)
- [🔔 Dunst](#-dunst)
- [🗂️ Pyprland (scratchpads)](#️-pyprland-scratchpads)
- [🎯 Apps de Usuário](#-apps-de-usuário)
- [🎨 Tema Catppuccin](#-tema-catppuccin-onde-é-aplicado)
- [❌ Módulos desabilitados](#-módulos-desabilitados-comentados-no-flakenix)
- [📋 Resumo Executivo](#-resumo-executivo)

---

## 🖥️ Sistema Base

| Módulo | Arquivo | Resumo | Configurações-chave |
|--------|---------|--------|---------------------|
| Sistema | `configuration.nix` | Ponto de entrada base | `system.stateVersion = "your_version_here"` (placeholder) |
| Flake | `flake.nix` | Orquestrador de módulos | NixOS unstable; host `isitreal-laptop`; inputs: nixpkgs, rust-overlay, wezterm, nix-ai-tools |
| Kernel | `linux-kernel.nix` | Kernel e parâmetros de boot | `linux_zen`; PTI forçado; unprivilegedUsernsClone; LSM: landlock,lockdown,yama,integrity,apparmor,bpf |
| Bootloader | `bootloader.nix` | systemd-boot + Plymouth | timeout=2; Plymouth com tema `catppuccin-macchiato`; font JetBrains Mono; initrd systemd |
| Swap | `swap.nix` | zram swap | `zramSwap.enable = true` |
| Hora | `time.nix` | Fuso horário | `Europe/Kyiv`; `hardwareClockInLocalTime = true` |
| Localização | `internationalisation.nix` | Locale e dicionários | `en_US.UTF-8` padrão; suporte uk_UA, ru_RU; hunspell para EN/UK/RU |
| Nix settings | `nix-settings.nix` | Configurações do daemon Nix | flakes + nix-command; substituters: cache.nixos.org, numtide.cachix.org, devenv.cachix.org |
| Nixpkgs | `nixpkgs.nix` | Overlays e unfree | `allowUnfree = true`; overlays para nix-ai-tools e wezterm-flake |
| GC | `gc.nix` | Garbage collector automático | semanal; `--delete-older-than 14d`; auto-optimise-store |
| Auto-upgrade | `auto-upgrade.nix` | Atualização automática (desabilitada) | `operation = switch`; semanal; atualiza nixpkgs + rust-overlay |
| Usuários | `users.nix` | Definição do usuário xnm | grupos: networkmanager, input, wheel, video, audio, tss; shell: fish; RuntimeDirectorySize=8G |
| Tela | `screen.nix` | Brilho | `brightnessctl` |
| Variáveis de ambiente | `environment-variables.nix` | Paths específicos | SPOTIFY_PATH, JDK_PATH, NODEJS_PATH, ANDROID_SDK_ROOT, ANDROID_AVD_HOME |
| Tema | `theme.nix` | Catppuccin Macchiato Teal | GTK_THEME, XCURSOR, HYPRCURSOR; console colors (16 cores macchiato); qt via gtk2 |

### Parâmetros do Kernel (`linux-kernel.nix`)

| Parâmetro | Efeito |
|-----------|--------|
| `quiet` | Suprime mensagens de boot |
| `splash` | Exibe Plymouth |
| `loglevel=3` | Apenas erros críticos no console |
| `rd.udev.log_priority=3` | Menos logs de udev no initrd |
| `systemd.show_status=auto` | Status systemd automático |
| `fbcon=nodefer` | Framebuffer console sem adiamento |
| `vt.global_cursor_default=0` | Cursor de console oculto |
| `kernel.modules_disabled=1` | Impede carregamento de módulos pós-boot |
| `lsm=landlock,lockdown,yama,integrity,apparmor,bpf` | Stack de segurança LSM completo |
| `usbcore.autosuspend=-1` | Desabilita autosuspend USB |
| `video4linux` | Suporte a câmera V4L2 |
| `acpi_rev_override=5` | Override de revisão ACPI |

---

## 🔒 Segurança

| Módulo | Arquivo | Serviço/Opção | Valor | O que faz |
|--------|---------|---------------|-------|-----------|
| sudo-rs | `security-services.nix` | `security.sudo-rs.enable` | true | Substitui sudo pelo sudo-rs (Rust) |
| sudo-rs | `security-services.nix` | `execWheelOnly` | true | Apenas grupo wheel pode usar sudo |
| sudo | `security-services.nix` | `security.sudo.enable` | false | Sudo clássico desabilitado |
| root | `security-services.nix` | `root.hashedPassword` | `!` | Root bloqueado |
| TPM2 | `security-services.nix` | `security.tpm2` | enable + pkcs11 + tctiEnvironment | Suporte a TPM2 com PKCS#11 |
| AppArmor | `security-services.nix` | `security.apparmor` | enable; killUnconfined | AppArmor ativo; mata processos não confinados |
| AppArmor PAM | `security-services.nix` | serviços PAM | login, sshd, sudo-rs, su, greetd, u2f | AppArmor aplicado em todos os serviços PAM |
| Fail2ban | `security-services.nix` | `services.fail2ban` | enable | Proteção contra brute force |
| ClamAV daemon | `security-services.nix` | `services.clamav.daemon` | enable | Antivírus em tempo real |
| ClamAV updater | `security-services.nix` | `services.clamav.updater` | diário; frequência 12 | Atualização de definições |
| Fangfrisch | `security-services.nix` | `services.clamav.fangfrisch` | diário | Fontes extras de assinaturas ClamAV |
| ClamAV scanner | `clamav-scanner.nix` | `services.clamav.scanner` | sábados 04:00 | Scan agendado semanal (módulo desabilitado) |
| Firejail | `security-services.nix` | `programs.firejail` | enable | Sandboxing de apps |
| Firejail mpv | `security-services.nix` | wrappedBinaries.mpv | perfil firejail | mpv em sandbox |
| Firejail imv | `security-services.nix` | wrappedBinaries.imv | perfil firejail | imv em sandbox |
| Firejail zathura | `security-services.nix` | wrappedBinaries.zathura | perfil firejail | zathura em sandbox |
| Firejail discord | `security-services.nix` | wrappedBinaries.discord | perfil firejail | Discord em sandbox |
| Firejail slack | `security-services.nix` | wrappedBinaries.slack | perfil firejail | Slack em sandbox |
| Firejail Telegram | `security-services.nix` | wrappedBinaries.Telegram | perfil firejail | Telegram em sandbox |
| Firejail brave | `security-services.nix` | wrappedBinaries.brave | perfil firejail | Brave em sandbox |
| Firejail qutebrowser | `security-services.nix` | wrappedBinaries.qutebrowser | perfil firejail | qutebrowser em sandbox |
| Firejail thunar | `security-services.nix` | wrappedBinaries.thunar | perfil firejail | Thunar em sandbox |
| Firejail vscodium | `security-services.nix` | wrappedBinaries.vscodium | perfil firejail | VSCodium em sandbox |
| BrowserPass | `security-services.nix` | `programs.browserpass` | enable | Integração pass com navegadores |
| USBGuard | `usb.nix` | `services.usbguard` | enable; implicitPolicyTarget=block | Bloqueia dispositivos USB não autorizados |
| MAC random | `mac-randomize.nix` | systemd service macchanger | oneshot | Randomiza MAC Wi-Fi (desabilitado no flake) |
| Página isolada | `linux-kernel.nix` | `security.forcePageTableIsolation` | true | Mitigação Meltdown/Spectre |
| YubiKey PAM | `yubikey.nix` | `security.pam.u2f` | enable; cue; sufficient | U2F via YubiKey; serviços: greetd, sudo-rs, hyprlock |
| Fingerprint | `fingerprint-scanner.nix` | `services.fprintd` | tod + goodix-550a (desabilitado) | Scanner de impressão digital |

### Pacotes de segurança

| Pacote | O que faz |
|--------|-----------|
| `gnupg` | GPG para criptografia/assinatura |
| `openssl` | Utilitários SSL/TLS |
| `vulnix` | Scanner de vulnerabilidades Nix (`vulnix --system`) |
| `clamav` | Antivírus CLI |
| `pass-wayland` | Gerenciador de senhas compatível com Wayland |
| `pass2csv` | Exporta pass para CSV |
| `passExtensions.pass-tomb` | Integração com Tomb |
| `passExtensions.pass-update` | Atualiza senhas |
| `passExtensions.pass-otp` | OTP via pass |
| `passExtensions.pass-import` | Importa de outros gerenciadores |
| `passExtensions.pass-audit` | Auditoria de senhas |
| `tomb` | Criptografia de arquivos |
| `pwgen` | Gerador de senhas |
| `pwgen-secure` | Gerador de senhas seguro |
| `apparmor-utils` | Utilitários AppArmor |
| `apparmor-profiles` | Perfis AppArmor |
| `usbutils` | lsusb e utilitários USB |
| `yubikey-manager` | Gerenciamento de YubiKey |

---

## 🌐 Rede & SSH

### Configuração de rede (`networking.nix`)

| Serviço/Opção | Valor | O que faz |
|---------------|-------|-----------|
| `networking.hostName` | `isitreal-laptop` | Hostname do sistema |
| `networking.wireless.iwd` | enable | Backend Wi-Fi iwd (não NetworkManager) |
| `iwd.General.EnableNetworkConfiguration` | true | iwd gerencia IPs |
| `iwd.Network.EnableIPv6` | true | Suporte IPv6 via iwd |
| `iwd.Scan.DisablePeriodicScan` | true | Sem scan periódico (economia de energia) |
| `iwgtk` | pacote | GUI para iwd |
| `impala` | pacote | TUI para iwd |

### DNS Criptografado (`dns.nix`)

| Opção | Valor | O que faz |
|-------|-------|-----------|
| `networking.nameservers` | `127.0.0.1`, `[::1]` | Aponta para dnscrypt-proxy local |
| `networking.dhcpcd.enable` | false | DHCP via iwd, não dhcpcd |
| `networking.networkmanager.dns` | `none` | NM não gerencia DNS |
| `networking.resolvconf.enable` | true | resolvconf ativo |
| `services.dnscrypt-proxy.enable` | true | DNSCrypt proxy local na porta 53 |
| `ipv6_servers` | true | Consulta servidores IPv6 |
| `require_dnssec` | true | Exige DNSSEC |
| Servidores DNS | cloudflare, cloudflare-ipv6, cloudflare-security, adguard-dns-doh, mullvad-adblock-doh, mullvad-doh, nextdns, quad9-dnscrypt-ipv4-filter-pri, google, google-ipv6, ibksturm | Lista de resolvers com DoH |

### Firewall (`firewall.nix`)

| Opção | Valor |
|-------|-------|
| `networking.firewall.enable` | true |
| TCPPorts abertas | nenhuma (comentadas) |
| UDPPorts abertas | nenhuma (comentadas) |

### SSH (`open-ssh.nix` — desabilitado no flake)

| Opção | Valor |
|-------|-------|
| `services.openssh.enable` | true (mas módulo comentado no flake) |
| `PasswordAuthentication` | false |
| `KbdInteractiveAuthentication` | false |
| `PermitRootLogin` | `no` |
| `AllowUsers` | `xnm` |

### Mosh (`mosh.nix`)

| Pacote | Detalhe |
|--------|---------|
| `mosh` | Instalado como pacote; serviço comentado |

### VPN (`vpn.nix`)

| Serviço | Pacote | Detalhe |
|---------|--------|---------|
| `services.mullvad-vpn` | `pkgs.mullvad` (CLI) | Mullvad VPN ativo |
| `mullvad-compass` | GUI | Compass para Mullvad |
| `mullvad-browser` | browser | Browser da Mullvad |
| `tor-browser` | browser | Tor Browser |

---

## 🎨 Desktop & Hyprland

### Serviços e pacotes do Hyprland

| Serviço/Pacote | Opção/Versão | O que faz |
|----------------|-------------|-----------|
| `programs.hyprland` | enable + withUWSM | Compositor Wayland Hyprland com UWSM |
| `programs.hyprlock` | enable | Bloqueio de tela |
| `services.hypridle` | enable | Daemon de ociosidade |
| `services.greetd` | tuigreet; `uwsm start hyprland` | Display manager de terminal |
| `NIXOS_OZONE_WL` | `1` | Wayland para apps Chromium/Electron |
| `WLR_NO_HARDWARE_CURSORS` | `1` | Fallback de cursor para Wayland |
| `pyprland` | plugin manager | Scratchpads, expose, magnify, shortcuts_menu |
| `hyprpicker` | color picker | Seletor de cor |
| `hyprcursor` | cursor | Suporte a cursores Hyprland |
| `hyprlock` | locker | Bloqueio de tela |
| `hypridle` | idle daemon | Gerencia ociosidade |
| `hyprpaper` | wallpaper | Daemon de papel de parede |
| `hyprsunset` | redshift | Temperatura de cor noturna |
| `hyprpolkitagent` | polkit | Agente Polkit para Hyprland |

### Monitor e workspaces (`hyprland.conf`)

| Monitor | Resolução | Posição | Escala |
|---------|-----------|---------|--------|
| `eDP-1` | preferred | auto | 1.6 |
| `HDMI-A-1` | preferred | auto-up | 1.6 |

| Workspaces | Monitor |
|-----------|---------|
| 1–10 | eDP-1 (monitor interno) |
| 11–20 | HDMI-A-1 (monitor externo) |

### Configurações gerais do Hyprland

| Seção | Opção | Valor |
|-------|-------|-------|
| `input` | kb_layout | us,ua,ru |
| `input` | kb_options | grp:win_space_toggle |
| `input` | follow_mouse | 1 |
| `input.touchpad` | natural_scroll | yes |
| `input.touchpad` | tap-and-drag | true |
| `general` | gaps_in | 5 |
| `general` | gaps_out | 10 |
| `general` | border_size | 2 |
| `general` | col.active_border | $teal |
| `general` | col.inactive_border | $surface1 |
| `general` | layout | dwindle |
| `decoration` | rounding | 10 |
| `decoration` | blur size | 8 |
| `decoration` | blur passes | 2 |
| `decoration` | shadow range | 15; color $teal |
| `decoration` | active_opacity | 0.7 |
| `decoration` | inactive_opacity | 0.7 |
| `decoration` | fullscreen_opacity | 0.7 |
| `animations` | windows | bezier myBezier(0.05,0.9,0.1,1.05), dur=2 |
| `animations` | windowsOut | popin 80%, dur=2 |
| `animations` | windowsMove | slide, dur=2 |
| `animations` | border | dur=3 |
| `animations` | workspaces | dur=1 |
| `dwindle` | pseudotile | yes |
| `dwindle` | preserve_split | yes |
| `dwindle` | smart_split | true |
| `misc` | disable_hyprland_logo | true |
| `misc` | background_color | 0x24273a |
| `binds` | workspace_back_and_forth | true |
| `gesture` | 3 horizontal | workspace swipe |

### Atalhos de teclado (tabela completa)

> `$mainMod = SUPER`

#### Aplicativos

| Atalho | Ação |
|--------|------|
| `SUPER + T` | Abre Kitty (com nvidia-offload se on AC) |
| `SUPER + SHIFT + T` | Abre Telegram |
| `SUPER + B` | Abre qutebrowser |
| `SUPER + SHIFT + B` | Abre Brave (firejail) |
| `SUPER + F` | Abre Thunar |
| `SUPER + S` | Abre Spotify |
| `SUPER + Y` | Abre Pear Desktop |
| `SUPER + D` | Abre Rofi (drun) |
| `SUPER + SHIFT + D` | Abre Discord (firejail + apparmor) |

#### Sistema / Sessão

| Atalho | Ação |
|--------|------|
| `SUPER + ESCAPE` | Abre wlogout |
| `SUPER + SHIFT + L` | Hyprlock (bloqueio de tela) |
| `SUPER + SHIFT + Q` | Fecha janela ativa (killactive) |
| `SUPER + ALT + M` | Sai do Hyprland (exit) |

#### Captura de tela / Gravação

| Atalho | Ação |
|--------|------|
| `SUPER + SHIFT + S` | Screenshot seleção → clipboard |
| `SUPER + E` | Screenshot + editar com swappy |
| `SUPER + SHIFT + R` | Gravar tela como GIF |
| `SUPER + R` | Gravar tela como MP4 |

#### Clipboard / Bookmarks

| Atalho | Ação |
|--------|------|
| `SUPER + V` | Abre cliphist e digita item selecionado |
| `SUPER + SHIFT + V` | Abre cliphist e copia item para wl-copy |
| `SUPER + X` | Deleta item do clipboard |
| `SUPER + SHIFT + X` | Limpa todo o clipboard |
| `SUPER + U` | Abre bookmarks e digita item |
| `SUPER + SHIFT + U` | Adiciona bookmark |
| `SUPER + CTRL + U` | Deleta bookmark |

#### Color Picker

| Atalho | Ação |
|--------|------|
| `SUPER + C` | hyprpicker -a (captura cor e copia) |
| `SUPER + SHIFT + C` | Pypr shortcuts_menu "Color picker" |

#### Controle de mídia

| Atalho | Ação |
|--------|------|
| `SUPER + P` | playerctl play-pause |
| `SUPER + ]` | playerctl next |
| `SUPER + [` | playerctl previous |
| `XF86AudioRaiseVolume` | volumectl -u up |
| `XF86AudioLowerVolume` | volumectl -u down |
| `XF86AudioMute` | volumectl toggle-mute |
| `XF86AudioMicMute` | volumectl -m toggle-mute |
| `XF86MonBrightnessUp` | lightctl -D intel_backlight up |
| `XF86MonBrightnessDown` | lightctl -D intel_backlight down |

#### Toggles

| Atalho | Ação |
|--------|------|
| `SUPER + SHIFT + A` | Airplane mode toggle |
| `SUPER + SHIFT + N` | Dunst pause toggle |
| `SUPER + SHIFT + Y` | Bluetooth toggle |
| `SUPER + SHIFT + W` | Wi-Fi toggle |

#### Foco / Layout

| Atalho | Ação |
|--------|------|
| `SUPER + ←/→/↑/↓` | Mover foco (setas) |
| `SUPER + H/L/K/J` | Mover foco (vim) |
| `SUPER + Tab` | cyclenext + bringactivetotop |
| `SUPER + SHIFT + F` | togglefloating |
| `SUPER + CTRL + F` | fullscreen 0 |
| `SUPER + SHIFT + P` | pseudo (dwindle) |
| `SUPER + SHIFT + O` | togglesplit (dwindle) |

#### Workspaces — Monitor interno (eDP-1)

| Atalho | Ação |
|--------|------|
| `SUPER + 1..9,0` | Switch para workspace 1..10 |
| `SUPER + SHIFT + 1..9,0` | Move janela para workspace 1..10 |
| `SUPER + scroll down/up` | Workspace e+1 / e-1 |

#### Workspaces — Monitor externo (HDMI-A-1)

| Atalho | Ação |
|--------|------|
| `SUPER + ALT + 1..9,0` | Switch para workspace 11..20 |
| `SUPER + ALT + SHIFT + 1..9,0` | Move janela para workspace 11..20 |

#### Mouse

| Atalho | Ação |
|--------|------|
| `SUPER + LMB (drag)` | Move janela |
| `SUPER + RMB (drag)` | Redimensiona janela |

#### Submap: Resize (`SUPER + ALT + R`)

| Atalho | Ação |
|--------|------|
| `←/→/↑/↓` ou `h/l/k/j` | resizeactive ±10px |
| `Escape` | Sair do submap |

#### Submap: Move (`SUPER + ALT + M` — seta) 
> Nota: `SUPER + ALT + M` também é keybind de exit; a entrada no submap "move" é por bind de submap separado.

| Atalho | Ação |
|--------|------|
| `←/→/↑/↓` ou `h/l/k/j` | movewindow l/r/u/d |
| `Escape` | Sair do submap |

#### Pyprland / Scratchpads

| Atalho | Ação |
|--------|------|
| `SUPER + CTRL + T` | Toggle scratchpad terminal (Kitty dropterm) |
| `SUPER + CTRL + V` | Toggle scratchpad volume (pavucontrol) |
| `SUPER + CTRL + M` | togglespecialworkspace minimized |
| `SUPER + M` | pypr toggle_special minimized |
| `SUPER + CTRL + E` | pypr expose |
| `SUPER + Z` | pypr zoom (magnify) |

### Windowrules

| Regra | Match | Valor |
|-------|-------|-------|
| float | `title .*mpv$` | float on |
| opaque | `title .*mpv$` | opaque on |
| size | `title .*mpv$` | 50% 50% |
| float | `content 2` | float on |
| opaque | `content 2` | opaque on |
| size | `content 2` | 50% 50% |
| float | `title .*imv.*` | float on |
| opaque | `title .*imv.*` | opaque on |
| size | `title .*imv.*` | 70% 70% |
| float | `content 1` | float on |
| opaque | `content 1` | opaque on |
| size | `content 1` | 70% 70% |
| float | `title .*\.pdf$` | float on |
| opaque | `title .*\.pdf$` | opaque on |
| maximize | `title .*\.pdf$` | maximize on |
| opaque | `title .*YouTube - Brave$` | opaque on |
| opaque | `title swappy` | opaque on |
| center | `title swappy` | center on |
| stay_focused | `title swappy` | stay_focused on |
| float | `$dropterm` (terminal-dropterm) | float on |
| pin | `$dropterm` | pin on |
| float | `$volume_sidemenu` (pavucontrol) | float on |
| pin | `$volume_sidemenu` | pin on |
| layerrule blur | `logout_dialog` | blur on |

### Exec-once (autostart)

Executado via `fish -c autostart` (função em `autostart.fish`):

| Processo | O que faz |
|----------|-----------|
| `pypr` | Plugin manager Hyprland (scratchpads, expose, zoom) |
| `hyprpaper` | Daemon de papel de parede |
| `hypridle` | Daemon de ociosidade |
| `waybar` | Barra de status (3 barras) |
| `poweralertd -s` | Notificações de bateria |
| `wl-paste --type text --watch cliphist store` | Monitor de clipboard (texto) |
| `wl-paste --type image --watch cliphist store` | Monitor de clipboard (imagem) |
| `wl-clip-persist --clipboard regular` | Persiste clipboard após fechar app |
| `avizo-service` | Daemon de OSD (volume/brilho) |
| `systemctl --user start psi-notify` | Notificações de pressão de memória |

### Papel de parede (`hyprpaper.conf`)

| Monitor | Arquivo |
|---------|---------|
| eDP-1 | `~/background` |
| HDMI-A-1 | `~/background` |

---

## 🔊 Áudio & Bluetooth

### Áudio (`sound.nix`)

| Serviço/Opção | Valor | O que faz |
|---------------|-------|-----------|
| `services.pulseaudio.enable` | false | PulseAudio desabilitado |
| `security.rtkit.enable` | true | RTKit para prioridade de áudio em tempo real |
| `services.pipewire.enable` | true | PipeWire como servidor de áudio |
| `services.pipewire.alsa.enable` | true | Compatibilidade ALSA |
| `services.pipewire.alsa.support32Bit` | true | ALSA 32-bit |
| `services.pipewire.pulse.enable` | true | Compatibilidade PulseAudio |
| `services.pipewire.wireplumber.enable` | true | WirePlumber como session manager |
| `pamixer` | pacote | Controle de volume CLI |
| `pavucontrol` | pacote | Controle de volume GUI (scratchpad) |

### Bluetooth (`bluetooth.nix`)

| Opção | Valor | O que faz |
|-------|-------|-----------|
| `hardware.bluetooth.enable` | true | Bluetooth habilitado |
| `hardware.bluetooth.powerOnBoot` | false | Não liga Bluetooth no boot |
| `overskride` | pacote | GUI Bluetooth (GTK) |

---

## 🖋️ Fontes

| Pacote | O que faz |
|--------|-----------|
| `jetbrains-mono` | Fonte principal monospace |
| `nerd-fonts.jetbrains-mono` | JetBrains Mono com ícones Nerd Fonts |
| `nerd-fonts.symbols-only` | Apenas símbolos Nerd Fonts |
| `noto-fonts-color-emoji` | Emojis coloridos |

Usadas em: Waybar, Rofi, Kitty, WezTerm, Helix, terminal, btop, dunst.

---

## ⌨️ Terminal & Shell

### Fish (aliases, funções, plugins)

**Habilitado em:** `nixos/terminal.nix` (`programs.fish.enable = true`)  
**Shell padrão de xnm:** `pkgs.fish`

#### Aliases (`config.fish`)

| Alias | Comando |
|-------|---------|
| `cl` | `clear` |
| `rad` | `rad-tui` |
| `ai` | `aichat` |
| `ai-commit` | `git diff --staged \| ai -r commit-message \| hx` |
| `ai-emoji-commit` | `git diff --staged \| ai -r emoji-commit-message \| hx` |
| `ai-branch` | `git diff --staged \| ai -r git-branch \| hx` |
| `ai-spell` | `vipe \| ai -r improve-writing \| hx` |
| `ai-email` | `vipe \| ai -r email-answer \| hx` |
| `ai-linkedin` | `vipe \| ai -r linkedin-answer \| hx` |
| `aic` | `ai-commit` |
| `aiec` | `ai-emoji-commit` |
| `aib` | `ai-branch` |
| `ais` | `ai-spell` |
| `aie` | `ai-email` |
| `ail` | `ai-linkedin` |
| `lgit` | `lazygit` |
| `ldocker` | `lazydocker` |
| `conf` | `z ~/.config` |
| `nixos` | `z /etc/nixos` |
| `store` | `z /nix/store` |
| `nswitch` | `sudo nixos-rebuild switch --flake /etc/nixos#isitreal-laptop` |
| `nswitchu` | `nix flake update + nixos-rebuild switch` |
| `nau` | `sudo nix-channel --add nixos-unstable` |
| `nsgc` | `sudo nix-store --gc` |
| `ngc` | `sudo nix-collect-garbage -d` |
| `ngc7` | `sudo nix-collect-garbage --delete-older-than 7d` |
| `ngc14` | `sudo nix-collect-garbage --delete-older-than 14d` |

#### Variáveis de ambiente (`config.fish`)

| Variável | Valor |
|----------|-------|
| `EDITOR` | `hx` |
| `VOLUME_STEP` | `5` |
| `BRIGHTNESS_STEP` | `5` |
| `PATH` | `~/.cargo/bin`, `~/.npm-packages/bin` |
| `FZF_DEFAULT_OPTS` | Catppuccin Macchiato colors |

#### Modo VI e cursor Fish

| Opção | Valor |
|-------|-------|
| `fish_vi_force_cursor` | ativo |
| cursor default | block |
| cursor insert | line blink |
| cursor visual | underscore blink |
| `fish_color_command` | blue |

#### Inicializações automáticas (`config.fish`)

| Comando | O que faz |
|---------|-----------|
| `starship init fish \| source` | Prompt Starship |
| `zoxide init fish \| source` | Navegação rápida de diretórios |
| `direnv hook fish \| source` | direnv para ambientes por diretório |
| `mise activate fish \| source` | mise para gerenciamento de versões |
| `enable_transience` | Prompt compacto pós-execução |

#### Funções Fish (lista completa de `functions/`)

| Arquivo | O que faz |
|---------|-----------|
| `aichat_fish.fish` | Integração aichat no Fish |
| `airplane_mode_toggle.fish` | Liga/desliga modo avião (Wi-Fi + Bluetooth) |
| `archive-preview.fish` | Preview de arquivos para fzf/yazi |
| `autostart.fish` | Inicia todos os daemons do Hyprland |
| `back-op.fish` | Operação de voltar (para yazi/fzf) |
| `backtrack-op.fish` | Retrocesso de diretório |
| `bluetooth_toggle.fish` | Liga/desliga Bluetooth |
| `bookmark_add.fish` | Adiciona bookmark via rofi |
| `bookmark_delete.fish` | Remove bookmark via rofi |
| `bookmark_to_type.fish` | Seleciona bookmark e digita com wtype |
| `check_airplane_mode.fish` | Checa estado modo avião para Waybar |
| `check_geo_module.fish` | Checa se geoclue está ativo para Waybar |
| `check_night_mode.fish` | Checa estado do modo noturno para Waybar |
| `check_recording.fish` | Checa se wl-screenrec está rodando |
| `check_webcam.fish` | Checa se webcam está ativa |
| `clear-op.fish` | Limpa seleção (yazi) |
| `clipboard_clear.fish` | Limpa histórico cliphist |
| `clipboard_delete_item.fish` | Remove item do cliphist via rofi |
| `clipboard_to_type.fish` | Seleciona item do clipboard e digita |
| `clipboard_to_wlcopy.fish` | Seleciona item do clipboard e copia |
| `dir-preview.fish` | Preview de diretório para fzf |
| `dunst_pause.fish` | Estado de pausa dunst para Waybar |
| `fetch_music_player_data.fish` | Dados do player para Waybar |
| `file-preview.fish` | Preview de arquivo para fzf |
| `fish_bind_count.fish` | Contagem de keybinds |
| `fish_default_mode_prompt.fish` | Prompt de modo VI |
| `fish_greeting.fish` | Saudação no terminal (fastfetch / figlet) |
| `fish_helix_command.fish` | Comandos helix integrados |
| `fish_helix_key_bindings.fish` | Keybindings helix no Fish |
| `fish_user_key_bindings.fish` | Keybindings customizados do usuário |
| `fzf-cd-preview-widget.fish` | Widget fzf de navegação de diretório |
| `fzf-file-preview-widget.fish` | Widget fzf de preview de arquivo |
| `fzf-ps-widget.fish` | Widget fzf de processos |
| `fzf_key_bindings.fish` | Keybindings fzf para Fish |
| `image-preview.fish` | Preview de imagem (chafa/viu) |
| `kitty_launch.fish` | Lança Kitty com nvidia-offload se on AC |
| `list-op.fish` | Lista arquivos (yazi) |
| `night_mode_temp_down.fish` | Diminui temperatura de cor (hyprsunset) |
| `night_mode_temp_up.fish` | Aumenta temperatura de cor (hyprsunset) |
| `night_mode_toggle.fish` | Liga/desliga modo noturno |
| `record_screen_gif.fish` | Grava tela como GIF (wl-screenrec + gifsicle) |
| `record_screen_mp4.fish` | Grava tela como MP4 (wl-screenrec) |
| `screenshot_edit.fish` | Screenshot → swappy para edição |
| `screenshot_to_clipboard.fish` | Screenshot seleção → clipboard + notificação |
| `switch-preview.fish` | Troca de preview (yazi) |
| `tre.fish` | Wrapper para tre-command |
| `wifi_toggle.fish` | Liga/desliga Wi-Fi (iwd) |
| `wlogout_uniqe.fish` | Garante apenas uma instância do wlogout |

### Kitty

| Opção | Valor |
|-------|-------|
| Fonte | JetBrains Mono (regular, bold, italic, bold italic) |
| Keybind | `kitty_mod+/` → launch hsplit search.py |
| Tema | Catppuccin Macchiato (via macchiato.conf) |

### WezTerm

| Opção | Valor |
|-------|-------|
| `enable_wayland` | true |
| `prefer_egl` | true |
| `front_end` | `WebGpu` |
| `webgpu_preferred_adapter` | `gpus[2]` |
| `color_scheme` | `Catppuccin Macchiato` |
| `enable_tab_bar` | false |
| Background | Cor sólida `#24273a` + imagem `lain.gif` (opacidade 0.02) |
| Launch menu | btop, cmatrix, pipes-rs |

#### Keybinds WezTerm

| Atalho | Ação |
|--------|------|
| `CTRL+SHIFT+J` | ScrollByPage(1) |
| `CTRL+SHIFT+K` | ScrollByPage(-1) |
| `CTRL+SHIFT+G` | ScrollToTop |
| `CTRL+SHIFT+E` | ScrollToBottom |
| `CTRL+SHIFT+SUPER+P` | PaneSelect |
| `CTRL+SHIFT+SUPER+O` | PaneSelect SwapWithActive |

### Zellij

#### Keybinds Zellij (`config.kdl`)

**Modo Normal:**

| Atalho | Ação |
|--------|------|
| `Alt 1..9` | GoToTab 1..9 + SwitchToMode Normal |
| `Alt 0` | ToggleTab |
| `Alt x` | CloseFocus |
| `Alt X` | CloseTab |
| `Alt N` | NewTab |

**Modo Resize:**

| Atalho | Ação |
|--------|------|
| `Ctrl n` | Normal |
| `h/j/k/l` ou setas | Resize Increase L/D/U/R |
| `H/J/K/L` | Resize Decrease L/D/U/R |
| `=/+` / `-` | Resize Increase/Decrease |

**Modo Pane:**

| Atalho | Ação |
|--------|------|
| `Ctrl p` | Normal |
| `h/j/k/l` | MoveFocus |
| `p` | SwitchFocus |
| `n` | NewPane |
| `d` | NewPane Down |
| `r` | NewPane Right |
| `x` | CloseFocus |
| `f` | ToggleFocusFullscreen |
| `z` | TogglePaneFrames |
| `w` | ToggleFloatingPanes |
| `e` | TogglePaneEmbedOrFloating |
| `c` | RenamePane |

**Modo Move:**

| Atalho | Ação |
|--------|------|
| `Ctrl h` | Normal |
| `n/Tab` | MovePane |
| `h/j/k/l` | MovePane L/D/U/R |

**Modo Tab:**

| Atalho | Ação |
|--------|------|
| `Ctrl t` | Normal |
| `r` | RenameTab |
| `h/k/←/↑` | GoToPreviousTab |
| `l/j/→/↓` | GoToNextTab |
| `n` | NewTab |
| `x` | CloseTab |
| `s` | ToggleActiveSyncTab |
| `1..9` | GoToTab 1..9 |
| `Tab` | ToggleTab |

---

## 🧑‍💻 Desenvolvimento

### Ferramentas CLI (`dev-tools.nix`, `terminal.nix`)

| Pacote | O que faz |
|--------|-----------|
| `mold` | Linker rápido |
| `gcc` | Compilador C/C++ |
| `clang` | Compilador LLVM |
| `lld` | Linker LLVM |
| `lldb` | Debugger LLVM |
| `musl` | libc musl |
| `jdk17` | Java 17 JDK |
| `dioxus-cli` | CLI para Dioxus (Rust web/native) |
| `trunk` | Bundler WASM para Rust |
| `devenv` | Ambientes de desenvolvimento |
| `sops` | Gerenciamento de segredos |
| `rops` | Rust reimplementação de sops |
| `git` | Controle de versão |
| `git-lfs` | Git Large File Storage |
| `lefthook` | Git hooks manager |
| `pre-commit-hook-ensure-sops` | Garante sops em pre-commit |
| `lazygit` | TUI para git |
| `lazynpm` | TUI para npm |
| `diffnav` | Navegação de diffs |
| `sqlx-cli` | CLI para sqlx (Rust + SQL) |
| `license-generator` | Gerador de arquivos LICENSE |
| `git-ignore` | Gerencia .gitignore |
| `gitleaks` | Detector de secrets em git |
| `pass-git-helper` | Helper de credenciais git via pass |
| `jujutsu` | VCS alternativo ao git |
| `jjui` | TUI para jujutsu |
| `just` | Task runner (makefile alternativo) |
| `mise` | Gerenciador de versões de ferramentas |
| `gh` | GitHub CLI |
| `gh-dash` | Dashboard GitHub no terminal |
| `hurl` | Teste de APIs HTTP |
| `grex` | Gerador de regex a partir de exemplos |
| `surrealdb` | Banco de dados multimodal |
| `surrealdb-migrations` | Migrations para SurrealDB |
| `surrealist` | GUI para SurrealDB |
| `ripgrep` | Busca de texto ultrarrápida |
| `fd` | Alternativa moderna ao find |
| `fzf` | Fuzzy finder |
| `bat` | cat com syntax highlight (tema Catppuccin Macchiato) |
| `delta` | Diff com syntax highlight |
| `jq` | Processador JSON |
| `sd` | Substituto do sed |
| `tokei` | Contador de linhas de código |
| `hyperfine` | Benchmarking de comandos |
| `posting` | TUI para requisições HTTP |
| `xh` | Cliente HTTP moderno |
| `process-compose` | Gerenciador de processos |
| `rewrk` / `wrk2` | Benchmark de servidores HTTP |
| `asciinema` / `asciinema-agg` | Gravação de terminal e GIF |

### LSP / Editores (`lsp.nix`, `helix/config.toml`, `helix/languages.toml`)

**Editor padrão:** Helix (`hx`)

#### Helix — Configuração

| Opção | Valor |
|-------|-------|
| Tema | `catppuccin_macchiato_transparent` |
| Shell | `fish -c` |
| `line-number` | relative |
| `cursorline` | true |
| `color-modes` | true |
| `auto-save` | false |
| `idle-timeout` | 0 |
| `bufferline` | multiple |
| `popup-border` | popup |
| cursor insert/normal | bar |
| cursor select | underline |
| `indent-guides` | render true |
| LSP `display-messages` | true |
| LSP `display-inlay-hints` | true |
| `soft-wrap` | enable |

#### Helix — Keybinds personalizados

| Atalho | Ação |
|--------|------|
| `backspace + w` | `:w` (salvar) |
| `backspace + d` | `:bc` (fechar buffer) |
| `backspace + S-d` | `:bca` (fechar todos buffers) |
| `backspace + c` | `wclose` |
| `backspace + q` | `:q` |
| `backspace + A-w` | `:w!` |
| `backspace + A-q` | `:q!` |
| `S-l` / `S-right` | `:bn` (próximo buffer) |
| `S-h` / `S-left` | `:bp` (buffer anterior) |
| `A-w` | `:w` |
| `A-r` | `:rl` (reload) |
| `C-h/j/k/l` | jump_view L/D/U/R |
| `C-y + y` | Yazi picker (abrir) via Zellij |
| `C-y + v` | Yazi picker (vsplit) |
| `C-y + h` | Yazi picker (hsplit) |
| `space + B` | `git blame` da linha atual |

#### Helix — Linguagens configuradas (`languages.toml`)

| Linguagem | LSP(s) | Extras |
|-----------|--------|--------|
| `hyprlang` | `hyprls` | — |
| `rust` | `rust-analyzer` | checkOnSave = clippy |
| `html` | `emmet-lsp`, `vscode-html-language-server` | — |
| `javascript` | `typescript-language-server` | indent 4, auto-format |
| `jsx` | `typescript-language-server` | indent 4, auto-format |
| `typescript` | `typescript-language-server` | indent 4, auto-format |
| `tsx` | `typescript-language-server` | indent 3, auto-format |
| `json` | — | comment-token // |
| `config` | — | scope source.conf, extensão .conf |

#### LSPs instalados (`lsp.nix`)

| LSP | Linguagem/Domínio |
|-----|------------------|
| `python-lsp-server` | Python |
| `ty` | Python type checker |
| `ruff` | Python linter/formatter |
| `nodemon` | Node.js watch |
| `typescript` | TypeScript |
| `typescript-language-server` | TS/JS |
| `eslint` | JS/TS linting |
| `biome` | JS/TS/JSON formatter |
| `rubyPackages.htmlbeautifier` | HTML/Ruby |
| `vscode-langservers-extracted` | HTML/CSS/JSON/ESLint |
| `superhtml` | HTML |
| `jsonnet-language-server` | Jsonnet |
| `yaml-language-server` | YAML |
| `taplo` | TOML |
| `tombi` | TOML |
| `bash-language-server` | Bash |
| `graphql-language-service-cli` | GraphQL |
| `dockerfile-language-server` | Dockerfile |
| `vue-language-server` | Vue |
| `lua-language-server` | Lua |
| `marksman` | Markdown |
| `markdown-oxide` | Markdown (Obsidian-style) |
| `nil` | Nix |
| `nixd` | Nix |
| `zls` | Zig |
| `gopls` | Go |
| `delve` | Go debugger |
| `emmet-language-server` | HTML/CSS emmet |
| `buf` | Protocol Buffers |
| `protols` | Protocol Buffers LSP |
| `cmake-language-server` | CMake |
| `neocmakelsp` | CMake |
| `just-lsp` | Justfile |
| `docker-compose-language-service` | Docker Compose |
| `vscode-extensions.vadimcn.vscode-lldb` | LLDB debugger |
| `slint-lsp` | Slint UI |
| `terraform-ls` | Terraform |
| `hyprls` | Hyprland config |
| `nix-ai-tools.copilot-language-server` | GitHub Copilot |
| `lsp-ai` | AI completions (LSP) |
| `fish-lsp` | Fish shell |
| `wasm-language-tools` | WebAssembly |

### Linguagens (`programming-languages.nix`)

| Linguagem | Pacote |
|-----------|--------|
| Go | `go` |
| Python | `python313` + pygobject3, gobject-introspection, pyqt6-sip |
| uv | `uv` (Python package manager) |
| Node.js | `nodejs` |
| pnpm | `pnpm` |
| Bun | `bun` |
| Lua | `lua` |
| Zig | `zig` |
| Numbat | `numbat` (calculadora científica) |
| Gleam | `gleam` |

### Rust (`rust.nix`)

Toolchain via `rust-overlay` (arquivo `rust-toolchain.toml`):

| Pacote | O que faz |
|--------|-----------|
| `rust-bin.fromRustupToolchainFile` | Toolchain definido em rust-toolchain.toml |
| `cargo-watch` | Watch e re-executa comandos cargo |
| `cargo-deny` | Auditoria de dependências |
| `cargo-audit` | Vulnerabilidades de dependências |
| `cargo-update` | Atualiza crates instalados |
| `cargo-edit` | add/rm/upgrade no Cargo.toml |
| `cargo-outdated` | Verifica crates desatualizados |
| `cargo-license` | Lista licenças de dependências |
| `cargo-tarpaulin` | Cobertura de testes |
| `cargo-cross` | Cross-compilation |
| `cargo-zigbuild` | Build via Zig como linker |
| `cargo-nextest` | Runner de testes mais rápido |
| `cargo-spellcheck` | Verifica ortografia em doc comments |
| `cargo-modules` | Visualiza estrutura de módulos |
| `cargo-bloat` | Análise de tamanho de binário |
| `cargo-sweep` | Remove artefatos de build antigos |
| `cargo-unused-features` | Detecta features não usadas |
| `cargo-feature` | Gerencia features Cargo |
| `cargo-features-manager` | UI para features Cargo |
| `worker-build` | Build para Cloudflare Workers |
| `bacon` | Watcher de background para Rust |
| `evcxr` | REPL interativo para Rust |
| `rust-script` | Executa scripts Rust sem projeto |

### WASM (`wasm.nix`)

| Pacote | O que faz |
|--------|-----------|
| `wasmedge` | Runtime WebAssembly para server-side |
| `wasmi` | Interpretador WASM (comentado: wasmer) |
| `wrangler` | CLI Cloudflare Workers |
| `fermyon-spin` | Framework WASM para microservices |
| `wash-cli` | CLI para wasmCloud |

---

## 🤖 LLM / IA

### Serviços (`llm.nix`)

| Serviço | Opção | Valor |
|---------|-------|-------|
| `services.ollama` | enable | true |
| `services.ollama` | package | `ollama-cuda` (GPU NVIDIA) |
| `services.ollama` | syncModels | true |
| `services.searx` | enable | true; porta 7777; localhost |
| `services.n8n` | enable | false (desabilitado) |
| `services.open-webui` | enable | false; porta 8888 |

### Modelos Ollama carregados

| Modelo |
|--------|
| `gemma4:e2b` |
| `gemma4:e4b` |
| `gpt-oss:20b` |
| `jaahas/qwen3.5-uncensored:4b` |
| `jaahas/qwen3.5-uncensored:9b` |
| `devstral-small-2:24b` |
| `glm-4.7-flash` |
| `nomic-embed-text-v2-moe` |
| `x/z-image-turbo` |
| `x/flux2-klein:4b` |
| `x/flux2-klein:9b` |

### Pacotes de IA (`llm.nix`)

| Pacote | O que faz |
|--------|-----------|
| `nix-ai-tools.backlog-md` | Gestão de backlog em markdown com IA |
| `nix-ai-tools.beads-rust` | Ferramenta de raciocínio em cadeia |
| `nix-ai-tools.tuicr` | TUI para LLMs |
| `nix-ai-tools.mcporter` | Portador de contexto para MCP |
| `nix-ai-tools.rtk` | Reasoning toolkit |
| `oterm` | TUI para Ollama |
| `aichat` | Cliente AI multi-backend via CLI |
| `fabric-ai` | Framework de AI pipelines (fabric) |
| `nix-ai-tools.ccusage-opencode` | Rastreamento de uso de tokens |
| `nix-ai-tools.opencode` | Agente de codificação AI |
| `nix-ai-tools.openspec` | Geração de specs via IA |
| `nix-ai-tools.openskills` | Biblioteca de habilidades AI |
| `nix-ai-tools.agent-browser` | Browser controlado por agente AI |
| `chromium` | Browser para AI agents |

---

## 🖥️ GPU (NVIDIA)

### Configuração NVIDIA (`nvidia.nix`)

| Opção | Valor | O que faz |
|-------|-------|-----------|
| `services.xserver.videoDrivers` | `["nvidia"]` | Driver NVIDIA |
| `hardware.nvidia-container-toolkit.enable` | true | NVIDIA em containers |
| `hardware.nvidia.modesetting.enable` | true | Modesetting (obrigatório Wayland) |
| `hardware.nvidia.powerManagement.enable` | true | Power management NVIDIA |
| `hardware.nvidia.powerManagement.finegrained` | true | Desliga GPU quando ociosa |
| `hardware.nvidia.dynamicBoost.enable` | mkForce true | Dynamic Boost (Max-Q) |
| `hardware.nvidia.open` | true | Kernel module open-source NVIDIA |
| `hardware.nvidia.nvidiaSettings` | true | nvidia-settings habilitado |
| `hardware.nvidia.package` | `nvidiaPackages.production` | Driver versão production |
| `prime.offload.enable` | true | Optimus PRIME offload mode |
| `prime.offload.enableOffloadCmd` | true | Comando `nvidia-offload` |
| `nvidiaBusId` | FIXME: `PCI:0:0:0` | Bus ID NVIDIA (personalizar) |
| `intelBusId` | FIXME: `PCI:0:0:0` | Bus ID Intel (personalizar) |

### Specialisation `nvidia-sync`

| Opção | Valor |
|-------|-------|
| `powerManagement.finegrained` | false |
| `prime.offload` | desabilitado |
| `prime.sync.enable` | true |

> Boot em `nvidia-sync` para modo de máxima performance (GPU sempre ativa).

### OpenGL / Graphics (`opengl.nix`)

| Pacote | O que faz |
|--------|-----------|
| `intel-compute-runtime` | OpenCL Intel |
| `intel-media-driver` (iHD) | VA-API Intel (moderno) |
| `intel-vaapi-driver` (i965) | VA-API Intel (legado; Firefox/Chromium) |
| `libva-vdpau-driver` | VDPAU via libva |
| `libvdpau-va-gl` | VDPAU via OpenGL |
| `mesa` | Implementação Open Source OpenGL/Vulkan |
| `nvidia-vaapi-driver` | VA-API via NVIDIA |
| `nv-codec-headers-12` | Headers NVENC/NVDEC |
| Pacotes 32-bit | intel-media-driver, intel-vaapi-driver, libva-vdpau-driver, mesa, libvdpau-va-gl |

### Desabilitação NVIDIA (`disable-nvidia.nix` — módulo opcional)

Quando usado (em vez de `nvidia.nix`), blacklista: `nouveau`, `nvidia`, `nvidia_drm`, `nvidia_modeset` via udev + kernel.

---

## 💾 Virtualização

### Configuração (`virtualisation.nix`)

| Serviço | Estado | Detalhe |
|---------|--------|---------|
| Docker | false | Desabilitado |
| Podman | true | Habilitado |
| `dockerCompat` | false | Sem alias docker→podman |
| `dockerSocket.enable` | false | Sem socket docker |
| `defaultNetwork.dns_enabled` | true | DNS entre containers |
| `DBX_CONTAINER_MANAGER` | podman | Distrobox usa podman |
| Grupo podman | xnm | Usuário no grupo podman |

### Pacotes de virtualização

| Pacote | O que faz |
|--------|-----------|
| `nvidia-docker` | Suporte NVIDIA em containers |
| `nerdctl` | CLI compatível com docker (containerd) |
| `distrobox` | Containers como ambientes de desenvolvimento |
| `qemu` | Emulador/virtualizador |
| `lima` | VMs Linux para macOS/Linux |
| `lima-additional-guestagents` | Agentes convidados para Lima |
| `podman-compose` | Docker Compose para Podman |
| `podman-tui` | TUI para Podman |
| `docker-client` | CLI docker (client only) |
| `docker-compose` | Docker Compose CLI |
| `lazydocker` | TUI para Docker/Podman |
| `docker-credential-helpers` | Helpers de credencial Docker |

---

## 🔧 Hardware Específico

### YubiKey (`yubikey.nix`)

| Opção | Valor | O que faz |
|-------|-------|-----------|
| `services.udev.packages` | `yubikey-personalization` | Regras udev para YubiKey |
| `programs.ssh.startAgent` | true | SSH agent iniciado |
| `security.pam.u2f.enable` | true | PAM U2F habilitado |
| `security.pam.u2f.settings.cue` | true | Indica quando tocar no YubiKey |
| `security.pam.u2f.control` | sufficient | U2F suficiente para autenticação |
| `pam.services.greetd.u2fAuth` | true | Login com YubiKey |
| `pam.services.sudo-rs.u2fAuth` | true | Sudo com YubiKey |
| `pam.services.hyprlock.u2fAuth` | true | Unlock com YubiKey |
| `yubikey-manager` | pacote | Gerenciamento de YubiKey |

### Leitor de Impressão Digital (`fingerprint-scanner.nix` — desabilitado)

| Opção | Valor |
|-------|-------|
| `services.fprintd.enable` | true |
| `services.fprintd.tod.enable` | true |
| `services.fprintd.tod.driver` | `libfprint-2-tod1-goodix-550a` |

> **Status:** Módulo comentado no `flake.nix`.

### USB (`usb.nix`)

| Serviço | Opção | Valor |
|---------|-------|-------|
| `services.gvfs` | enable | true (automounting) |
| `services.usbguard` | enable | true |
| `services.usbguard.dbus.enable` | true | Controle via D-Bus |
| `services.usbguard.implicitPolicyTarget` | `block` | Bloqueia tudo por padrão |
| Regras | FIXME | Personalizar com IDs dos dispositivos confiáveis |

---

## 📊 Waybar

Três barras configuradas em `home/.config/waybar/config`:

### Barra Superior (`top_bar`) — `position: top`, height 36

| Módulo | Posição | O que exibe |
|--------|---------|-------------|
| `hyprland/workspaces` | left | Ícones numerados 1–10 + special |
| `hyprland/submap` | left | Modo atual (resize/move) |
| `clock#time` | center | Hora atual (12h + timezone) |
| `custom/separator` | center | `|` |
| `clock#week` | center | Dia da semana |
| `custom/separator_dot` | center | `•` |
| `clock#month` | center | Mês abreviado |
| `custom/separator` | center | `|` |
| `clock#calendar` | center | Data completa + calendário ao hover |
| `bluetooth` | right | Status Bluetooth + bateria dispositivo |
| `network` | right | Status Wi-Fi (sinal%, SSID) |
| `group/misc` | right | Grupo de indicadores |
| `custom/logout_menu` | right | Botão de logout |

**Módulos do `group/misc`:**

| Módulo | O que faz |
|--------|-----------|
| `custom/webcam` | Indica câmera ativa |
| `privacy` | Indica microfone/screenshare ativos |
| `custom/recording` | Indica gravação de tela ativa |
| `custom/geo` | Indica geolocalização ativa |
| `custom/media` | Player de mídia atual |
| `custom/dunst` | Pausa/ativa notificações |
| `custom/night_mode` | Modo noturno (scroll ajusta temperatura) |
| `custom/airplane_mode` | Modo avião |
| `idle_inhibitor` | Inibe ociosidade do sistema |

### Barra Inferior (`bottom_bar`) — `position: bottom`, height 36

| Módulo | Posição | O que exibe |
|--------|---------|-------------|
| `user` | left | Usuário + uptime formatado colorido |
| `hyprland/window` | center | Título da janela ativa |
| `keyboard-state` | right | CapsLock (travado/desbloqueado) |
| `hyprland/language` | right | Layout de teclado atual (🇺🇸/🇺🇦/🇷🇺) |

### Barra Lateral Esquerda (`left_bar`) — `position: left`, width 75

| Módulo | Posição | O que exibe |
|--------|---------|-------------|
| `wlr/taskbar` | top | Ícones das janelas abertas |
| `cpu` | center | Uso CPU % (cores por nível de uso) |
| `memory` | center | Uso memória % |
| `disk` | center | Uso disco % |
| `temperature` | center | Temperatura (ícone + °C) |
| `battery` | center | Bateria (ícone nível + %) |
| `backlight` | center | Brilho % |
| `pulseaudio` | center | Volume saída + microfone |
| `systemd-failed-units` | center | Unidades systemd com falha |
| `tray` | bottom | System tray |

### Estilo Waybar (`style.css`)

- Fundo: `alpha(@base, 0.7)` — translúcido
- Fontes: `JetBrains Mono`, `Symbols Nerd Font`, `Noto Color Emoji`
- Bordas: `alpha(@surface1, 0.7)`
- Barras left/bottom/top com border-radius 15px
- Cores por estado de uso: rosewater (low) → yellow → peach → maroon → red (high)
- Módulo bluetooth: azul (on), sapphire (connected)
- Módulo network: teal (wifi), red (disconnected)

---

## 🚀 Rofi

**Configuração:** `home/.config/rofi/config.rasi`

| Opção | Valor |
|-------|-------|
| `modi` | `drun` |
| `icon-theme` | `Numix-Circle` |
| `font` | `JetBrains Mono Regular 13` |
| `show-icons` | true |
| `terminal` | `wezterm` |
| `drun-display-format` | `{icon} {name}` |
| `location` | `0` (centro) |
| `disable-history` | false |
| `hide-scrollbar` | true |
| `display-drun` | `   Apps ` |
| `sidebar-mode` | true |
| `border-radius` | 10 |
| Tema | `~/.config/rofi/themes/catppuccin-macchiato.rasi` |

**Tema Catppuccin Macchiato (Rofi):**

| Elemento | Cor |
|----------|-----|
| bg-col | `#24273a` (base) |
| blue | `#8aadf4` |
| fg-col | `#cad3f5` |
| fg-col2 | `#ed8796` (red) |
| teal | `#8bd5ca` |
| Border | 2px teal |
| Window | 600×360px |
| Selecionado | cor teal |

---

## 🔔 Dunst

**Configuração:** `home/.config/dunst/dunstrc`

| Opção | Valor |
|-------|-------|
| `frame_color` | `#cad3f5` |
| `separator_color` | frame |
| `font` | `JetBrains Mono Regular 11` |
| `corner_radius` | 10 |
| `offset` | `5x5` |
| `origin` | `top-right` |
| `notification_limit` | 8 |
| `gap_size` | 7 |
| `frame_width` | 2 |
| `width` | 300 |
| `height` | 100 |
| `follow` | keyboard |
| urgency_low background | `#24273A` / foreground `#CAD3F5` |
| urgency_normal background | `#24273A` / foreground `#CAD3F5` |
| urgency_critical background | `#24273A` / foreground `#CAD3F5` / frame `#F5A97F` |

---

## 🗂️ Pyprland (scratchpads)

**Configuração:** `home/.config/pypr/config.toml`

**Plugins ativos:**

| Plugin | O que faz |
|--------|-----------|
| `scratchpads` | Janelas flutuantes toggleáveis |
| `magnify` | Zoom na tela (`pypr zoom`) |
| `expose` | Expõe todas as janelas (`pypr expose`) |
| `shortcuts_menu` | Menu de atalhos customizados |
| `toggle_special` | Toggle de workspace especial |

### Scratchpads configurados

| Nome | Comando | Classe | Animação | Tamanho | Behavior |
|------|---------|--------|----------|---------|---------|
| `term` | `kitty --class terminal-dropterm fish -i -l` | `terminal-dropterm` | fromTop | 75% × 60% (max 1920px) | unfocus=hide; lazy; single; margin 50 |
| `volume` | `pavucontrol` | `org.pulseaudio.pavucontrol` | fromLeft | 40% × 70% | unfocus=hide; lazy; single; margin 90 |

### Shortcuts Menu

| Entrada | Opções | Comando |
|---------|--------|---------|
| `Color picker` | format: hex/rgb/hsv/hsl/cmyk | `hyprpicker --format [format] -a` |

---

## 🎯 Apps de Usuário

### Pacotes do usuário xnm (`users.nix`)

| Pacote | O que faz |
|--------|-----------|
| `spotify` | Streaming de música |
| `pear-desktop` | Aplicativo desktop Pear |
| `discord` | Chat (override: openASAR + TTS) |
| `telegram-desktop` | Mensageiro Telegram |
| `vscodium` | VSCode sem telemetria |
| `brave` | Navegador Brave |

### Pacotes de serviços gerais (`services.nix`)

| Pacote | O que faz |
|--------|-----------|
| `qutebrowser` | Navegador teclado-centrico (via firejail) |
| `zathura` | Leitor de PDF (via firejail) |
| `mpv` | Player de vídeo (via firejail) |
| `mpv-handler` | Handler URI para mpv |
| `imv` | Visualizador de imagens (via firejail) |
| `at-spi2-atk` | Acessibilidade (AT-SPI) |
| `qt6.qtwayland` | Suporte Qt6 Wayland |
| `playerctl` | Controle de player (MPRIS) |
| `psmisc` | Utilitários de processos (killall, fuser) |
| `grim` | Captura de tela Wayland |
| `slurp` | Seleção de área Wayland |
| `imagemagick` | Manipulação de imagens |
| `swappy` | Editor de screenshots |
| `ffmpeg_6-full` | Processamento de vídeo/áudio |
| `wl-screenrec` | Gravador de tela Wayland |
| `wl-clipboard` | Clipboard Wayland |
| `wl-clip-persist` | Persiste clipboard após fechar apps |
| `cliphist` | Histórico de clipboard |
| `xdg-utils` | Utilitários XDG |
| `wtype` | Digita texto via Wayland |
| `wlrctl` | Controla compositors wlroots |
| `waybar` | Barra de status |
| `rofi` | Launcher |
| `dunst` | Notificações |
| `avizo` | OSD de volume/brilho |
| `wlogout` | Menu de logout Wayland |
| `gifsicle` | Manipulação de GIFs |
| `libfido2` | FIDO2/WebAuthn |

### Pacotes de terminal/utilitários (`terminal.nix`)

| Pacote | O que faz |
|--------|-----------|
| `wezterm-flake` | WezTerm (build do flake oficial) |
| `kitty` | Terminal Kitty |
| `cool-retro-term` | Terminal retro |
| `starship` | Prompt customizável |
| `helix` | Editor de texto modal |
| `moreutils` | Utilitários extras Unix |
| `file` | Identifica tipo de arquivo |
| `upx` | Compressor de executáveis |
| `delta` | Diff com highlights |
| `mermaid-cli` | Diagramas Mermaid |
| `posting` | TUI HTTP client |
| `xh` | Cliente HTTP moderno |
| `process-compose` | Gerenciador de processos |
| `zellij` | Multiplexador de terminal |
| `progress` | Monitor de progresso de comandos |
| `noti` | Notificações após comando |
| `topgrade` | Atualiza tudo no sistema |
| `ripgrep` | Busca rápida |
| `nix-ai-tools.ck` | Contador de tokens |
| `rewrk` / `wrk2` | Benchmark HTTP |
| `procs` | ps moderno em Rust |
| `tealdeer` | tldr (resumo de man pages) |
| `monolith` | Salva página web em arquivo único |
| `asciinema` / `asciinema-agg` | Gravação de terminal |
| `aria2` | Downloader multi-protocolo |
| `magic-wormhole-rs` | Transferência segura de arquivos |
| `rage` / `age-plugin-fido2-hmac` / `age-plugin-sss` / `ragenix` | Criptografia age |
| `croc` | Transferência de arquivos |
| `yt-dlp` | Downloader de vídeos |
| `doggo` | DNS query moderno |
| `sd` | sed moderno |
| `ouch` | Compressão/descompressão |
| `duf` | df moderno |
| `ncdu` | Analisador de disco NCurses |
| `dust` | du moderno em Rust |
| `fd` | find moderno |
| `jq` | Processador JSON |
| `trash-cli` | Lixeira para CLI |
| `zoxide` | Navegação rápida de diretórios |
| `tokei` | Contador de linhas de código |
| `fzf` | Fuzzy finder |
| `bat` | cat com syntax highlight |
| `hexyl` | Hex viewer |
| `mdcat` | Renderiza markdown no terminal |
| `treemd` | Árvore em markdown |
| `pandoc` | Conversor de documentos |
| `tabiew` | Viewer de dados tabulares |
| `tidy-viewer` | CSV viewer colorido |
| `qsvlite` | Processador CSV rápido |
| `lsd` | ls moderno |
| `lsof` | Lista arquivos abertos |
| `gping` | ping com gráfico |
| `viu` | Imagens no terminal |
| `tre-command` | tree moderno |
| `yazi` | File manager terminal |
| `chafa` | Imagens no terminal (ASCII art) |
| `jrnl` | Diário em linha de comando |
| `python313Packages.faker` | Gerador de dados falsos |
| `cmatrix` | Matrix no terminal |
| `pipes-rs` | Pipes animados |
| `rsclock` | Relógio no terminal |
| `cava` | Visualizador de áudio |
| `figlet` | Arte ASCII |
| `lolcat` | Arco-íris no terminal |
| `cbonsai` | Bonsai animado |

### Info Fetchers (`info-fetchers.nix`)

| Pacote | O que faz |
|--------|-----------|
| `fastfetch` | Sistema info (com logo NixOS PNG) |
| `onefetch` | Info de repositório git |
| `ipfetch` | Info de IP |
| `cpufetch` | Info de CPU |
| `ramfetch` | Info de RAM |
| `starfetch` | Info de signo |
| `octofetch` | Info do GitHub |
| `htop` | Monitor de processos interativo |
| `bottom` | Monitor moderno (btm) |
| `btop` | Monitor avançado (tema Catppuccin Macchiato) |
| `zfxtop` | Monitor mínimo |
| `kmon` | Monitor de módulos do kernel |
| `nvtopPackages.nvidia` | Monitor GPU NVIDIA |
| `nvtopPackages.intel` | Monitor GPU Intel |
| `wlr-randr` | Configuração de monitors Wayland |
| `gpu-viewer` | Viewer de informações GPU |
| `dig` | DNS query |
| `speedtest-rs` | Teste de velocidade |

### Trabalho (`work.nix`)

| Pacote | O que faz |
|--------|-----------|
| `slack` | Comunicação corporativa (via firejail) |
| `google-cloud-sdk` | Google Cloud CLI |
| `awscli2` | AWS CLI |
| `ssm-session-manager-plugin` | AWS SSM Session Manager |
| `cargo-lambda` | Deploy de Rust para AWS Lambda |
| `gnumake` | Make |
| `cmake` | CMake |
| `firebase-tools` | Firebase CLI |
| `redli` | Redis CLI |
| `postgresql_18` | PostgreSQL 18 |
| `pspg` | Pager para PostgreSQL |
| `androidenv.androidPkgs.androidsdk` | Android SDK |
| `androidenv.androidPkgs.emulator` | Android Emulator |
| `androidenv.androidPkgs.platform-tools` | adb, fastboot |
| `terragrunt` | Wrapper para Terraform |
| `terraform` | IaC Terraform |

### Radicle (`radicle.nix`)

| Pacote/Serviço | Estado |
|----------------|--------|
| `services.radicle` | enable=false, checkConfig=false |
| `radicle-tui` | pacote instalado |
| `radicle-job` | pacote instalado |
| `radicle-native-ci` | pacote instalado |
| `radicle-ci-broker` | pacote instalado |
| `radicle-node` | pacote instalado |

### Teclado (`keyboard.nix`)

| Configuração | Valor |
|-------------|-------|
| `xkb.layout` | `us,ua,ru` |
| `xkb.options` | `grp:alt_shift_toggle` |
| Teclado `klavaro` | Tutor de digitação |
| `gtypist` | Tutor de digitação GNU |
| `via` | Configurador de teclados QMK |

### Serviços gerais (`services.nix`)

| Serviço | Opção | Valor |
|---------|-------|-------|
| `programs.dconf` | enable | true |
| `services.dbus` | enable; implementation=broker | D-Bus com dbus-broker |
| `services.mpd` | enable | true (Media Player Daemon) |
| `programs.thunar` | enable | true (file manager) |
| `programs.xfconf` | enable | true |
| `services.tumbler` | enable | true (thumbnail service) |
| `services.fwupd` | enable | true (firmware updates) |

### Power (`power.nix`)

| Serviço | Opção | Valor | O que faz |
|---------|-------|-------|-----------|
| `services.auto-cpufreq` | enable | false | Desabilitado (conflito com TLP) |
| `services.power-profiles-daemon` | enable | false | Desabilitado (conflito com TLP) |
| `services.thermald` | enable | true | Gestão térmica |
| `services.tlp` | enable | true | Gestão avançada de energia |
| TLP `CPU_SCALING_GOVERNOR_ON_AC` | `powersave` | Escalonamento de CPU na AC |
| TLP `CPU_ENERGY_PERF_POLICY_ON_AC` | `performance` | Política energia AC |
| TLP `CPU_SCALING_GOVERNOR_ON_BAT` | `powersave` | Escalonamento bateria |
| TLP `CPU_ENERGY_PERF_POLICY_ON_BAT` | `balance_power` | Política energia bateria |
| TLP `STOP_CHARGE_THRESH_BAT0` | `1` | Modo conservação de bateria (Lenovo) |
| TLP `CPU_BOOST_ON_AC` | `1` | Turbo boost na AC |
| TLP `CPU_BOOST_ON_BAT` | `0` | Turbo boost desabilitado na bateria |
| TLP `RUNTIME_PM_ON_AC` | `on` | GPU runtime PM na AC |
| TLP `RUNTIME_PM_ON_BAT` | `auto` | GPU runtime PM na bateria |
| TLP `PCIE_ASPM_ON_AC` | `default` | PCIe ASPM na AC |
| TLP `PCIE_ASPM_ON_BAT` | `powersave` | PCIe ASPM na bateria |
| `services.upower` | enable | true | Monitoramento de bateria |
| `psi-notify` | pacote | Notificações de pressão de memória |
| `poweralertd` | pacote | Notificações de bateria |

### Wlogout

| Botão | Ação | Tecla |
|-------|------|-------|
| Lock | `hyprlock` | `l` |
| Hibernate | `systemctl hibernate` | `h` |
| Logout | `loginctl terminate-user $USER` | `e` |
| Shutdown | `systemctl poweroff` | `s` |
| Suspend | `systemctl suspend` | `u` |
| Reboot | `systemctl reboot` | `r` |

---

## 🎨 Tema Catppuccin (onde é aplicado)

| Componente | Variant | Accent | Como aplicado |
|-----------|---------|--------|---------------|
| GTK | Macchiato | Teal | `catppuccin-gtk` overlay; `GTK_THEME` env |
| Plymouth (boot) | Macchiato | — | `catppuccin-plymouth` |
| Hyprland border | Macchiato | Teal ($teal) | `col.active_border` |
| Hyprland shadow | Macchiato | Teal | `color = $teal` |
| Cursor | Macchiato | Teal | `catppuccin-cursors.macchiatoTeal`; `XCURSOR_THEME` |
| Waybar | Macchiato | — | `@import "macchiato.css"` |
| Rofi | Macchiato | Teal | `catppuccin-macchiato.rasi` |
| btop | Macchiato | — | `color_theme = catppuccin_macchiato.theme` |
| Helix | Macchiato | — | `theme = "catppuccin_macchiato_transparent"` |
| WezTerm | Macchiato | — | `color_scheme = 'Catppuccin Macchiato'` |
| Bat | Macchiato | — | `--theme="Catppuccin Macchiato"` |
| Dunst | Macchiato | — | `#24273A` background, `#CAD3F5` foreground |
| Wlogout | Macchiato | — | `rgba(36, 39, 58, 0.7)` |
| Console TTY | Macchiato | — | 16 cores definidas em `theme.nix` |
| FZF | Macchiato | — | `FZF_DEFAULT_OPTS` no `config.fish` |
| Kvantum (Qt) | Macchiato | Teal Standard | `catppuccin-kvantum` |
| Ícones (sistema) | — | Teal | `colloid-icon-theme` override |
| Ícones (Rofi/Waybar) | — | — | `Numix-Circle` |
| Hyprlock | — | — | via hyprland macchiato.conf |

---

## ❌ Módulos desabilitados (comentados no `flake.nix`)

| Módulo | Arquivo | Por que desabilitado (comentário/contexto) |
|--------|---------|---------------------------------------------|
| `disable-nvidia.nix` | `# ./disable-nvidia.nix` | NVIDIA ativo; este módulo blacklistaria drivers |
| `fingerprint-scanner.nix` | `# ./fingerprint-scanner.nix` | Scanner de impressão digital não configurado |
| `clamav-scanner.nix` | `# ./clamav-scanner.nix` | Scan agendado ClamAV (daemon e updater já ativos) |
| `auto-upgrade.nix` | `# ./auto-upgrade.nix` | Atualização manual preferida com `topgrade` |
| `location.nix` | `# ./location.nix` | Geoclue2 não está sendo usado |
| `mac-randomize.nix` | `# ./mac-randomize.nix` | MAC randomization desabilitada |
| `open-ssh.nix` | `# ./open-ssh.nix` | SSH não exposto (usa Mosh) |
| `printing.nix` | `# ./printing.nix` | Impressão não necessária |
| `gnome.nix` | `# ./gnome.nix` | Usando Hyprland, não GNOME |

---

## 📋 Resumo Executivo

| Atributo | Valor |
|----------|-------|
| **Hostname** | `isitreal-laptop` |
| **Usuário** | `xnm` |
| **OS** | NixOS (nixpkgs unstable) |
| **Arquitetura** | x86_64-linux |
| **Compositor** | Hyprland (com UWSM) |
| **Display Manager** | greetd + tuigreet |
| **Shell** | Fish |
| **Editor** | Helix (`hx`) |
| **Terminal principal** | Kitty (lançado com nvidia-offload quando em AC) |
| **Terminal secundário** | WezTerm (flake) |
| **Multiplexador** | Zellij |
| **Browser padrão** | qutebrowser |
| **Browser GUI** | Brave |
| **Browser privacidade** | Mullvad Browser + Tor Browser |
| **Kernel** | `linux_zen` |
| **Fuso horário** | Europe/Kyiv |
| **Locale** | en_US.UTF-8 (+ uk_UA, ru_RU) |
| **Layouts teclado** | us, ua, ru (toggle: Win+Space / Alt+Shift) |
| **GPU** | NVIDIA (Optimus PRIME offload) + Intel integrada |
| **Áudio** | PipeWire + WirePlumber |
| **VPN** | Mullvad |
| **DNS** | dnscrypt-proxy (DoH) |
| **Wi-Fi** | iwd |
| **Bluetooth** | habilitado (não liga no boot) |
| **Virtualização** | Podman |
| **Tema** | Catppuccin Macchiato Teal |
| **Ícones** | Colloid Teal + Numix-Circle |
| **Cursor** | Catppuccin Macchiato Teal |
| **Bootloader** | systemd-boot + Plymouth Catppuccin |
| **Swap** | zram |
| **Segurança** | AppArmor + Firejail + YubiKey U2F + TPM2 + Fail2ban |
| **AI/LLM** | Ollama CUDA (11 modelos) + SearX + aichat + fabric |
| **Linguagens** | Rust, Go, Python, JS/TS, Zig, Lua, Gleam, Numbat, WASM |
| **Gerenciador versões** | mise |
| **Gerenciador pacotes Node** | pnpm + bun |
