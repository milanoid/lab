

## zoxide

- better `cd`
- self-learn the most used paths

```bash
milan@SPM-LN4K9M0GG7 ~
> z devops
milan@SPM-LN4K9M0GG7 ~/repos/devops-terraform (PEP-2852-qa-jdk21-task-definition-prod)
>
```

## fzf

## direnv

- [ ] setup milanoid repo, populate with env
- [ ] setup SP repo - use `secureden-cli` to retrieve secrets
	- [ ] ask for Admin/token (not available in UI)

- not only for configuring env vars, but can also run a custom script (e.g. uv install)


### securden-cli

```bash
# SP config
securden-cli config --url https://statsperform.securden-pam.com


# get secret

```

---


## Hermes


https://hermes-agent.nousresearch.com/

- [ ] as VM in Proxmox


- official docker image https://hub.docker.com/r/nousresearch/hermes-agent


### cron jobs

- regular reports, batch processing
- "reminders" - "In an hour remind me ...."

## webhooks




## memory management

- permanent (basics)
- procedural (skills)
- history from previous sessions

- multiple user support
- multiple agent support


## Messaging gateway

- primary way to communicate with Hermes
- e.g. Slack, Telegram, Whatsapp, Signal .... many more including self-hosted solution (Metrix)
- even voice messages


## Hermes Desktop


- installs also a local agent
- dashboard
- not recommended 




## Security

- do not trust Hermes
- prompt injection
- egress firewall, SE Linux