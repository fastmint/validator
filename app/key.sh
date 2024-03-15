#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
NODE=http://37.27.25.89:26657


echo -e ${RED}IMPORT NEW KEY${NC}

{
    docker run --rm -i --name fmc_cli \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    keys delete key --keyring-backend test -y
} &> /dev/null

# IMPORT KEY
# mnemonic="pulse quit normal snap wrestle rebuild category blanket breeze decrease reflect marriage clay merit tomorrow blade barrel use dentist track glance include unknown upper"
mnemonic="else taste dirt hood little state prefer rule front call goddess remain south evil leader federal buzz punch skill lemon tree half farm arena"

   test=$(echo $mnemonic | docker run --rm -i --name fmc_cli \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    keys add key --recover  --keyring-backend test)




# while true 
# do
# read -p "Enter your pass (min 10 characters): " first
#     if [[ ${#first} -le 9 ]] 
#     then
#         echo -e ${RED}password is too short, try again:${NC}
#         continue
#     fi
# read -p "Confirm your pass: " second
#     if [[ "$first" == "$second" ]] 
#         then
#                 break
#     fi
#         echo -e ${RED}passwords doesn\'t match, try again:${NC}
# done




# json='{"access_token":"kjdshfsd", "key2":"value"}' 
    
# echo $json | grep -o '"access_token":"[^"]*' | grep -o '[^"]*$'