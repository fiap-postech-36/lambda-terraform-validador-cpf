# main.tf

# Provider
provider "aws" {
  region = "us-east-1"  # Altere para sua região
}

# Cria a role para a Lambda com permissões básicas
resource "aws_iam_role" "lambda_role" {
  name = "lambda_cpf_validator_role"

  assume_role_policy = jsonencode({
    Version = "2024-09-23",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Anexa a política necessária à role
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Função Lambda
resource "aws_lambda_function" "cpf_validator" {
  function_name = "validateCPF"

  # Definindo o runtime como Python 3.12
  runtime     = "python3.12"
  handler     = "handler.lambda_handler" # handler.py, função lambda_handler

  # Código do Lambda
  filename    = "${path.module}/lambda/index.zip"

  role        = aws_iam_role.lambda_role.arn

  source_code_hash = filebase64sha256("${path.module}/lambda/index.zip")

  environment {
    variables = {
      STAGE = var.stage
    }
  }
}

# Referenciando o API Gateway existente usando o ID
data "aws_api_gateway_rest_api" "substituir-aqui-pelo-nome-do-api-gateway" {
  rest_api_id = "seu-api-gateway-id" # Substitua pelo ID do API Gateway existente
}

# Recurso para criar o recurso no API Gateway (rota/path)
resource "aws_api_gateway_resource" "lambda_resource" {
  rest_api_id = data.aws_api_gateway_rest_api.substituir-aqui-pelo-nome-do-api-gateway.id
  parent_id   = data.aws_api_gateway_rest_api.substituir-aqui-pelo-nome-do-api-gateway.root_resource_id
  path_part   = "validate-cpf"
}

# Método HTTP para a função Lambda (POST, GET, etc.)
resource "aws_api_gateway_method" "lambda_method" {
  rest_api_id   = data.aws_api_gateway_rest_api.substituir-aqui-pelo-nome-do-api-gateway.id
  resource_id   = aws_api_gateway_resource.lambda_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integração do API Gateway com a função Lambda
resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id = data.aws_api_gateway_rest_api.substituir-aqui-pelo-nome-do-api-gateway.id
  resource_id = aws_api_gateway_resource.lambda_resource.id
  http_method = aws_api_gateway_method.lambda_method.http_method
  type        = "AWS_PROXY"
  integration_http_method = "POST"
  uri         = aws_lambda_function.cpf_validator.invoke_arn
}

# Permissão para o API Gateway invocar a função Lambda
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cpf_validator.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${data.aws_api_gateway_rest_api.substituir-aqui-pelo-nome-do-api-gateway.execution_arn}/*/*"
}
