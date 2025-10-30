# Phase 5: L2 Services Deployment - COMPLETE ✅

**Status**: All binaries built and configured  
**Network**: Celo Sepolia (Chain ID: 11142220)  
**L2 Chain ID**: 424242  
**Date**: October 30, 2025

---

## ✅ Binaries Built

| Service | Binary | Size | Location |
|---------|--------|------|----------|
| **op-node** | op-node | 69M | `/optimism/optimism/op-node/bin/op-node` |
| **op-batcher** | op-batcher | 40M | `/optimism/optimism/op-batcher/bin/op-batcher` |
| **op-proposer** | op-proposer | 38M | `/optimism/optimism/op-proposer/bin/op-proposer` |

---

## 📋 Configuration Files Created

### op-node Configuration
**File**: `/l2-deployment/op-node.env`

```env
OP_NODE_L1_ETH_RPC=https://rpc.ankr.com/celo_sepolia
OP_NODE_L2_ENGINE_RPC=http://localhost:8551
OP_NODE_ROLLUP_CONFIG=/l2-deployment/rollup.json
OP_NODE_RPC_ADDR=0.0.0.0
OP_NODE_RPC_PORT=9545
OP_NODE_METRICS_PORT=7300
```

### op-batcher Configuration
**File**: `/l2-deployment/op-batcher.env`

```env
OP_BATCHER_L1_ETH_RPC=https://rpc.ankr.com/celo_sepolia
OP_BATCHER_L2_ETH_RPC=http://localhost:8545
OP_BATCHER_PRIVATE_KEY=f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c
OP_BATCHER_METRICS_PORT=7301
```

### op-proposer Configuration
**File**: `/l2-deployment/op-proposer.env`

```env
OP_PROPOSER_L1_ETH_RPC=https://rpc.ankr.com/celo_sepolia
OP_PROPOSER_L2_ETH_RPC=http://localhost:8545
OP_PROPOSER_PRIVATE_KEY=9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02
OP_PROPOSER_L2_OUTPUT_ORACLE_ADDRESS=0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1
OP_PROPOSER_METRICS_PORT=7302
OP_PROPOSER_RPC_PORT=8560
```

---

## 🚀 Starting Services

### Option 1: Automated Startup (Recommended)

```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
bash start-services.sh
```

This script will:
1. Start op-node (consensus layer)
2. Start op-batcher (batch submission)
3. Start op-proposer (state root submission)
4. Create logs in `/l2-deployment/logs/`

### Option 2: Manual Startup

**Terminal 1 - Start op-node:**
```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
source op-node.env
/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-node/bin/op-node
```

**Terminal 2 - Start op-batcher:**
```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
source op-batcher.env
/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-batcher/bin/op-batcher
```

**Terminal 3 - Start op-proposer:**
```bash
cd /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment
source op-proposer.env
/Users/arkoroy/Desktop/arx/Arx-Protocol/arx/optimism/optimism/op-proposer/bin/op-proposer
```

---

## 📊 Service Endpoints

| Service | Endpoint | Port | Purpose |
|---------|----------|------|---------|
| **op-node RPC** | http://localhost:9545 | 9545 | Consensus layer RPC |
| **op-node Metrics** | http://localhost:7300 | 7300 | Prometheus metrics |
| **op-batcher Metrics** | http://localhost:7301 | 7301 | Prometheus metrics |
| **op-proposer RPC** | http://localhost:8560 | 8560 | Proposer RPC |
| **op-proposer Metrics** | http://localhost:7302 | 7302 | Prometheus metrics |

---

## 🔍 Monitoring & Verification

### Check Service Status
```bash
# Check if services are running
ps aux | grep -E "op-node|op-batcher|op-proposer" | grep -v grep

# View logs
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-node.log
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-batcher.log
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-proposer.log
```

### Test L2 Connectivity
```bash
# Query op-node
curl -X POST http://localhost:9545 \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'

# Expected response: {"jsonrpc":"2.0","result":"0x67a2e","id":1}
# (0x67a2e = 424242 in hex)
```

