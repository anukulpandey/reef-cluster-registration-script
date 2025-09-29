#!/bin/bash
set -e

SECRET="blind art bundle write fashion equal vapor zero oppose system sunny success"
NODE_PATH="/Users/anukul/Desktop/chain-upgrade/target/release/reef-node"
RPC_URL="http://localhost:9944"

echo ">>>>>>>>> Inspecting Accounts"
for i in 1 2; do 
  for j in stash controller; do 
    $NODE_PATH key inspect "$SECRET//$i//$j"; 
  done; 
done

echo ">>>>>>>>> Inspecting BABE Keys"
for i in 1 2; do 
  $NODE_PATH key inspect --scheme sr25519 "$SECRET//$i//babe"
done

echo ">>>>>>>>> Inspecting GRANDPA Keys"
for i in 1 2; do 
  $NODE_PATH key inspect --scheme ed25519 "$SECRET//$i//grandpa"
done

echo ">>>>>>>>> Inspecting IM_ONLINE Keys"
for i in 1 2; do 
  $NODE_PATH key inspect --scheme sr25519 "$SECRET//$i//im_online"
done

echo ">>>>>>>>> Inspecting AUTHORITY_DISCOVERY Keys"
for i in 1 2; do 
  $NODE_PATH key inspect --scheme sr25519 "$SECRET//$i//authority_discovery"
done

echo ">>>>>>>>> Inserting Keys into Reef Node"

# BABE
for i in 1 2; do 
  PUB=$($NODE_PATH key inspect --scheme sr25519 "$SECRET//$i//babe" | sed -n -e 5p | cut -d ":" -f 2 | xargs)
  curl -s $RPC_URL -H "Content-Type:application/json" \
    -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"babe\", \"$SECRET//$i//babe\", \"$PUB\" ] }"
done

# GRANDPA
for i in 1 2; do 
  PUB=$($NODE_PATH key inspect --scheme ed25519 "$SECRET//$i//grandpa" | sed -n -e 5p | cut -d ":" -f 2 | xargs)
  curl -s $RPC_URL -H "Content-Type:application/json" \
    -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"gran\", \"$SECRET//$i//grandpa\", \"$PUB\" ] }"
done

# IM_ONLINE
for i in 1 2; do 
  PUB=$($NODE_PATH key inspect --scheme sr25519 "$SECRET//$i//im_online" | sed -n -e 5p | cut -d ":" -f 2 | xargs)
  curl -s $RPC_URL -H "Content-Type:application/json" \
    -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"imon\", \"$SECRET//$i//im_online\", \"$PUB\" ] }"
done

# AUTHORITY_DISCOVERY
for i in 1 2; do 
  PUB=$($NODE_PATH key inspect --scheme sr25519 "$SECRET//$i//authority_discovery" | sed -n -e 5p | cut -d ":" -f 2 | xargs)
  curl -s $RPC_URL -H "Content-Type:application/json" \
    -d "{ \"jsonrpc\":\"2.0\", \"id\":1, \"method\":\"author_insertKey\", \"params\": [ \"audi\", \"$SECRET//$i//authority_discovery\", \"$PUB\" ] }"
done

echo ""
echo ">>>>>>>>> All Keys Inserted Successfully!"
