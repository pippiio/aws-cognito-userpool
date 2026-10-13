resource "aws_lambda_permission" "pre_token_generation" {
  count = local.config.pre_token_generation != null ? 1 : 0

  statement_id  = "AllowPreTokenGenerationFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = local.config.pre_token_generation.lambda_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = aws_cognito_user_pool.this.arn
}
