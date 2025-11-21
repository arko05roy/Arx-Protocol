# OP Stack on Celo Mainnet - Implementation Plan

## Critical Understanding

**OPTIMISM STACK DOES NOT SUPPORT CELO BY DEFAULT**

Optimism natively supports only:
- Ethereum Mainnet
- Ethereum Sepolia
- Ethereum Holesky

Your current deployment on Celo Sepolia required custom modifications to make it work. This document outlines what needs to change to run on Celo Mainnet.

---

## Goal

Deploy a simple, single-sequencer OP Stack rollup that settles to **Celo Mainnet (Chain ID: 42220)**.

---

## Architecture Overview

```
┌─────────────────────────────────────────────────┐
│          L2 (Your Rollup - Chain ID: 424242)     │
│                                                   │
│  Components:                                      │
│  - op-geth (execution layer)                     │
│  - op-node (consensus/derivation)                │
│  - op-batcher (posts to L1)                      │
│  - op-proposer (submits state roots)             │
└─────────────────────┬───────────────────────────┘
                      │
                      │ Settlement
                      ▼
┌─────────────────────────────────────────────────┐
│         L1 (Celo Mainnet - Chain ID: 42220)      │
│                                                   │
│  - OptimismPortal (withdrawals)                  │
│  - SystemConfig (rollup config)                  │
│  - L1StandardBridge (asset bridge)               │
│  - BatchInbox (receives transaction batches)     │
└─────────────────────────────────────────────────┘
```

---

## Phase 1: Configuration Files for Celo Mainnet

### 1.1 Create `.envrc.celo-mainnet`

```bash
# Celo Mainnet L1 Configuration
export L1_RPC_URL=https://forno.celo.org
# Backup: https://rpc.ankr.com/celo

export L1_RPC_KIND=basic
export L1_CHAIN_ID=42220  # Celo Mainnet

# L2 Configuration
export L2_CHAIN_ID=424242  # Your L2 chain ID
export L2_RPC_URL=http://localhost:8545

# Deployment Wallets (use your actual private keys)
export DEPLOYER_PRIVATE_KEY="your-deployer-key"
export BATCHER_PRIVATE_KEY="your-batcher-key"
export PROPOSER_PRIVATE_KEY="your-proposer-key"
export SEQUENCER_PRIVATE_KEY="your-sequencer-key"

# Wallet Addresses
export BATCHER_ADDRESS="0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62"
export PROPOSER_ADDRESS="0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47"
export SEQUENCER_ADDRESS="0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49"
export FINAL_SYSTEM_OWNER="0x89a26a33747b293430D4269A59525d5D0D5BbE65"
```

**Location**: `/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/.envrc.celo-mainnet`

---

### 1.2 Create `celo-mainnet.json` Deployment Config

```json
{
  "l1ChainID": 42220,
  "l2ChainID": 424242,
  "l1BlockTime": 5,
  "l2BlockTime": 2,
  "maxSequencerDrift": 600,
  "sequencerWindowSize": 3600,
  "channelTimeout": 300,
  "finalSystemOwner": "0x89a26a33747b293430D4269A59525d5D0D5BbE65",
  "batchSenderAddress": "0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62",
  "p2pSequencerAddress": "0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49",
  "batchInboxAddress": "0xff00000000000000000000000000000000424242",
  "l2OutputOracleSubmissionInterval": 120,
  "l2OutputOracleStartingTimestamp": 0,
  "l2OutputOracleProposer": "0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47",
  "l2OutputOracleChallenger": "0x89a26a33747b293430D4269A59525d5D0D5BbE65",
  "l2BlockGasLimit": 30000000,
  "l1BlockGasLimit": 30000000,
  "baseFeeVaultRecipient": "0x89a26a33747b293430D4269A59525d5D0D5BbE65",
  "l1FeeVaultRecipient": "0x89a26a33747b293430D4269A59525d5D0D5BbE65",
  "sequencerFeeVaultRecipient": "0x89a26a33747b293430D4269A59525d5D0D5BbE65",
  "governanceTokenSymbol": "ARX",
  "governanceTokenName": "Arx Token",
  "governanceTokenOwner": "0x89a26a33747b293430D4269A59525d5D0D5BbE65",
  "l2GenesisBlockGasLimit": "0x1c9c380",
  "gasPriceOracleOverhead": 2100,
  "gasPriceOracleScalar": 1000000,
  "enableGovernance": false,
  "eip1559Denominator": 50,
  "eip1559DenominatorCanyon": 250,
  "eip1559Elasticity": 6,
  "systemConfigStartBlock": 0,
  "requiredProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "recommendedProtocolVersion": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "faultGameAbsolutePrestate": "0x03c7ae758795765c6664a5d39bf63841c71ff191e9189522bad8ebff5d4eca98",
  "faultGameMaxDepth": 73,
  "faultGameClockExtension": 0,
  "faultGameMaxClockDuration": 1200,
  "faultGameGenesisBlock": 0,
  "faultGameGenesisOutputRoot": "0x0000000000000000000000000000000000000000000000000000000000000000",
  "faultGameSplitDepth": 30,
  "faultGameWithdrawalDelay": 604800,
  "preimageOracleMinProposalSize": 126000,
  "preimageOracleChallengePeriod": 86400,
  "proofMaturityDelaySeconds": 604800,
  "disputeGameFinalityDelaySeconds": 302400,
  "respectedGameType": 0,
  "useFaultProofs": true
}
```

