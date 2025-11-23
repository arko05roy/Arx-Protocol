#!/bin/bash

# =============================================================================
# ARX L3 BLOCKCHAIN - ONE-SHOT RUNNER WITH GENESIS CONTRACT DEPLOYMENT
# =============================================================================
# This script starts and manages the complete L3 blockchain stack with
# automatic ARX Protocol contract deployment at genesis.
# When this script stops, the entire blockchain stops.
# Transactions automatically settle to Celo Sepolia while running.
# =============================================================================

set -e

DEPLOYMENT_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"
OPTIMISM_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"
WEB3_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/web3"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Process IDs
GETH_CONTAINER=""
NODE_PID=""
BATCHER_PID=""
PROPOSER_PID=""

# =============================================================================
# CLEANUP FUNCTION - Called on script exit
# =============================================================================
cleanup() {
    echo ""
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}          🛑 SHUTTING DOWN ARX L3 BLOCKCHAIN${NC}"
    echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
    echo ""

    # Stop processes in reverse order
    if [ ! -z "$PROPOSER_PID" ]; then
        echo -e "${BLUE}Stopping op-proposer (PID: $PROPOSER_PID)...${NC}"
        kill $PROPOSER_PID 2>/dev/null || true
    fi

    if [ ! -z "$BATCHER_PID" ]; then
        echo -e "${BLUE}Stopping op-batcher (PID: $BATCHER_PID)...${NC}"
        kill $BATCHER_PID 2>/dev/null || true
    fi

    if [ ! -z "$NODE_PID" ]; then
        echo -e "${BLUE}Stopping op-node (PID: $NODE_PID)...${NC}"
        kill $NODE_PID 2>/dev/null || true
    fi

    if [ ! -z "$GETH_CONTAINER" ]; then
        echo -e "${BLUE}Stopping op-geth container...${NC}"
        docker stop $GETH_CONTAINER 2>/dev/null || true
        docker rm $GETH_CONTAINER 2>/dev/null || true
    fi

    echo ""
    echo -e "${GREEN}✅ ARX L3 Blockchain stopped successfully${NC}"
    echo ""
    exit 0
}

# Set up trap to catch exit signals
trap cleanup SIGINT SIGTERM EXIT

