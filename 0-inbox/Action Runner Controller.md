

Goal: understand how it works, what components it uses, how it all fits together


## vocabulary

ScaleSet
ScaleSet API
Listener
Runner
Runner Scale Set
EphemeralRunner
JIT config - Just In Time configuration
[HPA](https://kubernetes.io/docs/concepts/workloads/autoscaling/horizontal-pod-autoscale/)
...


# The big picture

- Scale set API -> contract between Github and K8s
- ARC decided _how many_ runners should exist and makes reality match that number
- Github decides which runner gets assigned a job
- EphemeralRunners are registering to GitHub
- When runner gets terminate it also de-register itself


Why not use K8s native HPA?

- HPA is for stateless, interchangeable 

```
 GITHUB (control of WORK)         K8S (control of COMPUTE)
 ┌───────────────────────┐        ┌────────────────────────┐
 │ workflow: runs-on: X  │        │ ARC decides how many   │
 │ job queue             │◄──────►│ runner pods exist and  │
 │ scale set "X"         │  API   │ starts / removes them  │
 └───────────────────────┘        └────────────────────────┘
```