**Location**: `/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/packages/contracts-bedrock/deploy-config/celo-mainnet.json`

---

### 1.3 Update `intent.toml` for Celo Mainnet

```toml
configType = "standard"
l1ChainID = 42220  # Celo Mainnet

# IMPORTANT: Need to verify if OPCM is deployed on Celo Mainnet
# If not deployed, this will need to be deployed first
# For Celo Sepolia it was: 0x3bb6437aba031afbf9cb3538fa064161e2bf2d78
opcmAddress = "TBD_CHECK_CELO_MAINNET"

fundDevAccounts = false
l1ContractsLocator = "embedded"
l2ContractsLocator = "embedded"

[[chains]]
  # L2 Chain ID in hex format
  id = "0x0000000000000000000000000000000000000000000000000000000000067932"

  # Deployment addresses
  batcher = "0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62"
  proposer = "0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47"
  unsafeBlockSigner = "0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49"

  # System owner
  finalSystemOwner = "0x89a26a33747b293430D4269A59525d5D0D5BbE65"
```

**Location**: `/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/intent.toml`

**CRITICAL NOTE**: Check if OPCM (OP Contracts Manager) is deployed on Celo Mainnet. If not, you may need to deploy it first or use an alternative deployment method.

---

### 1.4 Create `celo-mainnet-config.json`

```json
{
  "l1ChainID": 42220,
  "l2ChainID": 424242,
  "finalSystemOwner": "0x89a26a33747b293430D4269A59525d5D0D5BbE65",
  "batchSenderAddress": "0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62",
  "p2pSequencerAddress": "0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49"
}
```

**Location**: `/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/celo-mainnet-config.json`

---

## Phase 2: Wallet Preparation

### 2.1 Fund Deployment Wallets

**Required CELO amounts (estimates):**

1. **Deployer Wallet**: 50-100 CELO
   - Will deploy ~24 smart contracts to Celo Mainnet
   - One-time cost

2. **Batcher Wallet** (`0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62`): 100+ CELO
   - Posts transaction batches to L1 continuously
   - Ongoing operational cost
   - Monitor and refill regularly

3. **Proposer Wallet** (`0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47`): 50+ CELO
   - Submits state roots to L1 every ~2 minutes
   - Ongoing operational cost
   - Monitor and refill regularly

4. **Sequencer Wallet**: 0 CELO (only signs L2 blocks, no L1 txs)

### 2.2 Verify Wallets Have Correct Private Keys

Ensure you have private keys for all four addresses in your `.envrc.celo-mainnet` file.

---

## Phase 3: Deploy L1 Contracts to Celo Mainnet

### 3.1 Update Deployment Script

**File**: `l2-deployment/deploy-l1-contracts.sh`

