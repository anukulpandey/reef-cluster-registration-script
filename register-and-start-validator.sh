#!/bin/bash
set -e

# Arguments
MNEMONIC="$1"
RPC_URL="$2"
NODE_PATH="$3"
VAL_PORT="$4"
VAL_RPC_PORT="$5"
BOOTNODE_MULTIADDR="$6"
NODE_NAME="$7"

BASE_PATH="./validator-db"

# Start validator node in background
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
  --bootnodes $BOOTNODE_MULTIADDR &

# Wait for RPC to be available
echo "Waiting for node RPC..."
until curl -s $RPC_URL > /dev/null; do
    sleep 1
done
echo "Node RPC is up!"

# Now inspect keys
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

echo ">>>>>>>>> Inserting Keys into Reef Node"
for key in babe gran imon audi; do
    case $key in
        babe) PUB=$($NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//babe" | sed -n -e 5p | cut -d ":" -f2 | xargs) ;;
        gran) PUB=$($NODE_PATH key inspect --scheme ed25519 "$MNEMONIC//grandpa" | sed -n -e 5p | cut -d ":" -f2 | xargs) ;;
        imon) PUB=$($NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//im_online" | sed -n -e 5p | cut -d ":" -f2 | xargs) ;;
        audi) PUB=$($NODE_PATH key inspect --scheme sr25519 "$MNEMONIC//authority_discovery" | sed -n -e 5p | cut -d ":" -f2 | xargs) ;;
    esac
    curl -s $RPC_URL -H "Content-Type:application/json" \
        -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"$key\", \"$MNEMONIC//$key\", \"$PUB\" ] }"
done

echo ""
echo ">>>>>>>>> All Keys Inserted Successfully!"
echo "Validator is running..."
wait
