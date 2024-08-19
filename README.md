# AWS Kubernetes(EKS) Infrastructure

This repo contains AWS Kubernetes(EKS) Infrastructure files to setup EKS Cluster on AWS.

## Installation

Please follow the installation instructions required for setting up the project [here](INSTALLATION.md).

## Setup Terraform in repo

To set up Terraform within your repository, follow these steps:

1. **Navigate to Repository**: Open a terminal or command prompt and navigate to the root directory of the repository.
2. **Initialize Terraform**: Run terraform init to initialize Terraform within the repository. This command initializes various Terraform configurations and plugins required for your infrastructure.

        $ terraform init
        Initializing the backend...

        Initializing provider plugins...
        - Reusing previous version of hashicorp/aws from the dependency lock file
        - Installing hashicorp/aws v5.51.1...
        - Installed hashicorp/aws v5.51.1 (signed by HashiCorp)
        ...
        Terraform has been successfully initialized!

3. **Plan Infrastructure Changes**: After initialization, you can run terraform plan to see what changes Terraform will make to your infrastructure. Use -var-file to specify a variable file if needed.

        terraform plan

4. **Apply Infrastructure Changes**: If the plan looks good, you can apply the changes by running terraform apply. Use -var-file to specify a variable file if needed.

        terraform apply

5. **Destroy Infrastructure**: To destroy the infrastructure created by Terraform, you can run terraform destroy. Make sure to review the plan before proceeding.

        terraform destroy

## What's in  this repo

This repo contains the following files:

- `ebs.tf`: This file contains the terraform code to setup EBS volume on AWS.
- `eks_iam_roles.tf`: This file contains the terraform code to setup IAM roles for EKS Cluster on AWS.
- `eks_security_groups.tf`: This file contains the terraform code to setup security group for EKS Cluster on AWS.
- `eks.tf`: This file contains the terraform code to setup EKS Cluster on AWS.
- `keys.tf`: This file contains the terraform code to setup key pair on AWS.
- `nat.tf`: This file contains the terraform code to setup NAT Gateway on AWS.
- `network.tf`: This file contains the terraform code to setup VPC, Subnets, Route Tables, Internet Gateway on AWS.
- `provider.tf`: This file contains the terraform code to setup Jenkins on AWS.
- `variables.tf`: This file contains the variables required for the terraform code.

## Variables

### Basic Variables

| Variable Name    | Type   | Description                                | Default Value |
| ---------------- | ------ | ------------------------------------------ | ------------- |
| `profile`        | string | AWS profile to use for authentication      | -             |
| `region`         | string | AWS region where resources will be created | -             |
| `vpc_name`       | string | Name of the VPC                            | -             |
| `vpc_cidr_range` | string | CIDR range for the VPC                     | -             |

### Subnets

| Variable Name                  | Type   | Description                       | Default Value |
| ------------------------------ | ------ | --------------------------------- | ------------- |
| `subnets[].name`               | string | Name of the subnet                | -             |
| `subnets[].public_cidr_block`  | string | CIDR block for the public subnet  | -             |
| `subnets[].private_cidr_block` | string | CIDR block for the private subnet | -             |
| `subnets[].zone`               | string | Availability zone for the subnet  | -             |

### Internet Gateway

| Variable Name           | Type   | Description                  | Default Value |
| ----------------------- | ------ | ---------------------------- | ------------- |
| `internet_gateway_name` | string | Name of the Internet Gateway | -             |

### Route Tables

| Variable Name                           | Type   | Description                     | Default Value |
| --------------------------------------- | ------ | ------------------------------- | ------------- |
| `route_tables.public_route_table_name`  | string | Name of the public route table  | -             |
| `route_tables.private_route_table_name` | string | Name of the private route table | -             |
| `route_tables.route_cidr`               | string | CIDR block for the route        | -             |

### Network ACL

| Variable Name                    | Type   | Description                      | Default Value |
| -------------------------------- | ------ | -------------------------------- | ------------- |
| `network_acl_ingress[].protocol` | string | Protocol for the ingress rule    | -             |
| `network_acl_ingress[].port`     | number | Port for the ingress rule        | -             |
| `network_acl_ingress[].number`   | number | Rule number for the ingress rule | -             |
| `network_acl_ingress[].action`   | string | Action for the ingress rule      | -             |
| `network_acl_ingress[].cidr`     | string | CIDR block for the ingress rule  | -             |
| `network_acl_egress[].protocol`  | string | Protocol for the egress rule     | -             |
| `network_acl_egress[].port`      | number | Port for the egress rule         | -             |
| `network_acl_egress[].number`    | number | Rule number for the egress rule  | -             |
| `network_acl_egress[].action`    | string | Action for the egress rule       | -             |
| `network_acl_egress[].cidr`      | string | CIDR block for the egress rule   | -             |

### NAT Gateway