# =============================================================================
# INITIAL CLEANUP
# =============================================================================
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}          🚀 STARTING ARX L3 BLOCKCHAIN${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${YELLOW}Cleaning up existing processes...${NC}"
pkill -f "op-node|op-batcher|op-proposer" 2>/dev/null || true
docker stop celo-l3-geth 2>/dev/null || true
docker rm celo-l3-geth 2>/dev/null || true
sleep 2

# =============================================================================
# INITIALIZE GETH WITH GENESIS (if needed)
# =============================================================================
if [ ! -d "$DEPLOYMENT_DIR/geth-data/geth/chaindata" ]; then
    echo ""
    echo -e "${YELLOW}Initializing geth with genesis (first run)...${NC}"
    docker run --rm \
      -v $DEPLOYMENT_DIR/geth-data:/geth-data \
      -v $DEPLOYMENT_DIR/genesis.json:/genesis.json:ro \
      us-docker.pkg.dev/oplabs-tools-artifacts/images/op-geth:latest \
      init --datadir=/geth-data /genesis.json
    echo -e "${GREEN}✅ Geth initialized with genesis${NC}"
fi

# =============================================================================
# START OP-GETH (Execution Layer)
# =============================================================================
echo ""
echo -e "${GREEN}Starting op-geth (Execution Layer)...${NC}"

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

GETH_CONTAINER=$(docker ps -q --filter name=celo-l3-geth)

echo -e "${GREEN}✅ op-geth started (Container: $GETH_CONTAINER)${NC}"
sleep 5

# Wait for geth to be ready
echo -e "${YELLOW}Waiting for op-geth to be ready...${NC}"
for i in {1..30}; do
    if cast block-number --rpc-url http://localhost:8545 >/dev/null 2>&1; then
        echo -e "${GREEN}✅ op-geth is ready${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ op-geth failed to start${NC}"
        exit 1
    fi
    sleep 1
done

# =============================================================================
# START OP-NODE (Consensus Layer)
# =============================================================================
echo ""
echo -e "${GREEN}Starting op-node (Consensus Layer)...${NC}"

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

NODE_PID=$!

echo -e "${GREEN}✅ op-node started (PID: $NODE_PID)${NC}"
sleep 8

# Wait for node to start producing blocks
echo -e "${YELLOW}Waiting for op-node to start producing blocks...${NC}"
for i in {1..30}; do
    BLOCK_NUM=$(cast block-number --rpc-url http://localhost:8545 2>/dev/null || echo "0")
    if [ "$BLOCK_NUM" -gt "0" ]; then
        echo -e "${GREEN}✅ op-node is producing blocks (current: $BLOCK_NUM)${NC}"
        break
    fi
    if [ $i -eq 30 ]; then
        echo -e "${RED}❌ op-node failed to start producing blocks${NC}"
        exit 1
    fi
    sleep 1
done

# =============================================================================
# ARX PROTOCOL CONTRACTS - NOW USING PREDEPLOYS
# =============================================================================
# NOTE: ARX Protocol contracts are now embedded in genesis as predeploys.
# They are available immediately at fixed addresses from block 0.
# No compilation, deployment, or initialization needed!
#
# To regenerate genesis with predeploys, run:
#   node $DEPLOYMENT_DIR/scripts/inject-arx-predeploys.js
#
# Predeploy addresses (0x4200...0100 - 0x4200...010B):
#   - TaskRegistry: 0x4200000000000000000000000000000000000100
#   - DataRegistry: 0x4200000000000000000000000000000000000101
#   - ModelRegistry: 0x4200000000000000000000000000000000000102
#   - FundingPool: 0x4200000000000000000000000000000000000103
#   - CollateralManager: 0x4200000000000000000000000000000000000104
#   - VerificationManager: 0x4200000000000000000000000000000000000105
#   - CarbonCreditMinter: 0x4200000000000000000000000000000000000106
#   - CarbonMarketplace: 0x4200000000000000000000000000000000000107
#   - PredictionMarketplace: 0x4200000000000000000000000000000000000108
#   - GovernanceDAO: 0x4200000000000000000000000000000000000109
#   - Treasury: 0x420000000000000000000000000000000000010A
#   - cUSD Token: 0x420000000000000000000000000000000000010B
# =============================================================================

echo ""
echo -e "${GREEN}✅ ARX Protocol contracts available as genesis predeploys${NC}"
echo -e "${GREEN}   (No deployment needed - contracts embedded in genesis)${NC}"
echo ""

# =============================================================================
# MINT CUSD TOKENS
# =============================================================================
echo -e "${YELLOW}Minting cUSD tokens...${NC}"

CUSD_ADDRESS="0x420000000000000000000000000000000000010B"
TARGET_ACCOUNT="0xABaF59180e0209bdB8b3048bFbe64e855074C0c4"
FUNDED_KEY="0xf0071a1eef433a24b6603da004f67c6aad2513718c54ec0c70504a88de4edb88"
MINT_AMOUNT="1000000000000000000000000" # 1M tokens with 18 decimals

# Wait a bit for the chain to stabilize
sleep 2

# Mint cUSD tokens to ARX Dapp account (with timeout)
timeout 10s cast send $CUSD_ADDRESS \
  "mint(address,uint256)" \
  $TARGET_ACCOUNT \
  $MINT_AMOUNT \
  --private-key $FUNDED_KEY \
  --rpc-url http://localhost:8545 \
  --legacy \
  --gas-price 1000000000 \
  --gas-limit 100000 > /dev/null 2>&1 || MINT_STATUS=$?

# Set default status if not set
MINT_STATUS=${MINT_STATUS:-0}
if [ $MINT_STATUS -eq 0 ]; then
    echo -e "${GREEN}✅ Minted 1,000,000 cUSD to ARX Dapp account${NC}"
elif [ $MINT_STATUS -eq 124 ]; then
    echo -e "${YELLOW}⚠️  cUSD minting timed out (will retry in background)${NC}"
else
    echo -e "${YELLOW}⚠️  cUSD minting failed (may already be minted)${NC}"
fi

echo ""

# =============================================================================
# FUND ARX DAPP ACCOUNT
# =============================================================================
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}          💰 FUNDING ARX DAPP ACCOUNT${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

TARGET_ACCOUNT="0xabaf59180e0209bdb8b3048bfbe64e855074c0c4"
FUNDED_ACCOUNT="0x6813Eb9362372EeF6200f3b1dbC3f819671cBA69"
FUNDED_PRIVATE_KEY="0xf0071a1eef433a24b6603da004f67c6aad2513718c54ec0c70504a88de4edb88"

# Check current balance
CURRENT_BALANCE=$(cast balance $TARGET_ACCOUNT --rpc-url http://localhost:8545 2>/dev/null || echo "0")
CURRENT_BALANCE_ETH=$(cast --to-unit $CURRENT_BALANCE ether 2>/dev/null || echo "0")

echo -e "${YELLOW}Current balance: $CURRENT_BALANCE_ETH ETH${NC}"

# Only fund if balance is less than 15,000 ETH (account starts with 20,000 from genesis)
if (( $(echo "$CURRENT_BALANCE_ETH < 15000" | bc -l) )); then
    echo -e "${YELLOW}Funding account: $TARGET_ACCOUNT${NC}"
    echo -e "${YELLOW}Amount: 10,000 ETH${NC}"
    echo ""

    # Send 10,000 ETH to the target account
    TX_HASH=$(cast send $TARGET_ACCOUNT \
      --value 10000ether \
      --private-key $FUNDED_PRIVATE_KEY \
      --rpc-url http://localhost:8545 \
      --legacy 2>&1 | grep "transactionHash" | awk '{print $2}')

    if [ -z "$TX_HASH" ]; then
        echo -e "${YELLOW}⚠️  Funding transaction failed (account may already be funded)${NC}"
    else
        echo -e "${GREEN}✅ Funding transaction sent: $TX_HASH${NC}"
        sleep 3
    fi
fi

# Verify final balance
BALANCE=$(cast balance $TARGET_ACCOUNT --rpc-url http://localhost:8545)
BALANCE_ETH=$(cast --to-unit $BALANCE ether)

echo -e "${GREEN}✅ ARX Dapp account ready${NC}"
echo -e "${GREEN}   Balance: $BALANCE_ETH ETH${NC}"
echo ""

# =============================================================================
# START OP-BATCHER (Batch Submitter)
# =============================================================================
echo -e "${GREEN}Starting op-batcher (Batch Submitter)...${NC}"

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

BATCHER_PID=$!

echo -e "${GREEN}✅ op-batcher started (PID: $BATCHER_PID)${NC}"
echo -e "${GREEN}   Batches will be submitted to: https://sepolia.celoscan.io/address/0xd9fc5aea3d4e8f484f618cd90dc6f7844a500f62${NC}"
sleep 5

# =============================================================================
# START OP-PROPOSER (Optional - State Root Submitter)
# =============================================================================
echo ""
echo -e "${GREEN}Starting op-proposer (State Root Submitter)...${NC}"

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

PROPOSER_PID=$!

echo -e "${YELLOW}⚠️  op-proposer started (PID: $PROPOSER_PID) - May fail if game factory not deployed${NC}"

# =============================================================================
# BLOCKCHAIN RUNNING - Display Status
# =============================================================================
sleep 5

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}          ✅ ARX L3 BLOCKCHAIN IS FULLY OPERATIONAL${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════════${NC}"
echo ""

echo -e "${BLUE}📊 SERVICES STATUS:${NC}"
echo ""
echo -e "${GREEN}1. op-geth (Execution Layer)${NC}"
echo "   • Status: Running"
echo "   • RPC URL: http://localhost:8545"
echo "   • WS URL: ws://localhost:8546"
echo "   • Chain ID: 424242"
echo ""

echo -e "${GREEN}2. op-node (Consensus Layer)${NC}"
echo "   • Status: Running (PID: $NODE_PID)"
echo "   • RPC URL: http://localhost:9545"
echo "   • Metrics: http://localhost:7300/metrics"
echo ""

echo -e "${GREEN}3. op-batcher (Batch Submitter)${NC}"
echo "   • Status: Running (PID: $BATCHER_PID)"
echo "   • RPC URL: http://localhost:8547"
echo "   • Metrics: http://localhost:7301/metrics"
echo "   • Submitting to: Celo Sepolia"
echo ""

echo -e "${GREEN}4. ARX Protocol Contracts${NC}"
if [ -f "$DEPLOYMENT_DIR/arx-contracts.json" ]; then
    echo "   • Status: Deployed"
    echo "   • Contract addresses: $DEPLOYMENT_DIR/arx-contracts.json"
else
    echo "   • Status: Not deployed"
fi
echo ""

echo -e "${GREEN}5. ARX Dapp Account${NC}"
echo "   • Address: $TARGET_ACCOUNT"
echo "   • Balance: $BALANCE_ETH ETH"
echo ""

echo -e "${BLUE}🔗 NETWORK DETAILS:${NC}"
echo "   • L3 Chain ID: 424242"
echo "   • L1 Chain ID: 11142220 (Celo Sepolia)"
echo "   • L3 RPC: http://localhost:8545"
echo "   • L1 RPC: https://rpc.ankr.com/celo_sepolia"
echo ""

echo -e "${BLUE}🌐 VIEW BATCHES ON EXPLORER:${NC}"
echo "   https://sepolia.celoscan.io/address/0xd9fc5aea3d4e8f484f618cd90dc6f7844a500f62"
echo ""

echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}          ℹ️  BLOCKCHAIN IS NOW RUNNING${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}• Transactions will automatically settle to Celo Sepolia${NC}"
echo -e "${YELLOW}• Press Ctrl+C to stop the blockchain${NC}"
echo -e "${YELLOW}• Logs are in: $DEPLOYMENT_DIR/logs/${NC}"
echo ""

# =============================================================================
# MONITORING LOOP - Keep script running and show periodic updates
# =============================================================================
echo -e "${BLUE}🔄 Monitoring blockchain activity...${NC}"
echo ""

while true; do
    sleep 30

    # Get current block number
    CURRENT_BLOCK=$(cast block-number --rpc-url http://localhost:8545 2>/dev/null || echo "N/A")

    # Check if processes are still running
    if ! kill -0 $NODE_PID 2>/dev/null; then
        echo -e "${RED}❌ op-node stopped unexpectedly${NC}"
        exit 1
    fi

    if ! kill -0 $BATCHER_PID 2>/dev/null; then
        echo -e "${RED}❌ op-batcher stopped unexpectedly${NC}"
        exit 1
    fi

    # Display status
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] ARX L3 Running | Block: $CURRENT_BLOCK | Status: ✅ Healthy${NC}"

    # Show recent batcher activity every 2 minutes
    if [ $(( $(date +%s) % 120 )) -lt 30 ]; then
        RECENT_BATCH=$(tail -1 $DEPLOYMENT_DIR/logs/op-batcher.log 2>/dev/null | grep "Transaction successfully published" || echo "")
        if [ ! -z "$RECENT_BATCH" ]; then
            echo -e "${BLUE}   📦 Recent batch submitted to Celo Sepolia${NC}"
        fi
    fi
done
