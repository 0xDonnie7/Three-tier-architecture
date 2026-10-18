# AWS Three-Tier Architecture with Terraform and GitHub Actions CI/CD

A three-tier web architecture on AWS, defined entirely in Terraform's HCL and deployed through GitHub Actions. Pull requests get an automatic plan preview; merges to main deploy dev and then prod, and a manual workflow tears environments down. GitHub authenticates to AWS with short-lived OIDC credentials, so there are no stored access keys.

![Architecture diagram](architecture_diagram/Three%20tier%20web%20application%20diagram.png)

# What this project demonstrates
- Infrastructure as code with reusable Terraform modules and separate dev and prod environments
- A plan-on-PR, apply-on-merge workflow, with plan output posted as PR comments
- Keyless AWS authentication from GitHub Actions using OIDC
- Least-privilege IAM: a read-only role for previews and a separate, scoped role for deployments
- Remote state in S3 with native state locking
- A guarded, manual destroy workflow

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
