{
  description = "DonOS";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

	spicetify-nix = {
	  url = "github:Gerg-L/spicetify-nix";
	  inputs.nixpkgs.follows = "nixpkgs";
	};

	figma-linux-next = {
	  url = "github:arximus88/figma-linux-next";
	  inputs.nixpkgs.follows = "nixpkgs";
	};
  };

  outputs = { self, nixpkgs, home-manager, spicetify-nix, figma-linux-next, ... }: {
    nixosConfigurations.eis-btw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true; 
            users.piotr = import ./home.nix;
            backupFileExtension = "backup";
          };
        }

		({ config, pkgs, inputs, ... }: {
	      imports = [ figma-linux-next.nixosModules.default spicetify-nix.nixosModules.spicetify ];
          programs.figma-linux-next.enable = true;

          programs.spicetify = {
            enable = true;
            theme = spicetify-nix.legacyPackages.${pkgs.stdenv.system}.themes.sleek;
            colorScheme = "UltraBlack";
          };
		})
      ];
    };
  };
}
