terraform {
    backend "s3" {
        key = "ca/consul/terraform.tfstate"
        region = "us-west-2"
    }
}
