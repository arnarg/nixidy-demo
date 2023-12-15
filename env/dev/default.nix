{...}: {
  # Set the base domain for the dev environment
  networking.domain = "dev.domain.com";

  # Set the target revision in all generated Argo CD applications
  # to our environment branch
  nixidy.target.revision = "env/dev";

  # Explicitly enable kubernetes-dashboard on the dev environment
  services.dashboard.enable = true;
}
