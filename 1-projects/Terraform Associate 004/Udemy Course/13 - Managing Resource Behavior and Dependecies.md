
## Controlling Resource Order with Explicit Dependencies


- `depends_on` Meta-Argument (explicit dep)
- e.g. a Webserver requires ready Database


How Terraform detects the dep (implicit)

- `implicit` dep - when one resource reference another resource's attribute



## Managing Resource Behavior

`lifecycle` Meta-Argument

- `create_before_destroy` -  to prevent downtime
- `prevent_destroy` - to prevent accidental destroy (production DB)
- `ignore_changes` - resource might change out of Terraform (AWS autoscaling...etc.)
- `replace_triggered_by` - forces resource replacement when specified resource or attributes change
- `precondition`, `postcondition` - validate resource state before/after operations



## Validating Configuration


Four mechanisms (in Order of Operations)

1. Variable Validation (failure stops plan/apply)
2. Preconditions (before creating a resource)
3. Postconditions (after creating a resource)
4. Checks Blocks (a very last step, reports warning on check failure) - e.g. health-check on API /health


https://developer.hashicorp.com/terraform/language/block/check








