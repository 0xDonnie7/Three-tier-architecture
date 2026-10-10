# Three tier AWS application

Terraform is split into independent `envs/dev` and `envs/prod` roots. Each root creates a VPC with public and private subnets, an internet facing Application Load Balancer, an EC2 Auto Scaling Group in the private subnets, and a private PostgreSQL RDS instance. RDS generates and stores its master credentials in Secrets Manager; the EC2 role receives permission to read that secret.

![Architecture diagram](architecture_diagram/Three%20tier%20web%20application%20diagram.png)
The compute module currently starts a basic Nginx placeholder page. Set `user_data` when calling the module to supply your application bootstrap script. Set `certificate_arn` in an environment tfvars file to enable HTTPS on the ALB; without it the listener serves HTTP.

## Initialize an environment

Provide an S3 bucket that already exists for Terraform state. Use a different state key for each environment:

```sh
cd envs/dev
terraform init \
  -backend-config="bucket=<your-state-bucket>" \
  -backend-config="key=dev/terraform.tfstate" \
  -backend-config="region=us-east-1" \
  -backend-config="encrypt=true" \
  -backend-config="use_lockfile=true"
```

For production, run the same command from `envs/prod` and use `key=prod/terraform.tfstate`. Configure AWS credentials through your normal AWS CLI profile or environment. Then review a plan before applying it:

```sh
terraform plan
terraform apply
```

The production defaults enable Multi-AZ RDS, seven days of backups, and deletion protection. Dev uses a single NAT Gateway and smaller application/database instances to reduce cost.
