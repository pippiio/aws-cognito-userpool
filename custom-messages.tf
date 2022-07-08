locals {
  enable_custom_messages = local.config.custom_messages != null ? 1 : 0

  signup_event = jsonencode({
    emailSubject = try(local.config.custom_messages.signup.subject, null)
    emailMessage = try(local.config.custom_messages.signup.body, null)
    smsMessage   = try(local.config.custom_messages.signup.sms, null)
  })
  admin_create_user_event = jsonencode({
    emailSubject = try(local.config.custom_messages.admin_create_user.subject, null)
    emailMessage = try(local.config.custom_messages.admin_create_user.body, null)
    smsMessage   = try(local.config.custom_messages.admin_create_user.sms, null)
  })
  resend_code_event = jsonencode({
    emailSubject = try(local.config.custom_messages.resend_code.subject, null)
    emailMessage = try(local.config.custom_messages.resend_code.body, null)
    smsMessage   = try(local.config.custom_messages.resend_code.sms, null)
  })
  forgot_password_event = jsonencode({
    emailSubject = try(local.config.custom_messages.forgot_password.subject, null)
    emailMessage = try(local.config.custom_messages.forgot_password.body, null)
    smsMessage   = try(local.config.custom_messages.forgot_password.sms, null)
  })
  update_user_attribute_event = jsonencode({
    emailSubject = try(local.config.custom_messages.update_user_attribute.subject, null)
    emailMessage = try(local.config.custom_messages.update_user_attribute.body, null)
    smsMessage   = try(local.config.custom_messages.update_user_attribute.sms, null)
  })
  verify_user_attribute_event = jsonencode({
    emailSubject = try(local.config.custom_messages.verify_user_attribute.subject, null)
    emailMessage = try(local.config.custom_messages.verify_user_attribute.body, null)
    smsMessage   = try(local.config.custom_messages.verify_user_attribute.sms, null)
  })
  authentication_event = jsonencode({
    emailSubject = try(local.config.custom_messages.authentication.subject, null)
    emailMessage = try(local.config.custom_messages.authentication.body, null)
    smsMessage   = try(local.config.custom_messages.authentication.sms, null)
  })
}

data "archive_file" "lambda" {
  count = local.enable_custom_messages

  type        = "zip"
  output_path = "${path.module}/lambda.zip"

  source {
    content = templatefile("${path.module}/src/index.js", {
      signup_event                = local.signup_event
      admin_create_user_event     = local.admin_create_user_event
      resend_code_event           = local.resend_code_event
      forgot_password_event       = local.forgot_password_event
      update_user_attribute_event = local.update_user_attribute_event
      verify_user_attribute_event = local.verify_user_attribute_event
      authentication_event        = local.authentication_event
    })
    filename = "index.js"
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  count = local.enable_custom_messages

  name              = "/aws/lambda/${local.name_prefix}CognitoCustomMessage"
  retention_in_days = 7
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  count = local.enable_custom_messages

  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "lambda_log_policy" {
  count = local.enable_custom_messages

  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams"
    ]

    resources = ["${one(aws_cloudwatch_log_group.lambda).arn}:*"]
  }
}

resource "aws_iam_role" "lambda" {
  count = local.enable_custom_messages

  name               = "${local.name_prefix}lambda-role"
  assume_role_policy = one(data.aws_iam_policy_document.lambda_assume_role_policy).json
  path               = "/"

  inline_policy {
    name   = "logs"
    policy = one(data.aws_iam_policy_document.lambda_log_policy).json
  }
}

resource "aws_lambda_function" "lambda" {
  count = local.enable_custom_messages

  function_name    = "${local.name_prefix}CognitoCustomMessage"
  filename         = "${path.module}/lambda.zip"
  role             = one(aws_iam_role.lambda).arn
  handler          = "index.handler"
  runtime          = "nodejs16.x"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")
  publish          = true

  depends_on = [
    aws_cloudwatch_log_group.lambda,
  ]
}

resource "aws_lambda_permission" "allow_cognito" {
  count = local.enable_custom_messages

  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = one(aws_lambda_function.lambda).function_name
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}
