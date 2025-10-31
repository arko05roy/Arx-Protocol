#!/bin/bash
set -euo pipefail

# Configuration
PRIVATE_KEY="9ef01f9bd02e2ee682be5c50c189720a37773ab58b5b031ebdb8489940cd01ad"
L1_RPC="https://forno.celo-sepolia.celo-testnet.org"
L1_CHAIN_ID="11142220"
OP_ROOT="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism"
DEPLOY_CFG="$OP_ROOT/packages/contracts-bedrock/deploy-config/celo-sepolia.json"
L2_DIR="/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment"

echo "==== Deploying L1 Contracts on Celo Sepolia ===="
echo "Chain ID: $L1_CHAIN_ID"
echo "RPC: $L1_RPC"

# Check if op-deployer exists
if [ ! -f "$OP_ROOT/op-deployer/bin/op-deployer" ]; then
  echo "Building op-deployer..."
  (cd "$OP_ROOT/op-deployer" && just op-deployer)
fi

# Create deployment directory
mkdir -p "$L2_DIR/l1-deployments"

# Run op-deployer to deploy contracts
echo "Running op-deployer..."
"$OP_ROOT/op-deployer/bin/op-deployer" apply \
  --deploy-config "$DEPLOY_CFG" \
  --l1-rpc "$L1_RPC" \
  --private-key "$PRIVATE_KEY" \
  --outfile "$L2_DIR/l1-deployments/11142220-deploy.json" \
  --wait-for-receipts

echo "✅ L1 Contracts deployed!"
echo "Deployment file: $L2_DIR/l1-deployments/11142220-deploy.json"

# Extract game factory address
GAME_FACTORY=$(jq -r '.DisputeGameFactoryProxy // .DisputeGameFactory // empty' "$L2_DIR/l1-deployments/11142220-deploy.json" 2>/dev/null || echo "")

if [ -z "$GAME_FACTORY" ]; then
  echo "⚠️  Could not extract game factory address from deployment"
  echo "Deployment addresses:"
  jq 'keys' "$L2_DIR/l1-deployments/11142220-deploy.json"
else
  echo "Game Factory Address: $GAME_FACTORY"
fi

