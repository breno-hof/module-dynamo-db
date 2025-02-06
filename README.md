# Terraform Module: AWS DynamoDB Table

This is a Terraform module for creating and managing an AWS DynamoDB table, allowing for custom configurations for keys, indexes, provisioning, and advanced options.;

## Resources Created;

- AWS DynamoDB Table;
- Global Secondary Indexes (GSI);
- Local Secondary Indexes (LSI);
- TTL Configuration;
- Streams Configuration;
- Global Replication;
- S3 Data Import

## Use

```hcl
locals {
	string_type = "S"
	
	name				= "pool_registry_table"

	partition_key = {
		name = "pool_id"
		type = local.string_type
	}

	sort_key = {
		name = "record_type"
		type = local.string_type
	}

	tags				= {
		Application		= local.name,
		GitHubRepo		= "pool-registry-service-dynamo-db"
	}
}

module "dynamo_db" {
	source							= "github.com/breno-hof/module-dynamo-db//src?ref=1.0.0"

	name							= local.name
	hash_key						= local.partition_key.name
	hash_key_type					= local.partition_key.type
	range_key						= local.sort_key.name
	range_key_type					= local.sort_key.type
	is_billing_mode_pay_per_request = true
	is_ttl_enabled					= true
	is_stream_enabled 				= true
	is_deletion_protection_enabled	= false

	global_secondary_index = [ {
		index_name 					= "heating_type_index"
		attribute_name 				= "heating_type"
		attribute_type 				= local.string_type
		range_key 					= local.partition_key.name
		projection_type				= "ALL"
	}, {
		index_name 					= "material_index"
		attribute_name 				= "material"
		attribute_type 				= local.string_type
		range_key 					= local.partition_key.name
		projection_type				= "KEYS_ONLY"
	} ]

	local_secondary_index = [ {
		index_name 					= "record_type_local_index"
		range_key 					= local.sort_key.name
		projection_type				= "ALL"
	} ]

	# replica = [ {
	# 	region_name = "sa-east-1"
	# } ]
}
```

## Variables

| Nome                              | Tipo     | Descrição                                                | Padrão               |
| --------------------------------- | -------- | -------------------------------------------------------- | -------------------- |
| `name`                            | `string` | Nome único da tabela dentro da região                    | -                    |
| `hash_key`                        | `string` | Nome do atributo chave primária (obrigatório)            | -                    |
| `hash_key_type`                   | `string` | Tipo do atributo chave primária (`S`, `N`, `B`)          | -                    |
| `range_key`                       | `string` | Nome do atributo chave de ordenação (opcional)           | `null`               |
| `range_key_type`                  | `string` | Tipo do atributo chave de ordenação                      | `null`               |
| `is_billing_mode_pay_per_request` | `bool`   | Define se a cobrança será por solicitação                | `false`              |
| `is_deletion_protection_enabled`  | `bool`   | Ativa a proteção contra exclusão                         | `true`               |
| `is_ttl_enabled`                  | `bool`   | Ativa o Time-To-Live (TTL)                               | `false`              |
| `is_stream_enabled`               | `bool`   | Ativa Streams no DynamoDB                                | `false`              |
| `stream_view_type`                | `string` | Tipo de visão do stream (`KEYS_ONLY`, `NEW_IMAGE`, etc.) | `NEW_AND_OLD_IMAGES` |

## Outputs

| Nome                    | Descrição                    |
| ----------------------- | ---------------------------- |
| `aws_dynamodb_table_id` | ID da tabela DynamoDB criada |

## Requirements

- Terraform >= 1.0
- AWS Provider >= 4.0

## License

This project is licensed under the GNU General Public License - see the LICENSE file for details.
