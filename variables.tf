variable "instance_type" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_type_db" {
  description = "The EC2 instance type"
  type        = string
  default     = "t3.small"
}

variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "us-east-1"
}

variable "IP_Address" {
  description = "The IP address for the EC2 instance"
  type        = string
  /* default     = "192.18.1.100" */
}

variable "key_pair_name" {
  description = "The name of the key pair"
  type        = string
  default     = "tf-key-pair"
}

variable "ssh_username" {
  description = "SSH username"
  type        = string
  default     = "techcorpuser"
}

variable "ssh_password" {
  description = "SSH password"
  type        = string
  sensitive   = true
}