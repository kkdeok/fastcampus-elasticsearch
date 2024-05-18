variable "cluster_name" {
  type = string
  default = "elasticsearch"
}

variable "name" {
  type = string
}

variable "role" {
  type        = string
  description = "elastic role"

  validation {
    condition     = contains(["master", "data"], var.role)
    error_message = "supported elastic role is master or data for now."
  }
}

variable "subnet_ids" {
  type        = list(string)
  description = "ASG VPC Zone ID"
}

variable "is_seed_master_node" {
  type        = bool
  default     = false
  description = "Is seed node for using initial master node"
}

variable "cnt" {
  type        = number
  description = "The number of elastic node with the role."
  default     = 1
}

variable "image_id" {
  type        = string
  default     = "ami-0c031a79ffb01a803"
  description = "AWS EC2 image id"
}

variable "key_pair_name" {
  type        = string
  default     = "elastic"
  description = "AWS EC2 key pair name"
}

variable "instance_type" {
  type        = string
  default     = "t2.small"
  description = "AWS EC2 instance type"
}

variable "sg_id" {
  type        = string
  description = "AWS security group id"
}

variable "instance_profile_name" {
  type        = string
  description = "AWS instance profile"
}

variable "monitoring_elasticsearch_host" {
  type = string
  description = "Monitoring elasticsearch host"
  default = ""
}

variable "metricbeat_image" {
  type = string
  description = "Metricbeat docker image"
  default = "busybox"
}