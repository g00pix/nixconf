{ pkgs, config, lib, ... }:

{
  imports = [
    ./gui
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
    LESS_TERMCAP_mb = "[1;32m";
    LESS_TERMCAP_md = "[1;32m";
    LESS_TERMCAP_me = "[0m";
    LESS_TERMCAP_se = "[0m";
    LESS_TERMCAP_so = "[01;33m";
    LESS_TERMCAP_ue = "[0m";
    LESS_TERMCAP_us = "[1;4;31m";
  };

  programs.git = {
    enable = true;
    userName = "Nicolas Froger";
    userEmail = "nicolas@kektus.xyz";
    signing = {
      signByDefault = true;
      key = "00BD4B2A4EBA035CC102E0B5B7D7C14018816976";
    };
    includes = [
      {
        condition = "gitdir:~/Documents/cri/";
        contents = {
          user = {
            email = "nico@cri.epita.fr";
          };
        };
      }
      {
        condition = "gitdir:~/Documents/epita/";
        contents = {
          user = {
            email = "nicolas.froger@epita.fr";
          };
        };
      }
      {
        condition = "gitdir:~/Documents/zelros/";
        contents = {
          user = {
            email = "nicolas.froger@zelros.com";
            signingKey = "E5C5184FEC5F8C6AB7BD56AC8552733297F5B117";
          };
        };
      }
    ];
  };

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
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.neovim = {
    enable = true;
    vimAlias = true;
    #coc = {
    #  enable = true;
    #};
    plugins = with pkgs.vimPlugins; [
      emmet-vim
      {
        plugin = vimtex;
        config = ''
              let g:latex_view_general_viewer = "zathura"
          let g:vimtex_view_method = "zathura"
          let g:tex_flavor = "latex"
        '';
      }
      {
        plugin = onedark-vim;
        config = ''
          packadd! onedark-vim

          let g:onedark_color_overrides = {
                      \ "black": {"gui": "#1c1c1c", "cterm": "235", "cterm16": "0" }
          \}

          " onedark.vim override: Don't set a background color when running in a terminal;
          " just use the terminal's background color
          " `gui` is the hex color code used in GUI mode/nvim true-color mode
          " `cterm` is the color code used in 256-color mode
          " `cterm16` is the color code used in 16-color mode
          if (has("autocmd") && !has("gui_running"))
            augroup colorset
              autocmd!
              let s:white = { "gui": "#ABB2BF", "cterm": "145", "cterm16" : "7" }
              autocmd ColorScheme * call onedark#set_highlight("Normal", { "fg": s:white }) " `bg` will not be styled since there is no `bg` setting
            augroup END
          endif

          set background=dark
          colorscheme onedark
          let g:airline_theme = "onedark"

          if (has("termguicolors"))
            set termguicolors
          endif
        '';
      }
      vim-polyglot
    ];
    extraConfig = ''
      set nocompatible
      filetype off

      " Enable syntax highlight
      syntax on
      " Enable filetype detection for plugins and indentation options
      filetype plugin indent on
      " Force encoding to UTF-8
      set encoding=utf-8
      " Reload file when changed
      set autoread
      " Set amount of lines under and above cursor
      set scrolloff=5
      " Show command being executed
      set showcmd
      " Show current mode
      set showmode
      " Always show status line
      set laststatus=2
      " Display whitespace characters
      set list
      set listchars=tab:›\ ,eol:¬,trail:⋅
      " Indentation options
      """""""""""""""""""""""""""""
      " Length of a tab
      " Read somewhere it should always be 8
      set tabstop=8
      " Number of spaces inserted when using < or >
      set shiftwidth=4
      " Number of spaces inserted with Tab
      " -1 = same as shiftwidth
      set softtabstop=-1
      " Insert spaces instead of tabs
      set expandtab
      " When tabbing manually, use shiftwidth instead of tabstop and softtabstop
      set smarttab
      set autoindent
      nnoremap <silent> <space> za
      set foldlevel=99
      set t_Co=256
      set vb t_vb=".
      set smartcase
      set browsedir=buffer
      set tw=80
      set wrap
      set mouse=a
      set relativenumber

      set number
      set colorcolumn=80
      highlight colorcolumn ctermbg=4

      set clipboard=unnamed
    '';
  };

  programs.bat = {
    enable = true;
  };
}