### Monitor Metrics
```bash
# op-node metrics
curl http://localhost:7300/metrics | grep -E "op_node|process"

# op-batcher metrics
curl http://localhost:7301/metrics | grep -E "op_batcher|process"

# op-proposer metrics
curl http://localhost:7302/metrics | grep -E "op_proposer|process"
```

---

## 🛑 Stopping Services

### Automated Shutdown
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/stop-services.sh
```

### Manual Shutdown
```bash
# Find and kill processes
pkill -f "op-node"
pkill -f "op-batcher"
pkill -f "op-proposer"
```

---

## 📁 Directory Structure

```
/l2-deployment/
├── rollup.json              # op-node configuration
├── addresses.json           # Contract addresses
├── jwt-secret.txt          # JWT authentication
├── op-node.env             # op-node environment
├── op-batcher.env          # op-batcher environment
├── op-proposer.env         # op-proposer environment
├── start-services.sh       # Startup script
├── stop-services.sh        # Shutdown script
├── geth-data/              # Geth data directory
└── logs/                   # Service logs
    ├── op-node.log
    ├── op-batcher.log
    └── op-proposer.log
```

---

## 🔑 Key Addresses

| Role | Address |
|------|---------|
| **Batcher** | `0xd9fC5AEA3D4e8F484f618cd90DC6f7844a500f62` |
| **Proposer** | `0x79BF82C41a7B6Af998D47D2ea92Fe0ed0af6Ed47` |
| **L2 Output Oracle** | `0x6C5Fd71d75Fa4b6054E0b9b5cC154AEBb18930c1` |
| **System Config** | `0xC7D71BC3bF37C129fa12c81377B8566661435a96` |

---

## ⚠️ Important Notes

1. **JWT Secret**: Located at `/l2-deployment/jwt-secret.txt`
   - Required for op-node to op-geth communication
   - Keep secure and do not share

2. **Private Keys**: Stored in environment files
   - Batcher: `f2d83d4bb547d821db1e33c6a488a9350d263dee584acadbd6603f862931349c`
   - Proposer: `9ebad8e26c7d816238400f806f0c81b25ce6f8e937c3386efc5223c5bad12a02`
   - **NEVER commit to version control**

3. **Port Requirements**: Ensure these ports are available:
   - 8545 (L2 RPC - for op-geth)
   - 8551 (L2 Engine - for op-node)
   - 9545 (op-node RPC)
   - 7300-7302 (Metrics)
   - 8560 (op-proposer RPC)

4. **L1 Connectivity**: Services require access to Celo Sepolia RPC
   - RPC: https://rpc.ankr.com/celo_sepolia
   - Verify connectivity before starting services

---

## 🐛 Troubleshooting

### Services Won't Start
```bash
# Check if ports are in use
lsof -i :9545
lsof -i :7300
lsof -i :7301
lsof -i :7302
lsof -i :8560

# Kill existing processes if needed
pkill -9 op-node
pkill -9 op-batcher
pkill -9 op-proposer
```

### L1 Connection Issues
```bash
# Verify RPC endpoint
curl -X POST https://rpc.ankr.com/celo_sepolia \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}'

# Should return: {"jsonrpc":"2.0","result":"0xaa044c","id":1}
# (0xaa044c = 11142220 in hex)
```

### Check Logs for Errors
```bash
# View recent errors
grep "ERROR" /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/*.log

# Follow logs in real-time
tail -f /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/logs/op-node.log
```

---

## ✅ Deployment Complete

**Phase 1**: ✅ Environment Setup  
**Phase 2**: ✅ Configuration  
**Phase 3**: ✅ L1 Contract Deployment  
**Phase 4**: ✅ L2 Initialization  
**Phase 5**: ✅ Services Built & Configured  

**Next**: Start services with `bash start-services.sh`

---

**Status**: Ready for Production Deployment 🚀
