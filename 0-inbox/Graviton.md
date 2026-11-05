
https://github.com/milanoid-labs/milanoid-aws-terraform

```bash
# plan/apply
GRAVITON_TARGETS=(
  -target=aws_ecr_repository.graviton_playground
  -target=aws_security_group.graviton_runner
  -target=aws_iam_role.graviton_runner
  -target=aws_iam_role_policy_attachment.graviton_runner_ssm
  -target=aws_iam_role_policy.graviton_runner_token
  -target=aws_iam_role_policy.graviton_runner_ecr_push
  -target=aws_iam_instance_profile.graviton_runner
  -target=aws_ssm_parameter.graviton_runner_token
  -target=aws_instance.graviton_runner
)

tofu plan "${GRAVITON_TARGETS[@]}" -out /tmp/graviton.plan
tofu apply "/tmp/graviton.plan"


aws ssm put-parameter --name /graviton-runner/registration-token \
  --type SecureString --overwrite \
  --value "$(gh api -X POST orgs/milanoid-labs/actions/runners/registration-token -q .token)"
  
  
# destroy
tofu destroy
```