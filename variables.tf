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

    federated_identity_providers = optional(map(object({
      saml = optional(map(object({
        metadata = string
        attribute_mappings = optional(map(string))
      })))
      // https://docs.aws.amazon.com/cognito-user-identity-pools/latest/APIReference/API_CreateIdentityProvider.html#CognitoUserPools-CreateIdentityProvider-request-AttributeMapping
      # google = 
      # facebook =
      # amazon =
      # apple = 
      # open_id =
    })), {})

    client = map(object({
      callback_urls = set(string)
      logout_urls   = set(string)
      auth_flows    = optional(set(string))
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
