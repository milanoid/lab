
_or how to handle secrets_


## The Problem

Terraform needs secrets to manage infrastructure, but those secrets can be exposed in multiple places. Secrets are stored as plaintext in State.

Secrets shared across teams. Remote backends make state accessible to multiple people and lags and outputs are captured.


