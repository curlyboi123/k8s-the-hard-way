terraform {
  backend "s3" {
    bucket = "john-bucket-terraform-state"
    key    = "learn-k8s-the-hard-way"
    region = "eu-west-1"
  }
}
