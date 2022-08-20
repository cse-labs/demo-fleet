# Deploy Virtual TLog App to a Fleet

## Copy yaml files to apps directory

```bash

# cd to the sample-apps directory
cd $PIB_BASE/sample-apps

# copy vtlog yaml files to apps directory
cp -aR ./vtlog ../apps

# commit and push to GitHub
git add .
git commit -am "Add vtlog app"
git push

```

## Create a vtlog workspace

```bash

# cd to the workspaces directory
cd $PIB_BASE/workspaces

# create a vtlog workspace
printf "kind: Workspace
metadata:
  name: vtlog
spec: {}
" > vtlog.yaml

# commit and push to GitHub
git add .
git commit -am "Add vtlog workspace"
git push

```

## Deploy the app

```bash

cd $PIB_BASE/apps/vtlog

# check deploy targets (should be [])
flt targets list

# clear the targets if not []
flt targets clear

# add all clusters as a target
flt targets add all

# deploy the changes
flt targets deploy

```

## Check deployment

- Once the GitHub action completes successfully

```bash

# you should see vtlog added to your cluster
git pull

# force flux to sync
flt sync

# check that vtlog is deployed to your cluster
flt check app vtlog

# curl the vtlog endpoints
flt curl /tlog/version
flt curl /tlog/healthz
flt curl /tlog/readyz

```
