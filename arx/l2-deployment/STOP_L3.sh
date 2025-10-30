#!/bin/bash

echo "🛑 Stopping Celo Sepolia L3..."
echo ""

# Kill processes
echo "Stopping op-batcher..."
pkill -f "op-batcher/bin/op-batcher" 2>/dev/null || true

echo "Stopping op-proposer..."
pkill -f "op-proposer/bin/op-proposer" 2>/dev/null || true

echo "Stopping op-node..."
pkill -f "op-node/bin/op-node" 2>/dev/null || true

# Stop Docker
echo "Stopping op-geth..."
docker stop celo-l3-geth 2>/dev/null || true

sleep 2

echo ""
echo "✅ All services stopped"
echo ""
echo "To restart: bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/START_L3_COMPLETE.sh"
