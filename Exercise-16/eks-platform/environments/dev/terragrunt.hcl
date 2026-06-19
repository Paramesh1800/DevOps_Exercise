terraform {
  source = "../../modules/eks"
}

inputs = {
  cluster_name = "dev-eks"
  aws_region   = "ap-south-1"
}