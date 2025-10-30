#!/bin/bash

# Celo Sepolia L3 - Start op-geth (L2 Execution Layer)
# Based on Op.md Step 14

set -e

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
GETH_DATA="$DEPLOYMENT_DIR/geth-data"
JWT_SECRET="$DEPLOYMENT_DIR/jwt-secret.txt"

echo "🚀 Starting op-geth (L2 Execution Layer)..."
echo ""

# Check if geth-data exists
if [ ! -d "$GETH_DATA" ]; then
    echo "Creating geth-data directory..."
    mkdir -p "$GETH_DATA"
fi

# Check if JWT secret exists
if [ ! -f "$JWT_SECRET" ]; then
    echo "ERROR: JWT secret not found at $JWT_SECRET"
    exit 1
fi

# Check if geth binary exists
if [ ! -f "/usr/local/bin/geth" ] && [ ! -f "/usr/bin/geth" ]; then
    echo "ERROR: geth binary not found"
    echo "Please install op-geth first"
    exit 1
fi

# Find geth binary
GETH_BIN=$(which geth || echo "/usr/local/bin/geth")

if [ ! -f "$GETH_BIN" ]; then
    GETH_BIN="/usr/bin/geth"
fi

echo "Using geth: $GETH_BIN"
echo "Data directory: $GETH_DATA"
echo "JWT secret: $JWT_SECRET"
echo ""

# Start op-geth
echo "Starting op-geth..."
$GETH_BIN \
  --datadir="$GETH_DATA" \
  --http \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=web3,eth,debug,net,engine \
  --http.corsdomain="*" \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.api=web3,eth,debug,net,engine \
  --ws.origins="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.jwtsecret="$JWT_SECRET" \
  --authrpc.vhosts="*" \
  --syncmode=full \
  --maxpeers=0 \
  --networkid=424242 \
  --nodiscover \
  --rollup.disabletxpoolgossip \
  --rollup.sequencerhttp=http://localhost:8545 \
  > "$DEPLOYMENT_DIR/logs/geth.log" 2>&1 &

GETH_PID=$!
echo "$GETH_PID" > "$DEPLOYMENT_DIR/geth.pid"

echo "✅ op-geth started (PID: $GETH_PID)"
echo ""
echo "Logs: $DEPLOYMENT_DIR/logs/geth.log"
echo ""
echo "Endpoints:"
echo "  HTTP RPC: http://localhost:8545"
echo "  WebSocket: ws://localhost:8546"
echo "  Engine RPC: http://localhost:8551"
echo ""
echo "To view logs:"
echo "  tail -f $DEPLOYMENT_DIR/logs/geth.log"
