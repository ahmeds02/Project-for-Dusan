variable "region" {
  description = "Value of the regions"
  type        = string
  default     = "us-east-1"
}

variable "domainName" {
  default = "ourdb.com"
  type    = string
}

variable "record_name" {
  default = "www"
  type    = string
}

variable "instance_type" {
  description = "Value of the instance type"
  type        = string
  default     = "m5.large"
}


variable "allowed_cidr_blocks" {
  type    = list(any)
  default = ["0.0.0.0/0"]
}

variable "availability_zones" {
  type    = list(any)
  default = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
}

variable "database_name" {
  description = "db name"
  type        = string
  default     = "newdb"
}

variable "database_user" {
  description = "db user"
  type        = string
  default     = "testdb"
}

variable "database_password" {
  description = "db password"
  type        = string
  default     = "welcome123"
}


variable "amis" {
  type = map(any)
  default = {
    "us-east-1" = "ami-0dc2d3c9c0f9ebd18"
    "us-east-2" = "ami-0ba62214bwa52bec7"
  }
}





variable "instance_name" {
  description = "Value of the regions"
  type        = string
  default     = "CloudBhai-EC2-Instance-webserver"
}
