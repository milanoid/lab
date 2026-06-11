I'm not going to use the devcontainer/devpod setup yet.

I'll be using Mac with `uv` and other tools I have already setup.

---

# Conventional commits & Commitizen

- https://www.conventionalcommits.org/en/v1.0.0/
- https://commitizen-tools.github.io/commitizen/


## Commitizen

- helps with conventional commits
- has a hook with a [pre-commit](https://pre-commit.com/) (script being triggered on a commit event)


- [x] pre-commit installed
- [x] commitizen installed `brew install commitizen`
- [x] setup pre-commit hook

```yaml
# basic pre-commit hook @.pre-commit-config.yaml
repos:  
  - repo: https://github.com/commitizen-tools/commitizen  
    rev: v1.17.0  
    hooks:  
      - id: commitizen  
        stages: [commit-msg]
```

- ensures every commit follows the conventional commits standard


---

## Commitizen in action

```bash
# init
cz init
```