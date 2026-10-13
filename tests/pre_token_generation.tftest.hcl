mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

variables {
  name_prefix = "test-"
  config = {
    domain = "test"
    client = {
      app = {
        callback_urls = ["https://example.com/callback"]
      }
    }
  }
}

run "without_a_trigger" {
  command = plan

  assert {
    condition     = length(aws_cognito_user_pool.this.lambda_config) == 0
    error_message = "A pool without triggers should have no lambda_config."
  }

  assert {
    condition     = length(aws_lambda_permission.pre_token_generation) == 0
    error_message = "No permission should be granted without a trigger."
  }
}

run "with_a_pre_token_generation_trigger" {
  command = plan

  variables {
    config = {
      domain = "test"
      client = {
        app = {
          callback_urls = ["https://example.com/callback"]
        }
      }
      pre_token_generation = {
        lambda_arn = "arn:aws:lambda:eu-west-1:123456789012:function:token-groups"
      }
    }
  }

  assert {
    condition     = aws_cognito_user_pool.this.lambda_config[0].pre_token_generation_config[0].lambda_arn == "arn:aws:lambda:eu-west-1:123456789012:function:token-groups"
    error_message = "The trigger's function should be configured."
  }

  assert {
    condition     = aws_cognito_user_pool.this.lambda_config[0].pre_token_generation_config[0].lambda_version == "V1_0"
    error_message = "The event version should default to V1_0."
  }

  assert {
    condition     = aws_lambda_permission.pre_token_generation[0].principal == "cognito-idp.amazonaws.com"
    error_message = "Cognito should be allowed to invoke the trigger."
  }
}

run "with_custom_messages_and_a_trigger" {
  command = plan

  variables {
    config = {
      domain = "test"
      client = {
        app = {
          callback_urls = ["https://example.com/callback"]
        }
      }
      custom_messages = {}
      pre_token_generation = {
        lambda_arn     = "arn:aws:lambda:eu-west-1:123456789012:function:token-groups"
        lambda_version = "V2_0"
      }
    }
  }

  assert {
    condition     = length(aws_cognito_user_pool.this.lambda_config) == 1
    error_message = "Both triggers should share one lambda_config."
  }

  assert {
    condition     = aws_cognito_user_pool.this.lambda_config[0].pre_token_generation_config[0].lambda_version == "V2_0"
    error_message = "The configured event version should be used."
  }
}
