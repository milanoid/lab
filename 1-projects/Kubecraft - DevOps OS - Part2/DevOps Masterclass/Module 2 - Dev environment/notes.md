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
# init first - wizard (conventional commit, semver2, uv, config file to .cz.toml etc)
cz init

# invalid commit message is caught
git commit -m "I am not a conventional commit message"

[INFO] Initializing environment for https://github.com/commitizen-tools/commitizen.
[INFO] Installing environment for https://github.com/commitizen-tools/commitizen.
[INFO] Once installed this environment will be reused.
[INFO] This may take a few minutes...
commitizen check.........................................................Failed
- hook id: commitizen
- exit code: 14

commit validation: failed!
please enter a commit message in the commitizen format.                                                                                               
commit: I am not a conventional commit message
     
                                                                                                                                                      
pattern: (build|ci|docs|feat|fix|perf|refactor|style|test|chore|revert|bump)(\(\S+\))?:\s.*   
```


Using `cz` to walk me through a correct commit message

```bash
> cz commit
? Select the type of change you are committing (Use arrow keys)
 » fix: A bug fix. Correlates with PATCH in SemVer
   feat: A new feature. Correlates with MINOR in SemVer
   docs: Documentation only changes
   style: Changes that do not affect the meaning of the code (white-space, formatting, missing semi-colons, etc)
   refactor: A code change that neither fixes a bug nor adds a feature
   perf: A code change that improves performance
   test: Adding missing or correcting existing tests
   build: Changes that affect the build system or external dependencies (example scopes: pip, docker, npm)
   ci: Changes to CI configuration files and scripts (example scopes: GitLabCI)
```


- for commit message use imperative summary:
```
'adds idea (ide) settings'  # wrong - in 3rd person

'add idea (ide) settings' # right - in base form
```


list commit messages on git cli - `git reflog`:

```bash
milan@SPM-LN4K9M0GG7 ~/repos/devops-study-app (main)
> git reflog
4836a38 (HEAD -> main, origin/main) HEAD@{0}: commit: docs(tooling): fix typo (commitizen)
ed8660c HEAD@{1}: commit: docs(tooling): pre-requisites (git, pre-commit, commitizer)
2e28763 HEAD@{2}: commit: build(idea): adds idea (ide) settings
7e9513e HEAD@{3}: commit: build(commitizen): added .cz.toml commitizen config (cz init)
6dfab84 HEAD@{4}: commit: added pre-commit hook
2138fab HEAD@{5}: commit (initial): first commit
```