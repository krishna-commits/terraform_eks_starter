<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_tag\_map | Additional tags for appending to each tag map | map(string) | `{}` | no |
| attributes | Any extra attributes for naming these resources | list(string) | `[]` | no |
| availability\_zones | List of Availability Zones where subnets will be created | list(string) | n/a | yes |
| cidr\_block | Base CIDR block which will be divided into subnet CIDR blocks \(e.g. `10.0.0.0/16`\) | string | n/a | yes |
| context | Default context to use for passing state between label invocations | object | `{ "additional_tag_map": [ {} ], "attributes": [], "delimiter": "", "enabled": true, "environment": "", "label_order": [], "name": "", "namespace": "", "regex_replace_chars": "", "stage": "", "tags": [ {} ] }` | no |
| delimiter | Delimiter to be used between `namespace`, `stage`, `name` and `attributes` | string | `"-"` | no |
| environment | The environment name if not using stage | string | `""` | no |
| igw\_id | Internet Gateway ID the public route table will point to \(e.g. `igw-9c26a123`\) | string | n/a | yes |
| label\_order | The naming order of the ID output and Name tag | list(string) | `[]` | no |
| map\_public\_ip\_on\_launch | Instances launched into a public subnet should be assigned a public IP address | bool | `"true"` | no |
| max\_subnet\_count | Sets the maximum amount of subnets to deploy. 0 will deploy a subnet for every provided availablility zone \(in `availability\_zones` variable\) within the region | string | `"0"` | no |
| name | Solution name, e.g. 'app' or 'jenkins' | string | `""` | no |
| namespace | Namespace, which could be your organization name or abbreviation, e.g. 'eg' or 'cp' | string | `""` | no |
| nat\_gateway\_enabled | Flag to enable/disable NAT Gateways to allow servers in the private subnets to access the Internet | bool | `"true"` | no |
| nat\_instance\_enabled | Flag to enable/disable NAT Instances to allow servers in the private subnets to access the Internet | bool | `"false"` | no |
| nat\_instance\_type | NAT Instance type | string | `"t3.micro"` | no |
| private\_network\_acl\_id | Network ACL ID that will be added to private subnets. If empty, a new ACL will be created | string | `""` | no |
| public\_network\_acl\_id | Network ACL ID that will be added to public subnets. If empty, a new ACL will be created | string | `""` | no |
| regex\_replace\_chars | Regex to replace chars with empty string in `namespace`, `environment`, `stage` and `name`. By default only hyphens, letters and digits are allowed, all other chars are removed | string | `"/[^a-zA-Z0-9-]/"` | no |
| stage | Stage, e.g. 'prod', 'staging', 'dev', or 'test' | string | `""` | no |
| subnet\_type\_tag\_key | Key for subnet type tag to provide information about the type of subnets, e.g. `cpco.io/subnet/type=private` or `cpco.io/subnet/type=public` | string | `"cpco.io/subnet/type"` | no |
| subnet\_type\_tag\_value\_format | This is using the format interpolation symbols to allow the value of the subnet\_type\_tag\_key to be modified. | string | `"%s"` | no |
| tags | Additional tags to apply to all resources that use this label module | map(string) | `{}` | no |
| vpc\_default\_route\_table\_id | Default route table for public subnets. If not set, will be created. \(e.g. `rtb-f4f0ce12`\) | string | `""` | no |
| vpc\_id | VPC ID where subnets will be created \(e.g. `vpc-aceb2723`\) | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| availability\_zones | List of Availability Zones where subnets were created |
| nat\_gateway\_ids | IDs of the NAT Gateways created |
| private\_route\_table\_ids | IDs of the created private route tables |
| private\_subnet\_cidrs | CIDR blocks of the created private subnets |
| private\_subnet\_ids | IDs of the created private subnets |
| public\_route\_table\_ids | IDs of the created public route tables |
| public\_subnet\_cidrs | CIDR blocks of the created public subnets |
| public\_subnet\_ids | IDs of the created public subnets |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->