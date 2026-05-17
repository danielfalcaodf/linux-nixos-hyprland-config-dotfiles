{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ── Editores ────────────────────────────────────────────────────────
    helix
    vscodium              # VS Code open-source

    # ── Git e controle de versão ────────────────────────────────────────
    git
    lazygit
    gh                    # GitHub CLI
    delta                 # git diff melhorado

    # ── Terminais e shells ──────────────────────────────────────────────
    kitty
    starship              # prompt
    fish

    # ── Utilitários de busca e navegação ───────────────────────────────
    ripgrep               # grep turbinado
    fd                    # find turbinado
    bat                   # cat com syntax highlight
    eza                   # ls moderno
    fzf                   # fuzzy finder
    zoxide                # cd inteligente

    # ── Monitoramento ───────────────────────────────────────────────────
    btop
    htop
    bottom

    # ── Rede ────────────────────────────────────────────────────────────
    curl
    wget
    httpie
    nmap

    # ── Processamento de dados ──────────────────────────────────────────
    jq
    yq-go
    miller

    # ── Containers ──────────────────────────────────────────────────────
    docker-compose
    lazydocker
    dive                  # inspecionar layers Docker

    # ── Linguagens e runtimes ───────────────────────────────────────────
    nodejs_22
    python3
    rustup                # toolchain Rust (gerenciado via rustup)

    # ── Ferramentas de sistema ──────────────────────────────────────────
    tree
    file
    unzip
    zip
    p7zip
    rsync
    tmux
  ];

  # Rust via rustup (não nixpkgs) — mais controle sobre toolchain
  environment.variables.CARGO_HOME = "/home/daniel/.cargo";
  environment.variables.RUSTUP_HOME = "/home/daniel/.rustup";
}
