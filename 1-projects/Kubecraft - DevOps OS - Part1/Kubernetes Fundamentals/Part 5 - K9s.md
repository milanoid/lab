vim keybindings

- SHIFT+? - help
### Sorting Pods

- SHIFT+A -> by Age
- SHIFT+S -> by Status

### Pod Logs

while focused on a Pod hit `L`

then:

- `S` - for toggling auto scroll
- CTRL+U - scroll up a page
- CTRL+D - scroll down a page
-  `/` - then type a string to search for, works on list of Pods too

### Attach to a Pod (open shell)

while focused on a Pod hit `S` (for shell)

### Actions on a Pod

- CTRL+K - restart Pod
- D - describe
- CTRL+D - delete Pod
- SHIFT+F - port forward
- Y - YAML manifest

### Actions on Deployment

- `:` then `deployement` to show deployments
-  L - logs of deployment (all Pods in deployment)
- e - Edit, opens default terminal 

 Similarly one can switch from Pods to Deployment to Services and others.
