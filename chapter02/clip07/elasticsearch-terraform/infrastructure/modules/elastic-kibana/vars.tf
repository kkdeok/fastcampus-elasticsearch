variable "subnet_ids" {
  type        = list(string)
  description = "ASG VPC Zone ID"
}


variable "sg_id" {
  type        = string
  description = "EC2 Security Group"
}


variable "vpc_id" {
  type        = string
  description = "Target Group VPC ID"
}

variable "image_id" {
  type        = string
  default     = "ami-0c031a79ffb01a803"
  description = "AWS EC2 image id"
}

variable "instance_type" {
  type        = string
  default     = "t2.small"
  description = "AWS EC2 instance type"
}

variable "instance_profile_name" {
  type        = string
  description = "AWS instance profile"
}

variable "kibana_image" {
  type        = string
  description = "Docker Image for Kibana"
  default     = "docker.elastic.co/kibana/kibana:8.12.2"
}

variable "elasticsearch_host" {
  type        = string
  description = "Elasticsearch URL"
}

variable "monitoring_elasticsearch_host" {
  type        = string
  description = "Monitoring Elasticsearch URL"
}

variable "key_name" {
  type        = string
  description = "EC2 Key Pair Name"
  default     = "elastic"
}

variable "cnt" {
  type    = string
  default = "1"
}