```bash
#!/bin/bash
set -euo pipefail

# Load environment
source .envrc.celo-mainnet

# Paths
OP_ROOT="$(pwd)/optimism/optimism"
L2_DIR="$(pwd)/l2-deployment"
DEPLOY_CFG="$OP_ROOT/packages/contracts-bedrock/deploy-config/celo-mainnet.json"

# Verify configuration exists
if [ ! -f "$DEPLOY_CFG" ]; then
  echo "Error: Deploy config not found at $DEPLOY_CFG"
  exit 1
fi

# Deploy using op-deployer
echo "Deploying L1 contracts to Celo Mainnet..."
"$OP_ROOT/op-deployer/bin/op-deployer" apply \
  --deploy-config "$DEPLOY_CFG" \
  --l1-rpc "$L1_RPC_URL" \
  --private-key "$DEPLOYER_PRIVATE_KEY" \
  --outfile "$L2_DIR/l1-deployments/42220-deploy.json" \
  --wait-for-receipts

echo "Deployment complete!"
echo "Addresses saved to: $L2_DIR/l1-deployments/42220-deploy.json"
```

### 3.2 Run Deployment

```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx
source .envrc.celo-mainnet
./l2-deployment/deploy-l1-contracts.sh
```

**Expected output**: JSON file with all deployed contract addresses.

### 3.3 Contracts That Will Be Deployed

1. **OptimismPortalProxy** - Main entry/exit for deposits/withdrawals
2. **SystemConfigProxy** - Rollup configuration storage
3. **L1CrossDomainMessengerProxy** - Message passing
4. **L1StandardBridgeProxy** - Asset bridge
5. **DisputeGameFactoryProxy** - Fault proof system
6. **AnchorStateRegistryProxy** - State anchoring
7. **DelayedWETHProxy** - Wrapped ETH with delay
8. **PermissionedDisputeGame** - Dispute resolution
9. **PreimageOracle** - Fault proof data
10. **MIPS** - VM for fault proofs
11. **DataAvailabilityChallenge** - Data availability
12. Plus 13 more supporting contracts

**Total**: ~24 contracts deployed to Celo Mainnet

---

## Phase 4: Generate L2 Genesis

### 4.1 Create Genesis Generation Script

**File**: `l2-deployment/generate-genesis-mainnet.sh`

```bash
#!/bin/bash
set -euo pipefail

source .envrc.celo-mainnet

OP_ROOT="$(pwd)/optimism/optimism"
L2_DIR="$(pwd)/l2-deployment"
DEPLOY_JSON="$L2_DIR/l1-deployments/42220-deploy.json"

# Generate L2 genesis
echo "Generating L2 genesis configuration..."

"$OP_ROOT/op-node/bin/op-node" genesis l2 \
  --deploy-config "$OP_ROOT/packages/contracts-bedrock/deploy-config/celo-mainnet.json" \
  --l1-deployments "$DEPLOY_JSON" \
  --outfile.l2 "$L2_DIR/genesis-mainnet.json" \
  --outfile.rollup "$L2_DIR/rollup-mainnet.json"

echo "Genesis generated:"
echo "  - L2 Genesis: $L2_DIR/genesis-mainnet.json"
echo "  - Rollup Config: $L2_DIR/rollup-mainnet.json"
```

### 4.2 Run Genesis Generation

```bash
./l2-deployment/generate-genesis-mainnet.sh
```

**Output files**:
- `genesis-mainnet.json` - L2 chain genesis (for op-geth)
- `rollup-mainnet.json` - Rollup configuration (for op-node)

---

## Phase 5: Configure Services for Celo Mainnet

### 5.1 op-node Configuration

**File**: `l2-deployment/op-node-mainnet.env`

