# 🚀 CELO SEPOLIA L3 BLOCKCHAIN - COMPLETE SETUP

## ⚡ TL;DR (Quick Start)

### Prerequisites
- Docker Desktop installed and running
- Nothing else needed

### Start Your Blockchain
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/START_L3_COMPLETE.sh
```

### Monitor Your Blockchain
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/MONITOR.sh
```

### Stop Your Blockchain
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/STOP_L3.sh
```

---

## 📋 WHAT YOU GET

| Component | Status | Purpose |
|-----------|--------|---------|
| **op-geth** | ✅ Included | L3 Sequencer (Execution Layer) |
| **op-batcher** | ✅ Included | Submits batches to Celo Sepolia L1 |
| **op-proposer** | ✅ Included | Submits state roots to Celo Sepolia L1 |
| **Monitoring** | ✅ Included | Real-time dashboard with logs |

---

## 💰 YOUR ACCOUNT

```
Address:     0xABaF59180e0209bdB8b3048bFbe64e855074C0c4
Private Key: 0x9ef01f9bd02e2ee682be5c50c189720a37773ab58b5b031ebdb8489940cd01ad
Balance:     100,000 GAIA tokens (pre-minted in genesis)
Chain ID:    424242
RPC:         http://localhost:8545
```

---

## 🧪 TEST COMMANDS

### Send a Transaction
```bash
cast send \
  --rpc-url http://localhost:8545 \
  --private-key 0x9ef01f9bd02e2ee682be5c50c189720a37773ab58b5b031ebdb8489940cd01ad \
  --value 1ether \
  0x89a26a33747b293430D4269A59525d5D0D5BbE65
```

### Check Your Balance
```bash
cast balance 0xABaF59180e0209bdB8b3048bFbe64e855074C0c4 \
  --rpc-url http://localhost:8545
```

### Get Current Block
```bash
cast block-number --rpc-url http://localhost:8545
```

### Deploy a Contract
```bash
forge create \
  --rpc-url http://localhost:8545 \
  --private-key 0x9ef01f9bd02e2ee682be5c50c189720a37773ab58b5b031ebdb8489940cd01ad \
  src/MyContract.sol:MyContract
```

---

## 🌐 CONNECT IN METAMASK

1. Open MetaMask
2. Click **Settings** → **Networks** → **Add a network**
3. Fill in:
   - **Network Name**: Celo Sepolia L3
   - **RPC URL**: http://localhost:8545
   - **Chain ID**: 424242
   - **Currency Symbol**: GAIA
4. Click **Save**
5. Import your account with private key

---

## 📊 MONITORING DASHBOARD

The MONITOR.sh script shows:
- ✅ Service status (op-geth, op-batcher, op-proposer)
- ✅ Current block height
- ✅ Your account balance
- ✅ Gas price
- ✅ Recent logs from batcher and proposer
- ✅ Real-time updates every 5 seconds

---

## 🔧 TROUBLESHOOTING

### "Transaction indexing is in progress"
- **Cause**: op-geth is indexing transactions (normal on startup)
- **Solution**: Wait 30-60 seconds and retry

### "Connection refused"
- **Cause**: op-geth not running
- **Solution**: Run START_L3_COMPLETE.sh again

### "Docker not found"
- **Cause**: Docker Desktop not running
- **Solution**: Open Docker Desktop from Applications

### Services not starting
- **Cause**: Port already in use
- **Solution**: Kill existing processes: `pkill -f "op-batcher|op-proposer|op-node" && docker stop celo-l3-geth`

---

## 📁 FILES

```
/l2-deployment/
├── START_L3_COMPLETE.sh    # Start everything
├── MONITOR.sh              # Monitor dashboard
├── STOP_L3.sh              # Stop everything
├── QUICK_START.md          # Quick reference
├── README.md               # This file
├── genesis.json            # L3 genesis (pre-minted tokens)
├── rollup.json             # L3 configuration
├── jwt-secret.txt          # JWT authentication
├── geth-data/              # op-geth data directory
└── logs/
    ├── op-batcher.log      # Batch submitter logs
    └── op-proposer.log     # State root submitter logs
```

---

## 🎯 WORKFLOW

### First Time
1. Install Docker Desktop
2. Run: `bash START_L3_COMPLETE.sh`
3. Wait 30 seconds
4. Run: `bash MONITOR.sh` (in new terminal)
5. See your blockchain running!

### Every Time You Start
1. Open Docker Desktop
2. Run: `bash START_L3_COMPLETE.sh`
3. Run: `bash MONITOR.sh` (in new terminal)
4. Use your blockchain!

### When Done
1. Run: `bash STOP_L3.sh`
2. Close Docker Desktop (optional)

---

## 🚀 YOU'RE READY!

Your Celo Sepolia L3 blockchain is:
- ✅ Fully operational
- ✅ Settling to Celo Sepolia L1
- ✅ Ready for contracts and transactions
- ✅ Monitored and logged

**Start your blockchain now:**
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/START_L3_COMPLETE.sh
```

**Monitor it:**
```bash
bash /Users/arkoroy/Desktop/arx/Arx-Protocol/arx/l2-deployment/MONITOR.sh
```

**Enjoy! 🎉**
