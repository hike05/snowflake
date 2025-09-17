{
  description = "❄️ snowflake - A unique macOS configuration powered by Nix flakes";

  inputs = {
    # Package repositories
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    
    # macOS system configuration
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # User environment management
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Homebrew management via Nix
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, darwin, home-manager, nix-homebrew, ... }: 
  let
    # Helper function to create Darwin system configuration
    mkDarwinSystem = hostname: system: username:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = { 
          inherit inputs username;
          inherit (inputs) self;
        };
        
        modules = [
          # Core Darwin configuration
          ./darwin/default.nix
          
          # Host-specific configuration
          ./hosts/${hostname}.nix
          
          # Home Manager as Darwin module
          home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${username} = import ./home/default.nix;
              extraSpecialArgs = { 
                inherit username;
                inherit (inputs) self;
              };
            };
          }
          
          # Homebrew integration
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              enableRosetta = true;
              user = username;
              autoMigrate = true;
            };
          }
        ];
      };
  in
  {
    # System configurations
    darwinConfigurations = {
      # MacBook Pro (Apple Silicon)
      "mbp" = mkDarwinSystem "mbp" "aarch64-darwin" "maxime";
    };
    
    # Formatters for 'nix fmt'
    formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixpkgs-fmt;
    formatter.x86_64-darwin = nixpkgs.legacyPackages.x86_64-darwin.nixpkgs-fmt;
  };
}