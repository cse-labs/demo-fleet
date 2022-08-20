#!/bin/bash

# don't use SSL
unset PIB_SSL

# remove any existing clusters
rm -rf clusters
mkdir -p clusters
touch clusters/.gitkeep

# create the clusters
flt create --gitops-only \
    -c west-wa-phi-0010 \
    -c west-wa-red-1010 \
    -c west-wa-sea-2010 \
    -c west-wa-mer-3010 \
    -c west-wa-bell-4010 \
    -c west-wa-tac-5010 \
    -c west-wa-ren-6010