```bash
# L1 Connection
OP_NODE_L1_ETH_RPC=https://forno.celo.org
OP_NODE_L1_BEACON=
OP_NODE_L1_KIND=basic

# L2 Connection
OP_NODE_L2_ENGINE_RPC=http://localhost:8551
OP_NODE_L2_ENGINE_AUTH=/path/to/jwt.hex

# Rollup Configuration
OP_NODE_ROLLUP_CONFIG=/path/to/l2-deployment/rollup-mainnet.json
OP_NODE_NETWORK=celo-mainnet
OP_NODE_L2_ENGINE_KIND=geth

# RPC
OP_NODE_RPC_ADDR=0.0.0.0
OP_NODE_RPC_PORT=9545

# Metrics
OP_NODE_METRICS_ENABLED=true
OP_NODE_METRICS_ADDR=0.0.0.0
OP_NODE_METRICS_PORT=7300

# P2P (disabled for single sequencer)
OP_NODE_P2P_DISABLE=true

# Sequencer (enable if this node is the sequencer)
OP_NODE_SEQUENCER_ENABLED=true
OP_NODE_SEQUENCER_L1_CONFS=4
```

---

### 5.2 op-batcher Configuration

**File**: `l2-deployment/op-batcher-mainnet.env`

```bash
# L1 Connection
OP_BATCHER_L1_ETH_RPC=https://forno.celo.org
OP_BATCHER_PRIVATE_KEY=<batcher-private-key>

# L2 Connection
OP_BATCHER_L2_ETH_RPC=http://localhost:8545
OP_BATCHER_ROLLUP_RPC=http://localhost:9545

# Batch Submission
OP_BATCHER_MAX_CHANNEL_DURATION=1
OP_BATCHER_SUB_SAFETY_MARGIN=4
OP_BATCHER_POLL_INTERVAL=1s
OP_BATCHER_NUM_CONFIRMATIONS=4
OP_BATCHER_SAFE_ABORT_NONCE_TOO_LOW_COUNT=3
OP_BATCHER_RESUBMISSION_TIMEOUT=30s

# Data Availability
OP_BATCHER_DATA_AVAILABILITY_TYPE=calldata

# Metrics
OP_BATCHER_METRICS_ENABLED=true
OP_BATCHER_METRICS_ADDR=0.0.0.0
OP_BATCHER_METRICS_PORT=7301
```

**IMPORTANT**: Use `calldata` for data availability (not blobs) to ensure Celo compatibility.

---

### 5.3 op-proposer Configuration

**File**: `l2-deployment/op-proposer-mainnet.env`

```bash
# L1 Connection
OP_PROPOSER_L1_ETH_RPC=https://forno.celo.org
OP_PROPOSER_PRIVATE_KEY=<proposer-private-key>

# L2 Connection
OP_PROPOSER_ROLLUP_RPC=http://localhost:9545

# Proposal Settings
OP_PROPOSER_POLL_INTERVAL=12s
OP_PROPOSER_NUM_CONFIRMATIONS=4
OP_PROPOSER_SAFE_ABORT_NONCE_TOO_LOW_COUNT=3
OP_PROPOSER_RESUBMISSION_TIMEOUT=30s

# Game Settings
OP_PROPOSER_PROPOSAL_INTERVAL=120s
OP_PROPOSER_DISPUTE_GAME_TYPE=0
OP_PROPOSER_ALLOW_NON_FINALIZED=false

# Metrics
OP_PROPOSER_METRICS_ENABLED=true
OP_PROPOSER_METRICS_ADDR=0.0.0.0
OP_PROPOSER_METRICS_PORT=7302
```

---

### 5.4 op-geth Startup Script

**File**: `l2-deployment/start-geth-mainnet.sh`

```bash
#!/bin/bash
set -euo pipefail

source .envrc.celo-mainnet

DATADIR="./l2-data-mainnet"
JWT_SECRET="./jwt.hex"
GENESIS="./l2-deployment/genesis-mainnet.json"

# Initialize if needed
if [ ! -d "$DATADIR/geth" ]; then
  echo "Initializing op-geth with genesis..."
  geth init --datadir="$DATADIR" "$GENESIS"
fi

# Start op-geth
echo "Starting op-geth..."
geth \
  --datadir="$DATADIR" \
  --http \
  --http.addr=0.0.0.0 \
  --http.port=8545 \
  --http.api=eth,net,web3,debug,txpool \
  --http.corsdomain="*" \
  --http.vhosts="*" \
  --ws \
  --ws.addr=0.0.0.0 \
  --ws.port=8546 \
  --ws.api=eth,net,web3,debug,txpool \
  --ws.origins="*" \
  --authrpc.addr=0.0.0.0 \
  --authrpc.port=8551 \
  --authrpc.vhosts="*" \
  --authrpc.jwtsecret="$JWT_SECRET" \
  --syncmode=full \
  --gcmode=archive \
  --maxpeers=0 \
  --nodiscover \
  --rollup.disabletxpoolgossip \
  --rollup.sequencerhttp=http://localhost:9545 \
  --networkid=$L2_CHAIN_ID
```

