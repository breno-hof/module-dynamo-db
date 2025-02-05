resource "aws_dynamodb_table" "this" {
	name							= var.name
	hash_key						= var.hash_key
	range_key						= var.range_key
	billing_mode					= var.is_billing_mode_pay_per_request ? "PAY_PER_REQUEST" : "PROVISIONED"
	deletion_protection_enabled		= var.is_deletion_protection_enabled
	stream_enabled					= var.is_stream_enabled
	stream_view_type				= var.is_stream_enabled ? var.stream_view_type : null 
	read_capacity					= local.is_billing_mode_provisioned && !var.is_autoscaling_policy_attached ? 1 : null
	write_capacity					= local.is_billing_mode_provisioned && !var.is_autoscaling_policy_attached ? 1 : null
	
	attribute {
		name						= var.hash_key
		type						= var.hash_key_type
	}

	dynamic "attribute" {
		for_each					= var.range_key != null ? [1] : []

		content {
			name					= var.range_key
			type					= var.range_key_type
		}
	}

	dynamic "import_table" {
		for_each 					= var.import_table != null ? [1] : []

		content {
			input_compression_type	= var.import_table.input_compression_type
			input_format			= var.import_table.input_format

			dynamic "input_format_options" {
				for_each			= var.import_table.input_format_options != null ? [1] : []

				content {
					csv {
						delimiter	= var.import_table.input_format_options.delimiter
						header_list	= var.import_table.input_format_options.header_list
					}
				}
			}

			s3_bucket_source {
				bucket				= var.import_table.s3_bucket_source.bucket
				bucket_owner		= var.import_table.s3_bucket_source.bucket_owner
				key_prefix			= var.import_table.s3_bucket_source.key_prefix
			}
		}
	}

	dynamic "attribute" {
		for_each					= var.global_secondary_index

		content {
			name					= attribute.value.attribute_name
			type					= attribute.value.attribute_type
		}
	}

	dynamic "global_secondary_index" {
		for_each					= var.global_secondary_index

		content {
			name					= global_secondary_index.value.index_name
			hash_key				= global_secondary_index.value.attribute_name
			range_key				= global_secondary_index.value.range_key
			write_capacity			= global_secondary_index.value.write_capacity
			read_capacity			= global_secondary_index.value.read_capacity
			projection_type			= global_secondary_index.value.projection_type 
			non_key_attributes		= global_secondary_index.value.projection_type == "INCLUDE" && global_secondary_index.value.non_key_attributes != null ? global_secondary_index.value.non_key_attributes : null
		}
	}

	dynamic "local_secondary_index" {
		for_each					= var.local_secondary_index
		content {
			name					= local_secondary_index.value.index_name
			range_key				= local_secondary_index.value.range_key
			projection_type			= local_secondary_index.value.projection_type 
			non_key_attributes		= local_secondary_index.value.projection_type == "INCLUDE" && local_secondary_index.value.non_key_attributes != null ? local_secondary_index.value.non_key_attributes : null
		}
	}

	dynamic "replica" {
		for_each					= var.replica

		content {
			region_name				= replica.value.region_name
			propagate_tags			= replica.value.propagate_tags
		}
	}

	ttl {
		attribute_name				= "ttl"
		enabled						= var.is_ttl_enabled
	}

	lifecycle {
    	ignore_changes = [replica]
  	}
}