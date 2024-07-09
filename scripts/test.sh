#!/bin/bash

# Load variables from .env file
set -o allexport
source .env
set +o allexport

# Constants
DEPLOYMENT_TX_DATA_FILE=deployment_tx_data
ACTIVATION_TX_DATA_FILE=activation_tx_data
DEPLOY_CONTRACT_RESULT_FILE=create_contract_result

# Function to handle deployment errors
handle_error() {
    echo "Error: $1"
    exit 1
}

# Check if PRIVATE_KEY is provided
if [ -z "$PRIVATE_KEY" ]; then
    handle_error "You need to provide the PRIVATE_KEY of the deployer"
fi

# Deploy CallBack contract
echo ""
echo "----------------------"
echo "Deploying CallBack contract"
echo "----------------------"

cd ../
output=$(cargo stylus deploy -e $RPC_URL --private-key $PRIVATE_KEY)
clean_output=$(echo "$output" | sed "s/\x1B\[[0-9;]*[mGKF]//g")
contract_address=$(echo "$clean_output" | grep "deployed code at address:" | awk '{print $5}')
echo "CallBack contract deployed at address: $contract_address"

# Deploy Target contract
echo ""
echo "-------------------------"
echo "Deploying Target contract"
echo "-------------------------"

cd target-contract
forge build || handle_error "Failed to build Target contract"
forge create --rpc-url $RPC_URL --private-key $PRIVATE_KEY src/TargetContract.sol:TargetContract --constructor-args "$contract_address" > $DEPLOY_CONTRACT_RESULT_FILE || handle_error "Failed to deploy Target contract"

target_contract_address=$(awk 'NR==3 {print $3}' $DEPLOY_CONTRACT_RESULT_FILE)
echo "Target contract deployed at address: $target_contract_address"

# Clean up temporary files
rm $DEPLOY_CONTRACT_RESULT_FILE

# Interaction with Target contract
echo ""
echo "-------------------------"
echo "Interacting with Target contract"
echo "-------------------------"

# Call cast to execute the function
cast send $contract_address "execute(address)" "$target_contract_address" --rpc-url $RPC_URL --private-key $PRIVATE_KEY 