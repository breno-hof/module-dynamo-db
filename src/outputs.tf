output "aws_dynamodb_table_id" {
	description	= "ID of the AWS DynamoDB table"
	value		= aws_dynamodb_table.this.id
}