variable "fixed_id" {
  type = string
}

variable "parameterized_id" {
  type = string
}

output "fixed_integer" {
  value = random_integer.fixed.result
}

output "parameterized_integer" {
  value = random_integer.parameterized.result
}

# a child resource that will remain as is
resource "random_integer" "fixed" {
  keepers = {
    value = var.fixed_id
  }

  min = 0
  max = 1000000
}

# a child resource that will be ported to use a for_each stmt
resource "random_integer" "parameterized" {
  keepers = {
    value = var.parameterized_id
  }

  min = 0
  max = 1000000
}

