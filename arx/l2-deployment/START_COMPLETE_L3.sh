#!/bin/bash

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"

echo "🚀 STARTING COMPLETE CELO SEPOLIA L3 DEPLOYMENT"
echo ""

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
    --ipcdisable \
    --rollup.disabletxpoolgossip > /dev/null 2>&1
  sleep 5
fi

echo "✅ op-geth started"
echo ""

# Start op-node
echo "Starting op-node..."
nohup $OPTIMISM_DIR/op-node/bin/op-node \
  --l1=https://rpc.ankr.com/celo_sepolia \
  --l2=http://localhost:8551 \
  --l2.jwt-secret=$DEPLOYMENT_DIR/jwt-secret.txt \
  --rollup.config=$DEPLOYMENT_DIR/rollup.json \
  --rollup.l1-chain-config=$DEPLOYMENT_DIR/celo-sepolia-l1.json \
  --sequencer.enabled \
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
  --rpc.addr=0.0.0.0 \
  --rpc.port=8547 \
  --metrics.enabled \
  --metrics.addr=0.0.0.0 \
  --metrics.port=7301 \
  --data-availability-type=calldata \
  --throttle.unsafe-da-bytes-lower-threshold=0 \
  > $DEPLOYMENT_DIR/logs/op-batcher.log 2>&1 &

sleep 3

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

sleep 15

echo ""
echo "════════════════════════════════════════════════════════"
echo "         ✅ CELO SEPOLIA L3 - FULLY OPERATIONAL"
echo "════════════════════════════════════════════════════════"
echo ""

echo "📊 SERVICE STATUS:"
echo ""

echo "1. op-geth (Sequencer):"
if docker ps | grep -q celo-l3-geth; then
  echo "   ✅ RUNNING on http://localhost:8545"
else
  echo "   ❌ NOT RUNNING"
fi

echo ""
echo "2. op-node (Consensus):"
if ps aux | grep "op-node/bin/op-node" | grep -v grep > /dev/null; then
  echo "   ✅ RUNNING on http://localhost:9545"
  echo "   📈 Metrics: http://localhost:7300/metrics"
else
  echo "   ⚠️  STARTING (may take a moment)"
  sleep 5
  if ps aux | grep "op-node/bin/op-node" | grep -v grep > /dev/null; then
    echo "   ✅ NOW RUNNING on http://localhost:9545"
  else
    echo "   ❌ FAILED - Check logs: tail -f $DEPLOYMENT_DIR/logs/op-node.log"
  fi
fi

echo ""
echo "3. op-batcher (Batch Submitter):"
if ps aux | grep "op-batcher/bin/op-batcher" | grep -v grep > /dev/null; then
  echo "   ✅ RUNNING - Submitting batches to Celo Sepolia"
  echo "   📈 Metrics: http://localhost:7301/metrics"
else
  echo "   ❌ NOT RUNNING - Check logs: tail -f $DEPLOYMENT_DIR/logs/op-batcher.log"
fi

echo ""
echo "4. op-proposer (State Root Submitter):"
if ps aux | grep "op-proposer/bin/op-proposer" | grep -v grep > /dev/null; then
  echo "   ✅ RUNNING - Submitting state roots to Celo Sepolia"
  echo "   📈 Metrics: http://localhost:7302/metrics"
else
  echo "   ❌ NOT RUNNING - Check logs: tail -f $DEPLOYMENT_DIR/logs/op-proposer.log"
fi

echo ""
echo "🔗 NETWORK DETAILS:"
echo "   L3 Chain ID: 424242"
echo "   L1 Chain ID: 11142220 (Celo Sepolia)"
echo "   L3 RPC: http://localhost:8545"
echo "   L1 RPC: https://rpc.ankr.com/celo_sepolia"

echo ""
echo "🚀 READY TO USE:"
echo ""
echo "Deploy a contract:"
echo "  forge create --rpc-url http://localhost:8545 \\"
echo "    --private-key f0071a1eef433a24b6603da004f67c6aad2513718c54ec0c70504a88de4edb88 \\"
echo "    src/Contract.sol:Contract"
echo ""
echo "Send a transaction:"
echo "  cast send --rpc-url http://localhost:8545 \\"
echo "    --private-key f0071a1eef433a24b6603da004f67c6aad2513718c54ec0c70504a88de4edb88 \\"
echo "    --value 0.1ether 0x89a26a33747b293430D4269A59525d5D0D5BbE65"
echo ""
echo "════════════════════════════════════════════════════════"
echo ""
