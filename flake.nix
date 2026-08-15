{
  description = "Nix package for the Moshi host integration hook";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs =
    { nixpkgs, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      moshi-hook = pkgs.callPackage ./package.nix { };
    in
    {
      packages.${system} = {
        default = moshi-hook;
        inherit moshi-hook;
      };

      apps.${system}.default = {
        type = "app";
        program = "${moshi-hook}/bin/moshi";
      };

      formatter.${system} = pkgs.nixfmt-tree;
    };
}
