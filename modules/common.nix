{ lib, pkgs, username, hostname, ... }:

{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "nvidia-x11"
      "nvidia-settings"
      "brave"
      "brave-browser"
    ];

  networking.hostName = hostname;
  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "Primary desktop user";
    extraGroups = [ "wheel" "networkmanager" "audio" "video" ];
    initialPassword = "nixos";
    shell = pkgs.zsh;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
    promptInit = ''
      PROMPT='%F{red}[%*] : %. > %f'
    '';
    shellAliases = {
      ls = "ls --color=auto";
      ll = "ls -lah --color=auto";
      la = "eza -lah --icons --git --group-directories-first";
      lt = "eza --tree --level=2 --icons";
      k = "kubectl";
      mk = "minikube";
      vi = "vim -c \"syntax on\"";
    };
    interactiveShellInit = ''
      HISTFILE=~/.zsh_history
      HISTSIZE=10000
      SAVEHIST=10000

      setopt APPEND_HISTORY
      setopt INC_APPEND_HISTORY
      setopt SHARE_HISTORY
      setopt HIST_IGNORE_DUPS
      setopt HIST_IGNORE_ALL_DUPS

      bindkey "[1;5D" backward-word
      bindkey "[1;5C" forward-word

      if command -v dircolors >/dev/null 2>&1; then
        eval "$(dircolors -b)"
        zstyle ':completion:*:default' list-colors "''${(s.:.)LS_COLORS}"
      fi

      zstyle ':completion:*' menu select=long
      zstyle ':completion:*' matcher-list "" 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
      zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
      zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'

      if command -v wl-copy >/dev/null 2>&1 && command -v wl-paste >/dev/null 2>&1; then
        alias pbcopy='wl-copy'
        alias pbpaste='wl-paste'
        alias pbj='pbpaste | jq "." | pbcopy'
      elif command -v xclip >/dev/null 2>&1; then
        alias pbcopy='xclip -selection clipboard'
        alias pbpaste='xclip -selection clipboard -o'
        alias pbj='pbpaste | jq "." | pbcopy'
      fi

      if command -v kubectl >/dev/null 2>&1; then
        source <(kubectl completion zsh)
      fi
      if command -v helm >/dev/null 2>&1; then
        source <(helm completion zsh)
      fi
      if command -v kustomize >/dev/null 2>&1; then
        source <(kustomize completion zsh)
      fi
      bindkey '^[[Z' autosuggest-accept 2>/dev/null || true
      bindkey '^[[27;2;27~' autosuggest-clear 2>/dev/null || true
      bindkey '\e' autosuggest-clear 2>/dev/null || true

      export KUBECONFIG="$HOME/.kube/config"
    '';
  };
  users.defaultUserShell = pkgs.zsh;

  security.sudo.wheelNeedsPassword = true;

  services.openssh.enable = true;
  services.openssh.settings = {
    PasswordAuthentication = false;
    KbdInteractiveAuthentication = false;
    PermitRootLogin = "no";
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
      dates = "weekly";
    };
  };

  environment.systemPackages = with pkgs; [
    vim
    git
    vscodium
    htop
    btop
    curl
    jq
    iproute2
    ethtool
    tldr
    dig
    ripgrep
    kubectl
    helm
    kustomize
    eza
    zsh-completions
    xclip
    wl-clipboard
    wget
    tree
    usbutils
    pciutils
    rsync
  ];

  programs.bash.shellAliases = {
    la = "ls -alh";
    k = "kubectl";
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users.${username} = {
      home.stateVersion = "25.05";
      home.enableNixpkgsReleaseCheck = false;

      home.sessionVariables = {
        EDITOR = "vim";
      };

      programs.git = {
        enable = true;
        settings = {
          user.name = "Sergei Razgulin";
          user.email = "sergei.razgulin@gmail.com";
          core.editor = "vim";
          merge.tool = "vimdiff";
          merge.conflictstyle = "diff3";
          alias = {
            co = "checkout";
            ci = "commit";
            st = "status";
            br = "branch";
            lds = "!git --no-pager log --pretty=format:'%h %ad %s [%cn]' --decorate --date=short";
          };
        };
      };

      programs.vim = {
        enable = true;
        extraConfig = ''
          set mouse=v
        '';
      };
    };
  };
}
