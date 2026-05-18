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
      nsgc      = "sudo nix-store --gc";
      ngc       = "sudo nix-collect-garbage -d";
      ngc7      = "sudo nix-collect-garbage --delete-older-than 7d";
      ngc14     = "sudo nix-collect-garbage --delete-older-than 14d";

      # Docker
      dc        = "docker compose";
      dps       = "docker ps";
      dlogs     = "docker logs -f";

      # AI / Dev
      ai           = "aichat";
      ai-commit    = "git diff --staged | aichat -r commit-message | hx";
      ai-emoji-commit = "git diff --staged | aichat -r emoji-commit-message | hx";
      ai-branch    = "git diff --staged | aichat -r git-branch | hx";
      ai-spell     = "vipe | aichat -r improve-writing | hx";
      ai-email     = "vipe | aichat -r email-answer | hx";
      ai-linkedin  = "vipe | aichat -r linkedin-answer | hx";
      aic          = "ai-commit";
      aiec         = "ai-emoji-commit";
      aib          = "ai-branch";
      ais          = "ai-spell";
      aie          = "ai-email";
      ail          = "ai-linkedin";
      lgit         = "lazygit";
      ldocker      = "lazydocker";
      rad          = "rad-tui";

      # Navegação
      conf  = "z ~/.config";
      nixos = "z ~/repo";
      store = "z /nix/store";
      cl    = "clear";

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

      # Direnv (carrega .envrc em cada projeto)
      direnv hook fish | source

      # Mise (runtime version manager)
      mise activate fish | source

      # Transient prompt (limpa prompts anteriores no scroll)
      enable_transience

      # Vi mode no cursor
      set fish_vi_force_cursor
      set fish_cursor_default     block
      set fish_cursor_insert      line blink
      set fish_cursor_visual      underscore blink

      # Cor do comando (Catppuccin Macchiato blue)
      set -g fish_color_command blue

      # FZF — cores Catppuccin Macchiato
      set -gx FZF_DEFAULT_OPTS "\
      --color=bg+:#363a4f,bg:#24273a,spinner:#f4dbd6,hl:#ed8796 \
      --color=fg:#cad3f5,header:#ed8796,info:#c6a0f6,pointer:#f4dbd6 \
      --color=marker:#f4dbd6,fg+:#cad3f5,prompt:#c6a0f6,hl+:#ed8796"

      # PATH extras
      fish_add_path $HOME/.cargo/bin
      fish_add_path $HOME/.npm-packages/bin
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
    EDITOR          = "hx";
    VISUAL          = "hx";
    BROWSER         = "firefox";
    PAGER           = "less";
    VOLUME_STEP     = "5";
    BRIGHTNESS_STEP = "5";
  };

  # Deixar home-manager gerenciar o próprio ambiente
  programs.home-manager.enable = true;

  # ── Dotfiles — deploya home/.config/ para ~/.config/ ─────────────────────
  # fish, kitty e starship são gerenciados pelos blocks programs.* acima.
  # Os demais são linkados diretamente do repositório.
  xdg.configFile = {
    # ── Desktop / Hyprland ──────────────────────────────────────────────────
    "hypr".source         = ./.config/hypr;
    "waybar".source       = ./.config/waybar;
    "rofi".source         = ./.config/rofi;
    "dunst".source        = ./.config/dunst;
    "pypr".source         = ./.config/pypr;
    "wlogout".source      = ./.config/wlogout;
    "avizo".source        = ./.config/avizo;
    "swappy".source       = ./.config/swappy;

    # ── Terminais / Shells ───────────────────────────────────────────────────
    "wezterm".source      = ./.config/wezterm;
    "zellij".source       = ./.config/zellij;

    # Fish: programs.fish gerencia config.fish — linkamos apenas funções e extras
    "fish/functions".source    = ./.config/fish/functions;
    "fish/completions".source  = ./.config/fish/completions;
    "fish/icons".source        = ./.config/fish/icons;

    # ── Editores / Dev ───────────────────────────────────────────────────────
    "helix".source        = ./.config/helix;
    "lazygit".source      = ./.config/lazygit;
    "gh-dash".source      = ./.config/gh-dash;
    "posting".source      = ./.config/posting;

    # ── TUIs / Utilitários ───────────────────────────────────────────────────
    "btop".source         = ./.config/btop;
    "cava".source         = ./.config/cava;
    "yazi".source         = ./.config/yazi;
    "zathura".source      = ./.config/zathura;
    "fastfetch".source    = ./.config/fastfetch;
    "bat".source          = ./.config/bat;
    "bottom".source       = ./.config/bottom;
    "tealdeer".source     = ./.config/tealdeer;

    # ── Multimídia ───────────────────────────────────────────────────────────
    "mpv".source          = ./.config/mpv;

    # ── GTK / Tema ───────────────────────────────────────────────────────────
    "Kvantum".source      = ./.config/Kvantum;
    "gtk-3.0".source      = ./.config/gtk-3.0;
    "gtk-4.0".source      = ./.config/gtk-4.0;

    # ── Apps ─────────────────────────────────────────────────────────────────
    "qutebrowser".source  = ./.config/qutebrowser;
  };
}
