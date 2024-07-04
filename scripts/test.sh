#!/bin/bash

# ------------- #
# Configuration #
# ------------- #

# Load variables from .env file
set -o allexport
source scripts/.env
set +o allexport

# Helper constants
DEPLOYMENT_TX_DATA_FILE=deployment_tx_data
ACTIVATION_TX_DATA_FILE=activation_tx_data
DEPLOY_CONTRACT_RESULT_FILE=create_contract_result

# -------------- #
# Initial checks #
# -------------- #
if [ -z "$PRIVATE_KEY" ]
then
    echo "You need to provide the PRIVATE_KEY of the deployer"
    exit 0
fi

# ----------------- #
# Deployment of CallBack contract #
# ----------------- #
echo ""
echo "----------------------"
echo "Deploying CallBack contract"
echo "----------------------"

# Deploy contract
cargo stylus deploy -e $RPC_URL --private-key $PRIVATE_KEY > $DEPLOY_CONTRACT_RESULT_FILE

# Get contract address (last "sed" command removes the color codes of the output)
# (Note: last regex obtained from https://stackoverflow.com/a/51141872)
call_back_contract_address_str=$(cat $DEPLOY_CONTRACT_RESULT_FILE | sed -n 2p)
if ! [[ $call_back_contract_address_str == *0x* ]]
then
    # When the program needs activation, the output of the command is slightly different
    call_back_contract_address_str=$(cat $DEPLOY_CONTRACT_RESULT_FILE | sed -n 3p)
fi
art_contract_address_array=($art_contract_address_str)
art_contract_address=$(echo ${art_contract_address_array[2]} | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g')
rm $DEPLOY_CONTRACT_RESULT_FILE



# -------------------- #
# Deployment of Target contract #
# -------------------- #
echo ""
echo "-------------------------"
echo "Deploying Target contract"
echo "-------------------------"

# Move to nft folder
cd target-contract

# Compile and deploy Target contract
forge build
forge create --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/TargetContract.sol:TargetContract > $DEPLOY_CONTRACT_RESULT_FILE

# Get contract address
target_contract_address_str=$(cat $DEPLOY_CONTRACT_RESULT_FILE | sed -n 3p)
target_contract_address_array=($target_contract_address_str)
target_contract_address=${target_contract_address_array[2]}

# Remove all files
rm $DEPLOY_CONTRACT_RESULT_FILE

# Final result
echo "Target contract deployed at address: $target_contract_address"
