variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_ami_id" {
  default = "ami-95f8d2f3"
}

variable "aws_keypair_name" {
  default = "teamcity_keypair"
}

variable "aws_keypair_file" {
  default = "~/.ssh/terraform_rsa.pub"
}

variable "teamcity_db_name" {
  default = "teamcitydb"
}

variable "teamcity_db_user" {
  default = "teamcity_app"
}

variable "teamcity_db_pass" {
  default = "randomsecretpassword"
}
