provider "aws" {
  region  = "eu-central-1"
}

terraform {
  backend "s3" {
    encrypt        = true
    bucket         = "new-test-bucket-xyz"
    profile        = "default"
    region         = "eu-central-1"
    key            = "terraform.tfstate"
  }
}
