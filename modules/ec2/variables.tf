variable "ami_id" {
  type = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "subnet_id" {
  type = string
}

variable "instance_name" {
  type = string
}

variable "s3_bucket_arn" {
  type = string
}