---

## Phase 6: Start Services

### 6.1 Service Startup Order

```bash
# 1. Start op-geth
./l2-deployment/start-geth-mainnet.sh

# 2. Start op-node (in separate terminal)
op-node --env-file=./l2-deployment/op-node-mainnet.env

# 3. Start op-batcher (in separate terminal)
op-batcher --env-file=./l2-deployment/op-batcher-mainnet.env

# 4. Start op-proposer (in separate terminal)
op-proposer --env-file=./l2-deployment/op-proposer-mainnet.env
```

### 6.2 Verify Services Are Running

```bash
# Check op-geth
curl -X POST http://localhost:8545 -H "Content-Type: application/json" \
  --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'

# Check op-node
curl http://localhost:9545/healthz

# Check metrics
curl http://localhost:7300/metrics  # op-node
curl http://localhost:7301/metrics  # op-batcher
curl http://localhost:7302/metrics  # op-proposer
```

---

## Phase 7: Validation & Testing

### 7.1 Check L2 Block Production

```bash
# Watch blocks being produced
watch -n 2 'curl -s -X POST http://localhost:8545 \
  -H "Content-Type: application/json" \
  --data '"'"'{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}'"'"' \
  | jq'
```

**Expected**: Block number increasing every 2 seconds

### 7.2 Check L1 Batch Submission

Monitor batcher logs for:
```
"publishing transaction"
"transaction confirmed"
"batch submitted"
```

Check batcher wallet on Celo Mainnet explorer:
- https://celoscan.io/address/0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62

### 7.3 Check L1 State Root Proposals

Monitor proposer logs for:
```
"proposing output root"
"state root published"
```

Check proposer wallet on Celo Mainnet explorer:
- https://celoscan.io/address/0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47

### 7.4 Test Deposit (L1 → L2)

```javascript
// Using ethers.js
const OptimismPortal = new ethers.Contract(
  OPTIMISM_PORTAL_ADDRESS,
  OptimismPortalABI,
  l1Signer
);

// Deposit 1 CELO to L2
await OptimismPortal.depositTransaction(
  l2RecipientAddress,
  ethers.utils.parseEther("1"),
  100000, // gas limit
  false,  // isCreation
  "0x"    // data
);
```

Check L2 wallet receives funds after ~2-3 minutes.

---

## Key Differences from Standard OP Stack

### 1. L1 Chain ID
- **Standard OP Stack**: 1 (Ethereum), 11155111 (Sepolia), 17000 (Holesky)
- **Your Setup**: 42220 (Celo Mainnet)

### 2. L1 RPC Endpoints
- **Standard**: Ethereum nodes
- **Your Setup**: Celo nodes (forno.celo.org)

### 3. L1 Block Time
- **Ethereum**: 12 seconds
- **Celo**: 5 seconds
- **Impact**: Faster finality on L1

### 4. Gas Token
- **Ethereum**: ETH
- **Celo**: CELO
- **Impact**: All L1 transactions paid in CELO

### 5. Data Availability
- **Standard**: Can use EIP-4844 blobs on Ethereum
- **Your Setup**: MUST use calldata (Celo may not support blobs)

---

## Monitoring & Operations

### Monitor These Metrics

1. **Batcher Wallet Balance**
   - Check daily
   - Refill before it runs out
   - Cost: ~5-20 CELO per day (depends on L2 activity)

2. **Proposer Wallet Balance**
   - Check weekly
   - Cost: ~1-5 CELO per day

3. **Service Health**
   - All 4 services should be running
   - Check logs for errors
   - Monitor metrics endpoints

4. **L1 Transaction Success Rate**
   - Batcher transactions should succeed >99%
   - Proposer transactions should succeed >99%
   - If failures increase, check RPC health

