# PiB Demo Fleet

![License](https://img.shields.io/badge/license-MIT-green.svg)

## Private Repo Notice

- This is a private repo for a specific project team
  - Contact bartr for access

## Create a Codespace

- From <https://github.com/cse-labs/demo-fleet>
- Click on `Code`
  - Click on the `Codespaces` tab if necessary
- Click `Create Codespace on main`

Once Codespaces starts, exit the terminal `exit` and start a new terminal `ctl "backtick"`

- The initial shell starts before setup is complete

> Validate that you are running `zsh` and not `bash`

## Check Environment

```bash

flt env

```

Expected results

```text

CLI_BIN_DIR=/home/vscode/bin
CLI_BIN_NAME=flt
CLI_BOA_DIR=/home/vscode/bin/.flt
CLI_CMD_DIR=/home/vscode/bin/.flt/commands
PIB_BASE=/workspaces/demo-fleet
PIB_BRANCH=main
PIB_FULL_REPO=https://github.com/cse-labs/demo-fleet
PIB_GHCR=ghcr.io/cse-labs
PIB_PAT=ghu_...
PIB_REPO=cse-labs/demo-fleet

```

## Setup

> Setup is already complete

- Run `create.sh` from the root of the repo
- This will create the cluster metadata for each cluster
- Wait for ci-cd to complete <https://github.com/cse-labs/demo-fleet/actions>
- Run `git pull`
  - You should see the yaml files created in the `clusters` directory

## Setting up Arc

- All of the values you need for Arc setup are displayed via `flt env`
  - PIB_FULL_REPO
  - PIB_BRANCH
  - PIB_PAT

- From the Arc Portal

  - Select `Kubernetes Clusters` in left nav
  - Select the cluster
  - Select `GitOps` in the left nav
  - Click `Install`
  - Repository type is `Private`
  - `Provide Authentication information here`
    - HTTPS User: "gitops"
    - HTTPS Key: value of PIB_PAT from `flt env`
    - HTTPS CA Cert: leave blank
    - Sync interval: 1 minute
    - Sync timeout: 3 minutes

- Create a Kustomization
  - Instance name: flux-system
  - Path: ./clusters/{{cluster-name}}/flux-system/workspaces
  - Sync interval: 1 minute
  - Sync timeout: 3 minutes
  - Retry interval: 1 minute
  - Prune: checked
  - Force: checked
  - Depends on: leave blank

- Select `Configuration objects` from the left nav
  - Wait for `gitops-flux-system` to be created
    - Wait for Compliant

## Check in Arc Portal

- Use the Arc Portal to check GitOps setup
  - Check cluster namespaces and workloads

## Deploying Apps

```bash

# make sure you're in the apps/imdb directory
cd apps/imdb

# check deployment targets
# should be []
flt targets list

# deploy to all clusters
flt targets clear
flt targets add all
flt targets deploy

## wait for ci-cd to run
git pull

# check the clusters in Arc for the imdb workload

```

## Deploying to specific clusters

- flt targets uses key-value pairs from ./cluster/clusterName.yaml
- `ring` is an arbitrary key-value pairs with values [1, 2, 3]
- You can define / edit KVPs in the ./clusters/clusterName.yaml files

```yaml

kind: Cluster
metadata:
  name: west-wa-bell-4010
  labels:
    environment: dev
    region: west
    zone: west-wa
    district: west-wa-bell
    store: west-wa-bell-4010
    domain: west-wa-bell-4010
    ingressType: Http
    gitopsRepo: cse-labs/demo-fleet
    gitopsBranch: main
    ring: 1

```

- Deploy to `ring:0`

> Make sure to start in the apps/imdb directory

```bash

# clear existing targets
flt targets clear
flt targets add ring:0
flt targets deploy

# wait for ci-cd to run
git pull

# check the clusters in Arc for the imdb workload

# add ring:1
flt targets add ring:1
flt targets deploy

# wait for ci-cd to run
git pull

# check the clusters in Arc for the imdb workload

# deploy to ring:1 and ring:2
flt targets clear
flt targets add ring:1 ring:2
flt targets deploy

# wait for ci-cd to run
git pull

# check the clusters in Arc for the imdb workload

```

## Support

This is a private repo for the project team. There is no support outside of that team.

## Contributing

This is a private repo for the project team. We don't accept contributions.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Any use of third-party trademarks or logos are subject to those third-party's policies.
