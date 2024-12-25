output "oidc_provider" {
  value = module.eks.oidc_provider
}

output "cluster_name" {
  value = module.eks.cluster_name
}
