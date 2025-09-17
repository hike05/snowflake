{ config, pkgs, lib, username, ... }:

{
  imports = [
    ./shell.nix
    ./git.nix
    ./packages.nix
  ];

  home = {
    username = maxime;
    homeDirectory = "/Users/${username}";
    
    # State version for Home Manager
    stateVersion = "24.11";
    
    # Environment variables
    sessionVariables = {
      BROWSER = "open";
      TERMINAL = "iterm2";
      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
    };
    
    # Create default directories
    file = {
      ".config/.keep".text = "";
      "Pictures/Screenshots/.keep".text = "";
      "Developer/.keep".text = "";
    };
  };

  # Enable Home Manager
  programs.home-manager.enable = true;

  # XDG Base Directory
  xdg = {
    enable = true;
    configHome = "${config.home.homeDirectory}/.config";
    cacheHome = "${config.home.homeDirectory}/.cache";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };
}