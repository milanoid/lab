
`terraform <subcommand> [options or flags]`

- `fmt`, `validate`, `init`, `plan`, `apply`, `destroy`


Using environment variables

- increase security by keeping sensitive data like API keys out of `.tf` files
- e.g. `export TF_LOG=DEBUG`
- pattern  `TF_VAR_NAME`, e.g. `TF_VAR_svr_name="prod-db-01`


plan - _forces replacement_ vs _on the fly_

- [x] configure `~/.terraformrc` https://developer.hashicorp.com/terraform/cli/config/config-file


```bash
credentials "app.terraform.io" {
  token = "tokenvalue"
}
```

- don't need to call `terraform login`