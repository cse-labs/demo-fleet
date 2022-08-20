# Creating a Dev/Test Fleet

![License](https://img.shields.io/badge/license-MIT-green.svg)

> Contact bartr for access

- `Pilot in a Box` allows you to quickly create Kubernetes clusters running `K3s` in `Azure VMs`
- These cluster are intended for learning, dev and test
- For secure or production clusters, we recommend [AKS Secure Baseline](https://github.com/mspnp/aks-baseline)

## Prerequisites

- Required Learning
  - Go through the Kubernetes in Codespaces inner-loop hands-on lab [here](https://github.com/cse-labs/kubernetes-in-codespaces)
  - Repeat until you are comfortable with Codespaces, Kubernetes, Prometheus, Fluent Bit, Grafana, K9s, and our inner-loop process
    - Everything is built on this

## Note

- This repo is setup to use my Azure subscription which is configured for DNS, SSL, and Arc
- If you want to use your own subscription, please start here: <https://github.com/retaildevcrews/gitops-template>

## Create a Codespace

- Create your Codespace from this repo
  - Click on `Code` then click `New Codespace`
Once Codespaces is running:

> Make sure your terminal is running zsh - bash is not supported and will not work
>
> If it's running bash, exit and create a new terminal (this is a random bug in Codespaces)

## Validate your setup

> It is a best practice to close the first shell and start a new one - sometimes the shell starts before setup is complete and isn't fully configured

```bash

# check your PAT - the two values should be the same
echo $PIB_PAT
echo $GITHUB_TOKEN

# check your env vars
flt env

# output
# PIB_GITOPS=true
# PIB_PAT=yourPAT
# PIB_REPO=yourTeanant/yourFleet

```

## Set Flux repo and branch

- Checkout a branch
  - yourAlias-fleet
  - Push the branch with the `-u` option to set your upstream
- Edit `apps/flux-system/app.yaml`
  - Set `repo` and `branch`
  - Git commit and push

## Login to Azure

- Run `flt az login`
  - This logs you in with an Azure Service Principal that has the correct permissions

## Create a single cluster fleet

- `flt create -c region-state-city-number --verbose`
  - specify `--verbose` to see verbose errors
- Use central, east, or west for the region
- Use 2 letter state
- example: west-nv-vegas-777

## Update your GitOps repo

```bash

# you should see new files from ci-cd
# if you don't, check the Actions tab
git pull

# add and commit the ips file
git add .
git commit -am "added ips file"
git push

```

## Check setup status

> flt is the fleet CLI provided by Pilot-in-a-Box
>
> The `flt check` commands will fail until SSHD is running, so you may get errors for 30 seconds or so

- Run until you get a status of "complete"
  - Usually 4-5 min

```bash

# check setup status
flt check setup

```

## Check your Fleet

```bash

# list clusters in the fleet
flt list

# check heartbeat on the fleet
# you should get 17 bytes from each cluster
# if not, please reach out to the Platform Team for support
flt check heartbeat

```

## Deploy the IMDb Reference App

- IMDb is the reference application
- Normally, the apps would be in separate repos
  - We include several sample apps in this repo for convenience
  - Heartbeat is one of the `bootstrap services` and should be in this repo

Follow the instructions [here](./sample-apps/README.md) to deploy the IMDb app to your fleet.

## Check that your GitHub Action is running

- <https://github.com/retaildevcrews/pib-gitops/actions>
  - your action should be queued or in-progress

## Check deployment

- Once the action completes successfully

```bash

# you should see imdb added to your cluster
git pull

# force flux to sync
# flux will sync on a schedule - this command forces it to sync now for debugging
flt sync

# check that imdb is deployed to your cluster
flt check app imdb

# curl the IMDb endpoints
flt curl /version
flt curl /healthz
flt curl /readyz

```

## Delete your test cluster

```bash

# change to the repo base dir
cd $PIB_BASE

git pull

flt delete yourCluster
rm ips

# commit and push to GitHub
git add .
git commit -am "delete cluster"
git push

```

## Create a multi-cluster Fleet

- We generally group our fleets together in one resource group
- An example of creating a 3 cluster fleet
  - this will create the following meta data which can be used as targets
    - region:central
    - zone:central-tx
    - district:central-tx-atx
    - store:central-tx-atx-801

  ```bash

  flt create -g my-fleet \
    -c central-tx-atx-801 \
    -c east-ga-atl-801 \
    -c west-wa-sea-801

  ```

## Setup your GitHub PAT

> GitOps needs a PAT that can push to this repo
>
> You can use your Codespaces token but it will be deleted when your Codespace is deleted and GitOps will quit working

### For production, you want to use a service account instead of your individual account

- Create a Personal Access Token (PAT) in your GitHub account
  - Grant repo and package access
  - You can use an existing PAT as long as it has permissions
  - <https://github.com/settings/tokens>

- Create a personal Codespace secret
  - <https://github.com/settings/codespaces>
  - todo - should we make this PIB_PAT and update Codespaces?
  - Name: PAT
  - Value: your PAT
  - Grant access to this repo and any other repos you want

## Setup your Azure Subscription

> todo - this is written for internal audiences - should we write for external [and internal]

- If you plan to use Azure Arc
  - Request a `sponsored subscription` from AIRS
- Additional setup is required
  - Contact the Platform Team for more details
    - domain name
    - DNS
    - Managed Identity
    - Key Vault

    > NOTE: Update `.devcontainer` for your fleet repository to add these env variables for an on-going updates to fleet

## Setup Notes

- todo - working notes - update
- I was not able to create an SP in my AIRS sub :(

  ```bash

  az login --use-device-code

  # unset env vars
  unset PIB_DNS_RG
  unset PIB_MI
  unset PIB_SSL

  # check env vars
  flt env

  # create a cluster
  flt create -c central-tx-dfw-9001

  ```

  - setup https
  - we use Let's Encrypt for SSL certs

  - purchase or use an existing domain name
  - create a DNS zone
    - we use "tld" as the resource group
  - create a Managed Identity in the same RG
    - we use pib-mi
    - grant MI full access to DNS Zone

      ```bash

      # set env vars
      export PIB_DNS_RG=tld
      export PIB_MI=/subscriptions/{{your subscription ID}}/resourcegroups/tld/providers/Microsoft.ManagedIdentity/userAssignedIdentities/pib-mi
      PIB_SSL=your-domain.com

      # create a cluster
      flt create -c central-tx-dfw-9002

      ```

## Add a lock to your DNS Zone

- todo - rough notes - update
- you can't lock the DNS zone as the locks are inherited and you won't be able to delete cluster DNS entries
- this powershell script locks the @ records

  ```powershell

  $lvl = "CanNotDelete"
  $lnm = "delete"
  $rsc = "soldevex.com/@"
  $rty = "Microsoft.Network/DNSZones/SOA"
  $rsg = "tld"

  New-AzResourceLock -LockLevel $lvl -LockName $lnm -ResourceName $rsc -ResourceType $rty -ResourceGroupName $rsg

  ```

## GitOps (Flux v2)

- todo - add section on GitOps

## Arc

- todo - add section on Arc
  - GitOps
  - Key Vault
  - Open Service Mesh
  - flt az arc-token

## Contour (ingress)

- todo - add section on Contour

## Let's Encrypt (SSL cert)

- todo - add section on Let's Encrypt

## Support

This project uses GitHub Issues to track bugs and feature requests. Please search the existing issues before filing new issues to avoid duplicates.  For new issues, file your bug or feature request as a new issue.

## Contributing

This project welcomes contributions and suggestions and has adopted the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct.html).

For more information see [Contributing.md](./.github/CONTRIBUTING.md)

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Any use of third-party trademarks or logos are subject to those third-party's policies.
