# AWS Three-Tier Architecture with Terraform and GitHub Actions CI/CD

This project deploys a three-tier web architecture on AWS, defined entirely in Terraform's HCL and deployed through GitHub Actions. A pull request triggers an automatic plan preview; merges to the `main` branch deploys `dev` then `prod`; and a manual workflow tears down environments. GitHub authenticates to AWS with short-lived OIDC credentials, so there are no stored access keys.

## What this project demonstrates
- Infrastructure as code with reusable Terraform modules and separate dev and prod environments
- A plan-on-PR, apply-on-merge workflow, with plan output posted as PR comments
- Keyless AWS authentication from GitHub Actions using OIDC
- Least-privilege IAM: a read-only role for previews and a separate, scoped role for deployments
- Remote state in S3 with native state locking
- A guarded, manual destroy workflow

![Architecture diagram](architecture_diagram/Three%20tier%20web%20application%20diagram.png)

| Tier | Service |
|---|---|
| Web / entry | Application Load Balancer |
| Application | Auto Scaling Group of EC2 instances |
| Data | RDS PostgreSQL 16 |

Networking: one VPC per environment, two public and two private subnets across two Availability Zones, an internet gateway, and NAT gateways so private instances can reach the internet outbound.

Security groups chain the tiers together: the ALB accepts web traffic from the internet, the app instances accept traffic only from the ALB, and the database accepts PostgreSQL traffic (port 5432) only from the app instances.

## Repository layout
```
.
├── .github/workflows/
│   ├── terraform-plan.yml      # PR preview (read-only role)
│   ├── terraform-apply.yml     # Deploy on merge to main (apply role)
│   └── terraform-destroy.yml   # Manual teardown with confirmation
├── envs/
│   ├── dev/                    # Dev root module, state key dev/terraform.tfstate
│   └── prod/                   # Prod root module, state key prod/terraform.tfstate
└── modules/
    ├── network/                # VPC, subnets, gateways, route tables
    ├── alb/                    # Load balancer, listener, target group
    ├── compute/                # Launch template, ASG, instance IAM role
    └── database/               # RDS instance and subnet group
```

## CI/CD pipeline
### 1. Plan on pull request (`terraform-plan.yml`)

Runs when a PR targeting `main` changes `envs/**`, `modules/**`, or a Terraform workflow file. For both `dev` and `prod` it runs `terraform fmt -check`, `init`, `validate`, and `plan`, then posts the result as a PR comment titled Terraform plan: dev or Terraform plan: prod. The comment is updated in place on later pushes. This workflow never changes AWS and uses a read-only role.

### 2. Apply on merge (terraform-apply.yml)

Runs on pushes to main that touch `envs/**` or `modules/**`, and can also be started manually. Environments deploy one at a time: `dev` first, then `prod`. If `dev` fails, `prod` does not run. The `prod` GitHub Environment can require a reviewer, so a `prod` deployment waits for approval. A verification step confirms the job is running as the apply role before anything is created.

### 3. Destroy (terraform-destroy.yml)

Manual only, and only from `main`. You choose an environment and must type its name again to confirm. The workflow turns off deletion protection on the database and load balancer, shows the destroy plan, and then destroys the environment.

## Authentication and IAM

GitHub Actions assumes AWS roles through OpenID Connect. Each job requests a short-lived token, and AWS exchanges it for temporary credentials if the token matches the role's trust policy.


| Role | Used by | Permissions |
|---|---|---|
| Plan role | `terraform-plan.yml` | Read-only access to the services in this stack, plus read and lock access to the state bucket |
| Apply role | `terraform-apply.yml`, `terraform-destroy.yml` | Create, change, and delete access scoped to this stack's services, region, and resource names, plus write access to the state files |

The apply role's trust policy is restricted to this repository, to the `dev` and `prod` GitHub Environments, and to the specific workflow files that are allowed to use it (`job_workflow_ref`). A pull request branch cannot assume it.

## State management

Terraform state is stored in an S3 bucket with one key per environment: `dev/terraform.tfstate` and `prod/terraform.tfstate`. State locking uses S3's native lock file, so concurrent runs against the same environment are blocked.

### Setup
1. **S3 bucket** for Terraform state, with versioning and encryption enabled.
2. **OIDC identity provider** in IAM for `token.actions.githubusercontent.com` with `audience sts.amazonaws.com`
3.  **Two IAM roles** (plan and apply) with trust policies scoped to this repository.
4.  **GitHub Environments** named `dev` and `prod`. Add a required reviewer to `prod`.
5.  **Repository variables** (Settings, Secrets and variables, Actions, Variables):

   | Variable | Value |
   |---|---|
   | `AWS_ROLE_ARN` | ARN of the plan role |
   | `AWS_APPLY_ROLE_ARN` | ARN of the apply role |
   | `AWS_REGION` | `us-east-1` |

6. Open a pull request to see the plan comments, and merge to deploy.

## Lessons learned
These came up while building the pipeline and are worth knowing before setting up something similar.

- **GitHub's OIDC subject format changed.** Repositories created after July 15, 2026 use an immutable subject that includes numeric owner and repository IDs (for example repo:OWNER@123/REPO@456:...). Trust policies written for the older name-only format are rejected. Printing the token's claims in a debug step shows exactly what GitHub sends.
- **Using a GitHub Environment changes the OIDC subject.** A job that sets environment: dev sends a subject ending in environment:dev, even when it runs on a pull request, so the IAM trust policy must list the environment:<name> form.
- **Plan and apply need different roles.** Previews run on every PR, so the role they use should not be able to change infrastructure.
- **State write access is essential for apply.** If an apply cannot save state, it leaves real resources behind that Terraform has no record of.
- **Re-running a workflow replays the old file.** "Re-run jobs" uses the workflow file from the original commit. Workflow fixes require a new run on a new commit.
- **AWS free plan accounts restrict some RDS settings.** Backup retention and instance size had to be reduced to fit, so the deployed database settings are smaller than a typical production setup.
- **Deletion protection blocks terraform destroy.** The destroy workflow disables it first.

## Cost and cleanup

Running both environments is not free. NAT gateways, load balancers, and RDS instances bill by the hour while they exist. Tear environments down when you are finished using the **Terraform Destroy** workflow, then check the AWS console for leftovers (NAT gateways, Elastic IPs, load balancers, databases, and snapshots).

## Possible improvements
- Add HTTPS to the load balancer with an ACM certificate and an HTTP-to-HTTPS redirect
- Narrow the apply role's permissions further using CloudTrail or IAM Access Analyzer
- Add a permissions boundary for the IAM roles that Terraform creates
- Add cost estimation (for example, Infracost) to the PR comments
- Add security scanning (for example, tfsec or Checkov) to the plan workflow
- Restore production-grade database settings (Multi-AZ, larger instance, longer backup retention) on a paid account plan
