
env vars to enable detailed logs

`export TF_LOG=trace|debug|info|warn|error`

- logs both Terraform Core and the Provider plugins

## Separate Core and Provider Logging

`export TF_LOG_CORE=trace`

vs

`export TF_LOG_PROVIDER=trace`


### Saving Logs to a File

```
export TF_LOG=debug
export TF_LOG_PATH=terrafor.log
```

- logs are appending