### Common Issues

**Issue**: Batcher transactions failing
- **Cause**: Insufficient CELO balance or gas price too low
- **Fix**: Fund wallet or increase gas price

**Issue**: op-node not syncing
- **Cause**: L1 RPC connection issues
- **Fix**: Switch to backup RPC or check Celo node status

**Issue**: No blocks being produced
- **Cause**: op-geth not connected to op-node
- **Fix**: Check JWT secret matches, verify Engine API connection

---

## Estimated Costs

### One-Time Deployment
- Contract deployment: 50-100 CELO (~$50-100 USD at current prices)

### Ongoing Operational Costs (per month)
- Batcher: 150-600 CELO/month (~$150-600 USD)
- Proposer: 30-150 CELO/month (~$30-150 USD)
- **Total**: ~$200-800 USD/month depending on L2 transaction volume

**Cost Optimization**:
- Increase batch submission interval (reduce frequency)
- Increase state root proposal interval
- Use compression more aggressively

---

## Rollback Plan

If deployment fails or issues arise:

1. **Keep Sepolia deployment running** (no changes made to it)
2. **Test independently** on mainnet
3. **No risk** to existing setup
4. **Can redeploy** contracts if needed (just costs gas)

---

## Critical Prerequisites

### Before Starting Deployment

- [ ] Verify you have 200+ CELO across all wallets
- [ ] Verify private keys for all 4 addresses
- [ ] Test Celo Mainnet RPC connectivity
- [ ] Check if OPCM is deployed on Celo Mainnet (for intent.toml)
- [ ] Backup current Sepolia configuration
- [ ] Ensure op-deployer binary exists and works

### Required Tools

- [ ] op-deployer (in `optimism/optimism/op-deployer/bin/`)
- [ ] op-node (in `optimism/optimism/op-node/bin/`)
- [ ] op-batcher (in `optimism/optimism/op-batcher/bin/`)
- [ ] op-proposer (in `optimism/optimism/op-proposer/bin/`)
- [ ] geth (op-geth)

---

## Summary of Changes from Sepolia to Mainnet

| Component | Sepolia | Mainnet |
|-----------|---------|---------|
| L1 Chain ID | 11142220 | 42220 |
| L1 RPC | https://rpc.ankr.com/celo_sepolia | https://forno.celo.org |
| L2 Chain ID | 424242 | 424242 (same) |
| Deploy Config | celo-sepolia.json | celo-mainnet.json |
| Contract Addresses | All new deployment | All new deployment |
| Data Directory | l2-data | l2-data-mainnet |
| Genesis File | genesis.json | genesis-mainnet.json |
| Rollup Config | rollup.json | rollup-mainnet.json |

---

## Next Steps After Reading This Document

1. Review all configuration files
2. Verify wallet balances and private keys
3. Update all paths and variables to match your system
4. Run through checklist of prerequisites
5. Start with Phase 1 (configuration files)
6. Proceed phase by phase
7. Test thoroughly after each phase

---

## Support & Debugging

### Logs to Check

```bash
# op-geth logs
tail -f l2-data-mainnet/geth.log

# op-node logs
journalctl -u op-node -f

# op-batcher logs
journalctl -u op-batcher -f

# op-proposer logs
journalctl -u op-proposer -f
```

### Useful Commands

```bash
# Check L2 sync status
cast rpc --rpc-url http://localhost:8545 eth_syncing

# Check op-node sync status
curl http://localhost:9545/v1/rollup/status | jq

# Check latest L1 block seen by op-node
curl http://localhost:9545/v1/rollup/l1 | jq
```

---

## Conclusion

This plan provides a complete path to deploy your OP Stack rollup to Celo Mainnet. The key challenge is that **Optimism does not natively support Celo**, so all configuration files must be manually updated to use Celo chain IDs, RPC endpoints, and contract addresses.

The deployment is straightforward but requires careful attention to:
1. Configuration file updates
2. Wallet funding
3. Service configuration
4. Ongoing monitoring

Once deployed, you'll have a fully functional L2 rollup that settles to Celo Mainnet with a single centralized sequencer.
