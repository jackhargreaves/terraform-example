variable "fixed_id" {
  type = string
}

variable "parameterized_id" {
  type = map(string)
}

output "fixed_integer" {
  value = random_integer.fixed.result
}

output "parameterized_integer" {
  value = random_integer.parameterized["label"].result
}

# a child resource that has remained as is
resource "random_integer" "fixed" {
  keepers = {
    value = var.fixed_id
  }

  min = 0
  max = 1000000
}

# a child resource that has been ported to use a for_each stmt
resource "random_integer" "parameterized" {
  for_each = var.parameterized_id
  keepers = {
    value = each.value
  }

  min = 0
  max = 1000000
}

# describe how the parameterized child resources are moving within the module
moved {
  from = random_integer.parameterized
  to   = random_integer.parameterized["label"]
}
