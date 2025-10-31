#!/bin/bash
set -euo pipefail

OP_ROOT="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"
L2_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
LOGS="$L2_DIR/logs"

mkdir -p "$LOGS"

echo "==== Starting L3 Services ===="

# Kill any existing processes
echo "Stopping existing services..."
pkill -9 -f "op-batcher/bin/op-batcher" 2>/dev/null || true
pkill -9 -f "op-proposer/bin/op-proposer" 2>/dev/null || true
sleep 2

# Check if op-node is running
if ! pgrep -f "op-node/bin/op-node" > /dev/null; then
  echo "❌ op-node is not running. Start it first with START_L3_PROD.sh"
  exit 1
fi

echo "✅ op-node is running"

# Wait for op-node RPC to be ready
echo "Waiting for op-node RPC on port 9545..."
for i in {1..30}; do
  if curl -s http://localhost:9545 > /dev/null 2>&1; then
    echo "✅ op-node RPC is ready"
    break
  fi
  echo "Waiting... ($i/30)"
  sleep 1
done

# Start op-batcher (use port 9546 for its RPC to avoid conflicts)
echo "Starting op-batcher..."
nohup "$OP_ROOT/op-batcher/bin/op-batcher" \
  --l1-eth-rpc=https://forno.celo-sepolia.celo-testnet.org \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c \
  --rpc.port=9546 \
  --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7301 \
  > "$LOGS/op-batcher.log" 2>&1 &

sleep 5

# Start op-proposer (if game factory address is available)
GAME_FACTORY=$(jq -r '.DisputeGameFactoryProxy // empty' "$L2_DIR/l1-deployments/11142220-deploy.json" 2>/dev/null || echo "")

if [ -n "$GAME_FACTORY" ]; then
  echo "Starting op-proposer with game factory: $GAME_FACTORY..."
  nohup "$OP_ROOT/op-proposer/bin/op-proposer" \
    --l1-eth-rpc=https://forno.celo-sepolia.celo-testnet.org \
    --rollup-rpc=http://localhost:9545 \
    --game-factory-address="$GAME_FACTORY" \
    --proposal-interval=1m \
    --rpc.port=9547 \
    --private-key=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02 \
    --metrics.enabled --metrics.addr=0.0.0.0 --metrics.port=7302 \
    > "$LOGS/op-proposer.log" 2>&1 &
  sleep 5
else
  echo "⚠️  Game factory address not found. Skipping op-proposer."
  echo "Deploy L1 contracts first with: ./deploy-l1-contracts.sh"
fi

# Status check
echo ""
echo "==== Service Status ===="
pgrep -f "op-batcher/bin/op-batcher" > /dev/null && echo "✅ op-batcher is running" || echo "❌ op-batcher failed"
pgrep -f "op-proposer/bin/op-proposer" > /dev/null && echo "✅ op-proposer is running" || echo "❌ op-proposer not running"

echo ""
echo "Logs:"
echo "  op-batcher: tail -f $LOGS/op-batcher.log"
echo "  op-proposer: tail -f $LOGS/op-proposer.log"
