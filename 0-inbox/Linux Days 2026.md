

## zoxide

- better `cd`
- self-learn the most used paths
- https://github.com/ajeetdsouza/zoxide

```bash
milan@SPM-LN4K9M0GG7 ~
> z devops
milan@SPM-LN4K9M0GG7 ~/repos/devops-terraform (PEP-2852-qa-jdk21-task-definition-prod)

> z terraform
milan@SPM-LN4K9M0GG7 ~/repos/pe-github-terraform (main)

> z homelab
milan@SPM-LN4K9M0GG7 ~/repos/homelab-cluster (main)
```

## fzf

- https://github.com/junegunn/fzf

```bash
# lists every file under the current directory, recursively, type to search, hit enter to open in 'nvim'
nvim $(fzf)

cat "$(fzf)"
less "$(fzf)"
```

```bash
# list branches, let user pick one and switch to it
git switch $(git branch | fzf)
```


```bash
# Shell keybindings
echo 'eval "$(fzf --bash)"' >> ~/.bashrc && source ~/.bashrc

CTRL+R Fuzzy-search your command history
CTRL+T Insert a file path at the cursor, e.g. type cp  then press Ctrl-T
Alt+C cd into a subdirectory you pick
```
## direnv

- https://direnv.net/

- [ ] setup milanoid repo, populate with env
- [ ] setup SP repo - use `secureden-cli` to retrieve secrets
	- [ ] ask for Admin/token (not available in UI)

- not only for configuring env vars, but can also run a custom script (e.g. uv install)


```bash
> z '/Users/milan/repos/milanoid-labs-terraform'
direnv: loading ~/repos/milanoid-labs-terraform/.envrc
direnv: export +GITHUB_TOKEN +USERNAME ~AWS_PROFILE
```
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