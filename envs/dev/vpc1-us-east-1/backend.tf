terraform {
  backend "s3" {
    bucket = "tmo"
    key    = "envs/dev/vpc1-us-east-1/terraform.tfstate"
    region = "us-east-1"
  }
}
