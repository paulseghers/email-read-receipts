variable "aws_profile" {
  description = "AWS profile to use locally. Set to an empty string in CI to use environment credentials."
  type        = string
  default     = "" #local profile on my machine
}

provider "aws" {
  region  = "eu-west-1"
  profile = var.aws_profile != "" ? var.aws_profile : null # in CI we use env variables, not a profile
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "email_read_receipts_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1a"
}

resource "aws_subnet" "email_read_receipts_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-1b"
}
