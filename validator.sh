#!/bin/bash
set -e

NODE_PATH="../reef-node"
BASE_PATH="../validator2-db"
CHAIN_SPEC="./customSpecRaw.json"
NAME="validator2"

# Replace PEER_ID with the actual ID from bootnode logs
BOOTNODE_MULTIADDR="/ip4/127.0.0.1/tcp/30333/p2p/12D3KooWGJ75fLeXQdgMHJ4mW4yctjPmWTCLtjS1VqgZQAos8LRo"

$NODE_PATH \
  --base-path $BASE_PATH \
  --chain $CHAIN_SPEC \
  --port 30334 \
  --rpc-port 9945 \
  --no-telemetry \
  --validator \
  --rpc-methods Unsafe \
  --name $NAME \
  --rpc-cors all \
  --rpc-external \
  --bootnodes $BOOTNODE_MULTIADDR
