### **Phase 1: Environment Setup**

#### **Step 1: Install Prerequisites**
```bash
# Install required tools
# Go 1.21+
wget https://go.dev/dl/go1.21.0.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.0.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Node.js 16+ and pnpm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
npm install -g pnpm

# Foundry (for smart contract deployment)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Docker (for running services)
sudo apt-get update
sudo apt-get install docker.io docker-compose

# Make, jq, and other utils
sudo apt-get install make jq git
```

#### **Step 2: Clone and Setup OP Stack**
```bash
# Create workspace
mkdir ~/celo-l3-project
cd ~/celo-l3-project

# Clone OP Stack (we'll use this as base)
git clone https://github.com/ethereum-optimism/optimism.git
cd optimism

# Create a new branch for your Celo modifications
git checkout -b celo-l3-custom

# Install dependencies
pnpm install

# Build the monorepo
make build
```

#### **Step 3: Get Celo Testnet Funds**
```bash
# Create wallets for different roles
# You need 5 addresses with CELO tokens on Alfajores testnet

# Generate private keys (or use existing ones)
cast wallet new  # Run this 5 times for:
# 1. Admin wallet (contract deployer & owner)
# 2. Batcher wallet (submits transaction batches to L1)
# 3. Proposer wallet (submits state roots to L1)
# 4. Sequencer wallet (signs blocks on L2)
# 5. Challenger wallet (can challenge invalid proposals)

# Fund all wallets with Alfajores CELO from faucet:
# https://faucet.celo.org/alfajores
```

### **Phase 2: Configure for Celo**

#### **Step 4: Create Celo Deployment Configuration**
```bash
cd packages/contracts-bedrock

# Create Celo config file
cat > deploy-config/celo-alfajores.json << 'EOF'
{
  "l1ChainID": 44787,
  "l2ChainID": 424242,
  "l2BlockTime": 2,
  "l1BlockTime": 5,
  
  "maxSequencerDrift": 600,
  "sequencerWindowSize": 720,
  "channelTimeout": 60,
  "p2pSequencerAddress": "YOUR_SEQUENCER_ADDRESS",
  "batchInboxAddress": "0xff00000000000000000000000000000000424242",
  "batchSenderAddress": "YOUR_BATCHER_ADDRESS",
  
  "l2OutputOracleSubmissionInterval": 60,
  "l2OutputOracleStartingBlockNumber": 0,
  "l2OutputOracleStartingTimestamp": 0,
  "l2OutputOracleProposer": "YOUR_PROPOSER_ADDRESS",
  "l2OutputOracleChallenger": "YOUR_CHALLENGER_ADDRESS",
  
  "finalizationPeriodSeconds": 12,
  
  "proxyAdminOwner": "YOUR_ADMIN_ADDRESS",
  "finalSystemOwner": "YOUR_ADMIN_ADDRESS",
  "portalGuardian": "YOUR_ADMIN_ADDRESS",
  "controller": "YOUR_ADMIN_ADDRESS",
  
  "baseFeeVaultRecipient": "YOUR_ADMIN_ADDRESS",
  "l1FeeVaultRecipient": "YOUR_ADMIN_ADDRESS",
  "sequencerFeeVaultRecipient": "YOUR_SEQUENCER_ADDRESS",
  
  "governanceTokenSymbol": "OP",
  "governanceTokenName": "Optimism",
  "governanceTokenOwner": "YOUR_ADMIN_ADDRESS",
  
  "l2GenesisBlockGasLimit": "0x1c9c380",
  "l2GenesisBlockBaseFeePerGas": "0x3b9aca00",
  "l2GenesisRegolithTimeOffset": "0x0",
  
  "eip1559Denominator": 50,
  "eip1559DenominatorCanyon": 250,
  "eip1559Elasticity": 6,
  
  "l1StartingBlockTag": "earliest",
  
  "l1UseClob": false,
  "canyonTime": 0,
  "deltaTime": 0,
  "ecotoneTime": 0,
  "fjordTime": 0,
  
  "fundDevAccounts": true,
  "gasPriceOracleOverhead": 2100,
  "gasPriceOracleScalar": 1000000,
  
  "enableGovernance": false,
  "governanceTokenSymbol": "OP",
  "governanceTokenName": "Optimism"
}
EOF

# Replace all YOUR_*_ADDRESS placeholders with your actual addresses
nano deploy-config/celo-alfajores.json
```

