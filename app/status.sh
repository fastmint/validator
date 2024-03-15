#!/bin/bash

RED='\033[0;31m'
NC='\033[0m' # No Color
GREEN='\033[0;32m'
YELLOW="\033[0;33m"   
NODE=http://37.27.25.89:26657
DENOM="ufmc"


{
  LAST_HEIGHT=$(docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    status --node $NODE | grep -o '"latest_block_height":"[^"]*' | grep -o '[^"]*$')

  CURRENT_HEIGHT=$(docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    status | grep -o '"latest_block_height":"[^"]*' | grep -o '[^"]*$')

  OPERATOR_ADDRESS=$(docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    keys show key --bech val -a --keyring-backend test)

  ACCOUNT_ADDRESS=$(docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    keys show key --bech acc -a --keyring-backend test )


  BALANCE=$(docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    query bank balances $ACCOUNT_ADDRESS --denom ufmc --node $NODE |  grep amount | awk '{ print $2; }'| tr -d '"')

  MIN_DEPOSIT=$(docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    query fmcprofile params --node $NODE |  grep min_deposit | awk '{ print $2; }'| tr -d '"')

  ROLE=$(docker run --rm -i --name fmc_cli --network host \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    query fmcprofile show-profile $ACCOUNT_ADDRESS --node $NODE | grep role | awk '{ print $2; }')

  VALIDATOR_JAILED_RES=$(docker run --rm -i --name fmc_cli \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    query staking validator $OPERATOR_ADDRESS  --node $NODE | grep jailed)



  VALIDATOR_STATUS_RES=$(docker run --rm -i --name fmc_cli \
    -v $(pwd)/.fmc:/root/.fmcapp \
    fastmint/fmcd_i \
    query staking validator $OPERATOR_ADDRESS  --node $NODE | grep status)
} &> /dev/null

clear
echo -e ${RED}FASTMINT VALIDATOR CONSOLE APP${NC}
echo -e "${GREEN}ACCOUNT: $ACCOUNT_ADDRESS${NC}"
let precent=$CURRENT_HEIGHT*100/$LAST_HEIGHT
if [ "$precent" == "100" ]; then
echo -e ${GREEN}NODE STATUS: READY${NC}
else
echo -e ${YELLOW}NODE STATUS: LOADING... $precent%${NC}
fi

if [[ $VALIDATOR_JAILED_RES == "jailed: true" ]] 
then 
  echo -e "${RED}VALIDATOR STATUS: JAILED${NC}"

elif [[ $VALIDATOR_STATUS_RES == "status: BOND_STATUS_BONDED" ]] 
then 
  echo -e "${GREEN}VALIDATOR STATUS: BONDED${NC}"

elif [[ $VALIDATOR_STATUS_RES == "status: BOND_STATUS_UNBONDING" ]] 
then 
  echo -e "${YELLOW}VALIDATOR STATUS: UNBONDING${NC}"
elif [[ $VALIDATOR_STATUS_RES == "status: BOND_STATUS_UNBONDED" ]] 
then 
  echo -e "${YELLOW}VALIDATOR STATUS: UNBONDED${NC}"

elif [[ $VALIDATOR_STATUS_RES == "" ]] 
then 
  echo -e "${YELLOW}VALIDATOR STATUS: NO${NC}"

  if [[ $ROLE == "partner" ]] 
  then 
    MIN_DEPOSIT="0000001"
  fi
  echo -e "${GREEN}BALANCE: ${BALANCE%??????}.${BALANCE: -6} FMC${NC}"
  echo -e "${GREEN}MIN DEPOSIT: ${MIN_DEPOSIT%??????}.${MIN_DEPOSIT: -6} FMC + 10FMC (tx fee)${NC}"

  MIN_DEPOSIT_INTEGER=$(( $MIN_DEPOSIT + 0 ))
  BALANCE_INTEGER=$(( $BALANCE - 1999999))
  if [[ $MIN_DEPOSIT_INTEGER > $BALANCE_INTEGER ]] 
  then 
    echo "There are not enough funds to become a validator, top up your wallet with the required amount"
  elif [ "$precent" != "100" ];then
    echo "wait until the node finishes synchronizing"
  
  elif [[ $MIN_DEPOSIT_INTEGER < $BALANCE_INTEGER ]] 
  then 
  echo "Do you want to become a validator?"
  select yn in "Yes" "No"; do
      case $yn in
          Yes ) 
          ./create-validator.sh $MIN_DEPOSIT_INTEGER$DENOM
          break;;
          No ) exit;;
      esac
  done

  fi
