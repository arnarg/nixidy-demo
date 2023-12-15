{...}: {
  # Set the base domain for the test environment
  networking.domain = "test.domain.com";

  # Set the target revision in all generated Argo CD applications
  # to our environment branch
  nixidy.target.revision = "env/test";
}
