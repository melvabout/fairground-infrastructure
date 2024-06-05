# fairground-infrastructure

Working through [Kubernetes the hardway](https://github.com/kelseyhightower/kubernetes-the-hard-way). Combining this repo with [fairground-machine-images](https://github.com/melvabout/fairground-machine-images) and [python-lambda-populate-hosts](https://github.com/melvabout/python-lambda-populate-hosts) you have everything up to and including [step 10](https://github.com/kelseyhightower/kubernetes-the-hard-way/blob/master/docs/10-configuring-kubectl.md). More to follow.

## Disclaimer
A little light (read no) testing and not really written for reusability.

Currently not intending to use EKS. Quoting Mrs Doyle: "Maybe I like the misery."

## Known issues

`populate_hosts.py` script isn't working correctly. Manual runs resolve issues provided that the added pod route on the server is removed first.