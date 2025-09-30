#!/bin/bash
set -e

NODE_PATH="../reef-node"
BASE_PATH="../bootnode-db"
CHAIN_SPEC="./customSpecRaw.json"
NAME="bootnode"

$NODE_PATH \
  --base-path $BASE_PATH \
  --chain $CHAIN_SPEC \
  --port 30333 \
  --rpc-port 9944 \
  --no-telemetry \
  --validator \
  --rpc-methods Unsafe \
  --name $NAME \
  --rpc-cors all \
  --rpc-external
