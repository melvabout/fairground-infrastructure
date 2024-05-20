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
    end_point_aws_security_group_id = "khhjkjh"
    this_aws_vpc_id = "djjdjdjd"
  }
}

dependency "storage" {
  config_path = "../storage"
  
  mock_outputs = {
    bucket_id = "bucket-bucket"
  }
}

inputs = {
  subnet_ids = dependency.network.outputs.private_subnets_list
  server_image_id = "ami-055ebfd5334bbdd77" # k8-server-aws-redhat-20240518093442
  s3_bucket = dependency.storage.outputs.bucket_id
  s3_key = "lambda/python/populate-hosts.zip"
  endpoint_security_group = dependency.network.outputs.end_point_aws_security_group_id
  vpc_id = dependency.network.outputs.this_aws_vpc_id
}