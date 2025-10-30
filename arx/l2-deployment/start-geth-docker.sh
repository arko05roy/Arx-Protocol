#!/bin/bash

# Celo Sepolia L3 - Start op-geth using Docker
# Much simpler than building from source

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
GETH_DATA="$DEPLOYMENT_DIR/geth-data"

echo "🚀 Starting op-geth (L2 Execution Layer) via Docker..."
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ ERROR: Docker is not installed"
    echo "Please install Docker from https://www.docker.com/products/docker-desktop"
    exit 1
fi

# Check if geth-data directory exists
if [ ! -d "$GETH_DATA" ]; then
    echo "Creating geth-data directory..."
    mkdir -p "$GETH_DATA"
fi

# Check if jwt-secret exists
if [ ! -f "$DEPLOYMENT_DIR/jwt-secret.txt" ]; then
    echo "❌ ERROR: JWT secret not found"
    exit 1
fi

echo "Configuration:"
echo "  Data directory: $GETH_DATA"
echo "  JWT secret: $DEPLOYMENT_DIR/jwt-secret.txt"
echo ""

# Start op-geth container
echo "Starting op-geth container..."
docker run -d \
  --name celo-l3-geth \
  -p 8545:8545 \
  -p 8546:8546 \
  -p 8551:8551 \
  -p 30303:30303 \
  -v "$GETH_DATA:/geth-data" \
  -v "$DEPLOYMENT_DIR/jwt-secret.txt:/jwt-secret.txt:ro" \
  us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:latest \
  --datadir=/geth-data \
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
  --authrpc.jwtsecret=/jwt-secret.txt \
  --authrpc.vhosts="*" \
  --syncmode=full \
  --maxpeers=0 \
  --networkid=424242 \
  --nodiscover \
  --rollup.disabletxpoolgossip \
  --rollup.sequencerhttp=http://localhost:8545

if [ $? -eq 0 ]; then
    echo "✅ op-geth container started"
    echo ""
    echo "Endpoints:"
    echo "  HTTP RPC:    http://localhost:8545"
    echo "  WebSocket:   ws://localhost:8546"
    echo "  Engine RPC:  http://localhost:8551"
    echo ""
    echo "To view logs:"
    echo "  docker logs -f celo-l3-geth"
    echo ""
    echo "To stop:"
    echo "  docker stop celo-l3-geth"
    echo "  docker rm celo-l3-geth"
else
    echo "❌ Failed to start op-geth container"
    exit 1
fi
