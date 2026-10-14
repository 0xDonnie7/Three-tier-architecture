# Partial configuration: bucket, key and region are supplied at init time so
# the same code can serve dev and prod. Example:
# change key from "dev/terraform.tfstate" to "prod/terraform.tfstate" and run `terraform init -reconfigure` to switch to prod.
terraform {
  backend "s3" {
    bucket       = "donnie-tfstate-12345"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
