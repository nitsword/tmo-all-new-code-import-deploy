variable "vpc_id" {}
variable "name_prefix" {}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "public_subnet_ids_map" {
  type = map(string)
}

variable "nonroutable_subnet_ids_map" {
  type = map(string)
}
