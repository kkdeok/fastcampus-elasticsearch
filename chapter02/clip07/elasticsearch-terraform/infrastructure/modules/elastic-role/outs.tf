output "elastic_role_id" {
  value = aws_iam_role.elastic_role.id
}

output "elastic_instance_profile_name" {
  value = aws_iam_instance_profile.elastic_role_instance_profile.name
}