#### **Step 5: Set Environment Variables**
```bash
# Create environment file
cat > .envrc.celo << 'EOF'
# Celo L1 Network
export L1_RPC_URL=https://alfajores-forno.celo-testnet.org
export L1_RPC_KIND=basic

# Private Keys (DO NOT COMMIT THESE!)
export DEPLOYER_PRIVATE_KEY=0xYOUR_ADMIN_PRIVATE_KEY
export BATCHER_PRIVATE_KEY=0xYOUR_BATCHER_PRIVATE_KEY
export PROPOSER_PRIVATE_KEY=0xYOUR_PROPOSER_PRIVATE_KEY
export SEQUENCER_PRIVATE_KEY=0xYOUR_SEQUENCER_PRIVATE_KEY

# Deployment Config
export DEPLOYMENT_CONTEXT=celo-alfajores
export IMPL_SALT=0x0000000000000000000000000000000000000000000000000000000000000001

# L2 Configuration
export L2_CHAIN_ID=424242
export L2_BLOCK_TIME=2

# Gas Configuration for Celo
export GAS_PRICE_ORACLE_OVERHEAD=2100
export GAS_PRICE_ORACLE_SCALAR=1000000
EOF

# Load environment
source .envrc.celo

# Or use direnv for auto-loading
echo "source .envrc.celo" >> ~/.bashrc
```

### **Phase 3: Deploy L1 Contracts to Celo**

#### **Step 6: Deploy Core Contracts to Celo Alfajores**
```bash
cd packages/contracts-bedrock

# Deploy contracts to Celo
forge script scripts/Deploy.s.sol:Deploy \
  --rpc-url $L1_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key YOUR_CELOSCAN_API_KEY

# This will deploy:
# - L1CrossDomainMessenger
# - L1StandardBridge  
# - L2OutputOracle
# - OptimismPortal
# - SystemConfig
# - ProxyAdmin
# And many more contracts...

# Save the deployment addresses (they'll be in deployments/ folder)
cat deployments/celo-alfajores/.deploy

# Copy addresses for later use
export L1_ADDRESSES_JSON=$(cat deployments/celo-alfajores/.deploy)
```

#### **Step 7: Generate L2 Genesis Configuration**
```bash
# Generate genesis state
forge script scripts/L2Genesis.s.sol:L2Genesis \
  --sig 'runWithStateDump()' \
  --chain-id 424242

# This creates genesis.json with:
# - Initial allocs
# - Your predeployed contracts
# - System configuration

# The genesis file will be at:
# deployments/celo-alfajores/.genesis
```

### **Phase 4: Integrate Your Custom Smart Contracts**

#### **Step 8: Add Your Custom Smart Contracts**
```bash
# Create directory for your custom contracts
mkdir -p packages/contracts-bedrock/src/custom

# Copy your custom contracts
cp -r ~/your-contracts/* packages/contracts-bedrock/src/custom/

# Example: Adding your custom logic
cat > packages/contracts-bedrock/src/custom/MyCustomLogic.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract MyCustomLogic {
    // Your custom business logic
    mapping(address => uint256) public balances;
    
    event CustomEvent(address indexed user, uint256 amount);
    
    function customFunction(uint256 amount) external {
        balances[msg.sender] += amount;
        emit CustomEvent(msg.sender, amount);
    }
}
EOF

# Add to genesis allocs
cat > scripts/DeployCustom.s.sol << 'EOF'
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "forge-std/Script.sol";
import "../src/custom/MyCustomLogic.sol";

contract DeployCustom is Script {
    function run() external {
        vm.startBroadcast();
        
        MyCustomLogic logic = new MyCustomLogic();
        console.log("MyCustomLogic deployed at:", address(logic));
        
        vm.stopBroadcast();
    }
}
EOF

# Add custom contracts to genesis
# Edit deployments/celo-alfajores/.genesis and add your contract addresses
```

### **Phase 5: Integrate Your Custom Consensus**

#### **Step 9: Modify op-node for Custom Consensus**

Now here's where it gets interesting - you mentioned you have your own consensus. Let me show you how to integrate it:

