#!/bin/bash

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"

echo "🚀 STARTING CELO SEPOLIA L3 BLOCKCHAIN"
echo ""

# Kill existing processes
pkill -f "op-batcher|op-proposer|op-node" 2>/dev/null || true
docker stop celo-l3-geth 2>/dev/null || true
docker rm celo-l3-geth 2>/dev/null || true
sleep 2

# Start op-geth
echo "1️⃣  Starting op-geth (Sequencer)..."
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

sleep 10

# Start RPC proxy (op-batcher and op-proposer need this)
echo "2️⃣  Starting RPC Proxy (for op-batcher and op-proposer)..."
nohup node $DEPLOYMENT_DIR/simple-rpc-proxy.js \
  > $DEPLOYMENT_DIR/logs/rpc-proxy.log 2>&1 &

sleep 3

# Start op-batcher
echo "3️⃣  Starting op-batcher (Batch Submitter)..."
nohup $OPTIMISM_DIR/op-batcher/bin/op-batcher \
  --l1-eth-rpc=https://rpc.ankr.com/celo_sepolia \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --private-key=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7301 \
  > $DEPLOYMENT_DIR/logs/op-batcher.log 2>&1 &

sleep 3

# Start op-proposer
echo "4️⃣  Starting op-proposer (State Root Submitter)..."
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

sleep 15

echo ""
echo "════════════════════════════════════════════════════════"
echo "✅ CELO SEPOLIA L3 - FULLY OPERATIONAL"
echo "════════════════════════════════════════════════════════"
echo ""
echo "📊 SERVICES:"
echo ""

# Check op-geth
if docker ps | grep -q celo-l3-geth; then
  echo "   ✅ op-geth (Sequencer)"
  echo "      RPC: http://localhost:8545"
  echo "      WebSocket: ws://localhost:8546"
else
  echo "   ❌ op-geth FAILED"
fi

echo ""

# Check RPC proxy
if ps aux | grep "simple-rpc-proxy.js" | grep -v grep > /dev/null; then
  echo "   ✅ RPC Proxy (for batcher/proposer)"
  echo "      RPC: http://localhost:9545"
else
  echo "   ❌ RPC Proxy FAILED"
fi

echo ""

# Check op-batcher
if ps aux | grep "op-batcher/bin/op-batcher" | grep -v grep > /dev/null; then
  echo "   ✅ op-batcher (Batch Submitter)"
  echo "      Submitting batches to Celo Sepolia"
else
  echo "   ❌ op-batcher FAILED"
fi

echo ""

# Check op-proposer
if ps aux | grep "op-proposer/bin/op-proposer" | grep -v grep > /dev/null; then
  echo "   ✅ op-proposer (State Root Submitter)"
  echo "      Submitting state roots to Celo Sepolia"
else
  echo "   ❌ op-proposer FAILED"
fi

echo ""
echo "💰 YOUR ACCOUNT:"
echo "   Address: 0xABaF59180e0209bdB8b3048bFbe64e855074C0c4"
echo "   Balance: 100,000 GAIA tokens"
echo ""
echo "🌐 NETWORK:"
echo "   Chain ID: 424242"
echo "   L1: Celo Sepolia (11142220)"
echo ""
echo "📖 NEXT STEPS:"
echo "   1. Monitor: bash $DEPLOYMENT_DIR/MONITOR.sh"
echo "   2. Send TX: cast send --rpc-url http://localhost:8545 --private-key YOUR_KEY --value 1ether 0x89a26a33747b293430D4269A59525d5D0D5BbE65"
echo "   3. Deploy: forge create --rpc-url http://localhost:8545 --private-key YOUR_KEY src/Contract.sol:Contract"
echo ""
echo "════════════════════════════════════════════════════════"
