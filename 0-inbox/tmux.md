`tmux` - starts a session with one _window_ and a single _panel_


- all commands are triggered by a _prefix key_ followed by a _command key_
- default _prefix key_ is `C-b` (emacs notation) ~ `CTRL-B` (press `CTRL` and `b`) 

### Splitting Panes

- `C-b %` - splits single pane into a left and right pane (vertical split)
- `C-b "` - splits single pane into up and down pane (horizontal split)


### Navigating Panes

- `C-b <arrow key>`

### Closing Panes

- `C-d` or typy `exit`


### Creating Windows

analogy - virtual desktops

- `C-b c` - create a new window
- `C-b p` - switch to a **p**revious window
- `C-b n` - switch to a **n**ext window
- `C-b <number>` - switch directly to a window


### Session Handling

A session can be closed by exiting all the panes inside or you can keep the session in the background for alter reuse.

- `C-b d` - detach from current session

Detaching from a session will leave everything you're doing in that session running in the background!

```bash
milan@SPM-LN4K9M0GG7 ~
> tmux 
> [detached (from session 1)]
```

- `C-b D` - gives a choice on which session to detach from

#### re-attach

- `tmux ls` - list sessions
- `tmux attach -t <session_id>` - attach back to a sesion 

```bash
milan@SPM-LN4K9M0GG7 ~
> tmux ls
1: 2 windows (created Thu Jun  4 10:25:58 2026)

milan@SPM-LN4K9M0GG7 ~
> tmux attach -t 1
```


#### naming sessions

- `tmux new -s homelab` - creates a new session with name instead of just number
- `tmux rename-session -t 0 homelab` - rename existing session