# Partial configuration: bucket, key and region are supplied at init time so
# the same code can serve dev and prod. Example:
#
#   terraform init \
#     -backend-config="bucket=<your-state-bucket>" \
#     -backend-config="key=prod/terraform.tfstate" \
#     -backend-config="region=eu-west-1" \
#     -backend-config="encrypt=true" \
#     -backend-config="use_lockfile=true"
terraform {
  backend "s3" {}
}
