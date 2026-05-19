# 📦 Inventário e Manual de Instalação — devdaniel NixOS

> Branch: `feat/devdaniel-nixos-config`  
> NixOS: `nixos-unstable` (≥ 25.11)  
> Usuário: `devdaniel` | Host: `devdaniel`

---

## Índice

1. [Visão Geral da Estrutura](#1-visão-geral-da-estrutura)
2. [Inventário de Módulos](#2-inventário-de-módulos)
3. [Inventário de Pacotes](#3-inventário-de-pacotes)
4. [Dotfiles Deployados (Home Manager)](#4-dotfiles-deployados-home-manager)
5. [Serviços Homelab](#5-serviços-homelab)
6. [Acesso Remoto](#6-acesso-remoto)
7. [Pré-instalação](#7-pré-instalação)
8. [Instalação](#8-instalação)
9. [Pós-instalação](#9-pós-instalação)
10. [Manutenção](#10-manutenção)
11. [Rollback](#11-rollback)

---

## 1. Visão Geral da Estrutura

```
.
├── flake.nix                          # Ponto de entrada principal
├── hosts/
│   └── devdaniel/
│       ├── configuration.nix          # Configuração do host (locale, teclado, bootloader)
│       ├── hardware-configuration.nix # ⚠️ NÃO versionado — copie do seu sistema
│       └── hardware-configuration.nix.example
├── modules/
│   ├── system/                        # Configurações base do SO
│   ├── desktop/                       # Hyprland, áudio, fontes
│   ├── dev/                           # Ferramentas de desenvolvimento
│   ├── homelab/                       # Docker, Caddy, DNS local
│   └── remote-access/                 # RustDesk, WayVNC, XRDP
├── home/
│   ├── devdaniel.nix                  # Config do Home Manager
│   └── .config/                       # Dotfiles (linkados pelo HM)
├── stacks/
│   ├── databases/                     # Docker Compose: bancos de dados
│   ├── n8n/                           # Docker Compose: automação
│   └── portainer/                     # Docker Compose: gestão de containers
└── legacy/
    └── original-xnm1/                 # Configuração original do fork (referência)
```

---

## 2. Inventário de Módulos

### 🖥️ Sistema (`modules/system/`)

| Arquivo | O que faz |
|---|---|
| `nix-settings.nix` | Habilita flakes + nix-command; caches binários (nixos, nix-community, numtide, devenv); GC automático semanal (14 dias); otimização automática da store; `allowUnfree = true` |
| `bootloader.nix` | systemd-boot (EFI); timeout 2s; Plymouth com tema Catppuccin Macchiato; initrd systemd habilitado (boot mais rápido) |
| `users.nix` | Usuário `devdaniel`; grupos: wheel, docker, networkmanager, audio, video, input; shell Fish; RuntimeDirectorySize 4G |
| `networking.nix` | NetworkManager com dnsmasq integrado; IPv6 habilitado |
| `firewall.nix` | Firewall ativo; portas abertas: 22 (SSH), 80 (HTTP), 443 (HTTPS) |
| `ssh.nix` | OpenSSH habilitado; sem login por senha; sem login root; apenas usuário `devdaniel` |
| `services.nix` | dconf, Thunar, xfconf, Tumbler (thumbnails), fwupd (firmware updates), mpv, ffmpeg, playerctl, imagemagick, avizo |
| `printing.nix` | CUPS habilitado (impressoras locais e de rede) |

### 🎨 Desktop (`modules/desktop/`)

| Arquivo | O que faz |
|---|---|
| `hyprland.nix` | Hyprland + UWSM; variáveis Wayland (NIXOS_OZONE_WL, XDG_SESSION_TYPE); hyprlock + hypridle; XDG portal (hyprland + gtk); greetd + tuigreet como display manager; pacotes: pyprland, hyprpaper, hyprpicker, hyprcursor, hyprpolkitagent, hyprsunset, waybar, dunst, rofi, grim, slurp, wf-recorder, wl-clipboard, cliphist, yazi, thunar, cool-retro-term |
| `audio.nix` | PipeWire (substitui PulseAudio); ALSA 32-bit; WirePlumber; RTKit (áudio real-time); Bluetooth com perfis A2DP/HFP; blueman; pamixer, pavucontrol, overskride |
| `fonts.nix` | JetBrainsMono Nerd Font, FiraCode Nerd Font, Hack Nerd Font, Symbols Only; Inter, Roboto, Source Han Sans (CJK), Noto Fonts, Noto Color Emoji; fontconfig com padrões definidos |

### 🛠️ Desenvolvimento (`modules/dev/`)

| Arquivo | O que faz |
|---|---|
| `packages.nix` | 50+ ferramentas (ver [seção 3](#3-inventário-de-pacotes)); direnv; variáveis CARGO_HOME e RUSTUP_HOME para `/home/devdaniel` |

### 🏠 Homelab (`modules/homelab/`)

| Arquivo | O que faz |
|---|---|
| `docker.nix` | Docker daemon; auto-prune semanal; log driver json-file com limite 10MB/3 arquivos; lazydocker, ctop |
| `caddy.nix` | Reverse proxy com TLS interno auto-assinado; domínios: portainer, n8n, uptime, grafana, home, adminer (todos em `*.devdaniel.home.arpa`) |
| `dns-local.nix` | dnsmasq resolve `*.devdaniel.home.arpa → 127.0.0.1`; upstream: 1.1.1.1 e 8.8.8.8; domain-needed e bogus-priv ativos |

### 🔗 Acesso Remoto (`modules/remote-access/`)

| Arquivo | O que faz |
|---|---|
| `rustdesk.nix` | Cliente RustDesk instalado; servidor self-hosted comentado (habilitar se necessário) |
| `wayvnc.nix` | Módulo opcional (`homelab.wayvnc.enable = true`); VNC nativo Wayland; serviço systemd de usuário; acesso via túnel SSH recomendado |
| `xrdp-xfce.nix` | Módulo opcional (`homelab.xrdp.enable = true`); XRDP + XFCE para acesso RDP; compatível com Windows Remote Desktop, Remmina, FreeRDP |

---

## 3. Inventário de Pacotes

### 📝 Editores e IDE

| Pacote | O que faz |
|---|---|
| `helix` | Editor modal moderno em Rust (alternativa ao Neovim); LSP nativo |
| `vscodium` | VS Code open-source sem telemetria da Microsoft |

### 🔀 Git e Controle de Versão

| Pacote | O que faz |
|---|---|
| `git` | Controle de versão |
| `lazygit` | TUI para git — navegar commits, branches, diffs visualmente |
| `gh` | GitHub CLI — PRs, issues, repos direto do terminal |
| `gh-dash` | Dashboard TUI de PRs e Issues do GitHub |
| `delta` | Git diff com syntax highlight e side-by-side |
| `gitleaks` | Detecta secrets acidentais no histórico git |
| `lefthook` | Hooks git em Go — mais rápido que husky |

### 💻 Terminais e Shell

| Pacote | O que faz |
|---|---|
| `kitty` | Terminal GPU-accelerated (gerenciado via HM) |
| `wezterm` | Terminal GPU-accelerated alternativo com config em Lua |
| `starship` | Prompt customizável para qualquer shell |
| `fish` | Shell moderno com autocompletion e syntax highlight |
| `zellij` | Multiplexer de terminal (alternativa ao tmux) |

### 🔍 Busca e Navegação

| Pacote | O que faz |
|---|---|
| `ripgrep` | grep turbinado em Rust (10x mais rápido) |
| `fd` | find moderno com sintaxe mais simples |
| `bat` | cat com syntax highlighting e line numbers |
| `eza` | ls moderno com ícones, git status e cores |
| `fzf` | Fuzzy finder interativo para qualquer lista |
| `zoxide` | cd inteligente que aprende seus diretórios frequentes |
| `sd` | sed mais simples e intuitivo |
| `doggo` | dig moderno com output colorido |
| `tealdeer` | tldr em Rust — resumo de man pages |
| `yazi` | File manager TUI com preview de imagens |

### 📊 Monitoramento

| Pacote | O que faz |
|---|---|
| `btop` | Monitor de sistema moderno (CPU, RAM, rede, disco) |
| `htop` | Monitor interativo clássico |
| `bottom` | Monitor em Rust com gráficos |
| `procs` | ps moderno com busca e filtros |
| `dust` | du com visualização em árvore |
| `duf` | df moderno com barras de uso |
| `ncdu` | du interativo no terminal |
| `ctop` | top para containers Docker |

### 🌐 Rede e HTTP

| Pacote | O que faz |
|---|---|
| `curl` | HTTP client clássico |
| `wget` | Download de arquivos |
| `httpie` | HTTP client amigável com syntax highlight |
| `posting` | TUI para APIs REST (alternativa ao Insomnia/Postman) |
| `hurl` | HTTP runner declarativo em texto (ideal para CI) |
| `nmap` | Scanner de rede e portas |

### 📦 Processamento de Dados

| Pacote | O que faz |
|---|---|
| `jq` | Processar e filtrar JSON no terminal |
| `yq-go` | jq para YAML, TOML e XML |
| `miller` | Processamento de CSV, JSON, TSV como banco de dados |
| `hexyl` | Hex viewer colorido no terminal |
| `tokei` | Contar linhas de código por linguagem |

### 🐋 Containers

| Pacote | O que faz |
|---|---|
| `docker-compose` | Orquestração de containers multi-serviço |
| `lazydocker` | TUI para Docker — containers, logs, stats |
| `dive` | Inspecionar e otimizar layers de imagens Docker |

### ⚙️ Build e Compilação

| Pacote | O que faz |
|---|---|
| `gcc` | GNU Compiler Collection (C/C++) |
| `clang` | Compilador C/C++ LLVM |
| `mold` | Linker ultra-rápido (substitui lld para builds grandes) |
| `lld` | Linker LLVM |
| `lldb` | Debugger LLVM |
| `musl` | libc estática para binários portáveis |

### 🏃 Task Runners

| Pacote | O que faz |
|---|---|
| `just` | Task runner moderno (Makefile mais simples) |
| `mise` | Gerenciador unificado de runtimes (nvm + pyenv + rbenv em um) |
| `direnv` | Carrega `.envrc` automaticamente ao entrar no diretório |

### 🔤 Linguagens e Runtimes

| Pacote | O que faz |
|---|---|
| `nodejs_22` | Node.js LTS v22 |
| `python3` | Python 3 (versão do nixpkgs unstable) |
| `rustup` | Gerenciador do toolchain Rust (não via nixpkgs) |

### 📁 Arquivos e Transferência

| Pacote | O que faz |
|---|---|
| `tree` | Exibir estrutura de diretórios em árvore |
| `file` | Identificar tipo de arquivo |
| `unzip`, `zip`, `p7zip` | Compressão/descompressão de arquivos |
| `ouch` | Compressão/descompressão universal (tar, gz, zip, 7z, etc.) |
| `rsync` | Sincronização eficiente de arquivos |
| `tmux` | Multiplexer de terminal clássico |
| `trash-cli` | Lixeira no terminal (rm seguro) |
| `magic-wormhole-rs` | Transferência segura ponto-a-ponto via código |

### 🎬 Multimídia

| Pacote | O que faz |
|---|---|
| `asciinema` | Gravar sessões de terminal |
| `asciinema-agg` | Converter gravações para GIF animado |
| `yt-dlp` | Download de vídeos (YouTube, Twitch, etc.) |

### 🧑‍💻 Aplicativos do Usuário (Home Manager)

| Pacote | O que faz |
|---|---|
| `firefox` | Navegador principal |
| `brave` | Navegador alternativo com bloqueador de ads nativo |
| `telegram-desktop` | Mensagens |
| `discord` | Comunicação (unfree — requer allowUnfree) |
| `obsidian` | Notas em Markdown com links bidirecionais |
| `libreoffice-fresh` | Suite de escritório |
| `imv` | Visualizador de imagens leve |
| `mpv` | Player de vídeo/áudio |
| `zathura` | Visualizador de PDFs |
| `gnome-calculator` | Calculadora |
| `pavucontrol` | Controle de áudio PipeWire |

---

## 4. Dotfiles Deployados (Home Manager)

O Home Manager linka automaticamente os arquivos de `home/.config/` para `~/.config/`. Qualquer edição nos arquivos do repositório reflete no sistema após `nixos-rebuild switch`.

| Config | Caminho | O que configura |
|---|---|---|
| `hypr/` | `~/.config/hypr/` | Hyprland (keybinds, monitores, windowrules, animações, exec-once) |
| `waybar/` | `~/.config/waybar/` | Barra de status (módulos, estilos CSS, posição) |
| `rofi/` | `~/.config/rofi/` | Launcher de aplicativos (tema, fonte, layout) |
| `dunst/` | `~/.config/dunst/` | Notificações (posição, tema, timeout, ícones) |
| `pypr/` | `~/.config/pypr/` | Plugin manager Hyprland (scratchpads, zoom) |
| `wlogout/` | `~/.config/wlogout/` | Menu de saída (desligar, reiniciar, suspender, logout) |
| `avizo/` | `~/.config/avizo/` | OSD volume/brilho no Wayland |
| `swappy/` | `~/.config/swappy/` | Editor de capturas de tela |
| `wezterm/` | `~/.config/wezterm/` | Config do terminal WezTerm (Lua) |
| `zellij/` | `~/.config/zellij/` | Config do multiplexer Zellij |
| `helix/` | `~/.config/helix/` | Config do editor Helix (temas, LSPs, keymaps) |
| `lazygit/` | `~/.config/lazygit/` | Config do TUI do git |
| `gh-dash/` | `~/.config/gh-dash/` | Dashboard GitHub PRs/Issues |
| `posting/` | `~/.config/posting/` | Config do cliente HTTP TUI |
| `btop/` | `~/.config/btop/` | Tema e layout do monitor de sistema |
| `cava/` | `~/.config/cava/` | Visualizador de áudio no terminal |
| `yazi/` | `~/.config/yazi/` | File manager TUI (plugins, keymaps, temas) |
| `zathura/` | `~/.config/zathura/` | Config do visualizador de PDF (tema, zoom) |
| `fastfetch/` | `~/.config/fastfetch/` | System info display (logo, campos) |
| `bat/` | `~/.config/bat/` | Tema de syntax highlight do bat |
| `bottom/` | `~/.config/bottom/` | Layout e tema do monitor bottom |
| `tealdeer/` | `~/.config/tealdeer/` | Config do cliente tldr |
| `mpv/` | `~/.config/mpv/` | Config do player de vídeo |
| `Kvantum/` | `~/.config/Kvantum/` | Tema Qt (visual das apps Qt) |
| `gtk-3.0/` | `~/.config/gtk-3.0/` | Tema GTK3 |
| `gtk-4.0/` | `~/.config/gtk-4.0/` | Tema GTK4 |
| `qutebrowser/` | `~/.config/qutebrowser/` | Navegador baseado em teclado (config Python) |

### Gerenciados via `programs.*` (não via xdg.configFile)

| Programa | Gerenciado por |
|---|---|
| Fish shell | `programs.fish` em `home/devdaniel.nix` |
| Kitty | `programs.kitty` em `home/devdaniel.nix` |
| Starship | `programs.starship` em `home/devdaniel.nix` |
| Git | `programs.git` em `home/devdaniel.nix` |

---

## 5. Serviços Homelab

### Docker Stacks (`stacks/`)

| Stack | Porta | URL (via Caddy) | O que faz |
|---|---|---|---|
| `portainer/` | 9000 | `portainer.devdaniel.home.arpa` | GUI web para gerenciar containers Docker |
| `n8n/` | 5678 | `n8n.devdaniel.home.arpa` | Automação de workflows (alternativa ao Zapier) |
| `databases/` | vários | — | PostgreSQL, MySQL, Redis, Adminer |

### Caddy Reverse Proxy

Todos os serviços ficam em `*.devdaniel.home.arpa` com HTTPS via TLS interno:

| Subdomínio | Porta interna | Serviço |
|---|---|---|
| `portainer.devdaniel.home.arpa` | 9000 | Portainer |
| `n8n.devdaniel.home.arpa` | 5678 | n8n |
| `uptime.devdaniel.home.arpa` | 3001 | Uptime Kuma |
| `grafana.devdaniel.home.arpa` | 3000 | Grafana |
| `home.devdaniel.home.arpa` | 3100 | Homepage/Homarr (dashboard) |
| `adminer.devdaniel.home.arpa` | 8080 | Adminer (GUI banco de dados) |

---

## 6. Acesso Remoto

| Método | Estado | Como habilitar |
|---|---|---|
| **SSH** | ✅ Ativo por padrão | Porta 22; apenas chave pública; sem senha |
| **RustDesk** | ✅ Cliente instalado | Abre o app e use normalmente; servidor self-hosted: descomente em `rustdesk.nix` |
| **WayVNC** | ⏸️ Módulo opcional | `homelab.wayvnc.enable = true` em `configuration.nix`; acesse via SSH tunnel |
| **XRDP** | ⏸️ Módulo opcional | `homelab.xrdp.enable = true` em `configuration.nix`; porta 3389 |

---

## 7. Pré-instalação

### Requisitos de Hardware

| Componente | Mínimo | Recomendado |
|---|---|---|
| CPU | 2 cores x86_64 | 4+ cores |
| RAM | 4 GB | 8+ GB |
| Disco | 30 GB SSD | 100+ GB NVMe |
| Modo boot | UEFI obrigatório | UEFI + Secure Boot desabilitado |
| GPU | Qualquer (software fallback) | Intel/AMD (drivers livres) |

> ⚠️ **NVIDIA**: requer configuração adicional de driver. Não incluído nesta branch.

### Passo 1 — Baixar o ISO do NixOS

```bash
# Acesse https://nixos.org/download e baixe o ISO Graphical (GNOME)
# Gravando em USB com dd:
sudo dd if=nixos-graphical-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

### Passo 2 — Boot e Instalação Básica

1. Boot pelo USB
2. Na tela do instalador: escolha **"NixOS Graphical Installer"**
3. Configure partições (recomendado: GPT + partição EFI 512MB + ext4/btrfs para `/`)
4. Anote o disco e as partições que serão usadas

### Passo 3 — Clonar o Repositório

Após a instalação base e primeiro boot:

```bash
# Instalar git temporariamente
nix-shell -p git

# Clonar o repositório
git clone https://github.com/danielfalcaodf/linux-nixos-hyprland-config-dotfiles.git ~/repo
cd ~/repo

# Mudar para a branch correta
git checkout feat/devdaniel-nixos-config
```

### Passo 4 — Copiar o hardware-configuration.nix

```bash
# O hardware-configuration.nix gerado na instalação fica em /etc/nixos/
# Copie-o para o repositório (ele NÃO é versionado por segurança)
cp /etc/nixos/hardware-configuration.nix ~/repo/hosts/devdaniel/hardware-configuration.nix

# Verificar o conteúdo antes de usar
cat ~/repo/hosts/devdaniel/hardware-configuration.nix
```

> 💡 Veja `hosts/devdaniel/hardware-configuration.nix.example` como referência da estrutura esperada.

### Passo 5 — Adicionar ao git index (obrigatório para Nix Flakes)

```bash
# Nix flakes só enxergam arquivos no git index
# O hardware-configuration.nix não é commitado, mas precisa ser staged
git add --force hosts/devdaniel/hardware-configuration.nix
```

### Passo 6 — Revisar configurações pessoais

Antes de aplicar, edite os arquivos abaixo conforme seu ambiente:

**`hosts/devdaniel/configuration.nix`** — verifique:
- `time.timeZone` — seu fuso horário
- `console.keyMap` — layout do teclado no console
- `services.xserver.xkb.layout` — layout no ambiente gráfico

**`modules/system/ssh.nix`** — se quiser acesso SSH, adicione sua chave pública:
```nix
# Em modules/system/users.nix, descomente e adicione:
openssh.authorizedKeys.keys = [
  "ssh-ed25519 AAAA... devdaniel@outro-pc"
];
```

**`home/devdaniel.nix`** — configure seu email do git:
```nix
programs.git = {
  userEmail = "seu@email.com";  # adicione esta linha
};
```

---

## 8. Instalação

### Build e verificação (sem aplicar)

```bash
cd ~/repo

# Verificar se a build passa sem erros
nix --extra-experimental-features 'nix-command flakes' build \
  '.#nixosConfigurations.devdaniel.config.system.build.toplevel'

# Se der erro, veja a seção de troubleshooting abaixo
```

### Aplicar a configuração

```bash
# Primeira aplicação (como root ou com sudo)
sudo nixos-rebuild switch --flake ~/repo#devdaniel

# Ou usando o alias configurado no Fish (após primeiro switch):
nixswitch
```

> ⚠️ O primeiro switch pode demorar 10–30 minutos dependendo da conexão e hardware.

### Verificar sucesso

```bash
# Verificar geração atual do bootloader
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Verificar serviços ativos
systemctl status caddy docker
```

---

## 9. Pós-instalação

### Configurar senha do usuário

```bash
# No primeiro boot, faça login via TTY (Ctrl+Alt+F2)
# Usuário: devdaniel (sem senha ainda)

# Definir senha
passwd devdaniel

# Voltar para o Hyprland
Ctrl+Alt+F1
```

### DNS local e CA do Caddy

O workstation age como **servidor DNS local** para toda a rede, resolvendo `*.devdaniel.home.arpa`.

#### 1. Configure o IP estático do workstation

Edite `modules/homelab/dns-local.nix` e defina `workstationLanIP`:

```nix
let
  workstationLanIP = "192.168.1.100";  # ← altere para o IP real
```

Para definir o IP estático via NixOS (adicione em `configuration.nix` ou `networking.nix`):

```nix
networking.interfaces.enp3s0.ipv4.addresses = [{  # ← troque a interface
  address      = "192.168.1.100";
  prefixLength = 24;
}];
networking.defaultGateway = "192.168.1.1";
```

Descubra a interface e IP atual:

```bash
ip route | grep default          # ex: default via 192.168.1.1 dev enp3s0
ip addr show enp3s0              # IP atual
```

#### 2. Aplique a config no workstation

```bash
sudo nixos-rebuild switch --flake .#devdaniel

# Verifique o dnsmasq
systemctl status dnsmasq
dig portainer.devdaniel.home.arpa @127.0.0.1   # deve retornar 192.168.1.100
```

#### 3. Configure os outros PCs para usar este DNS

**Opção A — Configuração por PC (manual):**

```bash
# Linux com NetworkManager:
nmcli con show                                  # anote o nome da conexão
nmcli con mod "Nome da Conexão" ipv4.dns "192.168.1.100"
nmcli con mod "Nome da Conexão" ipv4.ignore-auto-dns yes
nmcli con up  "Nome da Conexão"

# Teste:
dig portainer.devdaniel.home.arpa               # deve retornar 192.168.1.100
curl -k https://portainer.devdaniel.home.arpa   # deve responder (TLS warning = normal antes de instalar o CA)
```

```powershell
# Windows (PowerShell como Admin):
Get-NetAdapter                                  # anote o nome da interface
Set-DnsClientServerAddress -InterfaceAlias "Ethernet" -ServerAddresses "192.168.1.100"

# Teste:
Resolve-DnsName portainer.devdaniel.home.arpa
```

**Opção B — Via roteador (recomendado, todos os PCs recebem automaticamente):**

Acesse o painel do roteador → DHCP → DNS Server → defina `192.168.1.100`.
Todos os novos clientes DHCP receberão o DNS do workstation automaticamente.

#### 4. Instale o CA do Caddy para confiar no HTTPS

O CA é exportado automaticamente pelo Caddy e disponível em HTTP na porta 8888.

```bash
# No workstation (após nixos-rebuild):
systemctl status caddy-export-ca
ls -la /etc/caddy/ca.crt                        # deve existir

# Em outro PC da mesma rede:
curl -O http://192.168.1.100:8888/ca.crt        # baixa o CA cert

# Linux (Debian/Ubuntu/NixOS com update-ca-certificates):
sudo cp ca.crt /usr/local/share/ca-certificates/caddy-devdaniel.crt
sudo update-ca-certificates

# Linux (Arch/Fedora com update-ca-trust):
sudo cp ca.crt /etc/pki/ca-trust/source/anchors/caddy-devdaniel.crt
sudo update-ca-trust

# Firefox (qualquer OS):
# Preferências → Privacidade → Certificados → Importar → selecione ca.crt
# Marque "Confiar para identificar sites"

# Windows (PowerShell Admin):
Import-Certificate -FilePath ca.crt -CertStoreLocation Cert:\LocalMachine\Root

# macOS:
sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain ca.crt
```

**Verificação final (em outro PC após instalar CA e DNS):**

```bash
curl https://portainer.devdaniel.home.arpa      # sem erro de certificado
curl https://n8n.devdaniel.home.arpa
curl https://home.devdaniel.home.arpa
```

### Subir os Docker Stacks

```bash
cd ~/repo/stacks/portainer
docker compose up -d

cd ~/repo/stacks/databases
docker compose up -d

cd ~/repo/stacks/n8n
docker compose up -d
```

### Configurar git com seu email

```bash
# Por projeto (recomendado — não expõe email no repo)
cd ~/seu-projeto
git config user.email "seu@email.com"

# Ou globalmente (editando home/devdaniel.nix e rodando nixswitch)
```

### Verificar dotfiles deployados

```bash
# Verificar se os links simbólicos foram criados
ls -la ~/.config/hypr
ls -la ~/.config/waybar
ls -la ~/.config/helix
```

### Rust — instalar toolchain via rustup

```bash
# O rustup está instalado, mas o toolchain precisa ser inicializado
rustup toolchain install stable
rustup default stable

# Para projetos web/WASM
rustup target add wasm32-unknown-unknown
```

### Node.js — verificar versão

```bash
node --version   # deve retornar v22.x.x
npm --version

# Instalar pnpm ou bun globalmente se necessário
npm install -g pnpm
```

### Verificar Hyprland

```bash
# Verificar se hyprland está rodando corretamente
hyprctl version
hyprctl monitors

# Ver logs do Hyprland
journalctl --user -u hyprland.service -f
```

### Configurar SSH (acesso remoto)

```bash
# Se quiser acessar esta máquina via SSH, adicione sua chave pública
# em modules/system/users.nix:
#   openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
# Depois rode: nixswitch

# Para acessar outras máquinas, gere uma chave:
ssh-keygen -t ed25519 -C "devdaniel@$(hostname)"
cat ~/.ssh/id_ed25519.pub  # copie e adicione no GitHub/GitLab/servidor
```

---

## 10. Manutenção

### Aliases disponíveis no Fish

| Alias | Comando completo | O que faz |
|---|---|---|
| `nixswitch` | `sudo nixos-rebuild switch --flake ~/repo#devdaniel` | Aplica mudanças da configuração |
| `nixbuild` | `sudo nixos-rebuild build --flake ~/repo#devdaniel` | Builda sem aplicar (teste) |
| `nixupdate` | `nix flake update ~/repo` | Atualiza nixpkgs e home-manager |
| `ls` | `eza --icons` | Listagem moderna |
| `ll` | `eza -la --icons` | Listagem detalhada |
| `cat` | `bat` | Cat com syntax highlight |
| `cd` | `z` (zoxide) | cd inteligente |
| `dc` | `docker compose` | Docker Compose |
| `dps` | `docker ps` | Listar containers |
| `dlogs` | `docker logs -f` | Logs de container |

### Atualizar o sistema

```bash
# 1. Atualizar flake.lock (novos commits do nixpkgs)
nixupdate

# 2. Revisar o que mudou (opcional)
nix flake metadata ~/repo

# 3. Buildar e verificar (opcional)
nixbuild

# 4. Aplicar
nixswitch
```

### Limpeza manual do Nix store

```bash
# Remover gerações antigas (automático semanalmente, mas pode forçar)
sudo nix-collect-garbage --delete-older-than 14d

# Otimizar store (hardlinks)
sudo nix store optimise
```

### Adicionar novo módulo

```bash
# 1. Crie o arquivo em modules/<categoria>/novo.nix
# 2. Adicione ao flake.nix na lista de modules:
#      ./modules/<categoria>/novo.nix
# 3. Aplique:
nixswitch
```

---

## 11. Rollback

### Rollback imediato (sem reiniciar)

```bash
# Listar gerações disponíveis
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Voltar para a geração anterior
sudo nixos-rebuild switch --rollback
```

### Rollback via GRUB (se o sistema não iniciar)

1. Na tela do GRUB, selecione **"NixOS — All configurations"**
2. Escolha a geração anterior (identificada pela data)
3. O sistema inicia com a configuração anterior
4. Após resolver o problema, aplique novamente com `nixswitch`

### Rollback para geração específica

```bash
# Ver gerações
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Ativar geração específica (ex: geração 5)
sudo nix-env --switch-generation 5 --profile /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration switch
```

---

## Troubleshooting

### Erro: `hardware-configuration.nix not found`

```bash
cp /etc/nixos/hardware-configuration.nix ~/repo/hosts/devdaniel/
git add --force ~/repo/hosts/devdaniel/hardware-configuration.nix
```

### Erro: `unfree package refused`

Já configurado em `modules/system/nix-settings.nix` e `flake.nix`. Se persistir:
```bash
export NIXPKGS_ALLOW_UNFREE=1
nixos-rebuild switch --flake ~/repo#devdaniel --impure
```

### Erro: `rofi-wayland has been merged into rofi`

Já corrigido nesta branch. Use `pkgs.rofi` (não `pkgs.rofi-wayland`).

### Tela preta após login no Hyprland (VirtualBox)

Use a branch `feat/vm-compat` em vez de `feat/devdaniel-nixos-config`:
```bash
git checkout feat/vm-compat
nixswitch
```

### Plymouth travando no boot (VM)

Use a branch `feat/vm-compat` (Plymouth desabilitado para VMs).

### Build demora muito na primeira vez

Normal — o Nix está baixando todos os pacotes. Verifique sua conexão e aguarde.
Os caches configurados (`nix-community`, `numtide`) agilizam downloads subsequentes.

---

*Gerado automaticamente com base na branch `feat/devdaniel-nixos-config` — NixOS unstable (25.11+)*
