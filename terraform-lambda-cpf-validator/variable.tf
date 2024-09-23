# variables.tf

variable "stage" {
  description = "Environment stage (e.g., dev, prod)"
  type        = string
  default     = "dev"
}
