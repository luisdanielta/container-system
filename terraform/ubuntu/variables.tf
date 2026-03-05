variable "username" {
  description = "System username for the Ubuntu environment"
  type        = string
}

variable "password" {
  description = "Password for the sudo user"
  type        = string
  sensitive   = true # Prevents password from leaking in logs
}