```bash
cd ../../op-node

# Create custom consensus module
mkdir -p rollup/custom-consensus

cat > rollup/custom-consensus/consensus.go << 'EOF'
package customconsensus

import (
    "context"
    "github.com/ethereum/go-ethereum/common"
    "github.com/ethereum/go-ethereum/core/types"
)

// CustomConsensus is your custom consensus implementation
type CustomConsensus interface {
    // ValidateBlock validates a block according to your rules
    ValidateBlock(ctx context.Context, block *types.Block) error
    
    // ProposeBlock creates a new block using your consensus
    ProposeBlock(ctx context.Context, txs types.Transactions) (*types.Block, error)
    
    // FinalizeBlock marks a block as finalized
    FinalizeBlock(ctx context.Context, blockHash common.Hash) error
}

// Implement your consensus logic here
type MyConsensus struct {
    // Your consensus state
    validators map[common.Address]bool
    threshold  int
}

func NewMyConsensus(validators []common.Address, threshold int) *MyConsensus {
    validatorMap := make(map[common.Address]bool)
    for _, v := range validators {
        validatorMap[v] = true
    }
    
    return &MyConsensus{
        validators: validatorMap,
        threshold:  threshold,
    }
}

func (c *MyConsensus) ValidateBlock(ctx context.Context, block *types.Block) error {
    // TODO: Implement your consensus validation
    // Example: Check signatures, verify validator set, etc.
    return nil
}

func (c *MyConsensus) ProposeBlock(ctx context.Context, txs types.Transactions) (*types.Block, error) {
    // TODO: Implement your block proposal logic
    return nil, nil
}

func (c *MyConsensus) FinalizeBlock(ctx context.Context, blockHash common.Hash) error {
    // TODO: Implement your finalization logic
    return nil
}
EOF
```

#### **Step 10: Hook Custom Consensus into Derivation Pipeline**
```bash
# Modify the driver to use your consensus
cat > rollup/driver/state_custom.go << 'EOF'
package driver

import (
    "context"
    "github.com/ethereum-optimism/optimism/op-node/rollup/custom-consensus"
)

// Add custom consensus to the sequencer
func (s *Sequencer) initCustomConsensus() error {
    // Initialize your consensus
    validators := []common.Address{
        // Your validator addresses
    }
    
    s.customConsensus = customconsensus.NewMyConsensus(validators, 2)
    return nil
}

// Override block building to use your consensus
func (s *Sequencer) createCustomBlock(ctx context.Context) error {
    // Get pending transactions
    txs := s.pending
    
    // Use your consensus to propose block
    block, err := s.customConsensus.ProposeBlock(ctx, txs)
    if err != nil {
        return err
    }
    
    // Validate with your consensus
    if err := s.customConsensus.ValidateBlock(ctx, block); err != nil {
        return err
    }
    
    // Continue with normal flow
    return s.submitBlock(block)
}
EOF

# Integrate into main driver
nano rollup/driver/sequencer.go
# Add calls to your custom consensus in the appropriate places
```

### **Phase 6: Build and Configure Services**

#### **Step 11: Build All Components**
```bash
cd ~/celo-l3-project/optimism

# Build op-geth (L2 execution layer)
cd op-geth
make geth

# Build op-node (L2 consensus layer with your custom consensus)
cd ../op-node
make op-node

# Build op-batcher (submits batches to Celo)
cd ../op-batcher
make op-batcher

# Build op-proposer (submits outputs to Celo)
cd ../op-proposer
make op-proposer

# Verify builds
ls -lh op-geth/build/bin/geth
ls -lh op-node/bin/op-node
ls -lh op-batcher/bin/op-batcher
ls -lh op-proposer/bin/op-proposer
```

