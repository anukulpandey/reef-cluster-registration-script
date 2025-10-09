#!/bin/bash
set -e

# Expect exactly 3 arguments
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <MNEMONIC> <RPC_URL> <NODE_PATH>"
    exit 1
fi

MNEMONIC="$1"
RPC_URL="$2"
NODE_PATH="$3"

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

# Insert keys into specified RPC
echo ">>>>>>>>> Inserting Keys into $RPC_URL"

insert_key() {
    local key_type=$1
    local scheme=$2
    local key_name=$3
    local pub=$($NODE_PATH key inspect --scheme $scheme "$MNEMONIC//$key_name" | sed -n -e 5p | cut -d ":" -f2 | xargs)
    curl -s $RPC_URL -H "Content-Type:application/json" \
        -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"$key_type\", \"$MNEMONIC//$key_name\", \"$pub\" ] }"
}

insert_key "babe" sr25519 "babe"
insert_key "gran" ed25519 "grandpa"
insert_key "imon" sr25519 "im_online"
insert_key "audi" sr25519 "authority_discovery"

echo ""
echo ">>>>>>>>> All Keys Inserted Successfully into $RPC_URL!"
