#!/bin/bash
set -e

# Celo Sepolia L3 - Service Startup Script

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"

echo "🚀 Starting Celo Sepolia L3 Services..."
echo "=================================="

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create logs directory
mkdir -p "$DEPLOYMENT_DIR/logs"

# Function to start service in background
start_service() {
    local service=$1
    local env_file=$2
    local binary=$3
    local log_file="$DEPLOYMENT_DIR/logs/${service}.log"
    
    echo -e "${BLUE}Starting ${service}...${NC}"
    
    if [ ! -f "$binary" ]; then
        echo "❌ Binary not found: $binary"
        return 1
    fi
    
    # Load environment and start service
    set -a
    source "$env_file"
    set +a
    
    nohup "$binary" > "$log_file" 2>&1 &
    local pid=$!
    
    echo "$pid" > "$DEPLOYMENT_DIR/${service}.pid"
    echo -e "${GREEN}✅ ${service} started (PID: $pid)${NC}"
    echo "   Logs: $log_file"
}

# Start op-node first (consensus layer)
start_service "op-node" \
    "$DEPLOYMENT_DIR/op-node.env" \
    "$OPTIMISM_DIR/op-node/bin/op-node"

sleep 5

# Start op-batcher (batch submission)
start_service "op-batcher" \
    "$DEPLOYMENT_DIR/op-batcher.env" \
    "$OPTIMISM_DIR/op-batcher/bin/op-batcher"

sleep 5

# Start op-proposer (state root submission)
start_service "op-proposer" \
    "$DEPLOYMENT_DIR/op-proposer.env" \
    "$OPTIMISM_DIR/op-proposer/bin/op-proposer"

echo ""
echo "=================================="
echo -e "${GREEN}✅ All services started!${NC}"
echo ""
echo "Service Status:"
echo "  op-node:     http://localhost:9545"
echo "  op-batcher:  Running (Metrics: http://localhost:7301)"
echo "  op-proposer: http://localhost:8560"
echo ""
echo "Logs:"
echo "  op-node:     $DEPLOYMENT_DIR/logs/op-node.log"
echo "  op-batcher:  $DEPLOYMENT_DIR/logs/op-batcher.log"
echo "  op-proposer: $DEPLOYMENT_DIR/logs/op-proposer.log"
echo ""
echo "To stop services: bash $DEPLOYMENT_DIR/stop-services.sh"
