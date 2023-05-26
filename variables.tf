variable "region" {
  description = "choose region what ever you want"
  type        = string
  default     = ""
}
variable "vpc_id" {
  description = "providing existing vpc id"
  type        = string
  default     = ""
}

variable "subnets" {
    type        = list(string)
    default     = [""]  
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = ""
}
variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = ""
}

variable "health_check_path" {
  default = "/auth/"
}

variable "www_domain_name" {
  type        = string
  description = "The domain name for the website"
  default     = ""
}

variable "validation_method" {
  type        = string
  description = "Give validation method to validate the ssl certificate(DNS or EMAIL)"
  default     = "DNS"
}