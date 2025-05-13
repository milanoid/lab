- uses `vim` key bindings (`j` - down, `k` - up etc.)

## Goodies for pods
- `shift+a` - sorting on age of the pods
- `shift+s` - sorting by status

### Logs

- `l` - show logs
- `s` - toggle on/off the autoscroll
- `ctrl+u` - scroll up
- `ctrl+d` - scroll down
- `/`  - search the logs (works also on the pods list!)
- `0` - tail (absolute last line)
- `1` - head

#### Attach to a pod (open shell)

- `s` - shell for a selected pod
- `ctrl+d` - exit the shell

### Restart a pod

- `ctrl+k` - restart a selected pod

### Describe a pod

- `d` - describe a selected pod


### Delete a pod

- `ctrl+d` - delete a pod (with a confirmation)

### Port forwarding

- `shift+f` 
- `y` - show yaml file

## Goodies for other resources

On a main screen `:`

`:` > `deploy` - show deployments

- `s` - scale a deployment
- `e` - edit