#### **Step 12: Create Runtime Configuration Files**
```bash
# Create deployment directory
mkdir -p ~/celo-l3-deployment
cd ~/celo-l3-deployment

# 1. Create rollup.json (op-node config)
cat > rollup.json << 'EOF'
{
  "genesis": {
    "l1": {
      "hash": "0x...",
      "number": 0
    },
    "l2": {
      "hash": "0x...",
      "number": 0
    },
    "l2_time": 0,
    "system_config": {
      "batcherAddr": "YOUR_BATCHER_ADDRESS",
      "overhead": "0x0000000000000000000000000000000000000000000000000000000000000834",
      "scalar": "0x00000000000000000000000000000000000000000000000000000000000f4240",
      "gasLimit": 30000000
    }
  },
  "block_time": 2,
  "max_sequencer_drift": 600,
  "seq_window_size": 720,
  "channel_timeout": 60,
  "l1_chain_id": 44787,
  "l2_chain_id": 424242,
  "regolith_time": 0,
  "canyon_time": 0,
  "delta_time": 0,
  "ecotone_time": 0,
  "fjord_time": 0,
  "batch_inbox_address": "0xff00000000000000000000000000000000424242",
  "deposit_contract_address": "YOUR_OPTIMISM_PORTAL_ADDRESS",
  "l1_system_config_address": "YOUR_SYSTEM_CONFIG_ADDRESS"
}
EOF

# 2. Create genesis.json (from deployment)
cp ~/celo-l3-project/optimism/packages/contracts-bedrock/deployments/celo-alfajores/.genesis ./genesis.json

# 3. Extract addresses from deployment
cat > addresses.json << 'EOF'
{
  "AddressManager": "0x...",
  "L1CrossDomainMessengerProxy": "0x...",
  "L1StandardBridgeProxy": "0x...",
  "L2OutputOracleProxy": "0x...",
  "OptimismPortalProxy": "0x...",
  "SystemConfigProxy": "0x..."
}
EOF
# Fill in actual addresses from your deployment
```

### **Phase 7: Initialize and Start Your L3**

#### **Step 13: Initialize op-geth with Genesis**
```bash
# Initialize the L2 execution client
~/celo-l3-project/optimism/op-geth/build/bin/geth init \
  --datadir=./geth-data \
  ./genesis.json

# Create JWT secret for authentication between op-geth and op-node
openssl rand -hex 32 > jwt-secret.txt
```

#### **Step 14: Start op-geth (L2 Execution Layer)**
```bash
# Create startup script
cat > start-geth.sh << 'EOF'
#!/bin/bash

~/celo-l3-project/optimism/op-geth/build/bin/geth \
  --datadir=./geth-data \
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
  --authrpc.jwtsecret=./jwt-secret.txt \
  --authrpc.vhosts="*" \
  --syncmode=full \
  --maxpeers=0 \
  --networkid=424242 \
  --nodiscover \
  --rollup.disabletxpoolgossip \
  --rollup.sequencerhttp=http://localhost:8545
EOF

chmod +x start-geth.sh

# Start op-geth in background
./start-geth.sh > geth.log 2>&1 &

# Check if it's running
tail -f geth.log
```

#### **Step 15: Start op-node (L2 Consensus with Your Custom Logic)**
```bash
cat > start-node.sh << 'EOF'
#!/bin/bash

~/celo-l3-project/optimism/op-node/bin/op-node \
  --l1=https://alfajores-forno.celo-testnet.org \
  --l1.beacon=https://alfajores-forno.celo-testnet.org \
  --l2=http://localhost:8551 \
  --l2.jwt-secret=./jwt-secret.txt \
  --rollup.config=./rollup.json \
  --rpc.addr=0.0.0.0 \
  --rpc.port=9545 \
  --p2p.disable \
  --p2p.sequencer.key=$SEQUENCER_PRIVATE_KEY \
  --sequencer.enabled \
  --sequencer.l1-confs=0 \
  --verifier.l1-confs=0
EOF

chmod +x start-node.sh

# Start op-node
./start-node.sh > node.log 2>&1 &

# Monitor
tail -f node.log
```

#### **Step 16: Start op-batcher (Submits to Celo)**
```bash
cat > start-batcher.sh << 'EOF'
#!/bin/bash

~/celo-l3-project/optimism/op-batcher/bin/op-batcher \
  --l1-eth-rpc=https://alfajores-forno.celo-testnet.org \
  --l2-eth-rpc=http://localhost:8545 \
  --rollup-rpc=http://localhost:9545 \
  --poll-interval=1s \
  --sub-safety-margin=10 \
  --num-confirmations=1 \
  --safe-abort-nonce-too-low-count=3 \
  --resubmission-timeout=30s \
  --private-key=$BATCHER_PRIVATE_KEY \
  --max-channel-duration=1 \
  --max-l1-tx-size-bytes=120000 \
  --target-l1-tx-size-bytes=100000 \
  --target-num-frames=1
EOF

chmod +x start-batcher.sh

# Start batcher
./start-batcher.sh > batcher.log 2>&1 &

# Monitor
tail -f batcher.log
```

