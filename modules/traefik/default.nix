{
  lib,
  config,
  ...
}: let
  # Shorter reference to local declared options
  cfg = config.networking.traefik;

  # Fetch helm chart for traefik
  chart = lib.helm.downloadHelmChart {
    repo = "https://traefik.github.io/charts/";
    chart = "traefik";
    version = "26.0.0";
    chartHash = "sha256-GaBxl6RRwGSC84d3i35kuLHscgAsRVkJZtmqX0SWmZE=";
  };

  # It can be useful set some default values from options
  # declared in other modules but still allow overwriting
  # them them (or any others) in this service's values
  # option (i.e. `config.networking.traefik.values`).
  defaultValues = {
    ingressClass = {
      enabled = cfg.ingressClass.enable;
      name = cfg.ingressClass.name;
    };
  };
in {
  options.networking.traefik = with lib; {
    enable = mkEnableOption "traefik ingress controller";
    # Exposing some options that _could_ be set directly
    # in the values option below can be useful for discoverability
    # and being able to reference in other modules
    ingressClass = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Whether or not an ingress class for traefik should be created automatically.
        '';
      };
      name = mkOption {
        type = types.str;
        default = "traefik";
        description = ''
          The name of the ingress class for traefik that should be created automatically.
        '';
      };
    };
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

  # Only create the application if traefik is enabled
  config = lib.mkIf cfg.enable {
    applications.traefik = {
      namespace = "traefik";
      createNamespace = true;

      helm.releases.traefik = {
        inherit chart;

        # Here we merge default values with provided
        # values from `config.networking.traefik.values`.
        values = lib.recursiveUpdate defaultValues cfg.values;
      };
    };
  };
}
