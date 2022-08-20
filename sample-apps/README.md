# Deploy a Sample App to a Fleet

This directory has a collection of sample applications that can be deployed to a fleet:

- `dogs-cats`: A simple web server written in Go that uses Redis
- `httpbin`: A simple HTTP request & response service
- `imdb`: A k8s reference app written in C#
- `voe`: A custom Vision on Edge application based off of <https://github.com/Azure-Samples/azure-intelligent-edge-patterns/tree/master/factory-ai-vision>

## Choose the sample app to deploy

> The VoE application has additional required setup that is detailed in the [VoE readme](./voe/README.md).

```bash

# you can choose any of the other available sample apps
export PIB_APP=imdb

```

## Copy app yaml files to apps directory

```bash

# cd to the sample-apps directory
cd sample-apps

# copy the app's yaml files to apps directory
cp -aR ./$PIB_APP ../apps

# commit and push to GitHub
git add ../
git commit -am "Adding $PIB_APP app"
git push

```

## Create a workspace for the sample app

```bash

# cd to the workspaces directory
cd ../workspaces

# create a workspace
cat <<EOF > "./$PIB_APP.yaml"
kind: Workspace
metadata:
  name: $PIB_APP
spec: {}
EOF

# commit and push to GitHub
git add .
git commit -am "Add $PIB_APP workspace"
git push

```

## Deploy the app

```bash

cd ../apps/$PIB_APP

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

# you should see the sample app added to your cluster
git pull

# force flux to sync
flt sync

# check that the is deployed to your cluster
flt check app $PIB_APP

# curl the app's endpoints
# depending on the sample app you will need to update the endpoints
flt curl /healthz
flt curl /readyz

```
