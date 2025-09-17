{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    
    # User identity
    userName = "Your Name";
    userEmail = "you@example.com";
    
    # GPG signing
    signing = {
      key = null;  # Set if using GPG
      signByDefault = false;
    };
    
    # Better diffs
    delta = {
      enable = true;
      options = {
        features = "side-by-side line-numbers decorations";
        whitespace-error-style = "22 reverse";
        decorations = {
          commit-decoration-style = "bold yellow box ul";
          file-style = "bold yellow ul";
          file-decoration-style = "none";
        };
      };
    };
    
    # Git configuration
    extraConfig = {
      init.defaultBranch = "main";
      
      core = {
        editor = "nvim";
        whitespace = "fix,-indent-with-non-tab,trailing-space,cr-at-eol";
        excludesfile = "~/.gitignore_global";
      };
      
      pull.rebase = true;
      push.autoSetupRemote = true;
      
      merge = {
        tool = "vimdiff";
        conflictstyle = "diff3";
      };
      
      diff = {
        tool = "vimdiff";
        colorMoved = "default";
      };
      
      # Useful aliases
      alias = {
        # Shortcuts
        st = "status -sb";
        co = "checkout";
        br = "branch";
        ci = "commit";
        
        # Pretty logs
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
        ll = "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short";
        
        # Utilities
        unstage = "reset HEAD --";
        last = "log -1 HEAD";
        amend = "commit --amend --no-edit";
        undo = "reset HEAD~1 --mixed";
      };
    };
    
    # Global ignore patterns
    ignores = [
      # macOS
      ".DS_Store"
      "._*"
      ".Spotlight-V100"
      ".Trashes"
      
      # IDE
      ".vscode/"
      ".idea/"
      "*.iml"
      
      # Vim
      "*.swp"
      "*.swo"
      "*~"
      
      # Direnv
      ".direnv/"
      ".envrc"
      
      # Nix
      "result"
      "result-*"
    ];
  };

  # GitHub CLI
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  # TUI for Git
  programs.lazygit = {
    enable = true;
    settings = {
      gui = {
        showFileTree = true;
        showListFooter = false;
        showRandomTip = false;
      };
    };
  };
}