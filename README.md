# terraform-example
Demonstrates a bug with the `moved` terraform statement.

The `moved` statements within a child module fail to *all* parameterized
resouces.

In this example we create two foo modules. Each module creates two random
integers using the `random_id` resource.
We then parameterize the foo modules and parameterize one of the `random_id`
modules. We provide `moved` statments for the foo modules in `root/main.tf`
and for `moved` statements for the parameterized `random_id` resource are
provided with foo module terraform code. The expected behaviour on apply is
that nothing should happen. However, one and only one of the foo modules
recreates its parameterized `random_id` integers. We have to provide
explicit `moved` statements for the `random_id` resources in `root/main.tf`.

# Setup

```bash
cd root
cp main.tf.initial main.tf
terraform init
terraform apply -auto-approve
```

Which should output something like:

```
...
Apply complete! Resources: 4 added, 0 changed, 0 destroyed.

Outputs:

first = {
  "fixed_integer" = 381343
  "parameterized_integer" = 732293
}
second = {
  "fixed_integer" = 373518
  "parameterized_integer" = 540123
}
```

# Buggy behaviour

To demonstrate the buggy behaviour (after the setup), do:

```bash
cd root
cp main.tf.new main.tf
terraform plan
```

The output will look like:

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
  - destroy

Terraform will perform the following actions:

  # module.first.random_integer.fixed has moved to module.foo["first"].random_integer.fixed
    resource "random_integer" "fixed" {
        id      = "381343"
        # (4 unchanged attributes hidden)
    }

  # module.first.random_integer.parameterized has moved to module.foo["first"].random_integer.parameterized["label"]
    resource "random_integer" "parameterized" {
        id      = "732293"
        # (4 unchanged attributes hidden)
    }

  # module.second.random_integer.fixed has moved to module.foo["second"].random_integer.fixed
    resource "random_integer" "fixed" {
        id      = "373518"
        # (4 unchanged attributes hidden)
    }

  # module.foo["second"].random_integer.parameterized will be destroyed
  # (because resource uses count or for_each)
  # (moved from module.second.random_integer.parameterized)
  - resource "random_integer" "parameterized" {
      - id      = "540123" -> null
      - keepers = {
          - "value" = "second"
        } -> null
      - max     = 1000000 -> null
      - min     = 0 -> null
      - result  = 540123 -> null
    }

  # module.foo["second"].random_integer.parameterized["label"] will be created
  + resource "random_integer" "parameterized" {
      + id      = (known after apply)
      + keepers = {
          + "value" = "second"
        }
      + max     = 1000000
      + min     = 0
      + result  = (known after apply)
    }

Plan: 1 to add, 0 to change, 1 to destroy.

Changes to Outputs:
  ~ second = {
      ~ parameterized_integer = 540123 -> (known after apply)
        # (1 unchanged element hidden)
    }

```

Note how only one of the parameterized `random_id` modules is being recreated
(`second`). The `first` and its child parameterized resources one have been
successfully moved and no recreation is happening.

If you uncomment the last set of `moved` statements then plan becomes:

```
Terraform will perform the following actions:

  # module.first.random_integer.fixed has moved to module.foo["first"].random_integer.fixed
    resource "random_integer" "fixed" {
        id      = "381343"
        # (4 unchanged attributes hidden)
    }

  # module.first.random_integer.parameterized has moved to module.foo["first"].random_integer.parameterized["label"]
    resource "random_integer" "parameterized" {
        id      = "732293"
        # (4 unchanged attributes hidden)
    }

  # module.second.random_integer.fixed has moved to module.foo["second"].random_integer.fixed
    resource "random_integer" "fixed" {
        id      = "373518"
        # (4 unchanged attributes hidden)
    }

  # module.second.random_integer.parameterized has moved to module.foo["second"].random_integer.parameterized["label"]
    resource "random_integer" "parameterized" {
        id      = "540123"
        # (4 unchanged attributes hidden)
    }

Plan: 0 to add, 0 to change, 0 to destroy.
```
