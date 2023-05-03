output "role_arn" {
    value = aws_iam_role.lambda_role.arn 
}

output "lambda_arn" {
    value = aws_lambda_function.ebs_migration_lambda_function.arn
}

output "cloudwatch_event_arn" {
    value = aws_cloudwatch_event_rule.ebs_migration_lambda_event.arn
}