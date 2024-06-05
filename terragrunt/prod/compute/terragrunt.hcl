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

dependency "monitoring" {
  config_path = "../monitoring"
  
  mock_outputs = {
    fairground_instance_aws_sns_topic_arn = "arn:aws:sns:eu-west-2:111122223333:MyTopic"
  }
}

inputs = {
  subnet_ids = dependency.network.outputs.private_subnets_list
  server_image_id = "ami-0b79883452797386c" 
  node_image_ids = {
    node-0 = "ami-00178f168c76323cf" 
    node-1 = "ami-09d3f273bcdeefdba" 
  }
  s3_bucket = dependency.storage.outputs.bucket_id
  s3_key = "lambda/python/populate-hosts.zip"
  endpoint_security_group = dependency.network.outputs.end_point_aws_security_group_id
  vpc_id = dependency.network.outputs.this_aws_vpc_id
  sns_topic_arn = dependency.monitoring.outputs.fairground_instance_aws_sns_topic_arn
}