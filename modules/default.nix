{lib, ...}: {
  imports = [
    ./argocd
    ./dashboard
    ./traefik
  ];

  options.networking = with lib; {
    domain = mkOption {
      type = types.str;
      description = ''
        Base domain for the cluster that can be used for Ingress hostnames.
      '';
    };
  };

  config = {
    # This option is common across all environments so it goes in the
    # base module.
    nixidy.target.repository = "https://github.com/arnarg/nixidy-demo.git";

    # Nixidy will overwrite the whole environment branch on each rebuild.
    # Therefore you need to set any extra files in nix.
    nixidy.extraFiles."README.md".text = ''
      # Generated manifests

      This branch contains auto-generated manifests for a specific environment. Do not edit manually.
    '';

    # Many helm chars will render all resources with the
    # following labels.
    # This produces huge diffs when the charts are updated
    # because the values of these labels change each release.
    # Here we add a transformer that strips them out after
    # templating the helm charts in each application.
    nixidy.defaults.helm.transformer = map (lib.kube.removeLabels [
      "app.kubernetes.io/version"
      "helm.sh/chart"
    ]);

    # Set default enabled services.
    services.argocd.enable = lib.mkDefault true;
    networking.traefik.enable = lib.mkDefault true;
  };
}
