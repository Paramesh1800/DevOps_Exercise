terraform {
  source = "../../modules/eks"
}

inputs = {
  cluster_name = "prod-eks"
  aws_region   = "ap-south-1"
}