| Variable Name                  | Type   | Description                      | Default Value |
| ------------------------------ | ------ | -------------------------------- | ------------- |
| `nat.eip.public_ipv4_pool`     | string | Public IPv4 pool for the EIP     | -             |
| `nat.eip.domain`               | string | Domain for the EIP               | -             |
| `nat.eip.network_border_group` | string | Network border group for the EIP | -             |
| `nat.name`                     | string | Name of the NAT Gateway          | -             |

### Security Groups

| Variable Name                                   | Type         | Description                                                   | Default Value |
| ----------------------------------------------- | ------------ | ------------------------------------------------------------- | ------------- |
| `node_sg.name`                                  | string       | Name of the node security group                               | -             |
| `node_sg.rules[].description`                   | string       | Description of the rule                                       | -             |
| `node_sg.rules[].protocol`                      | string       | Protocol for the rule                                         | -             |
| `node_sg.rules[].from_port`                     | number       | Starting port for the rule                                    | -             |
| `node_sg.rules[].to_port`                       | number       | Ending port for the rule                                      | -             |
| `node_sg.rules[].type`                          | string       | Type of the rule                                              | -             |
| `node_sg.rules[].self`                          | bool         | Whether the rule applies to itself                            | null          |
| `node_sg.rules[].source_cluster_security_group` | bool         | Whether the rule applies to the source cluster security group | null          |
| `node_sg.rules[].cidr_blocks`                   | list(string) | List of CIDR blocks for the rule                              | null          |
| `cluster_sg.name`                               | string       | Name of the cluster security group                            | -             |
| `cluster_sg.rules[].description`                | string       | Description of the rule                                       | -             |
| `cluster_sg.rules[].protocol`                   | string       | Protocol for the rule                                         | -             |
| `cluster_sg.rules[].from_port`                  | number       | Starting port for the rule                                    | -             |
| `cluster_sg.rules[].to_port`                    | number       | Ending port for the rule                                      | -             |
| `cluster_sg.rules[].type`                       | string       | Type of the rule                                              | -             |
| `cluster_sg.rules[].self`                       | bool         | Whether the rule applies to itself                            | null          |
| `cluster_sg.rules[].source_node_security_group` | bool         | Whether the rule applies to the source node security group    | null          |
| `cluster_sg.rules[].cidr_blocks`                | list(string) | List of CIDR blocks for the rule                              | null          |

### KMS Keys

| Variable Name                              | Type   | Description                             | Default Value |
| ------------------------------------------ | ------ | --------------------------------------- | ------------- |
| `cluster_kms_key.name`                     | string | Name of the KMS key                     | -             |
| `cluster_kms_key.description`              | string | Description of the KMS key              | -             |
| `cluster_kms_key.key_usage`                | string | Key usage for the KMS key               | -             |
| `cluster_kms_key.deletion_window_in_days`  | number | Deletion window in days for the KMS key | -             |
| `cluster_kms_key.enable_key_rotation`      | bool   | Whether to enable key rotation          | -             |
| `cluster_kms_key.customer_master_key_spec` | string | Customer master key spec                | -             |
| `cluster_kms_key.enable_default_policy`    | bool   | Whether to enable the default policy    | -             |
| `ebs_kms_key.name`                         | string | Name of the KMS key                     | -             |
| `ebs_kms_key.description`                  | string | Description of the KMS key              | -             |
| `ebs_kms_key.key_usage`                    | string | Key usage for the KMS key               | -             |
| `ebs_kms_key.deletion_window_in_days`      | number | Deletion window in days for the KMS key | -             |
| `ebs_kms_key.enable_key_rotation`          | bool   | Whether to enable key rotation          | -             |
| `ebs_kms_key.customer_master_key_spec`     | string | Customer master key spec                | -             |
| `ebs_kms_key.enable_default_policy`        | bool   | Whether to enable the default policy    | -             |

### IAM Roles

| Variable Name                                   | Type         | Description                            | Default Value |
| ----------------------------------------------- | ------------ | -------------------------------------- | ------------- |
| `cluster_iam.role_name`                         | string       | Name of the IAM role                   | -             |
| `cluster_iam.description`                       | string       | Description of the IAM role            | -             |
| `cluster_iam.assume_role_policy.sid`            | string       | SID for the assume role policy         | -             |
| `cluster_iam.assume_role_policy.actions`        | list(string) | Actions for the assume role policy     | -             |
| `cluster_iam.assume_role_policy.type`           | string       | Type for the assume role policy        | -             |
| `cluster_iam.assume_role_policy.identifiers`    | list(string) | Identifiers for the assume role policy | -             |
| `cluster_iam.cluster_policies`                  | list(string) | List of cluster policies               | -             |
| `cluster_iam.kms.sid`                           | string       | SID for the KMS policy                 | -             |
| `cluster_iam.kms.actions`                       | list(string) | Actions for the KMS policy             | -             |
| `cluster_iam.kms.policy_name`                   | string       | Name of the KMS policy                 | -             |
| `node_group_iam.role_name`                      | string       | Name of the IAM role                   | -             |
| `node_group_iam.description`                    | string       | Description of the IAM role            | -             |
| `node_group_iam.assume_role_policy.sid`         | string       | SID for the assume role policy         | -             |
| `node_group_iam.assume_role_policy.actions`     | list(string) | Actions for the assume role policy     | -             |
| `node_group_iam.assume_role_policy.type`        | string       | Type for the assume role policy        | -             |
| `node_group_iam.assume_role_policy.identifiers` | list(string) | Identifiers for the assume role policy | -             |
| `node_group_iam.policies`                       | list(string) | List of policies                       | -             |

