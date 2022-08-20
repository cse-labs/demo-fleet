#!/bin/bash

# this runs as part of pre-build

echo "on-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create start" >> "$HOME/status"

# update these values for DNS / SSL support
#   uncomment additional lines below

# set env vars
#export PIB_MI=yourAzureManagedIdentity
#export PIB_DNS_RG=yourDNSResourceGroup
#export PIB_SSL=yourDomain

export GOPATH="$HOME/go"
export PATH="$PATH:$PWD/cli"

mkdir -p "$HOME/.ssh"
mkdir -p "$HOME/go"
mkdir -p "$HOME/.oh-my-zsh/completions"

{
    echo "defaultIPs: $PWD/ips"
    echo "reservedClusterPrefixes:"
    echo "  - corp-monitoring"
    echo "  - central-mo-kc"
    echo "  - central-tx-austin"
    echo "  - east-ga-atlanta"
    echo "  - east-nc-raleigh"
    echo "  - west-ca-sd"
    echo "  - west-wa-redmond"
    echo "  - west-wa-seattle"
} > "$HOME/.flt"

# set env based on repo
{
    echo ""
    echo "# uncomment these lines for DSN / SSL support"
    echo "#export PIB_MI=$PIB_MI"
    echo "#export PIB_DNS_RG=$PIB_DNS_RG"
    echo "#export PIB_SSL=$PIB_SSL"
    echo ""

    # add cli to path
    echo "export PATH=\$PATH:$PWD/cli"
    echo ""

    echo "export GOPATH=\$HOME/go"
    echo ""

    echo "if [ \"\$PAT\" != \"\" ]"
    echo "then"
    echo "    export GITHUB_TOKEN=\$PAT"
    echo "fi"
    echo ""

    echo "export PIB_PAT=\$GITHUB_TOKEN"
    echo ""

    echo "compinit"

} >> "$HOME/.zshrc"

# echo "dowloading kic CLI"
cd cli || exit

# use latest release
tag=$(curl -s https://api.github.com/repos/retaildevcrews/pib-dev/releases/latest | grep tag_name | cut -d '"' -f4)

wget -O flt.tar.gz "https://github.com/retaildevcrews/pib-dev/releases/download/$tag/flt-$tag-linux-amd64.tar.gz"
tar -xvzf flt.tar.gz
rm flt.tar.gz

cd "$OLDPWD" || exit

# echo "generating completions"
flt completion zsh > "$HOME/.oh-my-zsh/completions/_flt"
kubectl completion zsh > "$HOME/.oh-my-zsh/completions/_kubectl"

# only run apt upgrade on pre-build
if [ "$CODESPACE_NAME" = "null" ]
then
    echo "$(date +'%Y-%m-%d %H:%M:%S')    upgrading" >> "$HOME/status"
    sudo apt-get update
    sudo apt-get upgrade -y
fi

echo "on-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    on-create complete" >> "$HOME/status"