#### **Step 17: Start op-proposer (Submits State Roots to Celo)**
```bash
cat > start-proposer.sh << 'EOF'
#!/bin/bash

~/celo-l3-project/optimism/op-proposer/bin/op-proposer \
  --l1-eth-rpc=https://alfajores-forno.celo-testnet.org \
  --rollup-rpc=http://localhost:9545 \
  --l2oo-address=$(jq -r '.L2OutputOracleProxy' addresses.json) \
  --poll-interval=12s \
  --private-key=$PROPOSER_PRIVATE_KEY \
  --allow-non-finalized
EOF

chmod +x start-proposer.sh

# Start proposer
./start-proposer.sh > proposer.log 2>&1 &

# Monitor
tail -f proposer.log
```

### **Phase 8: Deploy Your Apps**

#### **Step 18: Deploy Your Custom Smart Contracts to L3**
```bash
# Your L3 is now running! Deploy your apps

# Connect to your L3
export L3_RPC=http://localhost:8545

# Deploy your contracts
cd ~/your-contracts-project

# Using Foundry
forge create \
  --rpc-url $L3_RPC \
  --private-key $DEPLOYER_PRIVATE_KEY \
  src/MyCustomLogic.sol:MyCustomLogic

# Or using Hardhat
npx hardhat run scripts/deploy.js --network celo-l3

# Save deployed addresses
echo "MyCustomLogic: 0x..." > deployed-contracts.txt
```

#### **Step 19: Test Your L3**
```bash
# Send a test transaction
cast send \
  --rpc-url $L3_RPC \
  --private-key $DEPLOYER_PRIVATE_KEY \
  0xYOUR_CONTRACT_ADDRESS \
  "customFunction(uint256)" \
  100

# Check balance
cast call \
  --rpc-url $L3_RPC \
  0xYOUR_CONTRACT_ADDRESS \
  "balances(address)(uint256)" \
  0xYOUR_ADDRESS

# Monitor L3 blocks
cast block latest --rpc-url $L3_RPC

# Check if transactions are being batched to Celo
cast logs \
  --rpc-url https://alfajores-forno.celo-testnet.org \
  --address 0xff00000000000000000000000000000000424242 \
  --from-block latest
```

### **Phase 9: Set Up Monitoring and Management**

#### **Step 20: Create Monitoring Dashboard**
```bash
# Install monitoring tools
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  prometheus:
    image: prom/prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    ports:
      - "9090:9090"

  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin

  # Op-node metrics
  node_exporter:
    image: prom/node-exporter
    ports:
      - "9100:9100"
EOF

# Create prometheus config
cat > prometheus.yml << 'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'op-node'
    static_configs:
      - targets: ['localhost:7300']
  
  - job_name: 'op-geth'
    static_configs:
      - targets: ['localhost:6060']
EOF

# Start monitoring
docker-compose up -d

# Access Grafana at http://localhost:3000
```

#### **Step 21: Create Management Scripts**
```bash
# Stop all services
cat > stop-all.sh << 'EOF'
#!/bin/bash
pkill -f op-geth
pkill -f op-node
pkill -f op-batcher
pkill -f op-proposer
EOF

# Start all services
cat > start-all.sh << 'EOF'
#!/bin/bash
./start-geth.sh &
sleep 10
./start-node.sh &
sleep 5
./start-batcher.sh &
./start-proposer.sh &
EOF

# Check status
cat > status.sh << 'EOF'
#!/bin/bash
echo "=== Op-Geth Status ==="
curl -s -X POST -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
  http://localhost:8545 | jq

echo "=== Op-Node Status ==="
curl -s http://localhost:9545/healthz

echo "=== Latest L1 Batch ==="
cast logs --rpc-url https://alfajores-forno.celo-testnet.org \
  --address 0xff00000000000000000000000000000000424242 \
  --from-block latest | head -n 5
EOF

chmod +x *.sh
```

### **Phase 10: Testing Your Complete Stack**

