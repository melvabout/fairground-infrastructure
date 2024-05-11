locals {
  vpc_cidr = "10.0.0.0/22"

  public_subnets = {
    eu-west-2a : "10.0.0.0/26"
    eu-west-2b : "10.0.0.64/26"
    eu-west-2c : "10.0.0.128/26"
  }
  private_subnets = {
    eu-west-2a : "10.0.1.0/26"
    eu-west-2b : "10.0.1.64/26"
    eu-west-2c : "10.0.1.128/26"
  }
}