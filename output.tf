output "user_pool" {
  value = aws_cognito_user_pool.this
}

output "clients" {
  value     = aws_cognito_user_pool_client.this
  sensitive = true
}
