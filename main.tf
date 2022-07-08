locals {
  config = defaults(var.config, {
    enable_signup = false
    optional_mfa  = false
  })
}
