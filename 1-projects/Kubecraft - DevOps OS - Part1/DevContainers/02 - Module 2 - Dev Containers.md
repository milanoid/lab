- by MS https://containers.dev/

# Creating our first Dev Container

## How a 'normal' person use Dev Containers

VS Code with Dev Containers extension. There are ready to use containers for development, e.g. python. Just to show what a developer would use. 

We will be using a command line approach instead.

- https://code.visualstudio.com/docs/devcontainers/containers





# Spec & Base Images


https://containers.dev/implementors/spec/

Example of real world `.devcontainer/devcontainer.json`

```json
{
	"name": "devops-monitoring",
	"build": {
		"dockerfile": "Dockerfile"
	},
	"remoteEnv": {
		"POETRY_HTTP_BASIC_NEXUS_USERNAME": "${localEnv:NEXUS_USER}",
		"POETRY_HTTP_BASIC_NEXUS_PASSWORD": "${localEnv:NEXUS_PASS}",
		"JENKINS_CRED_USR": "${localEnv:JENKINS_USER}",
		"JENKINS_CRED_PSW": "${localEnv:JENKINS_PASS}",
		"JENKINS_URL": "https://jenkins.com",
		"AWS_PROFILE": "${localEnv:AWS_PROFILE}"
	},
	"mounts": [
		"source=${localEnv:HOME}${localEnv:USERPROFILE}/.pip,target=/root/.pip,type=bind,consistency=cached",
		"source=${localEnv:HOME}${localEnv:USERPROFILE}/.aws,target=/root/.aws,type=bind,consistency=cached"
	],
	"customizations": {
		"vscode": {
			"extensions": [
				"ms-python.python"
			]
		}
	}

	// 👇 Features to add to the Dev Container. More info: https://containers.dev/implementors/features.
	// "features": {},

	// 👇 Use 'forwardPorts' to make a list of ports inside the container available locally.
	// "forwardPorts": [],

	// 👇 Use 'postCreateCommand' to run commands after the container is created.
	// "postCreateCommand": "",


	// 👇 Uncomment to connect as root instead. More info: https://aka.ms/dev-containers-non-root.
	// "remoteUser": "root"
}
```


Devcontainers base images https://github.com/devcontainers/images/tree/main/src for all mainstream languages (java, python, ruby ...). With all basic tooling installed (ssh, git, svn ...) and VS Code extensions.





