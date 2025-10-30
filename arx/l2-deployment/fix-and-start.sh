#!/bin/bash
set -e

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"

echo "🔧 Fixing op-node configuration..."

# Kill existing processes
pkill -f "op-node|op-batcher|op-proposer" || true
sleep 2

# Ensure op-geth is running
if ! docker ps | grep -q celo-l3-geth; then
  echo "Starting op-geth..."
  docker run -d \
    --name celo-l3-geth \
    -p 8545:8545 \
    -p 8546:8546 \
    -p 8551:8551 \
    -p 30303:30303 \
    -v $DEPLOYMENT_DIR/geth-data:/geth-data \
    -v $DEPLOYMENT_DIR/jwt-secret.txt:/jwt-secret.txt:ro \
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
    --rollup.disabletxpoolgossip > /dev/null 2>&1
  sleep 5
fi

echo "✅ op-geth ready"

# Start op-node with proper error handling
echo "Starting op-node..."
nohup $OPTIMISM_DIR/op-node/bin/op-node \
  --l1=https://rpc.ankr.com/celo_sepolia \
  --l2=http://localhost:8551 \
  --l2.jwt-secret=$DEPLOYMENT_DIR/jwt-secret.txt \
  --rollup.config=$DEPLOYMENT_DIR/rollup.json \
  --rpc.addr=0.0.0.0 \
  --rpc.port=9545 \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7300 \
  --p2p.disable \
  --l1.trustrpc \
  > $DEPLOYMENT_DIR/logs/op-node.log 2>&1 &

sleep 5

# Start op-batcher
echo "Starting op-batcher..."
nohup $OPTIMISM_DIR/op-batcher/bin/op-batcher \
  --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7301 \
  > $DEPLOYMENT_DIR/logs/op-batcher.log 2>&1 &

sleep 5

# Start op-proposer
echo "Starting op-proposer..."
nohup $OPTIMISM_DIR/op-proposer/bin/op-proposer \
  --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
  --rollup-rpc=http://localhost:9545 \
  --game-factory-address=0x47EdA6d3E07ce233AB48e83Fb26329e077b40e8e \
  --proposal-interval=1m \
  --private-key=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02 \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7302 \
  > $DEPLOYMENT_DIR/logs/op-proposer.log 2>&1 &

echo ""
echo "⏳ Waiting for services to start..."
sleep 15

echo ""
echo "=== SYSTEM STATUS ==="
echo ""
echo "op-geth:"
docker ps | grep celo-l3-geth | awk '{print $NF}' && echo "✅ Running" || echo "❌ Not running"

echo ""
echo "op-node:"
if ps aux | grep "op-node/bin/op-node" | grep -v grep > /dev/null; then
  echo "✅ Running"
else
  echo "❌ Not running - checking logs:"
  tail -5 $DEPLOYMENT_DIR/logs/op-node.log
fi

echo ""
echo "op-batcher:"
if ps aux | grep "op-batcher/bin/op-batcher" | grep -v grep > /dev/null; then
  echo "✅ Running"
else
  echo "❌ Not running - checking logs:"
  tail -5 $DEPLOYMENT_DIR/logs/op-batcher.log
fi

echo ""
echo "op-proposer:"
if ps aux | grep "op-proposer/bin/op-proposer" | grep -v grep > /dev/null; then
  echo "✅ Running"
else
  echo "❌ Not running - checking logs:"
  tail -5 $DEPLOYMENT_DIR/logs/op-proposer.log
fi

echo ""
echo "L3 RPC Test:"
curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' | jq '.result' && echo "✅ L3 RPC Working" || echo "❌ L3 RPC Not responding"

echo ""
echo "=== DEPLOYMENT COMPLETE ==="
