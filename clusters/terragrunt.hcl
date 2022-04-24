# remote_state {
#   backend = "s3"

#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite_terragrunt"
#   }

#   config = {
#     encrypt = true
#     key     = format("%s/terraform.tfstate", path_relative_to_include())
#     bucket  = "pb-mission-live-tf-state-${local.account_name}-${local.aws_region}"
#     region  = local.aws_region
#   }
# }