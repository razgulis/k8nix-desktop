{
  description = "Desktop NixOS configuration with bootable installer ISO";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      username = "sergei";
      hostname = "k8nix-desktop";

      mkSystem = extraModules:
        nixpkgs.lib.nixosSystem {
          inherit system;

          specialArgs = {
            inherit username hostname;
          };

          modules =
            [
              home-manager.nixosModules.home-manager
              ./modules/common.nix
              ./modules/desktop.nix
            ]
            ++ extraModules;
        };
    in
    {
      nixosConfigurations = {
        desktop = mkSystem [
          ./hosts/desktop/default.nix
        ];

        desktop-installer = mkSystem [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-plasma6.nix"
          ./modules/installer-iso.nix
        ];
      };

      packages.${system}.installerIso =
        self.nixosConfigurations.desktop-installer.config.system.build.isoImage;
    };
}
