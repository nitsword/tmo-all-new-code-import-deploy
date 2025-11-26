variable "vpc_id" {
  type = string
}

variable "name_prefix" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "subnets" {
  type = object({
    public = map(object({
      cidr = string
      az   = string
    }))

    private = map(object({
      cidr = string
      az   = string
    }))

    nonroutable = map(object({
      cidr = string
      az   = string
    }))
  })
}
