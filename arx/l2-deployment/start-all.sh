#!/bin/bash

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"

mkdir -p "$DEPLOYMENT_DIR/logs"

# Start op-node
nohup bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/run-op-node.sh \
  > /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-node.log 2>&1 &

sleep 3

# Start op-batcher
nohup /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-batcher/bin/op-batcher \
  --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7301 \
  > /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-batcher.log 2>&1 &

sleep 3

# Start op-proposer  
nohup /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-proposer/bin/op-proposer \
  --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
  --rollup-rpc=http://localhost:9545 \
  --game-factory-address=0x47EdA6d3E07ce233AB48e83Fb26329e077b40e8e \
  --private-key=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02 \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7302 \
  > /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-proposer.log 2>&1 &

echo "✅ All services started"
