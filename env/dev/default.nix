{...}: {
  # Set the base domain for the dev environment
  networking.domain = "dev.domain.com";

  # Explicitly enable kubernetes-dashboard on the dev environment
  services.dashboard.enable = true;
}
