variable "aws_region" {
  description = "region"
  default     = "ap-southeast-1"
}

variable "az_count" {
  description = "Number of AZs to cover in a given AWS region"
  default     = "2"
}

variable "tag_name" {
  description = "AWS resource tag Name"
}

variable "key_name" {
  description = "Name of AWS key pair"
  default = "fc_test_key"
}

variable "admin_cidr_ingress" {
  description = "CIDR to allow tcp/22 ingress to EC2 instance"
  default     = "0.0.0.0/0"
}