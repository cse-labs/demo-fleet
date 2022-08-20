# Vision on Edge (VoE) Demo App

## Fleet Configuration Prerequisites

The following documents the required Azure resources and other configuration required to successfully deploy the VoE application to a fleet.

### Create Azure Resources

#### Define resource name variables

```bash

export VOE_HUB_NAME=my-voe-hub

export VOE_RG=my-voe-rg

export VOE_AZ_COG_SVC_NAME=my-voe-acs

```

#### Login to Azure CLI

```bash

az login --use-device-code

```

#### Create Azure IoT Hub

```bash

# add azure-iot extension
az extension add -n azure-iot

az iot hub create --resource-group $VOE_RG --name $VOE_HUB_NAME

```

#### Create Azure Cognitive Services

```bash

# you may have to create a cognitive services multi-service account in the azure portal to fulfill the requirement to agree to the responsible AI terms for the resource
az cognitiveservices account create --kind CognitiveServices --name $VOE_AZ_COG_SVC_NAME --resource-group $VOE_RG --sku S0 --location yourlocation

```

### Update fleet creation script

Add the following lines to vm/setup/pre-flux.sh and replace the values in [] with the names of the resources created. Save and push your changes to main.

```bash

# add the iot extension
az extension add -n azure-iot

# azure iot secrets
echo "IOTHUB_CONNECTION_STRING=$(az iot hub connection-string show --hub-name [your-voe-hub-name] -o tsv)" > "$HOME/.ssh/iot.env"
echo "IOTEDGE_DEVICE_CONNECTION_STRING=$(az iot hub device-identity connection-string show --hub-name [your-voe-hub-name] --device-id "$(hostname)" -o tsv)" >> "$HOME/.ssh/iot.env"

# azure cognitive services secrets
echo "ENDPOINT=$(az cognitiveservices account show -n [your-voe-acs-name] -g [your-voe-rg] --query properties.endpoint -o tsv)" > "$HOME/.ssh/acs.env"
echo "TRAINING_KEY=$(az cognitiveservices account keys list -n [your-voe-acs-name] -g [your-voe-rg] --query key1 -o tsv)" >> "$HOME/.ssh/acs.env"

kubectl create ns voe

kubectl create secret generic azure-env --from-env-file "$HOME/.ssh/iot.env" --from-env-file="$HOME/.ssh/acs.env" -n voe

```

### Cluster VM Requirements

The VoE application requires at least 8 cores, this must be specified at fleet creation with the --cores flag. Below is an example of creating a single vm fleet with 8 cores.

The PIB_MI environment variable must be set so the fleet has access to the Azure CLI.

```bash

flt create -c your-cluster-name --cores 8 --verbose

```

### Add iot devices (clusters in fleet) to IoT Hub

You must run this command for each fleet in the cluster

```bash

az iot hub device-identity create --ee -n $VOE_HUB_NAME -d your-cluster-name

```

## Deploy the VoE app to a fleet

Follow the steps in the main [sample-apps readme](../README.md).
