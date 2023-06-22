{
  description = "Kent's NixOS configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }: {
    nixosConfigurations = builtins.mapAttrs (name: _: let
      parts = builtins.split "_(.*)" name;
      hostname = builtins.elemAt parts 0;
      system = builtins.elemAt parts 1 + "-linux";
    in 
    hostconfig = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        "./hosts/${name}/configuration.nix"
        "./hosts/${name}/hardware-configuration.nix"
      ];
    }) (builtins.readDir "${self}/hosts");
  };
}
