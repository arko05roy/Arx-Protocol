#!/bin/bash
set -e

# Celo Sepolia L3 - Direct Service Startup Script

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"

echo "🚀 Starting Celo Sepolia L3 Services (Direct)..."
echo "=================================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create logs directory
mkdir -p "$DEPLOYMENT_DIR/logs"

# Stop any existing services
echo "Stopping existing services..."
pkill -f "op-node" || true
pkill -f "op-batcher" || true
pkill -f "op-proposer" || true
sleep 2

# Start op-node
echo -e "${BLUE}Starting op-node...${NC}"
nohup "$OPTIMISM_DIR/op-node/bin/op-node" \
  --l1="https://rpc.ankr.com/celo_sepolia" \
  --l2="http://localhost:8551" \
  --l2.jwt-secret="$DEPLOYMENT_DIR/jwt-secret.txt" \
  --rollup.config="$DEPLOYMENT_DIR/rollup.json" \
  --rpc.addr="0.0.0.0" \
  --rpc.port="9545" \
  --metrics.enabled \
  --metrics.addr="0.0.0.0" \
  --metrics.port="7300" \
  --p2p.disable \
  > "$DEPLOYMENT_DIR/logs/op-node.log" 2>&1 &
echo "$!" > "$DEPLOYMENT_DIR/op-node.pid"
echo -e "${GREEN}✅ op-node started${NC}"

sleep 5

# Start op-batcher
echo -e "${BLUE}Starting op-batcher...${NC}"
nohup "$OPTIMISM_DIR/op-batcher/bin/op-batcher" \
  --l1-eth-rpc="https://rpc.ankr.com/celo_sepolia" \
  --l2-eth-rpc="http://localhost:8545" \
  --private-key="f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c" \
  --metrics.enabled \
  --metrics.addr="0.0.0.0" \
  --metrics.port="7301" \
  > "$DEPLOYMENT_DIR/logs/op-batcher.log" 2>&1 &
echo "$!" > "$DEPLOYMENT_DIR/op-batcher.pid"
echo -e "${GREEN}✅ op-batcher started${NC}"

sleep 5

# Start op-proposer
echo -e "${BLUE}Starting op-proposer...${NC}"
nohup "$OPTIMISM_DIR/op-proposer/bin/op-proposer" \
  --l1-eth-rpc="https://rpc.ankr.com/celo_sepolia" \
  --l2-eth-rpc="http://localhost:8545" \
  --private-key="9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02" \
  --l2-output-oracle-address="0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1" \
  --metrics.enabled \
  --metrics.addr="0.0.0.0" \
  --metrics.port="7302" \
  --rpc.addr="0.0.0.0" \
  --rpc.port="8560" \
  > "$DEPLOYMENT_DIR/logs/op-proposer.log" 2>&1 &
echo "$!" > "$DEPLOYMENT_DIR/op-proposer.pid"
echo -e "${GREEN}✅ op-proposer started${NC}"

echo ""
echo "=================================================="
echo -e "${GREEN}✅ All services started!${NC}"
echo ""
echo "Service Status:"
echo "  op-node:     http://localhost:9545"
echo "  op-batcher:  Running (Metrics: http://localhost:7301)"
echo "  op-proposer: http://localhost:8560"
echo ""
echo "Logs:"
echo "  tail -f $DEPLOYMENT_DIR/logs/op-node.log"
echo "  tail -f $DEPLOYMENT_DIR/logs/op-batcher.log"
echo "  tail -f $DEPLOYMENT_DIR/logs/op-proposer.log"
echo ""
echo "To stop: bash $DEPLOYMENT_DIR/stop-services.sh"
