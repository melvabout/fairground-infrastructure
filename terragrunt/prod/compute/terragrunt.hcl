include "root" {
  path = find_in_parent_folders()
}

terraform {
  source =  "${path_relative_from_include()}/../../terraform/${path_relative_to_include()}"
}

dependency "network" {
  config_path = "../network"
  
  mock_outputs = {
    private_subnets_list = ["kjhhakjsh"]
    public_subnets_list = ["kjhhakjsh"]
  }
}

inputs = {
  subnet_ids = dependency.network.outputs.private_subnets_list
  server_image_id = "ami-0d9bca9b2b1760291" # k8-server-aws-redhat-20240516071713
}