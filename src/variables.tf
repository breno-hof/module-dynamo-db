variable "name" {
	description						= "(Required) Unique within a region name of the table"
	type							= string
}

variable "hash_key" {
	description						= "(Required, Forces new resource) Attribute to use as the hash (partition) key name"
	type							= string
}

variable "hash_key_type" {
	description						= "(Required) Attribute to use as the hash (partition) key type"
	type							= string
}

variable "range_key" {
	description						= "(Optional, Forces new resource) Attribute to use as the range (sort) key name."
	type							= string
	default							= null 
}

variable "range_key_type" {
	description						= "(Optional)  Attribute to use as the range (sort) key type."
	type							= string
	default							= null
}

variable "is_billing_mode_pay_per_request" {
	description						= "(Optional)  Controls how you are charged for read and write throughput and how you manage capacity."
	type							= bool
	default							= false
}

variable "is_deletion_protection_enabled" {
	description						= "(Optional)  Enables deletion protection for table. Defaults to `true`."
	type							= bool
	default							= true
}

variable "import_table" {
	description						= "(Optional)  Import Amazon S3 data into a new table."
	type							= object({
			input_compression_type	= optional(string)
			input_format			= string
			input_format_options	= optional(object({
				csv					= optional(object({
					delimiter		= optional(string)
					header_list		= optional(string)
				})) 
			}))
			s3_bucket_source		= object({
				bucket				= string
				bucket_owner		= optional(string)
				key_prefix			= optional(string) 
			})
	})
	default							= null
}

variable "global_secondary_index" {
	description						= "(Optional) Describe a GSI for the table; subject to the normal limits on the number of GSIs, projected attributes, etc."
	type							= list(object({
			index_name				= string
			attribute_name			= string
			attribute_type			= string
			range_key				= optional(string)
			write_capacity			= optional(number)
			read_capacity			= optional(number)
			projection_type			= string
			non_key_attributes		= optional(list(string))
	}))
	default							= null
}

variable "local_secondary_index" {
	description						= "(Optional, Forces new resource) Describe an LSI on the table; these can only be allocated at creation so you cannot change this definition after you have created the resource."
	type							= list(object({
			index_name				= string
			range_key				= string
			projection_type			= string
			non_key_attributes		= optional(list(string))
	}))
	default							= null
}

variable "replica" {
	description						= "(Optional) Configuration block(s) with DynamoDB Global Tables V2 (version 2019.11.21) replication configurations."
	type							= list(object({
			region_name				= string
			propagate_tags			= optional(bool)
	}))
	default							= null
}

variable "is_ttl_enabled" {
	description						= "(Optional) Whether TTL is enabled. Default value is `false`."
	type							= bool
	default							= false
}

variable "is_stream_enabled" {
	description						= "(Optional) Whether Streams are enabled."
	type							= bool
	default							= false
}
