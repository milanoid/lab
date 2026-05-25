https://statsinc.atlassian.net/browse/PEP-2475

## repo https://github.com/statsperform/devops-automatic-atlantis-deploys/


- CI - Jenkins only https://jenkins.statsperform.tools/job/devops.github-repos-sp/job/devops-automatic-atlantis-deploys
- python code (with tests!)

### housekeeping

- Jenkins build WARNings fixes https://github.com/statsperform/devops-automatic-atlantis-deploys/pull/52 + version bump https://github.com/statsperform/devops-automatic-atlantis-deploys/pull/5
- release done via pushing a tag


## testing

1. python code change / image `0.14.0-test` https://github.com/statsperform/devops-automatic-atlantis-deploys/pull/54
2. GHA action referencing new image `0.14.0-test` https://github.com/statsperform/pe-gha-workflows/pull/294 

