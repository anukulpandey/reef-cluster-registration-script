#!/bin/bash
set -e

if [ "$#" -ne 8 ]; then
    echo "Usage: $0 <MNEMONIC> <RPC_URL> <NODE_PATH> <VALIDATOR_PORT> <RPC_PORT> <BOOTNODE_MULTIADDR> <NODE_NAME> <REGISTER_URL>"
    exit 1
fi

MNEMONIC="$1"
RPC_URL="$2"
NODE_PATH="$3"
VAL_PORT="$4"
VAL_RPC_PORT="$5"
BOOTNODE_MULTIADDR="$6"
NODE_NAME="$7"
REGISTER_URL="$8"

BASE_PATH="./validator-db"

# Inspect keys locally
echo ">>>>>>>>> Inspecting Accounts"
for j in stash controller; do
    $NODE_PATH key inspect "$MNEMONIC//$j"
done

echo ">>>>>>>>> Inspecting BABE Key"
$NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//babe"

echo ">>>>>>>>> Inspecting GRANDPA Key"
$NODE_PATH key inspect --scheme ed25519 "$MNEMONIC//grandpa"

echo ">>>>>>>>> Inspecting IM_ONLINE Key"
$NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//im_online"

echo ">>>>>>>>> Inspecting AUTHORITY_DISCOVERY Key"
$NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//authority_discovery"

# # Insert keys into specified RPC
# echo ">>>>>>>>> Inserting Keys into $REGISTER_URL"
# PUB=$($NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//babe" | sed -n -e 5p | cut -d ":" -f2 | xargs)
# curl -s $REGISTER_URL -H "Content-Type:application/json" \
#     -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"babe\", \"$MNEMONIC//babe\", \"$PUB\" ] }"

# PUB=$($NODE_PATH key inspect --scheme ed25519 "$MNEMONIC//grandpa" | sed -n -e 5p | cut -d ":" -f2 | xargs)
# curl -s $REGISTER_URL -H "Content-Type:application/json" \
#     -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"gran\", \"$MNEMONIC//grandpa\", \"$PUB\" ] }"

# PUB=$($NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//im_online" | sed -n -e 5p | cut -d ":" -f2 | xargs)
# curl -s $REGISTER_URL -H "Content-Type:application/json" \
#     -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"imon\", \"$MNEMONIC//im_online\", \"$PUB\" ] }"

# PUB=$($NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//authority_discovery" | sed -n -e 5p | cut -d ":" -f2 | xargs)
# curl -s $REGISTER_URL -H "Content-Type:application/json" \
#     -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"audi\", \"$MNEMONIC//authority_discovery\", \"$PUB\" ] }"

# echo ""
# echo ">>>>>>>>> All Keys Inserted Successfully into $REGISTER_URL!"

$NODE_PATH build-spec --disable-default-bootnode --chain /reef-data/customSpec.json --raw > /reef-data/customSpecRaw.json

# Start the validator
echo ">>>>>>>>> Starting Validator Node"
$NODE_PATH \
  --base-path $BASE_PATH \
  --chain ./customSpecRaw.json \
  --port $VAL_PORT \
  --rpc-port $VAL_RPC_PORT \
  --no-telemetry \
  --validator \
  --rpc-methods Unsafe \
  --name $NODE_NAME \
  --rpc-cors all \
  --rpc-external \
  --bootnodes $BOOTNODE_MULTIADDR
