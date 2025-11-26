variable "vpc_id" {
  type        = string
  description = "ID of the VPC"
}

variable "name_prefix" {
  type        = string
  description = "Prefix used for naming SG"
}

variable "inbound" {
  description = "List of inbound SG rule objects"
  type = list(object({
    description = string
    protocol    = string
    from        = number
    to          = number
    cidr        = string
  }))
}

variable "outbound" {
  description = "List of outbound SG rule objects"
  type = list(object({
    description = string
    protocol    = string
    from        = number
    to          = number
    cidr        = string
  }))
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags applied to the security group"
}
