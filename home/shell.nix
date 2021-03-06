{
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    oh-my-zsh = {
      enable = true;
      theme = "gallifrey";
      plugins = [ "git" ];
    };
    shellAliases = {
      cat = "bat";
      ls = "ls -hN --color=auto --group-directories-first";
      k = "kubectl";
      kns = "kubens";
      kcx = "kubectx";
      os = "openstack";
    };
    initExtra = ''
      source <(kubectl completion zsh)
      complete -F __start_kubectl k
    '';
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[»](bold white)";
        error_symbol = "[»](bold red)";
      };
      directory = {
        truncate_to_repo = false;
      };
      kubernetes = {
        disabled = false;
      };
    };
  };
}
