{lib, ...}: {
  # Set the base domain for the prod environment
  networking.domain = "domain.com";

  # To make extra sure that kubernetes-dashboard is _never_ deployed
  # on prod we use `mkForce` in case it's ever enabled accidentally
  # in the base modules
  services.dashboard.enable = lib.mkForce false;
}
