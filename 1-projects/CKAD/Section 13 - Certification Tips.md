CKAD - 2 hours/19 questions

1. try all the questions, do not get stuck, can skip and later go back
2. do not get stuck not on even easy questions
3. get good with yaml
4. use alias names, e.g. `pv` for `Persistent Volumes`


https://www.youtube.com/watch?v=rnemKrveZks

- get familiar with K8s doc pages
- be good with yaml


Time management
- editor - I want use `vim` `KUBE_EDITOR`
- kubectl aliases
- set context & namespace `kubectl config set-context <cluster-name> --namespace=myns`
- `explain` is useful `kubectl explain cronjob.spec.jobTemplate --recursive`
- use `dryrun=client`
- unix bash oneliners (multicontainer pod)
	  `args: ["-c", "while true; do date >> /var/log/app.txt; sleep 5; done"]`
	  - use `grep`