# outputs.tf

output "lambda_function_arn" {
  value = aws_lambda_function.cpf_validator.arn
}