### EKS Cluster

| Variable Name                                             | Type         | Description                                       | Default Value                                                       |
| --------------------------------------------------------- | ------------ | ------------------------------------------------- | ------------------------------------------------------------------- |
| `eks_cluster.name`                                        | string       | Name of the EKS cluster                           | -                                                                   |
| `eks_cluster.version`                                     | string       | Version of the EKS cluster                        | "1.29"                                                              |
| `eks_cluster.ip_family`                                   | string       | IP family for the EKS cluster                     | "ipv4"                                                              |
| `eks_cluster.ami_type`                                    | string       | AMI type for the EKS cluster                      | "AL2_x86_64"                                                        |
| `eks_cluster.authentication_mode`                         | string       | Authentication mode for the EKS cluster           | "API_AND_CONFIG_MAP"                                                |
| `eks_cluster.endpoint_public_access`                      | bool         | Whether to enable public access to the endpoint   | true                                                                |
| `eks_cluster.endpoint_private_access`                     | bool         | Whether to enable private access to the endpoint  | true                                                                |
| `eks_cluster.addons_version_most_recent`                  | bool         | Whether to use the most recent version of addons  | true                                                                |
| `eks_cluster.enable_irsa`                                 | bool         | Whether to enable IAM roles for service accounts  | true                                                                |
| `eks_cluster.creator_admin_permissions`                   | bool         | Whether to grant admin permissions to the creator | true                                                                |
| `eks_cluster.create_cluster_security_group`               | bool         | Whether to create a cluster security group        | false                                                               |
| `eks_cluster.create_kms_key`                              | bool         | Whether to create a KMS key                       | false                                                               |
| `eks_cluster.create_cluster_iam_role`                     | bool         | Whether to create a cluster IAM role              | false                                                               |
| `eks_cluster.create_node_security_group`                  | bool         | Whether to create a node security group           | false                                                               |
| `eks_cluster.create_node_iam_role`                        | bool         | Whether to create a node IAM role                 | false                                                               |
| `eks_cluster.dataplane_wait_duration`                     | string       | Dataplane wait duration                           | "30s"                                                               |
| `eks_cluster.log_types`                                   | list(string) | List of log types                                 | ["api", "audit", "authenticator", "controllerManager", "scheduler"] |
| `eks_cluster.node_groups[].name`                          | string       | Name of the node group                            | -                                                                   |
| `eks_cluster.node_groups[].ami_type`                      | string       | AMI type for the node group                       | -                                                                   |
| `eks_cluster.node_groups[].capacity_type`                 | string       | Capacity type for the node group                  | "ON_DEMAND"                                                         |
| `eks_cluster.node_groups[].instance_types`                | list(string) | List of instance types                            | ["c3.large"]                                                        |
| `eks_cluster.node_groups[].desired_size`                  | number       | Desired size of the node group                    | 3                                                                   |
| `eks_cluster.node_groups[].min_size`                      | number       | Minimum size of the node group                    | 3                                                                   |
| `eks_cluster.node_groups[].max_size`                      | number       | Maximum size of the node group                    | 6                                                                   |
| `eks_cluster.node_groups[].update_config.max_unavailable` | number       | Maximum number of unavailable nodes during update | 1                                                                   |
| `eks_cluster.node_groups[].update_config.max_surge`       | number       | Maximum number of surge nodes during update       | 0                                                                   |

### EBS

| Variable Name                        | Type         | Description                            | Default Value |
| ------------------------------------ | ------------ | -------------------------------------- | ------------- |
| `ebs.ebs_csi_policy`                 | string       | EBS CSI policy                         | -             |
| `ebs.create_role`                    | bool         | Whether to create a role               | true          |
| `ebs.role_name`                      | string       | Name of the role                       | -             |
| `ebs.oidc_fully_qualified_audiences` | list(string) | List of OIDC fully qualified audiences | -             |
| `ebs.oidc_fully_qualified_subjects`  | list(string) | List of OIDC fully qualified subjects  | -             |
| `ebs.kms.sid`                        | string       | SID for the KMS policy                 | -             |
| `ebs.kms.actions`                    | list(string) | Actions for the KMS policy             | -             |
| `ebs.kms.policy_name`                | string       | Name of the KMS policy                 | -             |
