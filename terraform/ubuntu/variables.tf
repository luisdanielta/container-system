variable "username" {
  description = "System username for the environment"
  type        = string
}

variable "password" {
  description = "Password for the sudo user"
  type        = string
  sensitive   = true
}