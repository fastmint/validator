#!/bin/bash
NODE=http://37.27.25.89:26657


PUBKEY=$(docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    tendermint show-validator)
echo $PUBKEY

docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    tx staking create-validator   --amount=$1 --pubkey=$PUBKEY --moniker="validator"  --chain-id=fmc-1 --commission-rate="0.10" --commission-max-rate="0.20" --commission-max-change-rate="0.01" --gas="200000" --gas-prices="10ufmc" --min-self-delegation 1 --from=key --keyring-backend test -y
