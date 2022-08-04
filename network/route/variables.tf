variable "nat_subnet_id" {
  type = string
}

variable "subnets" {
  type = list(string)
}

variable "internet_gateway" {
  type = string
}

variable "vpc_id" {
  type = string
}
