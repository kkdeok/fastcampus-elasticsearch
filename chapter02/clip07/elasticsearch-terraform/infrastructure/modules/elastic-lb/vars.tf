variable "tg_asg_name" {
  type        = string
  description = "Target Auto Scaling Group Name"
}

variable "is_internal" {
  type        = bool
  description = "Internal Load Balancer"
  default     = false
}

variable "name" {
  type        = string
  description = "Load Balancer Name"
}

variable "sg_ids" {
  type        = list(string)
  description = "EC2 Security Groups"
}

variable "cluster_name" {
  type        = string
  description = "ES Cluster Name"
}

variable "subnet_ids" {
  type        = list(string)
  description = "LoadBalancer Subnet IDs"
}

variable "vpc_id" {
  type        = string
  description = "Target Group VPC ID"
}

variable "ports" {
  type        = map(number)
  description = "LoadBalancer:Port -> TargetGroup:Port"
}

variable "https" {
  type = object({
    enabled      = bool
    acm_cert_arn = string
  })
  description = "TargetGroup Via HTTPS Protocol"
  default     = {
    enabled      = false
    acm_cert_arn = ""
  }
}
