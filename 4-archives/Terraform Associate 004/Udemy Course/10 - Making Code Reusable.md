

## Built-in functions

- min, max ....



## Dynamic Values


## Data Sources

- for dynamic lookups
- they do not create, just read existing resources



## `count` Meta-Argument

- allows to create multiple identical resources using a single block
- each item has an index 


```bash
variable "vm_count" {
  type    = number
  default = 3
}

resource "azurerm_virtual_machine" "example" {
  count = var.vm_count
  name  = "vm-${count.index}"
}
```

- a `for_each` might be better -> with changing `count` value TF might recreate resources !


## `for_each` Meta-Argument

- works over a `Map` or a `Set` (unlike `count` with number)
- each has a key
- more stable and flexible, prefer over `count`



