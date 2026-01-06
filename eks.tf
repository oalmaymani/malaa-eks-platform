module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "mallaa-eks-tf"
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = slice(module.vpc.private_subnets, 1, 3)
  control_plane_subnet_ids = slice(module.vpc.private_subnets, 1, 3)

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    servers-nodes = {
      min_size     = 4
      max_size     = 10
      desired_size = 4

      instance_types = ["t3.medium"]
      capacity_type  = "ON_DEMAND"
      
      # ✅ Force node group to use 1.31 (prevent automatic upgrade to 1.34)
      ami_type = "AL2_x86_64"

      # ✅ Give nodes permissions for EBS CSI (temporary approach, avoids IRSA cycle)
      iam_role_additional_policies = {
        AmazonEBSCSIDriverPolicy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }
    }
  }

  # ✅ Break the cycle: install the addon WITHOUT service_account_role_arn
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  enable_cluster_creator_admin_permissions = true
  tags = local.tags
}

# ✅ Temporarily disable IRSA role module to avoid circular dependency
# You can re-enable later by moving addon attachment to a separate aws_eks_addon resource
# (but you said no new files/resources now).
#
# module "ebs_csi_irsa_role" {
#   source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#   version = "~> 5.0"
#
#   role_name             = "ebs-csi-irsa-mallaa"
#   attach_ebs_csi_policy = true
#
#   oidc_providers = {
#     ex = {
#       provider_arn               = module.eks.oidc_provider_arn
#       namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
#     }
#   }
# }
