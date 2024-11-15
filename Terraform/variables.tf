variable "aws_access_key" {
  type      = string
  sensitive = true
}
variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "region" {}

variable "instance_type" {
  default = "t3.medium"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance"
  default     = "db.t3.micro"
}

variable "db_name" {
  description = "The name of the database to create when the DB instance is created"
  type        = string
  default     = "ecommercedb"
}

variable "db_username" {
  description = "Username for the master DB user"
  type        = string
  sensitive   = true
  default     = ""
}

variable "db_password" {
  description = "Password for the master DB user"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dockerhub_username" {
  description = "Username for the dockerhub"
  type        = string
  sensitive   = true
  default     = ""
}

variable "dockerhub_password" {
  description = "Password for the dockerhub"
  type        = string
  sensitive   = true
  default     = ""
}

