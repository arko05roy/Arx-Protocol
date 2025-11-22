# ARX L3 Blockchain

Your Layer 3 blockchain on Optimism Bedrock stack, settling to Celo Sepolia.

## Quick Start

```bash
# Start the blockchain
./RUN_L3.sh

# Stop the blockchain
Press Ctrl+C
```

## What Happens When You Run It

1. **Cleanup**: Stops any existing processes
2. **Start op-geth**: Execution layer starts in Docker
3. **Start op-node**: Consensus layer begins producing blocks
4. **Fund ARX Account**: `0xabaf59180e0209bdb8b3048bfbe64e855074c0c4` receives 10,000 ETH
5. **Start op-batcher**: Begins submitting batches to Celo Sepolia
6. **Monitor**: Shows real-time blockchain status

## Network Details

- **L3 Chain ID**: 424242
- **L3 RPC**: http://localhost:8545
- **L3 WebSocket**: ws://localhost:8546
- **L1**: Celo Sepolia (Chain ID: 11142220)

## ARX Dapp Account

- **Address**: `0xabaf59180e0209bdb8b3048bfbe64e855074c0c4`
- **Initial Balance**: 10,000 ETH
- **Purpose**: Interact with ARX Dapp

## View Batches on Explorer

Your batches settling to Celo Sepolia:
https://sepolia.celoscan.io/address/0xd9fc5aea3d4e8f484f618cd90dc6f7844a500f62

## Services & Ports

| Service | Port | Purpose |
|---------|------|---------|
| op-geth | 8545 | HTTP RPC |
| op-geth | 8546 | WebSocket |
| op-geth | 8551 | Auth RPC |
| op-node | 9545 | Rollup RPC |
| op-node | 7300 | Metrics |
| op-batcher | 8547 | Batcher RPC |
| op-batcher | 7301 | Metrics |
| op-proposer | 7302 | Metrics |

## Log Files

All logs are stored in `logs/`:

- `op-node.log` - Consensus layer logs
- `op-batcher.log` - Batch submission logs
- `op-proposer.log` - State root submission logs

## Troubleshooting

### View logs in real-time
```bash
# Node logs
tail -f logs/op-node.log

# Batcher logs
tail -f logs/op-batcher.log
```

### Check current block
```bash
cast block-number --rpc-url http://localhost:8545
```

### Check account balance
```bash
cast balance 0xabaf59180e0209bdb8b3048bfbe64e855074c0c4 --rpc-url http://localhost:8545
```

### Send a test transaction
```bash
cast send 0xYourAddress \
  --value 1ether \
  --private-key 0xf0071a1eef433a24b6603da004f67c6aad2513718c54ec0c70504a88de4edb88 \
  --rpc-url http://localhost:8545 \
  --legacy
```

## Important Files

- `RUN_L3.sh` - Main blockchain runner script
- `rollup.json` - Rollup configuration
- `genesis.json` - L3 genesis state
- `jwt-secret.txt` - JWT secret for op-geth <-> op-node auth
- `celo-sepolia-l1.json` - L1 chain configuration

## Configuration Changes

All critical fixes applied:
- ✅ Scalar overflow fixed in `rollup.json`
- ✅ Genesis funded with test accounts
- ✅ Batcher throttling disabled
- ✅ L1 chain config added for Celo Sepolia
- ✅ Correct genesis hash in rollup config

## When Script Stops

Everything stops:
- Docker container (op-geth) is removed
- All processes (node, batcher, proposer) are killed
- Blockchain stops producing blocks
- No more batches submitted to L1

## Data Persistence

- Blockchain data: `geth-data/` directory
- Survives script restarts
- To reset blockchain: `rm -rf geth-data && mkdir geth-data`