#### **Step 22: End-to-End Test**
```bash
# Create test script
cat > test-l3.sh << 'EOF'
#!/bin/bash

L3_RPC=http://localhost:8545
CELO_RPC=https://alfajores-forno.celo-testnet.org

echo "1. Testing L3 is producing blocks..."
BLOCK=$(cast block-number --rpc-url $L3_RPC)
echo "Current L3 block: $BLOCK"
sleep 5
NEW_BLOCK=$(cast block-number --rpc-url $L3_RPC)
echo "New L3 block: $NEW_BLOCK"

if [ $NEW_BLOCK -gt $BLOCK ]; then
  echo "✅ L3 is producing blocks"
else
  echo "❌ L3 is NOT producing blocks"
  exit 1
fi

echo ""
echo "2. Testing transaction submission..."
TX_HASH=$(cast send \
  --rpc-url $L3_RPC \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --value 0.01ether \
  0x0000000000000000000000000000000000000000 \
  | grep "transactionHash" | awk '{print $2}')

echo "Transaction submitted: $TX_HASH"

echo ""
echo "3. Waiting for transaction confirmation..."
sleep 5
RECEIPT=$(cast receipt $TX_HASH --rpc-url $L3_RPC)
echo "✅ Transaction confirmed"

echo ""
echo "4. Checking if batches are submitted to Celo..."
sleep 60  # Wait for batcher
CELO_LOGS=$(cast logs \
  --rpc-url $CELO_RPC \
  --address 0xff00000000000000000000000000000000424242 \
  --from-block latest)

if [ ! -z "$CELO_LOGS" ]; then
  echo "✅ Batches are being submitted to Celo"
else
  echo "⚠️  No recent batches found on Celo (may need to wait longer)"
fi

echo ""
echo "5. Checking output proposals..."
L2OO_ADDRESS=$(jq -r '.L2OutputOracleProxy' addresses.json)
LATEST_OUTPUT=$(cast call \
  --rpc-url $CELO_RPC \
  $L2OO_ADDRESS \
  "latestOutputIndex()(uint256)")

echo "Latest output index: $LATEST_OUTPUT"
echo "✅ Proposer is submitting outputs"

echo ""
echo "=== Test Summary ==="
echo "✅ All components are working!"
EOF

chmod +x test-l3.sh
./test-l3.sh
```

### **Phase 11: Production Considerations**

#### **Step 23: Secure Your Setup**
```bash
# 1. Never expose private keys
# Move to secure key management
export PRIVATE_KEY_FILE=/secure/path/to/keys

# 2. Set up firewall
sudo ufw allow 8545  # L3 RPC
sudo ufw allow 9545  # Op-node RPC
sudo ufw deny 8551   # Auth RPC (internal only)

# 3. Use reverse proxy with rate limiting
# Install nginx
sudo apt install nginx

cat > /etc/nginx/sites-available/l3-rpc << 'EOF'
server {
    listen 80;
    server_name your-l3-domain.com;

    location / {
        proxy_pass http://localhost:8545;
        limit_req zone=rpc_limit burst=20;
    }
}
EOF
```

#### **Step 24: Set Up Backups**
```bash
# Create backup script
cat > backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backup/l3-$(date +%Y%m%d)"
mkdir -p $BACKUP_DIR

# Backup geth data
tar -czf $BACKUP_DIR/geth-data.tar.gz ./geth-data

# Backup configs
cp rollup.json genesis.json addresses.json $BACKUP_DIR/

# Backup to cloud (optional)
# aws s3 sync $BACKUP_DIR s3://your-backup-bucket/
EOF

# Schedule daily backups
crontab -e
# Add: 0 2 * * * /path/to/backup.sh
```

### **Phase 12: Moving to Mainnet**

#### **Step 25: Deploy to Celo Mainnet**
```bash
# Update configs for mainnet
sed -i 's/44787/42220/g' deploy-config/celo-mainnet.json
sed -i 's/alfajores-forno/forno/g' .envrc.celo

# Update RPC URLs
export L1_RPC_URL=https://forno.celo.org

# Deploy to mainnet (with more CELO in accounts!)
cd packages/contracts-bedrock
forge script scripts/Deploy.s.sol:Deploy \
  --rpc-url $L1_RPC_URL \
  --private-key $DEPLOYER_PRIVATE_KEY \
  --broadcast \
  --verify

# Update all configs with mainnet addresses
# Restart all services pointing to mainnet
```

---

## **Quick Reference: Key Files and Ports**

```
Ports:
- 8545: L3 RPC (public)
- 8546: L3 WebSocket (public)
- 8551: Auth RPC (internal)
- 9545: Op-node RPC (internal)
- 3000: Grafana (monitoring)
- 9090: Prometheus (monitoring)

