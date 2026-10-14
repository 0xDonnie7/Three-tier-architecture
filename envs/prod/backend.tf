terraform {
  backend "s3" {
    bucket       = "donnie-tfstate-12345"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}
