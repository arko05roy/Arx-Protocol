# Phase 4: Initialize L2 (op-geth & op-node)

**Status**: Ready to Initialize  
**L1 Contracts**: ✅ Deployed  
**Network**: Celo Sepolia (Chain ID: 11142220)  
**L2 Chain ID**: 424242

## Step 1: Create L2 Deployment Directory

```bash
mkdir -p /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
```

## Step 2: Create rollup.json (op-node configuration)

```bash
cat > rollup.json << 'EOF'
{
  "genesis": {
    "l1": {
      "hash": "0x6de784206f025d5d788cebbc665e54cf6daaa169f3c8626bcf9c1bdc6ad343fa",
      "number": 8539727
    },
    "l2": {
      "hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
      "number": 0
    },
    "l2_time": 0,
    "system_config": {
      "batcherAddr": "0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62",
      "overhead": "0x0000000000000000000000000000000000000000000000000000000000000834",
      "scalar": "0x00000000000000000000000000000000000000000000000000000000000f4240",
      "gasLimit": 30000000
    }
  },
  "block_time": 2,
  "max_sequencer_drift": 600,
  "seq_window_size": 720,
  "channel_timeout": 60,
  "l1_chain_id": 11142220,
  "l2_chain_id": 424242,
  "regolith_time": 0,
  "canyon_time": 0,
  "delta_time": 0,
  "ecotone_time": 0,
  "fjord_time": 0,
  "batch_inbox_address": "0xff00000000000000000000000000000000424242",
  "deposit_contract_address": "0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1",
  "l1_system_config_address": "0xC7D71BC3bF37C129fa12c81377B8566661435a96"
}
EOF
```

## Step 3: Create addresses.json

```bash
cat > addresses.json << 'EOF'
{
  "AddressManager": "0xb7D614FEAC4179069246dCd452Fa1Ec21FEdaf17",
  "L1CrossDomainMessengerProxy": "0xaF03e76b94b1dFdF2DaF8ed0ef13DC9dE5B23dD8",
  "L1StandardBridgeProxy": "0x022B27F7F11Ce7841b53E8E00735C62c10B56dB6",
  "L1ERC721BridgeProxy": "0x713C552Fa215D1a8a832d0A44461f9728A52a62E",
  "OptimismPortalProxy": "0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1",
  "SystemConfigProxy": "0xC7D71BC3bF37C129fa12c81377B8566661435a96",
  "DisputeGameFactoryProxy": "0x47EdA6d3E07ce233AB48e83Fb26329e077b40e8e",
  "SuperchainConfigProxy": "0xDc82c0362A241Aa94d53546648EACe48C9773dAa"
}
EOF
```

## Step 4: Copy Genesis File

```bash
# The genesis file will be generated after L1 deployment
# For now, we'll create a minimal genesis
cat > genesis.json << 'EOF'
{
  "config": {
    "chainId": 424242,
    "homesteadBlock": 0,
    "eip150Block": 0,
    "eip155Block": 0,
    "eip158Block": 0,
    "byzantiumBlock": 0,
    "constantinopleBlock": 0,
    "petersburgBlock": 0,
    "istanbulBlock": 0,
    "muirGlacierBlock": 0,
    "berlinBlock": 0,
    "londonBlock": 0,
    "arrowGlacierBlock": 0,
    "grayGlacierBlock": 0,
    "mergeNetsplitBlock": 0,
    "shanghaiBlock": 0,
    "cancunBlock": 0
  },
  "difficulty": "0x1",
  "gasLimit": "0x1c9c380",
  "alloc": {}
}
EOF
```

## Step 5: Create JWT Secret

```bash
openssl rand -hex 32 > jwt-secret.txt
cat jwt-secret.txt
```

## Step 6: Build op-node

```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-node
make op-node
```

## Step 7: Create op-node Configuration

```bash
cat > /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/op-node.env << 'EOF'
# L1 Configuration
OP_NODE_L1_ETH_RPC=https://rpc.ankr.com/celo_sepolia
OP_NODE_L1_BEACON_HTTP=

# L2 Configuration
OP_NODE_L2_ENGINE_AUTH=/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/jwt-secret.txt
OP_NODE_L2_ENGINE_RPC=http://localhost:8551

# Rollup Configuration
OP_NODE_ROLLUP_CONFIG=/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/rollup.json

# Logging
OP_NODE_LOG_LEVEL=info

# Metrics
OP_NODE_METRICS_ENABLED=true
OP_NODE_METRICS_ADDR=0.0.0.0
OP_NODE_METRICS_PORT=7300

# P2P (optional)
OP_NODE_P2P_DISABLE=true
EOF
```

## Step 8: Initialize op-geth

For now, we'll use Docker or a pre-built geth. The initialization requires:

```bash
# Create geth data directory
mkdir -p /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/geth-data

# Initialize geth with genesis (requires geth binary)
# This step will be completed once op-geth is available
```

## Environment Setup

```bash
# Load environment
source /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/.envrc.celo-sepolia

# Export L2 variables
export L2_CHAIN_ID=424242
export L2_RPC_URL=http://localhost:8545
export L2_ENGINE_RPC=http://localhost:8551
export JWT_SECRET=$(cat /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/jwt-secret.txt)
```

## Next Steps

1. **Build op-node** - Compile the consensus layer
2. **Start op-geth** - Initialize and run the execution layer
3. **Start op-node** - Run the consensus layer
4. **Verify L2** - Test connectivity and basic operations
5. **Phase 5** - Start op-batcher and op-proposer

## Key Addresses for Reference

- **Sequencer**: `0xB24e7987af06aF7CFB94E4021d0B3CB8f80f0E49`
- **Batcher**: `0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62`
- **Proposer**: `0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47`
- **Admin**: `0x89a26a33747b293430D4269A59525d5D0D5BbE65`

## Troubleshooting

- **JWT Secret**: Must be 32 bytes (64 hex characters)
- **RPC URLs**: Verify connectivity before starting services
- **Port Conflicts**: Ensure ports 8545, 8551, 7300 are available
- **Logs**: Check `/l2-deployment/logs/` for service output
