{ pkgs, ... }:

# Home Manager — configuração do ambiente do usuário daniel
# Este arquivo é gerenciado pelo módulo home-manager no flake.nix
{
  home.username    = "devdaniel";
  home.homeDirectory = "/home/devdaniel";

  # Compatível com a versão do home-manager importada no flake
  home.stateVersion = "25.05";

  # ── Pacotes de usuário ────────────────────────────────────────────────────
  home.packages = with pkgs; [
    # Navegadores
    firefox
    brave

    # Comunicação
    telegram-desktop
    discord

    # Produtividade
    obsidian
    libreoffice-fresh

    # Visualizadores
    imv           # imagens
    mpv           # vídeos
    zathura       # PDFs

    # Utilitários
    gnome-calculator
    pavucontrol   # controle de áudio PipeWire/PulseAudio
  ];

  # ── Git ───────────────────────────────────────────────────────────────────
  programs.git = {
    enable      = true;
    userName    = "Daniel";
    # Defina seu email via git config local no projeto (não colocar aqui)
    # userEmail = "seu@email.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase        = false;
      core.editor        = "hx";  # helix
    };
  };

  # ── Fish shell ────────────────────────────────────────────────────────────
  programs.fish = {
    enable = true;

    shellAliases = {
      # NixOS
      nixswitch = "sudo nixos-rebuild switch --flake ~/repo#devdaniel";
      nixbuild  = "sudo nixos-rebuild build --flake ~/repo#devdaniel";
      nixupdate = "nix flake update ~/repo";

      # Docker
      dc        = "docker compose";
      dps       = "docker ps";
      dlogs     = "docker logs -f";

      # Atalhos comuns
      ls  = "eza --icons";
      ll  = "eza -la --icons";
      cat = "bat";
      cd  = "z";  # zoxide
    };

    interactiveShellInit = ''
      # Starship prompt
      starship init fish | source

      # Zoxide (cd inteligente)
      zoxide init fish | source
    '';
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      character = {
        success_symbol = "[❄](bold blue)";
        error_symbol   = "[✗](bold red)";
      };
    };
  };

  # ── Kitty terminal ────────────────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    font = {
      name = "JetBrainsMono Nerd Font";
      size = 13;
    };
    settings = {
      background_opacity = "0.95";
      confirm_os_window_close = 0;
    };
  };

  # ── Variáveis de ambiente do usuário ──────────────────────────────────────
  home.sessionVariables = {
    EDITOR  = "hx";
    VISUAL  = "hx";
    BROWSER = "firefox";
    PAGER   = "less";
  };

  # Deixar home-manager gerenciar o próprio ambiente
  programs.home-manager.enable = true;
}
