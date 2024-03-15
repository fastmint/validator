#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
NODE=http://37.27.25.89:26657



#INIT
rm -rf $(pwd)/.fmc


  docker run --rm -i --name fmc_cli \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    init fmc


#CONF
cp genesis.json .fmc/config/genesis.json
cp config.toml .fmc/config/config.toml
cp app.toml .fmc/config/app.toml
docker run --rm -i \
    -v $(pwd)/.fmc:/root/.fmcapp \
    --entrypoint sed \
    fastmint/fmcd_i \
    -Ei '0,/^laddr = .*$/{s/^laddr = .*$/laddr = "tcp:\/\/0.0.0.0:26657"/}' \
    /root/.fmcapp/config/config.toml


docker run --rm -i -d --name fmc_node --network host  \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    start