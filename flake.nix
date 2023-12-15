{
  description = "My ArgoCD configuration with nixidy.";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.nixidy.url = "github:arnarg/nixidy";

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    nixidy,
  }: (flake-utils.lib.eachDefaultSystem (system: let
    pkgs = import nixpkgs {
      inherit system;
    };
  in {
    nixidyEnvs = nixidy.lib.mkEnvs {
      inherit pkgs;
      modules = [
        ./modules
      ];

      envs = {
        dev.modules = [./env/dev];
        test.modules = [./env/test];
        prod.modules = [./env/prod];
      };
    };
  }));
}
