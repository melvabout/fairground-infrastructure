include "root" {
  path = find_in_parent_folders()
}

terraform {
  source =  "${path_relative_from_include()}/../../terraform/${path_relative_to_include()}"
}

dependency "encryption" {
  config_path = "../encryption"

  mock_outputs = {
    kms_key_arn = "arn:arn:arn"
  }
}

inputs = {
  kms_key_arn = dependency.encryption.outputs.kms_key_arn
}