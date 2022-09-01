#!/bin/bash

tag=$1

# todo - remove this once releaed
tag="0.9.1"

mkdir -p "$HOME/bin"

# update CLI
cd "$HOME/bin" || exit

# remove old CLI
rm -rf flt .flt

# use latest release
if [ "$tag" = "" ]; then
    tag=$(curl -s https://api.github.com/repos/retaildevcrews/pib-dev/releases/latest | grep tag_name | cut -d '"' -f4)
fi

wget -O flt.tar.gz "https://github.com/retaildevcrews/pib-dev/releases/download/$tag/flt-edge-$tag-linux-amd64.tar.gz"
tar -xvzf flt.tar.gz
rm flt.tar.gz

cd "$OLDPWD" || exit
