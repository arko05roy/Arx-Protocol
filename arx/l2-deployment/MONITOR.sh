#!/bin/bash

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
L1_RPC="https://rpc.ankr.com/celo_sepolia"
L2_RPC="http://localhost:8545"

# Load environment if available
if [ -f "../.envrc.celo-sepolia" ]; then
  source "../.envrc.celo-sepolia"
fi

# Account addresses
BATCHER_ADDR="0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62"
PROPOSER_ADDR="0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47"
ADMIN_ADDR="0x89a26a33747b293430D4269A59525d5D0D5BbE65"

# Thresholds (in wei) - ULTRA LOW COST
MIN_BATCHER=100000000000000000    # 0.1 CELO
MIN_PROPOSER=50000000000000000    # 0.05 CELO

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
  echo "🔧 SERVICES STATUS:"
  echo ""

  if docker ps | grep -q celo-l3-geth; then
    echo "   ✅ op-geth (Execution Layer) - RUNNING"
    # Check if RPC is responsive
    if curl -sf -X POST $L2_RPC -H "Content-Type: application/json" \
       -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' > /dev/null 2>&1; then
      echo "      └─ RPC: Responsive ✓"
    else
      echo "      └─ RPC: Not responding ⚠️"
    fi
  else
    echo "   ❌ op-geth (Execution Layer) - STOPPED"
  fi

  if ps aux | grep "op-batcher/bin/op-batcher" | grep -v grep > /dev/null; then
    echo "   ✅ op-batcher (Batch Submitter) - RUNNING"
  else
    echo "   ❌ op-batcher (Batch Submitter) - STOPPED"
  fi

  if ps aux | grep "op-proposer/bin/op-proposer" | grep -v grep > /dev/null; then
    echo "   ✅ op-proposer (State Root Proposer) - RUNNING"
  else
    echo "   ❌ op-proposer (State Root Proposer) - STOPPED"
  fi

  # Check op-node (RPC proxy)
  if ps aux | grep "simple-rpc-proxy.js" | grep -v grep > /dev/null; then
    echo "   ✅ op-node RPC Proxy - RUNNING"
  else
    echo "   ⚠️  op-node RPC Proxy - STOPPED (using proxy)"
  fi

  echo ""
  echo "💰 L1 ACCOUNT BALANCES (Celo Sepolia):"
  echo ""

  # Check if cast is available
  if command -v cast &> /dev/null; then
    # Batcher balance
    BATCHER_BAL=$(cast balance $BATCHER_ADDR --rpc-url $L1_RPC 2>/dev/null)
    if [ ! -z "$BATCHER_BAL" ]; then
      BATCHER_ETH=$(cast --to-unit $BATCHER_BAL ether 2>/dev/null | cut -d'.' -f1)
      if [ "$BATCHER_BAL" -lt "$MIN_BATCHER" ]; then
        echo "   ⚠️  Batcher:  $BATCHER_ETH CELO (LOW - REFILL NEEDED!)"
      else
        echo "   ✅ Batcher:  $BATCHER_ETH CELO"
      fi
    else
      echo "   ⚠️  Batcher:  Unable to fetch"
    fi

    # Proposer balance
    PROPOSER_BAL=$(cast balance $PROPOSER_ADDR --rpc-url $L1_RPC 2>/dev/null)
    if [ ! -z "$PROPOSER_BAL" ]; then
      PROPOSER_ETH=$(cast --to-unit $PROPOSER_BAL ether 2>/dev/null | cut -d'.' -f1)
      if [ "$PROPOSER_BAL" -lt "$MIN_PROPOSER" ]; then
        echo "   ⚠️  Proposer: $PROPOSER_ETH CELO (LOW - REFILL NEEDED!)"
      else
        echo "   ✅ Proposer: $PROPOSER_ETH CELO"
      fi
    else
      echo "   ⚠️  Proposer: Unable to fetch"
    fi

    # Admin balance
    ADMIN_BAL=$(cast balance $ADMIN_ADDR --rpc-url $L1_RPC 2>/dev/null)
    if [ ! -z "$ADMIN_BAL" ]; then
      ADMIN_ETH=$(cast --to-unit $ADMIN_BAL ether 2>/dev/null | cut -d'.' -f1)
      echo "   ℹ️  Admin:    $ADMIN_ETH CELO"
    else
      echo "   ⚠️  Admin:    Unable to fetch"
    fi
  else
    echo "   ⚠️  Install 'cast' (foundry) to monitor L1 balances"
    echo "      https://book.getfoundry.sh/getting-started/installation"
  fi

  echo ""
  echo "📈 L2 BLOCKCHAIN STATS:"
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
  echo "🌐 NETWORK CONNECTIVITY:"
  echo ""

  # Check L1 RPC connectivity
  if curl -sf -X POST $L1_RPC -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' > /dev/null 2>&1; then
    L1_BLOCK=$(curl -s -X POST $L1_RPC -H "Content-Type: application/json" \
      -d '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' 2>/dev/null | jq -r '.result' 2>/dev/null)
    if [ ! -z "$L1_BLOCK" ]; then
      L1_BLOCK_DEC=$((16#${L1_BLOCK:2}))
      echo "   ✅ L1 RPC (Celo Sepolia): Connected - Block #$L1_BLOCK_DEC"
    else
      echo "   ⚠️  L1 RPC (Celo Sepolia): Connected but unable to parse"
    fi
  else
    echo "   ❌ L1 RPC (Celo Sepolia): Not reachable"
  fi

  # Check L2 RPC connectivity
  if curl -sf -X POST $L2_RPC -H "Content-Type: application/json" \
     -d '{"jsonrpc":"2.0","method":"net_version","params":[],"id":1}' > /dev/null 2>&1; then
    echo "   ✅ L2 RPC (localhost:8545): Connected"
  else
    echo "   ❌ L2 RPC (localhost:8545): Not reachable"
  fi

  echo ""
  echo "📝 RECENT ACTIVITY:"
  echo ""

  # Check for recent errors in batcher log
  if [ -f "$DEPLOYMENT_DIR/logs/op-batcher.log" ]; then
    ERROR_COUNT=$(grep -c "error\|Error\|ERROR" "$DEPLOYMENT_DIR/logs/op-batcher.log" 2>/dev/null | tail -100 || echo "0")
    if [ "$ERROR_COUNT" -gt 0 ]; then
      echo "   ⚠️  Batcher: $ERROR_COUNT errors in recent logs"
      echo "      Last activity:"
      tail -2 "$DEPLOYMENT_DIR/logs/op-batcher.log" 2>/dev/null | sed 's/^/         /'
    else
      echo "   ✅ Batcher: No recent errors"
      tail -1 "$DEPLOYMENT_DIR/logs/op-batcher.log" 2>/dev/null | sed 's/^/      /'
    fi
  else
    echo "   ⚠️  Batcher: No log file found"
  fi

  echo ""

  # Check for recent errors in proposer log
  if [ -f "$DEPLOYMENT_DIR/logs/op-proposer.log" ]; then
    PROP_ERROR_COUNT=$(grep -c "error\|Error\|ERROR" "$DEPLOYMENT_DIR/logs/op-proposer.log" 2>/dev/null | tail -100 || echo "0")
    if [ "$PROP_ERROR_COUNT" -gt 0 ]; then
      echo "   ⚠️  Proposer: $PROP_ERROR_COUNT errors in recent logs"
      echo "      Last activity:"
      tail -2 "$DEPLOYMENT_DIR/logs/op-proposer.log" 2>/dev/null | sed 's/^/         /'
    else
      echo "   ✅ Proposer: No recent errors"
      tail -1 "$DEPLOYMENT_DIR/logs/op-proposer.log" 2>/dev/null | sed 's/^/      /'
    fi
  else
    echo "   ⚠️  Proposer: No log file found"
  fi

  echo ""
  echo "════════════════════════════════════════════════════════"
  echo "💡 QUICK ACTIONS:"
  echo "   • Check full logs: tail -f logs/op-batcher.log"
  echo "   • Fund accounts: See ACCOUNT_FUNDING_GUIDE.md"
  echo "   • Restart services: ./START_L3_COMPLETE.sh"
  echo "════════════════════════════════════════════════════════"
  echo "🔄 Refreshing in 5 seconds... (Ctrl+C to stop)"
  echo "════════════════════════════════════════════════════════"

  sleep 5
done
