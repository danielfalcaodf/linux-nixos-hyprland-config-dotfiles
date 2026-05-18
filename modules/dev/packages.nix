{ pkgs, ... }:

{
  # direnv — carrega .envrc automaticamente ao entrar em diretórios de projeto
  programs.direnv.enable = true;

  environment.systemPackages = with pkgs; [
    # ── Editores ────────────────────────────────────────────────────────
    helix
    vscodium              # VS Code open-source

    # ── Git e controle de versão ────────────────────────────────────────
    git
    lazygit
    gh                    # GitHub CLI
    gh-dash               # dashboard PRs e Issues no terminal
    delta                 # git diff melhorado
    gitleaks              # detecção de secrets no histórico git
    lefthook              # hooks git performáticos

    # ── Terminais e shells ──────────────────────────────────────────────
    kitty
    wezterm               # terminal GPU-accelerated (alternativa ao kitty)
    starship              # prompt
    fish
    zellij                # multiplexer de terminal (alternativa ao tmux)

    # ── Utilitários de busca e navegação ───────────────────────────────
    ripgrep               # grep turbinado
    fd                    # find turbinado
    bat                   # cat com syntax highlight
    eza                   # ls moderno
    fzf                   # fuzzy finder
    zoxide                # cd inteligente
    sd                    # sed mais simples
    doggo                 # dig moderno
    tealdeer              # tldr em Rust

    # ── Monitoramento ───────────────────────────────────────────────────
    btop
    htop
    bottom
    procs                 # ps moderno em Rust
    dust                  # du com visualização em árvore
    duf                   # df moderno
    ncdu                  # du interativo

    # ── Rede ────────────────────────────────────────────────────────────
    curl
    wget
    httpie
    posting               # TUI para HTTP (alternativa ao Insomnia/Postman)
    hurl                  # HTTP runner declarativo (CI-friendly)
    nmap

    # ── Processamento de dados ──────────────────────────────────────────
    jq
    yq-go
    miller
    hexyl                 # hex viewer moderno
    tokei                 # contagem de linhas de código

    # ── Containers ──────────────────────────────────────────────────────
    docker-compose
    lazydocker
    dive                  # inspecionar layers Docker

    # ── Utilitários de sistema / hardware ────────────────────────────────
    brightnessctl         # controle de brilho (usado por hypridle.conf)
    firejail              # sandbox de aplicações (usado para Discord)
    wl-screenrec          # gravação de tela Wayland (waybar check: pgrep wl-screenrec)
    iwgtk                 # GUI WiFi GTK (waybar: network right-click)

    # ── Build e compilação ───────────────────────────────────────────────
    gcc
    clang
    mold                  # linker rápido (alternativa ao lld)
    lld
    lldb
    musl                  # libc estática para binários portáveis

    # ── Task runners e ferramentas de projeto ───────────────────────────
    just                  # task runner moderno (alternativa ao make)
    mise                  # gerenciador de runtimes (nvm/pyenv/rbenv unificado)

    # ── Linguagens e runtimes ───────────────────────────────────────────
    nodejs_22
    python3
    rustup                # toolchain Rust (gerenciado via rustup)

    # ── Utilitários de arquivo e transferência ──────────────────────────
    tree
    file
    unzip
    zip
    p7zip
    rsync
    tmux
    ouch                  # compressão/descompressão universal
    trash-cli             # lixeira no terminal (rm seguro)
    magic-wormhole-rs     # transferência segura de arquivos ponto-a-ponto

    # ── Multimídia e produtividade ──────────────────────────────────────
    asciinema             # gravar sessões de terminal
    asciinema-agg         # converter gravações para GIF
    yt-dlp                # download de vídeos
  ];

  # Rust via rustup (não nixpkgs) — mais controle sobre toolchain
  environment.variables.CARGO_HOME = "/home/devdaniel/.cargo";
  environment.variables.RUSTUP_HOME = "/home/devdaniel/.rustup";
}
