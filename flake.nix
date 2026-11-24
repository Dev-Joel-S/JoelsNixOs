{
  description  = "NixOS auf USERs ThinkPad";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    omnyssh.url = "github:timhartmann7/omnyssh/v1.1.5";
    omnyssh.inputs.nixpkgs.follows = "nixpkgs";

    nixstore = {
      url = "github:ExpressoCodes/NixStore";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs@{
    nixpkgs,
    nixpkgs-unstable,
    lanzaboote,
    nixstore,
    ...
  }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      
      specialArgs = { inherit inputs; };

      modules = [
        lanzaboote.nixosModules.lanzaboote
        nixstore.nixosModules.default
        {
          nixpkgs.overlays = [
            (final: prev: {
              aerion = (import nixpkgs-unstable {
                system = "x86_64-linux";
                config.allowUnfree = true;
              }).aerion.override {
                withOAuth = true;
              };
            })
          ];
        }
        
        {
          imports = [ "${nixpkgs-unstable}/nixos/modules/services/networking/portmaster.nix" ];
          nixpkgs.overlays = [
            (final: prev: {
              portmaster = (import nixpkgs-unstable {
                system = "x86_64-linux";
              }).portmaster;
            })
          ];
        }


        ./configuration.nix
      ];
    };
  };
}
