{
  lib,
  config,
  ...
}: let
  # Shorter reference to local declared options
  cfg = config.services.dashboard;

  # Fetch helm chart for argocd
  chart = lib.helm.downloadHelmChart {
    repo = "https://kubernetes.github.io/dashboard/";
    chart = "kubernetes-dashboard";
    version = "7.0.0-alpha1";
    chartHash = "sha256-Te5I2e1RtaUzwYT85DQe/lDHqebrAX9PUHdzQ8oorFw=";
  };

  # It can be useful set some default values from options
  # declared in other modules but still allow overwriting
  # them them (or any others) in this service's values
  # option (i.e. `config.services.dashboard.values`).
  defaultValues = {
    app.ingress = {
      # Only enable the dashboard ingress using helm values
      # when traefik is enabled
      enabled = config.networking.traefik.enable;
      # Use the base domain option declared in `modules/default.nix`
      hosts = ["dashboard.${config.networking.domain}"];
      # Reference ingress class name declared by traefik
      ingressClassName = config.networking.traefik.ingressClass.name;
    };
  };
in {
  options.services.dashboard = with lib; {
    enable = mkEnableOption "dashboard";
    # To not limit the consumers of this module allowing for
    # setting the helm values directly is useful in certain
    # situations
    values = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = ''
        Value overrides that will be passed to the helm chart.
      '';
    };
  };

  # Only create the application if argocd is enabled
  config = lib.mkIf cfg.enable {
    applications.dashboard = {
      namespace = "kubernetes-dashboard";
      createNamespace = true;

      helm.releases.kubernetes-dashboard = {
        inherit chart;

        # Here we merge default values with provided
        # values from `config.services.dashboard.values`.
        values = lib.recursiveUpdate defaultValues cfg.values;

        # All resources are rendered with the following labels.
        # This produces huge diffs when the chart is updated
        # because the values of these labels changes each release.
        # Here we add a transformer that strips them out after
        # templating the helm chart.
        transformer = map (lib.kube.removeLabels [
          "app.kubernetes.io/version"
          "helm.sh/chart"
        ]);
      };
    };
  };
}
