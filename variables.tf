variable "config" {
  description = ""

  type = object({
    domain          = string
    certificate_arn = optional(string)
    enable_signup   = optional(bool, false)
    optional_mfa    = optional(bool, false)
    schema = optional(map(object({
      attribute_data_type      = string
      required                 = optional(bool)
      developer_only_attribute = optional(bool)
      mutable                  = optional(bool)
      number_attribute_constraints = optional(object({
        max_value = optional(number)
        min_value = optional(number)
      }))
      string_attribute_constraints = optional(object({
        max_length = optional(number)
        min_length = optional(number)
      }))
    })), {})

    federated_identity_providers = optional(object({
      saml = optional(map(object({
        metadata           = string
        attribute_mappings = optional(map(string))
      })), {})
      google = optional(map(object({
        client_id          = string
        client_secret      = string
        authorize_scopes   = set(string)
        attribute_mappings = optional(map(string))
      })), {})
      facebook = optional(map(object({
        client_id          = string
        client_secret      = string
        authorize_scopes   = set(string)
        api_version        = string
        attribute_mappings = optional(map(string))
      })), {})
      amazon = optional(map(object({
        client_id          = string
        client_secret      = string
        authorize_scopes   = set(string)
        attribute_mappings = optional(map(string))
      })), {})
      apple = optional(map(object({
        client_id          = string
        team_id            = string
        key_id             = string
        private_key        = string
        authorize_scopes   = set(string)
        attribute_mappings = optional(map(string))
      })), {})
      oidc = optional(map(object({
        client_id                 = string
        client_secret             = string
        attributes_request_method = string
        issuer_url                = string
        authorize_scopes          = set(string)
        attribute_mappings        = optional(map(string))
      })), {})
    }), {})

    client = map(object({
      callback_urls      = set(string)
      logout_urls        = optional(set(string))
      auth_flows         = optional(set(string))
      identity_providers = optional(set(string), ["cognito"])
    }))

    custom_messages = optional(object({
      signup = optional(object({
        subject = optional(string)
        body    = optional(string)
        sms     = optional(string)
      }))
      admin_create_user = optional(object({
        subject = optional(string)
        body    = optional(string)
        sms     = optional(string)
      }))
      resend_code = optional(object({
        subject = optional(string)
        body    = optional(string)
        sms     = optional(string)
      }))
      forgot_password = optional(object({
        subject = optional(string)
        body    = optional(string)
        sms     = optional(string)
      }))
      update_user_attribute = optional(object({
        subject = optional(string)
        body    = optional(string)
        sms     = optional(string)
      }))
      verify_user_attribute = optional(object({
        subject = optional(string)
        body    = optional(string)
        sms     = optional(string)
      }))
      authentication = optional(object({
        subject = optional(string)
        body    = optional(string)
        sms     = optional(string)
      }))
    }))
  })
}
