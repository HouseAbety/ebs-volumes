////IAM POLICY FOR LAMBDA FUNCTION
data "aws_iam_policy_document" "lambda_assume_role_policy"{
    statement {
      effect = "Allow"
      actions = ["sts:AssumeRole"]

      principals {
        type ="Service"
        identifiers = ["lambda.amazonaws.com"]
      }
    }
}

///IAM ROLE FOR LAMBDA FUNCTION/
resource "aws_iam_role" "lambda_role" {
    name = "ebs-migration-lambda"
    assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

///CREATE ARCHIVE FILE FROM LAMBDA_FUNCTION.PY - ZIP

data "archive_file" "python_lambda_package" {
    type = "zip"
    source_file = "${path.cwd}/code/lambda_function.py"
    output_path = "ebs_migration_script.zip"
}

/// CREATE LAMBDA FUNCTION
resource "aws_lambda_function" "ebs_migration_lambda_function" {
    function_name = "EBSMigrationLambda"
    filename = "ebs_migration_script.zip"
    source_code_hash = data.archive_file.python_lambda_package.output_base64sha256
    role = aws_iam_role.lambda_role.arn
    runtime = "python3.9"
    handler = "lambda_function.lambda_handler"
    timeout = 30
}

/// CLOUDWATCH EVENT TRIGGER FOR FOR LAMBDA FUNCTION - CRON JOB
resource "aws_cloudwatch_event_rule" "ebs_migration_lambda_event" {
    name = "run-ebs-migration-lambda"
    description = "Schedule EBS migration Lambda function"
    schedule_expression = "cron(0 22 ? * SUN *)" ###### NEED TO GO OVER THIS ######
}

resource "aws_cloudwatch_event_target" "ebs_migration_lambda_function_target" {
    target_id = "ebs-migration-lambda-function-target"
    rule = aws_cloudwatch_event_rule.ebs_migration_lambda_event.name
    arn = aws_lambda_function.ebs_migration_lambda_function.arn
}

/// PERMISSIONS FOR CLOUDWATCH EVENT TO ACCESS LAMBDA
resource "aws_lambda_permission" "allow_cloudwatch" {
    statement_id = "AllowExecutionFromCloudwatch"
    action = "lambda:InvokeFunction"
    function_name = aws_lambda_function.ebs_migration_lambda_function.function_name
    principal = "events.amazonaws.com"
    source_arn = aws_cloudwatch_event_rule.ebs_migration_lambda_event.arn
}