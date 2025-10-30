#!/bin/bash

# Celo Sepolia L3 - Service Shutdown Script

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"

echo "🛑 Stopping Celo Sepolia L3 Services..."
echo "=================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

# Function to stop service
stop_service() {
    local service=$1
    local pid_file="$DEPLOYMENT_DIR/${service}.pid"
    
    if [ -f "$pid_file" ]; then
        local pid=$(cat "$pid_file")
        if kill -0 "$pid" 2>/dev/null; then
            kill "$pid"
            echo -e "${GREEN}✅ ${service} stopped (PID: $pid)${NC}"
            rm "$pid_file"
        else
            echo -e "${RED}⚠️  ${service} not running${NC}"
            rm "$pid_file"
        fi
    else
        echo -e "${RED}⚠️  ${service} PID file not found${NC}"
    fi
}

# Stop services in reverse order
stop_service "op-proposer"
sleep 2
stop_service "op-batcher"
sleep 2
stop_service "op-node"

echo ""
echo "=================================="
echo -e "${GREEN}✅ All services stopped!${NC}"
