
By Microsoft, a json file specification of a dev environment. The editor will lunch the project in a container.

### Docker

https://wiki.archlinux.org/title/Docker

	pacman -Syu docker

Enable docker

	systemctl enable --now docker.service

```
[milan@jantar lab]$ docker ps
permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/v1.49/containers/json": dial unix /var/run/docker.sock: connect: permission denied
```

	sudo docker info

To fix this I need to add my user to `docker` group (and logout and login back)

	sudo usermod -aG docker milan


#### DevPod

https://devpod.sh/

	yay -Si devpod # to get more informations before installing
	yay devpod

	pacman -Syu btop # a bit nicer "htop"

it does not create a symlink for `devpod`, let's create it:

	sudo ln -sf /usr/bin/devpod-cli /usr/bin/devpod

#### configuration

Set default editor to none (won't start editor when starting devpod)

	devpod ide use none

	devpod provider list
	devpod provider add docker

As a demo project let's use http://github.com/mischavandenburg/pi (having .devcontainer.json spec in root).

	devpod up .
	devpod up . dotfile <git@github:repo-with-my-dotfiles.git>
	devpod ls
	devpod ssh

issue - backspace is not working for me

```
[milan@jantar pi]$ devpod ssh

? Please select a workspace from the list below pi
vscode ????? /workspaces/pi (main) $ !backspace is not working :(
```