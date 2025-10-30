#!/bin/bash

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"

echo "📊 CELO SEPOLIA L3 - LIVE MONITORING DASHBOARD"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo ""

while true; do
  clear
  
  echo "════════════════════════════════════════════════════════"
  echo "📊 CELO SEPOLIA L3 - LIVE MONITORING"
  echo "════════════════════════════════════════════════════════"
  echo ""
  
  # Get current time
  echo "⏰ Time: $(date '+%Y-%m-%d %H:%M:%S')"
  echo ""
  
  # Check services
  echo "🔧 SERVICES:"
  echo ""
  
  if docker ps | grep -q celo-l3-geth; then
    echo "   ✅ op-geth (Sequencer) - RUNNING"
  else
    echo "   ❌ op-geth (Sequencer) - STOPPED"
  fi
  
  if ps aux | grep "op-batcher/bin/op-batcher" | grep -v grep > /dev/null; then
    echo "   ✅ op-batcher (Batch Submitter) - RUNNING"
  else
    echo "   ❌ op-batcher (Batch Submitter) - STOPPED"
  fi
  
  if ps aux | grep "op-proposer/bin/op-proposer" | grep -v grep > /dev/null; then
    echo "   ✅ op-proposer (State Root Submitter) - RUNNING"
  else
    echo "   ❌ op-proposer (State Root Submitter) - STOPPED"
  fi
  
  echo ""
  echo "📈 BLOCKCHAIN STATS:"
  echo ""
  
  # Get block number
  BLOCK=$(curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 2>/dev/null | jq -r '.result' 2>/dev/null)
  
  if [ ! -z "$BLOCK" ] && [ "$BLOCK" != "null" ]; then
    BLOCK_DEC=$((16#${BLOCK:2}))
    echo "   📦 Current Block: $BLOCK_DEC"
  else
    echo "   📦 Current Block: N/A (op-geth indexing...)"
  fi
  
  # Get your balance
  BALANCE=$(curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0xABaF59180e0209bdB8b3048bFbe64e855074C0c4","latest"],"id":1}' 2>/dev/null | jq -r '.result' 2>/dev/null)
  
  if [ ! -z "$BALANCE" ] && [ "$BALANCE" != "null" ]; then
    BALANCE_DEC=$((16#${BALANCE:2}))
    BALANCE_TOKENS=$(echo "scale=2; $BALANCE_DEC / 1000000000000000000" | bc)
    echo "   💰 Your Balance: $BALANCE_TOKENS GAIA"
  else
    echo "   💰 Your Balance: N/A"
  fi
  
  # Get gas price
  GASPRICE=$(curl -s http://localhost:8545 -X POST -H "Content-Type: application/json" \
    -d '{"jsonrpc":"2.0","method":"eth_gasPrice","params":[],"id":1}' 2>/dev/null | jq -r '.result' 2>/dev/null)
  
  if [ ! -z "$GASPRICE" ] && [ "$GASPRICE" != "null" ]; then
    GASPRICE_DEC=$((16#${GASPRICE:2}))
    echo "   ⛽ Gas Price: $GASPRICE_DEC wei"
  else
    echo "   ⛽ Gas Price: N/A"
  fi
  
  echo ""
  echo "📝 RECENT LOGS:"
  echo ""
  
  # Show last 5 lines of batcher log
  if [ -f "$DEPLOYMENT_DIR/logs/op-batcher.log" ]; then
    echo "   op-batcher:"
    tail -2 "$DEPLOYMENT_DIR/logs/op-batcher.log" | sed 's/^/      /'
  fi
  
  echo ""
  
  # Show last 5 lines of proposer log
  if [ -f "$DEPLOYMENT_DIR/logs/op-proposer.log" ]; then
    echo "   op-proposer:"
    tail -2 "$DEPLOYMENT_DIR/logs/op-proposer.log" | sed 's/^/      /'
  fi
  
  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "🔄 Refreshing in 5 seconds... (Ctrl+C to stop)"
  echo "════════════════════════════════════════════════════════"
  
  sleep 5
done
