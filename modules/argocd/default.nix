{
  lib,
  config,
  ...
}: let
  # Shorter reference to local declared options
  cfg = config.services.argocd;

  # Fetch helm chart for argocd
  chart = lib.helm.downloadHelmChart {
    repo = "https://argoproj.github.io/argo-helm/";
    chart = "argo-cd";
    version = "5.51.6";
    chartHash = "sha256-3kRkzOQdYa5JkrBV/+iJK3FP+LDFY1J8L20aPhcEMkY=";
  };

  # It can be useful set some default values from options
  # declared in other modules but still allow overwriting
  # them them (or any others) in this service's values
  # option (i.e. `config.services.argocd.values`).
  defaultValues = {
    server.ingress = {
      # Only enable argocd-server ingress using helm values
      # when traefik is enabled
      enabled = config.networking.traefik.enable;
      # Use the base domain option declared in `modules/default.nix`
      hosts = ["argocd.${config.networking.domain}"];
      # Reference ingress class name declared by traefik
      ingressClassName = config.networking.traefik.ingressClass.name;
    };

    # Traefik (if enabled) will terminate TLS so argocd-server
    # can run with plain HTTP
    configs.params."server.insecure" =
      if config.networking.traefik.enable
      then "true"
      else "false";
  };
in {
  options.services.argocd = with lib; {
    enable = mkEnableOption "argocd";
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
    applications.argocd = {
      namespace = "argocd";
      createNamespace = true;

      helm.releases.argocd = {
        inherit chart;

        # Here we merge default values with provided
        # values from `config.services.argocd.values`.
        values = lib.recursiveUpdate defaultValues cfg.values;
      };
    };
  };
}