fi






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












# {
#   VALIDATOR_STATUS_RES=$(docker run --rm -i --name fmc_cli \
#     -v $(pwd)/.fmc:/root/.fmcapp \
#     fastmint/fmcd_i \
#     query staking validator $OPERATOR_ADDRESS  --node $NODE | grep status)
# } &> /dev/null

# {
#   VALIDATOR_JAILED_RES=$(docker run --rm -i --name fmc_cli \
#     -v $(pwd)/.fmc:/root/.fmcapp \
#     fastmint/fmcd_i \
#     query staking validator $OPERATOR_ADDRESS  --node $NODE | grep jailed)
# } &> /dev/null

# if [[ $VALIDATOR_JAILED_RES == "jailed: true" ]] 
# then 
# echo -e "VALIDATOR: ${RED}JAILED${NC}"

# elif [[ $VALIDATOR_STATUS_RES == "status: BOND_STATUS_BONDED" ]] 
# then 
# echo -e "VALIDATOR: ${GREEN}YES${NC}"

# elif [[ $VALIDATOR_STATUS_RES == "" ]] 
# then 
# echo -e "VALIDATOR: ${RED}NO${NC}"
# fi


# echo -e ${RED}VALIDATOR:${NC}
# if [[ $VALIDATOR_STATUS == "status: BOND_STATUS_BONDED" ]] 
# then 
# echo "VALIDATOR: OK"
# fi 
# echo "VALIDATOR OFF"





# echo -e ${RED}SHOW STATS${NC}


#     ADDRESS=$(docker run --rm -i \
#     -v $(pwd)/.fmc:/root/.fmcapp \
#     fastmint/fmcd_i \
#     keys \
#     show key --address --keyring-backend test)
    


#     echo -e ${RED}Your address is: $ADDRESS${NC}
#     # if [[ ${#ADDRESS} -le 9 ]] 
#     # then
#     #     echo -e ${RED}incorrect mnemonic:${NC}
#     # fi
# # done

# echo "Done!"

# echo ИМПОРТ КЛЮЧА
# while true
# do
# echo passwords doesnt match
# read -p "Enter your pass: " first
# read -p "Confirm your pass: " second
#     if [[ "$first" == "$second" ]] 
#     then 
#         break
# done
#   docker run --rm -it --name fmc_cli \
#     -v $(pwd)/.fmc:/root/.fmcapp \
#     fastmint/fmcd_i \
#     keys add key --recover


#     ADDRESS=$(echo 1234567890 | docker run --rm -i \
#     -v $(pwd)/prod-sim/desk-alice:/root/.fmc \
#     fmcd_i \
#     keys \
#     --keyring-backend file --keyring-dir /root/.fmc/keys \
#     show alice --address)
#     if [[ "$first" -eq "$second" ]]  
#     then break
# done



# mnemonic=TEST

# while [ $mnemonic -le 2 ]
# do
# read -p "Enter your mnemonic: " fullname
# done






# while [1=1]
# do
#   docker run --rm -it --name fmc_cli \
#     -v $(pwd)/.fmc:/root/.fmcapp \
#     fastmint/fmcd_i \
#     keys add key --recover
# done





# apt update
# apt install golang-go
# go version





# #Настраиваем ufw
# echo "y" | apt update
# echo "y" | apt upgrade