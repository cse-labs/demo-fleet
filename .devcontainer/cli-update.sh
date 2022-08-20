#!/bin/bash

# update CLI
cd cli || exit

# remove old CLI
rm -rf flt .flt

# use latest release
tag=$(curl -s https://api.github.com/repos/retaildevcrews/pib-dev/releases/latest | grep tag_name | cut -d '"' -f4)

wget -O flt.tar.gz "https://github.com/retaildevcrews/pib-dev/releases/download/$tag/flt-$tag-linux-amd64.tar.gz"
tar -xvzf flt.tar.gz
rm flt.tar.gz

cd "$OLDPWD" || exit
